#!/usr/bin/env bash
set -euo pipefail

echo "Setting up worktree environment..."
echo "Using shared Docker images (no rebuild needed)"
echo ""

echo "1) Configuring submodules..."
mise run submodule-checkout
mise run submodule-update

echo ""
echo "2) Starting services (using existing images)..."
mise run start

echo ""
echo "3) Installing dependencies..."
mise run install-deps

echo ""
echo "4) Initializing application..."
mise run laravel-init

echo ""
echo "5) Installing frontend dependencies locally..."
mise run front-init

echo ""
echo "Worktree setup completed"
echo ""
mise run worktree-info
