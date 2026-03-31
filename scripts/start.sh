#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

# Ensure shared PostgreSQL is running before starting this worktree's stack
bash "$SCRIPT_DIR/ensure-shared-db.sh"

# Clean up legacy repo containers that may hold the ports we need
bash "$SCRIPT_DIR/legacy-port-cleanup.sh" "$WEB_PORT" "$SWAGGER_PORT" "$COMPOSE_PROJECT_NAME"

# Start the worktree's stack, removing any orphaned services (e.g., old project-local postgresql)
docker compose up -d --remove-orphans
