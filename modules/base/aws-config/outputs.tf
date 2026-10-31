output "recorder_name" {
  description = "Configuration recorder name"
  value       = aws_config_configuration_recorder.this.name
}

output "delivery_channel_name" {
  description = "Delivery channel name"
  value       = aws_config_delivery_channel.this.name
}

output "rule_arns" {
  description = "Config rule ARNs keyed by rule name"
  value       = merge({ for k, r in aws_config_config_rule.this : k => r.arn }, { for k, r in aws_config_config_rule.custom : k => r.arn })
}
