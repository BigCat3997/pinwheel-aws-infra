variable "name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "path" {
  description = "Path in which to create the policy"
  type        = string
  default     = "/"
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = ""
}

variable "policy" {
  description = "JSON string containing the policy document. Takes precedence over `policy_file`."
  type        = string
  default     = ""
}

variable "policy_file" {
  description = "Path to a file containing the JSON policy document. Used when `policy` is empty."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to assign to the policy"
  type        = map(string)
  default     = {}
}
