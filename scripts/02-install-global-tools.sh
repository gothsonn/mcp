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

configure_public_npm_user_registry() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "SKIP npm user registry: npm not found yet"
    return
  fi

  local user_npmrc
  user_npmrc="$(npm config get userconfig)"

  if [ "$APPLY" != "1" ]; then
    echo "DRY-RUN: backup and sanitize ${user_npmrc/#$HOME/\$HOME}"
    echo "DRY-RUN: npm config set registry https://registry.npmjs.org/ --location=user"
    echo "DRY-RUN: npm config delete strict-ssl --location=user"
    echo "DRY-RUN: npm config set fund false --location=user"
    echo "DRY-RUN: npm config set audit true --location=user"
    return
  fi

  if [ -f "$user_npmrc" ]; then
    cp "$user_npmrc" "$user_npmrc.bak-$(date +%Y%m%d-%H%M%S)"
    local tmp_npmrc
    tmp_npmrc="$(mktemp)"
    awk '
      BEGIN { IGNORECASE = 1 }
      /^registry=.*codeartifact/ { next }
      /codeartifact/ && /_authToken/ { next }
      /^strict-ssl=false$/ { next }
      /^always-auth=/ { next }
      { print }
    ' "$user_npmrc" > "$tmp_npmrc"
    mv "$tmp_npmrc" "$user_npmrc"
  fi

  npm config set registry https://registry.npmjs.org/ --location=user
  npm config delete strict-ssl --location=user >/dev/null 2>&1 || true
  npm config set fund false --location=user
  npm config set audit true --location=user
}

echo "== Prerequisites and global tools =="
echo "APPLY=$APPLY"
echo

if ! command -v brew >/dev/null 2>&1; then
  if [ "$APPLY" = "1" ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "DRY-RUN: install Homebrew from https://brew.sh"
    echo "Homebrew is required before installing the rest automatically."
    exit 0
  fi
fi

has_app() {
  local app="$1"
  [ -d "/Applications/$app" ] || [ -d "$HOME/Applications/$app" ]
}

install_formula_if_missing() {
  local command_name="$1"
  local formula_name="$2"
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "OK formula command $command_name: $(command -v "$command_name")"
  else
    run_or_show brew install "$formula_name"
  fi
}

install_cask_if_missing() {
  local app_name="$1"
  local cask_name="$2"
  local command_name="${3:-}"

  if has_app "$app_name"; then
    echo "OK app $app_name"
    return
  fi

  if [ -n "$command_name" ] && command -v "$command_name" >/dev/null 2>&1; then
    echo "OK command $command_name: $(command -v "$command_name")"
    return
  fi

  run_or_show brew install --cask "$cask_name"
}

install_codex_cli() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "SKIP Codex CLI: npm not found"
    return
  fi

  if [ "$APPLY" = "1" ]; then
    echo "+ npm install -g @openai/codex@latest"
    NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ \
      npm_config_registry=https://registry.npmjs.org/ \
      npm_config_always_auth=false \
      npm install -g @openai/codex@latest
  else
    echo "DRY-RUN: npm install -g @openai/codex@latest"
  fi
}

echo "== CLI prerequisites =="
install_formula_if_missing git git
install_formula_if_missing node node
install_formula_if_missing python3 python
install_formula_if_missing rg ripgrep

echo
echo "== Public npm registry for global tools =="
configure_public_npm_user_registry

echo
echo "== Codex CLI =="
install_codex_cli

echo
echo "== Desktop apps and agent CLIs =="
install_cask_if_missing "Docker.app" docker-desktop docker
install_cask_if_missing "IntelliJ IDEA.app" intellij-idea idea
install_cask_if_missing "Codex.app" codex codex
install_cask_if_missing "Antigravity.app" antigravity agy

echo
echo "== Optional global optimizer =="
install_formula_if_missing rtk rtk

echo
echo "== Versions after check/install =="
for cmd in git node npm python3 docker jq rg codex rtk agy idea; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "-- $cmd"
    "$cmd" --version 2>/dev/null || true
  fi
done

echo
echo "Next manual checks:"
echo "- Open Docker Desktop once and finish privileged helper setup"
echo "- Authenticate Codex"
echo "- Authenticate Antigravity"
echo "- Sign in to IntelliJ IDEA and confirm JetBrains AI/MCP Server"
