#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose -p "teamdev-2026-shared" -f "$COMPOSE_DIR/compose.shared.yml" stop