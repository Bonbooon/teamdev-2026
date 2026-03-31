#!/usr/bin/env bash
set -euo pipefail

# Access the shared PostgreSQL container
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure the shared DB is running before accessing it
bash "$SCRIPT_DIR/ensure-shared-db.sh"

docker compose -p "teamdev-2026-shared" -f "$COMPOSE_DIR/compose.shared.yml" exec postgresql bash
