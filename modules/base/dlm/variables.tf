variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "dlm_arn" {
  description = "ARN of the DLM execution role"
  type        = string
}
variable "name" {
  description = "Name/identifier for the DLM lifecycle policy"
  type        = string
}

variable "description" {
  description = "Description for the DLM policy"
  type        = string
  default     = null
}

variable "target_tags" {
  description = "Tags on volumes that this policy applies to"
  type        = map(string)
}

variable "state" {
  description = "State of the DLM policy (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "state must be either ENABLED or DISABLED"
  }
}

variable "schedules" {
  description = "List of snapshot schedules for different volume groups"
  type = list(object({
    name          = string
    interval      = number
    interval_unit = string
    times         = list(string)
    retain_count  = number
    tags_to_add   = optional(map(string), {})
    copy_tags     = optional(bool, true)
  }))
}
