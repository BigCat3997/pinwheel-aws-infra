output "vpc_id" {
  description = "VPC ID"
  value       = module.local_vpc.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.local_vpc.cidr_block
}

output "public_subnet_names" {
  description = "List of public subnet names"
  value       = module.local_subnet.public_subnet_names
}

output "private_subnet_names" {
  description = "List of private subnet names"
  value       = module.local_subnet.private_subnet_names
}
