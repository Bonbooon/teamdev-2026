#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"

echo "Initializing Laravel application..."

echo "Setting up environment file..."
if docker compose exec app test -f .env; then
  echo "  .env already exists (copied from main worktree) - skipping"
else
  docker compose exec app cp .env.example .env || echo "Warning: Failed to copy .env.example"
  echo "  Created .env from .env.example"
fi

echo "Generating application key..."
docker compose exec app php artisan key:generate

echo "Running database migrations..."
docker compose exec app php artisan migrate

echo "Seeding database..."
docker compose exec app php artisan db:seed

echo "Laravel initialization completed"
