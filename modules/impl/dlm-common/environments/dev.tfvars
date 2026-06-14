common_tags = {
  Environment = "dev"
  Project     = "dlm-common"
  Name        = "bc-dlm-vol_bastion_ec2_root_dev_0-dev-0"
  ManagedBy   = "Terraform"
  CreatedBy   = "Terraform"
}

name = "bc-dlm-ec2_volumes-dev-0"

dlm_target_volume_names = [
  "bc-vol-private_ec2_root-dev-0"
]

target_tags = {
  DLM_Managed = true
}

schedules = [
  {
    name          = "daily-snapshot"
    interval      = 24
    interval_unit = "HOURS"
    times         = ["17:00"]
    retain_count  = 14
    tags_to_add = {
      SnapshotCreatedBy = "DLM"
    }
    copy_tags = true
  }
]
