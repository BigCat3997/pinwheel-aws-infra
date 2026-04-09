variable "name" {
  description = "Parameter Store name"
  type        = string
}

variable "description" {
  description = "Description for the parameter"
  type        = string
  default     = null
}

variable "type" {
  description = "Parameter Store type"
  type        = string
  default     = "String"
}

variable "value" {
  description = "Parameter Store value"
  type        = string
}

variable "key_id" {
  description = "KMS key ID/ARN for SecureString"
  type        = string
  default     = null
}

variable "tier" {
  description = "Parameter tier"
  type        = string
  default     = "Standard"
}

variable "overwrite" {
  description = "Overwrite existing parameter"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the parameter"
  type        = map(string)
  default     = {}
}
