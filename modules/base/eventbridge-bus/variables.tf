variable "name" {
  description = "Name of the custom event bus"
  type        = string
}

variable "description" {
  description = "Description of the event bus"
  type        = string
  default     = null
}

variable "kms_key_identifier" {
  description = "Customer managed KMS key ARN to encrypt events (null uses an AWS owned key)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
