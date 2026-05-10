#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
PROFILE="${PROFILE:-empty}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$HOME/.gemini/antigravity/mcp_config.json"

case "$PROFILE" in
  empty)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.json.example"
    ;;
  gateway-frontend)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.gateway-frontend.example.json"
    ;;
  gateway-frontend-stdio)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.gateway-frontend-stdio.example.json"
    ;;
  gateway-backend-stdio)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.gateway-backend-stdio.example.json"
    ;;
  gateway-product-architecture-stdio)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.gateway-product-architecture-stdio.example.json"
    ;;
  gateway-database-readonly-stdio)
    TEMPLATE="$ROOT_DIR/templates/antigravity/mcp_config.gateway-database-readonly-stdio.example.json"
    ;;
  *)
    echo "Unknown PROFILE=$PROFILE"
    echo "Allowed: empty, gateway-frontend, gateway-frontend-stdio, gateway-backend-stdio, gateway-product-architecture-stdio, gateway-database-readonly-stdio"
    exit 1
    ;;
esac

mkdir -p "$(dirname "$TARGET")"

echo "== Antigravity MCP configuration =="
echo "Profile:  $PROFILE"
echo "Template: $TEMPLATE"
echo "Target:   $TARGET"
echo "APPLY=$APPLY"
echo

if [ "$APPLY" != "1" ]; then
  echo "DRY-RUN only. To write template to target, run:"
  echo "APPLY=1 PROFILE=$PROFILE $0"
  exit 0
fi

if [ -f "$TARGET" ]; then
  backup="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$TARGET" "$backup"
  echo "Backup created: $backup"
fi

cp "$TEMPLATE" "$TARGET"
jq . "$TARGET" >/dev/null
echo "Wrote valid JSON to $TARGET"
