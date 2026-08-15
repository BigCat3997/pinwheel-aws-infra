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
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet definitions"
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

variable "public_rtb_assoc" {
  description = "Public subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "key_pair_name" {
  description = "EC2 key pair name for the OpenVPN instance"
  type        = string
}

# variable "ssh_public_key_path" {
#   description = "Local path to the SSH public key file (.pub) to register as EC2 key pair"
#   type        = string
# }

variable "vpn_instance_name" {
  description = "Name tag for the OpenVPN EC2 instance"
  type        = string
  default     = "openvpn-server"
}

variable "vpn_ami_id" {
  description = "AMI ID for the OpenVPN instance. Defaults to latest Ubuntu 24.04 LTS from SSM if null."
  type        = string
  default     = null
}

variable "vpn_instance_type" {
  description = "EC2 instance type for the OpenVPN server"
  type        = string
  default     = "t3.micro"
}

variable "vpn_subnet_name" {
  description = "Name of the public subnet to place the OpenVPN instance"
  type        = string
}

variable "vpn_private_ip" {
  description = "Fixed private IPv4 address for the OpenVPN EC2 instance. If null, a static address is derived from the subnet CIDR."
  type        = string
  default     = null
}

variable "vpn_volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 20
}

variable "vpn_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "vpn_server_port" {
  description = "TCP port OpenVPN will listen on"
  type        = number
  default     = 443
}

variable "vpn_network" {
  description = "VPN tunnel network (OpenVPN server address pool)"
  type        = string
  default     = "10.8.0.0"
}

variable "vpn_network_mask" {
  description = "VPN tunnel network mask"
  type        = string
  default     = "255.255.255.0"
}

variable "vpn_client_ingress_cidrs" {
  description = "CIDR blocks allowed to connect to the OpenVPN port (0.0.0.0/0 allows any phone/client)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_ssh_ingress_cidrs" {
  description = "CIDR blocks allowed SSH access for initial setup (tighten after setup)"
  type        = list(string)
  default     = []
}
