output "nat_gateway_ids" {
  description = "Map of NAT gateway names to IDs"
  value = { for k, v in aws_nat_gateway.this : k => v.id }
}
