#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT_DIR/templates/cursor/mcp.json.example"
TARGET="$HOME/.cursor/mcp.json"

mkdir -p "$HOME/.cursor"

echo "== Cursor MCP configuration =="
echo "Template: $TEMPLATE"
echo "Target:   $TARGET"
echo "APPLY=$APPLY"
echo

if [ "$APPLY" != "1" ]; then
  echo "DRY-RUN only. To write template to target, run:"
  echo "APPLY=1 $0"
  exit 0
fi

if [ -f "$TARGET" ]; then
  backup="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$TARGET" "$backup"
  echo "Backup created: $backup"
fi

cp "$TEMPLATE" "$TARGET"
jq . "$TARGET" >/dev/null
echo "Wrote valid JSON to $TARGET"

