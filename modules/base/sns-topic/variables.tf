variable "name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Display name shown as the sender of email notifications"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "Topic subscriptions. Email subscriptions stay pending until the recipient confirms them"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
