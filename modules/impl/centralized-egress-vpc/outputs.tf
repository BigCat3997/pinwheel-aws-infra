output "tgw_id" {
  description = "Transit Gateway ID"
  value       = module.tgw.id
}

output "tgw_arn" {
  description = "Transit Gateway ARN"
  value       = module.tgw.arn
}

output "shared_vpc_id" {
  description = "Shared VPC ID"
  value       = module.local_shared_vpc.id
}

output "shared_vpc_cidr" {
  description = "Shared VPC CIDR block"
  value       = module.local_shared_vpc.cidr_block
}

output "shared_public_subnet_ids" {
  description = "Map of shared VPC public subnet names to IDs"
  value       = module.local_shared_subnet.public_subnet_ids
}

output "shared_private_subnet_ids" {
  description = "Map of shared VPC private subnet names to IDs"
  value       = module.local_shared_subnet.private_subnet_ids
}

# output "shared_nat_gateway_ids" {
#   description = "Map of shared VPC NAT Gateway names to IDs"
#   value       = module.local_shared_nat_gateway.id
# }

output "shared_igw_id" {
  description = "Shared VPC Internet Gateway ID"
  value       = module.local_shared_igw.id
}

output "tgw_shared_vpc_attachment_id" {
  description = "TGW Shared VPC Attachment ID"
  value       = module.tgw_shared_vpc_attachment.id
}

output "consumer_vpc_id" {
  description = "Consumer VPC ID"
  value       = module.consumer_vpc.id
}

output "consumer_vpc_cidr" {
  description = "Consumer VPC CIDR block"
  value       = module.consumer_vpc.cidr_block
}

output "consumer_public_subnet_ids" {
  description = "Map of consumer VPC public subnet names to IDs"
  value       = module.consumer_subnet.public_subnet_ids
}

output "consumer_private_subnet_ids" {
  description = "Map of consumer VPC private subnet names to IDs"
  value       = module.consumer_subnet.private_subnet_ids
}

output "consumer_igw_id" {
  description = "Consumer VPC Internet Gateway ID"
  value       = module.consumer_igw.id
}

output "tgw_consumer_vpc_attachment_id" {
  description = "TGW Consumer VPC Attachment ID"
  value       = module.tgw_consumer_vpc_attachment.id
}

output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = module.bastion_ec2.id
}

output "bastion_public_ip" {
  description = "Bastion EC2 public IP address"
  value       = module.bastion_ec2.public_ip
}

output "bastion_private_ip" {
  description = "Bastion EC2 private IP address"
  value       = module.bastion_ec2.private_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.bastion_ec2.ssh_public
}

output "app_ec2_instance_id" {
  description = "App EC2 instance ID"
  value       = module.app_ec2.id
}

output "app_ec2_private_ip" {
  description = "App EC2 private IP address"
  value       = module.app_ec2.private_ip
}

output "app_ec2_ssh_command_from_bastion" {
  description = "SSH command to connect to app EC2 from bastion"
  value       = module.app_ec2.ssh_private
}

output "bastion_key_pair_name" {
  description = "Bastion key pair name"
  value       = module.bastion_key_pair.name
}

output "app_ec2_key_pair_name" {
  description = "App EC2 key pair name"
  value       = module.app_ec2_key_pair.name
}
