output "public_subnet_ids" {
  description = "Map of public subnet names to IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet names to IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}
