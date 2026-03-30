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
echo "3) Starting services..."
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
echo "Setup completed successfully"
echo ""
echo "Services are now available at:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost/api"
echo "  - Swagger UI: http://localhost:8080"
echo "  - PostgreSQL: localhost:5432"
