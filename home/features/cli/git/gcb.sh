#!/usr/bin/env bash
# Clone a bare repository and set it up for worktrunk worktree workflow

set -euo pipefail

url="${1:-}"
dir="${2:-}"

if [[ -z "$url" ]]; then
  echo "Usage: $(basename "$0") <url> [directory]"
  exit 1
fi

# Derive directory name from URL if not provided
if [[ -z "$dir" ]]; then
  dir=$(basename "$url" .git)
fi

mkdir -p "$dir"
git clone --bare "$url" "$dir/.git"
cd "$dir/.git"
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git fetch origin
git remote set-head origin --auto
cd ..
echo "Bare repo ready at $PWD"
