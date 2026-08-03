# Agent Guide

Guidance for AI agents and developers working in this repo. Read this first; it covers the
architecture, workflow, and gotchas that commonly trip up automated edits.

## Repo state

- Droplet: 165.227.12.213 (SSH alias `my-droplet`, user root).
- Internal Docker network: 172.22.0.0/24. Every service gets a **static IP** — never DHCP.
- **Caddy** (172.22.0.11) reverse-proxies all services with TLS issued by **step-ca** (172.22.0.50).
- **AdGuard** (172.22.0.53) does DNS rewrites `*.zharkaron.lab` -> 172.22.0.11.
- This repo is the source of truth. The droplet mirrors it via git; treat droplet-local edits
  as transient unless you made them.

## Source of truth files

- `docker-compose.yml` — every container, network, static IP, port, env var.
- `caddy/Caddyfile` — routing + TLS. There is currently **no** Caddy-level basic auth; each app
  handles its own authentication.
- `adguard/conf/AdGuardHome.yaml` — DNS config; every published subdomain needs a rewrite entry.
- `step-ca/` — private CA (certs/secrets are gitignored).
- `.github/workflows/deploy.yml` — auto-deploy on push to main.

## Deploy workflow

- Pushing to `main` triggers GitHub Actions (`deploy.yml`): SSH to droplet, `git pull origin main`,
  `docker compose up -d --remove-orphans`.
- Because of that, config changes merged to `main` take effect automatically. You normally do NOT
  need to touch the droplet for repo changes.
- Manual-only operations (database resets, first-run user creation, ID3 tag edits, force rescans)
  still need SSH: `ssh my-droplet`.

## Adding or modifying a service

Follow `SERVICE_TEMPLATE.md`. Three files always change for a new service:

1. `docker-compose.yml` — add the container with a free static IP on 172.22.0.0/24 (see table below).
2. `caddy/Caddyfile` — `import tls` + `reverse_proxy <name>:<port>`.
3. `adguard/conf/AdGuardHome.yaml` — add rewrite `<sub>.zharkaron.lab` -> 172.22.0.11.

Validate before committing:

- `docker compose config -q` (validates docker-compose.yml; needs the docker CLI).
- `caddy validate --config caddy/Caddyfile` (needs the caddy binary).
- YAML sanity check on `adguard/conf/AdGuardHome.yaml`.

## Gotchas

- **SELinux**: bind mounts need a `:Z` (or `:z`) suffix or containers cannot read them. Every
  volume in docker-compose.yml has one — keep it when adding volumes.
- **Navidrome** mounts the music library `:ro`. It scans hourly and on restart. Force a rescan
  with `docker restart navidrome`.
- **Static IPs** must be unique on 172.22.0.0/24 (see allocation table).
- **Authelia was removed.** Do not add Authelia containers or `authelia.zharkaron.lab` routing.
- **Ports**: Caddy binds host `127.0.0.1:80`; wg-easy publishes `51820/udp`. Only those leave the
  internal network.
- **watchtower** auto-updates images every 5 minutes; config changes still need a redeploy.
- **Secrets**: do not commit API keys/passwords to tracked files. Data dirs like `nextcloud/data/`,
  `homarr/config/`, `step-ca/secrets/` are gitignored — leave them alone.
- **LibreChat** config lives in `librechat/config/librechat.yaml`; env secrets (`JWT_*`, `CRED_*`)
  are in docker-compose.yml. Registration is enabled; the first user becomes admin.

## Service and IP allocation

| Service | IP | Port | Subdomain |
|---|---|---|---|
| navidrome | 172.22.0.10 | 4533 | music.zharkaron.lab |
| caddy | 172.22.0.11 | 80 | (all *.zharkaron.lab) |
| nextcloud | 172.22.0.12 | 80 | cloud.zharkaron.lab |
| beszel | 172.22.0.20 | 8090 | beszel.zharkaron.lab |
| beszel-agent | 172.22.0.21 | 45876 | (internal only) |
| dockge | 172.22.0.22 | 5001 | dockge.zharkaron.lab |
| homarr | 172.22.0.30 | 7575 | homepage.zharkaron.lab |
| mealie | 172.22.0.31 | 9000 | mealie.zharkaron.lab |
| librechat | 172.22.0.40 | 3080 | librechat.zharkaron.lab |
| librechat-mongo | 172.22.0.41 | 27017 | (internal only) |
| step-ca | 172.22.0.50 | 9000 | (internal only) |
| adguard | 172.22.0.53 | 80 | adguard.zharkaron.lab |
| wg-easy | (published) | 51820/udp | wireguard.zharkaron.lab |
| watchtower | (no IP) | - | (internal only) |
| wger-web | 172.22.0.100 | 8000 | workout.zharkaron.lab |
| wger-db | 172.22.0.101 | 5432 | (internal only) |
| wger-cache | 172.22.0.102 | 6379 | (internal only) |
| wger-nginx | 172.22.0.103 | 80 | (internal only) |

## Homarr

Homarr (`homepage.zharkaron.lab`) manages its own users, groups, and permissions inside the app.
There is no shared SSO across services.
