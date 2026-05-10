#!/usr/bin/env bash
set -euo pipefail

echo "== JetBrains MCP validation =="
echo "Home: $HOME"
echo

JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"

if [ ! -d "$JETBRAINS_DIR" ]; then
  echo "MISS JetBrains config directory: $JETBRAINS_DIR"
  exit 1
fi

echo "== IDE apps =="
for app in "IntelliJ IDEA.app" "WebStorm.app" "DataGrip.app" "Rider.app"; do
  if [ -d "/Applications/$app" ]; then
    echo "OK   /Applications/$app"
  elif [ -d "$HOME/Applications/$app" ]; then
    echo "OK   $HOME/Applications/$app"
  else
    echo "MISS $app"
  fi
done
echo

echo "== MCP Server plugin directories =="
find "$JETBRAINS_DIR" -maxdepth 3 -type d -name 'mcpserver' -print 2>/dev/null | sort || true
echo

echo "== MCP server settings =="
found_settings=0
enabled_settings=0
while IFS= read -r file; do
  found_settings=$((found_settings + 1))
  echo "-- $file"
  if grep -q 'name" value="google-ai-mcp-local"' "$file"; then
    echo "   google-ai-mcp-local: present"
  else
    echo "   google-ai-mcp-local: missing"
  fi
  if grep -q 'enabled" value="true"' "$file"; then
    enabled_settings=$((enabled_settings + 1))
    echo "   enabled: true"
  else
    echo "   enabled: false or absent"
  fi
done < <(find "$JETBRAINS_DIR" -maxdepth 4 -path '*/options/llm.mcpServers.xml' -type f -print 2>/dev/null | sort)

if [ "$found_settings" -eq 0 ]; then
  echo "MISS no llm.mcpServers.xml files found"
fi
echo

echo "== External client configuration =="
if command -v codex >/dev/null 2>&1; then
  if codex mcp list | grep -qi 'jetbrains\|idea\|intellij'; then
    echo "OK   Codex has a JetBrains/IntelliJ MCP entry"
    codex mcp get jetbrains 2>/dev/null | sed 's/^/     /' || true
  else
    echo "MISS Codex JetBrains MCP entry"
    echo "     Use IntelliJ IDEA: Settings | Tools | MCP Server | Auto-Configure for Codex"
    echo "     Or run: codex mcp add jetbrains -- npx -y @jetbrains/mcp-proxy"
  fi
else
  echo "MISS codex command"
fi

if [ -f "$HOME/.cursor/mcp.json" ]; then
  if grep -qi 'jetbrains\|idea\|intellij' "$HOME/.cursor/mcp.json"; then
    echo "OK   Cursor has a JetBrains/IntelliJ MCP entry"
  else
    echo "MISS Cursor JetBrains MCP entry"
    echo "     Configure later in the Cursor phase if useful"
  fi
else
  echo "MISS Cursor MCP config"
fi
echo

if [ "$enabled_settings" -gt 0 ]; then
  echo "RESULT JetBrains MCP Server appears enabled in at least one IDE config."
else
  echo "RESULT JetBrains MCP Server not enabled in detected configs."
  exit 2
fi
