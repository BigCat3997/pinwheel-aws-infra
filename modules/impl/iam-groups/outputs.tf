output "administrator_group_name" {
  description = "Name of the administrator IAM group"
  value       = module.administrator_group.group_name
}

output "administrator_group_arn" {
  description = "ARN of the administrator IAM group"
  value       = module.administrator_group.group_arn
}

output "administrator_members" {
  description = "Users assigned to the administrator group"
  value       = module.administrator_group.members
}

output "developer_group_name" {
  description = "Name of the developer IAM group"
  value       = module.developer_group.group_name
}

output "developer_group_arn" {
  description = "ARN of the developer IAM group"
  value       = module.developer_group.group_arn
}

output "developer_members" {
  description = "Users assigned to the developer group"
  value       = module.developer_group.members
}
