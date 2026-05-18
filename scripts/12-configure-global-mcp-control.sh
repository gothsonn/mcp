#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT_DIR/mcp-control/src/server.js"
SERVER_COMMAND='exec node "$HOME/Sites/mcp/mcp-control/src/server.js"'
ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"

echo "== Global MCP Control configuration =="
echo "Server: $SERVER"
echo "APPLY=$APPLY"
echo

if [ ! -f "$SERVER" ]; then
  echo "MISS server file: $SERVER"
  exit 1
fi

if [ "$APPLY" != "1" ]; then
  echo "DRY-RUN only. To configure Codex and Antigravity:"
  echo "APPLY=1 $0"
  exit 0
fi

if codex mcp get mcp-control >/dev/null 2>&1; then
  codex mcp remove mcp-control
fi
codex mcp add mcp-control -- zsh -lc "$SERVER_COMMAND"

mkdir -p "$(dirname "$ANTIGRAVITY_CONFIG")"
if [ ! -f "$ANTIGRAVITY_CONFIG" ]; then
  printf '{"mcpServers":{}}\n' > "$ANTIGRAVITY_CONFIG"
fi

tmp="$(mktemp)"
jq --arg serverCommand "$SERVER_COMMAND" '
  .mcpServers["mcp-control"] = {
    "command": "zsh",
    "args": ["-lc", $serverCommand]
  }
' "$ANTIGRAVITY_CONFIG" > "$tmp"
mv "$tmp" "$ANTIGRAVITY_CONFIG"
jq . "$ANTIGRAVITY_CONFIG" >/dev/null
echo "Antigravity mcp-control configured"
