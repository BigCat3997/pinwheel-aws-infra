output "group_name" {
  description = "Name of the IAM group"
  value       = aws_iam_group.this.name
}

output "group_arn" {
  description = "ARN of the IAM group"
  value       = aws_iam_group.this.arn
}

output "group_id" {
  description = "ID of the IAM group"
  value       = aws_iam_group.this.id
}

output "group_unique_id" {
  description = "Unique ID of the IAM group"
  value       = aws_iam_group.this.unique_id
}

output "membership_name" {
  description = "Name of the group membership resource if users were assigned"
  value       = try(aws_iam_group_membership.this[0].name, null)
}

output "members" {
  description = "IAM users assigned to the group"
  value       = try(aws_iam_group_membership.this[0].users, [])
}

output "attached_policy_arns" {
  description = "Managed policy ARNs attached to the group"
  value       = sort([for attachment in aws_iam_group_policy_attachment.managed : attachment.policy_arn])
}

output "inline_policy_names" {
  description = "Names of inline policies attached to the group"
  value       = sort([for policy in aws_iam_group_policy.inline : policy.name])
}
