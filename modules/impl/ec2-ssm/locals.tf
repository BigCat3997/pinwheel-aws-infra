locals {
  ec2_ami_id = coalesce(var.ec2_ami_id, data.aws_ssm_parameter.amazon_linux_2023_ami.value)

  rhel_ec2_ami_id = coalesce(var.rhel_ec2_ami_id, data.aws_ami.rhel_9.id)

  # Installs the SSM agent if the AMI does not already ship it.
  rhel_user_data = <<-EOT
    #!/bin/bash
    if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
      dnf install -y https://s3.${var.aws_region}.amazonaws.com/amazon-ssm-${var.aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm
    fi
    systemctl enable --now amazon-ssm-agent
  EOT

  # Session Manager needs all three interface endpoints when there is no NAT/IGW.
  ssm_endpoint_services = toset(["ssm", "ssmmessages", "ec2messages"])

  subnet_ids_by_name = merge(module.local_subnet.public_subnets, module.local_subnet.private_subnets)

  endpoint_subnet_ids = [
    for subnet_name in distinct(concat([var.ec2_subnet_name], var.endpoint_extra_subnet_names)) :
    local.subnet_ids_by_name[subnet_name]
  ]
}
