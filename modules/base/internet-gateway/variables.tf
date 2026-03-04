variable "vpc_id" {
  description = "VPC ID for the Internet Gateway"
  type        = string
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
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
