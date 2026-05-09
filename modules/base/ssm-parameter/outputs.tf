output "name" {
  description = "Parameter name"
  value       = aws_ssm_parameter.this.name
}

output "arn" {
  description = "Parameter ARN"
  value       = aws_ssm_parameter.this.arn
}

output "version" {
  description = "Current parameter version"
  value       = aws_ssm_parameter.this.version
}
