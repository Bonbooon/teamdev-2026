#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

# Ensure shared PostgreSQL is running
# Execute in subshell to prevent exit statements from terminating this script
bash "$SCRIPT_DIR/ensure-shared-db.sh"

docker compose down && docker compose up -d
