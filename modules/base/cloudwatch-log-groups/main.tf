resource "aws_cloudwatch_log_group" "this" {
  for_each = { for log_group in var.log_groups : log_group.name => log_group }

  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  tags              = each.value.tags
}
