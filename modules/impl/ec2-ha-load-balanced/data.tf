data "aws_caller_identity" "current" {}

data "aws_instance" "this" {
  for_each = var.ec2_lookup_names

  filter {
    name   = "tag:Name"
    values = [each.value]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.primary_ec2, module.standby_ec2]
}

data "aws_secretsmanager_secret_version" "bastion_ec2_public_key" {
  secret_id = var.bastion_ec2_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "primary_ec2_public_key" {
  secret_id = var.primary_ec2_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "standby_ec2_public_key" {
  secret_id = var.standby_ec2_public_key_secret_name
}
