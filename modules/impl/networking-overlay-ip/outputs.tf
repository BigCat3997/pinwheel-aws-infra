output "overlay_ip" {
  description = "Overlay IPv4 address routed through the transit gateway"
  value       = var.overlay_ip
}

output "ha_route_table_id" {
  description = "HA VPC route table containing the active-node overlay route"
  value       = module.ha_route_tables.public_route_table_ids[var.ha_overlay_route_table_name]
}

output "primary_instance_id" {
  description = "Initial active EC2 instance ID"
  value       = module.primary_ec2.id
}

output "node_a_instance_id" {
  description = "Deprecated compatibility alias for primary_instance_id"
  value       = module.primary_ec2.id
}

output "primary_eni_id" {
  description = "Initial active EC2 primary network interface ID"
  value       = module.primary_ec2.primary_network_interface_id
}

output "node_a_eni_id" {
  description = "Deprecated compatibility alias for primary_eni_id"
  value       = module.primary_ec2.primary_network_interface_id
}

output "standby_instance_id" {
  description = "Initial standby EC2 instance ID"
  value       = module.standby_ec2.id
}

output "node_b_instance_id" {
  description = "Deprecated compatibility alias for standby_instance_id"
  value       = module.standby_ec2.id
}

output "standby_eni_id" {
  description = "Initial standby EC2 primary network interface ID"
  value       = module.standby_ec2.primary_network_interface_id
}

output "node_b_eni_id" {
  description = "Deprecated compatibility alias for standby_eni_id"
  value       = module.standby_ec2.primary_network_interface_id
}

output "client_instance_id" {
  description = "Test client EC2 instance ID"
  value       = module.client_ec2.id
}

output "test_from_client" {
  description = "Session Manager and curl commands used to test the overlay service"
  value       = "aws ssm start-session --target ${module.client_ec2.id}; then run: curl http://${var.overlay_ip}:${var.service_port}"
}

output "manual_failover_commands" {
  description = "Commands that move the overlay IP and route from the primary to the standby node"
  value       = <<-COMMANDS
    # 1. Add the overlay IP to the standby node:
    aws ssm send-command --instance-ids ${module.standby_ec2.id} --document-name AWS-RunShellScript --parameters 'commands=["sudo ip address replace ${local.overlay_cidr} dev lo"]'

    # 2. Move the HA VPC route to the standby node's network interface:
    aws ec2 replace-route --region ${var.aws_region} --route-table-id ${module.ha_route_tables.public_route_table_ids[var.ha_overlay_route_table_name]} --destination-cidr-block ${local.overlay_cidr} --network-interface-id ${module.standby_ec2.primary_network_interface_id}

    # 3. Remove the overlay IP from the primary node:
    aws ssm send-command --instance-ids ${module.primary_ec2.id} --document-name AWS-RunShellScript --parameters 'commands=["sudo ip address del ${local.overlay_cidr} dev lo"]'

    # 4. Re-run curl from the client; it should now report the standby node.
  COMMANDS
}
