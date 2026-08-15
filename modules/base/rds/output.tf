output "id" {
  description = "RDS instance ID"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].id : aws_db_instance.this[0].id
}

output "arn" {
  description = "RDS instance ARN"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].arn : aws_db_instance.this[0].arn
}

output "endpoint" {
  description = "RDS endpoint"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].address : aws_db_instance.this[0].address
}

output "availability_zone" {
  description = "RDS instance availability zone"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].availability_zone : aws_db_instance.this[0].availability_zone
}

output "port" {
  description = "RDS endpoint port"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].port : aws_db_instance.this[0].port
}

output "resource_id" {
  description = "RDS resource ID"
  value       = var.manage_master_user_password ? aws_db_instance.this_managed[0].resource_id : aws_db_instance.this[0].resource_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name used by the instance"
  value       = local.effective_db_subnet_group_name
}

output "primary_database_name" {
  description = "Primary database name"
  value       = var.primary_database_name
}

output "secondary_database_name" {
  description = "Secondary database name"
  value       = var.secondary_database_name
}
