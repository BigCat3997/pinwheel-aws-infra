variable "create_vpc" {
  description = "Whether to create a new VPC (true) or use an existing VPC by name (false)"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "Public subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "nat_gateways" {
  description = "NAT Gateway configuration"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "internet_gateway_name" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = null
}

variable "public_route_tables" {
  description = "Public route tables"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "Private route tables"
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
}

variable "public_rt_subnet_associations" {
  description = "Public route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
}

variable "rt_subnet_associations" {
  description = "Private route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
}

variable "nsg_definitions" {
  description = "Security group definitions"
  type = list(object({
    name = string
    security_rules = list(object({
      from_port         = number
      to_port           = number
      protocol          = string
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      security_group_id = optional(string)
      description       = optional(string)
    }))
    egress_rules = list(
      object({
        from_port        = number
        to_port          = number
        protocol         = string
        cidr_blocks      = optional(list(string))
        ipv6_cidr_blocks = optional(list(string))
        description      = optional(string)
    }))
  }))
  default = []
}

variable "bastion_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the bastion EC2 instance"
  default     = true
}

variable "bastion_key_pair_name" {
  type        = string
  description = "Name of the key pair for the bastion EC2 instance"
}

variable "bastion_public_key_path" {
  type        = string
  description = "Path to the public key for the bastion EC2 instance"
}

variable "bastion_name" {
  type        = string
  description = "Bastion EC2 instance name"
}

variable "bastion_ami_id" {
  type        = string
  description = "Bastion AMI ID"
}

variable "bastion_instance_type" {
  type        = string
  description = "Bastion EC2 instance type"
}

variable "bastion_subnet_name" {
  type        = string
  description = "Public subnet name for bastion"
}

variable "bastion_security_group_names" {
  type        = list(string)
  description = "Security group names for bastion"
  default     = []
}

variable "bastion_associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP with the bastion instance"
  default     = true
}

variable "bastion_ssh_user" {
  description = "Default SSH user for the bastion instance"
  type        = string
  default     = "ec2-user"
}

variable "bastion_user_data" {
  type        = string
  description = "User data for bastion instance"
  default     = null
}

variable "bastion_volume_size" {
  type        = number
  description = "Bastion volume size"
  default     = 8
}

variable "bastion_volume_type" {
  type        = string
  description = "Bastion volume type"
  default     = "gp3"
}

variable "bastion_volume_encrypted" {
  type        = bool
  description = "Whether the bastion volume is encrypted"
  default     = false
}

variable "bastion_volume_delete_on_termination" {
  type        = bool
  description = "Whether to delete bastion volume on termination"
  default     = true
}

variable "bastion_create_external_volume" {
  type        = bool
  description = "Whether to create an external volume for the bastion EC2 instance"
  default     = false
}

variable "app_ec2_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the EC2 instance"
  default     = true
}

variable "app_ec2_key_pair_name" {
  type        = string
  description = "Name of the key pair for the EC2 instance"
}

variable "app_ec2_name" {
  type        = string
  description = "EC2 instance name"
}

variable "app_ec2_ami_id" {
  type        = string
  description = "AMI ID"
}

variable "app_ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "app_ec2_subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "app_ec2_security_group_names" {
  type    = list(string)
  default = []
}

variable "app_ec2_associate_public_ip" {
  type    = bool
  default = false
}

variable "app_ec2_ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "app_ec2_user_data" {
  type    = string
  default = null
}

variable "app_ec2_volume_size" {
  type = number
}

variable "app_ec2_volume_type" {
  type = string
}

variable "app_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "app_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "create_lt_ec2_key_pair" {
  description = "Whether to create a new key pair for the launch template"
  type        = bool
  default     = true
}

variable "lt_ec2_key_pair_name" {
  description = "Prefix for launch template name"
  type        = string
}

variable "lt_user_data" {
  description = "User data for launch template"
  type        = string
  default     = null
}

variable "lt_security_group_names" {
  description = "List of NSG names to assign to launch template"
  type        = list(string)
}

variable "lt_volume_type" {
  description = "Volume type for launch template"
  type        = string
  default     = "gp3"
}

variable "lt_volume_size" {
  description = "Volume size for launch template"
  type        = number
  default     = 8
}

variable "lt_volume_encrypted" {
  description = "Whether the volume is encrypted"
  type        = bool
  default     = true
}

variable "lt_name" {
  description = "Name for launch template"
  type        = string
}

variable "lt_associate_public_ip" {
  description = "Whether to associate a public IP with the launch template"
  type        = bool
  default     = false
}

variable "lt_name_prefix" {
  description = "Prefix for launch template name"
  type        = string
}

variable "lt_ami_id" {
  description = "AMI ID for launch template"
  type        = string
}

variable "lt_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "lt_key_name" {
  description = "Key pair name"
  type        = string
  default     = null
}

variable "asg_name" {
  description = "Name for autoscaling group"
  type        = string
}
variable "asg_instance_name" {
  description = "Name tag for EC2 instances in ASG"
  type        = string
}
variable "asg_subnet_names" {
  description = "List of private subnet names for ASG"
  type        = list(string)
}

variable "asg_desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum size for ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum size for ASG"
  type        = number
}

variable "asg_health_check_type" {
  description = "Health check type for ASG"
  type        = string
  default     = "EC2"
}

variable "asg_health_check_grace_period" {
  description = "Health check grace period for ASG"
  type        = number
  default     = 300
}

variable "asg_wait_for_capacity_timeout" {
  description = "Wait for capacity timeout for ASG"
  type        = string
  default     = "0"
}

variable "nlb_name" {
  description = "Name for the Network Load Balancer"
  type        = string
}

variable "nlb_target_group_name" {
  description = "Name for the NLB target group"
  type        = string
  default     = "nlb-tg"
}

variable "nlb_target_port" {
  description = "Target port for NLB target group"
  type        = number
  default     = 8080
}

variable "nlb_target_protocol" {
  description = "Target protocol for NLB target group"
  type        = string
  default     = "TCP"
}

variable "nlb_target_type" {
  description = "Target type for NLB target group"
  type        = string
  default     = "instance"
}

variable "nlb_listener_port" {
  description = "Listener port for NLB"
  type        = number
  default     = 8080
}

variable "nlb_listener_protocol" {
  description = "Listener protocol for NLB"
  type        = string
  default     = "TCP"
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
}

variable "alb_target_group_name" {
  description = "Name for the ALB target group"
  type        = string
  default     = "alb-tg"
}

variable "alb_target_port" {
  description = "Target port for ALB target group"
  type        = number
  default     = 80
}

variable "alb_target_protocol" {
  description = "Target protocol for ALB target group"
  type        = string
  default     = "HTTP"
}

variable "alb_listener_port" {
  description = "Listener port for ALB"
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "Listener protocol for ALB"
  type        = string
  default     = "HTTP"
}

variable "kms_key_name" {
  description = "Name for the KMS key used to encrypt secrets"
  type        = string
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting key pair secrets"
}
