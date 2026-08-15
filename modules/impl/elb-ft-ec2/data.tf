data "aws_instance" "this" {
  for_each = var.ec2_lookup_names

  filter {
    name   = "tag:Name"
    values = [each.value]
  }

  depends_on = [module.primary_ec2, module.standby_ec2]
}
