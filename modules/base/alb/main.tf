resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.enable_public_access ? false : true
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id
  tags     = var.tags
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
  count = var.autoscaling_group_name != null ? 1 : 0

  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

resource "aws_lb_target_group_attachment" "instance_targets" {
  count = length(var.target_instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.target_port
}
