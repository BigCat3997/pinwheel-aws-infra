output "zone_id" {
  description = "Hosted zone ID used by the record"
  value       = local.selected_zone_id
}

output "zone_name" {
  description = "Hosted zone name"
  value       = local.normalized_zone_name
}

output "record_fqdn" {
  description = "Fully-qualified domain name for the A record"
  value       = aws_route53_record.this.fqdn
}

output "record_name" {
  description = "Route 53 record name"
  value       = aws_route53_record.this.name
}
