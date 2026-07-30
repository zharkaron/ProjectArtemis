
## Homelab Architecture

- **Droplet:** 165.227.12.213 (SSH: `my-droplet`)
- **Internal network:** 172.22.0.0/24
- **Caddy** (172.22.0.11) reverse-proxies all services with TLS via step-ca (172.22.0.50)
- **AdGuard** (172.22.0.53) handles DNS rewrites for `*.zharkaron.lab` -> Caddy
- **Homarr** at 172.22.0.30, proxied on `homepage.zharkaron.lab` and `friends.zharkaron.lab`
- Authelia has been removed. Do not add Authelia containers or `authelia.zharkaron.lab` routing.

## Adding New Services

Follow `SERVICE_TEMPLATE.md` in the repo root. Quick steps:

1. Create `feat/<name>` branch off `main`
2. Add container to `docker-compose.yml` with a static IP on 172.22.0.0/24
3. Add Caddy route in `caddy/Caddyfile` (import tls + reverse_proxy)
4. Add DNS rewrite in AdGuard config (`adguard/conf/AdGuardHome.yaml`): `<sub>.zharkaron.lab` -> 172.22.0.11
5. Deploy: pull branch on droplet, `docker compose up -d <service>`, restart caddy/adguard
6. Merge to main when working

## Existing Services

| Service      | IP             | Port  | Subdomain                     |
|--------------|----------------|-------|-------------------------------|
| navidrome    | 172.22.0.10    | 4533  | music.zharkaron.lab           |
| caddy        | 172.22.0.11    | 80    | (all *.zharkaron.lab)         |
| nextcloud    | 172.22.0.12    | 80    | cloud.zharkaron.lab           |
| beszel       | 172.22.0.20    | 8090  | beszel.zharkaron.lab          |
| beszel-agent | 172.22.0.21    | 45876 | (internal only)               |
| dockge       | 172.22.0.22    | 5001  | dockge.zharkaron.lab          |
| homarr       | 172.22.0.30    | 7575  | homepage.zharkaron.lab        |
| mealie       | 172.22.0.31    | 9000  | mealie.zharkaron.lab          |
| librechat    | 172.22.0.40    | 3080  | librechat.zharkaron.lab       |
| librechat-mongo | 172.22.0.41 | 27017 | (internal only)               |
| step-ca      | 172.22.0.50    | 9000  | (internal only)               |
| adguard      | 172.22.0.53    | 80    | adguard.zharkaron.lab         |
| wg-easy      | (published)    | 51820 | wireguard.zharkaron.lab       |
| watchtower   | (no IP)        | -     | (internal only)               |
| wger-web     | 172.22.0.100   | 8000  | workout.zharkaron.lab         |
| wger-db      | 172.22.0.101   | 5432  | (internal only)               |
| wger-cache   | 172.22.0.102   | 6379  | (internal only)               |
| wger-nginx   | 172.22.0.103   | 80    | (internal only)               |

## Homarr + Caddy Basic Auth

- Caddy protects all published lab services with the shared `basicauth` snippet.
- Homarr authentication and group/permission setup are handled inside Homarr itself.
