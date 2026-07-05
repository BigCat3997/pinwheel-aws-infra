variable "vpc_id" {
  description = "VPC ID where the endpoint is created"
  type        = string
}

variable "service_name" {
  description = "AWS endpoint service name, for example com.amazonaws.us-east-1.s3"
  type        = string
}

variable "vpc_endpoint_type" {
  description = "Type of endpoint: Interface, Gateway, or GatewayLoadBalancer"
  type        = string
}

variable "auto_accept" {
  description = "Whether to accept the endpoint attachment automatically"
  type        = bool
  default     = null
}

variable "policy" {
  description = "Optional policy document for the endpoint"
  type        = string
  default     = null
}

variable "route_table_ids" {
  description = "Route table IDs for Gateway endpoints"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for Interface or GatewayLoadBalancer endpoints"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs for Interface endpoints"
  type        = list(string)
  default     = null
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for Interface endpoints"
  type        = bool
  default     = null
}

variable "ip_address_type" {
  description = "The IP address type for the endpoint"
  type        = string
  default     = null
}

variable "private_dns_only_for_inbound_resolver_endpoint" {
  description = "Whether private DNS should be enabled only for inbound Route 53 Resolver endpoints"
  type        = bool
  default     = null
}

variable "name" {
  description = "Name tag for the endpoint"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
