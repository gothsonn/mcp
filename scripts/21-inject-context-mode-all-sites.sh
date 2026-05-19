#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
SITES_ROOT="${SITES_ROOT:-$HOME/Sites}"
MCP_REPO="${MCP_REPO:-$HOME/Sites/mcp}"
INCLUDE_MCP_REPO="${INCLUDE_MCP_REPO:-1}"

if [ ! -d "$SITES_ROOT" ]; then
  echo "MISS sites root: $SITES_ROOT"
  exit 2
fi

script="$MCP_REPO/scripts/20-inject-context-mode-prompt.sh"
if [ ! -x "$script" ]; then
  echo "MISS script: $script"
  exit 2
fi

tmp_repos="$(mktemp)"
trap 'rm -f "$tmp_repos"' EXIT

find "$SITES_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -print > "$tmp_repos"
find "$SITES_ROOT" \
  -path '*/node_modules' -prune -o \
  -path '*/vendor' -prune -o \
  -path '*/.git' -type d -print \
  | sed 's#/.git$##' >> "$tmp_repos"
sort -u "$tmp_repos" -o "$tmp_repos"

echo "== Inject context-mode prompt into all Sites projects =="
echo "SITES_ROOT=$SITES_ROOT"
echo "APPLY=$APPLY"
echo "INCLUDE_MCP_REPO=$INCLUDE_MCP_REPO"
echo

count=0
ok=0
fail=0

while IFS= read -r repo; do
  [ -d "$repo" ] || continue
  case "$(basename "$repo")" in
    .* ) continue ;;
  esac
  if [ "$INCLUDE_MCP_REPO" != "1" ] && [ "$(cd "$repo" && pwd)" = "$(cd "$MCP_REPO" && pwd)" ]; then
    echo "SKIP $repo"
    continue
  fi

  count=$((count + 1))
  echo "-- $repo"
  if TARGET_REPO="$repo" APPLY="$APPLY" "$script"; then
    ok=$((ok + 1))
  else
    fail=$((fail + 1))
    echo "FAIL $repo"
  fi
  echo
done < "$tmp_repos"

echo "== Summary =="
echo "count=$count"
echo "ok=$ok"
echo "fail=$fail"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
