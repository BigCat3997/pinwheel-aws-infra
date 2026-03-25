variable "name" {
  description = "Name of the IAM role"
  type        = string
}

variable "path" {
  description = "Path in which to create the role"
  type        = string
  default     = "/"
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "JSON string for the trust policy (assume role policy)"
  type        = string
}

variable "assume_role_policy_file" {
  description = "Path to a JSON file containing the assume role policy. Used when `assume_role_policy` is empty."
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to JSON policy documents"
  type        = map(string)
  default     = {}
}

variable "permissions_boundary" {
  description = "ARN of the policy used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role. Valid range: 3600-43200"
  type        = number
  default     = 3600
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to assign to the role"
  type        = map(string)
  default     = {}
}
