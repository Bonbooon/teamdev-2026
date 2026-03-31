#!/usr/bin/env bash
# ensure-shared-db.sh - Ensure the shared PostgreSQL container is running
# This script handles legacy per-worktree PostgreSQL containers from the old topology
# Allows safe migration: removes legacy containers if they block port 5432

set -euo pipefail

SHARED_PROJECT_NAME="teamdev-2026-shared"
SHARED_CONTAINER_NAME="${SHARED_PROJECT_NAME}-postgresql-1"
CANONICAL_SHARED_NETWORK_NAME="teamdev-2026-shared"
LEGACY_SHARED_NETWORK_NAME="${SHARED_PROJECT_NAME}_teamdev-2026-shared"
COMPOSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

is_shared_db_running() {
  local container_id

  container_id=$(docker compose -p "$SHARED_PROJECT_NAME" -f "$COMPOSE_DIR/compose.shared.yml" ps -q postgresql 2>/dev/null || true)

  if [ -z "$container_id" ]; then
    return 1
  fi

  [ "$(docker inspect --format '{{.State.Running}}' "$container_id" 2>/dev/null || echo false)" = "true" ]
}

get_container_networks() {
  local container_name="$1"

  docker inspect "$container_name" --format '{{range $name, $_ := .NetworkSettings.Networks}}{{printf "%s\n" $name}}{{end}}' 2>/dev/null || true
}

reconcile_shared_db_network_attachment() {
  local attached_networks
  attached_networks=$(get_container_networks "$SHARED_CONTAINER_NAME")

  if [ -z "$attached_networks" ]; then
    return 0
  fi

  if echo "$attached_networks" | grep -qx "$CANONICAL_SHARED_NETWORK_NAME"; then
    return 0
  fi

  echo "[network-reconcile] Shared PostgreSQL is not attached to '$CANONICAL_SHARED_NETWORK_NAME'."
  echo "[network-reconcile] Current network attachments:"
  echo "$attached_networks" | sed 's/^/  - /'
  echo "[network-reconcile] Recreating $SHARED_CONTAINER_NAME on '$CANONICAL_SHARED_NETWORK_NAME'"

  docker rm -f "$SHARED_CONTAINER_NAME" >/dev/null 2>&1 || true

  if echo "$attached_networks" | grep -qx "$LEGACY_SHARED_NETWORK_NAME"; then
    docker network rm "$LEGACY_SHARED_NETWORK_NAME" >/dev/null 2>&1 || true
  fi
}

# Function to detect and remove legacy per-worktree PostgreSQL containers blocking port 5432
# Robust approach using Docker's own port detection (netstat/ss unreliable on Windows Git Bash)
handle_legacy_postgres_on_5432() {
  local port=5432
  
  # Check which container (if any) is publishing port 5432 via Docker
  local container_with_port
  container_with_port=$(docker ps --filter "publish=$port" --format "{{.Names}}" 2>/dev/null | head -1 || echo "")
  
  # No container publishing the port
  if [ -z "$container_with_port" ]; then
    # Port is free in Docker; safe to continue (will catch non-Docker conflicts later)
    return 0
  fi
  
  # Check if the container is the intended shared container
  if [ "$container_with_port" = "${SHARED_PROJECT_NAME}-postgresql-1" ]; then
    echo "Shared PostgreSQL is already running on port $port"
    return 0
  fi
  
  # Check if it's a legacy per-worktree PostgreSQL container (ends with -postgresql-1 but isn't the shared one)
  if [[ "$container_with_port" =~ -postgresql-1$ ]]; then
    # Found a legacy per-worktree PostgreSQL container blocking the port; remove it
    echo "[legacy-cleanup] Found legacy per-worktree PostgreSQL container on port $port: $container_with_port"
    echo "[legacy-cleanup] Stopping and removing: $container_with_port"
    docker stop "$container_with_port" 2>/dev/null || true
    docker rm "$container_with_port" 2>/dev/null || true
    sleep 1  # Give the port time to be released
    return 0
  fi
  
  # Container is something else entirely; fail with clear error
  echo "Error: Port $port is published by an unexpected container: $container_with_port"
  echo "Expected '${SHARED_PROJECT_NAME}-postgresql-1' or a legacy per-worktree PostgreSQL container"
  echo "Please investigate and free port $port before retrying."
  return 1
}

# Handle potential legacy PostgreSQL containers blocking port 5432
if ! handle_legacy_postgres_on_5432; then
  exit 1
fi

reconcile_shared_db_network_attachment

# Check if the shared DB container is already running
if is_shared_db_running; then
  exit 0
fi

# Check if the network exists
if ! docker network ls | grep -q "^.*teamdev-2026-shared"; then
  # Network doesn't exist; need to start shared DB to create it
  if ! docker compose -p "$SHARED_PROJECT_NAME" -f "$COMPOSE_DIR/compose.shared.yml" up -d 2>&1; then
    echo ""
    echo "Error: Failed to start shared PostgreSQL container."
    echo "This may be due to port 5432 being held by a non-Docker process."
    echo "Please check port 5432 and try again:"
    echo "  docker ps --filter publish=5432"
    echo "  # On Windows (PowerShell): netstat -ano | findstr :5432"
    echo "  # On Linux/macOS: netstat -tuln | grep 5432"
    exit 1
  fi
else
  # Network exists but container isn't running; start just the container
  if ! docker compose -p "$SHARED_PROJECT_NAME" -f "$COMPOSE_DIR/compose.shared.yml" up -d postgresql 2>&1; then
    echo ""
    echo "Error: Failed to start shared PostgreSQL container."
    echo "This may be due to port 5432 being held by a non-Docker process."
    echo "Please check port 5432 and try again:"
    echo "  docker ps --filter publish=5432"
    echo "  # On Windows (PowerShell): netstat -ano | findstr :5432"
    echo "  # On Linux/macOS: netstat -tuln | grep 5432"
    exit 1
  fi
fi

# Wait for DB to be ready
echo "Waiting for shared PostgreSQL to be ready..."
for i in {1..30}; do
  if docker compose -p "$SHARED_PROJECT_NAME" -f "$COMPOSE_DIR/compose.shared.yml" exec -T postgresql pg_isready -U user -d posse >/dev/null 2>&1; then
    echo "PostgreSQL is ready"
    exit 0
  fi
  echo "  [$i/30] PostgreSQL not ready yet, waiting..."
  sleep 1
done

echo "Error: Shared PostgreSQL failed to start within 30 seconds"
exit 1
