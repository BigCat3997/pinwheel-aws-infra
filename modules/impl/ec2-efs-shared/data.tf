data "aws_secretsmanager_secret" "ec2_public_key" {
  name = var.sm_ec2_ssh_public_key_name
}

data "aws_secretsmanager_secret_version" "ec2_public_key" {
  secret_id = data.aws_secretsmanager_secret.ec2_public_key.id
}
