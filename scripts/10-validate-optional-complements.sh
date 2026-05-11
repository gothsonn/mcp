#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_CAVEMAN="${CHECK_CAVEMAN:-0}"

echo "== Optional complements validation =="
echo

check_cmd() {
  local name="$1"
  local command_name="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    echo "OK   $name: $(command -v "$command_name")"
  else
    echo "MISS $name: command '$command_name' not found"
  fi
}

check_cmd "RTK" rtk
if command -v rtk >/dev/null 2>&1; then
  rtk --version
fi

check_cmd "uv" uv
if command -v uv >/dev/null 2>&1; then
  uv --version
fi

check_cmd "npx" npx
if command -v npx >/dev/null 2>&1; then
  npx --version
fi

if command -v graphify >/dev/null 2>&1; then
  echo "OK   Graphify: $(command -v graphify)"
  graphify --version 2>/dev/null || true
elif [ -x "$HOME/.local/bin/graphify" ]; then
  echo "OK   Graphify: $HOME/.local/bin/graphify"
  echo "WARN $HOME/.local/bin is not on PATH for this shell"
  "$HOME/.local/bin/graphify" --version 2>/dev/null || true
else
  echo "INFO install Graphify with:"
  echo "     APPLY=1 INSTALL_GRAPHIFY=1 ./scripts/11-install-optional-complements.sh"
fi

echo
echo "== Project pilot files =="
for path in \
  "$ROOT_DIR/ides/COMPLEMENTOS_OPCIONAIS.md" \
  "$ROOT_DIR/inventories/repos-piloto.md" \
  "$ROOT_DIR/templates/frontend/PRODUCT.md.example" \
  "$ROOT_DIR/templates/frontend/DESIGN.md.example"; do
  if [ -f "$path" ]; then
    echo "OK   $path"
  else
    echo "MISS $path"
    exit 1
  fi
done

echo
echo "== Candidate repositories =="
for repo in \
  "$HOME/Sites/projeto_qrcode_movidesk" \
  "$HOME/Sites/rafaelfreitas" \
  "$HOME/Sites/easysuite" \
  "$HOME/Sites/Cresol" \
  "$HOME/Sites/PortoSeguro/auto-cotacao-web"; do
  if [ -d "$repo" ]; then
    echo "OK   $repo"
  else
    echo "MISS $repo"
  fi
done

if [ "$CHECK_CAVEMAN" = "1" ]; then
  echo
  echo "== Caveman dry-run =="
  curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash -s -- --dry-run --only codex
else
  echo
  echo "INFO skipping Caveman network dry-run. Run with CHECK_CAVEMAN=1 to verify installer."
fi

echo
echo "Optional complements validation completed."
