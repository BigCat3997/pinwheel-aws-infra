resource "aws_sqs_queue" "this" {
  name                       = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  sqs_managed_sse_enabled    = true

  redrive_policy = var.redrive_target_arn == null ? null : jsonencode({
    deadLetterTargetArn = var.redrive_target_arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_sqs_queue_policy" "this" {
  count = var.policy == null ? 0 : 1

  queue_url = aws_sqs_queue.this.url
  policy    = var.policy
}
