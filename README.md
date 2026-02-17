# selfhost

Self-hosted infrastructure for mfilipe.eu. See DESIGN.md for architecture.

## Services

- **caddy/** - Reverse proxy (*.mfilipe.eu)
- **immich/** - Photo management (img.mfilipe.eu)
- **monitoring/** - Metrics stack (VictoriaMetrics, Grafana, Telegraf)
- **iot/** - Home automation (Zigbee2MQTT, Mosquitto, sensors)
- **ddns/** - Dynamic DNS updater
- **fail2ban/** - Security (IP banning)
- **openclaw/** - AI assistant (LXC container) [docs need update]

## Deploy

```bash
git clone git@github.com:msf/selfhost.git /srv/selfhost
cd /srv/selfhost
./deploy.sh

# Start services
cd caddy && docker compose up -d
cd ../immich && docker compose up -d
cd ../monitoring && docker compose up -d
cd ../monitoring/telegraf && docker compose up -d
cd ../monitoring/vmagent && docker compose up -d
cd ../iot && docker compose up -d
cd ../fail2ban && ./install.sh

systemctl restart jellyfin ddns.timer
```

## Update

```bash
cd /srv/selfhost
git pull
./deploy.sh  # Extract secrets

# Restart changed services
docker compose restart  # in relevant dir
# or: systemctl restart <service>
```

## Secrets

```bash
./encrypt-secrets.sh           # Encrypt env files → secrets.tar.age
git commit secrets.tar.age -m "update secrets"
./deploy.sh                    # Decrypt secrets.tar.age → */env
```

Age key: Generate with `age-keygen -o ~/.age-key.txt` (backup this file).

## Check Status

```bash
# Docker services
docker ps
docker logs caddy immich_server victoriametrics grafana

# Systemd services
systemctl status jellyfin ddns fail2ban

# Logs
journalctl -u ddns -f
tail -f /var/log/fail2ban.log
tail -f /srv/logs/caddy/access.log
```

## fail2ban

```bash
sudo fail2ban-client status caddy-auth caddy-404
sudo fail2ban-client set caddy-auth unbanip 1.2.3.4
sudo iptables -L -n | grep DROP
tail -f /var/log/fail2ban.log
```

## Service-Specific Docs

- **monitoring/README.md** - Metrics, Grafana, VictoriaMetrics
- **iot/README.md** - Zigbee, MQTT, sensors
