#!/bin/bash
set -e
echo "Installing CloudWatch Agent..."

sudo dnf update -y
sudo dnf upgrade -y

sudo dnf install -y wget

cd /opt
wget https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c ssm:/cloudwatch-config/application

echo "CloudWatch Agent installation completed!"