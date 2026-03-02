resource "aws_route_table" "public" {
  for_each = { for rt in var.public_route_tables : rt.name => rt }
  vpc_id   = var.vpc_id

  dynamic "route" {
    for_each = var.internet_gateway_id != null ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.internet_gateway_id
    }
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_route_table" "private" {
  for_each = { for rt in var.private_route_tables : rt.name => rt }
  vpc_id   = var.vpc_id

  dynamic "route" {
    for_each = each.value.nat_gw_name != null ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_ids[each.value.nat_gw_name]
    }
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}
