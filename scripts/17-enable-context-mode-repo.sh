#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
UPDATE_OBSIDIAN="${UPDATE_OBSIDIAN:-1}"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian Vault}"
CONTEXT_MODE_SOURCE="${CONTEXT_MODE_SOURCE:-}"

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: TARGET_REPO=\$HOME/Sites/repo APPLY=1 $0"
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

if ! command -v context-mode >/dev/null 2>&1; then
  echo "MISS context-mode command not found"
  echo "Install first: npm install -g context-mode"
  exit 2
fi

if [ -z "$CONTEXT_MODE_SOURCE" ]; then
  context_mode_bin="$(command -v context-mode)"
  context_mode_real="$(realpath "$context_mode_bin" 2>/dev/null || printf '%s' "$context_mode_bin")"
  for candidate in \
    "$(dirname "$context_mode_real")/configs/codex/AGENTS.md" \
    "$(npm root -g)/context-mode/configs/codex/AGENTS.md" \
    "/opt/homebrew/lib/node_modules/context-mode/configs/codex/AGENTS.md"; do
    if [ -f "$candidate" ]; then
      CONTEXT_MODE_SOURCE="$candidate"
      break
    fi
  done
fi

if [ ! -f "$CONTEXT_MODE_SOURCE" ]; then
  echo "MISS context-mode Codex rules: $CONTEXT_MODE_SOURCE"
  exit 2
fi

repo_name="$(basename "$REPO")"
agents_file="$REPO/AGENTS.md"
context_file="$REPO/AGENTS.context-mode.md"
obsidian_note="$OBSIDIAN_VAULT/10-Projects/$repo_name/Context Mode.md"
reference='@./AGENTS.context-mode.md'
today="$(date +%F)"
timestamp="$(date '+%F %H:%M:%S %z')"

echo "== Enable context-mode for repository =="
echo "Repo:            $REPO"
echo "APPLY:           $APPLY"
echo "Source:          $CONTEXT_MODE_SOURCE"
echo "Rules file:      $context_file"
echo "AGENTS.md:       $agents_file"
echo "UPDATE_OBSIDIAN: $UPDATE_OBSIDIAN"
echo

if [ "$APPLY" != "1" ]; then
  echo "DRY  would copy context-mode Codex rules to $context_file"
  if [ -f "$agents_file" ]; then
    if grep -Fxq "$reference" "$agents_file"; then
      echo "DRY  AGENTS.md already references $reference"
    else
      echo "DRY  would append $reference to AGENTS.md"
    fi
  else
    echo "DRY  would create AGENTS.md with $reference"
  fi
  if [ "$UPDATE_OBSIDIAN" = "1" ]; then
    echo "DRY  would update $obsidian_note"
  fi
  echo
  echo "No changes were made. Re-run with APPLY=1 after reviewing the plan."
  exit 0
fi

if [ -f "$context_file" ]; then
  echo "KEEP $context_file"
else
  cp "$CONTEXT_MODE_SOURCE" "$context_file"
  echo "COPY $context_file"
fi

if [ -f "$agents_file" ]; then
  if grep -Fxq "$reference" "$agents_file"; then
    echo "KEEP $agents_file already references $reference"
  else
    printf '\n%s\n' "$reference" >> "$agents_file"
    echo "UPDATE $agents_file"
  fi
else
  printf '%s\n' "$reference" > "$agents_file"
  echo "CREATE $agents_file"
fi

if [ "$UPDATE_OBSIDIAN" = "1" ]; then
  if [ -d "$OBSIDIAN_VAULT" ]; then
    mkdir -p "$(dirname "$obsidian_note")"
    if [ -f "$obsidian_note" ]; then
      cat >> "$obsidian_note" <<EOF_NOTE

## Update - $timestamp

- context-mode habilitado para Codex no repositorio: \`$REPO\`.
- Regras locais: \`AGENTS.context-mode.md\`.
- Entrada do agente: \`AGENTS.md\`.
EOF_NOTE
    else
      cat > "$obsidian_note" <<EOF_NOTE
---
type: tool-configuration
project: $repo_name
tool: context-mode
updated_at: $today
tags:
  - codex
  - context-mode
  - mcp
---

# Context Mode

## Status

context-mode habilitado para Codex neste repositorio.

## Repository

\`\`\`text
$REPO
\`\`\`

## Files

- \`AGENTS.context-mode.md\`
- \`AGENTS.md\`

## Usage

- \`ctx doctor\`
- \`ctx stats\`
- Use context-mode para analisar saidas grandes sem despejar dados brutos no contexto.
EOF_NOTE
    fi
    echo "OBSIDIAN $obsidian_note"
  else
    echo "SKIP Obsidian vault not found: $OBSIDIAN_VAULT"
  fi
fi

echo
echo "Next checks:"
echo "- cd \"$REPO\""
echo "- context-mode doctor"
echo "- Ask Codex: ctx stats"
