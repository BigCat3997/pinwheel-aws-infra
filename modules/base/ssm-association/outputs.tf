output "id" {
  description = "Association ID"
  value       = aws_ssm_association.this.association_id
}

output "arn" {
  description = "Association ARN"
  value       = aws_ssm_association.this.arn
}
