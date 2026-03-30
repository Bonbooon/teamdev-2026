#!/usr/bin/env bash
set -euo pipefail

docker compose exec app vendor/bin/pint
