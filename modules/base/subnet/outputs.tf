output "private_subnet_names" {
  description = "List of private subnet names"

  value = var.create ? keys(aws_subnet.private) : keys(data.aws_subnet.private)
}

output "public_subnet_names" {
  description = "List of public subnet names"

  value = var.create ? keys(aws_subnet.public) : keys(data.aws_subnet.public)
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"

  value = var.create ? [for subnet in aws_subnet.private : subnet.id] : [for subnet in data.aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"

  value = var.create ? [for subnet in aws_subnet.public : subnet.id] : [for subnet in data.aws_subnet.public : subnet.id]
}

output "public_subnets" {
  description = "Map of public subnet"
  value       = var.create ? { for k, v in aws_subnet.public : k => v.id } : { for k, v in data.aws_subnet.public : k => v.id }
}

output "private_subnets" {
  description = "Map of private subnet"
  value       = var.create ? { for k, v in aws_subnet.private : k => v.id } : { for k, v in data.aws_subnet.private : k => v.id }
}
