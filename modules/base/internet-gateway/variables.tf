variable "vpc_id" {
  description = "VPC ID for the Internet Gateway"
  type        = string
}

variable "name" {
  description = "Name tag for Internet Gateway"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
