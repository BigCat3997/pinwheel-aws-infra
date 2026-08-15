data "aws_vpc" "this" {
  count = var.create ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [var.name]
  }
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = local.flow_logs_use_cloudwatch && var.flow_logs_iam_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "flow_logs" {
  count = local.flow_logs_use_cloudwatch && var.flow_logs_iam_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      local.flow_logs_destination_arn_effective,
      "${local.flow_logs_destination_arn_effective}:*"
    ]
  }
}
