#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.cursor/mcp.json"

echo "== Cursor MCP validation =="
echo "Config: $CONFIG"
echo

if [ ! -f "$CONFIG" ]; then
  echo "MISS Cursor MCP config"
  exit 1
fi

jq . "$CONFIG" >/dev/null
echo "OK   valid JSON"
echo

required=(MCP_DOCKER openaiDeveloperDocs playwright jetbrains)
optional=(GitKraken)

echo "== Required servers =="
for name in "${required[@]}"; do
  if jq -e --arg name "$name" '.mcpServers[$name] != null' "$CONFIG" >/dev/null; then
    echo "OK   $name"
  else
    echo "MISS $name"
  fi
done
echo

echo "== Optional servers =="
for name in "${optional[@]}"; do
  if jq -e --arg name "$name" '.mcpServers[$name] != null' "$CONFIG" >/dev/null; then
    echo "OK   $name"
  else
    echo "SKIP $name"
  fi
done
echo

echo "== Commands =="
for cmd in cursor docker npx; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK   $cmd: $(command -v "$cmd")"
  else
    echo "MISS $cmd"
  fi
done

if command -v cursor-agent >/dev/null 2>&1; then
  echo "OK   cursor-agent: $(command -v cursor-agent)"
else
  echo "INFO cursor-agent not found in PATH; Cursor.app and cursor CLI can still use MCP config."
fi

