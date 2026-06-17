output "efs_id" {
  description = "EFS file system ID"
  value       = module.local_efs.id
}

output "efs_arn" {
  description = "EFS file system ARN"
  value       = module.local_efs.arn
}

output "efs_dns_name" {
  description = "EFS DNS name used for mounting"
  value       = module.local_efs.dns_name
}

output "efs_access_point_ids" {
  description = "Map of EFS access point IDs by access point name"
  value       = module.local_efs.access_point_ids
}

output "efs_access_point_arns" {
  description = "Map of EFS access point ARNs by access point name"
  value       = module.local_efs.access_point_arns
}

output "efs_file_system_policy_id" {
  description = "EFS file system policy ID when role-based mount enforcement is enabled"
  value       = module.local_efs.file_system_policy_id
}

output "ec2_node1_role_arn" {
  description = "IAM role ARN attached to the first EC2 node"
  value       = module.local_ec2_node1_role.role_arn
}

output "ec2_node2_role_arn" {
  description = "IAM role ARN attached to the second EC2 node"
  value       = module.local_ec2_node2_role.role_arn
}

output "ec2_node1_instance_id" {
  description = "Instance ID of the first EC2 node"
  value       = module.local_ec2_node1.id
}

output "ec2_node1_private_ip" {
  description = "Private IP of the first EC2 node"
  value       = module.local_ec2_node1.private_ip
}

output "ec2_node2_instance_id" {
  description = "Instance ID of the second EC2 node"
  value       = module.local_ec2_node2.id
}

output "ec2_node2_private_ip" {
  description = "Private IP of the second EC2 node"
  value       = module.local_ec2_node2.private_ip
}

output "bastion_instance_id" {
  description = "Instance ID of bastion"
  value       = module.local_bastion_ec2.id
}

output "bastion_public_ip" {
  description = "Public IP of bastion"
  value       = module.local_bastion_ec2.public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.local_bastion_ec2.ssh_public
}

output "nat_gateway_id" {
  description = "NAT gateway ID used by private route table"
  value       = module.local_nat_gateway.id
}

output "nat_gateway_eip" {
  description = "Elastic IP allocated to NAT gateway"
  value       = module.local_nat_gateway_eip.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.local_vpc.id
}
