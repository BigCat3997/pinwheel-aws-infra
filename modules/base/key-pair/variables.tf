variable "tags" {
  description = "A map of tags to add to the key pair"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Whether to create the key pair"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the key pair"
  type        = string
}

variable "public_key" {
  type    = string
  default = null
}

variable "public_key_path" {
  description = "The path to the public key file"
  type        = string
  default     = null
}
