# Troubleshooting and Gotchas

Common problems when editing or operating this stack, and how to fix them.

## VPN (WireGuard) feels slow or drops

The wg-easy config is usually fine; the symptom is almost always the **droplet running out of
resources**, not the tunnel. Check before touching the VPN:

- Raw path to a client is fast but tunnel pings are slow/variable:
  `ssh my-droplet` then `ping <client-endpoint>` (host) vs
  `docker exec wg-easy ping 10.8.0.x` (through the tunnel). A big gap means host-side delays.
- Confirm resource exhaustion: `uptime` (load > 1 on this 1-vCPU droplet), `free -h` (swap full),
  `docker stats --no-stream`.
- The stack is heavily oversized for a 1 vCPU / ~2GiB droplet. The real fix is resizing the
  droplet. Interim measures:
  - **wger is profiled** (`profiles: ["wger"]` in docker-compose.yml) so it is **not** started by
    the normal deploy. Start it deliberately with `docker compose --profile wger up -d`. Its
    celery worker was the top CPU consumer (concurrency is now 1, `CACHE_API_EXERCISES_CELERY_FORCE_UPDATE=False`).
  - Every service has a `mem_limit` to stop one container from thrashing swap.
  - `WG_DEFAULT_MTU=1280` is set on wg-easy as a safety net for clients on flaky/MTU-reduced
    paths. Existing client configs bake in the old MTU — re-download them in the wg-easy UI
    (or set `MTU = 1280` in the client's `[Interface]`) for it to take effect.
- A peer in `wg show` with no endpoint and no handshake never connected — delete that client in
  the wg-easy UI.

## Mount or permission errors (SELinux)

The droplet runs Fedora (or another SELinux-enabled distro). Bind mounts need a `:Z` (or `:z`)
suffix or the container cannot read the mounted directory.

- If a container suddenly can't read its data volume, check the volume line in docker-compose.yml
  still has the label suffix, then redeploy.
- Keep the suffix when adding any new bind mount.

## Container won't start (static IP conflict)

All IPs on `172.22.0.0/24` are statically assigned. Two containers with the same IP cannot both
start. If a new container fails to come up with a network error:

- Check the allocation table in `AGENTS.md` / `SERVICE_TEMPLATE.md`.
- Inspect leases: `docker network inspect internal`.

## A subdomain does not resolve

- Confirm a rewrite entry exists for it in `adguard/conf/AdGuardHome.yaml` pointing to
  `172.22.0.11`.
- Reload AdGuard after editing: `docker compose restart adguard`.
- Confirm the client actually uses the lab DNS (AdGuard at 172.22.0.53 or the VPN).

## A subdomain resolves but connection fails

- Confirm the route exists in `caddy/Caddyfile`.
- Validate the config: `docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile`
  (or `caddy validate --config caddy/Caddyfile` locally).
- Confirm the backend is running and the `reverse_proxy` target port matches the container's
  exposed port.

## Navidrome not picking up songs

- The music library is mounted `:ro` at `/music` -> `./music/library`. Add files there on the
  droplet (`ssh my-droplet`).
- Navidrome scans hourly and on restart. Force a scan: `docker restart navidrome`.
- If titles look wrong, the file has no ID3 tags; set them:
  `id3v2 -t "Title" -a "Artist" -A "Album" file.mp3`.
- A stale "Unknown Album" entry usually means the file had no album tag when scanned. Fix the
  tags, then `docker restart navidrome`. If it persists, reset the cache DB: stop navidrome,
  delete `music/data/navidrome.db*`, start it again. This clears play history and admin users —
  back up the DB first.

## watchtower surprises

watchtower updates images every 5 minutes. An updated image can change behavior or break a
service. `restart: unless-stopped` recovers most failures; pin image tags if you need stability.

## First-run admin accounts

There is no shared SSO. Each app creates its admin through its own web UI on first run:
navidrome, beszel, homarr, mealie, dockge. wg-easy uses `PASSWORD_HASH` in docker-compose.yml
(bcrypt). Generate a fresh hash with:

```
htpasswd -bnBC 12 "" 'your-password' | tr -d ':\n'
```

## Removed or disabled pieces

- **Authelia** was removed. Do not re-add it or create `authelia.zharkaron.lab` routing.
- There is currently **no** Caddy-level basic auth; each app handles authentication itself.

## Secrets hygiene

- Never commit API keys or passwords to tracked files.
- Sensitive data dirs are gitignored (`nextcloud/data/`, `homarr/config/`, `step-ca/secrets/`,
  etc.) — leave them out of commits.
- Put runtime-only secrets in untracked `.env` files or droplet-only config, not the repo.
