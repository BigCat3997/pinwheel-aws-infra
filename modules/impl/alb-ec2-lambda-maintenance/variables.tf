variable "aws_region" {
  description = "AWS region to deploy the stack into"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix used for all resource names"
  type        = string
}

variable "maintenance_mode" {
  description = "false = ALB forwards to the nginx EC2 target group, true = ALB forwards to Lambda which serves the S3 maintenance page"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the demo VPC"
  type        = string
}

variable "public_subnets" {
  description = "At least two public subnets so the ALB can span AZs and each nginx EC2 can sit in its own subnet"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))

  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "Provide at least two public subnets for the ALB and two nginx EC2 instances."
  }
}

variable "alb_port" {
  description = "HTTP port exposed by the ALB"
  type        = number
  default     = 80
}

variable "instance_port" {
  description = "Port exposed by nginx on the EC2 instances"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "EC2 instance type for the nginx web servers"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Optional existing EC2 key pair for SSH access"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the nginx EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name used to store the maintenance HTML page"
  type        = string
}

variable "maintenance_object_key" {
  description = "Object key for the static maintenance page inside the bucket"
  type        = string
  default     = "index.html"
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to destroy the maintenance bucket even when it contains files"
  type        = bool
  default     = true
}
