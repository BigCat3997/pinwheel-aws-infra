variable "name" {
  description = "Name of the SSM document"
  type        = string
}

variable "document_type" {
  description = "Document type, e.g. Command, Automation, Session"
  type        = string
  default     = "Command"
}

variable "document_format" {
  description = "Document format: JSON or YAML"
  type        = string
  default     = "JSON"
}

variable "content" {
  description = "Document content in the chosen format"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
