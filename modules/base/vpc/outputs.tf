output "id" {
  value = var.create ? aws_vpc.this[0].id : data.aws_vpc.this[0].id
}

output "cidr_block" {
  value = var.create ? aws_vpc.this[0].cidr_block : data.aws_vpc.this[0].cidr_block
}

output "flow_log_id" {
  description = "VPC Flow Log ID when flow logs are enabled"
  value       = try(aws_flow_log.this[0].id, null)
}

output "flow_logs_destination_arn" {
  description = "Effective destination ARN used by VPC Flow Logs"
  value       = var.enable_flow_logs ? local.flow_logs_destination_arn_effective : null
}

output "flow_logs_iam_role_arn" {
  description = "Effective IAM role ARN used by VPC Flow Logs for CloudWatch Logs destination"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? local.flow_logs_iam_role_arn_effective : null
}
