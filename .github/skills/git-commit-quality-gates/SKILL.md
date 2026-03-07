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

Run the quality gates via the single entrypoint script from the repo root:

```bash
./scripts/quality-gates.sh
```

Behavior:

- Runs workspace + frontend quality checks in the required order.
- Auto-detects OpenAPI contract changes and runs OpenAPI regeneration only when needed.

Options:

- `./scripts/quality-gates.sh --skip-mise`
- `./scripts/quality-gates.sh --skip-openapi`

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
