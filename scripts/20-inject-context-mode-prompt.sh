#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
UPDATE_OBSIDIAN="${UPDATE_OBSIDIAN:-1}"
UPDATE_PROMPT="${UPDATE_PROMPT:-1}"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian Vault}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT_DIR/templates/context-mode/CONTEXT_MODE_PROMPT.md"

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

if [ ! -f "$TEMPLATE" ]; then
  echo "MISS template: $TEMPLATE"
  exit 2
fi

repo_name="$(basename "$REPO")"
context_file="$REPO/CONTEXT_MODE_PROMPT.md"
obsidian_note="$OBSIDIAN_VAULT/10-Projects/$repo_name/Context Mode.md"
timestamp="$(date '+%F %H:%M:%S %z')"
today="$(date +%F)"

agent_files=(
  "$REPO/AGENTS.md"
  "$REPO/GEMINI.md"
  "$REPO/CLAUDE.md"
)

echo "== Inject context-mode prompt =="
echo "Repo:            $REPO"
echo "APPLY:           $APPLY"
echo "Template:        $TEMPLATE"
echo "Prompt file:     $context_file"
echo "UPDATE_OBSIDIAN: $UPDATE_OBSIDIAN"
echo "UPDATE_PROMPT:   $UPDATE_PROMPT"
echo

if [ "$APPLY" != "1" ]; then
  echo "DRY  would copy $TEMPLATE to $context_file"
  for file in "${agent_files[@]}"; do
    reference="@./CONTEXT_MODE_PROMPT.md"
    if [ -f "$file" ]; then
      if grep -Fxq "$reference" "$file"; then
        echo "DRY  $(basename "$file") already references $reference"
      else
        echo "DRY  would append $reference to $(basename "$file")"
      fi
    else
      echo "DRY  would create $(basename "$file") with $reference"
    fi
  done
  if [ "$UPDATE_OBSIDIAN" = "1" ]; then
    echo "DRY  would update $obsidian_note"
  fi
  echo
  echo "No changes were made. Re-run with APPLY=1 after reviewing the plan."
  exit 0
fi

if [ -f "$context_file" ]; then
  if cmp -s "$TEMPLATE" "$context_file"; then
    echo "KEEP $context_file"
  elif [ "$UPDATE_PROMPT" = "1" ]; then
    cp "$context_file" "$context_file.bak-context-mode-$(date +%Y%m%d-%H%M%S)"
    cp "$TEMPLATE" "$context_file"
    echo "UPDATE $context_file"
  else
    echo "KEEP $context_file differs from template"
  fi
else
  cp "$TEMPLATE" "$context_file"
  echo "COPY $context_file"
fi

for file in "${agent_files[@]}"; do
  reference="@./CONTEXT_MODE_PROMPT.md"
  if [ -f "$file" ]; then
    if grep -Fxq "$reference" "$file"; then
      echo "KEEP $file already references $reference"
    else
      printf '\n%s\n' "$reference" >> "$file"
      echo "UPDATE $file"
    fi
  else
    printf '%s\n' "$reference" > "$file"
    echo "CREATE $file"
  fi
done

if [ "$UPDATE_OBSIDIAN" = "1" ]; then
  if [ -d "$OBSIDIAN_VAULT" ]; then
    mkdir -p "$(dirname "$obsidian_note")"
    if [ -f "$obsidian_note" ]; then
      cat >> "$obsidian_note" <<EOF_NOTE

## Prompt injection - $timestamp

- Prompt automatico do context-mode aplicado no repositorio: \`$REPO\`.
- Arquivo comum: \`CONTEXT_MODE_PROMPT.md\`.
- Entradas atualizadas: \`AGENTS.md\`, \`GEMINI.md\`, \`CLAUDE.md\`.
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
  - antigravity
  - claude
  - context-mode
---

# Context Mode

## Status

Prompt automatico do context-mode aplicado no repositorio.

## Repository

\`\`\`text
$REPO
\`\`\`

## Files

- \`CONTEXT_MODE_PROMPT.md\`
- \`AGENTS.md\`
- \`GEMINI.md\`
- \`CLAUDE.md\`
EOF_NOTE
    fi
    echo "OBSIDIAN $obsidian_note"
  else
    echo "SKIP Obsidian vault not found: $OBSIDIAN_VAULT"
  fi
fi

echo
echo "Prompt injection completed."
