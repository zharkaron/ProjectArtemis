# Architecture

ProjectArtemis runs a private homelab on a single DigitalOcean droplet. All services are Docker
containers on one internal bridge network, fronted by a single reverse proxy.

## Network topology

```
                         internet / VPN
                              |
                    +---------+---------+
                    |  Caddy 172.22.0.11 |
                    |  (TLS proxy,       |
                    |   host 127.0.0.1:80)|
                    +----+----+----+-----+
                         |    |    |
        +----------------+    |    +----------------+
        |                     |                     |
   navidrome 172.22.0.10  ... other services
   (music)
```

- Internal bridge network: `172.22.0.0/24` (defined as `internal` in docker-compose.yml).
- Every service has a **static IP** allocated from that range. The allocation table lives in
  `AGENTS.md` and `SERVICE_TEMPLATE.md` — keep it updated when adding containers.
- Containers reach each other by service name (Docker DNS) or static IP.

## TLS (step-ca + Caddy)

- **step-ca** (172.22.0.50) is a private ACME certificate authority, configured in `step-ca/`.
- **Caddy** trusts step-ca's root (`step-ca/certs/root_ca.crt`) and is pointed at
  `https://step-ca:9000/acme/acme/directory`, so it issues a `*.zharkaron.lab` cert on demand
  for each route (`import tls` snippet in the Caddyfile).
- Devices that visit `*.zharkaron.lab` must trust the step-ca root certificate or browsers will
  warn about the unknown CA. Install `root_ca.crt` on every client.

## DNS (AdGuard)

- **AdGuard** (172.22.0.53) is the resolver for the lab. It uses DoH upstreams
  (Cloudflare, Google, Quad9) and applies blocklists (AdGuard DNS filter, EasyList, EasyPrivacy,
  StevenBlack, Peter Lowe).
- DNS **rewrites** in `adguard/conf/AdGuardHome.yaml` map each `<sub>.zharkaron.lab` to
  `172.22.0.11` (Caddy), so a plain hostname reaches the right container.
- A subdomain will not resolve on the internal network until its rewrite entry exists.

## Request flow

1. Device queries the internal DNS (AdGuard).
2. AdGuard rewrites `music.zharkaron.lab` -> `172.22.0.11`.
3. The browser connects to Caddy on 172.22.0.11; Caddy terminates TLS with a step-ca cert.
4. Caddy reverse-proxies to the backend container (`navidrome:4533`, etc.).

## Deployment pipeline

`.github/workflows/deploy.yml` runs on every push to `main`:

1. GitHub Actions SSHs into the droplet (secrets: `SERVER_IP`, `SERVER_USER`, `SSH_KEY`).
2. `cd ~/ProjectArtemis && git pull origin main`.
3. `docker compose up -d --remove-orphans`.

Containers use `restart: unless-stopped`; changed definitions are recreated automatically.
Because this pipeline exists, merging to `main` deploys. There is no manual deployment step for
repo changes. The default deploy starts only essential services; profiled services (`extra`, `wger`)
must be started manually on the droplet.

## Data and persistence

- The repo tracks **config only**. Runtime data lives either in gitignored bind mounts
  (`homarr/config/`, `music/data/`, ...) or named volumes
  (`wger-postgres`, ...). See the `volumes:` blocks in docker-compose.yml.
- Backups of data dirs are out of scope of this repo; treat any `docker compose` data volume as
  the only copy.

## Ports exposed to the host

| Host port | Container | Purpose |
|---|---|---|
| `127.0.0.1:80` | caddy | Reverse proxy entry (behind the firewall) |
| `51820/udp` | wg-easy | WireGuard VPN |

Everything else stays on the internal bridge network and is only reachable via Caddy or Docker DNS.
