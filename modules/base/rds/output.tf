output "id" {
  description = "RDS instance ID"
  value       = aws_db_instance.this.id
}

output "arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS endpoint port"
  value       = aws_db_instance.this.port
}

output "resource_id" {
  description = "RDS resource ID"
  value       = aws_db_instance.this.resource_id
}

output "primary_database_name" {
  description = "Primary database name"
  value       = var.primary_database_name
}

output "secondary_database_name" {
  description = "Secondary database name"
  value       = var.secondary_database_name
}
