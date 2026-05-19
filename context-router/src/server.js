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

const HOME = os.homedir();
const SITES_DIR = path.join(HOME, "Sites");
const DEFAULT_MAX_BYTES = 6000;
const DEFAULT_TIMEOUT_MS = 30000;

function assertSitesPath(inputPath = SITES_DIR) {
  const resolved = path.resolve(inputPath.replace(/^~(?=$|\/)/, HOME));
  if (resolved !== SITES_DIR && !resolved.startsWith(`${SITES_DIR}${path.sep}`)) {
    throw new Error(`Refusing path outside $HOME/Sites: ${resolved}`);
  }
  return resolved;
}

function clampNumber(value, fallback, min, max) {
  const number = Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.max(min, Math.min(max, number));
}

function linePreview(text, maxBytes = DEFAULT_MAX_BYTES) {
  const input = String(text || "");
  if (Buffer.byteLength(input, "utf8") <= maxBytes) {
    return { text: input, truncated: false, omittedBytes: 0 };
  }

  const half = Math.floor(maxBytes / 2);
  const head = Buffer.from(input).subarray(0, half).toString("utf8");
  const tail = Buffer.from(input).subarray(Math.max(0, Buffer.byteLength(input, "utf8") - half)).toString("utf8");
  return {
    text: `${head}\n\n[... output truncated by context-router ...]\n\n${tail}`,
    truncated: true,
    omittedBytes: Math.max(0, Buffer.byteLength(input, "utf8") - Buffer.byteLength(head, "utf8") - Buffer.byteLength(tail, "utf8")),
  };
}

function filterByIntent(text, intent, maxBytes) {
  const source = String(text || "");
  const terms = String(intent || "")
    .toLowerCase()
    .split(/[^a-z0-9_.:/-]+/i)
    .filter((term) => term.length >= 3);

  if (!terms.length) return linePreview(source, maxBytes);

  const lines = source.split(/\r?\n/);
  const selected = [];
  for (let index = 0; index < lines.length; index += 1) {
    const lower = lines[index].toLowerCase();
    if (terms.some((term) => lower.includes(term))) {
      const start = Math.max(0, index - 1);
      const end = Math.min(lines.length - 1, index + 1);
      for (let cursor = start; cursor <= end; cursor += 1) {
        selected.push(`${cursor + 1}: ${lines[cursor]}`);
      }
    }
  }

  const unique = [...new Set(selected)];
  return linePreview(unique.length ? unique.join("\n") : source, maxBytes);
}

function safeShell(args) {
  const cwd = assertSitesPath(args.cwd || args.repoPath || SITES_DIR);
  const command = String(args.command || "").trim();
  if (!command) throw new Error("Missing command.");

  const timeout = clampNumber(args.timeoutMs, DEFAULT_TIMEOUT_MS, 1000, 120000);
  const maxBytes = clampNumber(args.maxBytes, DEFAULT_MAX_BYTES, 1000, 20000);
  const result = spawnSync("zsh", ["-lc", command], {
    cwd,
    timeout,
    encoding: "utf8",
    maxBuffer: 10 * 1024 * 1024,
  });

  const combined = [result.stdout, result.stderr].filter(Boolean).join("\n");
  const preview = args.intent ? filterByIntent(combined, args.intent, maxBytes) : linePreview(combined, maxBytes);
  return {
    cwd,
    command,
    exitCode: result.status,
    signal: result.signal,
    timedOut: Boolean(result.error && result.error.code === "ETIMEDOUT"),
    truncated: preview.truncated,
    omittedBytes: preview.omittedBytes,
    output: preview.text,
  };
}

function safeReadFile(args) {
  const file = assertSitesPath(args.path);
  if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
    throw new Error(`File not found: ${file}`);
  }

  const maxBytes = clampNumber(args.maxBytes, DEFAULT_MAX_BYTES, 1000, 20000);
  const content = fs.readFileSync(file, "utf8");
  const preview = args.query ? filterByIntent(content, args.query, maxBytes) : linePreview(content, maxBytes);
  return {
    file,
    bytes: Buffer.byteLength(content, "utf8"),
    lines: content.split(/\r?\n/).length,
    query: args.query || null,
    truncated: preview.truncated,
    omittedBytes: preview.omittedBytes,
    output: preview.text,
  };
}

