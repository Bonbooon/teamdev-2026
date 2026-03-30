#!/usr/bin/env bash
set -euo pipefail

echo "1) Generating OpenAPI spec from PHP annotations..."
docker compose exec app php artisan l5-swagger:generate

echo "2) Copying spec to docs/openapi/..."
cp teamdev-2026-api/web/storage/api-docs/api-docs.json teamdev-2026-api/docs/openapi/openapi.json

echo "3) Regenerating frontend types..."
cd teamdev-2026-front
pnpm run openapi
pnpm run format

echo "OpenAPI codegen complete"
