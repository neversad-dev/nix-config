#!/usr/bin/env bash
set -euo pipefail

NIX_SECRETS_STUB="${1:-stub-flake-for-ci/nix-secrets}"
WALLPAPERS_STUB="${2:-stub-flake-for-ci/wallpapers}"

# Generate nix-secrets stubs based on ${mysecrets} references in the codebase
mkdir -p "$NIX_SECRETS_STUB"

grep -r '\${mysecrets}' home/ hosts/ secrets/ modules/ 2>/dev/null |
  sed -n 's/.*\${mysecrets}\/\([^"'"'"'; ]*\).*/\1/p' | sort -u | while read -r p; do
  mkdir -p "$NIX_SECRETS_STUB/$(dirname "$p")"
  touch "$NIX_SECRETS_STUB/$p"
done

echo "Generated nix-secrets stubs in $NIX_SECRETS_STUB:"
find "$NIX_SECRETS_STUB" -type f | sort

# Generate wallpapers stub (just needs a desktop/ directory)
mkdir -p "$WALLPAPERS_STUB/desktop"
echo "# CI stub for wallpapers flake input" > "$WALLPAPERS_STUB/desktop/README.md"
echo "" >> "$WALLPAPERS_STUB/desktop/README.md"
echo "Replaces the large wallpapers repository during CI builds" >> "$WALLPAPERS_STUB/desktop/README.md"
echo "to avoid downloading hundreds of images for every dry-run evaluation." >> "$WALLPAPERS_STUB/desktop/README.md"

echo ""
echo "Generated wallpapers stub in $WALLPAPERS_STUB:"
find "$WALLPAPERS_STUB" -type f | sort
