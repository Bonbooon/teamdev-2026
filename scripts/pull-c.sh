#!/usr/bin/env bash
set -euo pipefail

bash scripts/pull-all.sh
bash scripts/cleanb.sh
echo "All repositories have been updated and cleaned up."