resource "aws_eip" "nat" {
  for_each = { for gw in var.nat_gateways : gw.name => gw }
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = each.value.eip_name
  })
}
