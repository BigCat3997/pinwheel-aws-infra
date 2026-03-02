variable "name" {
  type        = string
  description = "EC2 instance name"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "user_data" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

variable "volume_encrypted" {
  type    = bool
  default = false
}

variable "volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "tags" {
  type    = map(string)
  default = {}
}
