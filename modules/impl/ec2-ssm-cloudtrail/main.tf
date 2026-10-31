module "local_vpc" {
  source     = "../../base/vpc"
  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.common_tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.common_tags

  depends_on = [module.local_vpc]
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"
  vpc_id = module.local_vpc.id
  name   = var.internet_gateway_name
  tags   = var.common_tags
}

module "local_eip" {
  source   = "../../base/eip"
  for_each = { for ngw in var.nat_gateways : ngw.eip_name => ngw }

  name = each.key
  tags = var.common_tags
}

module "local_nat_gateway" {
  source   = "../../base/nat-gateway"
  for_each = { for ngw in var.nat_gateways : ngw.name => ngw }

  name      = each.key
  eip_id    = module.local_eip[each.value.eip_name].id
  subnet_id = module.local_subnet.public_subnets[each.value.subnet_name]
  tags      = var.common_tags

  depends_on = [module.local_internet_gateway]
}

module "local_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.id
  nat_gateway_ids      = { for name, ngw in module.local_nat_gateway : name => ngw.id }
  tags                 = var.common_tags

  depends_on = [module.local_vpc, module.local_internet_gateway]
}

module "local_route_table_association" {
  source                  = "../../base/route-table-association"
  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = var.private_rtb_assoc
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = module.local_subnet.private_subnets
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_bastion_mon_ec2_sg" {
  source = "../../base/sg"

  name   = "${var.bastion_mon_ec2_name}-sg"
  vpc_id = module.local_vpc.id

  # No inbound rules: access is through Session Manager only.
  security_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all inbound"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.common_tags
}

module "local_app_mon_ec2_sg" {
  source = "../../base/sg"

  name   = "${var.app_mon_ec2_name}-sg"
  vpc_id = module.local_vpc.id

  # Internal only: SSH is allowed from the Amazon Linux EC2 (bastion) alone.
  security_rules = [
    {
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      security_group_id = module.local_bastion_mon_ec2_sg.id
      description       = "SSH from the Amazon Linux EC2"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.common_tags
}

module "local_vpc_endpoints_sg" {
  source = "../../base/sg"

  name   = "${var.bastion_mon_ec2_name}-vpce-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = module.local_bastion_mon_ec2_sg.id
      description       = "HTTPS from EC2 to SSM interface endpoints"
    },
    {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = module.local_app_mon_ec2_sg.id
      description       = "HTTPS from RHEL EC2 to SSM interface endpoints"
    }
  ]

  tags = var.common_tags
}

module "local_ssm_vpce" {
  source   = "../../base/vpce"
  for_each = local.ssm_endpoint_services

  name                = "${var.bastion_mon_ec2_name}-${each.key}-vpce"
  vpc_id              = module.local_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.endpoint_subnet_ids
  security_group_ids  = [module.local_vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags                = var.common_tags
}

module "local_mon_ec2_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.bastion_mon_ec2_name}-ssm-role"
  path                    = "/"
  description             = "EC2 role for Systems Manager Session Manager access"
  assume_role_policy_file = "${path.module}/resources/iam/ec2-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]

  tags = var.common_tags
}

module "local_bastion_mon_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = var.bastion_mon_ec2_create_key_pair
  name       = var.bastion_mon_ec2_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.bastion_mon_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_app_mon_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = var.app_mon_ec2_create_key_pair
  name       = var.app_mon_ec2_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.app_mon_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_bastion_mon_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_mon_ec2_name
  ami_id                       = local.bastion_mon_ec2_ami_id
  instance_type                = var.bastion_mon_ec2_instance_type
  subnet_id                    = local.subnet_ids_by_name[var.bastion_mon_ec2_subnet_name]
  security_group_ids           = [module.local_bastion_mon_ec2_sg.id]
  associate_public_ip          = var.bastion_mon_ec2_associate_public_ip
  user_data                    = null
  instance_profile_name        = "${var.bastion_mon_ec2_name}-profile"
  role_name                    = module.local_mon_ec2_iam_role.role_name
  volume_size                  = var.bastion_mon_ec2_volume_size
  volume_type                  = var.bastion_mon_ec2_volume_type
  volume_encrypted             = var.bastion_mon_ec2_volume_encrypted
  volume_delete_on_termination = true
  volume_tags                  = var.bastion_mon_ec2_volume_tags
  key_name                     = module.local_bastion_mon_ec2_key_pair.name
  monitoring                   = true
  tags                         = var.common_tags

  depends_on = [module.local_ssm_vpce, module.local_mon_ec2_iam_role]
}

