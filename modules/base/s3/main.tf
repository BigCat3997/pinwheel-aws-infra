resource "aws_s3_bucket" "this" {
  count = var.create ? 1 : 0

  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = local.s3_id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_encryption ? 1 : 0

  bucket = local.s3_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.enable_public_access ? 0 : 1

  bucket = local.s3_id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  count = var.enable_bucket_policy ? 1 : 0

  bucket = local.s3_id
  policy = local.policy
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.enable_website_configuration ? 1 : 0

  bucket = local.s3_id

  index_document {
    suffix = var.website_index_document
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.lifecycle_configuration == null ? 0 : 1

  bucket = local.s3_id

  rule {
    id     = try(var.lifecycle_configuration.id, "default")
    status = "Enabled"

    filter {
      prefix = try(var.lifecycle_configuration.prefix, "")
    }

    dynamic "expiration" {
      for_each = try(var.lifecycle_configuration.expiration_days, null) == null ? [] : [1]
      content {
        days = var.lifecycle_configuration.expiration_days
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = try(var.lifecycle_configuration.noncurrent_version_expiration_days, null) == null ? [] : [1]
      content {
        noncurrent_days = var.lifecycle_configuration.noncurrent_version_expiration_days
      }
    }

    dynamic "abort_incomplete_multipart_upload" {
      for_each = try(var.lifecycle_configuration.abort_incomplete_multipart_upload_days, null) == null ? [] : [1]
      content {
        days_after_initiation = var.lifecycle_configuration.abort_incomplete_multipart_upload_days
      }
    }
  }
}

resource "aws_s3_object" "objects" {
  for_each = var.s3_objects

  bucket              = local.s3_id
  key                 = each.key
  source              = each.value.source
  content_type        = each.value.content_type
  cache_control       = each.value.cache_control
  content_disposition = each.value.content_disposition
  etag                = filemd5(each.value.source)
}
