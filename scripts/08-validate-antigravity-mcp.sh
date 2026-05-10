#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
PROFILE="${PROFILE:-antigravity-frontend}"
MAX_TOOLS="${MAX_TOOLS:-100}"

case "$PROFILE" in
  antigravity-frontend)
    SERVER_KEY="gateway-frontend"
    ;;
  antigravity-backend)
    SERVER_KEY="gateway-backend"
    ;;
  antigravity-product-architecture)
    SERVER_KEY="gateway-product-architecture"
    ;;
  antigravity-database-readonly)
    SERVER_KEY="gateway-database-readonly"
    ;;
  *)
    SERVER_KEY="${SERVER_KEY:-gateway-frontend}"
    ;;
esac

echo "== Antigravity MCP validation =="
echo "Config:  $CONFIG"
echo "Profile: $PROFILE"
echo "Server:  $SERVER_KEY"
echo

if [ ! -f "$CONFIG" ]; then
  echo "MISS Antigravity MCP config"
  exit 1
fi

jq . "$CONFIG" >/dev/null
echo "OK   valid JSON"

if jq -e --arg key "$SERVER_KEY" '.mcpServers[$key] != null' "$CONFIG" >/dev/null; then
  echo "OK   $SERVER_KEY configured"
else
  echo "MISS $SERVER_KEY"
  exit 1
fi
echo

echo "== Docker MCP profile =="
profile_out="$(mktemp)"
profile_err="$(mktemp)"
trap 'rm -f "$profile_out" "$profile_err"' EXIT

if docker mcp profile show "$PROFILE" >"$profile_out" 2>"$profile_err"; then
  echo "OK   profile exists"
  rg -n 'name: (playwright|context7|sequentialthinking)$' "$profile_out" || true
else
  echo "MISS profile $PROFILE"
  cat "$profile_err"
  exit 1
fi
echo

echo "== Gateway dry-run =="
dry_run_output="$(docker mcp gateway run --profile "$PROFILE" --dry-run 2>&1)"
echo "$dry_run_output" | sed -n '1,220p'

tools_count="$(echo "$dry_run_output" | sed -n 's/.*> \([0-9][0-9]*\) tools listed.*/\1/p' | tail -1)"
if [ -z "$tools_count" ]; then
  echo "MISS could not determine tools count"
  exit 1
fi

if [ "$tools_count" -le "$MAX_TOOLS" ]; then
  echo "OK   tools count $tools_count <= $MAX_TOOLS"
else
  echo "FAIL tools count $tools_count > $MAX_TOOLS"
  exit 2
fi
