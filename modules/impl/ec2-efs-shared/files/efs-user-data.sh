#!/bin/bash
set -euxo pipefail

dnf update -y
# On your RHEL instances
sudo dnf install -y curl nfs-utils
curl https://amazon-efs-utils.aws.com/efs-utils-installer.sh | sudo sh -s -- --install

# Verify the EFS utilities are installed
mount.efs --version


# MOUNT_PATH="${mount_path}"
# EFS_ID="${efs_id}"
# MOUNT_OPTIONS="${mount_options}"
# AP_ID="${ap_id}"

# mkdir -p "$MOUNT_PATH"
# mount -t efs -o "$MOUNT_OPTIONS" "$EFS_ID":/ "$MOUNT_PATH"

# # Persist across reboots
# echo "$EFS_ID:/ $MOUNT_PATH efs _netdev,$MOUNT_OPTIONS 0 0" >> /etc/fstab
# df -hT /mnt/efs

# # Mount using the access point
# sudo mkdir -p /mnt/app-data
# sudo mount -t efs -o tls,accesspoint=$AP_ID $EFS_ID:/ /mnt/app-data

# # Verify the mount
# df -hT /mnt/app-data