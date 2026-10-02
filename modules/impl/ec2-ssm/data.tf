data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Red Hat's official AWS account; RHEL has no public SSM AMI parameter.
data "aws_ami" "rhel_9" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-${var.rhel_ec2_version}*_HVM-*-x86_64-*-Hourly2-GP3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_secretsmanager_secret_version" "ec2_public_key" {
  secret_id = var.ec2_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "rhel_ec2_public_key" {
  secret_id = var.rhel_ec2_public_key_secret_name
}

data "aws_caller_identity" "current" {}
