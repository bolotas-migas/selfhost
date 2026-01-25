#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
[ -f env ] || { echo "ERROR: ddns/env not found - run ../deploy.sh first"; exit 1; }
go build -o ddns ddns.go
sudo cp -f ddns.service ddns.timer /etc/systemd/system/
sudo chown -R nobody:adm /srv/selfhost/ddns
sudo chmod 755 ddns
sudo chmod 600 env
sudo systemctl daemon-reload
sudo systemctl enable --now ddns.timer
echo "DDNS installed and running"
