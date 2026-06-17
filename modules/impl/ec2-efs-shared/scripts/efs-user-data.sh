#!/bin/bash
# set -euxo pipefail

dnf update -y
sudo dnf install -y curl nfs-utils
curl https://amazon-efs-utils.aws.com/efs-utils-installer.sh | sudo sh -s -- --install
mount.efs --version

MOUNT_PATH="${mount_path}"
EFS_ID="${efs_id}"
MOUNT_OPTIONS="${mount_options}"
AP_ID="${ap_id}"

mkdir -p "$MOUNT_PATH"
sudo mount -t efs -o "$MOUNT_OPTIONS" "$EFS_ID":/ "$MOUNT_PATH"
echo "$EFS_ID:/ $MOUNT_PATH efs _netdev,$MOUNT_OPTIONS 0 0" >> /etc/fstab
df -hT "$MOUNT_PATH"