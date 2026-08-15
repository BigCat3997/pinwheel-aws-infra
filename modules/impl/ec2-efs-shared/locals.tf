locals {
  ec2_node1_role_name = coalesce(var.ec2_node1_role_name, "${var.ec2_node1_name}-role")
  ec2_node2_role_name = coalesce(var.ec2_node2_role_name, "${var.ec2_node2_name}-role")

  ec2_node1_instance_profile_name = coalesce(var.ec2_node1_instance_profile_name, "${var.ec2_node1_name}-instance-profile")
  ec2_node2_instance_profile_name = coalesce(var.ec2_node2_instance_profile_name, "${var.ec2_node2_name}-instance-profile")

  efs_mount_options = var.efs_mount_access_point_name != null ? "tls,iam,accesspoint=${module.local_efs.access_point_ids[var.efs_mount_access_point_name]}" : "tls,iam"

  efs_user_data = templatefile("${path.module}/scripts/efs-user-data.sh", {
    mount_path    = var.efs_mount_path
    efs_id        = module.local_efs.id
    mount_options = local.efs_mount_options
    ap_id         = var.efs_mount_access_point_name != null ? module.local_efs.access_point_ids[var.efs_mount_access_point_name] : ""
  })

  efs_policy = templatefile("${path.module}/templates/efs-policy.tftpl", {
    ec2_role_arns_json = jsonencode([module.local_ec2_node1_role.role_arn, module.local_ec2_node2_role.role_arn])
    efs_resource       = module.local_efs.arn
  })
}
