#!/usr/bin/env bash
# gen-worktree-env.sh - Generate deterministic Docker Compose env vars for a worktree
# Usage: gen-worktree-env.sh <worktree-name> [<is-main>]
# Example: gen-worktree-env.sh "main" "true" > .worktree.env

set -e

WORKTREE_NAME="${1:-}"
IS_MAIN_WORKTREE="${2:-false}"

if [ -z "$WORKTREE_NAME" ]; then
  echo "Error: worktree name required"
  echo "Usage: gen-worktree-env.sh <worktree-name> [is-main-true-false]"
  exit 1
fi

# Docker Compose project namespace: canonical name for main worktree, normalized name for linked worktrees.
if [ "$IS_MAIN_WORKTREE" = "true" ]; then
  PROJECT_NAME="teamdev-2026"
else
  PROJECT_NAME="teamdev-2026-${WORKTREE_NAME}"
  PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi

# Main worktree keeps canonical web/swagger ports. Linked worktrees keep their offsets.
# All worktrees share one PostgreSQL database on 5432.
if [ "$IS_MAIN_WORKTREE" = "true" ]; then
  WEB_PORT="80"
  DB_PORT="5432"
  SWAGGER_PORT="8080"
else
  # Use a simple hash based on worktree name to compute deterministic offset
  # This avoids cksum dependency and produces consistent results on all platforms
  HASH=0
  for i in $(echo "$WORKTREE_NAME" | od -An -tu1 | tr -d ' '); do
    HASH=$((HASH + i))
  done
  OFFSET=$((HASH % 2000 + 1))
  WEB_PORT="$((10080 + OFFSET))"
  DB_PORT="5432"
  SWAGGER_PORT="$((18080 + OFFSET))"
fi

# Output as shell-sourceable format
cat << EOF
# Generated worktree Docker Compose environment
# DO NOT EDIT MANUALLY - regenerate using: scripts/gen-worktree-env.sh
IS_MAIN_WORKTREE="$IS_MAIN_WORKTREE"
WORKTREE_NAME="$WORKTREE_NAME"
COMPOSE_PROJECT_NAME="$PROJECT_NAME"
WEB_PORT="$WEB_PORT"
DB_PORT="$DB_PORT"
SWAGGER_PORT="$SWAGGER_PORT"
EOF
