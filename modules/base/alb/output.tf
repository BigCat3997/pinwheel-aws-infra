output "id" {
  value = aws_lb.this.id
}

output "arn" {
  value = aws_lb.this.arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "lambda_target_group_arn" {
  description = "ARN of the lambda maintenance target group (null if lambda_function_arn not set)"
  value       = var.lambda_function_arn != null ? aws_lb_target_group.lambda[0].arn : null
}
