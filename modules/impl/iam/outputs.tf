output "user_id" {
  description = "Id of the created user."
  value       = module.local_user_iam.id
}

output "user_arn" {
  description = "ARN of the created user."
  value       = module.local_user_iam.arn
}

output "user_console_username" {
  description = "Name of the created user."
  value       = module.local_user_iam.name
}

output "user_console_password" {
  description = "AWS Console password for the created user (null if login profile is not created)."
  value       = module.local_user_iam.console_password
  sensitive   = true
}

output "user_access_key_id" {
  description = "Access key id for the created user."
  value       = module.local_user_iam.access_key_id
}

output "user_secret_access_key" {
  description = "Secret access key for the created user."
  value       = module.local_user_iam.secret_access_key
  sensitive   = true
}

output "codecommit_https_user_name" {
  description = "HTTPS Git user name for AWS CodeCommit."
  value       = module.local_user_iam.codecommit_service_user_name
}

output "codecommit_https_password" {
  description = "HTTPS Git password for AWS CodeCommit."
  value       = module.local_user_iam.codecommit_service_password
  sensitive   = true
}
