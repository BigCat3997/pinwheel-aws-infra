variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpcs" {
  description = "Exactly two VPCs to set up, keyed by VPC name"
  type = map(object({
    create           = optional(bool, true)
    cidr_block       = string
    enable_flow_logs = optional(bool, true)
    public_subnets = optional(list(object({
      name = string
      cidr = string
      az   = string
    })), [])
    private_subnets = optional(list(object({
      name = string
      cidr = string
      az   = string
    })), [])
  }))

  validation {
    condition     = length(var.vpcs) == 2
    error_message = "vpcs must contain exactly 2 VPCs."
  }

  validation {
    condition     = alltrue([for vpc in var.vpcs : length(vpc.public_subnets) + length(vpc.private_subnets) >= 2])
    error_message = "Each VPC must have at least 2 subnets (public + private)."
  }

  validation {
    condition     = alltrue([for vpc in var.vpcs : length(vpc.private_subnets) >= 1 || length(vpc.public_subnets) >= 1])
    error_message = "Each VPC needs at least one subnet to attach to the Transit Gateway."
  }
}

variable "tgw_name" {
  description = "Name of the Transit Gateway connecting the two VPCs"
  type        = string
  default     = "shared-resource-tgw"
}

variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN of the Transit Gateway"
  type        = number
  default     = 64512
}

variable "endpoint_vpc_name" {
  description = "Key in vpcs of the VPC that hosts the interface endpoints. The other VPC reuses them via private hosted zones."
  type        = string
}

variable "endpoint_services" {
  description = "Interface endpoint service suffixes to create (com.amazonaws.<region>.<suffix>)"
  type        = list(string)
  default     = ["ssm", "ssmmessages", "ec2messages", "logs"]
}

variable "ec2_name" {
  description = "Name of the test EC2 created in the VPC that does not host the interface endpoints"
  type        = string
  default     = "shared-resource-consumer-ec2"
}

variable "ec2_instance_type" {
  description = "Instance type of the test EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_volume_size" {
  description = "Root volume size (GiB) of the test EC2"
  type        = number
  default     = 8
}

variable "ec2_log_group_name" {
  description = "CloudWatch log group that receives the EC2 resource metrics"
  type        = string
  default     = "/aws/shared-resource/ec2-metrics"
}

variable "ec2_log_retention_days" {
  description = "Retention (days) of the EC2 metrics log group"
  type        = number
  default     = 7
}

variable "ec2_metrics_interval_seconds" {
  description = "Seconds between metric samples written on the EC2"
  type        = number
  default     = 60
}

variable "egress_vpc" {
  description = "Centralized egress VPC. Its NAT gateway is the only path to the internet for the private subnets of the other VPCs, reached through the Transit Gateway."
  type = object({
    name             = string
    cidr_block       = string
    enable_flow_logs = optional(bool, true)
    public_subnets = list(object({
      name = string
      cidr = string
      az   = string
    }))
    private_subnets = list(object({
      name = string
      cidr = string
      az   = string
    }))
  })

  validation {
    condition     = length(var.egress_vpc.public_subnets) >= 1 && length(var.egress_vpc.private_subnets) >= 1
    error_message = "egress_vpc needs at least one public subnet (NAT gateway) and one private subnet (TGW attachment)."
  }
}
