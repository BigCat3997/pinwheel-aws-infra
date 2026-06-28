# !/bin/bash
# set -euxo pipefail

# Log everything for debugging
exec > >(tee /var/log/user-data.log) 2>&1

dnf update -y

hostnamectl set-hostname bc-bastion-dev-0
exec bash