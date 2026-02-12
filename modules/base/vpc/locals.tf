locals {
  public_rt_subnet_associations = flatten([
    for rt in var.public_route_tables : [
      for sn in rt.subnet_names : {
        key     = "${rt.name}-${sn}"
        rt_name = rt.name
        sn_name = sn
      }
    ]
  ])

  rt_subnet_associations = flatten([
    for rt in var.private_route_tables : [
      for sn in rt.subnet_names : {
        key     = "${rt.name}-${sn}"
        rt_name = rt.name
        sn_name = sn
      }
    ]
  ])
}
