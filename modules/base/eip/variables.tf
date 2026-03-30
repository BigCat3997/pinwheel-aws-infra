variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "name" {
  description = "Name for the EIP"
  type        = string
}

variable "domain" {
  description = "The domain for the EIP"
  type        = string
  default     = "vpc"
}
