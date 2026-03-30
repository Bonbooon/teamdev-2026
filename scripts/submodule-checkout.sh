#!/usr/bin/env bash
set -euo pipefail

echo "Checking out submodules to their configured branches..."
git submodule foreach -q --recursive 'git switch $(git config -f $toplevel/.gitmodules submodule.$name.branch) || echo "Warning: Could not switch branch for $name"'
echo "Submodule checkout completed"
