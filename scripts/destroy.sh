#!/usr/bin/env bash
set -euo pipefail

docker compose down --rmi all --volumes --remove-orphans
