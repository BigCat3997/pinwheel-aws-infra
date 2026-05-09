locals {
  s3_id = var.create == true ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
}
