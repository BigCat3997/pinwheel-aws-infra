data "aws_ebs_volume" "dlm_targets" {
  for_each = toset(var.dlm_target_volume_names)

  most_recent = true

  filter {
    name   = "tag:Name"
    values = [each.value]
  }

  filter {
    name   = "tag:DLM_Managed"
    values = ["true"]
  }
}
