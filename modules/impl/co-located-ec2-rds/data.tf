data "aws_secretsmanager_secret" "ec2_public_key" {
  name = var.sm_ec2_ssh_public_key_name
}

data "aws_secretsmanager_secret_version" "ec2_public_key" {
  secret_id = data.aws_secretsmanager_secret.ec2_public_key.id
}

data "archive_file" "failover_lambda" {
  type        = "zip"
  source_file = "${path.module}/resources/lambda/rds_db2_failover_handler.py"
  output_path = "${path.module}/resources/lambda/rds_db2_failover_handler.zip"
}
