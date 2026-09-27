import json
import os
import re
import time

import boto3

ec2 = boto3.client("ec2")
rds = boto3.client("rds")


def _get_instance_state(instance_id: str) -> str:
    resp = ec2.describe_instances(InstanceIds=[instance_id])
    return resp["Reservations"][0]["Instances"][0]["State"]["Name"]


def _ensure_started(instance_id: str) -> None:
    state = _get_instance_state(instance_id)
    if state in ["running", "pending"]:
        return
    ec2.start_instances(InstanceIds=[instance_id])


def _ensure_stopped(instance_id: str) -> None:
    state = _get_instance_state(instance_id)
    if state in ["stopped", "stopping"]:
        return
    ec2.stop_instances(InstanceIds=[instance_id])


def _is_failover_related(event: dict) -> bool:
    detail = event.get("detail", {})
    print(f"Received event detail: {json.dumps(detail)}")
    categories = [str(c).lower() for c in detail.get("EventCategories", [])]
    message = str(detail.get("Message", "")).lower()
    event_id = str(detail.get("EventID", "")).lower()
    return "failover" in categories or "failover" in message or "failover" in event_id


def _extract_expected_az_from_message(message: str) -> str | None:
    primary_match = re.search(
        r"current\s+primary\s+host\s+is\s+in\s+availability\s+zone\s+([a-z]{2}-[a-z]+-\d[a-z])",
        message,
        flags=re.IGNORECASE,
    )
    if primary_match:
        return primary_match.group(1)

    # Prefer "to <az>" if present, else fallback to the last AZ found in message.
    to_match = re.search(r"\bto\s+([a-z]{2}-[a-z]+-\d[a-z])\b", message, flags=re.IGNORECASE)
    if to_match:
        return to_match.group(1)

    az_matches = re.findall(r"\b[a-z]{2}-[a-z]+-\d[a-z]\b", message)
    if not az_matches:
        return None
    return az_matches[-1]


def _describe_db(db_identifier: str) -> dict:
    resp = rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
    return resp["DBInstances"][0]


def _resolve_expected_primary_az(
    message: str,
    initial_az: str | None,
    primary_az: str | None,
    standby_az: str | None,
) -> str | None:
    expected_az = _extract_expected_az_from_message(message)
    if expected_az:
        return expected_az

    if initial_az and primary_az and standby_az:
        if initial_az == primary_az:
            return standby_az
        if initial_az == standby_az:
            return primary_az

    return None


def _wait_for_failover_zone_update(
    db_identifier: str,
    initial_az: str,
    expected_az: str | None,
    expected_secondary_az: str | None,
    max_attempts: int,
    poll_interval_seconds: int,
) -> tuple[dict, bool, int, bool]:
    latest = _describe_db(db_identifier)
    observed_zone_change = False
    state_settled = False

    for attempt in range(1, max_attempts + 1):
        latest = _describe_db(db_identifier)
        status = latest.get("DBInstanceStatus")
        current_az = latest.get("AvailabilityZone")
        secondary_az = latest.get("SecondaryAvailabilityZone")
        zone_changed = bool(initial_az and current_az and current_az != initial_az)
        observed_zone_change = observed_zone_change or zone_changed

        primary_matches = expected_az is None or current_az == expected_az
        secondary_matches = expected_secondary_az is None or secondary_az == expected_secondary_az
        state_settled = status == "available" and primary_matches and secondary_matches

        print(
            json.dumps(
                {
                    "attempt": attempt,
                    "db_status": status,
                    "current_az": current_az,
                    "secondary_az": secondary_az,
                    "initial_az": initial_az,
                    "expected_az": expected_az,
                    "expected_secondary_az": expected_secondary_az,
                    "zone_changed": zone_changed,
                    "observed_zone_change": observed_zone_change,
                    "state_settled": state_settled,
                }
            )
        )

        if state_settled:
            return latest, observed_zone_change, attempt, True

        if attempt < max_attempts:
            time.sleep(poll_interval_seconds)

    return latest, observed_zone_change, max_attempts, False


# def lambda_handler(event, context):
#     db_identifier = os.environ["DB_INSTANCE_IDENTIFIER"]
#     primary_instance_id = os.environ["PRIMARY_INSTANCE_ID"]
#     standby_instance_id = os.environ["STANDBY_INSTANCE_ID"]
#     primary_az = os.environ["PRIMARY_AZ"]
#     standby_az = os.environ["STANDBY_AZ"]

#     if not _is_failover_related(event):
#         return {
#             "status": "ignored_non_failover_event",
#             "event": event.get("detail", {}),
#         }

#     db = rds.describe_db_instances(DBInstanceIdentifier=db_identifier)["DBInstances"][0]
#     active_az = db.get("AvailabilityZone")

#     if active_az == primary_az:
#         desired_on = primary_instance_id
#         desired_off = standby_instance_id
#         active_node = "primary"
#     elif active_az == standby_az:
#         desired_on = standby_instance_id
#         desired_off = primary_instance_id
#         active_node = "standby"
#     else:
#         return {
#             "status": "unknown_db_az",
#             "db_primary_az": active_az,
#             "primary_ec2_az": primary_az,
#             "standby_ec2_az": standby_az,
#         }

#     _ensure_started(desired_on)
#     _ensure_stopped(desired_off)

#     return {
#         "status": "switched",
#         "db_primary_az": active_az,
#         "active_node": active_node,
#         "started_instance": desired_on,
#         "stopped_instance": desired_off,
#     }


