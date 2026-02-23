resource "aws_eip" "nat" {
	for_each = { for gw in var.nat_gateways : gw.name => gw }
	domain   = "vpc"

	tags = merge(var.tags, {
		Name = each.value.eip_name
	})
}

resource "aws_nat_gateway" "this" {
	for_each      = { for gw in var.nat_gateways : gw.name => gw }
	allocation_id = aws_eip.nat[each.key].id
	subnet_id     = var.public_subnet_ids[each.value.subnet_name]

	tags = merge(var.tags, {
		Name = each.key
	})

	depends_on = [aws_eip.nat]
}
