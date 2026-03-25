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

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "create_access_key" {
  description = "Whether to create an access key for the user created by this module."
  type        = bool
  default     = false
}

variable "create_codecommit_https_credential" {
  description = "Whether to create HTTPS Git credentials for AWS CodeCommit for the user."
  type        = bool
  default     = false
}

variable "create_login_profile" {
  description = "Whether to create an AWS Console login profile (password) for the user."
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

variable "attach_policy_arn" {
  description = "Optional managed policy ARN to attach to the user created by this module."
  type        = string
  default     = ""
}

variable "attach_policy" {
  description = "Whether to attach a managed policy to the user. This flag is evaluated at plan time and should be provided by the caller."
  type        = bool
  default     = false
}

variable "access_key_count" {
  description = "Number of access keys to create for the user."
  type        = number
  default     = 0
}
