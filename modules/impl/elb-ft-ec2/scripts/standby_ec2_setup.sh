#!/bin/bash
# set -euxo pipefail

exec > >(tee /var/log/user-data.log) 2>&1

dnf update -y
dnf install -y nginx

systemctl enable nginx
systemctl start nginx