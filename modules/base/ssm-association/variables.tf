variable "document_name" {
  description = "Name of the SSM document to associate"
  type        = string
}

variable "association_name" {
  description = "Name of the association"
  type        = string
}

variable "parameters" {
  description = "Parameters passed to the SSM document"
  type        = map(string)
  default     = {}
}

variable "targets" {
  description = "Association targets, e.g. key = InstanceIds"
  type = list(object({
    key    = string
    values = list(string)
  }))
}

variable "schedule_expression" {
  description = "Cron or rate expression to re-apply the association (null runs it once on create/update)"
  type        = string
  default     = null
}
