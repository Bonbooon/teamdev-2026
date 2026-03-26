#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FRONT_DIR="$ROOT_DIR/teamdev-2026-front"
API_DIR="$ROOT_DIR/teamdev-2026-api/web"

usage() {
  cat <<'USAGE'
Usage: scripts/quality-gates.sh [--skip-mise] [--skip-openapi]

Runs the repo quality gates in the expected order:
  1) mise all
  2) pnpm check
  3) pnpm check:fix
  4) pnpm format
  5) pnpm lint:fix
  6) pnpm typecheck
  7) pnpm test
  8) pnpm openapi (only if OpenAPI contracts changed)

Notes:
- This script does not auto-fix failures; it stops at the first failing command.
- If fix/format/lint steps modify files, it re-runs pnpm check + pnpm typecheck.
USAGE
}

SKIP_MISE=0
SKIP_OPENAPI=0

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --skip-mise)
      SKIP_MISE=1
      ;;
    --skip-openapi)
      SKIP_OPENAPI=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

run() {
  echo
  echo "+ $*"
  "$@"
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "Missing directory: $dir" >&2
    exit 1
  fi
}

# Collect changed paths (staged + unstaged + untracked) within a git repo.
# If the directory isn't a git repo, return empty.
git_changed_paths() {
  local repo_dir="$1"
  if ! git -C "$repo_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  {
    git -C "$repo_dir" diff --name-only
    git -C "$repo_dir" diff --name-only --cached
    git -C "$repo_dir" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

has_openapi_contract_changes() {
  local changed_front changed_api

  changed_front="$(git_changed_paths "$FRONT_DIR" || true)"
  changed_api="$(git_changed_paths "$API_DIR" || true)"

  if echo "$changed_front" | grep -Eq '^openapi/'; then
    return 0
  fi

  # API OpenAPI source-of-truth is expected under docs/openapi/
  if echo "$changed_api" | grep -Eq '^\.\./docs/openapi/|^docs/openapi/'; then
    return 0
  fi

  return 1
}

require_dir "$ROOT_DIR"
require_dir "$FRONT_DIR"
require_dir "$API_DIR"

if [[ "$SKIP_MISE" -eq 0 ]]; then
  run cd "$ROOT_DIR"
  run mise all
fi

run cd "$FRONT_DIR"

front_status_before="$(git_changed_paths "$FRONT_DIR" || true)"

run pnpm check
run pnpm check:fix
run pnpm format
run pnpm lint:fix
run pnpm typecheck
run pnpm test

front_status_after="$(git_changed_paths "$FRONT_DIR" || true)"

if [[ "$front_status_before" != "$front_status_after" ]]; then
  echo
  echo "Detected file changes from fix/format/lint; re-running check + typecheck."
  run pnpm check
  run pnpm typecheck
fi

if [[ "$SKIP_OPENAPI" -eq 0 ]]; then
  if has_openapi_contract_changes; then
    echo
    echo "OpenAPI contract changes detected; running pnpm openapi."
    run pnpm openapi
    run pnpm typecheck
  else
    echo
    echo "No OpenAPI contract changes detected; skipping pnpm openapi."
  fi
fi

echo
echo "All quality gates passed."
