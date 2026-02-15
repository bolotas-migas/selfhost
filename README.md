# selfhost

Self-hosted infrastructure for mfilipe.eu. See DESIGN.md for architecture.

## Deploy
```bash
git clone git@github.com:msf/selfhost.git /srv/selfhost
cd /srv/selfhost
./deploy.sh
cd caddy && docker compose up -d
cd ../immich && docker compose up -d
cd ../openclaw && docker compose up -d
cd ../fail2ban && ./install.sh
systemctl restart jellyfin ddns.timer
```

## Update
```bash
git pull
docker compose restart  # or systemctl restart <service>
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
docker ps; systemctl status jellyfin ddns fail2ban
docker logs caddy immich_server
journalctl -u ddns -f
```

## fail2ban
```bash
sudo fail2ban-client status caddy-auth caddy-404
sudo fail2ban-client set caddy-auth unbanip 1.2.3.4
sudo iptables -L -n | grep DROP
tail -f /var/log/fail2ban.log
```
