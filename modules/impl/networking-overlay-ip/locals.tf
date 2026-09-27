locals {
  ami_id       = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  overlay_cidr = "${var.overlay_ip}/32"

  ec2_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