module "local_app_mon_ec2" {
  source = "../../base/ec2"

  name                = var.app_mon_ec2_name
  ami_id              = local.app_mon_ec2_ami_id
  instance_type       = var.app_mon_ec2_instance_type
  ssh_user            = "ec2-user"
  subnet_id           = local.subnet_ids_by_name[var.app_mon_ec2_subnet_name]
  security_group_ids  = [module.local_app_mon_ec2_sg.id]
  associate_public_ip = false
  user_data = templatefile("${path.module}/templates/ec2/rhel-user-data.sh.tftpl", {
    aws_region = var.aws_region
  })
  user_data_replace_on_change  = true
  instance_profile_name        = "${var.app_mon_ec2_name}-profile"
  role_name                    = module.local_mon_ec2_iam_role.role_name
  volume_size                  = var.bastion_mon_ec2_volume_size
  volume_type                  = var.bastion_mon_ec2_volume_type
  volume_encrypted             = var.bastion_mon_ec2_volume_encrypted
  volume_delete_on_termination = true
  volume_tags                  = var.bastion_mon_ec2_volume_tags
  key_name                     = module.local_app_mon_ec2_key_pair.name
  monitoring                   = true
  tags                         = var.common_tags

  depends_on = [
    module.local_ssm_vpce,
    module.local_mon_ec2_iam_role,
    module.local_route_table_association,
    module.local_nat_gateway
  ]
}

module "kms" {
  source = "../../base/kms"

  kms_key_name = var.kms_key_name
  description  = var.kms_description
  tags         = var.common_tags
}

module "ec2_secrets" {
  source = "../../base/secret"

  secrets = [
    {
      name  = "ec2/${var.bastion_mon_ec2_name}/ec2-user/public-key"
      value = module.local_bastion_mon_ec2_key_pair.public_key
    },
    {
      name  = "ec2/${var.app_mon_ec2_name}/ec2-user/public-key"
      value = module.local_app_mon_ec2_key_pair.public_key
    },
  ]

  resource_policy = templatefile("${path.module}/templates/secrets/secret-resource-policy.json.tftpl", {
    user_arn = data.aws_caller_identity.current.arn
  })
  kms_key_id = module.kms.id

  depends_on = [
    module.local_bastion_mon_ec2_key_pair,
    module.local_app_mon_ec2_key_pair,
  ]
  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# CloudTrail
# ---------------------------------------------------------------------------

module "cloudtrail_kms" {
  source = "../../base/kms"

  kms_key_name = var.cloudtrail_kms_key_name
  description  = "KMS key for encrypting CloudTrail logs"
  policy = templatefile("${path.module}/templates/cloudtrail/kms-policy.json.tftpl", {
    account_id = data.aws_caller_identity.current.account_id
    trail_arn  = local.cloudtrail_arn
  })
  tags = var.common_tags
}

module "eventbridge_kms" {
  source = "../../base/kms"

  kms_key_name = var.eventbridge_kms_key_name
  description  = "KMS key for encrypting EventBridge event buses"
  policy = templatefile("${path.module}/templates/eventbridge/kms-policy.json.tftpl", {
    account_id = data.aws_caller_identity.current.account_id
    region     = var.aws_region
  })
  tags = var.common_tags
}

module "cloudtrail_bucket" {
  source = "../../base/s3"

  bucket_name          = var.cloudtrail_bucket_name
  force_destroy        = var.cloudtrail_bucket_force_destroy
  enable_versioning    = true
  enable_bucket_policy = true
  kms_key_id           = module.cloudtrail_kms.arn
  policy = templatefile("${path.module}/templates/cloudtrail/bucket-policy.json.tftpl", {
    bucket_name = var.cloudtrail_bucket_name
    account_id  = data.aws_caller_identity.current.account_id
    trail_arn   = local.cloudtrail_arn
  })

  tags = var.common_tags
}

module "cloudtrail" {
  source = "../../base/cloudtrail"

