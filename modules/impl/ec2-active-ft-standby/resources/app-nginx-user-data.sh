#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/app-bootstrap.log) 2>&1

echo "Starting app/standby bootstrap..."

if command -v dnf >/dev/null 2>&1; then
  PKG_MGR="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MGR="yum"
else
  echo "Unsupported OS: neither dnf nor yum is available."
  exit 1
fi

$PKG_MGR install -y nginx
systemctl enable nginx
systemctl restart nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
<!doctype html>
<html>
  <head><title>Nginx Ready</title></head>
  <body>
    <h1>Nginx is running</h1>
    <p>This EC2 instance was bootstrapped by Terraform user data.</p>
  </body>
</html>
EOF

if ! $PKG_MGR install -y amazon-cloudwatch-agent 2>/dev/null; then
  echo "Package repo install failed, falling back to S3 download..."
  $PKG_MGR install -y curl
  curl -fsSL -o /tmp/amazon-cloudwatch-agent.rpm \
    https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
  rpm -Uvh /tmp/amazon-cloudwatch-agent.rpm
fi

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop || true
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c ssm:/cloudwatch-config/application

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent

echo "App/standby bootstrap completed successfully."
