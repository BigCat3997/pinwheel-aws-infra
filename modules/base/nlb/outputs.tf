output "id" {
  value = aws_lb.this.id
}

output "arn" {
  value = aws_lb.this.arn
}

output "name" {
  value = aws_lb.this.name
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arns" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn }
}

output "target_group_names" {
  value = [for tg_name, tg in aws_lb_target_group.this : tg_name]
}
