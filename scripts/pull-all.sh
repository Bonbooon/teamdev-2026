#!/usr/bin/env bash
set -euo pipefail

git switch master
git pull
echo "Pulling all repositories..."

cd teamdev-2026-api
git switch main
git pull
echo "Pulled teamdev-2026-api"

cd ../teamdev-2026-front
git switch main
git pull
echo "Pulled teamdev-2026-front"