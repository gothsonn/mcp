#!/usr/bin/env node
import { createHash } from "node:crypto";
import { spawn } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const repo = path.resolve(process.env.TARGET_REPO || process.argv[2] || "");
const apply = process.env.APPLY === "1";
const indexAll = process.env.INDEX_ALL === "1";
const forceReindex = process.env.FORCE_REINDEX === "1";
const maxFiles = Number.parseInt(process.env.MAX_FILES || (indexAll ? "10000" : "120"), 10);
const maxFileBytes = Number.parseInt(process.env.MAX_FILE_BYTES || "500000", 10);
const maxDepth = Number.parseInt(process.env.MAX_DEPTH || (indexAll ? "20" : "6"), 10);
const manifestRoot = process.env.CONTEXT_MODE_MANIFEST_DIR || path.join(os.homedir(), ".context-mode-kit", "manifests");

async function main() {
  if (!repo || !fs.existsSync(repo) || !fs.statSync(repo).isDirectory()) {
    console.error("Usage: TARGET_REPO=$HOME/Sites/repo APPLY=1 scripts/22-index-context-mode-repo.sh");
    process.exit(2);
  }

  if (!repo.startsWith(path.join(os.homedir(), "Sites") + path.sep)) {
    console.error(`Refusing path outside $HOME/Sites: ${repo}`);
    process.exit(2);
  }

  const repoName = path.basename(repo);
  const repoHash = createHash("sha256").update(repo).digest("hex").slice(0, 16);
  const manifestPath = path.join(manifestRoot, `${repoName}-${repoHash}.json`);
  const previous = readJson(manifestPath) || { files: {} };

  const candidates = discover(repo)
    .map((file) => {
      const stat = fs.statSync(file);
      const rel = path.relative(repo, file);
      const hash = sha256(file);
      return {
        path: file,
        rel,
        size: stat.size,
        mtimeMs: Math.round(stat.mtimeMs),
        hash,
        source: `${repoName}:${rel}`,
        changed: forceReindex || previous.files?.[rel]?.hash !== hash,
      };
    })
    .sort((a, b) => Number(b.changed) - Number(a.changed) || a.rel.localeCompare(b.rel))
    .slice(0, maxFiles);

  const changed = candidates.filter((item) => item.changed);

  console.log("== Context-mode repo index ==");
  console.log(`Repo:      ${repo}`);
  console.log(`APPLY:     ${apply ? "1" : "0"}`);
  console.log(`INDEX_ALL: ${indexAll ? "1" : "0"}`);
  console.log(`FORCE:     ${forceReindex ? "1" : "0"}`);
  console.log(`Manifest:  ${manifestPath}`);
  console.log(`Files:     ${candidates.length}`);
  console.log(`Changed:   ${changed.length}`);
  console.log();

  if (!apply) {
    for (const item of changed) {
      console.log(`DRY  ${item.rel} (${item.size} bytes)`);
    }
    console.log();
    console.log("No changes were made. Re-run with APPLY=1.");
    process.exit(0);
  }

  if (changed.length > 0) {
    const client = new McpClient({ cwd: repo, env: { CONTEXT_MODE_PROJECT_DIR: repo, PWD: repo } });
    await client.start();
    try {
      for (const item of changed) {
        const response = await client.callTool("ctx_index", {
          path: item.path,
          source: item.source,
        });
        const text = response?.result?.content?.[0]?.text || "";
        console.log(`INDEX ${item.rel}`);
        if (text) console.log(`  ${text.split("\n")[0]}`);
      }
    } finally {
      client.close();
    }
  }

  const next = {
    repo,
    repoName,
    updatedAt: new Date().toISOString(),
    maxFiles,
    maxFileBytes,
    maxDepth,
    indexAll,
    files: Object.fromEntries(
      candidates.map((item) => [
        item.rel,
        {
          hash: item.hash,
          size: item.size,
          mtimeMs: item.mtimeMs,
          source: item.source,
        },
      ]),
    ),
  };

  fs.mkdirSync(manifestRoot, { recursive: true });
  fs.writeFileSync(manifestPath, `${JSON.stringify(next, null, 2)}\n`);

  console.log();
  console.log("== Summary ==");
  console.log(`indexed=${changed.length}`);
  console.log(`tracked=${candidates.length}`);
  console.log(`manifest=${manifestPath}`);
}

function discover(root) {
  const result = [];
  walk(root, root, 0, result);
  return result;
}

function walk(root, dir, depth, result) {
  if (depth > maxDepth) return;
  const base = path.basename(dir);
  if (shouldSkipDir(base)) return;

  let entries = [];
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }

  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(root, full, depth + 1, result);
      continue;
    }
    if (!entry.isFile()) continue;
    if (isCandidate(full, root)) result.push(full);
  }
}

function shouldSkipDir(name) {
  return [
    ".git",
    "node_modules",
    "vendor",
    "dist",
    "build",
    "target",
    "coverage",
    ".next",
    ".nuxt",
    ".angular",
    ".venv",
    "venv",
    "__pycache__",
    "graphify-out",
    ".idea",
    ".vscode",
    ".cursor",
    ".DS_Store",
  ].includes(name);
}

