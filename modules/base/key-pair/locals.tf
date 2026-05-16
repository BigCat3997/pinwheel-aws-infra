locals {
  create_tls_private_key = var.public_key == null && var.public_key_path == null
}
