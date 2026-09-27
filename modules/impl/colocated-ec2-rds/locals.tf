locals {
  private_subnet_cidr_by_name = { for s in var.private_subnets : s.name => s.cidr }

  primary_private_ip = cidrhost(local.private_subnet_cidr_by_name[var.ec2_primary_subnet_name], 10)
  standby_private_ip = cidrhost(local.private_subnet_cidr_by_name[var.ec2_standby_subnet_name], 10)

  primary_subnet_az = one([
    for s in var.private_subnets : s.az if s.name == var.ec2_primary_subnet_name
  ])

  standby_subnet_az = one([
    for s in var.private_subnets : s.az if s.name == var.ec2_standby_subnet_name
  ])

  lambda_src_dir  = "${path.module}/files/lambda/rds_db2_failover_handler"
  lambda_zip_file = "${path.module}/files/lambda/rds_db2_failover_handler.zip"
}
