# The route controlled by Pacemaker in a real SAP deployment. It initially
# directs the Overlay IP to node A. For this lab, replace its target manually.
resource "aws_route" "overlay_to_active_node" {
  route_table_id         = module.ha_route_tables.public_route_table_ids[var.ha_overlay_route_table_name]
  destination_cidr_block = local.overlay_cidr
  network_interface_id   = module.primary_ec2.primary_network_interface_id
}
