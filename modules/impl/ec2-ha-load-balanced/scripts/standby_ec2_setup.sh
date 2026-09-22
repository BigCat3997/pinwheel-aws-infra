#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log) 2>&1

hostnamectl set-hostname bc-standby-dev-0

dnf update -y

dnf install -y nginx java-17-openjdk tomcat

systemctl enable --now nginx
systemctl enable --now tomcat