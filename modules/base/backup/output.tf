output "vault_name" {
  description = "Backup vault name"
  value       = module.vault.name
}

output "plan_id" {
  description = "Backup plan ID"
  value       = try(aws_backup_plan.this[0].id, null)
}

output "selection_id" {
  description = "Backup selection ID"
  value       = try(aws_backup_selection.this[0].id, null)
}

output "role_name" {
  description = "IAM role name used by AWS Backup"
  value       = try(aws_iam_role.backup[0].name, null)
}
