#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";

const HOME = os.homedir();
const SITES_DIR = path.join(HOME, "Sites");
const MCP_REPO = process.env.MARKDOWN_CONVERTER_REPO || path.join(SITES_DIR, "mcp");
const CACHE_ROOT = process.env.MARKDOWN_CACHE_ROOT || path.join(HOME, ".context-mode-kit", "markdown-cache");
const PYTHON = process.env.MARKDOWN_CONVERTER_PYTHON || path.join(HOME, ".context-mode-kit", "markdown-converter-venv", "bin", "python");
const WORKER = process.env.MARKDOWN_CONVERTER_WORKER || path.join(MCP_REPO, "markdown-converter", "worker", "convert.py");
const CONVERT_TIMEOUT_MS = Number.parseInt(process.env.MARKDOWN_CONVERTER_TIMEOUT_MS || "60000", 10);

const server = new Server(
  {
    name: "gothsonn-markdown-converter",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  },
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "convert_file",
      description: "Convert one repository file to Markdown and store it in the external markdown cache.",
      inputSchema: {
        type: "object",
        properties: {
          path: { type: "string", description: "Absolute file path or path relative to repo." },
          repo: { type: "string", description: "Repository root. Defaults to current project dir." },
          force: { type: "boolean", description: "Reconvert even when cached output is fresh." },
        },
        required: ["path"],
      },
    },
    {
      name: "convert_repo",
      description: "Convert safe text/document files from a repository to Markdown cache.",
      inputSchema: {
        type: "object",
        properties: {
          repo: { type: "string", description: "Repository root. Defaults to current project dir." },
          force: { type: "boolean", description: "Reconvert every candidate file." },
          maxFiles: { type: "number", description: "Maximum files to convert. Default 10000." },
          maxFileBytes: { type: "number", description: "Maximum source file size. Default 25000000." },
        },
      },
    },
    {
      name: "list_cache",
      description: "List Markdown files currently cached for a repository.",
      inputSchema: {
        type: "object",
        properties: {
          repo: { type: "string", description: "Repository root. Defaults to current project dir." },
          limit: { type: "number", description: "Maximum entries. Default 100." },
        },
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args = {} } = request.params;
  try {
    if (name === "convert_file") return textResponse(convertFileTool(args));
    if (name === "convert_repo") return textResponse(convertRepoTool(args));
    if (name === "list_cache") return textResponse(listCacheTool(args));
    return textResponse(`Unknown tool: ${name}`, true);
  } catch (error) {
    return textResponse(error instanceof Error ? error.message : String(error), true);
  }
});

function convertFileTool(args) {
  const repo = resolveRepo(args.repo);
  const source = resolveSource(repo, String(args.path || ""));
  const result = convertOne(repo, source, Boolean(args.force));
  return [
    "== Markdown conversion ==",
    `repo=${repo}`,
    `source=${path.relative(repo, source)}`,
    `status=${result.status}`,
    `output=${result.output}`,
    result.message ? `message=${result.message}` : "",
  ].filter(Boolean).join("\n");
}

function convertRepoTool(args) {
  const repo = resolveRepo(args.repo);
  const maxFiles = Number.parseInt(String(args.maxFiles || "10000"), 10);
  const candidates = discover(repo, Number.parseInt(String(args.maxFileBytes || "25000000"), 10))
    .slice(0, maxFiles);

  let converted = 0;
  let cached = 0;
  let failed = 0;
  const failures = [];

  for (const source of candidates) {
    const result = convertOne(repo, source, Boolean(args.force));
    if (result.status === "converted") converted += 1;
    else if (result.status === "cached") cached += 1;
    else {
      failed += 1;
      failures.push(`${path.relative(repo, source)}: ${result.message}`);
    }
  }

  return [
    "== Markdown repo conversion ==",
    `repo=${repo}`,
    `candidates=${candidates.length}`,
    `converted=${converted}`,
    `cached=${cached}`,
    `failed=${failed}`,
    `cache=${cacheDirForRepo(repo)}`,
    ...failures.slice(0, 20).map((line) => `FAIL ${line}`),
  ].join("\n");
}

function listCacheTool(args) {
  const repo = resolveRepo(args.repo);
  const cacheDir = cacheDirForRepo(repo);
  const limit = Number.parseInt(String(args.limit || "100"), 10);
  if (!fs.existsSync(cacheDir)) {
    return `No cache found for ${repo}`;
  }
  const files = [];
  walk(cacheDir, cacheDir, 30, [], (file) => {
    if (file.endsWith(".md")) files.push(path.relative(cacheDir, file));
  });
  return [
    "== Markdown cache ==",
    `repo=${repo}`,
    `cache=${cacheDir}`,
    `files=${files.length}`,
    ...files.sort().slice(0, limit),
  ].join("\n");
}

