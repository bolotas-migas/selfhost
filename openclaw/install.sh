#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

MACHINE=openclaw
NSPAWN_DIR=/etc/systemd/nspawn
SERVICE="systemd-nspawn@${MACHINE}.service"

[ -d /var/lib/machines/$MACHINE ] || { echo "ERROR: /var/lib/machines/$MACHINE not found (debootstrap first)"; exit 1; }

# Install nspawn unit
install -Dm644 openclaw.nspawn "$NSPAWN_DIR/$MACHINE.nspawn"

# Resource limits (1 CPU, 1.5GB RAM, 128 tasks)
mkdir -p /etc/systemd/system/${SERVICE}.d
cat > /etc/systemd/system/${SERVICE}.d/limits.conf <<'UNIT'
[Service]
CPUQuota=100%
MemoryMax=1536M
TasksMax=128
UNIT

systemctl daemon-reload

# Enable at boot
machinectl enable $MACHINE

echo "Installed: $NSPAWN_DIR/$MACHINE.nspawn + resource limits"
echo "Start: machinectl start $MACHINE"
echo "Shell: machinectl shell $MACHINE"
