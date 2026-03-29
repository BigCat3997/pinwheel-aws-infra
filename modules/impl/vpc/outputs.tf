output "vpc_id" {
  description = "VPC ID"
  value       = module.local_vpc.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.local_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "Map of public subnet names to IDs"
  value       = module.local_subnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Map of private subnet names to IDs"
  value       = module.local_subnet.private_subnet_ids
}
