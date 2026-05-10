#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT_DIR/mcp-control/src/server.js"
CURSOR_CONFIG="$HOME/.cursor/mcp.json"
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
  echo "DRY-RUN only. To configure Codex, Cursor and Antigravity:"
  echo "APPLY=1 $0"
  exit 0
fi

if ! codex mcp get mcp-control >/dev/null 2>&1; then
  codex mcp add mcp-control -- node "$SERVER"
else
  echo "Codex mcp-control already configured"
fi

mkdir -p "$(dirname "$CURSOR_CONFIG")"
if [ ! -f "$CURSOR_CONFIG" ]; then
  printf '{"mcpServers":{}}\n' > "$CURSOR_CONFIG"
fi

tmp="$(mktemp)"
jq --arg server "$SERVER" '
  .mcpServers["mcp-control"] = {
    "command": "node",
    "args": [$server]
  }
' "$CURSOR_CONFIG" > "$tmp"
mv "$tmp" "$CURSOR_CONFIG"
jq . "$CURSOR_CONFIG" >/dev/null
echo "Cursor mcp-control configured"

mkdir -p "$(dirname "$ANTIGRAVITY_CONFIG")"
if [ ! -f "$ANTIGRAVITY_CONFIG" ]; then
  printf '{"mcpServers":{}}\n' > "$ANTIGRAVITY_CONFIG"
fi

tmp="$(mktemp)"
jq --arg server "$SERVER" '
  .mcpServers["mcp-control"] = {
    "command": "node",
    "args": [$server]
  }
' "$ANTIGRAVITY_CONFIG" > "$tmp"
mv "$tmp" "$ANTIGRAVITY_CONFIG"
jq . "$ANTIGRAVITY_CONFIG" >/dev/null
echo "Antigravity mcp-control configured"
