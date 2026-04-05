#!/usr/bin/env bash
set -euo pipefail

# Source worktree detection to get COMPOSE_PROJECT_NAME and port environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-worktree.sh"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ENV_FILE="$ROOT_DIR/teamdev-2026-api/web/.env"

get_demo_manager_email() {
  if [ ! -f "$APP_ENV_FILE" ]; then
    return 0
  fi

  local email
  email=$(grep -E '^DEMO_MANAGER_EMAIL=' "$APP_ENV_FILE" | tail -n 1 | cut -d '=' -f 2- | tr -d '\r' || true)
  email="${email%\"}"
  email="${email#\"}"
  printf '%s' "$email"
}

ensure_interactive_terminal() {
  if [ -t 0 ]; then
    return 0
  fi

  echo "Error: mise run laravel-init requires interactive input for the demo manager Google login step."
  echo "Run it from an interactive terminal after setting DEMO_MANAGER_EMAIL in $APP_ENV_FILE."
  exit 1
}

verify_demo_manager_login() {
  docker compose exec -T app php <<'PHP' >/dev/null
<?php
chdir('/work/web');

require 'vendor/autoload.php';

$app = require 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$email = config('app.demo_manager_email');

if (!is_string($email) || $email === '') {
    fwrite(STDERR, "DEMO_MANAGER_EMAIL is not configured.\n");
    exit(2);
}

exit(App\Models\User::query()->where('email', mb_strtolower($email))->exists() ? 0 : 1);
PHP
}

prompt_for_demo_manager_login() {
  local demo_email
  local prompt_label

  while true; do
    demo_email="$(get_demo_manager_email)"

    echo ""
    echo "Database reset completed. Demo data seeding requires a Google-authenticated demo manager user."
    if [ -n "$demo_email" ]; then
      echo "DEMO_MANAGER_EMAIL is currently: $demo_email"
    else
      echo "DEMO_MANAGER_EMAIL is not set in $APP_ENV_FILE"
    fi
    echo ""
    echo "Before seeding:"
    echo "  1. Update $APP_ENV_FILE so DEMO_MANAGER_EMAIL matches the Google account you will use"
    echo "  2. Open the app in your browser and sign in with that Google account"
    echo "  3. Complete profile setup if this is the first login"
    echo ""

    prompt_label="Have you logged in yet? [Press Enter to verify and continue]"
    read -r -p "$prompt_label" _

    if verify_demo_manager_login; then
      demo_email="$(get_demo_manager_email)"
      echo "Demo manager user detected for ${demo_email:-DEMO_MANAGER_EMAIL}. Continuing with seeding..."
      return 0
    fi

    demo_email="$(get_demo_manager_email)"
    echo "Demo manager user was not found for ${demo_email:-<unset>} yet."
    echo "Update DEMO_MANAGER_EMAIL if needed, finish the Google login flow, then try again."
  done
}

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

ensure_interactive_terminal

echo "Resetting database with migrate:fresh..."
docker compose exec app php artisan migrate:fresh

prompt_for_demo_manager_login

echo "Seeding database..."
docker compose exec app php artisan db:seed

echo "Laravel initialization completed"
echo ""
echo "💡 If you plan to use the Slack bot, run:  mise run slack-env-setup"
