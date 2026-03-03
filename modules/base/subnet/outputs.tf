output "public_subnet_ids" {
  description = "Map of public subnet names to IDs"
  value       = var.create ? { for k, v in aws_subnet.public : k => v.id } : { for k, v in data.aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet names to IDs"
  value       = var.create ? { for k, v in aws_subnet.private : k => v.id } : { for k, v in data.aws_subnet.private : k => v.id }
}

output "public_subnets" {
  description = "Map of public subnet objects"
  value       = var.create ? aws_subnet.public : data.aws_subnet.public
}

output "private_subnets" {
  description = "Map of private subnet objects"
  value       = var.create ? aws_subnet.private : data.aws_subnet.private
}
