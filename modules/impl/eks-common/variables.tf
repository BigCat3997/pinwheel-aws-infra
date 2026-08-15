variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# VPC
variable "create_vpc" {
  description = "Set to true to create a new VPC, or false to use an existing one."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

# Subnets
variable "public_subnets" {
  description = "List of public subnet configurations."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "private_subnets" {
  description = "List of private subnet configurations for EKS nodes."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

# EIP / NAT
variable "eips" {
  description = "List of EIPs to create for NAT Gateways."
  type = list(object({
    name = string
  }))
  default = []
}

variable "nat_gateways" {
  description = "List of NAT Gateway configurations."
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "internet_gateway_name" {
  description = "The name of the Internet Gateway."
  type        = string
}

# Route tables
variable "public_route_tables" {
  description = "List of public route table configurations."
  type = list(object({
    name = string
  }))
  default = []
}

variable "private_route_tables" {
  description = "List of private route table configurations."
  type = list(object({
    name        = string
    nat_gw_name = string
  }))
  default = []
}

variable "public_rtb_assoc" {
  description = "List of public route table association configurations."
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "private_rtb_assoc" {
  description = "List of private route table association configurations."
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

# Security Group
variable "cluster_sg_name" {
  description = "The name of the security group for the EKS cluster."
  type        = string
}

variable "cluster_sg_ingress_rules" {
  description = "Ingress rules for the EKS cluster security group."
  type = list(object({
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = optional(list(string))
    ipv6_cidr_blocks  = optional(list(string))
    security_group_id = optional(string)
    description       = optional(string)
  }))
  default = []
}

variable "cluster_sg_egress_rules" {
  description = "Egress rules for the EKS cluster security group."
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    description      = optional(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }]
}

# IAM
variable "cluster_role_name" {
  description = "The name of the IAM role for the EKS cluster control plane."
  type        = string
}

variable "node_role_name" {
  description = "The name of the IAM role for EKS worker nodes."
  type        = string
}

# EKS Cluster
variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "eks_kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster. e.g. '1.30'."
  type        = string
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server is accessible from within the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server is accessible from the internet."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "node_groups" {
  description = "A list of EKS managed node group configurations."
  type = list(object({
    name            = string
    instance_types  = list(string)
    capacity_type   = optional(string, "ON_DEMAND")
    disk_size       = optional(number, 50)
    desired_size    = number
    min_size        = number
    max_size        = number
    max_unavailable = optional(number, 1)
  }))
  default = []
}
