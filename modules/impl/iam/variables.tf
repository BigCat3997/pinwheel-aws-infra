variable "env" {
  description = "Environment name (e.g., dev, prd) exposed to CodeBuild as environment variables."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The user's name."
  type        = string
}

variable "path" {
  description = "Path in which to create the user."
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "The ARN of the policy used to set the permissions boundary for the user."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "When true, destroy even if user has non-Terraform-managed access keys, login profile, or MFA devices."
  type        = bool
  default     = false
}

variable "create_user" {
  description = "Whether to create a common IAM user."
  type        = bool
  default     = false
}

variable "user_name" {
  description = "Name of the IAM user to create when `create_user` is true."
  type        = string
  default     = "common-user"
}

variable "create_access_key" {
  description = "Whether to create an access key for the created user."
  type        = bool
  default     = false
}

variable "access_key_count" {
  description = "Number of access keys to create for the user. If null, defaults to 1 if `create_access_key` is true, otherwise 0."
  type        = number
  default     = null
}

variable "create_codecommit_https_credential" {
  description = "Whether to create HTTPS Git credentials for AWS CodeCommit for the created user."
  type        = bool
  default     = false
}

variable "create_login_profile" {
  description = "Whether to create an AWS Console login profile (password) for the created user."
  type        = bool
  default     = false
}

variable "login_profile_password_length" {
  description = "Generated console password length for IAM login profile."
  type        = number
  default     = 20
}

variable "login_profile_password_reset_required" {
  description = "Whether the user must reset the console password at first login."
  type        = bool
  default     = true
}

variable "policy_arn" {
  description = "Policy ARN to attach to the user."
  type        = string
  default     = ""
}

variable "policy_json" {
  description = "Inline JSON policy document to create and attach to the user. If provided this takes precedence over `policy_arn`."
  type        = string
  default     = ""
}

variable "policy_json_file" {
  description = "Path to a file containing the JSON policy document to create and attach to the user. Used when `policy_json` is empty."
  type        = string
  default     = ""
}

variable "custom_policy_name" {
  description = "Optional name for the custom policy."
  type        = string
  default     = ""
}

variable "create_policy" {
  description = "Whether to create the custom policy from `policy_json`/`policy_json_file`. This flag controls creation directly instead of inferring from provided JSON/file."
  type        = bool
  default     = false
}
