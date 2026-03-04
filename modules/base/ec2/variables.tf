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

variable "create_external_volume" {
  description = "Whether to create and attach an external EBS volume"
  type        = bool
  default     = false
}

variable "external_volume_size" {
  description = "Size (GiB) of external EBS volume"
  type        = number
  default     = 20
}

variable "external_volume_type" {
  description = "Type of external EBS volume"
  type        = string
  default     = "gp3"
}

variable "external_volume_encrypted" {
  description = "Whether external EBS volume is encrypted"
  type        = bool
  default     = false
}

variable "external_volume_device_name" {
  description = "Device name for attached external EBS volume"
  type        = string
  default     = "/dev/sdf"
}

variable "external_volume_iops" {
  description = "Provisioned IOPS for external EBS volume (when supported by volume type)"
  type        = number
  default     = null
}

variable "external_volume_throughput" {
  description = "Provisioned throughput (MiB/s) for external EBS volume (gp3 only)"
  type        = number
  default     = null
}

variable "metadata_http_endpoint" {
  description = "Whether to enable the instance metadata service"
  type        = string
  default     = "enabled"
}

variable "metadata_http_tokens" {
  description = "Whether to require IMDSv2 for instance metadata access"
  type        = string
  default     = "required"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "tags" {
  type    = map(string)
  default = {}
}
