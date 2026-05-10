#!/usr/bin/env bash
set -euo pipefail

VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian Vault}"
PROJECT="${OBSIDIAN_PROJECT:-mcp}"
PROJECT_DIR="$VAULT/10-Projects/$PROJECT"
REPO_PATH="${REPO_PATH:-/Users/rafaelpereirafreitas/Sites/mcp}"

required_dirs=(
  ".obsidian"
  "01-Dashboards"
  "10-Projects"
  "20-Architecture"
  "30-ADRs"
  "40-RFCs"
  "50-Runbooks"
  "60-Incidents"
  "70-Daily"
  "80-AI"
  "90-System"
  "90-Templates"
)

required_notes=(
  "Project Overview.md"
  "Pipeline.md"
  "Repo Snapshot.md"
  "Decision Log.md"
  "Runbook.md"
  "AI Agent Operating Model.md"
)

echo "== Obsidian vault validation =="
echo "Vault:   $VAULT"
echo "Project: $PROJECT"
echo

if [ ! -d "$VAULT" ]; then
  echo "MISS vault directory"
  exit 1
fi
echo "OK   vault directory exists"

for dir in "${required_dirs[@]}"; do
  if [ -d "$VAULT/$dir" ]; then
    echo "OK   $dir"
  else
    echo "MISS $dir"
    exit 1
  fi
done

echo
echo "== Project notes =="
if [ ! -d "$PROJECT_DIR" ]; then
  echo "MISS project directory: $PROJECT_DIR"
  exit 1
fi

for note in "${required_notes[@]}"; do
  if [ -f "$PROJECT_DIR/$note" ]; then
    echo "OK   $note"
  else
    echo "MISS $note"
    exit 1
  fi
done

echo
echo "== Repo snapshot =="
if rg -F "$REPO_PATH" "$PROJECT_DIR/Repo Snapshot.md" >/dev/null; then
  echo "OK   repo path found in Repo Snapshot"
else
  echo "MISS repo path in Repo Snapshot: $REPO_PATH"
  exit 1
fi

if rg -n '^type: project$|^type: repo-snapshot$|^type: runbook$|^type: decision-log$' "$PROJECT_DIR"/*.md >/dev/null; then
  echo "OK   note properties detected"
else
  echo "MISS expected note properties"
  exit 1
fi

echo
echo "Obsidian vault validation completed."