function safeSearch(args) {
  const cwd = assertSitesPath(args.path || args.repoPath || SITES_DIR);
  const pattern = String(args.pattern || "").trim();
  if (!pattern) throw new Error("Missing pattern.");

  const maxMatches = clampNumber(args.maxMatches, 50, 1, 200);
  const globs = Array.isArray(args.globs) ? args.globs.flatMap((glob) => ["--glob", String(glob)]) : [];
  const result = spawnSync("rg", ["-n", "--hidden", "--no-heading", "-m", String(maxMatches), ...globs, pattern, cwd], {
    cwd,
    encoding: "utf8",
    timeout: clampNumber(args.timeoutMs, 20000, 1000, 60000),
    maxBuffer: 5 * 1024 * 1024,
  });

  const output = [result.stdout, result.stderr].filter(Boolean).join("\n");
  const preview = linePreview(output, clampNumber(args.maxBytes, DEFAULT_MAX_BYTES, 1000, 20000));
  return {
    cwd,
    pattern,
    maxMatches,
    exitCode: result.status,
    truncated: preview.truncated,
    output: preview.text,
  };
}

async function safeFetchUrl(args) {
  const url = String(args.url || "").trim();
  if (!/^https?:\/\//i.test(url)) throw new Error("Only http(s) URLs are allowed.");
  const response = await fetch(url, { redirect: "follow" });
  const raw = await response.text();
  const text = raw
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  const preview = args.intent
    ? filterByIntent(text, args.intent, clampNumber(args.maxBytes, DEFAULT_MAX_BYTES, 1000, 20000))
    : linePreview(text, clampNumber(args.maxBytes, DEFAULT_MAX_BYTES, 1000, 20000));
  return {
    url: response.url,
    status: response.status,
    ok: response.ok,
    bytes: Buffer.byteLength(raw, "utf8"),
    truncated: preview.truncated,
    output: preview.text,
  };
}

async function main() {
  const server = new Server(
    { name: "gothsonn-context-router", version: "0.1.0" },
    { capabilities: { tools: {} } },
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: "safe_shell",
        description: "Run a shell command under $HOME/Sites and return bounded, intent-filtered output instead of raw terminal dumps.",
        inputSchema: {
          type: "object",
          properties: {
            cwd: { type: "string" },
            repoPath: { type: "string" },
            command: { type: "string" },
            intent: { type: "string" },
            maxBytes: { type: "number" },
            timeoutMs: { type: "number" },
          },
          required: ["command"],
        },
      },
      {
        name: "safe_read_file",
        description: "Read a file under $HOME/Sites with bounded output. Use query to return only relevant lines.",
        inputSchema: {
          type: "object",
          properties: {
            path: { type: "string" },
            query: { type: "string" },
            maxBytes: { type: "number" },
          },
          required: ["path"],
        },
      },
      {
        name: "safe_search",
        description: "Search under $HOME/Sites with ripgrep and bounded results.",
        inputSchema: {
          type: "object",
          properties: {
            path: { type: "string" },
            repoPath: { type: "string" },
            pattern: { type: "string" },
            globs: { type: "array", items: { type: "string" } },
            maxMatches: { type: "number" },
            maxBytes: { type: "number" },
            timeoutMs: { type: "number" },
          },
          required: ["pattern"],
        },
      },
      {
        name: "safe_fetch_url",
        description: "Fetch a URL and return a bounded text preview. Use intent to filter relevant lines.",
        inputSchema: {
          type: "object",
          properties: {
            url: { type: "string" },
            intent: { type: "string" },
            maxBytes: { type: "number" },
          },
          required: ["url"],
        },
      },
    ],
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const args = request.params.arguments || {};
    let result;
    if (request.params.name === "safe_shell") {
      result = safeShell(args);
    } else if (request.params.name === "safe_read_file") {
      result = safeReadFile(args);
    } else if (request.params.name === "safe_search") {
      result = safeSearch(args);
    } else if (request.params.name === "safe_fetch_url") {
      result = await safeFetchUrl(args);
    } else {
      throw new Error(`Unknown tool: ${request.params.name}`);
    }

    return {
      content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
    };
  });

  await server.connect(new StdioServerTransport());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
