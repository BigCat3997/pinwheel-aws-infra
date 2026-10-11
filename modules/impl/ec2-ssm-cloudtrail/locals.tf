locals {
  bastion_mon_ec2_ami_id = coalesce(var.bastion_mon_ec2_ami_id, data.aws_ssm_parameter.amazon_linux_2023_ami.value)

  app_mon_ec2_ami_id = coalesce(var.app_mon_ec2_ami_id, data.aws_ami.rhel_9.id)

  # Session Manager needs the three ssm* interface endpoints when there is no NAT/IGW;
  # "monitoring" is for the CloudWatch agent (PutMetricData).
  ssm_endpoint_services = toset(["ssm", "ssmmessages", "ec2messages", "monitoring"])

  subnet_ids_by_name = merge(module.local_subnet.public_subnets, module.local_subnet.private_subnets)

  endpoint_subnet_ids = [
    for subnet_name in distinct(concat([var.bastion_mon_ec2_subnet_name], var.endpoint_extra_subnet_names)) :
    local.subnet_ids_by_name[subnet_name]
  ]

  # Built from the name (not the resource) to avoid a cycle with the bucket/KMS policies.
  cloudtrail_arn = "arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"
}
