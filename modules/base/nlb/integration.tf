resource "aws_cloudwatch_log_delivery_source" "this" {
  for_each = var.enable_logging ? var.cloudwatch_log_types : toset([])

  name         = "${var.name}-${lower(replace(each.value, "_", "-"))}"
  log_type     = each.value
  resource_arn = aws_lb.this.arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "this" {
  count = var.enable_logging ? 1 : 0

  name          = "${var.name}-cloudwatch-logs"
  output_format = var.cloudwatch_log_output_format

  delivery_destination_configuration {
    destination_resource_arn = var.cloudwatch_log_group_arn
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.cloudwatch_log_group_arn != null
      error_message = "cloudwatch_log_group_arn must be set when enable_logging is true."
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  count = var.enable_logging ? 1 : 0

  policy_name = "${var.name}-nlb-log-delivery"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite20150319"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${trimsuffix(coalesce(var.cloudwatch_log_group_arn, ""), ":*")}:log-stream:*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = split(":", aws_lb.this.arn)[4]
          }
          ArnLike = {
            "aws:SourceArn" = "${join(":", slice(split(":", aws_lb.this.arn), 0, 5))}:*"
          }
        }
      },
    ]
  })
}

resource "aws_cloudwatch_log_delivery" "this" {
  for_each = aws_cloudwatch_log_delivery_source.this

  delivery_source_name     = each.value.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.this[0].arn
  tags                     = var.tags

  depends_on = [aws_cloudwatch_log_resource_policy.this]
}
