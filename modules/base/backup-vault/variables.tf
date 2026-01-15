variable "create" {
  type    = bool
  default = false
}

variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
