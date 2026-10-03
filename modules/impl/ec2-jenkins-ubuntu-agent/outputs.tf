output "instance_id" {
  description = "Jenkins agent EC2 instance ID"
  value       = module.agent.id
}

output "public_ip" {
  description = "Public IPv4 address assigned to the Jenkins agent"
  value       = module.agent.public_ip
}

output "private_ip" {
  description = "Private IPv4 address assigned to the Jenkins agent"
  value       = module.agent.private_ip
}

output "ssh_command" {
  description = "SSH command for the Jenkins agent"
  value       = module.agent.ssh_public
}

output "vpc_id" {
  description = "ID of the VPC created for the Jenkins agent"
  value       = module.vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet containing the Jenkins agent"
  value       = module.public_subnet.public_subnets[local.public_subnet_name]
}

output "instance_role_arn" {
  description = "IAM role ARN attached to the Jenkins agent"
  value       = module.agent_role.role_arn
}
