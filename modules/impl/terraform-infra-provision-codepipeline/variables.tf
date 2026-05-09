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

variable "codebuild_role_name" {
  type = string
}

variable "codebuild_policy_name" {
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
