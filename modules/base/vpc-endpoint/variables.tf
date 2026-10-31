variable "name" {
  description = "Name tag for the VPC endpoint"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the endpoint is created"
  type        = string
}

variable "service_name" {
  description = "Full service name, for example com.amazonaws.us-east-1.ssm"
  type        = string
}

variable "endpoint_type" {
  description = "Interface or Gateway"
  type        = string
  default     = "Interface"

  validation {
    condition     = contains(["Interface", "Gateway"], var.endpoint_type)
    error_message = "endpoint_type must be Interface or Gateway."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for an Interface endpoint"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for an Interface endpoint"
  type        = list(string)
  default     = []
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for an Interface endpoint"
  type        = bool
  default     = true
}

variable "route_table_ids" {
  description = "Route table IDs for a Gateway endpoint"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
