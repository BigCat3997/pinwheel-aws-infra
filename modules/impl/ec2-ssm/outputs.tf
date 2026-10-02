output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.local_ec2.id
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.local_ec2.private_ip
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.local_ec2.public_ip
}

output "ssm_endpoint_ids" {
  description = "SSM interface endpoint IDs by service"
  value       = { for service, vpce in module.local_ssm_vpce : service => vpce.id }
}

output "ssm_start_session" {
  description = "Command to open a Session Manager shell on the instance"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.local_ec2.id}"
}

output "rhel_ec2_instance_id" {
  description = "RHEL EC2 instance ID"
  value       = module.local_rhel_ec2.id
}

output "rhel_ec2_private_ip" {
  description = "RHEL EC2 private IP"
  value       = module.local_rhel_ec2.private_ip
}

output "rhel_ec2_public_ip" {
  description = "RHEL EC2 public IP"
  value       = module.local_rhel_ec2.public_ip
}

output "rhel_ssm_start_session" {
  description = "Command to open a Session Manager shell on the RHEL instance"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.local_rhel_ec2.id}"
}

output "ec2_key_pair_names" {
  description = "Key pair names per EC2"
  value = {
    ec2      = module.local_ec2_key_pair.name
    rhel_ec2 = module.local_rhel_ec2_key_pair.name
  }
}
