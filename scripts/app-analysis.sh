#!/usr/bin/env bash
set -euo pipefail

docker compose exec app vendor/bin/phpstan analyse --memory-limit=1G
