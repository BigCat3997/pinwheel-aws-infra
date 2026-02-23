resource "aws_route_table_association" "public" {
  for_each = { for a in var.public_rt_subnet_associations : a.key => a }

  subnet_id      = var.public_subnet_ids[each.value.sn_name]
  route_table_id = var.public_route_table_ids[each.value.rt_name]
}

resource "aws_route_table_association" "private" {
  for_each = { for a in var.rt_subnet_associations : a.key => a }

  subnet_id      = var.private_subnet_ids[each.value.sn_name]
  route_table_id = var.private_route_table_ids[each.value.rt_name]
}
