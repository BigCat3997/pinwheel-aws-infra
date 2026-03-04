variable "kms_key_name" {
  description = "Alias name for the KMS key"
  type        = string
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "Customer managed key"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
