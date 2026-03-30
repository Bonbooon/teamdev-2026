#!/usr/bin/env bash
set -euo pipefail

git fetch --prune
git branch -vv | awk '/: gone]/{print $1}' | xargs -r -n 1 git branch -D

cd teamdev-2026-api
git fetch --prune
git branch -vv | awk '/: gone]/{print $1}' | xargs -r -n 1 git branch -D

cd ../teamdev-2026-front
git fetch --prune
git branch -vv | awk '/: gone]/{print $1}' | xargs -r -n 1 git branch -D
echo "Cleaned up local branches that have been deleted on the remote."