output "alb_dns_name" {
  description = "DNS name of the ALB entrypoint"
  value       = aws_lb.this.dns_name
}

output "application_url" {
  description = "Browser URL for the application or maintenance page"
  value       = "http://${aws_lb.this.dns_name}"
}

output "active_route" {
  description = "Shows which backend the ALB currently forwards to"
  value       = var.maintenance_mode ? "lambda -> s3 maintenance page" : "ec2 -> nginx target group"
}

output "web_instance_ids" {
  description = "IDs of the nginx EC2 instances behind the ALB"
  value       = { for name, instance in aws_instance.web : name => instance.id }
}

output "maintenance_s3_website_endpoint" {
  description = "S3 website endpoint for the uploaded maintenance page"
  value       = aws_s3_bucket_website_configuration.maintenance.website_endpoint
}

output "maintenance_toggle_hint" {
  description = "How to switch traffic from EC2 to Lambda maintenance mode"
  value       = "Set maintenance_mode = true in terraform.tfvars and run terraform apply again."
}
