output "id" {
  description = "EFS file system ID"
  value       = try(aws_efs_file_system.this[0].id, null)
}

output "arn" {
  description = "EFS file system ARN"
  value       = try(aws_efs_file_system.this[0].arn, null)
}

output "dns_name" {
  description = "EFS DNS name"
  value       = try(aws_efs_file_system.this[0].dns_name, null)
}

output "mount_target_ids" {
  description = "Mount target IDs by subnet ID"
  value       = { for k, v in aws_efs_mount_target.this : k => v.id }
}
