output "public_route_table_ids" {
  description = "Map of public route table names to IDs"
  value       = { for k, v in aws_route_table.public : k => v.id }
}

output "private_route_table_ids" {
  description = "Map of private route table names to IDs"
  value       = { for k, v in aws_route_table.private : k => v.id }
}
