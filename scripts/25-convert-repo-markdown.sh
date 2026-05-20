#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
FORCE="${FORCE:-0}"
MAX_FILES="${MAX_FILES:-10000}"
MAX_FILE_BYTES="${MAX_FILE_BYTES:-25000000}"
MCP_REPO="${MCP_REPO:-$HOME/Sites/mcp}"
SERVER="$MCP_REPO/markdown-converter/src/server.js"

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

echo "== Convert repo files to Markdown cache =="
echo "Repo:           $REPO"
echo "APPLY:          $APPLY"
echo "FORCE:          $FORCE"
echo "MAX_FILES:      $MAX_FILES"
echo "MAX_FILE_BYTES: $MAX_FILE_BYTES"
echo

if [ "$APPLY" != "1" ]; then
  echo "DRY  would call markdown-converter MCP convert_repo"
  echo
  echo "No changes were made. Re-run with APPLY=1."
  exit 0
fi

node - <<'NODE' "$SERVER" "$REPO" "$FORCE" "$MAX_FILES" "$MAX_FILE_BYTES"
const { spawn } = require("node:child_process");
const server = process.argv[2];
const repo = process.argv[3];
const force = process.argv[4] === "1";
const maxFiles = Number(process.argv[5]);
const maxFileBytes = Number(process.argv[6]);
const child = spawn("node", [server], {
  cwd: repo,
  env: { ...process.env, CONTEXT_MODE_PROJECT_DIR: repo, PWD: repo },
  stdio: ["pipe", "pipe", "inherit"],
});
let nextId = 1;
let buffer = "";
const pending = new Map();
function send(method, params) {
  const id = nextId++;
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`timeout ${method}`));
    }, 600000);
    pending.set(id, { resolve, reject, timer });
  });
}
function notify(method, params) {
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
}
child.stdout.on("data", (chunk) => {
  buffer += chunk.toString("utf8");
  let idx;
  while ((idx = buffer.indexOf("\n")) >= 0) {
    const line = buffer.slice(0, idx);
    buffer = buffer.slice(idx + 1);
    if (!line.trim()) continue;
    const msg = JSON.parse(line);
    if (pending.has(msg.id)) {
      const item = pending.get(msg.id);
      clearTimeout(item.timer);
      pending.delete(msg.id);
      item.resolve(msg);
    }
  }
});
(async () => {
  await send("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "markdown-converter-script", version: "1.0.0" },
  });
  notify("notifications/initialized", {});
  const res = await send("tools/call", {
    name: "convert_repo",
    arguments: { repo, force, maxFiles, maxFileBytes },
  });
  console.log(res.result?.content?.[0]?.text || JSON.stringify(res));
  child.stdin.end();
  child.kill();
})().catch((err) => {
  console.error(err.message);
  child.kill();
  process.exit(1);
});
NODE
