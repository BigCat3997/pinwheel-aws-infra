variable "env" {
  description = "Environment name (e.g., dev, prd) exposed to CodeBuild as environment variables."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region exposed to CodeBuild as environment variables."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "iam_path" {
  description = "Path in which to create the user."
  type        = string
  default     = "/"
}

variable "iam_permissions_boundary" {
  description = "The ARN of the policy used to set the permissions boundary for the user."
  type        = string
  default     = null
}

variable "iam_force_destroy" {
  description = "When true, destroy even if user has non-Terraform-managed access keys, login profile, or MFA devices."
  type        = bool
  default     = false
}

variable "iam_create_user" {
  description = "Whether to create a common IAM user."
  type        = bool
  default     = false
}

variable "iam_name" {
  description = "Name of the IAM user to create when `create_user` is true."
  type        = string
  default     = "common-user"
}

variable "iam_create_access_key" {
  description = "Whether to create an access key for the created user."
  type        = bool
  default     = false
}

variable "iam_access_key_count" {
  description = "Number of access keys to create for the user. If null, defaults to 1 if `create_access_key` is true, otherwise 0."
  type        = number
  default     = null
}

variable "iam_create_codecommit_https_credential" {
  description = "Whether to create HTTPS Git credentials for AWS CodeCommit for the created user."
  type        = bool
  default     = false
}

variable "iam_create_login_profile" {
  description = "Whether to create an AWS Console login profile (password) for the created user."
  type        = bool
  default     = false
}

variable "iam_login_profile_password_length" {
  description = "Generated console password length for IAM login profile."
  type        = number
  default     = 20
}

variable "iam_login_profile_password_reset_required" {
  description = "Whether the user must reset the console password at first login."
  type        = bool
  default     = true
}

variable "iam_policy_json" {
  description = "Inline JSON policy document to create and attach to the user. If provided this takes precedence over `policy_arn`."
  type        = string
  default     = ""
}

variable "iam_custom_policy_name" {
  description = "Optional name for the custom policy."
  type        = string
  default     = ""
}

variable "create_iam_policy_admin" {
  description = "Whether to create the custom policy from `policy_json`/`policy_json_file`. This flag controls creation directly instead of inferring from provided JSON/file."
  type        = bool
  default     = false
}

variable "repositories" {
  description = "List of CodeCommit repositories with per-repository settings."
  type = list(object({
    repository_name = string
    description     = optional(string, null)
    default_branch  = optional(string, "main")
  }))
}

variable "codebuild_role_name" {
  type = string
}

variable "codebuild_policy_name" {
  type = string
}

variable "codebuild_target_tf_module_dir" {
  type = string
}

variable "codepipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}

variable "codepipeline_role_name" {
  description = "IAM role name for CodePipeline"
  type        = string
}

variable "codepipeline_policy_name" {
  description = "Inline IAM policy name for CodePipeline role"
  type        = string
}

variable "codepipeline_artifact_bucket_name" {
  description = "S3 bucket name used by CodePipeline to store artifacts"
  type        = string
}

variable "codepipeline_artifact_allowed_user_name" {
  description = "IAM user name allowed to access the CodePipeline artifact bucket without being denied by the bucket policy."
  type        = string
  default     = "cloud_user"
}

variable "codepipeline_codecommit_repository_name" {
  description = "CodeCommit repository name used by Source stage"
  type        = string
}

variable "codepipeline_codecommit_branch" {
  description = "CodeCommit branch used by Source stage"
  type        = string
  default     = "main"
}

variable "codepipeline_poll_for_source_changes" {
  description = "Whether CodePipeline polls CodeCommit for source changes"
  type        = bool
  default     = true
}

variable "codepipeline_orchestration_repository_name" {
  description = "CodeCommit repository name used by Orchestration stage"
  type        = string
}

variable "codepipeline_orchestration_branch" {
  description = "CodeCommit branch used by Orchestration stage"
  type        = string
  default     = "main"
}

variable "codepipeline_orchestration_poll_for_source_changes" {
  description = "Whether CodePipeline polls CodeCommit for source changes in Orchestration stage"
  type        = bool
  default     = false
}

variable "codepipeline_approval_message" {
  description = "Manual approval message displayed before Apply stage"
  type        = string
  default     = "Review Terraform plan output and approve to continue with terraform apply."
}

