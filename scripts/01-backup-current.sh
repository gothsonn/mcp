#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

copy_if_exists() {
  local src="$1"
  local name="$2"
  if [ -f "$src" ]; then
    cp "$src" "$BACKUP_DIR/$name"
    echo "BACKUP $src -> $BACKUP_DIR/$name"
  else
    echo "SKIP   $src"
  fi
}

copy_if_exists "$HOME/.codex/config.toml" "codex-config.toml"
copy_if_exists "$HOME/.codex/AGENTS.md" "codex-AGENTS.md"
copy_if_exists "$HOME/.codex/RTK.md" "codex-RTK.md"
copy_if_exists "$HOME/.cursor/mcp.json" "cursor-mcp.json"
copy_if_exists "$HOME/.gemini/antigravity/mcp_config.json" "antigravity-mcp_config.json"

JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"
if [ -d "$JETBRAINS_DIR" ]; then
  find "$JETBRAINS_DIR" -maxdepth 4 -name 'llm.mcpServers.xml' -print0 2>/dev/null | while IFS= read -r -d '' file; do
    safe_name="$(echo "$file" | sed "s#^$HOME/##; s#[ /]#_#g")"
    cp "$file" "$BACKUP_DIR/$safe_name"
    echo "BACKUP $file -> $BACKUP_DIR/$safe_name"
  done
fi

echo
echo "Backup directory: $BACKUP_DIR"
