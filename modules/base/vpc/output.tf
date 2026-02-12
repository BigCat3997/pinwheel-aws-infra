output "id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in var.public_subnets : aws_subnet.public[s.name].id]
}

output "private_subnet_ids" {
  value = [for s in var.private_subnets : aws_subnet.private[s.name].id]
}

output "public_route_table_ids" {
  value = [for rt in var.public_route_tables : aws_route_table.public[rt.name].id]
}

output "private_route_table_ids" {
  value = [for rt in var.private_route_tables : aws_route_table.private[rt.name].id]
}

output "nat_gateway_ids" {
  value = [for gw in var.nat_gateways : aws_nat_gateway.this[gw.name].id]
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "public_subnets" {
  description = "Map of public subnet name to subnet id"
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnets" {
  description = "Map of private subnet name to subnet id"
  value       = { for k, s in aws_subnet.private : k => s.id }
}
