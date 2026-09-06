variable "tags" {
  type    = map(string)
  default = {}
}

variable "ec2_tags" {
  type    = map(string)
  default = {}
}

variable "volume_tags" {
  type    = map(string)
  default = {}
}


variable "ebs_volume_tags" {
  type    = map(string)
  default = {}
}

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

variable "private_ip" {
  type        = string
  description = "Fixed private IPv4 address for the instance"
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "source_dest_check" {
  description = "Whether the EC2 instance performs source/destination checks"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Whether to enable detailed (one-minute) CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "user_data" {
  type = string
}

variable "volume_name" {
  type        = string
  description = "EC2 instance volume name"
  default     = null
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

variable "metadata_http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}

variable "metadata_instance_metadata_tags" {
  description = "Whether to enable instance metadata tags"
  type        = string
  default     = "disabled"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair"
  default     = null
}

variable "user_data_replace_on_change" {
  type        = bool
  description = "Whether changes to user_data force instance replacement"
  default     = false
}

variable "instance_profile_name" {
  type        = string
  description = "Name for IAM instance profile created by this module"
  default     = null
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Name of an existing IAM instance profile to attach instead of creating one"
  default     = null
}

variable "role_name" {
  type        = string
  description = "IAM role name to attach to the instance profile"
  default     = null
}

variable "ebs_volume_name" {
  description = "Name tag for the external EBS volume (if created)"
  type        = string
  default     = null
}
