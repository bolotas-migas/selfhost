# Design

## Goal
Self-hosted services on hopper (mfilipe.eu) with HTTPS, security, minimal maintenance.

## Stack
- **Reverse proxy**: Caddy (Docker) - Let's Encrypt wildcard cert via DNS-01 (Gandi plugin)
- **Security**: fail2ban on Caddy logs (401/403/404 → IP ban)
- **DDNS**: Go service updating Gandi DNS every 10min (systemd timer)
- **Storage**: ZFS RAID10 with compression/snapshots
- **Secrets**: age-encrypted tar (secrets.tar.age in repo)

## Architecture
```
Internet:443 → Router → hopper:443 → Caddy (Docker)
                                      ├→ tv.mfilipe.eu  → Jellyfin:8096 (systemd)
                                      └→ img.mfilipe.eu → Immich:2283 (docker compose)

LAN only:
  192.168.1.15:18789 → OpenClaw (systemd-nspawn, isolated network + NAT outbound)
```

## Security Layers
1. Only port 443 exposed
2. fail2ban: 10 auth failures or 20 404s → 1 day ban
3. Caddy: rate limiting, security headers
4. Services: localhost-only, proxied via Caddy

## Services
| Service | Domain | Tech | User |
|---------|--------|------|------|
| Caddy | *.mfilipe.eu | Docker | nobody:adm |
| Jellyfin | tv.mfilipe.eu | systemd | jellyfin |
| Immich | img.mfilipe.eu | Docker Compose | 1000:1000 |
| OpenClaw | LAN:18789 | systemd-nspawn | nspawn (isolated) |
| DDNS | - | systemd timer | nobody:nogroup |
| fail2ban | - | systemd | root |

## Storage Layout
```
/srv/selfhost/                  # Repo root
/srv/logs/caddy/                # JSON access logs (nobody:adm)
/media/simple/immich/           # ZFS dataset (compression=off)
/media/simple/videos/           # Jellyfin media
/media/ssd/VMs/openclaw/        # ZFS dataset (quota=10G), nspawn rootfs
```

## Secrets Management
- All env files encrypted in secrets.tar.age (in git)
- Decryption key: ~/.age-key.txt (59 bytes, not in git)
- Deploy script extracts to service dirs

## Design Decisions
- **Docker for Caddy/Immich**: Easier plugin management (Gandi DNS), isolated updates
- **Systemd for Jellyfin**: Native package, better GPU access
- **Wildcard cert**: Single Let's Encrypt cert for all subdomains
- **ZFS compression off for media**: Already compressed (photos/video)
- **ZFS compression on for DB**: Postgres benefits from zstd-fast
- **nspawn for OpenClaw**: Full persistent VM-like container on ZFS, resource-limited (1 CPU, 1.5GB RAM), isolated network with NAT outbound
