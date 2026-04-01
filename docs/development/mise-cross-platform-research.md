# Mise Cross-Platform Research

Date: 2026-04-01

## Purpose

This note documents a static review of the repository's `mise` configuration and task entrypoints to confirm that the Windows-native fixes do not introduce obvious regressions on macOS or Linux.

## Summary

- The Windows-specific `mise` settings are scoped to Windows shell launch behavior and should not, by themselves, break macOS or Linux.
- Task definitions remain Bash-based on all hosts, so the Windows change did not fork task behavior by platform.
- Moving away from config-time `env._.source` and toward explicit `.worktree.env` loading is generally safer across hosts.
- The main standalone-entrypoint gap identified during review was `wt-setup`, and it has now been aligned with the other compose-backed scripts by loading worktree environment values explicitly.
- A few unrelated Unix portability caveats still exist in task scripts, but they are separate from the Windows wrapper change.

## How Host OS Differences Are Handled

### Windows-specific shell settings

The root `mise.toml` uses Windows-only shell settings so native Windows runs tasks through `scripts/windows/bash.cmd`.

This affects shell launch on Windows only:

- `windows_default_inline_shell_args`
- `windows_default_file_shell_args`
- `use_file_shell_for_executable_tasks`

Because these are Windows-only settings, Unix hosts keep using `mise`'s normal Unix shell behavior.

### Shared task model across hosts

The actual task definitions still call Bash scripts on every host. Representative examples:

- `mise run start` -> `bash scripts/start.sh`
- `mise run install-deps` -> `bash scripts/install-deps.sh`
- `mise run fmtl` -> `bash scripts/fmtl.sh`

That means the Windows work was applied at the task launcher layer, not by splitting task definitions per OS.

### Worktree environment model

The repository now relies on explicit worktree environment files instead of config-time Bash sourcing.

- `scripts/gen-worktree-env.sh` generates `.worktree.env`
- `scripts/detect-worktree.sh` loads `.worktree.env` when present
- Most `docker compose` task scripts source `detect-worktree.sh` themselves before doing any work

This is generally more predictable than asking `mise` to source Bash during config loading.

## Task Portability Review

### Standalone-safe compose-backed tasks

These scripts load `detect-worktree.sh` themselves before using `docker compose`, so they are safe to run directly from the current worktree:

- `start`
- `ps`
- `down`
- `destroy`
- `build`
- `install-deps`
- `app-format`
- `app-analysis`
- `fmtl`
- `ft`
- `t`
- `rs`
- `codegen-openapi`
- `laravel-init`
- `app-shell`
- `front-shell`
- `worktree-info`

### Standalone-safe shared DB tasks

These do not depend on per-worktree compose env because they intentionally target the shared PostgreSQL compose project:

- `ensure-shared-db`
- `stop-shared-db`
- `db-shell`

### Standalone-safe non-compose or orchestration tasks

These tasks either orchestrate other tasks that already load their own env, or they do not depend on worktree docker variables:

- `setup`
- `submodule-checkout`
- `submodule-update`
- `front-format`
- `front-init`
- `install-deps-local`
- `all`
- `prd`
- `prdf`
- `prda`
- `pull-all`
- `cleanb`
- `pull-c`
- `wt-c`
- `wt-list`
- `wt-r`
- `render-puml`

### Follow-up fix applied after review

The review identified `wt-setup` as the only compose-backed task script that used `docker compose` directly without first loading worktree environment values.

That gap has now been fixed so `wt-setup` matches the same self-loading pattern used by `start`, `install-deps`, and `worktree-info`.

Result:

- The normal `wt-c` flow still works as before.
- A direct `mise run wt-setup` inside a linked worktree is now consistent with the rest of the compose-backed tasks.
- Linked worktree startup no longer depends on inherited environment for resolving worktree-specific compose settings in that script.

## Why The Windows Changes Are Likely Safe On macOS/Linux

The Windows-native support mainly changed how `mise` launches tasks on Windows. It did not add Unix-facing conditionals that redirect macOS/Linux into a Windows-specific execution path.

The strongest evidence for this is:

1. Task definitions remain plain Bash entrypoints for every host.
2. The Windows wrapper script lives in `scripts/windows/bash.cmd`, which is only meaningful on Windows.
3. The more important behavior change was replacing config-time shell sourcing with explicit runtime env loading, which is a portability improvement.

## Remaining Cross-Platform Caveats

These issues are real, but they are not caused by the Windows `mise` wrapper settings.

### `cleanb` uses GNU `xargs -r`

`scripts/cleanb.sh` uses `xargs -r`, which is GNU-specific and can fail on macOS where BSD `xargs` is standard.

### `render-puml` assumes Homebrew for Java bootstrap

If Java is missing, `scripts/render-puml.sh` tries to install it with Homebrew. That is fine on macOS with Homebrew, but it is not a general Linux solution.

### `wt-r` contains best-effort host-specific cleanup helpers

`scripts/wt-r.sh` includes commands such as:

- `chmod -RN`
- `xattr -rc`
- `lsof +D`

These are guarded with `|| true`, so they are best-effort cleanup rather than hard failures, but they are not uniformly portable.

## Documentation Drift Found During Review

The root README previously mentioned `mise run lint`, but the actual task name in `mise.toml` is `fmtl`. That doc drift has now been corrected.

## Recommendations

1. Replace or guard GNU-specific `xargs -r` usage in `cleanb`.
2. Make `render-puml`'s Java bootstrap path host-aware, or document Java as a prerequisite instead of auto-installing it.

## Confidence And Limits

This was a static repository review. I did not execute the task matrix on actual macOS or Linux hosts in this session.

Within that limit, the Windows-native `mise` wiring itself looks properly scoped. The remaining risks are the separate Unix portability caveats noted above rather than the Windows shell-wrapper change.