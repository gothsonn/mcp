#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
MCP_REPO="${MCP_REPO:-$HOME/Sites/mcp}"
VENV_DIR="${MARKDOWN_CONVERTER_VENV:-$HOME/.context-mode-kit/markdown-converter-venv}"
PACKAGE_DIR="$MCP_REPO/markdown-converter"

echo "== Install markdown converter MCP =="
echo "APPLY=$APPLY"
echo "PACKAGE_DIR=$PACKAGE_DIR"
echo "VENV_DIR=$VENV_DIR"
echo

if [ ! -d "$PACKAGE_DIR" ]; then
  echo "MISS package dir: $PACKAGE_DIR"
  exit 2
fi

if [ "$APPLY" != "1" ]; then
  echo "DRY  would run npm install in $PACKAGE_DIR"
  echo "DRY  would create Python venv at $VENV_DIR"
  echo "DRY  would install unstructured and document extras"
  echo
  echo "No changes were made. Re-run with APPLY=1."
  exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "MISS npm"
  exit 2
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "MISS uv"
  exit 2
fi

npm install --prefix "$PACKAGE_DIR"

mkdir -p "$(dirname "$VENV_DIR")"
if [ ! -x "$VENV_DIR/bin/python" ]; then
  uv venv "$VENV_DIR"
else
  echo "KEEP existing venv: $VENV_DIR"
fi
uv pip install --python "$VENV_DIR/bin/python" --upgrade pip
uv pip install --python "$VENV_DIR/bin/python" \
  "unstructured[docx,pptx,xlsx,pdf]" \
  markdownify \
  lxml

echo
echo "== Validation =="
node --check "$PACKAGE_DIR/src/server.js"
"$VENV_DIR/bin/python" -m py_compile "$PACKAGE_DIR/worker/convert.py"

echo
echo "Markdown converter installed."
