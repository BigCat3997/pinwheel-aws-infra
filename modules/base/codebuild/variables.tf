variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "description" {
  description = "CodeBuild project description"
  type        = string
  default     = null
}

variable "service_role_name" {
  description = "IAM role name for CodeBuild"
  type        = string
}

variable "buildspec" {
  description = "Path to buildspec file in the source repository"
  type        = string
  default     = "buildspec.yml"
}

variable "source_type" {
  description = "CodeBuild source type (for example: CODEPIPELINE, GITHUB, CODECOMMIT, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "source_location" {
  description = "Source location URL/ARN/bucket path depending on source_type."
  type        = string
  default     = null
}

variable "source_version" {
  description = "Optional source version (branch/tag/commit)."
  type        = string
  default     = null
}

variable "artifacts_type" {
  description = "CodeBuild artifacts type (for example: CODEPIPELINE, NO_ARTIFACTS, S3)."
  type        = string
  default     = "CODEPIPELINE"
}

variable "environment_type" {
  description = "CodeBuild environment type (for example: LINUX_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "service_role_arn" {
  description = "ARN of the IAM role for CodeBuild"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables to inject into CodeBuild container."
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
  default = []
}

variable "enable_cloudwatch_logs" {
  type    = bool
  default = true
}

variable "enable_s3_logs" {
  type    = bool
  default = false
}

variable "log_group_name" {
  type    = string
  default = null
}

variable "log_stream_name" {
  type    = string
  default = null

}

variable "s3_log_location" {
  type    = string
  default = ""
}
