locals {
  normalized_zone_name   = trimsuffix(var.zone_name, ".")
  normalized_record_name = trimspace(var.record_name)

  record_fqdn = local.normalized_record_name == "" || local.normalized_record_name == "@" ? local.normalized_zone_name : (
    endswith(trimsuffix(local.normalized_record_name, "."), local.normalized_zone_name)
    ? trimsuffix(local.normalized_record_name, ".")
    : "${trimsuffix(local.normalized_record_name, ".")}.${local.normalized_zone_name}"
  )

  selected_zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : (
    var.zone_id != null ? var.zone_id : data.aws_route53_zone.existing[0].zone_id
  )
}
