variable "name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Time a received message stays hidden from other consumers"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "How long messages are kept (max 14 days)"
  type        = number
  default     = 1209600
}

variable "redrive_target_arn" {
  description = "Queue that receives messages after max_receive_count failed receives (null disables)"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Receives before a message moves to redrive_target_arn"
  type        = number
  default     = 5
}

variable "policy" {
  description = "Queue access policy JSON (null keeps the default)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
