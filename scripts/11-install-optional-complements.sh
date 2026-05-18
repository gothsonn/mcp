#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
INSTALL_GRAPHIFY="${INSTALL_GRAPHIFY:-0}"
INSTALL_GRAPHIFY_PROJECT="${INSTALL_GRAPHIFY_PROJECT:-0}"
INSTALL_IMPECCABLE="${INSTALL_IMPECCABLE:-0}"
INSTALL_HUASHU="${INSTALL_HUASHU:-0}"
INSTALL_CAVEMAN_CODEX="${INSTALL_CAVEMAN_CODEX:-0}"
INSTALL_CAVEMAN_ANTIGRAVITY="${INSTALL_CAVEMAN_ANTIGRAVITY:-0}"
TARGET_REPO="${TARGET_REPO:-}"

echo "== Optional complements installer =="
echo "APPLY=$APPLY"
echo "INSTALL_GRAPHIFY=$INSTALL_GRAPHIFY"
echo "INSTALL_GRAPHIFY_PROJECT=$INSTALL_GRAPHIFY_PROJECT"
echo "INSTALL_IMPECCABLE=$INSTALL_IMPECCABLE"
echo "INSTALL_HUASHU=$INSTALL_HUASHU"
echo "INSTALL_CAVEMAN_CODEX=$INSTALL_CAVEMAN_CODEX"
echo "INSTALL_CAVEMAN_ANTIGRAVITY=$INSTALL_CAVEMAN_ANTIGRAVITY"
echo "TARGET_REPO=${TARGET_REPO:-<none>}"
echo

run_or_print() {
  if [ "$APPLY" = "1" ]; then
    "$@"
  else
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  fi
}

run_public_npm_or_print() {
  if [ "$APPLY" = "1" ]; then
    NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ \
      npm_config_registry=https://registry.npmjs.org/ \
      npm_config_always_auth=false \
      "$@"
  else
    printf 'DRY-RUN: NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ npm_config_registry=https://registry.npmjs.org/ npm_config_always_auth=false'
    printf ' %q' "$@"
    printf '\n'
  fi
}

run_in_target_or_print() {
  require_target_repo

  if [ "$APPLY" = "1" ]; then
    (cd "$TARGET_REPO" && "$@")
  else
    printf 'DRY-RUN: cd %q &&' "$TARGET_REPO"
    printf ' %q' "$@"
    printf '\n'
  fi
}

run_public_npm_in_target_or_print() {
  require_target_repo

  if [ "$APPLY" = "1" ]; then
    (
      cd "$TARGET_REPO"
      NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ \
        npm_config_registry=https://registry.npmjs.org/ \
        npm_config_always_auth=false \
        "$@"
    )
  else
    printf 'DRY-RUN: cd %q && NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ npm_config_registry=https://registry.npmjs.org/ npm_config_always_auth=false' "$TARGET_REPO"
    printf ' %q' "$@"
    printf '\n'
  fi
}

require_target_repo() {
  if [ -z "$TARGET_REPO" ]; then
    echo "TARGET_REPO is required for project-scoped skills"
    exit 1
  fi

  if [ ! -d "$TARGET_REPO" ]; then
    echo "TARGET_REPO does not exist: $TARGET_REPO"
    exit 1
  fi
}

if [ "$INSTALL_GRAPHIFY" = "1" ]; then
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv is required to install Graphify in an isolated tool environment"
    exit 1
  fi

  run_or_print uv tool install 'graphifyy[gemini]'
  run_or_print uvx --from graphifyy graphify install --platform codex
fi

if [ "$INSTALL_GRAPHIFY_PROJECT" = "1" ]; then
  require_target_repo
  run_in_target_or_print uvx --from graphifyy graphify antigravity install
fi

if [ "$INSTALL_IMPECCABLE" = "1" ]; then
  run_public_npm_in_target_or_print npx skills add pbakaus/impeccable
fi

if [ "$INSTALL_HUASHU" = "1" ]; then
  run_public_npm_in_target_or_print npx playbooks add skill alchaincyf/huashu-skills --skill huashu-design
fi

if [ "$INSTALL_CAVEMAN_CODEX" = "1" ]; then
  run_public_npm_or_print npx skills add JuliusBrussee/caveman -a codex
fi

if [ "$INSTALL_CAVEMAN_ANTIGRAVITY" = "1" ]; then
  run_public_npm_or_print npx skills add JuliusBrussee/caveman -a antigravity
fi

if [ "$APPLY" != "1" ]; then
  echo
  echo "No changes were made. Re-run with APPLY=1 after reviewing the commands."
fi
