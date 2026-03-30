output "arn" {
  description = "ARN of the Firehose delivery stream"
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].arn : null
}

output "name" {
  description = "Name of the Firehose delivery stream"
  value       = var.create ? aws_kinesis_firehose_delivery_stream.this[0].name : null
}
