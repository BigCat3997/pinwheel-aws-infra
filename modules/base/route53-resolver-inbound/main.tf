resource "aws_route53_resolver_endpoint" "this" {
  name                   = var.name
  direction              = "INBOUND"
  security_group_ids     = var.security_group_ids
  resolver_endpoint_type = "IPV4"

  dynamic "ip_address" {
    for_each = var.ip_addresses

    content {
      subnet_id = ip_address.value.subnet_id
      ip        = ip_address.value.ip
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
