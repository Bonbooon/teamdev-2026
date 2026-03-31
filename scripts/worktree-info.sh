#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get WORKTREE_NAME, COMPOSE_PROJECT_NAME, and ports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

echo "----------------------------------------"
echo "  Worktree Information"
echo "----------------------------------------"
echo "Name: $WORKTREE_NAME"
if [ "$IS_MAIN_WORKTREE" = "true" ]; then
  echo "Type: Main worktree"
else
  echo "Type: Linked worktree"
fi
echo "Compose project: $COMPOSE_PROJECT_NAME"
echo "Ports: web=$WEB_PORT db=$DB_PORT swagger=$SWAGGER_PORT"
echo ""
echo "Active containers:"
docker compose ps
echo "----------------------------------------"
