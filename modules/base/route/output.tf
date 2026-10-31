output "route_table_ids" {
  description = "Map of route table names that received the route"
  value       = { for k, r in aws_route.this : k => r.route_table_id }
}
