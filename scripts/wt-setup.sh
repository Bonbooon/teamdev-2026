#!/usr/bin/env bash
set -euo pipefail

echo "Setting up worktree environment..."
echo "Using shared Docker images (no rebuild needed)"
echo ""

echo "1) Configuring submodules..."
mise run submodule-checkout
mise run submodule-update

echo ""
echo "2) Ensuring shared PostgreSQL is running..."
mise run ensure-shared-db

echo ""
echo "3) Starting services (using existing images)..."
mise run start

echo ""
echo "4) Installing dependencies..."
mise run install-deps

echo ""
echo "5) Preparing Laravel application (shared DB: no migrate/seed)..."
if docker compose exec app test -f .env; then
	echo "  .env already exists - skipping"
else
	docker compose exec app cp .env.example .env || echo "Warning: Failed to copy .env.example"
	echo "  Created .env from .env.example"
fi

if docker compose exec app sh -c "grep -Eq '^APP_KEY=.+$' .env"; then
	echo "  APP_KEY already exists - skipping"
else
	echo "  Generating application key..."
	docker compose exec app php artisan key:generate
fi

echo "  Skipping migrations and seeders because worktrees share the same PostgreSQL database."
echo "  Run 'mise run laravel-init' manually only when you intentionally want to reset and reseed the shared database."

echo ""
echo "6) Installing frontend dependencies locally..."
mise run front-init

echo ""
echo "Worktree setup completed"
echo ""
mise run worktree-info
