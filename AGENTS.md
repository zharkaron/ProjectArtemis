
## Homarr + Authelia OIDC

- Homarr replaced two Homepage instances (PR #57).
- Single Homarr container at 172.22.0.30, proxied via Caddy on both `homepage.zharkaron.lab` and `friends.zharkaron.lab`.
- Uses OIDC with Authelia v4.39. Requires `AUTH_OIDC_FORCE_USERINFO=true` (Authelia v4.39 workaround).
- `extra_hosts` resolves `authelia.zharkaron.lab` → Caddy (172.22.0.11) for server-side OIDC calls.
- `NODE_EXTRA_CA_CERTS=/certs/ca.pem` mounts the CA cert so Homarr's Node.js trusts the wildcard cert.
- Access control: homepage/friends require `one_factor` (before the wildcard VPN bypass rule).
- First OIDC login creates admin user. Create groups (e.g. "friends") in Homarr UI, assign permissions per group.
