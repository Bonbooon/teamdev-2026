#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

docker compose exec app vendor/bin/phpstan analyse --memory-limit=1G
