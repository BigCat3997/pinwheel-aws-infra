variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "internet_gateway_name" {
  description = "Internet gateway name"
  type        = string
}

variable "public_route_tables" {
  description = "Public route table definitions"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "Private route table definitions. Set nat_gw_name = null for no outbound internet in private subnets."
  type = list(object({
    name        = string
    nat_gw_name = string
  }))
}

variable "public_rtb_assoc" {
  description = "Public subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "private_rtb_assoc" {
  description = "Private subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "private_test_subnet_name" {
  description = "Private subnet name where the test EC2 runs"
  type        = string
}

variable "app_instance_sg_name" {
  type = string
}

variable "app_instance_name" {
  description = "Name tag for the private test EC2 instance"
  type        = string
  default     = "cw-vpce-test-ec2"
}

variable "app_instance_type" {
  description = "EC2 instance type for the private test instance"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_private_ip" {
  description = "Optional static private IP for the test instance"
  type        = string
  default     = null
}

variable "app_instance_volume_size" {
  description = "Root EBS volume size for test instance"
  type        = number
  default     = 20
}

variable "app_instance_volume_type" {
  description = "Root EBS volume type for test instance"
  type        = string
  default     = "gp3"
}

variable "app_instance_access_public_ip" {
  description = "Whether the test EC2 instance should have a public IP"
  type        = bool
  default     = false
}

variable "app_instance_volume_encrypted" {
  description = "Whether the root EBS volume for the test instance is encrypted"
  type        = bool
  default     = true
}

variable "volume_delete_on_termination" {
  description = "Whether the root EBS volume for the test instance is deleted on termination"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention in days for the test CloudWatch log group"
  type        = number
  default     = 7
}

variable "log_push_interval_seconds" {
  description = "Interval in seconds between continuous test log events"
  type        = number
  default     = 30
}

variable "logs_vpce_sg_name" {
  description = "Name tag for the security group for the VPC Endpoint for CloudWatch Logs"
  type        = string
  default     = "cw-logs-vpce-sg"
}

variable "logs_vpce_name" {
  description = "Name tag for the CloudWatch Logs VPC Endpoint"
  type        = string
}

variable "logs_vpce_service_name" {
  description = "AWS service name for the CloudWatch Logs VPC Endpoint"
  type        = string
}

variable "logs_vpce_vpc_endpoint_type" {
  description = "Type of VPC endpoint (Interface or Gateway)"
  type        = string
}

variable "logs_vpce_private_dns_enabled" {
  description = "Whether private DNS is enabled for the VPC endpoint"
  type        = bool
  default     = false
}

variable "logs_vpce_enable_dns_support" {
  description = "Enable DNS support for the VPC"
  type        = bool
  default     = false
}

variable "logs_vpce_enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
  default     = false
}

variable "logs_vpce_sg_names" {
  type = list(string)
}

variable "logs_vpce_subnet_names" {
  type = list(string)
}

variable "logs_vpce_subnet_configs" {
  type = list(object({
    subnet_id = string
    ipv4      = optional(string)
    ipv6      = optional(string)
  }))
  default = []
}
