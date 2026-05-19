#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
CONFIGURE_ANTIGRAVITY="${CONFIGURE_ANTIGRAVITY:-1}"
CONFIGURE_CLAUDE_UI="${CONFIGURE_CLAUDE_UI:-1}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT_DIR/context-router/src/server.js"
SERVER_COMMAND='exec node "$HOME/Sites/mcp/context-router/src/server.js"'
ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "$file.bak-context-router-$(date +%Y%m%d-%H%M%S)"
  fi
}

write_context_router() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  if [ ! -f "$file" ]; then
    printf '{"mcpServers":{}}\n' > "$file"
  fi
  backup_file "$file"
  tmp="$(mktemp)"
  jq --arg serverCommand "$SERVER_COMMAND" '
    .mcpServers["context-router"] = {
      "command": "zsh",
      "args": ["-lc", $serverCommand]
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
  jq . "$file" >/dev/null
}

echo "== Configure context-router =="
echo "APPLY=$APPLY"
echo "Server: $SERVER"
echo "CONFIGURE_ANTIGRAVITY=$CONFIGURE_ANTIGRAVITY"
echo "CONFIGURE_CLAUDE_UI=$CONFIGURE_CLAUDE_UI"
echo

if [ ! -f "$SERVER" ]; then
  echo "MISS server file: $SERVER"
  exit 2
fi

if [ "$APPLY" != "1" ]; then
  [ "$CONFIGURE_ANTIGRAVITY" = "1" ] && echo "DRY  would add context-router to $ANTIGRAVITY_CONFIG"
  [ "$CONFIGURE_CLAUDE_UI" = "1" ] && echo "DRY  would add context-router to $CLAUDE_DESKTOP_CONFIG"
  echo
  echo "No changes were made. Re-run with APPLY=1 after reviewing the plan."
  exit 0
fi

if [ "$CONFIGURE_ANTIGRAVITY" = "1" ]; then
  write_context_router "$ANTIGRAVITY_CONFIG"
  echo "OK   Antigravity context-router configured"
fi

if [ "$CONFIGURE_CLAUDE_UI" = "1" ]; then
  write_context_router "$CLAUDE_DESKTOP_CONFIG"
  echo "OK   Claude UI context-router configured"
fi

echo
echo "Validation commands:"
echo "- jq '.mcpServers[\"context-router\"]' \"$ANTIGRAVITY_CONFIG\""
echo "- jq '.mcpServers[\"context-router\"]' \"$CLAUDE_DESKTOP_CONFIG\""
