#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "bootstrap complete"
