locals {
  effective_access_key_count = var.access_key_count != null ? var.access_key_count : (var.create_access_key ? 1 : 0)
}
