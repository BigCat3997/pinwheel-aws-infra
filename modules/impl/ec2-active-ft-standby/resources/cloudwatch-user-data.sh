#!/bin/bash
set -euxo pipefail

# Redirect all output to a log file for debugging
exec > >(tee /var/log/cloudwatch-user-data.log) 2>&1

echo "Starting CloudWatch Agent bootstrap..."

# Install amazon-cloudwatch-agent directly from Amazon Linux repos (no internet required for AL2023)
# Falls back to S3 download if not available in repos
if ! dnf install -y amazon-cloudwatch-agent 2>/dev/null; then
  echo "dnf repo install failed, falling back to S3 download..."
  dnf install -y curl
  curl -fsSL -o /tmp/amazon-cloudwatch-agent.rpm \
    https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
  rpm -Uvh /tmp/amazon-cloudwatch-agent.rpm
fi

# Stop agent before applying new config
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop || true

# Fetch config from SSM and start agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c ssm:/cloudwatch-config/application

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent

echo "CloudWatch Agent installation completed!"