#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT_DIR/mcp-control/src/server.js"
CURSOR_CONFIG="$HOME/.cursor/mcp.json"
ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"

echo "== Global MCP Control validation =="
echo "Server: $SERVER"
echo

test -f "$SERVER"
node --check "$SERVER"

echo "== Codex =="
codex mcp get mcp-control

echo
echo "== Cursor =="
jq -e '.mcpServers["mcp-control"].command == "zsh"' "$CURSOR_CONFIG" >/dev/null
jq '.mcpServers["mcp-control"]' "$CURSOR_CONFIG"

echo
echo "== Antigravity =="
jq -e '.mcpServers["mcp-control"].command == "zsh"' "$ANTIGRAVITY_CONFIG" >/dev/null
jq '.mcpServers["mcp-control"]' "$ANTIGRAVITY_CONFIG"

echo
echo "== MCP protocol smoke test =="
printf '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}\n' | node "$SERVER" | sed -n '1,40p'

echo
echo "Global MCP Control validation completed."
