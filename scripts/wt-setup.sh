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
echo "5) Initializing application..."
mise run laravel-init

echo ""
echo "6) Installing frontend dependencies locally..."
mise run front-init

echo ""
echo "Worktree setup completed"
echo ""
mise run worktree-info
