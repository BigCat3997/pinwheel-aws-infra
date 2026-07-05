resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = var.vpc_endpoint_type
  auto_accept         = var.auto_accept
  policy              = var.policy
  route_table_ids     = var.route_table_ids
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = var.private_dns_enabled
  ip_address_type     = var.ip_address_type

  dynamic "dns_options" {
    for_each = var.private_dns_only_for_inbound_resolver_endpoint == null ? [] : [1]
    content {
      private_dns_only_for_inbound_resolver_endpoint = var.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
