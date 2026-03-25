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

output "access_key_ids" {
  description = "List of access key ids created for the user."
  value       = [for key in aws_iam_access_key.key : key.id]
}

output "secret_access_key" {
  description = "Secret access key if created (null otherwise)."
  value       = try(aws_iam_access_key.key[0].secret, null)
  sensitive   = true
}

output "secret_access_keys" {
  description = "List of secret access keys created for the user."
  value       = [for key in aws_iam_access_key.key : key.secret]
  sensitive   = true
}

output "aws_cli_credentials" {
  description = "AWS CLI credentials object for the first access key with environment variable names."
  value = {
    AWS_ACCESS_KEY_ID     = try(aws_iam_access_key.key[0].id, null)
    AWS_SECRET_ACCESS_KEY = try(aws_iam_access_key.key[0].secret, null)
  }
  sensitive = true
}

output "codecommit_service_user_name" {
  description = "Service user name for CodeCommit HTTPS Git access if created (null otherwise)."
  value       = try(aws_iam_service_specific_credential.codecommit_https[0].service_user_name, null)
}

output "codecommit_service_password" {
  description = "Service password for CodeCommit HTTPS Git access if created (null otherwise)."
  value       = try(aws_iam_service_specific_credential.codecommit_https[0].service_password, null)
  sensitive   = true
}

output "attached_policy_arn" {
  description = "The ARN of a managed policy attached by this module (empty string if none)."
  value       = try(aws_iam_user_policy_attachment.attach[0].policy_arn, "")
}

output "console_password" {
  description = "AWS Console password for login profile (null if not created)."
  value       = try(aws_iam_user_login_profile.this[0].password, null)
  sensitive   = true
}
