output "name" {
  description = "Document name"
  value       = aws_ssm_document.this.name
}

output "arn" {
  description = "Document ARN"
  value       = aws_ssm_document.this.arn
}
