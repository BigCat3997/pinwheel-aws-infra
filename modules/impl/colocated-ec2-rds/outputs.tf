output "rds_db_identifier" {
  description = "RDS DB instance identifier"
  value       = module.local_rds_mysql.id
}

output "rds_db_arn" {
  description = "RDS DB instance ARN"
  value       = module.local_rds_mysql.arn
}

output "rds_primary_az" {
  description = "Current primary AZ of the RDS DB instance"
  value       = module.local_rds_mysql.availability_zone
}

output "rds_db_endpoint" {
  description = "RDS DB instance endpoint"
  value       = module.local_rds_mysql.endpoint
}

output "primary_ec2_instance_id" {
  description = "Primary EC2 instance ID"
  value       = module.local_primary_ec2.id
}

output "primary_ec2_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.local_primary_ec2.ssh_private
}

output "standby_ec2_instance_id" {
  description = "Standby EC2 instance ID"
  value       = module.local_standby_ec2.id
}

output "failover_lambda_name" {
  description = "Lambda function name handling DB failover"
  value       = module.local_failover_handler_lambda.name
}

output "failover_event_rule_name" {
  description = "EventBridge rule watching RDS DB events"
  value       = aws_cloudwatch_event_rule.rds_failover.name
}
