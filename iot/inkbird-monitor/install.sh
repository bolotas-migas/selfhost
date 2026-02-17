#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

SERVICE=inkbird-monitor.service

# Check if binary exists
command -v inkbird-monitor >/dev/null || {
    echo "ERROR: inkbird-monitor binary not found in PATH"
    echo "Build from: github.com/msf/inkbird-monitor"
    exit 1
}

# Install systemd service
install -Dm644 "$SERVICE" "/etc/systemd/system/$SERVICE"

# Create config directory
mkdir -p /etc/inkbird-monitor

# Reload and enable
systemctl daemon-reload
systemctl enable "$SERVICE"

echo "Installed: /etc/systemd/system/$SERVICE"
echo "Configure: /etc/inkbird-monitor/config.yaml (see repo for example)"
echo "Start: systemctl start $SERVICE"
