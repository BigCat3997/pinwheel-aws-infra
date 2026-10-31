variable "name" {
  description = "Alarm name"
  type        = string
}

variable "description" {
  description = "Alarm description"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Metric namespace"
  type        = string
}

variable "metric_name" {
  description = "Metric name"
  type        = string
}

variable "dimensions" {
  description = "Metric dimensions"
  type        = map(string)
  default     = {}
}

variable "statistic" {
  description = "Statistic applied over each period"
  type        = string
  default     = "Average"
}

variable "period" {
  description = "Period in seconds"
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "Periods evaluated"
  type        = number
  default     = 1
}

variable "datapoints_to_alarm" {
  description = "Breaching datapoints needed to alarm (null = evaluation_periods)"
  type        = number
  default     = null
}

variable "comparison_operator" {
  description = "Comparison between the statistic and the threshold"
  type        = string
}

variable "threshold" {
  description = "Alarm threshold"
  type        = number
}

variable "treat_missing_data" {
  description = "missing, notBreaching, breaching or ignore"
  type        = string
  default     = "missing"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "alarm_actions" {
  description = "ARNs (for example an SNS topic) notified when the alarm goes to ALARM"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs notified when the alarm returns to OK"
  type        = list(string)
  default     = []
}
