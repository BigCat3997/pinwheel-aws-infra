data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "bastion_ec2_public_key" {
  secret_id = var.bastion_ec2_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "app_ec2_public_key" {
  secret_id = var.app_ec2_public_key_secret_name
}
