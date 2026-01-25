#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Building ddns binary..."
go build -o ddns ddns.go

echo "Deploying to /srv/selfhost/ddns..."
sudo cp -f ddns.service /etc/systemd/system/
sudo cp -f ddns.timer /etc/systemd/system/

# Create env file if it doesn't exist
if [ ! -f /srv/selfhost/ddns/env ]; then
    echo "Create /srv/selfhost/ddns/env - EDIT THIS FILE WITH YOUR TOKEN!"
    exit 1
fi

sudo chown -R nobody:adm /srv/selfhost/ddns
sudo chmod 775 /srv/selfhost/ddns
sudo chmod 755 /srv/selfhost/ddns/ddns
sudo chmod 600 /srv/selfhost/ddns/env

echo "Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl enable ddns.timer
sudo systemctl restart ddns.timer

echo ""
echo "✓ DDNS installed and timer started"
echo ""
echo "Commands:"
echo "  sudo systemctl status ddns.timer    # Check timer status"
echo "  sudo systemctl list-timers ddns.*   # Show next run time"
echo "  sudo journalctl -u ddns -f          # Watch logs"
echo "  sudo systemctl start ddns           # Run now (manual)"
echo ""
echo "⚠ Edit /srv/selfhost/ddns/env with your Gandi API token!"
