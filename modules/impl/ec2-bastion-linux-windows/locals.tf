locals {
  public_subnet_cidr_by_name  = { for subnet in var.public_subnets : subnet.name => subnet.cidr }
  private_subnet_cidr_by_name = { for subnet in var.private_subnets : subnet.name => subnet.cidr }

  bastion_ami_id         = coalesce(var.bastion_ami_id, data.aws_ssm_parameter.amazon_linux_2023_ami.value)
  windows_bastion_ami_id = coalesce(var.windows_bastion_ami_id, data.aws_ssm_parameter.windows_server_2022_ami.value)

  bastion_private_ip_static = var.bastion_private_ip

  windows_bastion_private_ip_static = var.windows_bastion_private_ip

  private_ec2_private_ip_static = var.private_ec2_private_ip

  private_ec2_secondary_private_ip_static = var.private_ec2_secondary_private_ip

  private_ec2_endpoint_subnet_names = distinct([
    var.private_ec2_subnet_name,
    var.private_ec2_secondary_subnet_name,
  ])

  private_ec2_endpoint_subnet_ids = [
    for subnet_name in local.private_ec2_endpoint_subnet_names : module.local_subnet.private_subnets[subnet_name]
  ]

  bastion_user_data_linux = <<-EOT
    #!/bin/bash
    echo 'Bastion ready' > /var/log/bastion-user-data.log
  EOT

  bastion_user_data_windows = <<-EOT
    <powershell>
    Write-Output 'Windows bastion ready' | Out-File -FilePath C:\\bastion-user-data.log -Encoding utf8 -Force
    </powershell>
  EOT

  allow_all_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  # modules/base/cloudwatch-log-groups keys its "names" output by the log
  # group's full name, not by the "key" field, so index by that same name.
  private_ec2_system_log_group_name = "/aws/ec2/${var.private_ec2_name}/system"

  cloudwatch_agent_config = templatefile("${path.module}/files/cloudwatch-agent-config.json", {
    log_group_name = module.local_cloudwatch_log_groups.names[local.private_ec2_system_log_group_name]
  })
}
