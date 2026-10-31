output "vpc_ids" {
  description = "Map of VPC name to VPC ID"
  value       = { for name, vpc in module.local_vpc : name => vpc.id }
}

output "vpc_cidr_blocks" {
  description = "Map of VPC name to CIDR block"
  value       = { for name, vpc in module.local_vpc : name => vpc.cidr_block }
}

output "public_subnets" {
  description = "Map of VPC name to public subnet name/ID map"
  value       = { for name, s in module.local_subnet : name => s.public_subnets }
}

output "private_subnets" {
  description = "Map of VPC name to private subnet name/ID map"
  value       = { for name, s in module.local_subnet : name => s.private_subnets }
}

output "internet_gateway_ids" {
  description = "Map of VPC name to internet gateway ID"
  value       = { for name, igw in module.local_internet_gateway : name => igw.id }
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = module.tgw.id
}

output "tgw_attachment_ids" {
  description = "Map of VPC name to TGW VPC attachment ID"
  value       = { for name, a in module.tgw_vpc_attachment : name => a.id }
}

output "vpc_endpoint_ids" {
  description = "Map of service to interface endpoint ID"
  value       = { for s, e in module.local_vpce : s => e.id }
}

output "ec2_instance_id" {
  description = "Test EC2 instance ID"
  value       = module.ec2.id
}

output "ssm_start_session_command" {
  description = "Command to log in to the test EC2 with Session Manager"
  value       = "aws ssm start-session --target ${module.ec2.id} --region ${data.aws_region.current.region}"
}

output "ec2_log_group_name" {
  description = "Log group receiving the EC2 memory, disk, and CPU availability"
  value       = var.ec2_log_group_name
}

output "verify_log_command" {
  description = "Command to verify the metrics arrived through the logs endpoint"
  value       = "aws logs tail ${var.ec2_log_group_name} --since 10m --region ${data.aws_region.current.region}"
}

output "egress_vpc_id" {
  description = "Centralized egress VPC ID"
  value       = module.egress_vpc.id
}

output "egress_nat_public_ip" {
  description = "Public IP all VPCs share when going out to the internet"
  value       = module.egress_eip.public_ip
}

output "egress_tgw_attachment_id" {
  description = "TGW attachment ID of the egress VPC"
  value       = module.egress_tgw_vpc_attachment.id
}
