output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate data for the EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "The cluster security group ID created by EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster (used for IRSA)."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