function isCandidate(file, root) {
  const rel = path.relative(root, file);
  const parts = rel.split(path.sep);
  const name = path.basename(file);
  const lower = name.toLowerCase();
  const stat = fs.statSync(file);

  if (stat.size <= 0 || stat.size > maxFileBytes) return false;
  if (isSensitive(name)) return false;
  if (indexAll) return isTextLikeFile(name);

  const rootFiles = new Set([
    "AGENTS.md",
    "GEMINI.md",
    "CLAUDE.md",
    "CONTEXT_MODE_PROMPT.md",
    "README.md",
    "package.json",
    "pnpm-workspace.yaml",
    "yarn.lock",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    "pyproject.toml",
    "requirements.txt",
    "composer.json",
    "Dockerfile",
    "docker-compose.yml",
    "docker-compose.yaml",
  ]);
  if (parts.length === 1 && rootFiles.has(name)) return true;
  if (parts.length === 1 && /^readme(\..*)?\.md$/i.test(name)) return true;

  const first = parts[0]?.toLowerCase();
  const inImportantDir = ["docs", "doc", "documentation", "openapi", "swagger", "api", "apis", "spec", "specs", ".agents"].includes(first);
  if (inImportantDir && /\.(md|mdx|json|ya?ml|toml)$/i.test(name)) return true;

  if (/openapi|swagger/i.test(rel) && /\.(md|json|ya?ml)$/i.test(name)) return true;
  if (/architecture|arquitetura|adr|decision|decisao/i.test(rel) && /\.(md|mdx)$/i.test(name)) return true;

  return lower === "readme.md";
}

function isTextLikeFile(name) {
  const lower = name.toLowerCase();
  const textExtensions = [
    ".md",
    ".mdx",
    ".txt",
    ".json",
    ".jsonc",
    ".yaml",
    ".yml",
    ".toml",
    ".xml",
    ".html",
    ".htm",
    ".css",
    ".scss",
    ".sass",
    ".less",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".mjs",
    ".cjs",
    ".java",
    ".kt",
    ".kts",
    ".py",
    ".php",
    ".sql",
    ".sh",
    ".bash",
    ".zsh",
    ".properties",
    ".gradle",
    ".graphql",
    ".gql",
    ".proto",
    ".csv",
    ".tsv",
    ".drawio",
    ".puml",
    ".plantuml",
  ];
  const knownTextFiles = new Set([
    "dockerfile",
    "makefile",
    "readme",
    "license",
    "changelog",
    "pom.xml",
    "package.json",
    "composer.json",
    "requirements.txt",
    "settings.gradle",
    "build.gradle",
  ]);
  return textExtensions.some((ext) => lower.endsWith(ext)) || knownTextFiles.has(lower);
}

function isSensitive(name) {
  const lower = name.toLowerCase();
  return (
    lower === ".env" ||
    lower.includes("credential") ||
    lower.includes("secret") ||
    lower.includes("token") ||
    lower.includes("password") ||
    lower.endsWith(".pem") ||
    lower.endsWith(".key") ||
    lower.endsWith(".p12") ||
    lower.endsWith(".jks")
  );
}

function sha256(file) {
  return createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return undefined;
  }
}

class McpClient {
  constructor({ cwd, env }) {
    this.cwd = cwd;
    this.env = env;
    this.nextId = 1;
    this.buffer = "";
    this.pending = new Map();
  }

  async start() {
    this.child = spawn("context-mode", [], {
      cwd: this.cwd,
      env: { ...process.env, ...this.env },
      stdio: ["pipe", "pipe", "pipe"],
    });
    this.child.stdout.on("data", (chunk) => this.onData(chunk));
    this.child.stderr.on("data", () => {});
    await this.request("initialize", {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: { name: "mcp-kit-context-indexer", version: "1.0.0" },
    });
    this.notify("notifications/initialized", {});
  }

  callTool(name, args) {
    return this.request("tools/call", { name, arguments: args });
  }

  request(method, params) {
    const id = this.nextId++;
    const payload = { jsonrpc: "2.0", id, method, params };
    this.child.stdin.write(`${JSON.stringify(payload)}\n`);
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`MCP timeout: ${method}`));
      }, 30000);
      this.pending.set(id, { resolve, reject, timer });
    });
  }

  notify(method, params) {
    this.child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
  }

  onData(chunk) {
    this.buffer += chunk.toString("utf8");
    let index;
    while ((index = this.buffer.indexOf("\n")) >= 0) {
      const line = this.buffer.slice(0, index);
      this.buffer = this.buffer.slice(index + 1);
      if (!line.trim()) continue;
      const message = JSON.parse(line);
      if (message.id && this.pending.has(message.id)) {
        const pending = this.pending.get(message.id);
        clearTimeout(pending.timer);
        this.pending.delete(message.id);
        pending.resolve(message);
      }
    }
  }

  close() {
    try {
      this.child.stdin.end();
    } catch {}
    try {
      this.child.kill();
    } catch {}
  }
}

await main();
