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
echo "6) Initializing application (will pause for DEMO_MANAGER_EMAIL + Google login before seeding)..."
mise run laravel-init

echo ""
echo "7) Installing frontend dependencies locally..."
mise run front-init

echo ""
echo "Setup completed successfully"
echo ""

# Prompt to set up Slack bot if the directory exists
if [ -d "teamdev-2026-slack" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📡 Slack bot setup available!"
  echo ""
  echo "  To configure the Slack bot (requires SLACK_BOT_TOKEN,"
  echo "  SLACK_APP_TOKEN, and OPENAI_API_KEY in teamdev-2026-slack/.env):"
  echo ""
  echo "    1. Copy teamdev-2026-slack/.env.example to .env"
  echo "    2. Fill in SLACK_BOT_TOKEN, SLACK_APP_TOKEN, OPENAI_API_KEY"
  echo "    3. Run:  mise run slack-env-setup"
  echo ""
  echo "  This will auto-populate project/team IDs and create an API token."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

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
