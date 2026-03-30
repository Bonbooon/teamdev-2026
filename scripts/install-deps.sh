#!/usr/bin/env bash
set -euo pipefail

echo "Installing all dependencies..."
echo "Installing backend dependencies..."
docker compose exec app composer install
echo "All dependencies installed"
