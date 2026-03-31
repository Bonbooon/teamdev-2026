#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

FILTER=${1:-}
if [ -z "$FILTER" ]; then
  echo "Error: filter is required"
  echo "Usage: mise run t --filter='your-test-name'"
  exit 1
fi

docker compose exec app php artisan test --filter="$FILTER"
