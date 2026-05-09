variable "aws_region" {
  description = "AWS region used by the provider"
  type        = string
  default     = "us-east-1"
}

variable "path" {
  description = "Path in which to create the IAM groups"
  type        = string
  default     = "/"
}

variable "administrator_group_name" {
  description = "Name of the administrator IAM group"
  type        = string
  default     = "Administrator"
}

variable "administrator_managed_policy_arns" {
  description = "Managed policy ARNs attached to the administrator group"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "administrator_inline_policies" {
  description = "Inline policies attached to the administrator group"
  type        = map(string)
  default     = {}
}

variable "administrator_users" {
  description = "IAM users to add to the administrator group"
  type        = list(string)
  default     = []
}

variable "administrator_membership_name" {
  description = "Optional explicit membership resource name for the administrator group"
  type        = string
  default     = null
}

variable "developer_group_name" {
  description = "Name of the developer IAM group"
  type        = string
  default     = "Developer"
}

variable "developer_managed_policy_arns" {
  description = "Managed policy ARNs attached to the developer group"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "developer_inline_policies" {
  description = "Inline policies attached to the developer group"
  type        = map(string)
  default     = {}
}

variable "developer_users" {
  description = "IAM users to add to the developer group"
  type        = list(string)
  default     = []
}

variable "developer_membership_name" {
  description = "Optional explicit membership resource name for the developer group"
  type        = string
  default     = null
}

variable "reader_group_name" {
  description = "Name of the reader IAM group"
  type        = string
  default     = "Reader"
}

variable "reader_managed_policy_arns" {
  description = "Managed policy ARNs attached to the reader group"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

variable "reader_inline_policies" {
  description = "Inline policies attached to the reader group"
  type        = map(string)
  default     = {}
}

variable "reader_users" {
  description = "IAM users to add to the reader group"
  type        = list(string)
  default     = []
}

variable "reader_membership_name" {
  description = "Optional explicit membership resource name for the reader group"
  type        = string
  default     = null
}

