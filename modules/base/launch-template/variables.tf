variable "name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type    = string
  default = null
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
}

variable "volume_type" {
  description = "Root volume type (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 20
}

variable "volume_encrypted" {
  description = "Encrypt the root volume"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
}
