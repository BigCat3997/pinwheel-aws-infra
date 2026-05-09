locals {
  public_subnet_cidr_by_name  = { for sn in var.public_subnets : sn.name => sn.cidr }
  private_subnet_cidr_by_name = { for sn in var.private_subnets : sn.name => sn.cidr }

  bastion_private_ip_static = coalesce(
    var.bastion_private_ip,
    cidrhost(local.public_subnet_cidr_by_name[var.bastion_subnet_name], 10)
  )

  app_ec2_private_ip_static = coalesce(
    var.app_ec2_private_ip,
    cidrhost(local.private_subnet_cidr_by_name[var.app_ec2_subnet_name], 10)
  )

  app_standby_ec2_private_ip_static = coalesce(
    var.app_standby_ec2_private_ip,
    cidrhost(local.private_subnet_cidr_by_name[var.app_standby_ec2_subnet_name], 11)
  )

  cloudwatch_user_data = file("${path.module}/resources/cloudwatch-user-data.sh")
  app_nginx_user_data  = file("${path.module}/resources/app-nginx-user-data.sh")
}
