resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_subnet" "public" {
  for_each = { for s in var.public_subnets : s.name => s }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_subnet" "private" {
  for_each = { for s in var.private_subnets : s.name => s }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.internet_gateway_name
  })
}

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
  subnet_id     = aws_subnet.public[each.value.subnet_name].id

  tags = merge(var.tags, {
    Name = each.key
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  for_each = { for rt in var.public_route_tables : rt.name => rt }
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_route_table_association" "public" {
  for_each = { for a in local.public_rt_subnet_associations : a.key => a }

  subnet_id      = aws_subnet.public[each.value.sn_name].id
  route_table_id = aws_route_table.public[each.value.rt_name].id
}

resource "aws_route_table" "private" {
  for_each = { for rt in var.private_route_tables : rt.name => rt }
  vpc_id   = aws_vpc.this.id

  dynamic "route" {
    for_each = each.value.nat_gw_name != null ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[each.value.nat_gw_name].id
    }
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_route_table_association" "private" {
  for_each = { for a in local.rt_subnet_associations : a.key => a }

  subnet_id      = aws_subnet.private[each.value.sn_name].id
  route_table_id = aws_route_table.private[each.value.rt_name].id
}
