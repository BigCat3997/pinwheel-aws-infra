output "name" {
  value = try(aws_backup_vault.this[0].name, null)
}
