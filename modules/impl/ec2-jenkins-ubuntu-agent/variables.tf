variable "aws_region" {
  description = "AWS region for the Jenkins agent"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used to name the Jenkins agent and its supporting resources"
  type        = string
  default     = "jenkins-agent"

  validation {
    condition     = length(trimspace(var.name_prefix)) > 0
    error_message = "name_prefix must not be empty."
  }
}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR block for the Jenkins agent VPC"
  type        = string
  default     = "10.30.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the public Jenkins agent subnet"
  type        = string
  default     = "10.30.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone" {
  description = "Availability zone for the public subnet; when null, use the first available zone in aws_region"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID override; when null, use the latest Canonical Ubuntu 24.04 amd64 AMI from its public SSM parameter"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type for the Jenkins agent"
  type        = string
  default     = "t3.medium"
}

variable "ssh_user" {
  description = "SSH user Jenkins uses to launch the agent; must match the selected AMI's default user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_secret_name" {
  description = "Secrets Manager secret name whose current value is the OpenSSH public key Jenkins uses for SSH"
  type        = string
}

variable "jenkins_controller_cidrs" {
  description = "Trusted IPv4 CIDRs allowed to SSH to the agent; leave empty to disable inbound SSH"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.jenkins_controller_cidrs : can(cidrnetmask(cidr))])
    error_message = "Every jenkins_controller_cidrs value must be a valid IPv4 CIDR block."
  }
}

variable "terraform_version" {
  description = "Terraform version installed by the bootstrap script"
  type        = string
  default     = "1.9.8"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.terraform_version))
    error_message = "terraform_version must use semantic version format, for example 1.9.8."
  }
}

variable "root_volume_size" {
  description = "Encrypted root EBS volume size in GiB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 20
    error_message = "root_volume_size must be at least 20 GiB."
  }
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable one-minute EC2 monitoring"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Whether to attach AmazonSSMManagedInstanceCore for Session Manager access"
  type        = bool
  default     = true
}

variable "instance_managed_policy_arns" {
  description = "Additional managed IAM policy ARNs required by Jenkins jobs; keep these least-privileged"
  type        = list(string)
  default     = []
}

variable "instance_inline_policies" {
  description = "Additional least-privileged IAM policies for Jenkins jobs, keyed by policy name"
  type        = map(string)
  default     = {}
}

variable "user_data_replace_on_change" {
  description = "Whether a bootstrap-script change should replace the EC2 instance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
