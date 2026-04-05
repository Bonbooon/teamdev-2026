#!/usr/bin/env bash
set -euo pipefail

# slack-env-setup.sh — Fetch IDs from the seeded DB and create a Sanctum token,
# then write them into teamdev-2026-slack/.env

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SLACK_DIR="$ROOT_DIR/teamdev-2026-slack"
ENV_FILE="$SLACK_DIR/.env"

if [ ! -d "$SLACK_DIR" ]; then
  echo "❌ teamdev-2026-slack/ directory not found at $SLACK_DIR"
  exit 1
fi

echo "🔍 Fetching IDs from database..."

# Helper: run a psql query against the shared DB and return the trimmed result
db_query() {
  docker compose -p "teamdev-2026-shared" -f "$ROOT_DIR/compose.shared.yml" \
    exec -T postgresql \
    psql -U user -d posse -t -A -c "$1" 2>/dev/null
}

# Fetch seeded UUIDs
PROJECT_ID=$(db_query "SELECT id FROM projects WHERE title = '顧客管理システム刷新' LIMIT 1")
TEMPLATE_ID=$(db_query "SELECT id FROM issue_templates WHERE name = 'SMARTタスクテンプレート' LIMIT 1")
TEAM_ID=$(db_query "SELECT id FROM teams WHERE name = 'エンジニアリングチーム' LIMIT 1")

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Project '顧客管理システム刷新' not found. Has the database been seeded?"
  exit 1
fi
if [ -z "$TEMPLATE_ID" ]; then
  echo "❌ Template 'SMARTタスクテンプレート' not found."
  exit 1
fi
if [ -z "$TEAM_ID" ]; then
  echo "❌ Team 'エンジニアリングチーム' not found."
  exit 1
fi

echo "   Project:  $PROJECT_ID"
echo "   Template: $TEMPLATE_ID"
echo "   Team:     $TEAM_ID"

# Resolve the demo manager email from the API's .env file
API_ENV_FILE="$ROOT_DIR/teamdev-2026-api/web/.env"
if [ ! -f "$API_ENV_FILE" ]; then
  echo "❌ API .env file not found at $API_ENV_FILE"
  exit 1
fi
DEMO_MANAGER_EMAIL=$(grep '^DEMO_MANAGER_EMAIL=' "$API_ENV_FILE" | cut -d= -f2- | tr -d '\r\n')
if [ -z "$DEMO_MANAGER_EMAIL" ]; then
  echo "❌ DEMO_MANAGER_EMAIL not set in $API_ENV_FILE"
  exit 1
fi

USER_ID=$(db_query "SELECT id FROM users WHERE email = '$DEMO_MANAGER_EMAIL' LIMIT 1")
if [ -z "$USER_ID" ]; then
  echo "❌ Demo manager user ($DEMO_MANAGER_EMAIL) not found. Has the database been seeded?"
  exit 1
fi
echo "   User:     $USER_ID ($DEMO_MANAGER_EMAIL)"

# Get assignee — the demo manager's team_member row in the engineering team
ASSIGNEE_ID=$(db_query "SELECT id FROM team_members WHERE team_id = '$TEAM_ID' AND user_id = '$USER_ID' LIMIT 1")
if [ -z "$ASSIGNEE_ID" ]; then
  echo "❌ Demo manager is not a member of team $TEAM_ID"
  exit 1
fi
echo "   Assignee: $ASSIGNEE_ID"

# Create a Sanctum API token via artisan tinker
echo "🔑 Creating Sanctum API token..."

API_TOKEN=$(docker compose exec -T app php artisan tinker --execute="
  \$user = App\Models\User::find('$USER_ID');
  if (!\$user) { echo 'USER_NOT_FOUND'; exit(1); }
  \$token = \$user->createToken('slack-bot');
  echo \$token->plainTextToken;
" 2>/dev/null | tr -d '\r\n')

if [ -z "$API_TOKEN" ] || [ "$API_TOKEN" = "USER_NOT_FOUND" ]; then
  echo "❌ Failed to create API token for user $USER_ID"
  exit 1
fi
echo "   Token:    ${API_TOKEN:0:10}..."

# Write the .env file, preserving existing Slack/OpenAI keys if present
if [ -f "$ENV_FILE" ]; then
  # Read existing values we want to keep
  EXISTING_SLACK_BOT=$(grep '^SLACK_BOT_TOKEN=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || true)
  EXISTING_SLACK_APP=$(grep '^SLACK_APP_TOKEN=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || true)
  EXISTING_OPENAI=$(grep '^OPENAI_API_KEY=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || true)
  EXISTING_API_BASE=$(grep '^API_BASE_URL=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || true)
fi

cat > "$ENV_FILE" <<EOF
SLACK_BOT_TOKEN=${EXISTING_SLACK_BOT:-xoxb-your-token}
SLACK_APP_TOKEN=${EXISTING_SLACK_APP:-xapp-your-token}
OPENAI_API_KEY=${EXISTING_OPENAI:-sk-your-key}
API_BASE_URL=${EXISTING_API_BASE:-http://localhost:80/api}

API_TOKEN="${API_TOKEN}"
DEFAULT_PROJECT_ID=${PROJECT_ID}
DEFAULT_TEMPLATE_ID=${TEMPLATE_ID}
DEFAULT_TEAM_ID=${TEAM_ID}
DEFAULT_ASSIGNEE_ID=${ASSIGNEE_ID}
EOF

echo ""
echo "✅ Written to $ENV_FILE"
echo "   Make sure SLACK_BOT_TOKEN, SLACK_APP_TOKEN, and OPENAI_API_KEY are set."
