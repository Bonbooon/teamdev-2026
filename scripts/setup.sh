#!/usr/bin/env bash
set -euo pipefail

echo "Setting up development environment..."
echo "This will take a few minutes on first run..."
echo ""

echo "1) Configuring submodules..."
mise run submodule-checkout
mise run submodule-update

echo ""
echo "2) Building Docker containers..."
mise run build

echo ""
echo "3) Ensuring shared PostgreSQL is running..."
mise run ensure-shared-db

echo ""
echo "4) Starting services..."
mise run start

echo ""
echo "5) Installing dependencies..."
mise run install-deps

echo ""
echo "6) Initializing application..."
mise run laravel-init

echo ""
echo "7) Installing frontend dependencies locally..."
mise run front-init

echo ""
echo "Setup completed successfully"
echo ""

# Only show default ports for main worktree. Linked worktrees use different ports.
if [ -f ".worktree.env" ]; then
  source .worktree.env
  if [ "$IS_MAIN_WORKTREE" = "true" ]; then
    echo "Services are now available at:"
    echo "  - Frontend: http://localhost"
    echo "  - Backend API: http://localhost/api"
    echo "  - Swagger UI: http://localhost:8080"
    echo "  - PostgreSQL: localhost:5432 (shared)"
  else
    echo "Linked worktree detected. Check worktree-info for actual ports:"
    echo "  mise run worktree-info"
  fi
else
  echo "Services are now available at:"
  echo "  - Frontend: http://localhost"
  echo "  - Backend API: http://localhost/api"
  echo "  - Swagger UI: http://localhost:8080"
  echo "  - PostgreSQL: localhost:5432 (shared)"
fi
