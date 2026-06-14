locals {
  dlm_volume_arns = [
    for v in data.aws_ebs_volume.dlm_targets : v.arn
  ]
}
