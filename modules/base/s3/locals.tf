locals {
  s3_id  = var.create == true ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
  policy = var.policy != null ? var.policy : (var.policy_file != null ? file(var.policy_file) : null)
}
