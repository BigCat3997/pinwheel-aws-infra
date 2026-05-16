variable "name" {
  description = "Name of the IAM group"
  type        = string
}

variable "path" {
  description = "Path in which to create the IAM group"
  type        = string
  default     = "/"
}

variable "managed_policy_arns" {
  description = "List of AWS managed or customer managed policy ARNs to attach to the group"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to JSON policy documents"
  type        = map(string)
  default     = {}
}

variable "users" {
  description = "List of IAM user names to place into the group"
  type        = list(string)
  default     = []
}

variable "membership_name" {
  description = "Optional explicit name for the aws_iam_group_membership resource"
  type        = string
  default     = null
}
