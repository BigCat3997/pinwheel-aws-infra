resource "aws_route" "this" {
  for_each = var.route_table_ids

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
  gateway_id             = var.gateway_id
  nat_gateway_id         = var.nat_gateway_id
}
