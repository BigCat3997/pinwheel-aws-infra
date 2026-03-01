output "user_id" {
  description = "Id of the created user."
  value       = module.user_iam.id
}

output "user_arn" {
  description = "ARN of the created user."
  value       = module.user_iam.arn
}

output "user_name" {
  description = "Name of the created user."
  value       = module.user_iam.name
}

output "user_access_key_id" {
  description = "Access key id for the created user."
  value       = module.user_iam.access_key_id
}

output "user_secret_access_key" {
  description = "Secret access key for the created user."
  value       = module.user_iam.secret_access_key
  sensitive   = true
}

output "policy_arn_used" {
  description = "The policy ARN attached to the created user. If a JSON/file was provided, this will be the created policy ARN; otherwise this will be the provided `policy_arn`."
  value       = try(module.iam_policy[0].policy_arn, var.policy_arn)
}
