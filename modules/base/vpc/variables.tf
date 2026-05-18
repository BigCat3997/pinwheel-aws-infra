variable "create" {
  description = "Whether to create a new VPC (true) or use an existing VPC by name (false)"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name tag for VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = null
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for this VPC"
  type        = bool
  default     = false
}

variable "flow_logs_destination_type" {
  description = "Flow Logs destination type: cloud-watch-logs or s3"
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_logs_destination_type)
    error_message = "flow_logs_destination_type must be either cloud-watch-logs or s3."
  }
}

variable "flow_logs_destination_arn" {
  description = "Optional destination ARN for VPC Flow Logs. If null and destination type is cloud-watch-logs, the module creates a log group."
  type        = string
  default     = null
}

variable "flow_logs_iam_role_arn" {
  description = "Optional IAM role ARN used by VPC Flow Logs when destination type is cloud-watch-logs. If null, the module creates one."
  type        = string
  default     = null
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to capture in VPC Flow Logs"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_max_aggregation_interval" {
  description = "Maximum interval of time during which a flow of packets is captured and aggregated"
  type        = number
  default     = 600

  validation {
    condition     = contains([60, 600], var.flow_logs_max_aggregation_interval)
    error_message = "flow_logs_max_aggregation_interval must be 60 or 600."
  }
}

variable "flow_logs_log_group_name" {
  description = "Optional CloudWatch Log Group name for VPC Flow Logs"
  type        = string
  default     = null
}

variable "flow_logs_log_group_retention_in_days" {
  description = "Retention period (in days) for the auto-created CloudWatch Log Group"
  type        = number
  default     = 30
}

variable "flow_logs_log_format" {
  description = "Optional custom format for VPC Flow Logs"
  type        = string
  default     = null
}
