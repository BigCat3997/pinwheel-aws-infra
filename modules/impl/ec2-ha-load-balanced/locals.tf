locals {
  ec2_id_by_name = {
    for name, inst in data.aws_instance.this : name => inst.id
  }

  combined_nlb_subnet_mappings = [
    for subnet_name, ip in var.nlb_subnet_configs : {
      subnet_id            = module.subnet.private_subnets[subnet_name]
      private_ipv4_address = ip
    }
  ]

  combined_nlb_target_groups = {
    for tg_name, tg in var.nlb_target_groups :
    tg_name => merge(tg, { vpc_id = module.vpc.id })
  }

  combined_nlb_attachments = [
    for att in var.nlb_attachments :
    merge(att, {
      target_id = local.ec2_id_by_name[att.target_name]
    })
  ]

  combined_alb_attachments = [
    for att in var.alb_attachments :
    merge(att, {
      target_id = local.ec2_id_by_name[att.target_name]
    })
  ]
}
