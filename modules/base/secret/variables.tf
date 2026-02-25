variable "secrets" {
  description = "Secrets definitions"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "kms_key_id" {
  description = "KMS key ID for secret encryption"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
