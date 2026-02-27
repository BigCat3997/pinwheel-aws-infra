resource "aws_vpc" "this" {
  count                = var.create ? 1 : 0
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, {
    Name = var.name
  })
}

data "aws_vpc" "this" {
  count = var.create ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [var.name]
  }
}
