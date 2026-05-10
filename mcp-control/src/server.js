#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { execFileSync } from "node:child_process";

const HOME = os.homedir();
const MCP_REPO = process.env.MCP_CONTROL_REPO || "/Users/rafaelpereirafreitas/Sites/mcp";
const DEFAULT_REPO = "/Users/rafaelpereirafreitas/Sites/rafaelfreitas";

const PROFILE_TEXT = {
  frontend: `# Frontend Profile

Role: frontend specialist + code review.

Use this profile for Angular, React, Next.js, UI behavior, accessibility, visual validation and Playwright checks.

Rules:
- Implement only what is already specified.
- Preserve existing framework conventions.
- Validate responsive behavior and screenshots when UI changes.
- Do not make PO/PM or broad architecture decisions in this profile.
`,
  backend: `# Backend Profile

Role: backend specialist + code review.

Use this profile for Java, NestJS, Python, PHP, APIs, services, contracts, logs, security and tests.

Rules:
- Implement only what is already specified.
- Preserve existing architecture and contracts.
- Validate tests, error handling, observability and security.
- Do not make PO/PM or sprint planning decisions in this profile.
`,
  "product-architecture": `# Product Architecture Profile

Role: PO + PM + architect + software engineer.

Use this profile for RESEARCH, SPEC, ADR, backlog, trade-offs, risks and delivery planning.

Rules:
- Do not implement code directly from this profile.
- Generate or update specs before implementation.
- Use Obsidian/project docs and Graphify reports when available.
- Hand off implementation to frontend or backend profile after the plan is approved.
`,
};

function exists(p) {
  return fs.existsSync(p);
}

function readJson(file) {
  if (!exists(file)) return null;
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function listFiles(dir, filter = () => true) {
  if (!exists(dir)) return [];
  return fs.readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && filter(entry.name))
    .map((entry) => path.join(dir, entry.name));
}

function assertRepoPath(repoPath) {
  const resolved = path.resolve(repoPath || DEFAULT_REPO);
  if (!resolved.startsWith("/Users/rafaelpereirafreitas/Sites/")) {
    throw new Error(`Refusing path outside /Users/rafaelpereirafreitas/Sites: ${resolved}`);
  }
  if (!exists(resolved)) {
    throw new Error(`Repository path does not exist: ${resolved}`);
  }
  return resolved;
}

function gitStatus(repoPath) {
  try {
    return execFileSync("git", ["status", "--short", "--branch"], {
      cwd: repoPath,
      encoding: "utf8",
    }).trim();
  } catch (error) {
    return `git status failed: ${error.message}`;
  }
}

function globalStatus() {
  const codexConfig = path.join(HOME, ".codex/config.toml");
  const cursorConfig = path.join(HOME, ".cursor/mcp.json");
  const antigravityConfig = path.join(HOME, ".gemini/antigravity/mcp_config.json");
  const cursorJson = readJson(cursorConfig);
  const antigravityJson = readJson(antigravityConfig);
  const codexText = exists(codexConfig) ? fs.readFileSync(codexConfig, "utf8") : "";

  return {
    codex: {
      config: codexConfig,
      hasMcpControl: codexText.includes("[mcp_servers.mcp-control]"),
      hasOpenAiDocs: codexText.includes("[mcp_servers.openaiDeveloperDocs]"),
      hasJetBrains: codexText.includes("[mcp_servers.jetbrains]"),
    },
    cursor: {
      config: cursorConfig,
      servers: Object.keys(cursorJson?.mcpServers || {}),
      hasMcpControl: Boolean(cursorJson?.mcpServers?.["mcp-control"]),
    },
    antigravity: {
      config: antigravityConfig,
      servers: Object.keys(antigravityJson?.mcpServers || {}),
      hasMcpControl: Boolean(antigravityJson?.mcpServers?.["mcp-control"]),
    },
    mcpControl: {
      repo: MCP_REPO,
      server: path.join(MCP_REPO, "mcp-control/src/server.js"),
    },
  };
}

function inspectRepository(repoPath) {
  const repo = assertRepoPath(repoPath);
  const graphifyOut = path.join(repo, "graphify-out");
  const profileDir = path.join(repo, ".agents/profiles");

  return {
    repo,
    gitStatus: gitStatus(repo),
    profiles: {
      directory: profileDir,
      configured: listFiles(profileDir, (name) => name.endsWith(".md")).map((file) => path.basename(file, ".md")),
      expected: Object.keys(PROFILE_TEXT),
    },
    rules: {
      agentRules: listFiles(path.join(repo, ".agents/rules")).map((file) => path.relative(repo, file)),
      workflows: listFiles(path.join(repo, ".agents/workflows")).map((file) => path.relative(repo, file)),
      cursorRules: listFiles(path.join(repo, ".cursor/rules")).map((file) => path.relative(repo, file)),
    },
    skills: {
      graphifyGlobal: exists(path.join(HOME, ".agents/skills/graphify/SKILL.md")),
      graphifyProjectRules: exists(path.join(repo, ".agents/rules/graphify.md")) || exists(path.join(repo, ".cursor/rules/graphify.mdc")),
      impeccableProjectHints: exists(path.join(repo, "PRODUCT.md")) || exists(path.join(repo, "DESIGN.md")),
      cavemanGlobal: exists(path.join(HOME, ".agents/skills/caveman/SKILL.md")),
    },
    graphify: {
      outputDir: graphifyOut,
      graphJson: exists(path.join(graphifyOut, "graph.json")),
      graphHtml: exists(path.join(graphifyOut, "graph.html")),
      graphReport: exists(path.join(graphifyOut, "GRAPH_REPORT.md")),
    },
  };
}

