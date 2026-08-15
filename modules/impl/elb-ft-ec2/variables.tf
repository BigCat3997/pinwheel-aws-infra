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

variable "public_rtb_subnet_assocs" {
  description = "Public route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "private_rtb_subnet_assocs" {
  description = "Private route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "security_groups" {
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

# variable "bastion_public_key_path" {
#   type        = string
#   description = "Path to the public key for the bastion EC2 instance"
# }

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

variable "primary_ec2_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the EC2 instance"
  default     = true
}

variable "primary_ec2_key_pair_name" {
  type        = string
  description = "Name of the key pair for the EC2 instance"
}

variable "primary_ec2_name" {
  type        = string
  description = "EC2 instance name"
}

variable "primary_ec2_ami_id" {
  type        = string
  description = "AMI ID"
}

variable "primary_ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "primary_ec2_subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "primary_ec2_security_group_names" {
  type    = list(string)
  default = []
}

variable "primary_ec2_associate_public_ip" {
  type    = bool
  default = false
}

variable "primary_ec2_ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "primary_ec2_user_data" {
  type    = string
  default = null
}

variable "primary_ec2_volume_size" {
  type = number
}

variable "primary_ec2_volume_type" {
  type = string
}

variable "primary_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "primary_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "standby_ec2_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the EC2 instance"
  default     = true
}

variable "standby_ec2_key_pair_name" {
  type        = string
  description = "Name of the key pair for the EC2 instance"
}

variable "standby_ec2_name" {
  type        = string
  description = "EC2 instance name"
}

variable "standby_ec2_ami_id" {
  type        = string
  description = "AMI ID"
}

variable "standby_ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "standby_ec2_subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "standby_ec2_security_group_names" {
  type    = list(string)
  default = []
}

variable "standby_ec2_associate_public_ip" {
  type    = bool
  default = false
}

variable "standby_ec2_ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "standby_ec2_user_data" {
  type    = string
  default = null
}

variable "standby_ec2_volume_size" {
  type = number
}

variable "standby_ec2_volume_type" {
  type = string
}

variable "standby_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "standby_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "nlb_name" {
  description = "Name for the Network Load Balancer"
  type        = string
}

variable "nlb_enable_public" {
  description = "Whether to enable public access for the NLB"
  type        = bool
  default     = false
}

variable "nlb_security_group_names" {
  description = "Security group names for the NLB"
  type        = set(string)
  default     = []
}

# variable "nlb_target_protocol" {
#   description = "Target protocol for NLB target group"
#   type        = string
#   default     = "TCP"
# }

# variable "nlb_target_type" {
#   description = "Target type for NLB target group"
#   type        = string
#   default     = "instance"
# }

# variable "nlb_enable_stickiness" {
#   type    = bool
#   default = true
# }

# variable "nlb_target_ips" {
#   description = "Optional list of IP addresses to register in the NLB target group when nlb_target_type is ip"
#   type        = list(string)
#   default     = []
# }

# variable "nlb_listener_port" {
#   description = "Listener port for NLB"
#   type        = number
#   default     = 8080
# }

# variable "nlb_listener_protocol" {
#   description = "Listener protocol for NLB"
#   type        = string
#   default     = "TCP"
# }
variable "nlb_enable_subnet_mapping" {
  type    = bool
  default = false
}

# variable "nlb_subnet_mappings" {
#   type = list(object({
#     subnet_id            = string
#     private_ipv4_address = optional(string, null)
#     eip_id               = optional(string, null)
#   }))
#   default = []
# }

variable "nlb_security_groups" {
  type    = list(string)
  default = []
}

# variable "nlb_subnet_names" {
#   description = "List of subnet names for the NLB"
#   type        = set(string)
#   default     = []
# }

variable "nlb_subnet_configs" {
  description = "Map of subnet name to static private IP for NLB subnet mappings"
  type        = map(string)
  default     = {}
}

variable "nlb_listeners" {
  description = "NLB listeners"

  type = list(object({
    protocol          = string
    port              = number
    target_group_name = string
    type              = optional(string, "forward")
    certificate_arn   = optional(string) # Required only when protocol = TLS
    ssl_policy        = optional(string) # Optional TLS policy
  }))

  default = []

  validation {
    condition = alltrue([
      for listener in var.nlb_listeners :
      contains(
        ["TCP", "TLS", "UDP", "TCP_UDP"],
        listener.protocol
      )
    ])

    error_message = "NLB listener protocol must be TCP, TLS, UDP, or TCP_UDP."
  }
}

variable "nlb_target_groups" {
  description = "NLB target groups"
  type = map(object({
    protocol    = string
    port        = number
    vpc_id      = optional(string, null)
    target_type = optional(string, "instance")
    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "TCP")
      port                = optional(string, "traffic-port")
      path                = optional(string)
      interval            = optional(number, 30)
      timeout             = optional(number, 10)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string)
    }), null)
    stickiness = optional(object({
      enabled = optional(bool, true)
      type    = optional(string, "source_ip")
    }), null)
    deregistration_delay = optional(number, 300)
    cross_zone_enabled   = optional(bool, true)
    tags                 = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for tg in var.nlb_target_groups :
      contains(
        ["TCP", "TLS", "UDP", "TCP_UDP"
        ],
        tg.protocol
      )
    ])
    error_message = "Target group protocol must be TCP, TLS, UDP, or TCP_UDP."
  }
}

variable "nlb_attachments" {
  description = "Target group attachments"

  type = map(object({
    target_group_name = string
    target_name       = optional(string, null)
    target_id         = optional(string)
    port              = optional(number)
    availability_zone = optional(string)
  }))

  default = {}
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

# ── ALB ──────────────────────────────────────────────────────────────
variable "alb_name" {
  type = string
}

variable "alb_enable_public" {
  type    = bool
  default = true
}

variable "alb_enable_deletion_protection" {
  type    = bool
  default = false
}

variable "alb_subnet_names" {
  type    = set(string)
  default = []
}

variable "alb_security_group_names" {
  type    = set(string)
  default = []
}

variable "alb_target_groups" {
  type = map(object({
    port        = number
    protocol    = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      enabled             = optional(bool, true)
      path                = optional(string, "/")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200-399")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
    }), null)
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
    }), null)
    deregistration_delay = optional(number, 300)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "alb_listeners" {
  type = map(object({
    port              = number
    protocol          = string
    ssl_policy        = optional(string)
    certificate_arn   = optional(string)
    target_group_name = string
  }))
  default = {}
}

variable "alb_attachments" {
  type = map(object({
    target_group_name = string
    target_id         = optional(string, null)
    target_name       = optional(string, null)
    port              = optional(number, null)
  }))
  default = {}
}

variable "ec2_lookup_names" {
  description = "Names to lookup existing EC2 instances for ALB attachments"
  type        = set(string)
  default     = []
}
