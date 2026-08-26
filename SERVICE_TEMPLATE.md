# Adding a New Service

Use this checklist when requesting a new service. Fill in the details and I'll handle the rest.

## Service Details

```
Service Name:        (e.g. mealie, paperless, vaultwarden)
Docker Image:        (e.g. ghcr.io/mealie-recipes/mealie:latest)
Internal Port:       (e.g. 9000)
Subdomain:           (e.g. mealie.zharkaron.lab)
Description:         (what does it do?)
```

## Volumes (optional)

```
./service-name/data:/app/data:Z
```

## Environment Variables (optional)

```
KEY=value
```

## What I Do (automated)

1. **Branch** `feat/<service-name>` off `main`
2. **Add container** to `docker-compose.yml` on the `internal` network (172.22.0.0/24)
3. **Add Caddy route** in `caddy/Caddyfile` with TLS via step-ca
4. **Add DNS rewrite** in AdGuard so `<subdomain>.zharkaron.lab` -> Caddy (172.22.0.11)
5. **Deploy** to the droplet and verify it starts
6. **Commit and push** the branch
7. **Merge to main** when you say it works

## IP Allocation

| IP              | Service       |
|-----------------|---------------|
| 172.22.0.10     | navidrome     |
| 172.22.0.11     | caddy         |
| 172.22.0.20     | beszel        |
| 172.22.0.21     | beszel-agent  |
| 172.22.0.22     | dockge        |
| 172.22.0.30     | homarr        |
| 172.22.0.31     | mealie        |
| 172.22.0.50     | step-ca       |
| 172.22.0.53     | adguard       |
| 172.22.0.100    | wger-web      |
| 172.22.0.101    | wger-db       |
| 172.22.0.102    | wger-cache    |
| 172.22.0.103    | wger-nginx    |

Free ranges remain: `172.22.0.12-19`, `172.22.0.23-29`, `172.22.0.32-39`, `172.22.0.40-49`,
`172.22.0.51-52`, `172.22.0.54-99`, `172.22.0.104-254`. Pick the next free IP and update this
table when you add a service.

## Examples

**"Add paperless-ngx for document management on port 8000"**

**"Add vaultwarden for passwords, subdomain pass.zharkaron.lab"**

**"Add jellyfin for media streaming on port 8096"**