function convertOne(repo, source, force) {
  assertSafeSource(repo, source);
  const output = outputPathFor(repo, source);
  const metaPath = `${output}.json`;
  const sourceHash = sha256(source);
  const prior = readJson(metaPath);

  if (!force && prior?.sourceHash === sourceHash && fs.existsSync(output)) {
    return { status: "cached", output };
  }

  fs.mkdirSync(path.dirname(output), { recursive: true });
  const python = fs.existsSync(PYTHON) ? PYTHON : "python3";
  const proc = spawnSync(python, [WORKER, "--input", source, "--output", output, "--repo", repo], {
    encoding: "utf8",
    maxBuffer: 1024 * 1024 * 20,
    timeout: CONVERT_TIMEOUT_MS,
  });

  if (proc.status !== 0) {
    return {
      status: "failed",
      output,
      message: (proc.error?.message || proc.stderr || proc.stdout || `exit ${proc.status}`).trim(),
    };
  }

  const workerMeta = readJsonFromString(proc.stdout) || {};
  fs.writeFileSync(metaPath, `${JSON.stringify({
    repo,
    source,
    sourceRelative: path.relative(repo, source),
    sourceHash,
    output,
    convertedAt: new Date().toISOString(),
    worker: workerMeta,
  }, null, 2)}\n`);

  return { status: "converted", output, message: workerMeta.engine };
}

function resolveRepo(repoArg) {
  const repo = path.resolve(String(repoArg || process.env.CONTEXT_MODE_PROJECT_DIR || process.env.PWD || process.cwd()));
  if (!repo.startsWith(SITES_DIR + path.sep)) {
    throw new Error(`Refusing repo outside $HOME/Sites: ${repo}`);
  }
  if (!fs.existsSync(repo) || !fs.statSync(repo).isDirectory()) {
    throw new Error(`Repository not found: ${repo}`);
  }
  return repo;
}

function resolveSource(repo, requested) {
  if (!requested) throw new Error("Missing path");
  const source = path.isAbsolute(requested) ? requested : path.resolve(repo, requested);
  return source;
}

function assertSafeSource(repo, source) {
  if (!source.startsWith(repo + path.sep)) {
    throw new Error(`Refusing source outside repo: ${source}`);
  }
  if (!fs.existsSync(source) || !fs.statSync(source).isFile()) {
    throw new Error(`Source file not found: ${source}`);
  }
  const rel = path.relative(repo, source);
  if (rel.split(path.sep).some(shouldSkipDir)) {
    throw new Error(`Refusing skipped path: ${rel}`);
  }
  if (isSensitive(path.basename(source))) {
    throw new Error(`Refusing sensitive file: ${rel}`);
  }
}

function discover(repo, maxFileBytes) {
  const files = [];
  walk(repo, repo, 30, files);
  return files
    .filter((file) => {
      const stat = fs.statSync(file);
      return stat.size > 0 && stat.size <= maxFileBytes && isConvertible(file) && !isSensitive(path.basename(file));
    })
    .sort((a, b) => path.relative(repo, a).localeCompare(path.relative(repo, b)));
}

function walk(root, dir, maxDepth, files, visit) {
  const depth = path.relative(root, dir).split(path.sep).filter(Boolean).length;
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
    if (entry.isDirectory()) walk(root, full, maxDepth, files, visit);
    else if (entry.isFile()) {
      if (visit) visit(full);
      else files.push(full);
    }
  }
}

function shouldSkipDir(name) {
  return [".git", "node_modules", "vendor", "dist", "build", "target", "coverage", ".next", ".nuxt", ".angular", ".venv", "venv", "__pycache__", "graphify-out", ".idea", ".vscode", ".cursor"].includes(name);
}

function isConvertible(file) {
  const lower = path.basename(file).toLowerCase();
  return [
    ".md", ".mdx", ".txt", ".json", ".jsonc", ".yaml", ".yml", ".toml", ".xml", ".html", ".htm",
    ".csv", ".tsv", ".docx", ".doc", ".pptx", ".ppt", ".xlsx", ".xls", ".pdf", ".rtf", ".epub",
    ".drawio", ".puml", ".plantuml", ".js", ".jsx", ".ts", ".tsx", ".java", ".kt", ".kts", ".py",
    ".php", ".sql", ".sh", ".bash", ".zsh", ".properties", ".gradle", ".graphql", ".gql", ".proto",
  ].some((ext) => lower.endsWith(ext)) || ["dockerfile", "makefile", "readme", "license", "changelog"].includes(lower);
}

function isSensitive(name) {
  const lower = name.toLowerCase();
  return (
    lower.startsWith("~$") ||
    lower.endsWith(".tmp") ||
    lower.endsWith(".lock") ||
    lower === ".env" ||
    lower.includes("credential") ||
    lower.includes("secret") ||
    lower.includes("token") ||
    lower.includes("password") ||
    lower.endsWith(".pem") ||
    lower.endsWith(".key") ||
    lower.endsWith(".p12") ||
    lower.endsWith(".pfx") ||
    lower.endsWith(".jks")
  );
}

function outputPathFor(repo, source) {
  const rel = path.relative(repo, source);
  return path.join(cacheDirForRepo(repo), `${rel}.md`);
}

function cacheDirForRepo(repo) {
  const repoName = path.basename(repo);
  const repoHash = createHash("sha256").update(repo).digest("hex").slice(0, 16);
  return path.join(CACHE_ROOT, `${repoName}-${repoHash}`);
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

function readJsonFromString(text) {
  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

function textResponse(text, isError = false) {
  return {
    content: [{ type: "text", text }],
    isError,
  };
}

const transport = new StdioServerTransport();
await server.connect(transport);