variable "cb_tf_validate_project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "cb_tf_validate_description" {
  description = "CodeBuild project description"
  type        = string
  default     = null
}

variable "cb_tf_validate_buildspec" {
  description = "Path to buildspec file in source repo"
  type        = string
  default     = "buildspec.yml"
}

variable "cb_tf_validate_source_type" {
  description = "CodeBuild source type (for example: CODEPIPELINE, GITHUB, CODECOMMIT, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_validate_source_location" {
  description = "Source location URL/ARN/bucket path depending on source_type."
  type        = string
  default     = null
}

variable "cb_tf_validate_source_version" {
  description = "Optional source version (branch/tag/commit)."
  type        = string
  default     = null
}

variable "cb_tf_validate_artifacts_type" {
  description = "CodeBuild artifacts type (for example: CODEPIPELINE, NO_ARTIFACTS, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_validate_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "cb_tf_validate_image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "cb_tf_validate_environment_type" {
  description = "CodeBuild environment type (for example: LINUX_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)."
  type        = string
  default     = "LINUX_CONTAINER"
}
variable "cb_checkov_validate_project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "cb_checkov_validate_description" {
  description = "CodeBuild project description"
  type        = string
  default     = null
}

variable "cb_checkov_validate_buildspec" {
  description = "Path to buildspec file in source repo"
  type        = string
  default     = "buildspec.yml"
}

variable "cb_checkov_validate_source_type" {
  description = "CodeBuild source type (for example: CODEPIPELINE, GITHUB, CODECOMMIT, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_checkov_validate_source_location" {
  description = "Source location URL/ARN/bucket path depending on source_type."
  type        = string
  default     = null
}

variable "cb_checkov_validate_source_version" {
  description = "Optional source version (branch/tag/commit)."
  type        = string
  default     = null
}

variable "cb_checkov_validate_artifacts_type" {
  description = "CodeBuild artifacts type (for example: CODEPIPELINE, NO_ARTIFACTS, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_checkov_validate_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "cb_checkov_validate_image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "cb_checkov_validate_environment_type" {
  description = "CodeBuild environment type (for example: LINUX_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "cb_tf_plan_project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "cb_tf_plan_description" {
  description = "CodeBuild project description"
  type        = string
  default     = null
}

variable "cb_tf_plan_buildspec" {
  description = "Path to buildspec file in source repo"
  type        = string
  default     = "buildspec.yml"
}

variable "cb_tf_plan_source_type" {
  description = "CodeBuild source type (for example: CODEPIPELINE, GITHUB, CODECOMMIT, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_plan_source_location" {
  description = "Source location URL/ARN/bucket path depending on source_type."
  type        = string
  default     = null
}

variable "cb_tf_plan_source_version" {
  description = "Optional source version (branch/tag/commit)."
  type        = string
  default     = null
}

variable "cb_tf_plan_artifacts_type" {
  description = "CodeBuild artifacts type (for example: CODEPIPELINE, NO_ARTIFACTS, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_plan_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "cb_tf_plan_image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "cb_tf_plan_environment_type" {
  description = "CodeBuild environment type (for example: LINUX_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "cb_tf_apply_project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "cb_tf_apply_description" {
  description = "CodeBuild project description"
  type        = string
  default     = null
}

variable "cb_tf_apply_buildspec" {
  description = "Path to buildspec file in source repo"
  type        = string
  default     = "buildspec.yml"
}

variable "cb_tf_apply_source_type" {
  description = "CodeBuild source type (for example: CODEPIPELINE, GITHUB, CODECOMMIT, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_apply_source_location" {
  description = "Source location URL/ARN/bucket path depending on source_type."
  type        = string
  default     = null
}

variable "cb_tf_apply_source_version" {
  description = "Optional source version (branch/tag/commit)."
  type        = string
  default     = null
}

variable "cb_tf_apply_artifacts_type" {
  description = "CodeBuild artifacts type (for example: CODEPIPELINE, NO_ARTIFACTS, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "cb_tf_apply_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "cb_tf_apply_image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "cb_tf_apply_environment_type" {
  description = "CodeBuild environment type (for example: LINUX_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)."
  type        = string
  default     = "LINUX_CONTAINER"
}
