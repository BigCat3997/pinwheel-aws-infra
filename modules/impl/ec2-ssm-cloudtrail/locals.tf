locals {
  bastion_mon_ec2_ami_id = coalesce(var.bastion_mon_ec2_ami_id, data.aws_ssm_parameter.amazon_linux_2023_ami.value)

  app_mon_ec2_ami_id = coalesce(var.app_mon_ec2_ami_id, data.aws_ami.rhel_9.id)

  # Session Manager needs the three ssm* interface endpoints when there is no NAT/IGW;
  # "monitoring" is for the CloudWatch agent (PutMetricData).
  ssm_endpoint_services = toset(["ssm", "ssmmessages", "ec2messages", "monitoring"])

  subnet_ids_by_name = merge(module.local_subnet.public_subnets, module.local_subnet.private_subnets)

  endpoint_subnet_ids = [
    for subnet_name in distinct(concat([var.bastion_mon_ec2_subnet_name], var.endpoint_extra_subnet_names)) :
    local.subnet_ids_by_name[subnet_name]
  ]

  # Built from the name (not the resource) to avoid a cycle with the bucket/KMS policies.
  cloudtrail_arn = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"

  # Built from the name (not the resource) so the topic policy can reference its own ARN.
  sns_topic_arn = "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"

  # Matches IAM user changes recorded by CloudTrail; shared by the forward and notify rules.
  iam_user_changes_pattern = jsonencode({
    source        = ["aws.iam"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = var.iam_user_event_names
    }
  })

  # EC2/RDS activity tracking: one forward rule (default bus) and one notify rule
  # (monitoring bus) per service. Management events are regional, so these rules only
  # see activity in var.aws_region.
  activity_tracking = {
    ec2 = {
      event_source = "ec2.amazonaws.com"
      event_names  = var.ec2_tracked_event_names
      input_paths = {
        action        = "$.detail.eventName"
        actor         = "$.detail.userIdentity.arn"
        instance      = "$.detail.requestParameters.instancesSet.items[0].instanceId"
        instance_attr = "$.detail.requestParameters.instanceId"
        time          = "$.detail.eventTime"
        ip            = "$.detail.sourceIPAddress"
        region        = "$.detail.awsRegion"
        account       = "$.account"
        error         = "$.detail.errorCode"
      }
      input_template = "\"EC2 activity: <action> on instance <instance><instance_attr> by <actor> at <time> from <ip> (region <region>, account <account>, error: <error>)\""
    }
    rds = {
      event_source = "rds.amazonaws.com"
      event_names  = var.rds_tracked_event_names
      input_paths = {
        action  = "$.detail.eventName"
        actor   = "$.detail.userIdentity.arn"
        db      = "$.detail.requestParameters.dBInstanceIdentifier"
        cluster = "$.detail.requestParameters.dBClusterIdentifier"
        time    = "$.detail.eventTime"
        ip      = "$.detail.sourceIPAddress"
        region  = "$.detail.awsRegion"
        account = "$.account"
        error   = "$.detail.errorCode"
      }
      input_template = "\"RDS activity: <action> on db instance '<db>' / cluster '<cluster>' by <actor> at <time> from <ip> (region <region>, account <account>, error: <error>)\""
    }
  }
}
