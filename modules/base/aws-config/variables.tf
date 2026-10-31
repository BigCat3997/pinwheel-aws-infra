variable "name" {
  description = "Name of the configuration recorder and delivery channel"
  type        = string
  default     = "default"
}

variable "role_arn" {
  description = "IAM role ARN AWS Config assumes to record resources and write to S3"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket receiving configuration history and snapshots"
  type        = string
}

variable "s3_key_prefix" {
  description = "Prefix for objects delivered to the bucket"
  type        = string
  default     = null
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for configuration change notifications"
  type        = string
  default     = null
}

variable "snapshot_delivery_frequency" {
  description = "Snapshot frequency: One_Hour, Three_Hours, Six_Hours, Twelve_Hours or TwentyFour_Hours (null = none)"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the recorder is recording"
  type        = bool
  default     = true
}

variable "all_supported" {
  description = "Record all supported resource types"
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Include global resources such as IAM (only with all_supported)"
  type        = bool
  default     = true
}

variable "resource_types" {
  description = "Resource types to record when all_supported is false, e.g. AWS::EC2::Instance"
  type        = list(string)
  default     = []
}

variable "managed_rules" {
  description = "AWS managed Config rules keyed by rule name"
  type = map(object({
    source_identifier = string
    description       = optional(string)
    input_parameters  = optional(map(string), {})
    resource_types    = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "custom_rules" {
  description = "Custom Config rules evaluated by a Lambda, keyed by rule name (triggered by configuration changes of resource_types)"
  type = map(object({
    lambda_arn     = string
    lambda_name    = string
    description    = optional(string)
    resource_types = list(string)
  }))
  default = {}
}

variable "account_id" {
  description = "Account ID allowed to invoke custom rule Lambdas (restricts the Config invoke permission)"
  type        = string
  default     = null
}
