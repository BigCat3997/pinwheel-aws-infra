variable "aws_region" {
  description = "AWS Region where the overlay IP topology is deployed"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "create_ha_vpc" {
  description = "Whether to create the HA VPC instead of looking it up by name"
  type        = bool
  default     = true
}

variable "ha_vpc_name" {
  description = "Name of the VPC containing the primary and standby nodes"
  type        = string
}

variable "ha_vpc_cidr_block" {
  description = "IPv4 CIDR block of the HA VPC"
  type        = string
}

variable "ha_public_subnets" {
  description = "Public subnets for the HA nodes and transit gateway attachment"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

#variable "create_ha_internet_gateway" {
#  description = "Whether to create an internet gateway for the HA VPC"
#  type        = bool
#  default     = true
#}

variable "ha_internet_gateway_name" {
  description = "Name of the HA VPC internet gateway"
  type        = string
}

variable "ha_public_route_tables" {
  description = "Public route tables in the HA VPC"
  type = list(object({
    name = string
  }))
}

variable "ha_public_rtb_subnet_assocs" {
  description = "HA public subnet-to-route-table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "ha_overlay_route_table_name" {
  description = "HA public route table that receives overlay and client return routes"
  type        = string
}

variable "create_client_vpc" {
  description = "Whether to create the client VPC instead of looking it up by name"
  type        = bool
  default     = true
}

variable "client_vpc_name" {
  description = "Name of the VPC containing the test client"
  type        = string
}

variable "client_vpc_cidr_block" {
  description = "IPv4 CIDR block of the client VPC"
  type        = string
}

variable "client_public_subnets" {
  description = "Public subnets for the client and transit gateway attachment"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

#variable "create_client_internet_gateway" {
#  description = "Whether to create an internet gateway for the client VPC"
#  type        = bool
#  default     = true
#}

variable "client_internet_gateway_name" {
  description = "Name of the client VPC internet gateway"
  type        = string
}

variable "client_public_route_tables" {
  description = "Public route tables in the client VPC"
  type = list(object({
    name = string
  }))
}

variable "client_public_rtb_subnet_assocs" {
  description = "Client public subnet-to-route-table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "client_overlay_route_table_name" {
  description = "Client public route table that receives the overlay route"
  type        = string
}

variable "ha_nodes_security_group_name" {
  description = "Name of the security group shared by the primary and standby nodes"
  type        = string
}

variable "client_security_group_name" {
  description = "Name of the client EC2 security group"
  type        = string
}

variable "ami_id" {
  description = "Optional AMI ID for all nodes; the latest Amazon Linux 2023 x86_64 AMI is used when null"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type used by all three nodes"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip" {
  description = "Whether the EC2 instances receive public IPv4 addresses"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Optional existing EC2 key pair name; Session Manager works without it"
  type        = string
  default     = null
}

variable "ssh_user" {
  description = "Default SSH user included in EC2 module helper outputs"
  type        = string
  default     = "ec2-user"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB for all nodes"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root EBS volume type for all nodes"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether root EBS volumes are encrypted"
  type        = bool
  default     = false
}

variable "user_data_replace_on_change" {
  description = "Whether changes to user data replace the EC2 instances"
  type        = bool
  default     = false
}

variable "primary_ec2_name" {
  description = "Name of the initial active EC2 instance"
  type        = string
}

variable "primary_ec2_subnet_name" {
  description = "HA public subnet name for the initial active instance"
  type        = string
}

variable "primary_hostname" {
  description = "Persistent hostname configured on the initial active instance"
  type        = string
}

variable "standby_ec2_name" {
  description = "Name of the initial standby EC2 instance"
  type        = string
}

variable "standby_ec2_subnet_name" {
  description = "HA public subnet name for the standby instance"
  type        = string
}

variable "standby_hostname" {
  description = "Persistent hostname configured on the standby instance"
  type        = string
}

variable "client_ec2_name" {
  description = "Name of the test client EC2 instance"
  type        = string
}

variable "client_ec2_subnet_name" {
  description = "Client public subnet name for the test client"
  type        = string
}

variable "client_hostname" {
  description = "Persistent hostname configured on the test client"
  type        = string
}

variable "ssm_role_name" {
  description = "Name of the IAM role used by all EC2 instances"
  type        = string
}

variable "ssm_instance_profile_name" {
  description = "Name of the shared EC2 instance profile"
  type        = string
}

variable "transit_gateway_name" {
  description = "Name of the transit gateway connecting the HA and client VPCs"
  type        = string
}

variable "transit_gateway_description" {
  description = "Description of the transit gateway"
  type        = string
  default     = "Overlay IP routing lab"
}

variable "ha_tgw_attachment_name" {
  description = "Name of the HA VPC transit gateway attachment"
  type        = string
}

variable "ha_tgw_attachment_subnet_names" {
  description = "HA subnet names used by the transit gateway attachment"
  type        = set(string)
}

variable "client_tgw_attachment_name" {
  description = "Name of the client VPC transit gateway attachment"
  type        = string
}

variable "client_tgw_attachment_subnet_names" {
  description = "Client subnet names used by the transit gateway attachment"
  type        = set(string)
}

variable "overlay_ip" {
  description = "Overlay IPv4 address routed to the active node"
  type        = string
}

variable "service_port" {
  description = "TCP port of the overlay test HTTP service"
  type        = number
  default     = 8080
}
