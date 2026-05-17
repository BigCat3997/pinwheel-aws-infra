locals {
  private_subnet_cidr_by_name = { for subnet in var.private_subnets : subnet.name => subnet.cidr }

  test_instance_private_ip_effective = coalesce(
    var.test_instance_private_ip,
    cidrhost(local.private_subnet_cidr_by_name[var.private_test_subnet_name], 10)
  )

  cloudwatch_log_group_name = "/aws/vpce-test/${var.test_instance_name}"
  cloudwatch_stream_prefix  = "vpce-test"

    vpce_log_pusher_python = templatefile("${path.module}/resources/vpce-log-pusher.py.tftpl", {
        aws_region                = var.aws_region
        cloudwatch_log_group_name = local.cloudwatch_log_group_name
        cloudwatch_stream_prefix  = local.cloudwatch_stream_prefix
        log_push_interval_seconds = var.log_push_interval_seconds
    })

    vpce_log_pusher_service = file("${path.module}/resources/vpce-log-pusher.service")

  common_allow_all_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  test_instance_user_data = templatefile("${path.module}/resources/vpce-log-pusher-user-data.sh.tftpl", {
    python_script = local.vpce_log_pusher_python
    service_unit  = local.vpce_log_pusher_service
  })
}
