locals {
  ec2_id_by_name = { for _, ec2 in module.local_web_ec2 : ec2.name => ec2.id }

  # alb_ready_arn waits for the Lambda invoke permission, so the attachment is ordered after it.
  attachment_target_id_by_name = merge(local.ec2_id_by_name, {
    "${var.name_prefix}-maintenance" = module.local_maintenance_lambda.alb_ready_arn
  })

  # Listener rules are only active in maintenance mode.
  active_alb_listener_rules = var.maintenance_mode ? var.alb_listener_rules : {}

  combined_alb_attachments = [
    for att in var.alb_attachments :
    merge(att, {
      target_id = local.attachment_target_id_by_name[att.target_name]
    })
  ]

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
