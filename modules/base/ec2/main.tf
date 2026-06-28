resource "aws_iam_instance_profile" "this" {
  count = var.instance_profile_name != null && var.role_name != null ? 1 : 0

  name = var.instance_profile_name
  role = var.role_name
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  iam_instance_profile        = try(aws_iam_instance_profile.this[0].name, null)
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = var.volume_encrypted
    delete_on_termination = var.volume_delete_on_termination

    tags = merge(
      var.tags,
      var.volume_tags
    )
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  tags = merge(
    var.ec2_tags,
    var.tags, {
      Name = var.name
    }
  )
}

resource "aws_ebs_volume" "external" {
  count = var.create_external_volume ? 1 : 0

  availability_zone = aws_instance.this.availability_zone
  size              = var.external_volume_size
  type              = var.external_volume_type
  encrypted         = var.external_volume_encrypted
  iops              = var.external_volume_iops
  throughput        = var.external_volume_throughput

  tags = merge(var.tags, var.ebs_volume_tags)
}

resource "aws_volume_attachment" "external" {
  count = var.create_external_volume ? 1 : 0

  device_name = var.external_volume_device_name
  volume_id   = aws_ebs_volume.external[0].id
  instance_id = aws_instance.this.id
}
