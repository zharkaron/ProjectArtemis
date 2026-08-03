---
name: work-issue
description: Implements a GitHub issue for the ProjectArtemis repo (zharkaron/ProjectArtemis). Use when the user asks to work on, implement, close out, or fix an issue (by number, link, or title). Reads the issue and the repo infrastructure, makes the change on a branch, validates it, and updates the project docs (AGENTS.md, SERVICE_TEMPLATE.md, README.md, docs/) so they stay in sync with the new state.
---

# ROLE

You are the ProjectArtemis Implementation Engineer. Implement the requested issue, follow repo
conventions, and leave the project documentation in sync with what changed.

# STEP 1 - LOAD CONTEXT

Read the issue:

- If given a number or link: `gh issue view <number>` and use the body (it is written to be
  self-contained by `create-issue`).
- If described in conversation, treat the description as the issue.

Then read the repo infrastructure needed to understand and change it:

- `AGENTS.md` (always) — architecture, IP table, gotchas, workflow
- `SERVICE_TEMPLATE.md` (for service changes)
- `docker-compose.yml`, `caddy/Caddyfile`, `adguard/conf/AdGuardHome.yaml` (for infra changes)
- `docs/architecture.md`, `docs/troubleshooting.md` (for docs changes)
- Only the service directories the issue touches.

Verify the issue has a Goal, Files to change, and Acceptance Criteria. If any are missing or
ambiguous, ask the user instead of guessing.

# STEP 2 - PLAN

State the plan briefly:

- Files to modify
- Files to create
- Validation commands to run

Then create the branch: `git checkout -b <fix|feat|docs>/<slug>` off `main`.

# STEP 3 - IMPLEMENT

Follow repo conventions (also listed in `AGENTS.md`):

- **New service**: add to `docker-compose.yml` with a UNIQUE static IP on 172.22.0.0/24 (check the
  IP table in `AGENTS.md` / `SERVICE_TEMPLATE.md` for the next free one), add a Caddy route
  (`import tls` + `reverse_proxy <name>:<port>`), and an AdGuard rewrite
  (`<sub>.zharkaron.lab` -> 172.22.0.11).
- **SELinux**: bind mounts need `:z` (shared volume / docker socket) or `:Z` (private). Never drop
  the suffix. Remember the music library and docker socket are shared — use `:z` there.
- **No Authelia.**
- **Do not commit secrets.** Keep API keys/passwords out of tracked files.
- Smallest change that satisfies the issue. No scope creep.

# STEP 4 - VALIDATE

Run the relevant checks before committing:

- `docker compose config -q` (validates docker-compose.yml)
- `caddy validate --config caddy/Caddyfile` (if the Caddyfile changed; needs the caddy binary)
- YAML sanity check on `adguard/conf/AdGuardHome.yaml` if changed
- Confirm no duplicate static IPs on 172.22.0.0/24

# STEP 5 - UPDATE PROJECT DOCS (MANDATORY)

After implementing, keep the repo documentation in sync with the new state:

- If a service, container, or IP was added/removed: update the service/IP table in `AGENTS.md` and
  `SERVICE_TEMPLATE.md`, and the service table in `README.md`.
- If routes or DNS rewrites changed: verify `docs/architecture.md` still matches.
- If you hit a non-obvious gotcha or fixed a recurring issue: add it to `docs/troubleshooting.md`.
- If user-facing behavior changed: reflect it in `README.md`.

This step is mandatory: the docs are the source of truth other agents rely on.

# STEP 6 - COMMIT AND OPEN PR

- Stage only intended files (never `git add .` blindly; avoid unrelated modified files).
- Conventional commit message matching repo style (`feat:` / `fix:` / `docs:` / `chore:`, concise).
- Push and open a PR to `main`: `gh pr create --base main --head <branch> --title ... --body ...`.
- Report the PR URL. Do not merge unless the user says to — merging auto-deploys to the droplet.

# STEP 7 - REVIEW

Self-review before finishing:

- Every acceptance criterion satisfied?
- Architecture preserved (static IPs, SELinux labels, Caddy/AdGuard wiring)?
- Docs updated (AGENTS.md, SERVICE_TEMPLATE.md, README.md, docs/) for the new state?
- No secrets committed, no unrelated changes, no dead code?

Fix anything that fails before finishing.

# SUMMARY

End with: what was implemented, files changed, docs updated, validation results, PR URL.
