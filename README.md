# ProjectArtemis

Self-hosted homelab running on a DigitalOcean droplet, managed entirely as code from this repository.

Everything (docker-compose.yml, Caddy reverse proxy, AdGuard DNS, step-ca TLS) is version-controlled.
Deploying is merging to `main`: a GitHub Action pulls the latest code on the droplet and restarts services.

## Services

| Service | IP | Port | Subdomain | Purpose |
|---|---|---|---|---|
| caddy | 172.22.0.11 | 80 | *.zharkaron.lab | Reverse proxy + TLS |
| navidrome | 172.22.0.10 | 4533 | music.zharkaron.lab | Music streaming (extra profile) |
| beszel | 172.22.0.20 | 8090 | beszel.zharkaron.lab | Server monitoring |
| beszel-agent | 172.22.0.21 | 45876 | (internal) | Beszel metrics agent |
| homarr | 172.22.0.30 | 7575 | homepage.zharkaron.lab | Dashboard |
| dockge | 172.22.0.22 | 5001 | dockge.zharkaron.lab | Docker stack manager (extra profile) |
| mealie | 172.22.0.31 | 9000 | mealie.zharkaron.lab | Recipe manager (extra profile) |
| step-ca | 172.22.0.50 | 9000 | (internal) | Private CA for TLS |
| adguard | 172.22.0.53 | 80 | adguard.zharkaron.lab | DNS + ad blocking |
| wg-easy | (published) | 51820/udp | wireguard.zharkaron.lab | WireGuard VPN |
| watchtower | (no IP) | - | (internal) | Auto-updates images (extra profile) |
| wger-web | 172.22.0.100 | 8000 | workout.zharkaron.lab | Workout tracker |
| wger-db | 172.22.0.101 | 5432 | (internal) | wger database |
| wger-cache | 172.22.0.102 | 6379 | (internal) | wger redis cache |
| wger-nginx | 172.22.0.103 | 80 | (internal) | wger web server |

## Architecture

- All services live on the internal Docker bridge network `172.22.0.0/24` with static IPs.
- **Caddy** (172.22.0.11) reverse-proxies every `*.zharkaron.lab` subdomain with TLS certificates
  issued by **step-ca** (172.22.0.50), the private certificate authority.
- **AdGuard** (172.22.0.53) resolves `*.zharkaron.lab` to Caddy (172.22.0.11) via DNS rewrites.
- The droplet is `165.227.12.213` (SSH alias: `my-droplet`).

Request flow: device -> AdGuard (DNS lookup) -> Caddy (TLS handshake) -> service container.

- **Resource profiles**: non-essential services (`navidrome`, `dockge`, `mealie`, `watchtower`) are
  behind `profiles: ["extra"]` to keep the default footprint small on the 1 vCPU / 2 GB droplet.
  Start them with `docker compose --profile extra up -d`.

See [docs/architecture.md](docs/architecture.md) for details.

## Repository layout

| Path | Purpose |
|---|---|
| `docker-compose.yml` | Every container, network, static IP, port, and env var |
| `caddy/Caddyfile` | Reverse proxy routing + TLS config |
| `adguard/conf/AdGuardHome.yaml` | DNS config and rewrites |
| `step-ca/` | Private certificate authority |
| `<service>/` | Per-service config and (gitignored) data mounts |
| `.github/workflows/deploy.yml` | CI/CD deploy on push to main |
| `AGENTS.md` | Guidance for AI agents working in this repo |
| `SERVICE_TEMPLATE.md` | Checklist for adding a new service |
| `docs/` | In-depth architecture and troubleshooting docs |

## How to make changes

1. Create a branch off `main` (e.g. `feat/<name>` or `fix/<name>`).
2. Edit the config files.
3. Commit, push, and open a pull request to `main`.
4. Merging to `main` auto-deploys: GitHub Actions SSHs into the droplet, runs
   `git pull origin main` and `docker compose up -d --remove-orphans`.

For a new service, follow [SERVICE_TEMPLATE.md](SERVICE_TEMPLATE.md).

## Documentation

- [docs/architecture.md](docs/architecture.md) — networking, TLS, DNS, deployment pipeline.
- [docs/troubleshooting.md](docs/troubleshooting.md) — common gotchas and how to fix them.
- [AGENTS.md](AGENTS.md) — guidance for AI agents and automated editors.

## Access

- SSH to the droplet: `ssh my-droplet` (see `~/.ssh/config`).
- Each app has its own login; there is no shared SSO. First-run admin users are created through
  each app's web UI.

## Notes

- The repository is the source of truth. The droplet may contain untracked runtime data or
  transient local edits; treat git as authoritative.
- Do not commit secrets. Sensitive data dirs are gitignored (see `.gitignore`).
