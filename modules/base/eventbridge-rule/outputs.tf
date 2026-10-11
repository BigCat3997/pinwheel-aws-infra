output "arn" {
  description = "Rule ARN"
  value       = aws_cloudwatch_event_rule.this.arn
}

output "name" {
  description = "Rule name"
  value       = aws_cloudwatch_event_rule.this.name
}
