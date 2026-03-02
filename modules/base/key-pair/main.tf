resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = var.name
  public_key = coalesce(var.public_key, try(file(var.public_key_path), null), tls_private_key.key.public_key_openssh)

  tags = merge(var.tags, {
    Name = var.name
  })
}
