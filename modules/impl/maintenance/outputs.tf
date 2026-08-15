output "alb_dns_name" {
  description = "DNS name of the ALB entrypoint"
  value       = module.local_alb.dns_name
}

output "application_url" {
  description = "Browser URL for the application or maintenance page"
  value       = "http://${module.local_alb.dns_name}"
}

output "active_route" {
  description = "Shows which backend the ALB currently forwards to"
  value       = var.maintenance_mode ? "lambda -> s3 maintenance page" : "ec2 -> nginx target group"
}

output "web_instance_ids" {
  description = "IDs of the nginx EC2 instances behind the ALB"
  value       = { for name, instance in module.local_web_ec2 : name => instance.id }
}

output "maintenance_s3_website_endpoint" {
  description = "S3 website endpoint for the uploaded maintenance page"
  value       = module.local_maintenance_s3.website_endpoint
}

output "maintenance_toggle_hint" {
  description = "How to switch traffic from EC2 to Lambda maintenance mode"
  value       = "Set maintenance_mode = true in terraform.tfvars and run terraform apply again."
}

output "s3_interface_vpc_endpoint_id" {
  description = "Interface VPC endpoint ID used by Lambda for S3 access"
  value       = module.local_s3_interface_vpc_endpoint.id
}

output "maintenance_lambda_public_function_url" {
  description = "Public Lambda Function URL without authentication"
  value       = module.local_maintenance_lambda.function_url
}
