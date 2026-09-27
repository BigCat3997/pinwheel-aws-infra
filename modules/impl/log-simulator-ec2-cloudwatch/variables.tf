variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))

  validation {
    condition     = length(var.public_subnets) > 0
    error_message = "At least one public subnet must be provided."
  }
}

variable "internet_gateway_name" {
  description = "Name tag for the internet gateway"
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_subnet_name" {
  description = "Name of the public subnet in which to launch the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID override; when null, the latest Canonical Ubuntu 24.04 amd64 AMI is read from SSM"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_user" {
  description = "Default SSH user for the selected AMI"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_secret_name" {
  description = "Secrets Manager secret name whose current value is an OpenSSH public key"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair Terraform creates from the public key secret"
  type        = string
}

variable "ssh_ingress_cidrs" {
  description = "IPv4 CIDR blocks allowed to connect over SSH; leave empty to disable inbound SSH"
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root EBS volume"
  type        = bool
  default     = true
}

variable "volume_tags" {
  description = "Additional tags applied to the root EBS volume"
  type        = map(string)
  default     = {}
}

variable "simulated_log_paths" {
  description = "File paths where the simulated services each write their own log, one per service"
  type        = list(string)
  default = [
    "/var/log/app/service1.log",
    "/var/log/app/service2.log",
    "/var/log/app/service3.log",
    "/var/log/app/service4.log",
    "/var/log/app/service5.log",
    "/var/log/app/service6.log",
  ]

  validation {
    condition     = length(var.simulated_log_paths) == 6
    error_message = "simulated_log_paths must contain exactly 6 file paths, one per simulated service."
  }
}

variable "collected_log_paths" {
  description = "Subset of simulated_log_paths that the CloudWatch Agent tails and pushes into log_group_name"
  type        = list(string)
  default = [
    "/var/log/app/service1.log",
    "/var/log/app/service2.log",
  ]

  validation {
    condition     = length(var.collected_log_paths) == 2
    error_message = "collected_log_paths must contain exactly 2 file paths."
  }
}

variable "log_group_name" {
  description = "Name of the single CloudWatch log group that receives both collected log streams"
  type        = string
}

variable "log_group_retention_in_days" {
  description = "Retention period, in days, for the CloudWatch log group"
  type        = number
  default     = 14
}

variable "log_simulation_interval_seconds" {
  description = "How often, in seconds, each simulated service appends a line to its log file"
  type        = number
  default     = 10
}

variable "log_archive_name" {
  description = "Name prefix for the log archive pipeline resources (Firehose, Lambda, IAM roles)"
  type        = string
  default     = "log-simulator-archive"
}

variable "log_archive_bucket_name" {
  description = "Globally unique name of the S3 bucket that stores archived logs (3-63 chars, lowercase letters, digits, dots, hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.log_archive_bucket_name))
    error_message = "log_archive_bucket_name must be 3-63 characters of lowercase letters, digits, dots or hyphens, starting and ending with a letter or digit."
  }
}

variable "log_archive_force_destroy" {
  description = "Allow Terraform to delete the log archive bucket even when it contains objects"
  type        = bool
  default     = false
}

variable "log_archive_expiration_days" {
  description = "Days after which archived log objects expire"
  type        = number
  default     = 90
}

variable "log_archive_buffer_size_mb" {
  description = "Firehose buffer size in MB before flushing an object to S3 (1-128); larger means fewer, bigger objects"
  type        = number
  default     = 5
}

variable "log_archive_buffer_interval_seconds" {
  description = "Firehose buffer interval in seconds before flushing to S3 (60-900)"
  type        = number
  default     = 300
}

variable "log_subscription_filter_pattern" {
  description = "CloudWatch Logs filter pattern for the subscription; empty string forwards every event of every stream"
  type        = string
  default     = ""
}
