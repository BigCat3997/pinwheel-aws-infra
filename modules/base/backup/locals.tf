locals {
  instance_arns = [
    for instance_id in var.instance_ids :
    "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/${instance_id}"
  ]
}
