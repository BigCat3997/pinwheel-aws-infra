variable "repository_name" {
  description = "The name for the repository."
  type        = string
}

variable "description" {
  description = "The description of the repository."
  type        = string
  default     = null
}

variable "default_branch" {
  description = "The name of the default branch."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
