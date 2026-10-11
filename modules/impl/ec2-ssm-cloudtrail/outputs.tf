output "bastion_mon_ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.local_bastion_mon_ec2.id
}

output "bastion_mon_ec2_private_ip" {
  description = "EC2 private IP"
  value       = module.local_bastion_mon_ec2.private_ip
}

output "bastion_mon_ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.local_bastion_mon_ec2.public_ip
}

output "ssm_endpoint_ids" {
  description = "SSM interface endpoint IDs by service"
  value       = { for service, vpce in module.local_ssm_vpce : service => vpce.id }
}

output "ssm_start_session" {
  description = "Command to open a Session Manager shell on the instance"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.local_bastion_mon_ec2.id}"
}

output "app_mon_ec2_instance_id" {
  description = "RHEL EC2 instance ID"
  value       = module.local_app_mon_ec2.id
}

output "app_mon_ec2_private_ip" {
  description = "RHEL EC2 private IP"
  value       = module.local_app_mon_ec2.private_ip
}

output "app_mon_ec2_public_ip" {
  description = "RHEL EC2 public IP"
  value       = module.local_app_mon_ec2.public_ip
}

output "rhel_ssm_start_session" {
  description = "Command to open a Session Manager shell on the RHEL instance"
  value       = "aws ssm start-session --region ${var.aws_region} --target ${module.local_app_mon_ec2.id}"
}

output "bastion_mon_ec2_key_pair_names" {
  description = "Key pair names per EC2"
  value = {
    ec2         = module.local_bastion_mon_ec2_key_pair.name
    app_mon_ec2 = module.local_app_mon_ec2_key_pair.name
  }
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.cloudtrail.arn
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket receiving CloudTrail logs"
  value       = module.cloudtrail_bucket.name
}

output "ssm_associations" {
  description = "State Manager associations managed by this module, with the document and target tags they apply to"
  value = {
    cw_agent_setup = {
      association_id   = module.cw_agent_setup.id
      association_arn  = module.cw_agent_setup.arn
      association_name = "${var.bastion_mon_ec2_name}-cw-agent-setup"
      document_name    = module.cw_agent_document.name
      config_parameter = module.cw_agent_config.name
      targets          = [var.bastion_mon_ec2_name, var.app_mon_ec2_name]
    }
  }
}

output "sns_topic_arn" {
  description = "SNS notifications topic ARN"
  value       = module.notifications_topic.arn
}

output "sns_subscription_arns" {
  description = "SNS subscriptions (email ones read PendingConfirmation until confirmed)"
  value       = module.notifications_topic.subscription_arns
}