  name                  = var.cloudtrail_name
  s3_bucket_name        = module.cloudtrail_bucket.name
  kms_key_id            = module.cloudtrail_kms.arn
  is_multi_region_trail = var.cloudtrail_is_multi_region
  tags                  = var.common_tags

  depends_on = [module.cloudtrail_bucket]
}

# ---------------------------------------------------------------------------
# CloudWatch agent (both EC2 instances, installed through SSM State Manager so
# user_data stays untouched)
# ---------------------------------------------------------------------------

# The RHEL private subnet has no NAT: the agent package comes from S3 and metrics go
# to CloudWatch, so it needs an S3 gateway endpoint plus the "monitoring" endpoint.
module "local_s3_gateway_vpce" {
  source = "../../base/vpce"

  name              = "${var.app_mon_ec2_name}-s3-vpce"
  vpc_id            = module.local_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = values(module.local_route_table.private_route_table_ids)
  tags              = var.common_tags
}

module "cw_agent_config" {
  source = "../../base/ssm-parameter"

  name        = "AmazonCloudWatch-${var.bastion_mon_ec2_name}-config"
  description = "CloudWatch agent config: memory and root disk usage"
  type        = "String"
  value       = templatefile("${path.module}/templates/cloudwatch/agent-config.json.tftpl", {})
  tags        = var.common_tags
}

module "cw_agent_document" {
  source = "../../base/ssm-document"

  name          = "${var.bastion_mon_ec2_name}-cw-agent-setup"
  document_type = "Command"
  content = templatefile("${path.module}/templates/cloudwatch/install-configure-agent.json.tftpl", {
    config_parameter_name = module.cw_agent_config.name
  })
  tags = var.common_tags
}

# One association runs install -> configure -> verify in order, so a run only succeeds
# when the agent is installed, configured and running.
module "cw_agent_setup" {
  source = "../../base/ssm-association"

  document_name       = module.cw_agent_document.name
  association_name    = "${var.bastion_mon_ec2_name}-cw-agent-setup"
  schedule_expression = "rate(30 minutes)" # re-applies and self-heals if a run failed

  # Tag targeting applies as soon as an instance registers with SSM (no first-run race).
  targets = [{
    key    = "tag:Name"
    values = [var.bastion_mon_ec2_name, var.app_mon_ec2_name]
  }]

  depends_on = [module.local_ssm_vpce, module.local_s3_gateway_vpce, module.cw_agent_config]
}

# ---------------------------------------------------------------------------
# Log generator: a scheduled Lambda that writes random INFO/WARNING/ERROR lines
# to CloudWatch Logs, for testing log pipelines, metric filters and alarms.
# ---------------------------------------------------------------------------

module "log_generator_log_group" {
  source = "../../base/cloudwatch-log-groups2"

  name              = "/aws/lambda/${var.log_generator_name}"
  retention_in_days = var.log_generator_retention_days
  tags              = var.common_tags
}

module "log_generator_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.log_generator_name}-role"
  path                    = "/"
  description             = "Execution role for the log generator Lambda"
  assume_role_policy_file = "${path.module}/resources/iam/lambda-assume-role.json"
  managed_policy_arns     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  tags = var.common_tags
}

module "log_generator_lambda" {
  source = "../../base/lambda"

  name        = var.log_generator_name
  runtime     = "python3.12"
  handler     = "log_generator.lambda_handler"
  timeout     = 10
  memory_size = 128
  source_file = "${path.module}/lambda/log_generator.py"
  output_path = "${path.module}/lambda/log_generator.zip"
  create_role = false
  role_name   = module.log_generator_iam_role.role_name
  role_arn    = module.log_generator_iam_role.role_arn

  tags = var.common_tags

  depends_on = [module.log_generator_log_group]
}

module "log_generator_schedule" {
  source = "../../base/eventbridge-rule"

  name                 = "${var.log_generator_name}-schedule"
  description          = "Invokes the log generator Lambda on a schedule"
  schedule_expression  = var.log_generator_schedule
  target_arn           = module.log_generator_lambda.arn
  lambda_function_name = module.log_generator_lambda.name
  tags                 = var.common_tags
}

# ---------------------------------------------------------------------------
# Notifications: SNS topic with email subscriptions
# ---------------------------------------------------------------------------

module "notifications_topic" {
  source = "../../base/sns-topic"

