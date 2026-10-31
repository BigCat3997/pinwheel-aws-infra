output "arn" {
  description = "Event bus ARN"
  value       = aws_cloudwatch_event_bus.this.arn
}

output "name" {
  description = "Event bus name"
  value       = aws_cloudwatch_event_bus.this.name
}
