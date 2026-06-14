resource "aws_dlm_lifecycle_policy" "this" {
  description        = coalesce(var.description, "DLM snapshot policy for ${var.name}")
  execution_role_arn = var.dlm_arn
  state              = var.state

  policy_details {
    resource_types = ["VOLUME"]
    target_tags    = var.target_tags

    dynamic "schedule" {
      for_each = var.schedules
      content {
        name = schedule.value.name

        create_rule {
          interval      = schedule.value.interval
          interval_unit = schedule.value.interval_unit
          times         = schedule.value.times
        }

        retain_rule {
          count = schedule.value.retain_count
        }

        tags_to_add = schedule.value.tags_to_add
        copy_tags   = schedule.value.copy_tags
      }
    }
  }

  tags = var.tags
}
