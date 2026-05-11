#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
FEATURE_KEY="${FEATURE_KEY:-${2:-}}"
FEATURE_TITLE="${FEATURE_TITLE:-}"
FEATURE_SUMMARY="${FEATURE_SUMMARY:-}"
VALIDATION="${VALIDATION:-}"
PR_URL="${PR_URL:-}"
RUN_GRAPHIFY="${RUN_GRAPHIFY:-1}"
UPDATE_OBSIDIAN="${UPDATE_OBSIDIAN:-1}"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian Vault}"
MCP_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: TARGET_REPO=\$HOME/Sites/repo FEATURE_KEY=TXP-1175 APPLY=1 $0"
  exit 2
fi

REPO="$(cd "$TARGET_REPO" && pwd)"
case "$REPO" in
  "$HOME"/Sites/*) ;;
  *)
    echo "Refusing path outside \$HOME/Sites: $REPO"
    exit 2
    ;;
esac

repo_name="$(basename "$REPO")"
today="$(date +%F)"
timestamp="$(date '+%F %H:%M:%S %z')"
feature_label="${FEATURE_KEY:-feature}"
feature_file_label="$(printf '%s' "$feature_label" | tr '/: ' '---')"
project_dir="$OBSIDIAN_VAULT/10-Projects/$repo_name"
feature_note="$project_dir/Feature $feature_file_label.md"
decision_log="$project_dir/Decision Log.md"

echo "== Feature done =="
echo "Repo:            $REPO"
echo "Feature:         ${FEATURE_KEY:-not provided}"
echo "APPLY:           $APPLY"
echo "RUN_GRAPHIFY:    $RUN_GRAPHIFY"
echo "UPDATE_OBSIDIAN: $UPDATE_OBSIDIAN"
echo

graphify_status="not-run"
if [ "$RUN_GRAPHIFY" = "1" ]; then
  echo "== Graphify refresh =="
  if ! command -v graphify >/dev/null 2>&1; then
    graphify_status="missing-command"
    echo "MISS graphify command not found"
  elif [ "$APPLY" != "1" ]; then
    graphify_status="dry-run"
    echo "DRY  would run: graphify extract . --backend gemini"
    echo "DRY  would run: graphify cluster-only ."
  else
    (
      cd "$REPO"
      graphify extract . --backend gemini
      graphify cluster-only .
    )
    graphify_status="updated"
    echo "OK   graphify updated"
  fi
fi

if [ "$UPDATE_OBSIDIAN" = "1" ]; then
  echo
  echo "== Obsidian update =="
  if [ "$APPLY" != "1" ]; then
    echo "DRY  would update $feature_note"
    echo "DRY  would append $decision_log"
  else
    mkdir -p "$project_dir"
    if [ ! -f "$feature_note" ]; then
      cat > "$feature_note" <<EOF_NOTE
---
type: feature-completion
project: $repo_name
feature: ${FEATURE_KEY:-}
updated_at: $today
tags:
  - feature
  - delivery
---

# ${FEATURE_KEY:-Feature} ${FEATURE_TITLE}

## Summary

${FEATURE_SUMMARY:-Pending summary.}

## Validation

${VALIDATION:-Pending validation notes.}

## Pull Request

${PR_URL:-Pending PR link.}

## Repository

\`\`\`text
$REPO
\`\`\`

## Graphify

$graphify_status at $timestamp.
EOF_NOTE
    else
      cat >> "$feature_note" <<EOF_NOTE

## Update - $timestamp

- Summary: ${FEATURE_SUMMARY:-Pending summary.}
- Validation: ${VALIDATION:-Pending validation notes.}
- Pull Request: ${PR_URL:-Pending PR link.}
- Graphify: $graphify_status.
EOF_NOTE
    fi

    if [ -f "$decision_log" ]; then
      printf '%s\n' "- $today: Feature ${FEATURE_KEY:-unknown} finalized; Obsidian updated; Graphify status: $graphify_status." >> "$decision_log"
    else
      cat > "$decision_log" <<EOF_LOG
---
type: decision-log
project: $repo_name
updated_at: $today
tags:
  - decision-log
---

# Decision Log

## Entries

- $today: Feature ${FEATURE_KEY:-unknown} finalized; Obsidian updated; Graphify status: $graphify_status.
EOF_LOG
    fi
    echo "OK   updated $feature_note"
    echo "OK   updated $decision_log"
  fi
fi

echo
echo "== Validation =="
if [ "$APPLY" = "1" ]; then
  OBSIDIAN_PROJECT="$repo_name" REPO_PATH="$REPO" "$MCP_REPO/scripts/09-validate-obsidian-vault.sh"
else
  echo "DRY  would validate Obsidian project $repo_name"
fi

echo
echo "Feature done workflow completed."
