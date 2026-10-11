output "id" {
  description = "Trail name"
  value       = aws_cloudtrail.this.id
}

output "arn" {
  description = "Trail ARN"
  value       = aws_cloudtrail.this.arn
}
