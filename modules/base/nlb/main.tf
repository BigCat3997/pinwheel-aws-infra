resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  internal           = var.enable_public_access ? false : true
  tags               = var.tags

  subnets = length(var.subnet_mappings) == 0 ? var.subnet_ids : null

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings

    content {
      subnet_id            = subnet_mapping.value.subnet_id
      private_ipv4_address = try(subnet_mapping.value.private_ipv4_address, null)
      allocation_id        = try(subnet_mapping.value.allocation_id, null)
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  stickiness {
    enabled = var.enable_stickiness
    type    = "source_ip"
  }

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "this" {
  count = var.autoscaling_group_name != null && var.autoscaling_group_name != "" ? 1 : 0

  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

resource "aws_lb_target_group_attachment" "instance_targets" {
  for_each = var.target_type == "instance" ? { for idx, instance_id in var.target_instance_ids : idx => instance_id } : {}

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}

resource "aws_lb_target_group_attachment" "ip_targets" {
  for_each = var.target_type == "ip" ? { for idx, ip in var.target_ips : idx => ip } : {}

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}
