#!/usr/bin/env bash
set -euo pipefail

echo "Installing frontend dependencies..."

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm not found. Install with: mise install"
  exit 1
fi

cd teamdev-2026-front
pnpm install

echo ""
echo "Frontend dependencies installed."
echo "Backend formatter/linter/tests run in Docker containers via mise tasks."
