# Setup Documentation

**Status**: Production deployment active at `/srv/selfhost/` on hopper
- tv.mfilipe.eu (Jellyfin) ✅
- img.mfilipe.eu (Immich) ✅  
- HTTPS with wildcard cert ✅
- Fail2ban active ✅
- DDNS updating A/AAAA records every 10min ✅

---

## What's Running

**Caddy** (Docker):
- Location: /srv/selfhost/caddy/
- Config: Caddyfile.production
- Cert: Let's Encrypt wildcard `*.mfilipe.eu` (DNS-01 via Gandi)
- Logs: /srv/logs/caddy/ (JSON access logs, nobody:adm 2775)
- User: nobody:adm

**Jellyfin** (systemd):
- Domain: tv.mfilipe.eu
- Service: `systemctl status jellyfin`
- Logs: /var/log/jellyfin/
- Port: 8096 (localhost only, behind Caddy)

**Immich** (Docker Compose):
- Domain: img.mfilipe.eu
- Location: /srv/selfhost/immich/
- Stack: postgres, redis, ml, server
- Data: ZFS datasets at /media/simple/immich/
- External library: /media/simple/ → /mnt/simple/
- Transcoding: CPU fallback (VAAPI doesn't work in container)

**DDNS** (systemd timer):
- Location: /srv/selfhost/ddns/
- Service: ddns.service (runs via ddns.timer every 10min)
- Updates: Both A (IPv4) and AAAA (IPv6) for tv/img subdomains
- User: nobody:nogroup

**Fail2ban** (systemd):
- Location: /srv/selfhost/fail2ban/ (symlinked to /etc/fail2ban/)
- Jails: caddy-auth (10 tries), caddy-404 (20 tries, excludes Immich thumbnails)
- Logs: /var/log/fail2ban.log
- Ban duration: 1 day

---

## DNS Configuration

```
tv.mfilipe.eu   A     93.108.195.82
tv.mfilipe.eu   AAAA  2001:818:e3da:f300:63f8:2c40:e3df:65c1
img.mfilipe.eu  A     93.108.195.82
img.mfilipe.eu  AAAA  2001:818:e3da:f300:63f8:2c40:e3df:65c1
```

Managed via Gandi API:
- Initial setup: `./configure-dns.sh`
- Auto-update: DDNS service (systemd timer, every 10min)

---

## Directory Structure

**On Server (hopper)**:
```
/srv/
├── selfhost/           # Production services
│   ├── caddy/
│   │   ├── Caddyfile.production
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   └── env         # Decrypted by deploy.sh (NOT in git)
│   ├── ddns/
│   │   ├── ddns.go, ddns.service, ddns.timer
│   │   └── env         # Decrypted by deploy.sh (NOT in git)
│   ├── fail2ban/       # Symlinked to /etc/fail2ban/
│   │   ├── filter.d/   # caddy-auth.conf, caddy-404.conf
│   │   └── jail.d/     # caddy.local
│   ├── immich/
│   │   ├── docker-compose.yml
│   │   ├── hwaccel.transcoding.yml
│   │   └── env         # Decrypted by deploy.sh (NOT in git)
│   ├── secrets.tar.age # Encrypted env files (in git)
│   └── deploy.sh       # Decrypts secrets
├── logs/
│   └── caddy/          # HTTP access logs (nobody:adm 2775)
└── configs/
    └── jellyfin -> /etc/jellyfin
```

**Development (local)**:
- `~/play/selfhost/` - Git repo (github.com/msf/selfhost)
- `~/.age-key.txt` - Age encryption key (59 bytes, backup needed)

---

## Secrets

**Encrypted**: `secrets.tar.age` (in git, encrypted with age)
**Key**: `~/.age-key.txt` (59 bytes, NOT in git, needs backup)

**Decrypt and deploy**:
```bash
cd /srv/selfhost
./deploy.sh  # Extracts env files to each service dir
```

**Encrypt secrets** (after editing env files):
```bash
./encrypt-secrets.sh  # Creates secrets.tar.age from env files
git add secrets.tar.age && git commit -m "update secrets"
```

**Encrypted files**:
- `caddy/env` - Gandi API token, timezone
- `ddns/env` - Gandi API token, subdomains
- `immich/env` - DB passwords, upload location

---

## Deployment

**Initial deploy** (✅ COMPLETED):
```bash
# On hopper
sudo mv /srv/selfhost /srv/selfhost.old
git clone git@github.com:msf/selfhost.git /srv/selfhost
cd /srv/selfhost
./deploy.sh  # Decrypt secrets
# Start services (see below)
```

**Update config**:
```bash
# On local dev machine
cd ~/play/selfhost
# Edit files, test locally
git add . && git commit -m "description" && git push

# On hopper
cd /srv/selfhost
git pull
./deploy.sh  # If secrets changed
# Restart affected services
```

**Service-specific restarts**:
- Caddy: `cd /srv/selfhost/caddy && docker compose restart`
- DDNS: `sudo systemctl restart ddns.service`
- Fail2ban: `sudo systemctl restart fail2ban`
- Immich: `cd /srv/selfhost/immich && docker compose restart`

---

## Caddy Config Structure

```caddyfile
*.mfilipe.eu {
    tls {
        dns gandi {env.GANDI_API_TOKEN}  # Wildcard cert via DNS-01
    }
    
    @tv host tv.mfilipe.eu
    handle @tv {
        reverse_proxy localhost:8096  # Jellyfin
        log {
            output file /logs/access.log
            format json
        }
    }
    
    @img host img.mfilipe.eu
    handle @img {
        reverse_proxy localhost:2283  # Immich
        log {
            output file /logs/access.log
            format json
        }
    }
}
```

---

## Troubleshooting

**Cert issues**:
```bash
# Check cert
echo | openssl s_client -connect tv.mfilipe.eu:443 | openssl x509 -noout -dates

# Caddy logs
docker logs caddy | grep -i certificate
```

**DNS issues**:
```bash
dig tv.mfilipe.eu
```

**Service not accessible**:
```bash
# Check Caddy
docker ps | grep caddy
docker logs caddy --tail 20

# Check Jellyfin
systemctl status jellyfin
ss -tlnp | grep 8096
```
