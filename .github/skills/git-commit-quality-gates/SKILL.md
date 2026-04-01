---
name: git-commit-quality-gates
description: Standard commit conventions, logical commit grouping, and required quality gates (mise + pnpm)
---

# Git Commit + Quality Gates Skill

This skill defines how AI agents should:

- Group diffs into reviewable commits
- Write concise, contextual commit messages
- Run the project’s quality gates via a single script

## Commit Policy (Conventional Commits)

### Required format

```
<type>(<scope>): <imperative summary>

(optional body)

(optional footer)
```

- **type**: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `style`
- **scope**: small, stable area name (examples: `front`, `api`, `alerts`, `auth`, `openapi`, `db`, `ci`)
- **summary**: <= ~60 chars, imperative, no period

### Examples

- `feat(alerts): add yellow alert trigger for stalled tasks`
- `fix(front): prevent duplicate submit on login`
- `refactor(api): extract progress calculation service`
- `docs(workflow): clarify openapi regen steps`

### Message content rules

- Focus on **why + what**, not implementation details.
- Prefer **user/business outcome** where relevant (PM delay prevention, alerts, progress visibility).
- Avoid vague messages (`update`, `wip`, `fix stuff`).

## Logical Commit Grouping (How to split diffs)

Create commits that are easy to review and revert.

- Keep refactors separate from behavior changes.
- Keep generated outputs (e.g., OpenAPI client/types) separate when practical.
- Don’t mix formatting-only changes with functional changes.

## Quality Gates (Must pass before committing)

Run the quality gates via the single entrypoint script from the active workspace/worktree root on the host shell:

```bash
./scripts/quality-gates.sh
```

Behavior:

- Runs workspace + frontend quality checks in the required order.
- Auto-detects OpenAPI contract changes and runs OpenAPI regeneration only when needed.

Options:

- `./scripts/quality-gates.sh --skip-mise`
- `./scripts/quality-gates.sh --skip-openapi`

### Frontend execution policy

- Run frontend `pnpm` commands from the active workspace/worktree's `teamdev-2026-front/` directory in the host shell.
- Never run frontend quality-gate commands through the frontend container (`docker compose exec front ...`, `docker exec ...front ...`).
- Never run `pnpm install`, `pnpm add`, `npm install`, or global installs merely to make the quality gates run.
- If `node_modules` or other frontend dependencies are missing, report the blocker and ask before changing the environment.

### Frontend quality commands (run from the active worktree's `teamdev-2026-front/`)

When working on frontend-only changes, you can run the individual gates directly:

```bash
pnpm format     # Auto-fix formatting via Biome
pnpm lint:fix   # Auto-fix lint issues via Biome
pnpm test       # Run Jest unit tests
pnpm check      # Biome check (formatting + lint + organise imports)
```

The full `quality-gates.sh` script runs these (except `pnpm test`) plus `pnpm typecheck` automatically.

## Commit Execution Checklist (Agent)

Before finalizing commits:

- Ensure `git status` is clean except intended changes.
- Ensure quality gates pass (see above).
- Create commits in logical order.
- Rebase/squash only if requested; otherwise keep review-friendly commits.

## When you are blocked

If a gate fails due to environment/tooling issues you can’t fix locally (container not running, missing secrets, upstream outage):

- Report the exact failing command and the key error lines.
- Suggest the smallest next diagnostic step.
