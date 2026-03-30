resource "aws_eip" "this" {
  domain = var.domain

  tags = merge(var.tags, {
    Name = var.name
  })
}
