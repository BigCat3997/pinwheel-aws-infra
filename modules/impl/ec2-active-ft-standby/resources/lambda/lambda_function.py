import boto3
import time

ec2 = boto3.client("ec2")
ssm = boto3.client("ssm")

PRIMARY_NAME = "sample-primary"
STANDBY_NAME = "sample-standby"

PARAM_NAME = "ACTIVE_NODE"   # store: primary | standby


def resolve_instance_id_by_name(instance_name):
    desc = ec2.describe_instances(
        Filters=[
            {
                "Name": "tag:Name", "Values": [instance_name]
            },
            {
                "Name": "instance-state-name",
                "Values": ["pending", "running", "stopping", "stopped"]
            }
        ]
    )

    instance_ids = [
        inst["InstanceId"]
        for reservation in desc.get("Reservations", [])
        for inst in reservation.get("Instances", [])
    ]

    if not instance_ids:
        raise ValueError(f"No EC2 instance found with Name tag '{instance_name}'")

    if len(instance_ids) > 1:
        raise ValueError(
            f"Multiple EC2 instances found with Name tag '{instance_name}': {instance_ids}"
        )

    return instance_ids[0]


def get_primary_status(primary_id):
    # --- Get lifecycle state ---
    desc = ec2.describe_instances(InstanceIds=[primary_id])
    instance = desc["Reservations"][0]["Instances"][0]
    state = instance["State"]["Name"]

    # --- Default ---
    situation = "UNKNOWN"

    # --- If stopped or stopping → NOT outage ---
    if state in ["stopped", "stopping"]:
        return "INTENTIONAL_STOP"

    # --- If starting/rebooting → wait ---
    if state == "pending":
        return "STARTING"

    # --- If running → check health ---
    status = ec2.describe_instance_status(
        InstanceIds=[primary_id],
        IncludeAllInstances=True
    )

    statuses = status["InstanceStatuses"]

    if not statuses:
        return "BOOTING"

    system_status = statuses[0]["SystemStatus"]["Status"]
    instance_status = statuses[0]["InstanceStatus"]["Status"]

    if system_status == "ok" and instance_status == "ok":
        situation = "HEALTHY"

    elif system_status == "impaired":
        situation = "INFRA_OUTAGE"

    elif instance_status == "impaired":
        situation = "OS_FAILURE"

    else:
        situation = "UNKNOWN"

    return situation


def lambda_handler(event, context):
    try:
        primary_id = resolve_instance_id_by_name(PRIMARY_NAME)
        standby_id = resolve_instance_id_by_name(STANDBY_NAME)
    except Exception as e:
        return {
            "status": "instance_lookup_failed",
            "reason": str(e)
        }

    # --- 0. Prevent duplicate failover ---
    try:
        param = ssm.get_parameter(Name=PARAM_NAME)
        if param["Parameter"]["Value"] == "standby":
            return {"status": "already_failed_over"}
    except:
        pass  # first run

    # --- 1. Check primary condition ---
    situation = get_primary_status(primary_id)
    print(f"Primary situation: {situation}")

    # --- 2. Decide ---
    if situation in ["HEALTHY", "INTENTIONAL_STOP", "STARTING", "BOOTING"]:
        return {
            "status": "no_failover",
            "reason": situation
        }

    # Only failover for real problems
    if situation not in ["INFRA_OUTAGE", "OS_FAILURE"]:
        return {
            "status": "unknown_state_no_action",
            "reason": situation
        }

    # --- 3. Stop primary (split-brain protection) ---
    try:
        ec2.stop_instances(InstanceIds=[primary_id])
    except Exception as e:
        print(f"Stop primary warning: {e}")

    # --- 4. Start standby ---
    ec2.start_instances(InstanceIds=[standby_id])

    waiter = ec2.get_waiter('instance_running')
    waiter.wait(InstanceIds=[standby_id])

    time.sleep(30)  # wait SSM ready

    # --- 5. Start service on standby ---
    ssm.send_command(
        InstanceIds=[standby_id],
        DocumentName="AWS-RunShellScript",
        Parameters={
            "commands": [
                "systemctl start sample"
            ]
        }
    )

    # --- 6. Mark active node ---
    ssm.put_parameter(
        Name=PARAM_NAME,
        Value="standby",
        Overwrite=True
    )

    return {
        "status": "failover_triggered",
        "active": "standby",
        "reason": situation
    }