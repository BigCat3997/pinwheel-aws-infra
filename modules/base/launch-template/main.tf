resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = var.user_data != null ? base64encode(var.user_data) : null

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    security_groups             = var.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = var.volume_type
      volume_size           = var.volume_size
      encrypted             = var.volume_encrypted
      delete_on_termination = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
