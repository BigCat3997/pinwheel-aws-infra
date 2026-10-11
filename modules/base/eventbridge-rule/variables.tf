variable "name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "description" {
  description = "Description of the rule"
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "Schedule (rate or cron). Set either this or event_pattern"
  type        = string
  default     = null
}

variable "event_pattern" {
  description = "Event pattern JSON. Set either this or schedule_expression"
  type        = string
  default     = null
}

variable "event_bus_name" {
  description = "Event bus the rule is attached to"
  type        = string
  default     = "default"
}

variable "state" {
  description = "Rule state: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "target_id" {
  description = "Target ID within the rule"
  type        = string
  default     = "target"
}

variable "target_arn" {
  description = "ARN of the target (Lambda function, SQS queue, ...)"
  type        = string
}

variable "input" {
  description = "Constant JSON passed to the target (null passes the matched event)"
  type        = string
  default     = null
}

variable "lambda_function_name" {
  description = "Lambda function name to grant events.amazonaws.com invoke permission on (null skips it)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
