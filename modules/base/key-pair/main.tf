resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = var.name
  public_key = file(var.public_key_path)

  lifecycle {
    precondition {
      condition     = var.public_key_path != null && can(file(var.public_key_path))
      error_message = "create_key_pair is true, but public_key_path is null or not readable."
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
