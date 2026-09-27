resource "aws_ec2_transit_gateway_route" "overlay_to_ha" {
  destination_cidr_block         = local.overlay_cidr
  transit_gateway_attachment_id  = module.ha_tgw_attachment.id
  transit_gateway_route_table_id = module.transit_gateway.association_default_route_table_id
}

resource "aws_route" "client_to_overlay" {
  route_table_id         = module.client_route_tables.public_route_table_ids[var.client_overlay_route_table_name]
  destination_cidr_block = local.overlay_cidr
  transit_gateway_id     = module.transit_gateway.id

  depends_on = [module.client_tgw_attachment]
}

resource "aws_route" "ha_return_to_client" {
  route_table_id         = module.ha_route_tables.public_route_table_ids[var.ha_overlay_route_table_name]
  destination_cidr_block = var.client_vpc_cidr_block
  transit_gateway_id     = module.transit_gateway.id

  depends_on = [module.ha_tgw_attachment]
}
