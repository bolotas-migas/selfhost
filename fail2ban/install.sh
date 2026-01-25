#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
sudo ln -sf /srv/selfhost/fail2ban/filter.d/* /etc/fail2ban/filter.d/
sudo ln -sf /srv/selfhost/fail2ban/jail.d/* /etc/fail2ban/jail.d/
sudo systemctl restart fail2ban
echo "fail2ban configured and restarted"
