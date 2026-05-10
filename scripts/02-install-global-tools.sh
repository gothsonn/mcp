#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"

run_or_show() {
  if [ "$APPLY" = "1" ]; then
    echo "+ $*"
    "$@"
  else
    echo "DRY-RUN: $*"
  fi
}

echo "== Global tools =="
echo "APPLY=$APPLY"
echo

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install Homebrew manually first: https://brew.sh"
  exit 1
fi

if ! command -v rtk >/dev/null 2>&1; then
  run_or_show brew install rtk
else
  echo "OK rtk already installed: $(command -v rtk)"
fi

if command -v rtk >/dev/null 2>&1; then
  rtk --version || true
fi

echo
echo "Next manual checks:"
echo "- Docker Desktop installed and running"
echo "- Codex installed and authenticated"
echo "- Cursor installed and authenticated"
echo "- Antigravity installed and authenticated"
echo "- IntelliJ IDEA installed with JetBrains AI/MCP Server"

