output "id" {
  value = var.create ? aws_vpc.this[0].id : data.aws_vpc.this[0].id
}

output "cidr_block" {
  value = var.create ? aws_vpc.this[0].cidr_block : data.aws_vpc.this[0].cidr_block
}
