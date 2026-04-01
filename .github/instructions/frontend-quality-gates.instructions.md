---
description: "Use when running frontend pnpm quality gates, Biome, Jest, typecheck, or OpenAPI generation in this workspace or any worktree. Requires running pnpm from the active worktree's teamdev-2026-front directory on the host shell and avoiding container-based installs for quality gates."
applyTo:
  - "teamdev-2026-front/**"
  - "teamdev-2026-api/**"
  - "worktrees/**/teamdev-2026-front/**"
  - "worktrees/**/teamdev-2026-api/**"
---

# Frontend Pnpm Execution Policy

- Run frontend `pnpm` commands from the active workspace/worktree's `teamdev-2026-front/` directory in the host shell.
- Prefer `./scripts/quality-gates.sh` from the active workspace/worktree root for full validation.
- When running frontend gates directly, use the existing scripts from that frontend repo: `pnpm check`, `pnpm check:fix`, `pnpm format`, `pnpm lint:fix`, `pnpm typecheck`, `pnpm test`, and `pnpm openapi`.
- Never run frontend quality-gate commands through the frontend container (`docker compose exec front ...`, `docker exec ...front ...`).
- Never run `pnpm install`, `pnpm add`, `npm install`, or global package installs merely to satisfy quality gates.
- If the worktree is missing `node_modules` or other frontend dependencies, report the blocker and wait for user direction before changing the environment.