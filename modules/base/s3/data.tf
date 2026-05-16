data "aws_s3_bucket" "this" {
  count  = var.create ? 0 : 1
  bucket = var.bucket_name
}
