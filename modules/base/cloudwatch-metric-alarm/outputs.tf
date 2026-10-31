output "arn" {
  description = "Alarm ARN"
  value       = aws_cloudwatch_metric_alarm.this.arn
}

output "name" {
  description = "Alarm name"
  value       = aws_cloudwatch_metric_alarm.this.alarm_name
}
