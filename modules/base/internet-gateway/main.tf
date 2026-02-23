resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.internet_gateway_name
  })
}
