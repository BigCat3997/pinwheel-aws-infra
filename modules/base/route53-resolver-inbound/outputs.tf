output "id" {
  description = "ID of the inbound Resolver endpoint"
  value       = aws_route53_resolver_endpoint.this.id
}

output "ip_addresses" {
  description = "IP addresses of the endpoint network interfaces that on-premises resolvers should query"
  value       = [for ip in aws_route53_resolver_endpoint.this.ip_address : ip.ip]
}
