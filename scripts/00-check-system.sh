#!/usr/bin/env bash
set -euo pipefail

echo "== MCP / IDE setup system check =="
echo "Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "User: $(id -un)"
echo "Home: $HOME"
echo

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "OK   %-18s %s\n" "$cmd" "$(command -v "$cmd")"
  else
    printf "MISS %-18s\n" "$cmd"
  fi
}

echo "== Commands =="
for cmd in git brew node npm npx python3 pip3 docker jq codex cursor-agent rtk; do
  check_cmd "$cmd"
done
echo

echo "== Versions =="
for cmd in git node npm python3 docker jq codex rtk; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "-- $cmd"
    "$cmd" --version 2>/dev/null || true
  fi
done
echo

echo "== Config files =="
for path in \
  "$HOME/.codex/config.toml" \
  "$HOME/.cursor/mcp.json" \
  "$HOME/.gemini/antigravity/mcp_config.json"; do
  if [ -f "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
  fi
done
echo

echo "== JetBrains MCP files =="
find "$HOME/Library/Application Support/JetBrains" -maxdepth 4 -name 'llm.mcpServers.xml' -print 2>/dev/null || true
echo

echo "== Sites repos/manifests =="
find "$HOME/Sites" -maxdepth 3 -type f \( \
  -name package.json -o \
  -name pom.xml -o \
  -name requirements.txt -o \
  -name pyproject.toml -o \
  -name composer.json -o \
  -name angular.json \
\) -print 2>/dev/null | sort || true

