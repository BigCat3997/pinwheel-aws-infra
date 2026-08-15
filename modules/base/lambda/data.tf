data "archive_file" "lambda_zip" {
  type        = var.compression_type
  source_file = var.source_dir == null ? var.source_file : null
  source_dir  = var.source_dir
  output_path = var.output_path
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_role" "lambda" {
  count = var.create_role ? 0 : (var.role_name != null ? 1 : 0)

  name = var.role_name
}