function installProfiles(repoPath, profiles, apply) {
  const repo = assertRepoPath(repoPath);
  const wanted = profiles?.length ? profiles : Object.keys(PROFILE_TEXT);
  const changes = [];
  const profileDir = path.join(repo, ".agents/profiles");

  for (const profile of wanted) {
    if (!PROFILE_TEXT[profile]) {
      throw new Error(`Unknown profile '${profile}'. Allowed: ${Object.keys(PROFILE_TEXT).join(", ")}`);
    }
    const target = path.join(profileDir, `${profile}.md`);
    changes.push({ action: exists(target) ? "update" : "create", target });
    if (apply) {
      fs.mkdirSync(profileDir, { recursive: true });
      fs.writeFileSync(target, PROFILE_TEXT[profile], "utf8");
    }
  }

  const index = path.join(profileDir, "README.md");
  changes.push({ action: exists(index) ? "update" : "create", target: index });
  if (apply) {
    fs.mkdirSync(profileDir, { recursive: true });
    fs.writeFileSync(index, `# Agent Profiles

Use profiles in sequence:

product-architecture -> frontend/backend -> specialist code review

Available profiles:
- frontend
- backend
- product-architecture
`, "utf8");
  }

  return {
    repo,
    apply,
    changes,
    next: apply ? "Review git diff and commit in the target repository." : "Re-run with apply=true to write files.",
  };
}

function installSkill(repoPath, skill, apply) {
  const repo = assertRepoPath(repoPath);
  const commands = [];

  if (skill === "graphify") {
    commands.push(["graphify", "cursor", "install"]);
    commands.push(["graphify", "antigravity", "install"]);
  } else if (skill === "impeccable") {
    commands.push(["npx", "skills", "add", "pbakaus/impeccable"]);
  } else if (skill === "huashu") {
    commands.push(["npx", "playbooks", "add", "skill", "alchaincyf/huashu-skills", "--skill", "huashu-design"]);
  } else {
    throw new Error("Unknown skill. Allowed: graphify, impeccable, huashu");
  }

  const results = [];
  for (const command of commands) {
    if (!apply) {
      results.push({ command: command.join(" "), status: "dry-run" });
      continue;
    }
    const output = execFileSync(command[0], command.slice(1), {
      cwd: repo,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });
    results.push({ command: command.join(" "), status: "applied", output: output.trim() });
  }

  return {
    repo,
    skill,
    apply,
    results,
    next: apply ? "Inspect repository status and commit changes if correct." : "Re-run with apply=true to execute.",
  };
}

async function main() {
  const server = new Server(
    { name: "gothsonn-mcp-control", version: "0.1.0" },
    { capabilities: { tools: {} } },
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: "global_mcp_status",
        description: "Inspect global MCP configuration status for Codex, Cursor and Antigravity.",
        inputSchema: { type: "object", properties: {} },
      },
      {
        name: "inspect_repository_profiles",
        description: "Inspect profiles, skills, rules and Graphify artifacts in a repository.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string", description: "Repository path under /Users/rafaelpereirafreitas/Sites" },
          },
        },
      },
      {
        name: "install_repository_profiles",
        description: "Create or update standard agent profile files inside a repository.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            profiles: {
              type: "array",
              items: { type: "string", enum: ["frontend", "backend", "product-architecture"] },
            },
            apply: { type: "boolean", description: "When false, returns planned changes only." },
          },
        },
      },
      {
        name: "install_repository_skill",
        description: "Install a supported project-scoped skill/rule set in a repository.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            skill: { type: "string", enum: ["graphify", "impeccable", "huashu"] },
            apply: { type: "boolean", description: "When false, returns commands only." },
          },
          required: ["skill"],
        },
      },
    ],
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const args = request.params.arguments || {};
    let result;

    if (request.params.name === "global_mcp_status") {
      result = globalStatus();
    } else if (request.params.name === "inspect_repository_profiles") {
      result = inspectRepository(args.repoPath);
    } else if (request.params.name === "install_repository_profiles") {
      result = installProfiles(args.repoPath, args.profiles, Boolean(args.apply));
    } else if (request.params.name === "install_repository_skill") {
      result = installSkill(args.repoPath, args.skill, Boolean(args.apply));
    } else {
      throw new Error(`Unknown tool: ${request.params.name}`);
    }

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  });

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
