locals {
  common_tags = merge(
    {
      Project      = var.name_prefix
      Managed_By   = "terraform"
      Architecture = "alb-ec2-lambda-maintenance"
    },
    var.tags,
  )

  maintenance_bucket_arn = "arn:aws:s3:::${var.s3_bucket_name}"
}
