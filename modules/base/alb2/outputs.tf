output "id" {
  value = aws_lb.this.id
}

output "arn" {
  value = aws_lb.this.arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}

output "target_group_arns" {
  value = { for k, tg in aws_lb_target_group.this : k => tg.arn }
}

output "listener_arns" {
  value = { for k, l in aws_lb_listener.this : k => l.arn }
}

output "cloudwatch_log_delivery_arns" {
  description = "Map of CloudWatch log delivery ARNs keyed by ALB log type"
  value       = { for log_type, delivery in aws_cloudwatch_log_delivery.this : log_type => delivery.arn }
}
