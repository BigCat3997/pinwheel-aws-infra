variable "secrets" {
  description = "Secrets definitions"
  sensitive   = true
  type = list(object({
    name  = string
    value = string
  }))

  validation {
    condition     = length(distinct([for secret in var.secrets : secret.name])) == length(var.secrets)
    error_message = "Every secret name must be unique."
  }
}

variable "resource_policy" {
  type = string
}

variable "kms_key_id" {
  description = "KMS key ID for secret encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
