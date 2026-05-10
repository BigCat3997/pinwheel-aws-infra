output "cb_tf_validate_project_name" {
  value = module.local_cb_tf_validate.project_name
}

output "cb_tf_plan_project_name" {
  value = module.local_cb_tf_plan.project_name
}

output "cb_tf_apply_project_name" {
  value = module.local_cb_tf_apply.project_name
}

output "codepipeline_name" {
  value = aws_codepipeline.terraform_infra.name
}

output "codepipeline_arn" {
  value = aws_codepipeline.terraform_infra.arn
}

output "codepipeline_artifact_bucket_name" {
  value = module.local_s3_codepipeline_artifacts.name
}

output "codecommit_username" {
  description = "CodeCommit HTTPS Git username for cloning repositories"
  value       = module.local_iam_user_admin.codecommit_service_user_name
}

output "codecommit_password" {
  description = "CodeCommit HTTPS Git password (API key) for cloning repositories"
  value       = module.local_iam_user_admin.codecommit_service_password
  sensitive   = true
}

output "iam_user_name" {
  description = "IAM user name created for CodeCommit access"
  value       = module.local_iam_user_admin.name
}

output "iam_user_access_key_id" {
  description = "AWS Access Key ID for the IAM user"
  value       = module.local_iam_user_admin.access_key_id
  sensitive   = true
}

output "iam_user_secret_access_key" {
  description = "AWS Secret Access Key for the IAM user"
  value       = module.local_iam_user_admin.secret_access_key
  sensitive   = true
}

output "git_clone_commands" {
  description = "Git clone commands for all CodeCommit repositories with embedded credentials"
  value = {
    for repo_name, repo in module.local_code_commit :
    repo_name => "git clone https://${module.local_iam_user_admin.codecommit_service_user_name}:${module.local_iam_user_admin.codecommit_service_password}@git-codecommit.us-east-1.amazonaws.com/v1/repos/${repo_name}"
  }
  sensitive = true
}
