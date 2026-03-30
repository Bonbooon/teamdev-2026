#!/usr/bin/env bash
set -euo pipefail

FILTER=${1:-}
if [ -z "$FILTER" ]; then
  echo "Error: filter is required"
  echo "Usage: mise run t --filter='your-test-name'"
  exit 1
fi

docker compose exec app php artisan test --filter="$FILTER"
