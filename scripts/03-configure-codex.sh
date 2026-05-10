#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT_DIR/templates/codex/config.toml.example"
TARGET="$HOME/.codex/config.toml"

mkdir -p "$HOME/.codex"

echo "== Codex configuration =="
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
echo "Wrote $TARGET"
echo
echo "Now add MCPs one by one, starting with:"
echo "codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp"

