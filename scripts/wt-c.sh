#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME=${1:-}
WORKTREE_PATH="worktrees/$BRANCH_NAME"

if [ -z "$BRANCH_NAME" ]; then
  echo "Error: branch name is required"
  echo "Usage: mise run wt-c feature/my-feature"
  exit 1
fi

mkdir -p ./worktrees

echo "Creating worktree..."
echo "  Branch: $BRANCH_NAME"
echo "  Path: $WORKTREE_PATH"
echo ""

git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

echo ""
echo "Initializing submodules and checking out matching branches..."
echo ""

cd "$WORKTREE_PATH"
git submodule update --init --recursive

git config --file .gitmodules --get-regexp path | awk '{print $2}' | while read -r SUBMODULE_PATH; do
  SUBMODULE_NAME=$(basename "$SUBMODULE_PATH")
  echo "Processing submodule: $SUBMODULE_NAME"

  cd "$SUBMODULE_PATH"

  if git rev-parse --verify "origin/$BRANCH_NAME" >/dev/null 2>&1; then
    git switch --create "$BRANCH_NAME" "origin/$BRANCH_NAME"
    echo "  Checked out existing branch: $BRANCH_NAME"
  elif git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    git switch "$BRANCH_NAME"
    echo "  Switched to existing local branch: $BRANCH_NAME"
  else
    echo "  Branch does not exist, creating from main..."
    git switch --create "$BRANCH_NAME" origin/main
    echo "  Created new branch: $BRANCH_NAME (from main)"
  fi

  cd ..
done

cd ../..

echo ""
echo "Copying .env files from main worktree..."
MAIN_ROOT="$(pwd)"

if [ -f "$MAIN_ROOT/teamdev-2026-front/.env.local" ]; then
  cp "$MAIN_ROOT/teamdev-2026-front/.env.local" "$WORKTREE_PATH/teamdev-2026-front/.env.local"
  echo "  Copied teamdev-2026-front/.env.local"
else
  echo "  No .env.local found in main frontend - skipped"
fi

if [ -f "$MAIN_ROOT/teamdev-2026-api/web/.env" ]; then
  cp "$MAIN_ROOT/teamdev-2026-api/web/.env" "$WORKTREE_PATH/teamdev-2026-api/web/.env"
  echo "  Copied teamdev-2026-api/web/.env"
else
  echo "  No .env found in main backend - skipped"
fi

echo ""
echo "Generating worktree-local Docker environment..."
MAIN_REPO_ROOT="$(pwd)"
bash "$MAIN_REPO_ROOT/scripts/gen-worktree-env.sh" "$BRANCH_NAME" "false" > "$WORKTREE_PATH/.worktree.env"
if [ ! -f "$WORKTREE_PATH/.worktree.env" ] || [ ! -s "$WORKTREE_PATH/.worktree.env" ]; then
  echo "Error: Failed to generate .worktree.env"
  exit 1
fi
echo "  Generated $WORKTREE_PATH/.worktree.env"

echo ""
echo "Worktree created successfully"
echo ""
echo "Submodule status:"
cd "$WORKTREE_PATH"
git submodule foreach --recursive 'echo "  $displaypath: $(git branch --show-current)"' || true

# Load the worktree env before running tasks
if [ ! -f .worktree.env ]; then
  echo "Error: .worktree.env not found in worktree directory"
  exit 1
fi
set -a
source .worktree.env
set +a

mise run wt-setup
mise run worktree-info
cd - >/dev/null 2>&1
