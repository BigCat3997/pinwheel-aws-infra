locals {
  vpc_id = var.create ? aws_vpc.this[0].id : data.aws_vpc.this[0].id

  flow_logs_use_cloudwatch = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs"

  flow_logs_log_group_name_effective = coalesce(var.flow_logs_log_group_name, "/aws/vpc/${var.name}/flow-logs")

  flow_logs_destination_arn_effective = var.flow_logs_destination_arn != null ? var.flow_logs_destination_arn : (
    local.flow_logs_use_cloudwatch ? aws_cloudwatch_log_group.flow_logs[0].arn : null
  )

  flow_logs_iam_role_arn_effective = local.flow_logs_use_cloudwatch ? (
    var.flow_logs_iam_role_arn != null ? var.flow_logs_iam_role_arn : aws_iam_role.flow_logs[0].arn
  ) : null
}
