output "id" {
  description = "VPC endpoint ID"
  value       = aws_vpc_endpoint.this.id
}

output "dns_name" {
  description = "Regional DNS name of an Interface endpoint"
  value       = try(aws_vpc_endpoint.this.dns_entry[0].dns_name, null)
}

output "hosted_zone_id" {
  description = "Hosted zone ID of the Interface endpoint DNS name, used for alias records"
  value       = try(aws_vpc_endpoint.this.dns_entry[0].hosted_zone_id, null)
}
