#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEXER="$ROOT_DIR/scripts/lib/context-mode-index-repo.mjs"

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: TARGET_REPO=\$HOME/Sites/repo APPLY=1 $0"
  exit 2
fi

if ! command -v context-mode >/dev/null 2>&1; then
  echo "MISS context-mode command not found"
  exit 2
fi

if [ ! -f "$INDEXER" ]; then
  echo "MISS indexer: $INDEXER"
  exit 2
fi

TARGET_REPO="$TARGET_REPO" APPLY="$APPLY" node "$INDEXER"
