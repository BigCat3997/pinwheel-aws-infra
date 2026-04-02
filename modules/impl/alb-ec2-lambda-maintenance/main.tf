locals {
  common_tags = merge(
    {
      Project      = var.name_prefix
      Managed_By   = "terraform"
      Architecture = "alb-ec2-lambda-maintenance"
    },
    var.tags,
  )
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

data "archive_file" "maintenance_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/maintenance_handler.py"
  output_path = "${path.module}/lambda/maintenance_handler.zip"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = {
    for subnet in var.public_subnets : subnet.name => subnet
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow internet traffic to the ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from internet"
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow ALB to reach nginx on the EC2 instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = var.instance_port
    to_port         = var.instance_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Optional SSH for admin access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

resource "aws_instance" "web" {
  for_each = aws_subnet.public

  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = each.value.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = var.key_pair_name
  user_data                   = templatefile("${path.module}/templates/nginx_user_data.sh.tftpl", { instance_name = each.key })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${each.key}-nginx"
    Role = "nginx"
  })
}

resource "aws_lb" "this" {
  name               = substr("${var.name_prefix}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "web" {
  name        = substr("${var.name_prefix}-web-tg", 0, 32)
  port        = var.instance_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-web-tg"
  })
}

resource "aws_lb_target_group_attachment" "web" {
  for_each = aws_instance.web

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = each.value.id
  port             = var.instance_port
}

resource "aws_s3_bucket" "maintenance" {
  bucket        = var.s3_bucket_name
  force_destroy = var.force_destroy_bucket

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-maintenance-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "maintenance" {
  bucket = aws_s3_bucket.maintenance.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "maintenance" {
  bucket = aws_s3_bucket.maintenance.id

  index_document {
    suffix = var.maintenance_object_key
  }
}

resource "aws_s3_bucket_policy" "maintenance" {
  bucket = aws_s3_bucket.maintenance.id
  policy = templatefile("${path.module}/iam/maintenance-bucket-public-read-policy.json.tftpl", {
    maintenance_bucket_arn = aws_s3_bucket.maintenance.arn
  })

  depends_on = [aws_s3_bucket_public_access_block.maintenance]
}

resource "aws_s3_object" "maintenance_page" {
  bucket              = aws_s3_bucket.maintenance.id
  key                 = var.maintenance_object_key
  source              = "${path.module}/maintenance-site/index.html"
  content_type        = "text/html; charset=utf-8"
  content_disposition = "inline"
  cache_control       = "no-store, no-cache, must-revalidate"
  etag                = filemd5("${path.module}/maintenance-site/index.html")
}

module "local_lambda_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.name_prefix}-lambda-role"
  path                    = "/"
  assume_role_policy      = ""
  assume_role_policy_file = "${path.module}/iam/lambda-assume-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policies = {
    "${var.name_prefix}-lambda-s3-read" = templatefile("${path.module}/iam/lambda-s3-read-policy.json.tftpl", {
      maintenance_bucket_arn = aws_s3_bucket.maintenance.arn
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-lambda-role"
  })
}

resource "aws_lambda_function" "maintenance" {
  function_name    = "${var.name_prefix}-maintenance"
  role             = module.local_lambda_iam_role.role_arn
  runtime          = "python3.12"
  handler          = "maintenance_handler.lambda_handler"
  filename         = data.archive_file.maintenance_lambda.output_path
  source_code_hash = data.archive_file.maintenance_lambda.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.maintenance.bucket
      OBJECT_KEY  = var.maintenance_object_key
    }
  }

  depends_on = [
    module.local_lambda_iam_role,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-maintenance"
  })
}

resource "aws_lb_target_group" "maintenance" {
  name        = substr("${var.name_prefix}-maint-tg", 0, 32)
  target_type = "lambda"

  lambda_multi_value_headers_enabled = false

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-maint-tg"
  })
}

resource "aws_lambda_permission" "allow_alb_invoke" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.maintenance.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.maintenance.arn
}

resource "aws_lb_target_group_attachment" "maintenance" {
  target_group_arn = aws_lb_target_group.maintenance.arn
  target_id        = aws_lambda_function.maintenance.arn

  depends_on = [aws_lambda_permission.allow_alb_invoke]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.maintenance_mode ? aws_lb_target_group.maintenance.arn : aws_lb_target_group.web.arn
  }
}
