resource "aws_lb" "this" {
  name                       = var.name
  load_balancer_type         = var.type
  internal                   = var.enable_public ? false : true
  subnets                    = length(var.subnet_mappings) == 0 ? var.subnet_ids : null
  security_groups            = var.security_group_ids
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings

    content {
      subnet_id            = subnet_mapping.value.subnet_id
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
      allocation_id        = subnet_mapping.value.eip_id
    }
  }

  lifecycle {
    precondition {
      condition = (
        (length(var.subnet_ids) > 0) != (length(var.subnet_mappings) > 0)
      )
      error_message = "Provide either subnet_ids or subnet_mappings, not both and not neither."
    }
  }
  tags = var.tags
}
