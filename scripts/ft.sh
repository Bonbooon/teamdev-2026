#!/usr/bin/env bash
set -euo pipefail

docker compose exec app php artisan test
