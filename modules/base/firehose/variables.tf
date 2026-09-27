variable "create" {
  description = "Whether to create the Firehose delivery stream"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the Kinesis Firehose delivery stream"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role used by Firehose to write to the S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the destination S3 bucket"
  type        = string
}

variable "compression_format" {
  description = "Compression format for objects written to S3 (e.g. GZIP, ZIP, Snappy, HADOOP_SNAPPY)"
  type        = string
  default     = "GZIP"
}

variable "buffering_size" {
  description = "Buffer incoming data to the specified size in MBs before delivering to S3 (1–128)"
  type        = number
  default     = 5
}

variable "buffering_interval" {
  description = "Buffer incoming data for the specified period of time in seconds before delivering to S3 (60–900)"
  type        = number
  default     = 300
}

variable "prefix" {
  description = "S3 key prefix for delivered objects"
  type        = string
  default     = ""
}

variable "error_output_prefix" {
  description = "S3 key prefix for objects that failed delivery"
  type        = string
  default     = "errors/"
}

variable "tags" {
  description = "Common tags applied to the delivery stream"
  type        = map(string)
  default     = {}
}

variable "processing_lambda_arn" {
  description = "ARN of a Lambda function used to transform records before delivery (null disables transformation)"
  type        = string
  default     = null
}

variable "processing_buffer_size" {
  description = "Buffer size in MBs before invoking the processing Lambda (1-3)"
  type        = number
  default     = 3
}

variable "processing_buffer_interval" {
  description = "Buffer interval in seconds before invoking the processing Lambda (0-900)"
  type        = number
  default     = 60
}
