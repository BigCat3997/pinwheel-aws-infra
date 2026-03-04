resource "aws_subnet" "public" {
  for_each = var.create ? { for s in var.public_subnets : s.name => s } : {}

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_subnet" "private" {
  for_each = var.create ? { for s in var.private_subnets : s.name => s } : {}

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = each.key
  })
}

data "aws_subnet" "public" {
  for_each = var.create ? {} : { for s in var.public_subnets : s.name => s }

  filter {
    name   = "tag:Name"
    values = [each.key]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "private" {
  for_each = var.create ? {} : { for s in var.private_subnets : s.name => s }

  filter {
    name   = "tag:Name"
    values = [each.key]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
