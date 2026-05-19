#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
CONFIGURE_ANTIGRAVITY="${CONFIGURE_ANTIGRAVITY:-1}"
CONFIGURE_CURSOR="${CONFIGURE_CURSOR:-1}"
CONFIGURE_CLAUDE="${CONFIGURE_CLAUDE:-1}"

ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
CURSOR_MCP_CONFIG="$HOME/.cursor/mcp.json"
CURSOR_HOOKS_CONFIG="$HOME/.cursor/hooks.json"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_CONTEXT_MD="$HOME/.claude/CLAUDE.context-mode.md"

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "$file.bak-context-mode-$(date +%Y%m%d-%H%M%S)"
  fi
}

write_json() {
  local file="$1"
  local jq_filter="$2"
  mkdir -p "$(dirname "$file")"
  if [ ! -f "$file" ]; then
    printf '{"mcpServers":{}}\n' > "$file"
  fi
  backup_file "$file"
  tmp="$(mktemp)"
  jq "$jq_filter" "$file" > "$tmp"
  mv "$tmp" "$file"
  jq . "$file" >/dev/null
}

context_mode_pkg_dir() {
  local bin real
  bin="$(command -v context-mode)"
  real="$(realpath "$bin" 2>/dev/null || printf '%s' "$bin")"
  dirname "$real"
}

echo "== Configure context-mode clients =="
echo "APPLY=$APPLY"
echo "CONFIGURE_ANTIGRAVITY=$CONFIGURE_ANTIGRAVITY"
echo "CONFIGURE_CURSOR=$CONFIGURE_CURSOR"
echo "CONFIGURE_CLAUDE=$CONFIGURE_CLAUDE"
echo

if ! command -v context-mode >/dev/null 2>&1; then
  echo "MISS context-mode command not found"
  echo "Install first: npm install -g context-mode"
  exit 2
fi

pkg_dir="$(context_mode_pkg_dir)"

if [ "$APPLY" != "1" ]; then
  [ "$CONFIGURE_ANTIGRAVITY" = "1" ] && echo "DRY  would add context-mode MCP to $ANTIGRAVITY_CONFIG"
  [ "$CONFIGURE_CURSOR" = "1" ] && echo "DRY  would add context-mode MCP and hooks to $CURSOR_MCP_CONFIG and $CURSOR_HOOKS_CONFIG"
  [ "$CONFIGURE_CLAUDE" = "1" ] && echo "DRY  would add context-mode Claude rules/hooks under $HOME/.claude"
  if command -v claude >/dev/null 2>&1; then
    echo "DRY  would run: claude mcp add context-mode -- context-mode"
  else
    echo "DRY  claude command not found; would prepare files only"
  fi
  echo
  echo "No changes were made. Re-run with APPLY=1 after reviewing the plan."
  exit 0
fi

if [ "$CONFIGURE_ANTIGRAVITY" = "1" ]; then
  write_json "$ANTIGRAVITY_CONFIG" '.mcpServers["context-mode"] = {"command":"context-mode"}'
  echo "OK   Antigravity context-mode MCP configured"
fi

if [ "$CONFIGURE_CURSOR" = "1" ]; then
  write_json "$CURSOR_MCP_CONFIG" '.mcpServers["context-mode"] = {"command":"context-mode"}'
  mkdir -p "$(dirname "$CURSOR_HOOKS_CONFIG")"
  backup_file "$CURSOR_HOOKS_CONFIG"
  cp "$pkg_dir/configs/cursor/hooks.json" "$CURSOR_HOOKS_CONFIG"
  jq . "$CURSOR_HOOKS_CONFIG" >/dev/null
  echo "OK   Cursor context-mode MCP and hooks configured"
fi

if [ "$CONFIGURE_CLAUDE" = "1" ]; then
  mkdir -p "$HOME/.claude"
  backup_file "$CLAUDE_SETTINGS"
  cat > "$CLAUDE_SETTINGS" <<'EOF_SETTINGS'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Read|Grep|WebFetch|mcp__",
        "hooks": [
          {
            "type": "command",
            "command": "context-mode hook claude-code pretooluse"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Read|Write|Edit|NotebookEdit|Glob|Grep|TodoWrite|TaskCreate|TaskUpdate|EnterPlanMode|ExitPlanMode|Skill|Agent|AskUserQuestion|EnterWorktree|mcp__",
        "hooks": [
          {
            "type": "command",
            "command": "context-mode hook claude-code posttooluse"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "context-mode hook claude-code precompact"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "context-mode hook claude-code userpromptsubmit"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "context-mode hook claude-code sessionstart"
          }
        ]
      }
    ]
  }
}
EOF_SETTINGS
  jq . "$CLAUDE_SETTINGS" >/dev/null

  cp "$pkg_dir/configs/claude-code/CLAUDE.md" "$CLAUDE_CONTEXT_MD"
  if [ ! -f "$CLAUDE_MD" ]; then
    printf '@CLAUDE.context-mode.md\n' > "$CLAUDE_MD"
  elif ! grep -Fxq '@CLAUDE.context-mode.md' "$CLAUDE_MD"; then
    backup_file "$CLAUDE_MD"
    tmp="$(mktemp)"
    {
      printf '@CLAUDE.context-mode.md\n\n'
      cat "$CLAUDE_MD"
    } > "$tmp"
    mv "$tmp" "$CLAUDE_MD"
  fi

  if command -v claude >/dev/null 2>&1; then
    if claude mcp get context-mode >/dev/null 2>&1; then
      claude mcp remove context-mode
    fi
    claude mcp add context-mode -- context-mode
    echo "OK   Claude context-mode MCP configured"
  else
    echo "WARN claude command not found; Claude files/hooks prepared, MCP CLI registration skipped"
  fi
fi

echo
echo "Validation commands:"
echo "- context-mode doctor"
echo "- jq '.mcpServers[\"context-mode\"]' \"$ANTIGRAVITY_CONFIG\""
echo "- jq '.mcpServers[\"context-mode\"]' \"$CURSOR_MCP_CONFIG\""
