#!/usr/bin/env bash
set -euo pipefail

echo "Updating submodules to latest commits..."
git submodule update --remote --merge
echo "Submodule update completed"
