#!/bin/bash
# detect-worktree.sh - Detect worktree and export Docker Compose isolation vars

set -e

# Detect worktree type
GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -z "$GIT_TOPLEVEL" ]; then
  # Not in a git repo
  export IS_MAIN_WORKTREE="true"
  export WORKTREE_NAME="unknown"
else
  MAIN_WORKTREE=$(git worktree list --porcelain | awk '/^worktree / {print $2; exit}')
  export WORKTREE_NAME=$(basename "$GIT_TOPLEVEL")

  if [ "$GIT_TOPLEVEL" = "$MAIN_WORKTREE" ]; then
    export IS_MAIN_WORKTREE="true"
  else
    export IS_MAIN_WORKTREE="false"
  fi
fi

# Every worktree gets its own Docker Compose project namespace.
PROJECT_NAME="teamdev-2026-${WORKTREE_NAME}"
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
export COMPOSE_PROJECT_NAME="$PROJECT_NAME"

# Main worktree keeps canonical ports. Linked worktrees get deterministic offsets.
if [ "$IS_MAIN_WORKTREE" = "true" ]; then
  export WEB_PORT="80"
  export DB_PORT="5432"
  export SWAGGER_PORT="8080"
else
  WORKTREE_HASH=$(printf "%s" "$WORKTREE_NAME" | cksum | awk '{print $1}')
  OFFSET=$((WORKTREE_HASH % 2000 + 1))
  export WEB_PORT="$((10080 + OFFSET))"
  export DB_PORT="$((15432 + OFFSET))"
  export SWAGGER_PORT="$((18080 + OFFSET))"
fi

# Optional: Print info (enable with MISE_WORKTREE_VERBOSE=1)
if [ "${MISE_WORKTREE_VERBOSE:-0}" = "1" ]; then
  if [ "$IS_MAIN_WORKTREE" = "true" ]; then
    echo "🏠 Main worktree: $WORKTREE_NAME"
  else
    echo "🌿 Linked worktree: $WORKTREE_NAME"
  fi
  echo "🐳 COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
  echo "🔌 WEB_PORT=$WEB_PORT DB_PORT=$DB_PORT SWAGGER_PORT=$SWAGGER_PORT"
fi
