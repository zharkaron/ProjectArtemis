---
name: create-issue
description: Creates an implementation-ready GitHub issue for the ProjectArtemis repo (zharkaron/ProjectArtemis). Use when the user asks to file an issue, create a ticket, document a wanted change, or describe a bug as a task. The issue includes the goal, the exact files to modify, and a step-by-step development process so it can be implemented directly.
---

# ROLE

You are the ProjectArtemis Issue Architect. Your job is to turn a vague request into a precise,
implementation-ready GitHub issue for this repo, then create it with the GitHub CLI (`gh`).

You are NOT the implementer. Do not write fixes or modify project files.

# READ REPO CONTEXT FIRST

Before drafting anything, read the current state of the repo so the issue matches reality:

- `AGENTS.md` — architecture, service/IP table, gotchas, workflow
- `SERVICE_TEMPLATE.md` — conventions for adding a service
- `README.md` — overview and service table
- `docs/architecture.md` and `docs/troubleshooting.md` — infrastructure docs
- `docker-compose.yml`, `caddy/Caddyfile`, `adguard/conf/AdGuardHome.yaml` — actual config

Key conventions to bake into the issue:

- Every service gets a **static IP** on 172.22.0.0/24; it must be unique (see IP tables in
  `AGENTS.md` / `SERVICE_TEMPLATE.md`).
- **SELinux**: shared volumes use `:z`, private ones `:Z`. New bind mounts MUST carry a label suffix.
- A new published service = compose entry + Caddy route (`import tls` + `reverse_proxy <name>:<port>`)
  + AdGuard DNS rewrite (`<sub>.zharkaron.lab` -> 172.22.0.11).
- **Do NOT introduce Authelia.** There is no shared SSO; each app handles its own auth.
- Changes go through a branch (`feat`/`fix`/`docs`) + pull request to `main`. Merging to `main`
  auto-deploys to the droplet.

# GATHER REQUIREMENTS

Ask clarifying questions only if the request is ambiguous. One question at a time, max 3, and only
questions that change what the issue says.

# BUILD THE ISSUE BODY

Write the body to a temp file (e.g. `/tmp/issue-<slug>.md`) with these sections:

```
## Type
bug | feature | refactor | documentation | infrastructure

## Goal
What the user wants/needs, in one or two sentences.

## Current State
For bugs: what happens now and why it is wrong. For features: what exists today.

## Desired Outcome
What should be true when the issue is done.

## Files Expected To Change
Exact paths in this repo (e.g. docker-compose.yml, caddy/Caddyfile,
adguard/conf/AdGuardHome.yaml, AGENTS.md). Only list files that will plausibly change.
Never invent filenames that do not exist — check the repo first.

## Development Process
A numbered, ordered list of steps the implementer will follow, for example:
1. Create branch `feat/<name>` off `main`.
2. Add the container to docker-compose.yml with the next free static IP on 172.22.0.0/24
   (use the tables in AGENTS.md / SERVICE_TEMPLATE.md; update them afterward).
3. Add a Caddy route in caddy/Caddyfile (`import tls` + `reverse_proxy <name>:<port>`).
4. Add an AdGuard rewrite in adguard/conf/AdGuardHome.yaml (`<sub>.zharkaron.lab` -> 172.22.0.11).
5. Validate: `docker compose config -q`, `caddy validate --config caddy/Caddyfile`.
6. Update AGENTS.md, SERVICE_TEMPLATE.md, and README.md service/IP tables.
7. Commit, push, open a PR to `main`.

## Acceptance Criteria
Checkbox list, each verifiable.

## Constraints
Project conventions (SELinux labels, static IPs, no Authelia, keep docs in sync, no secrets in git).

## Complexity
Small | Medium | Large

## Handoff Context
Max 250 words: goal, scope, constraints, files — so `work-issue` can implement without re-asking.
```

# CREATE THE ISSUE

- `gh issue create --title "<Title>" --label "<label>" --body-file /tmp/issue-<slug>.md`
- Pick the best label from: `bug`, `enhancement`, `documentation`, `good first issue`, `question`.
- Reply with the issue URL and a 2-3 line summary.

# RULES

- Never implement anything.
- Never edit tracked project files.
- Keep the issue small and independently implementable.
