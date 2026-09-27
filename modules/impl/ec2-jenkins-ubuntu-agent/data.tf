data "aws_ssm_parameter" "ubuntu_2404_ami" {
  count = var.ami_id == null ? 1 : 0

  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_secretsmanager_secret" "ssh_public_key" {
  name = var.ssh_public_key_secret_name
}

data "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = data.aws_secretsmanager_secret.ssh_public_key.id
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
