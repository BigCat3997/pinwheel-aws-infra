output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.id
}

output "public_ip" {
  description = "Public IPv4 address assigned to the EC2 instance"
  value       = module.ec2.public_ip
}

output "ssh_command" {
  description = "SSH command for the EC2 instance"
  value       = module.ec2.ssh_public
}

output "log_group_name" {
  description = "CloudWatch log group receiving the two collected log streams"
  value       = module.local_cloudwatch_log_groups.names["/ec2/log-simulator/app"]
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group receiving the two collected log streams"
  value       = module.local_cloudwatch_log_groups.arns["/ec2/log-simulator/app"]
}

output "simulated_log_paths" {
  description = "All 6 file paths where simulated services write logs on the instance"
  value       = var.simulated_log_paths
}

output "collected_log_paths" {
  description = "The 2 file paths the CloudWatch Agent tails and pushes to log_group_name"
  value       = var.collected_log_paths
}

output "log_archive_bucket_name" {
  description = "S3 bucket receiving the archived logs"
  value       = module.log_archive_bucket.name
}

output "log_delivery_stream_name" {
  description = "Firehose delivery stream that batches log events into S3"
  value       = module.log_delivery_stream.name
}
