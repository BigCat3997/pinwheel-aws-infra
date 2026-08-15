locals {
  allow_https_ingress = {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    security_group_id = module.local_app_instance_sg.id
    description       = "Allow HTTPS"
  }

  allow_all_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  logs_vpce_subnet_configs = [
    {
      subnet_id = module.local_subnet.private_subnets["private-a"]
      ipv4      = "10.190.11.254"
    },
    {
      subnet_id = module.local_subnet.private_subnets["private-b"]
      ipv4      = "10.190.12.254"
    },
  ]


  cloudwatch_log_group_name = "/aws/vpce-test/${var.app_instance_name}/push-logs-service"
  cloudwatch_stream_prefix  = "vpce-test"

  vpce_log_pusher_python = templatefile("${path.module}/templates/push-logs-service/vpce-log-pusher.py.tftpl", {
    aws_region                = var.aws_region
    cloudwatch_log_group_name = local.cloudwatch_log_group_name
    cloudwatch_stream_prefix  = local.cloudwatch_stream_prefix
    log_push_interval_seconds = var.log_push_interval_seconds
  })

  logs_vpc_endpoint_policy = templatefile("${path.module}/templates/iam/vpc-endpoint-policy.json.tftpl", {
    account_id    = data.aws_caller_identity.current.account_id
    log_group_arn = module.local_cloudwatch_log_group.arns["vpce_test"]
  })

  vpce_log_pusher_service = file("${path.module}/files/vpce-log-pusher.service")
  app_instance_user_data = templatefile("${path.module}/templates/push-logs-service/vpce-log-pusher-user-data.sh.tftpl", {
    python_script = local.vpce_log_pusher_python
    service_unit  = local.vpce_log_pusher_service
  })
}
