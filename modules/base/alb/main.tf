resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.enable_public_access ? false : true
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.target_port
  protocol    = var.target_protocol
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = var.health_check_enabled
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = var.tags
}

resource "aws_lb_target_group" "lambda" {
  count = var.enable_integrate_lambda ? 1 : 0


  name        = var.lambda_target_group_name
  target_type = "lambda"

  lambda_multi_value_headers_enabled = false

  tags = var.tags
}

resource "aws_lambda_permission" "alb_invoke" {
  count = var.enable_integrate_lambda ? 1 : 0

  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda[0].arn
}

resource "aws_lb_target_group_attachment" "lambda" {
  count = var.enable_integrate_lambda ? 1 : 0

  target_group_arn = aws_lb_target_group.lambda[0].arn
  target_id        = var.lambda_function_arn

  depends_on = [aws_lambda_permission.alb_invoke]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = (var.maintenance_mode && var.lambda_function_arn != null) ? aws_lb_target_group.lambda[0].arn : aws_lb_target_group.this.arn
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
