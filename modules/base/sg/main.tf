resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })
}

# Note: source_security_group_id only supports single SG - use separate rules for multiple SGs
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.security_rules : idx => rule }

  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  source_security_group_id = try(each.value.security_group_id, null)
  description              = lookup(each.value, "description", null)
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port        = each.value.from_port
  to_port          = each.value.to_port
  protocol         = each.value.protocol
  cidr_blocks      = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks = lookup(each.value, "ipv6_cidr_blocks", null)
  description      = lookup(each.value, "description", null)
}
