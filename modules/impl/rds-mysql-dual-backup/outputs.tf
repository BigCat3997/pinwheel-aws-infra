output "rds_id" {
  description = "RDS instance id"
  value       = module.local_rds.id
}

output "rds_arn" {
  description = "RDS instance arn"
  value       = module.local_rds.arn
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.local_rds.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = module.local_rds.port
}

output "automated_backup_window_utc" {
  description = "RDS automated backup window in UTC"
  value       = var.automated_backup_window
}

output "aws_backup_vault_name" {
  description = "AWS Backup vault name"
  value       = try(aws_backup_vault.this[0].name, null)
}

output "aws_backup_plan_id" {
  description = "AWS Backup plan id"
  value       = try(aws_backup_plan.this[0].id, null)
}

output "aws_backup_selection_id" {
  description = "AWS Backup selection id"
  value       = try(aws_backup_selection.this[0].id, null)
}

output "aws_backup_role_arn" {
  description = "Custom IAM role ARN used by AWS Backup"
  value       = try(module.local_aws_backup_role[0].role_arn, null)
}

output "aws_backup_custom_backup_policy_arn" {
  description = "Custom IAM policy ARN for AWS Backup jobs"
  value       = try(module.local_aws_backup_policy_backup[0].policy_arn, null)
}

output "aws_backup_custom_restore_policy_arn" {
  description = "Custom IAM policy ARN for AWS Backup restore jobs"
  value       = try(module.local_aws_backup_policy_restore[0].policy_arn, null)
}

output "aws_backup_schedule_expression" {
  description = "AWS Backup schedule expression"
  value       = var.aws_backup_schedule_expression
}
