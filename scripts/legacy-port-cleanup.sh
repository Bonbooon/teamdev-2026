#!/usr/bin/env bash
# legacy-port-cleanup.sh - Clean up legacy repo containers blocking WEB_PORT and SWAGGER_PORT
# Handles migration from old project-local container topology to new shared topology
# Only removes legacy repo containers that match expected patterns (not arbitrary containers)

set -euo pipefail

WEB_PORT="${1:-80}"
SWAGGER_PORT="${2:-8080}"
CURRENT_PROJECT="${3:-teamdev-2026}"
LEGACY_PROJECT_NAME="${4:-teamdev-2026}"

get_compose_project_label() {
  local container_name=$1

  docker inspect "$container_name" --format '{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null || true
}

# Function to safely remove legacy containers holding a specific port
cleanup_port_conflict() {
  local port=$1
  local port_name=$2
  local current_container=$3
  shift 3
  local legacy_containers=("$@")
  
  # Check if any container is publishing this port
  local container_with_port
  container_with_port=$(docker ps --filter "publish=$port" --format "{{.Names}}" 2>/dev/null | head -1 || echo "")
  
  if [ -z "$container_with_port" ]; then
    # Port is free; nothing to do
    return 0
  fi
  
  # Check if it's the container from the current project (expected case)
  if [ "$container_with_port" = "$current_container" ]; then
    # It's our current project's container, which is fine
    return 0
  fi
  
  # Check if it's a legacy repo container we should remove
  local is_legacy=false
  local compose_project_label
  compose_project_label=$(get_compose_project_label "$container_with_port")
  local legacy_container
  for legacy_container in "${legacy_containers[@]}"; do
    if [ "$container_with_port" = "$legacy_container" ] && [ "$compose_project_label" = "$LEGACY_PROJECT_NAME" ]; then
      is_legacy=true
      break
    fi
  done
  
  if [ "$is_legacy" = "true" ]; then
    echo "[legacy-cleanup] Found legacy $port_name container on port $port: $container_with_port"
    echo "[legacy-cleanup] Stopping and removing: $container_with_port"
    docker stop "$container_with_port" 2>/dev/null || true
    docker rm "$container_with_port" 2>/dev/null || true
    sleep 1  # Give the port time to be released
    return 0
  fi
  
  # Container is something else (not current project, not recognized legacy pattern); fail clearly
  echo "Error: Port $port (${port_name}) is published by an unexpected container: $container_with_port"
  echo "Expected either:"
  echo "  - Current project container: $current_container"
  echo "  - Legacy containers from compose project '$LEGACY_PROJECT_NAME': ${legacy_containers[*]}"
  echo "Please investigate and free port $port before retrying, or clear the container:"
  echo "  docker stop $container_with_port && docker rm $container_with_port"
  return 1
}

# Cleanup legacy containers holding WEB_PORT (specific legacy container: teamdev-2026-web-1)
if ! cleanup_port_conflict "$WEB_PORT" "WEB" "${CURRENT_PROJECT}-web-1" "teamdev-2026-web-1"; then
  exit 1
fi

# Cleanup legacy containers holding SWAGGER_PORT (specific legacy container: teamdev-2026-swagger-ui-1)
if ! cleanup_port_conflict "$SWAGGER_PORT" "SWAGGER" "${CURRENT_PROJECT}-swagger-ui-1" "teamdev-2026-swagger-ui-1"; then
  exit 1
fi

exit 0
