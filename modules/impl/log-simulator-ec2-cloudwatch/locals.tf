check "collected_log_paths_is_subset" {
  assert {
    condition     = alltrue([for p in var.collected_log_paths : contains(var.simulated_log_paths, p)])
    error_message = "collected_log_paths must be a subset of simulated_log_paths."
  }
}

locals {
  ami_id = coalesce(var.ami_id, data.aws_ssm_parameter.ubuntu_2404_ami.value)

  ingress_rules = [
    for cidr in var.ssh_ingress_cidrs : {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [cidr]
      description = "SSH access from ${cidr}"
    }
  ]

  allow_all_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound IPv4 traffic"
  }

  collected_log_entries = [
    for path in var.collected_log_paths : {
      path   = path
      stream = trimsuffix(basename(path), ".log")
    }
  ]

  cloudwatch_agent_config = templatefile("${path.module}/files/cloudwatch-agent-config.json.tftpl", {
    log_entries    = local.collected_log_entries
    log_group_name = module.local_cloudwatch_log_groups.names["/ec2/log-simulator/app"]
  })

  user_data = templatefile("${path.module}/templates/log-simulator-user-data.sh.tftpl", {
    cloudwatch_agent_config_base64  = base64encode(local.cloudwatch_agent_config)
    simulated_log_paths             = var.simulated_log_paths
    log_simulation_interval_seconds = var.log_simulation_interval_seconds
  })
}
