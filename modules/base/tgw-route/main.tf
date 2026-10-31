resource "aws_ec2_transit_gateway_route" "this" {
  destination_cidr_block         = var.destination_cidr_block
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = var.transit_gateway_attachment_id
  blackhole                      = var.blackhole
}
