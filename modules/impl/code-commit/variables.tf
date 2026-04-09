variable "repositories" {
  description = "List of CodeCommit repositories with per-repository settings."
  type = list(object({
    repository_name = string
    description     = optional(string, null)
    default_branch  = optional(string, "main")
  }))
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}
