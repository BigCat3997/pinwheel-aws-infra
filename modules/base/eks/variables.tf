variable "name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster. e.g. '1.30'."
  type        = string
}

variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster control plane."
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for EKS worker nodes."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster and node groups."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of additional security group IDs to attach to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster API server endpoint is accessible from within the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API server endpoint is accessible from the internet."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable. Valid values: api, audit, authenticator, controllerManager, scheduler."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "node_groups" {
  description = "A list of EKS managed node group configurations."
  type = list(object({
    name           = string
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    desired_size   = number
    min_size       = number
    max_size       = number
    max_unavailable = optional(number, 1)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
