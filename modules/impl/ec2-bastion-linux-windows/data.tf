data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "windows_server_2022_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

data "aws_secretsmanager_secret_version" "bastion_ec2_public_key" {
  secret_id = var.bastion_ec2_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "windows_bastion_ec2_public_key" {
  secret_id = var.windows_bastion_ec2_public_key_secret_name
}

data "aws_secretsmanager_secret" "private_ec2_public_key" {
  name = var.sm_private_ec2_ssh_public_key_name
}

data "aws_secretsmanager_secret_version" "private_ec2_public_key" {
  secret_id = data.aws_secretsmanager_secret.private_ec2_public_key.id
}

data "aws_secretsmanager_secret" "private_ec2_secondary_public_key" {
  name = var.sm_private_ec2_secondary_ssh_public_key_name
}

data "aws_secretsmanager_secret_version" "private_ec2_secondary_public_key" {
  secret_id = data.aws_secretsmanager_secret.private_ec2_secondary_public_key.id
}

data "aws_caller_identity" "current" {}