  name         = var.sns_topic_name
  display_name = var.sns_display_name
  subscriptions = [
    for email in var.sns_email_endpoints : {
      protocol = "email"
      endpoint = email
    }
  ]
  policy = templatefile("${path.module}/templates/sns/topic-policy.json.tftpl", {
    account_id = data.aws_caller_identity.current.account_id
    topic_arn  = local.sns_topic_arn
  })
  tags = var.common_tags
}

# IAM user changes are only delivered to the default bus, so a rule there forwards
# them to the monitoring bus, where a second rule formats them and emails SNS.
# IAM events are recorded in us-east-1 (this module's region) and reach EventBridge
# through CloudTrail without needing a trail of your own.
module "monitoring_event_bus" {
  source = "../../base/eventbridge-bus"

  name               = var.monitoring_event_bus_name
  description        = "Monitoring events (IAM user changes) routed to SNS"
  kms_key_identifier = module.eventbridge_kms.arn
  tags               = var.common_tags
}

module "eventbridge_forward_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.monitoring_event_bus_name}-forward-role"
  path                    = "/"
  description             = "Lets EventBridge forward events from the default bus to ${var.monitoring_event_bus_name}"
  assume_role_policy_file = "${path.module}/resources/iam/events-assume-role.json"
  inline_policies = {
    "put-events-monitoring-bus" = templatefile("${path.module}/templates/eventbridge/put-events-policy.json.tftpl", {
      event_bus_arn = module.monitoring_event_bus.arn
      kms_key_arn   = module.eventbridge_kms.arn
    })
  }

  tags = var.common_tags
}

module "iam_user_changes_forward_rule" {
  source = "../../base/eventbridge-rule"

  name            = "${var.iam_user_events_rule_name}-forward"
  description     = "Forward IAM user change events from the default bus to ${var.monitoring_event_bus_name}"
  event_bus_name  = "default"
  event_pattern   = local.iam_user_changes_pattern
  target_arn      = module.monitoring_event_bus.arn
  target_role_arn = module.eventbridge_forward_iam_role.role_arn
  tags            = var.common_tags
}

module "iam_user_changes_rule" {
  source = "../../base/eventbridge-rule"

  name           = var.iam_user_events_rule_name
  description    = "Notify SNS when IAM users or their access are created, changed or removed"
  event_bus_name = module.monitoring_event_bus.name
  event_pattern  = local.iam_user_changes_pattern
  target_arn     = module.notifications_topic.arn

  input_transformer = {
    input_paths = {
      action  = "$.detail.eventName"
      actor   = "$.detail.userIdentity.arn"
      target  = "$.detail.requestParameters.userName"
      time    = "$.detail.eventTime"
      ip      = "$.detail.sourceIPAddress"
      account = "$.account"
      error   = "$.detail.errorCode"
    }
    input_template = "\"IAM user change detected: <action> on user '<target>' by <actor> at <time> from <ip> (account <account>, error: <error>)\""
  }

  tags = var.common_tags
}

# EC2 and RDS activity (start, stop, terminate, modify, ...): same two-hop path as the
# IAM alerts, one pair of rules per service.
module "activity_forward_rule" {
  source   = "../../base/eventbridge-rule"
  for_each = local.activity_tracking

  name           = "${var.activity_rule_prefix}-${each.key}_activity-forward"
  description    = "Forward ${each.key} activity events from the default bus to ${var.monitoring_event_bus_name}"
  event_bus_name = "default"
  event_pattern = jsonencode({
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = [each.value.event_source]
      eventName   = each.value.event_names
    }
  })
  target_arn      = module.monitoring_event_bus.arn
  target_role_arn = module.eventbridge_forward_iam_role.role_arn
  tags            = var.common_tags
}

module "activity_rule" {
  source   = "../../base/eventbridge-rule"
  for_each = local.activity_tracking

  name           = "${var.activity_rule_prefix}-${each.key}_activity"
  description    = "Notify SNS about ${each.key} activity"
  event_bus_name = module.monitoring_event_bus.name
  event_pattern = jsonencode({
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = [each.value.event_source]
      eventName   = each.value.event_names
    }
  })
  target_arn = module.notifications_topic.arn

  input_transformer = {
    input_paths    = each.value.input_paths
    input_template = each.value.input_template
  }

  tags = var.common_tags
}
