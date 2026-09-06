variable "log_groups" {
  description = "CloudWatch log groups to create"
  type = list(object({
    key               = string
    name              = string
    retention_in_days = number
    tags              = optional(map(string), {})
  }))
  default = []
}
