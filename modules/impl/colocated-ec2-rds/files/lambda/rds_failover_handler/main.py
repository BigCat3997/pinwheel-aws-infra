import json
import os

import boto3


ec2 = boto3.client("ec2")
rds = boto3.client("rds")


def _instance_states(instance_ids):
    response = ec2.describe_instances(InstanceIds=instance_ids)
    return {
        instance["InstanceId"]: instance["State"]["Name"]
        for reservation in response["Reservations"]
        for instance in reservation["Instances"]
    }


def lambda_handler(event, context):
    db_identifier = os.environ["DB_INSTANCE_IDENTIFIER"]
    instances_by_az = json.loads(os.environ["INSTANCE_IDS_BY_AZ"])
    db = rds.describe_db_instances(DBInstanceIdentifier=db_identifier)["DBInstances"][0]
    db_az = db["AvailabilityZone"]

    if db_az not in instances_by_az:
        raise RuntimeError(
            f"RDS primary is in {db_az}, but EC2 capacity exists only in "
            f"{sorted(instances_by_az)}"
        )

    desired_running = set(instances_by_az[db_az])
    all_instances = [instance_id for ids in instances_by_az.values() for instance_id in ids]
    states = _instance_states(all_instances)

    to_start = [
        instance_id for instance_id in desired_running
        if states.get(instance_id) not in {"pending", "running"}
    ]
    to_stop = [
        instance_id for instance_id in set(all_instances) - desired_running
        if states.get(instance_id) not in {"stopped", "stopping"}
    ]

    # Start capacity next to the database before stopping capacity in the old AZ.
    if to_start:
        ec2.start_instances(InstanceIds=to_start)
    if to_stop:
        ec2.stop_instances(InstanceIds=to_stop)

    result = {
        "database": db_identifier,
        "database_status": db["DBInstanceStatus"],
        "database_primary_az": db_az,
        "started": to_start,
        "stopped": to_stop,
        "desired_running": sorted(desired_running),
    }
    print(json.dumps({"event": event, "result": result}, default=str))
    return result
