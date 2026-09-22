#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1

hostnamectl set-hostname bc-bastion-dev-0

cat >/etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg <<'EOF'
  preserve_hostname: true
EOF

dnf update -y
dnf install -y java-21-openjdk