
## Homarr + Caddy Basic Auth

- Homarr replaced two Homepage instances (PR #57).
- Single Homarr container at 172.22.0.30, proxied via Caddy on both `homepage.zharkaron.lab` and `friends.zharkaron.lab`.
- Authelia has been removed. Do not add Homarr OIDC env vars, Authelia containers, or `authelia.zharkaron.lab` routing unless explicitly reintroducing Authelia.
- Caddy protects all published lab services with the shared `basicauth` snippet.
- Homarr authentication and group/permission setup are handled inside Homarr itself.
