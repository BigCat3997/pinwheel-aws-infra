output "ssh" {
  value = module.local_bastion_ec2.ssh_public
}

output "ssh_bastion" {
  description = "SSH command to bastion host"
  value       = module.local_bastion_ec2.ssh_public
}

output "ssh_app_from_bastion" {
  description = "SSH command to app EC2 from bastion host"
  value       = "ssh ${var.app_ec2_ssh_user}@${module.local_app_ec2.private_ip}"
}

output "ssh_app_standby_from_bastion" {
  description = "SSH command to standby app EC2 from bastion host"
  value       = "ssh ${var.app_standby_ec2_ssh_user}@${module.local_app_standby_ec2.private_ip}"
}

output "ssh_app_via_bastion" {
  description = "SSH command to app EC2 using local ProxyJump through bastion"
  value       = "ssh -J ${var.bastion_ssh_user}@${module.local_bastion_ec2.public_ip} ${var.app_ec2_ssh_user}@${module.local_app_ec2.private_ip}"
}

output "ssh_app_standby_via_bastion" {
  description = "SSH command to standby app EC2 using local ProxyJump through bastion"
  value       = "ssh -J ${var.bastion_ssh_user}@${module.local_bastion_ec2.public_ip} ${var.app_standby_ec2_ssh_user}@${module.local_app_standby_ec2.private_ip}"
}

output "s3_bucket_id" {
  value = module.local_app_s3.id
}

output "s3_bucket_arn" {
  value = module.local_app_s3.arn
}

output "efs_primary_id" {
  value = module.local_app_efs_primary.id
}

output "efs_standby_id" {
  value = module.local_app_efs_standby.id
}

output "ec2_iam_role_name" {
  description = "IAM role name for EC2 instances"
  value       = module.local_ec2_cloudwatch_agent_iam_role.role_name
}

output "cloudwatch_agent_config_param" {
  description = "SSM Parameter Store path for CloudWatch agent configuration"
  value       = module.local_cloudwatch_config_ssm.name
}

output "backup_vault_name" {
  description = "AWS Backup vault name"
  value       = module.local_ec2_backup.vault_name
}

output "backup_plan_id" {
  description = "AWS Backup plan ID"
  value       = module.local_ec2_backup.plan_id
}

output "backup_selection_id" {
  description = "AWS Backup selection ID"
  value       = module.local_ec2_backup.selection_id
}

output "nlb_dns_name" {
  value = module.local_nlb.nlb_dns_name
}


# output "cloudwatch_app_log_group" {
#   description = "CloudWatch log group for application logs"
#   value       = aws_cloudwatch_log_group.app_logs.name
# }

# output "cloudwatch_system_log_group" {
#   description = "CloudWatch log group for system logs"
#   value       = aws_cloudwatch_log_group.system_logs.name
# }

# output "cloudwatch_logs_archive_firehose_arn" {
#   description = "Kinesis Firehose ARN for CloudWatch Logs to S3 archival"
#   value       = try(module.local_cloudwatch_logs_firehose[0].arn, null)
# }

output "cloudwatch_logs_archive_bucket_name" {
  description = "Dedicated S3 bucket storing CloudWatch logs permanently"
  value       = module.local_cloudwatch_logs_s3.name
}

output "cloudwatch_logs_archive_lambda_name" {
  description = "Lambda function persisting CloudWatch logs into S3"
  value       = module.local_cloudwatch_logs_archive_lambda.name
}

output "cloudwatch_logs_archive_lambda_arn" {
  description = "ARN of the CloudWatch log archive Lambda function"
  value       = module.local_cloudwatch_logs_archive_lambda.arn
}

output "cloudwatch_logs_archive_s3_vpc_endpoint_id" {
  description = "S3 gateway VPC endpoint used by the archive Lambda"
  value       = aws_vpc_endpoint.cloudwatch_logs_archive_s3.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.local_alb.dns_name
}

output "route53_record_fqdn" {
  description = "FQDN of the Route 53 A record created for the application endpoint"
  value       = try(module.local_route53_record[0].record_fqdn, null)
}

output "route53_zone_id" {
  description = "Hosted zone ID used for the Route 53 application record"
  value       = try(module.local_route53_record[0].zone_id, null)
}
