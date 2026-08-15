output "dlm_policy_id" {
  description = "DLM lifecycle policy ID."
  value       = module.local_dlm.policy_id
}

output "dlm_policy_arn" {
  description = "DLM lifecycle policy ARN."
  value       = module.local_dlm.policy_arn
}
