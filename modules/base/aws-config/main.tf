resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = var.role_arn

  recording_group {
    all_supported                 = var.all_supported
    include_global_resource_types = var.all_supported ? var.include_global_resource_types : false
    resource_types                = var.all_supported ? null : var.resource_types
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = var.name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = var.sns_topic_arn

  dynamic "snapshot_delivery_properties" {
    for_each = var.snapshot_delivery_frequency == null ? [] : [1]
    content {
      delivery_frequency = var.snapshot_delivery_frequency
    }
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = var.enabled

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "this" {
  for_each = var.managed_rules

  name             = each.key
  description      = each.value.description
  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  dynamic "scope" {
    for_each = length(each.value.resource_types) > 0 ? [1] : []
    content {
      compliance_resource_types = each.value.resource_types
    }
  }

  tags = merge(var.tags, { Name = each.key })

  depends_on = [aws_config_configuration_recorder_status.this]
}

resource "aws_lambda_permission" "custom_rule" {
  for_each = var.custom_rules

  statement_id   = "AllowConfigInvoke-${each.key}"
  action         = "lambda:InvokeFunction"
  function_name  = each.value.lambda_name
  principal      = "config.amazonaws.com"
  source_account = var.account_id
}

resource "aws_config_config_rule" "custom" {
  for_each = var.custom_rules

  name        = each.key
  description = each.value.description

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = each.value.lambda_arn

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    source_detail {
      message_type = "OversizedConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = each.value.resource_types
  }

  tags = merge(var.tags, { Name = each.key })

  depends_on = [
    aws_config_configuration_recorder_status.this,
    aws_lambda_permission.custom_rule,
  ]
}
