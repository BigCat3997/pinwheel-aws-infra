output "names" {
  description = "Map of log group names keyed by item key"
  value       = { for key, log_group in aws_cloudwatch_log_group.this : key => log_group.name }
}

output "arns" {
  description = "Map of log group ARNs keyed by item key"
  value       = { for key, log_group in aws_cloudwatch_log_group.this : key => log_group.arn }
}
