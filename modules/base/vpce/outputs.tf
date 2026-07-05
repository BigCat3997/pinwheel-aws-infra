output "id" {
  description = "VPC endpoint ID"
  value       = aws_vpc_endpoint.this.id
}

output "arn" {
  description = "VPC endpoint ARN"
  value       = aws_vpc_endpoint.this.arn
}

output "state" {
  description = "VPC endpoint state"
  value       = aws_vpc_endpoint.this.state
}

output "network_interface_ids" {
  description = "Network interface IDs associated with this endpoint"
  value       = aws_vpc_endpoint.this.network_interface_ids
}
