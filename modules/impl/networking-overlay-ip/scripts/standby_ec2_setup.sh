#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

hostnamectl set-hostname ${hostname}
cat >/etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg <<'EOF'
preserve_hostname: true
EOF

mkdir -p /opt/overlay-lab
echo 'Response from STANDBY node' >/opt/overlay-lab/index.html

cat >/etc/systemd/system/overlay-lab.service <<'EOF'
[Unit]
Description=Overlay IP test HTTP server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/overlay-lab
ExecStart=/usr/bin/python3 -m http.server ${service_port} --bind 0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now overlay-lab.service
