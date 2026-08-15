variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all resources."
}

variable "dlm_target_volume_names" {
  type        = list(string)
  description = "List of volume Name tags to look up and allow DLM to snapshot."
  default     = []
}

variable "name" {
  type        = string
  description = "Base name for all resources."
}

variable "description" {
  type        = string
  default     = null
  description = "Description for the DLM policy. If null, auto-generated from name."
}

variable "state" {
  type        = string
  default     = "ENABLED"
  description = "State of the DLM policy (ENABLED or DISABLED)"
}

variable "target_tags" {
  type        = map(string)
  description = "Tags used to identify volumes managed by DLM. Must match the tags on the root volume."
}

variable "schedules" {
  type = list(object({
    name          = string
    interval      = number
    interval_unit = string
    times         = list(string)
    retain_count  = number
    tags_to_add   = optional(map(string), {})
    copy_tags     = optional(bool, true)
  }))
  description = "List of snapshot schedules for multiple volumes with different retention policies"
}
