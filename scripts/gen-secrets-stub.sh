#!/usr/bin/env bash
set -euo pipefail

STUB_DIR="${1:-secrets/ci-stub-for-flake}"
mkdir -p "$STUB_DIR"

grep -r '\${nix-secrets}' home/ hosts/ secrets/ modules/ 2> /dev/null |
  sed -n 's/.*\${nix-secrets}\/\([^"'"'"'; ]*\).*/\1/p' | sort -u | while read -r p; do
  mkdir -p "$STUB_DIR/$(dirname "$p")"
  touch "$STUB_DIR/$p"
done

echo "Generated stubs in $STUB_DIR:"
find "$STUB_DIR" -type f | sort
