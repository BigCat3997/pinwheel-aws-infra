output "id" {
  value = aws_iam_user.this.id
}

output "arn" {
  value = aws_iam_user.this.arn
}

output "name" {
  value = aws_iam_user.this.name
}

output "unique_id" {
  value = aws_iam_user.this.unique_id
}

output "access_key_id" {
  description = "Access key id if created (null otherwise)."
  value       = try(aws_iam_access_key.key[0].id, null)
}

output "secret_access_key" {
  description = "Secret access key if created (null otherwise)."
  value       = try(aws_iam_access_key.key[0].secret, null)
  sensitive   = true
}

output "attached_policy_arn" {
  description = "The ARN of a managed policy attached by this module (empty string if none)."
  value       = try(aws_iam_user_policy_attachment.attach[0].policy_arn, "")
}