def lambda_handler(event, context):
    print("Received Event:")
    print(json.dumps(event, indent=2))

    detail = event.get("detail", {})
    event_id = str(detail.get("EventID", "")).upper()
    db_identifier = detail.get("SourceIdentifier") or os.environ.get("DB_INSTANCE_IDENTIFIER")

    if not db_identifier:
        return {
            "statusCode": 400,
            "status": "missing_db_identifier",
            "detail": detail,
        }

    if not _is_failover_related(event):
        return {
            "statusCode": 200,
            "status": "ignored_non_failover_event",
            "event_id": event_id,
            "db_identifier": db_identifier,
        }

    initial_db = _describe_db(db_identifier)
    initial_az = initial_db.get("AvailabilityZone")
    initial_secondary_az = initial_db.get("SecondaryAvailabilityZone")
    expected_az = None
    expected_secondary_az = None
    state_settled = True
    primary_az = os.environ.get("PRIMARY_AZ")
    standby_ec2_az = os.environ.get("STANDBY_AZ")

    if event_id == "RDS-EVENT-0049":
        event_message = str(detail.get("Message", ""))
        expected_az = _resolve_expected_primary_az(
            message=event_message,
            initial_az=initial_az,
            primary_az=primary_az,
            standby_az=standby_ec2_az,
        )
        if initial_az and expected_az and initial_az != expected_az:
            expected_secondary_az = initial_az

        poll_attempts = int(os.environ.get("FAILOVER_POLL_ATTEMPTS", "20"))
        poll_interval = int(os.environ.get("FAILOVER_POLL_INTERVAL_SECONDS", "15"))

        print(
            f"RDS-EVENT-0049 detected for {db_identifier}. "
            f"Waiting for zone update (initial_az={initial_az}, initial_secondary_az={initial_secondary_az}, "
            f"expected_az={expected_az}, expected_secondary_az={expected_secondary_az}, "
            f"attempts={poll_attempts}, interval={poll_interval}s)."
        )

        db, observed_zone_change, attempts_used, state_settled = _wait_for_failover_zone_update(
            db_identifier=db_identifier,
            initial_az=initial_az,
            expected_az=expected_az,
            expected_secondary_az=expected_secondary_az,
            max_attempts=poll_attempts,
            poll_interval_seconds=poll_interval,
        )
    else:
        db = initial_db
        observed_zone_change = False
        attempts_used = 0
        state_settled = True

    db_status = db.get("DBInstanceStatus")
    current_az = db.get("AvailabilityZone")
    standby_az = db.get("SecondaryAvailabilityZone")

    print(f"Final DB status: {db_status}")
    print(f"Final primary AZ: {current_az}")
    print(f"Final standby AZ: {standby_az}")
    print(f"Expected primary AZ: {expected_az}")
    print(f"Expected secondary AZ: {expected_secondary_az}")
    print(f"State settled: {state_settled}")

    primary_instance_id = os.environ.get("PRIMARY_INSTANCE_ID")
    standby_instance_id = os.environ.get("STANDBY_INSTANCE_ID")

    if event_id == "RDS-EVENT-0049" and not state_settled:
        return {
            "statusCode": 200,
            "status": "db_state_not_settled",
            "event_id": event_id,
            "db_identifier": db_identifier,
            "db_status": db_status,
            "db_primary_az": current_az,
            "db_standby_az": standby_az,
            "expected_primary_az": expected_az,
            "expected_secondary_az": expected_secondary_az,
            "observed_zone_change": observed_zone_change,
            "attempts_used": attempts_used,
        }

    if all([primary_instance_id, standby_instance_id, primary_az, standby_ec2_az]):
        if current_az == primary_az:
            desired_on = primary_instance_id
            desired_off = standby_instance_id
            active_node = "primary"
        elif current_az == standby_ec2_az:
            desired_on = standby_instance_id
            desired_off = primary_instance_id
            active_node = "standby"
        else:
            return {
                "statusCode": 200,
                "status": "unknown_db_az",
                "event_id": event_id,
                "db_identifier": db_identifier,
                "db_status": db_status,
                "db_primary_az": current_az,
                "db_standby_az": standby_az,
                "primary_ec2_az": primary_az,
                "standby_ec2_az": standby_ec2_az,
                "expected_primary_az": expected_az,
                "expected_secondary_az": expected_secondary_az,
                "observed_zone_change": observed_zone_change,
                "attempts_used": attempts_used,
                "state_settled": state_settled,
            }

        _ensure_started(desired_on)
        _ensure_stopped(desired_off)

        return {
            "statusCode": 200,
            "status": "switched",
            "event_id": event_id,
            "db_identifier": db_identifier,
            "db_status": db_status,
            "db_primary_az": current_az,
            "db_standby_az": standby_az,
            "active_node": active_node,
            "started_instance": desired_on,
            "stopped_instance": desired_off,
            "expected_primary_az": expected_az,
            "expected_secondary_az": expected_secondary_az,
            "observed_zone_change": observed_zone_change,
            "attempts_used": attempts_used,
            "state_settled": state_settled,
        }

    return {
        "statusCode": 200,
        "status": "db_state_observed",
        "event_id": event_id,
        "db_identifier": db_identifier,
        "db_status": db_status,
        "db_primary_az": current_az,
        "db_standby_az": standby_az,
        "expected_primary_az": expected_az,
        "expected_secondary_az": expected_secondary_az,
        "observed_zone_change": observed_zone_change,
        "attempts_used": attempts_used,
        "state_settled": state_settled,
    }
