output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.local_eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.local_eks.cluster_name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = module.local_eks.cluster_arn
}

output "cluster_endpoint" {
  description = "The API server endpoint of the EKS cluster."
  value       = module.local_eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate data for the EKS cluster."
  value       = module.local_eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "The cluster security group ID created by EKS."
  value       = module.local_eks.cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "The OIDC issuer URL for IRSA."
  value       = module.local_eks.cluster_oidc_issuer
}
