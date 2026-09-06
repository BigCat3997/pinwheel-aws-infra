resource "aws_lb" "this" {
  name                       = var.name
  load_balancer_type         = "application"
  internal                   = var.enable_public ? false : true
  subnets                    = tolist(var.subnet_ids)
  security_groups            = tolist(var.security_group_ids)
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}