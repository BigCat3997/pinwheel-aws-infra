resource "tls_private_key" "key" {
  count = local.create_tls_private_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = var.name
  public_key = coalesce(var.public_key, try(file(var.public_key_path), null), try(tls_private_key.key[0].public_key_openssh, null))

  tags = merge(var.tags, {
    Name = var.name
  })
}
