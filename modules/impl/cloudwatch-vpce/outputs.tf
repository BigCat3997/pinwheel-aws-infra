output "vpc_id" {
  description = "VPC ID"
  value       = module.local_vpc.id
}

# output "cloudwatch_logs_vpc_endpoint_id" {
#   description = "CloudWatch Logs interface VPC endpoint ID"
#   value       = aws_vpc_endpoint.logs.id
# }

output "test_ec2_private_ip" {
  description = "Private IP of the test EC2"
  value       = module.local_private_main_ec2.private_ip
}

output "test_log_group_name" {
  description = "CloudWatch log group used by the private log push test"
  value       = module.local_cloudwatch_log_group.names["vpce_test"]
}

output "verify_log_command" {
  description = "Command to verify logs were pushed through the endpoint"
  value       = format("aws logs tail %s --since 1h --region %s", module.local_cloudwatch_log_group.names["vpce_test"], var.aws_region)
}
