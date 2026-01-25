# Self-Hosted Infrastructure Plan

**Domain**: mfilipe.eu (Gandi)  
**Server**: hopper (192.168.x.x, Ryzen 5 8500G, ZFS RAID10)  
**Goal**: Self-hosted services with HTTPS, security, easy deployment

---

## What's Working

✅ **Jellyfin** - tv.mfilipe.eu  
✅ **Immich** - img.mfilipe.eu (photos, hardware transcoding)  
✅ **DDNS** - Custom Go service (updates DNS every 10min)  
✅ **Fail2ban** - IP banning for 401/403/404 abuse  
✅ **Caddy** - Reverse proxy with wildcard *.mfilipe.eu cert  

---

## Architecture

```
Internet (Port 443 only)
  ↓
Router → hopper:443
  ↓
Caddy (Docker) - Let's Encrypt DNS-01
  ├→ tv.mfilipe.eu  → Jellyfin :8096 (systemd)
  ├→ img.mfilipe.eu → Immich :2283 (Docker stack)
  └→ *.mfilipe.eu   → Future services
```

**Security Layers**:
1. Fail2ban - Bans IPs (401/403: 10 tries, 404: 20 tries → 1 day ban)
2. Caddy - Security headers, rate limiting headers
3. ZFS - Compression, snapshots, RAID10

---

## Services

| Service | Domain | Tech | Status |
|---------|--------|------|--------|
| Jellyfin | tv.mfilipe.eu | systemd | ✅ Running |
| Immich | img.mfilipe.eu | Docker | ✅ Running |
| DDNS | - | systemd timer | ✅ Running |
| Fail2ban | - | systemd | ✅ Running |
| Caddy | *.mfilipe.eu | Docker | ✅ Running |
| Grafana | metrics.mfilipe.eu | systemd | 🔒 Internal only |

---

## Storage (ZFS)

```
simple/immich          → /media/simple/immich (compression=off)
simple/immich/postgres → /media/simple/immich/postgres (compression=zstd-fast)
simple/videos          → /media/simple/videos (compression=off)
simple/backups         → /media/simple/backups (compression=zstd)
```

---

## Secret Management

**Encrypted with Age** (`~/.age-key.txt`):
- `secrets.tar.age` - Contains all `env` files
- Decrypt: `./deploy.sh`
- Encrypt: `./encrypt-secrets.sh`

**Files encrypted**:
- `caddy/env` - Gandi API token
- `ddns/env` - Gandi API token  
- `immich/env` - DB password

---

## TODO

- [ ] Caddy metrics → VictoriaMetrics
- [ ] Immich hardware transcoding (VAAPI doesn't work in container, CPU fallback acceptable)
- [ ] Consider migrating Caddy from Docker to native binary (xcaddy with Gandi plugin)
- [ ] Deploy repo from local dev to `/srv/selfhost/` on hopper
- [ ] Setup wife's Immich account + partner sharing
- [ ] Expose Grafana (VPN-only or OAuth)
