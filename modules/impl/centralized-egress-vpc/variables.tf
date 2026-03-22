variable "tgw_name" {
  description = "Name for the Transit Gateway"
  type        = string
}

variable "tgw_description" {
  description = "Description for the Transit Gateway"
  type        = string
  default     = null
}

variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "tgw_auto_accept_shared_attachments" {
  description = "Auto accept shared attachments for TGW"
  type        = string
  default     = "disable"
}

variable "tgw_default_route_table_association" {
  description = "Default route table association for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_default_route_table_propagation" {
  description = "Default route table propagation for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_dns_support" {
  description = "DNS support for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_vpn_ecmp_support" {
  description = "VPN ECMP support for TGW"
  type        = string
  default     = "enable"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "create_shared_vpc" {
  description = "Whether to create a new VPC (true) or use an existing VPC by name (false)"
  type        = bool
  default     = true
}

variable "shared_vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "shared_vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = null
}

variable "shared_public_subnets" {
  description = "Public subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "shared_private_subnets" {
  description = "Private subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "shared_public_route_tables" {
  description = "Public route tables"
  type = list(object({
    name = string
  }))
}

variable "shared_private_route_tables" {
  description = "Private route tables for shared VPC"
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
  default = []
}

variable "shared_public_rt_subnet_associations" {
  description = "Public route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
}

variable "shared_private_rt_subnet_associations" {
  description = "Private route table to subnet associations for shared VPC"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
  default = []
}

variable "shared_igw_name" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = null
}

variable "shared_nat_gateways" {
  description = "NAT Gateway configuration"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "tgw_shared_vpc_attachment_name" {
  description = "Name for the TGW VPC Attachment for Shared VPC"
  type        = string
}

variable "tgw_shared_vpc_attachment_subnet_names" {
  description = "List of private subnet names to attach to TGW for Shared VPC"
  type        = list(string)
}

variable "tgw_shared_vpc_attachment_dns_support" {
  description = "DNS support for TGW VPC Attachment for Shared VPC"
  type        = string
  default     = "enable"
}

variable "tgw_shared_vpc_attachment_ipv6_support" {
  description = "IPv6 support for TGW VPC Attachment for Shared VPC"
  type        = string
  default     = "disable"
}

variable "create_consumer_vpc" {
  description = "Whether to create a new consumer VPC"
  type        = bool
  default     = true
}

variable "consumer_vpc_name" {
  description = "Name tag for consumer VPC"
  type        = string
}

variable "consumer_vpc_cidr_block" {
  description = "CIDR block for the consumer VPC"
  type        = string
}

variable "consumer_public_subnets" {
  description = "Public subnets configuration for consumer VPC"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "consumer_private_subnets" {
  description = "Private subnets configuration for consumer VPC"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "consumer_public_route_tables" {
  description = "Public route tables for consumer VPC"
  type = list(object({
    name = string
  }))
  default = []
}

variable "consumer_private_route_tables" {
  description = "Private route tables for consumer VPC"
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
  default = []
}

variable "consumer_public_rt_subnet_associations" {
  description = "Public route table to subnet associations for consumer VPC"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
  default = []
}

variable "consumer_private_rt_subnet_associations" {
  description = "Private route table to subnet associations for consumer VPC"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
  default = []
}

variable "consumer_igw_name" {
  description = "Name tag for Internet Gateway for consumer VPC"
  type        = string
}

variable "tgw_consumer_vpc_attachment_name" {
  description = "Name for the TGW VPC Attachment for Consumer VPC"
  type        = string
}

variable "tgw_consumer_vpc_attachment_subnet_names" {
  description = "List of private subnet names to attach to TGW for Consumer VPC"
  type        = list(string)
}

variable "tgw_consumer_vpc_attachment_dns_support" {
  description = "DNS support for TGW VPC Attachment for Consumer VPC"
  type        = string
  default     = "enable"
}

variable "tgw_consumer_vpc_attachment_ipv6_support" {
  description = "IPv6 support for TGW VPC Attachment for Consumer VPC"
  type        = string
  default     = "disable"
}

variable "bastion_create_key_pair" {
  description = "Whether to create a new key pair for the bastion EC2 instance"
  type        = bool
  default     = true
}

variable "bastion_key_pair_name" {
  description = "Name of the key pair for the bastion EC2 instance"
  type        = string
}

variable "bastion_public_key_path" {
  description = "Path to the public key for the bastion EC2 instance"
  type        = string
}

variable "app_ec2_create_key_pair" {
  description = "Whether to create a new key pair for the app EC2 instance"
  type        = bool
  default     = true
}

variable "app_ec2_key_pair_name" {
  description = "Name of the key pair for the app EC2 instance"
  type        = string
}

variable "app_ec2_public_key_path" {
  description = "Path to the public key for the app EC2 instance"
  type        = string
}

variable "bastion_sg_name" {
  description = "Name of the security group for bastion"
  type        = string
}

variable "app_ec2_sg_name" {
  description = "Name of the security group for app EC2"
  type        = string
}

variable "bastion_name" {
  description = "Name tag for bastion EC2 instance"
  type        = string
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion EC2 instance"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion EC2"
  type        = string
}

variable "bastion_subnet_name" {
  description = "Public subnet name for bastion"
  type        = string
}

variable "bastion_associate_public_ip" {
  description = "Whether to associate a public IP with the bastion instance"
  type        = bool
  default     = true
}

variable "bastion_user_data" {
  description = "User data for bastion instance"
  type        = string
  default     = null
}

variable "bastion_volume_size" {
  description = "Bastion volume size in GB"
  type        = number
  default     = 50
}

variable "bastion_volume_type" {
  description = "Bastion volume type"
  type        = string
  default     = "gp3"
}

variable "bastion_volume_encrypted" {
  description = "Whether the bastion volume is encrypted"
  type        = bool
  default     = true
}

variable "bastion_volume_delete_on_termination" {
  description = "Whether to delete bastion volume on termination"
  type        = bool
  default     = true
}

variable "app_ec2_name" {
  description = "Name tag for app EC2 instance"
  type        = string
}

variable "app_ec2_ami_id" {
  description = "AMI ID for app EC2 instance"
  type        = string
}

variable "app_ec2_instance_type" {
  description = "Instance type for app EC2"
  type        = string
}

variable "app_ec2_subnet_name" {
  description = "Private subnet name for app EC2"
  type        = string
}

variable "app_ec2_associate_public_ip" {
  description = "Whether to associate a public IP with the app instance (should be false for private subnet)"
  type        = bool
  default     = false
}

variable "app_ec2_user_data" {
  description = "User data for app EC2 instance"
  type        = string
  default     = null
}

variable "app_ec2_volume_size" {
  description = "App EC2 volume size in GB"
  type        = number
  default     = 50
}

variable "app_ec2_volume_type" {
  description = "App EC2 volume type"
  type        = string
  default     = "gp3"
}

variable "app_ec2_volume_encrypted" {
  description = "Whether the app EC2 volume is encrypted"
  type        = bool
  default     = true
}

variable "app_ec2_volume_delete_on_termination" {
  description = "Whether to delete app EC2 volume on termination"
  type        = bool
  default     = true
}
