output "eip_ids" {
  description = "Map of EIP names to their IDs"
  value = { for k, v in aws_eip.nat : k => v.id }
}
