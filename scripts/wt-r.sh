#!/usr/bin/env bash
set -euo pipefail

WORKTREE_NAME=${1:-}

if [ -z "$WORKTREE_NAME" ]; then
  echo "Error: worktree name is required"
  echo "Usage: mise run wt-r feature-my-feature"
  echo ""
  echo "Available worktrees:"
  git worktree list
  exit 1
fi

WORKTREE_PATH="worktrees/$WORKTREE_NAME"
WORKTREE_BASENAME=$(basename "$WORKTREE_PATH")
COMPOSE_PROJECT_NAME="teamdev-2026-$WORKTREE_BASENAME"
COMPOSE_PROJECT_NAME=$(echo "$COMPOSE_PROJECT_NAME" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

if [ ! -d "$WORKTREE_PATH" ]; then
  echo "Error: worktree not found: $WORKTREE_PATH"
  exit 1
fi

echo "Removing worktree: $WORKTREE_PATH"
echo "Stopping/removing Docker resources for: $COMPOSE_PROJECT_NAME"

docker compose -p "$COMPOSE_PROJECT_NAME" -f "$WORKTREE_PATH/compose.yml" down --rmi local --volumes --remove-orphans || true
sleep 1

chmod -R u+rwX "$WORKTREE_PATH" 2>/dev/null || true
chmod -RN "$WORKTREE_PATH" 2>/dev/null || true
xattr -rc "$WORKTREE_PATH" 2>/dev/null || true

if command -v docker >/dev/null 2>&1; then
  docker run --rm \
    -v "$PWD/$WORKTREE_PATH:/worktree" \
    alpine:3.20 \
    sh -c "chown -R $(id -u):$(id -g) /worktree 2>/dev/null || true" || true
fi

git worktree remove --force "$WORKTREE_PATH" || true
rm -rf "$WORKTREE_PATH"

if [ -e "$WORKTREE_PATH" ]; then
  echo "Warning: Could not fully delete $WORKTREE_PATH"
  echo "Open handles (if any):"
  lsof +D "$WORKTREE_PATH" 2>/dev/null | head -20 || true
  exit 1
fi

echo "Worktree removed"
