resource "aws_vpc" "this" {
  count                = var.create ? 1 : 0
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = local.flow_logs_use_cloudwatch && var.flow_logs_destination_arn == null ? 1 : 0

  name              = local.flow_logs_log_group_name_effective
  retention_in_days = var.flow_logs_log_group_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.name}-vpc-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = local.flow_logs_use_cloudwatch && var.flow_logs_iam_role_arn == null ? 1 : 0

  name               = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = local.flow_logs_use_cloudwatch && var.flow_logs_iam_role_arn == null ? 1 : 0

  name   = "${var.name}-vpc-flow-logs-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs[0].json
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id                   = local.vpc_id
  traffic_type             = var.flow_logs_traffic_type
  log_destination_type     = var.flow_logs_destination_type
  log_destination          = local.flow_logs_destination_arn_effective
  iam_role_arn             = local.flow_logs_iam_role_arn_effective
  max_aggregation_interval = var.flow_logs_max_aggregation_interval
  log_format               = var.flow_logs_log_format

  tags = merge(var.tags, {
    Name = "${var.name}-vpc-flow-log"
  })

  lifecycle {
    precondition {
      condition     = local.flow_logs_destination_arn_effective != null
      error_message = "flow_logs_destination_arn must be set when enable_flow_logs=true and no default destination can be created."
    }

    precondition {
      condition     = var.flow_logs_destination_type != "cloud-watch-logs" || local.flow_logs_iam_role_arn_effective != null
      error_message = "flow_logs_iam_role_arn must be set when using cloud-watch-logs and not creating the default IAM role."
    }
  }
}
