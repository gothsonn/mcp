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
const SITES_DIR = path.join(HOME, "Sites");
const MCP_REPO = process.env.MCP_CONTROL_REPO || path.join(SITES_DIR, "mcp");
const DEFAULT_REPO = path.join(SITES_DIR, "rafaelfreitas");

const PROFILE_TEXT = {
  frontend: `# Frontend Profile

Role: senior frontend specialist + code review.

Use this profile for Angular, React, Next.js, TypeScript, UI behavior, accessibility, visual validation and Playwright checks.

Operating standard:
- Act as a senior engineer for enterprise systems, not as a page builder.
- Start by identifying framework, routing, state management, component conventions, design system, tests and build commands.
- Preserve existing architecture and user-facing contracts unless the approved SPEC asks for a change.
- Keep UI work aligned with PRODUCT.md, DESIGN.md, docs/design/TASTE.md and Impeccable when present.
- Validate desktop and mobile behavior for user-facing changes.

Rules:
- Implement only what is already specified.
- Preserve existing framework conventions.
- Validate responsive behavior and screenshots when UI changes.
- Do not make PO/PM or broad architecture decisions in this profile.

Generic frontend criteria:
- Component boundaries, inputs/outputs and shared state must stay explicit.
- Avoid duplicated business logic in templates/components.
- Protect accessibility: semantic HTML, keyboard path, labels, focus, contrast and screen reader text.
- Avoid unnecessary re-renders, oversized bundles, blocking work and hydration errors.
- Validate API error states, loading states, empty states and permission states.

Angular criteria:
- Respect current Angular version and project style before introducing standalone components, signals or new patterns.
- Keep smart/container logic separated from presentational components when the project already uses that pattern.
- Review RxJS subscriptions, async pipe usage, teardown, interceptors, guards, resolvers and typed forms.
- Check change detection, lazy loading, route boundaries, module/provider scope and shared component reuse.

React/Next.js criteria:
- Identify App Router vs Pages Router, client/server component boundaries and data fetching strategy.
- Keep hooks deterministic; review dependency arrays, memoization, stale closures and unnecessary global state.
- Check SSR/CSR hydration, caching, route handlers, server actions, suspense/loading and error boundaries.
- Prefer clear composition over generic abstractions that hide product behavior.
`,
  backend: `# Backend Profile

Role: senior backend specialist + code review.

Use this profile for Java, Quarkus, Spring Boot, NestJS, Node.js, Python, PHP, APIs, services, contracts, logs, security, data processing and tests.

Operating standard:
- Act as a senior engineer for mission-critical enterprise systems.
- Start by identifying runtime, framework, module boundaries, persistence, messaging, auth, test style and deployment model.
- Preserve contracts and data compatibility unless the approved SPEC says otherwise.
- Treat security, observability, failure modes and transaction boundaries as first-class review items.

Rules:
- Implement only what is already specified.
- Preserve existing architecture and contracts.
- Validate tests, error handling, observability and security.
- Do not make PO/PM or sprint planning decisions in this profile.

Generic backend criteria:
- Check API design, DTO validation, status codes, pagination, idempotency, versioning and backward compatibility.
- Check SOLID, clean architecture, dependency direction, use cases/services, repositories and transaction scope.
- Check auth/authz, input validation, secrets, injection risks, sensitive logs and dependency risk.
- Check retries, timeouts, circuit breakers, rate limits, backpressure and graceful degradation.
- Check logs, metrics, traces, correlation IDs and actionable error messages.

Java/Spring/Quarkus criteria:
- Review package boundaries, CDI/Spring scopes, blocking vs non-blocking code and thread safety.
- Check JPA/Panache transactions, lazy loading, N+1 queries, indexes, optimistic locking and migration safety.
- For Quarkus, check build-time/runtime config, native-image impact, health checks and OpenTelemetry readiness.
- For microservices, check distributed transaction avoidance, eventual consistency, outbox/inbox and compensation.
- For Kafka, check event schema, keys, partitioning, ordering, retries, dead-letter strategy and compatibility.
- Review JVM memory allocation, connection pools, startup time, readiness/liveness and Kubernetes/OpenShift settings.

NestJS/Node criteria:
- Review module boundaries, providers, dependency injection, guards, interceptors, pipes and exception filters.
- Check DTO validation, serialization, async error handling, request lifecycle and background job isolation.
- Check Prisma/TypeORM transaction boundaries, connection pool usage, migrations and query plans.

Python criteria:
- Identify FastAPI, scripts, ETL, automation or data pipeline context before changing code.
- Check typing, pydantic/schema validation, logging, idempotency, retries, streaming/chunking and memory use.
- Validate pytest coverage for edge cases, data quality and failure modes.

PHP criteria:
- Identify Laravel, CodeIgniter or custom architecture before changing structure.
- Check request validation, auth middleware, ORM/query builder usage, SQL injection, CSRF and output escaping.
- Preserve legacy behavior unless tests/specs prove the intended migration path.
`,
  "product-architecture": `# Product Architecture Profile

Role: PO + PM + architect + software engineer.

Use this profile for RESEARCH, SPEC, ADR, backlog, trade-offs, risks and delivery planning.

Operating standard:
- Use the user's background as a senior fullstack/software architect across Java, Angular, React, Node, Python, PHP, Kafka, AWS, Kubernetes/OpenShift and relational databases.
- Convert ambiguous demand into bounded scope, acceptance criteria, risks, rollout plan and validation.
- Prefer architecture that fits the existing system over fashionable rewrites.
- Use Graphify reports, Obsidian/project docs and repository conventions as evidence.

Rules:
- Do not implement code directly from this profile.
- Generate or update specs before implementation.
- Use Obsidian/project docs and Graphify reports when available.
- Hand off implementation to frontend or backend profile after the plan is approved.

Architecture criteria:
- Define domain boundaries, API ownership, data ownership and integration contracts.
- Choose sync vs async communication deliberately; document latency, consistency and failure trade-offs.
- For event-driven systems, define event contracts, idempotency, replay behavior and dead-letter handling.
- For data-heavy systems, define source of truth, ETL lineage, data quality checks and reprocessing strategy.
- For cloud-native delivery, define health checks, resources, scaling, secrets, observability and rollback.
- Produce SPEC/ADR updates when a decision changes behavior, schema, API or operational risk.
`,
  "code-review": `# Code Review Profile

Role: principal engineer code reviewer.

Use this profile after implementation to review correctness, regressions, tests, UI/UX quality, security, performance and maintainability.

Rules:
- Start with findings ordered by severity.
- Reference concrete files and evidence.
- Compare implementation against approved SPEC/ADR when available.
- Do not rewrite code unless explicitly asked after review.

Review standard:
- Be rigorous, production-grade and specific.
- Explain what is wrong, why it is wrong, production impact and how to improve.
- Include improved code examples only when they clarify the fix.
- Separate blocking findings from recommendations.
- If no issue is found, say so and list residual risk or missing validation.

Always check:
- Architecture consistency, SOLID, clean code, naming, maintainability and framework conventions.
- Scalability, performance, memory, concurrency, thread safety and transaction consistency.
- Security vulnerabilities, input validation, auth/authz, secrets and sensitive data exposure.
- API design, event contracts, database indexing, migration safety and backward compatibility.
- Observability, logs, metrics, traces, alerts, health checks and failure diagnostics.
- Test coverage, edge cases, rollback safety and production operational behavior.

Stack-specific review:
- Angular: change detection, RxJS lifecycle, typed forms, route/module boundaries, accessibility and bundle impact.
- React/Next.js: client/server boundaries, hooks correctness, hydration, cache behavior, error/loading states and re-render cost.
- Java/Quarkus/Spring: microservice boundaries, transactions, JPA queries, Kafka contracts, JVM/Kubernetes readiness and resilience.
- NestJS/Node: module boundaries, DTO validation, async errors, guards/interceptors, ORM transactions and job processing.
- Python: typing, pydantic/data validation, memory use, retries, idempotent ETL and pytest coverage.
- PHP: validation, auth middleware, SQL safety, escaping, framework conventions and legacy compatibility.
`,
};

const PROFILE_SKILLS = {
  frontend: ["impeccable", "taste", "graphify"],
  backend: ["impeccable", "graphify"],
  "product-architecture": ["impeccable", "huashu", "graphify"],
  "code-review": ["impeccable", "taste", "graphify"],
};

const TASTE_TEXT = `# Taste Profile

Use this local profile to keep visual decisions consistent for this repository.

## Preferences

- Prefer clear hierarchy, strong information scent and restrained decoration.
- Use product-specific design constraints before personal preference.
- Favor evidence from screenshots, design system rules and user workflows.

## Anti-Preferences

- Do not apply generic AI gradients or one-note palettes.
- Do not override a corporate design system without explicit approval.
- Do not treat visual taste as a substitute for accessibility or usability.

## Validation

- Capture screenshots for visual changes.
- Compare against PRODUCT.md and DESIGN.md when they exist.
- Record durable visual decisions in project docs.
`;

const PROFILE_RULES_TEXT = `# Profile Engineering Rules

These rules are installed by mcp-control and apply to every profile in this repository.

## User Context

The default standard is calibrated for Rafael Pereira Freitas' profile:
- Senior software engineer and fullstack developer with 16+ years of experience.
- Strong backend and architecture background with Java, Quarkus, Spring Boot, Kotlin, Node.js, NestJS, Python, PHP, .NET and data pipelines.
- Strong frontend background with Angular, React, Next.js, TypeScript and reusable UI components.
- Enterprise architecture experience with microservices, Kafka, Redis, SQS/SNS, REST/SOAP, AWS, Docker, Kubernetes, OpenShift, CI/CD and observability.
- Database experience across PostgreSQL, Oracle, MySQL, SQL Server, DB2, MongoDB, DynamoDB and other SQL/NoSQL engines.

## Generic Engineering Criteria

All implementation and review work must check:
- Architecture consistency with the existing repository.
- SOLID, clean architecture, clean code, naming quality and maintainability.
- API contracts, DTO validation, backward compatibility and versioning.
- Security: auth/authz, input validation, injection, secrets, sensitive logs and dependency risk.
- Reliability: timeouts, retries, idempotency, backpressure, circuit breakers and graceful degradation.
- Data correctness: transaction boundaries, consistency, migration safety, indexing and query cost.
- Observability: logs, metrics, traces, correlation IDs, health checks and actionable errors.
- Tests: unit, integration, e2e when relevant, edge cases, regression coverage and test data quality.
- Operations: Docker, Kubernetes/OpenShift, resources, startup/shutdown, readiness/liveness and rollback.

## Frontend Criteria

### Angular

- Detect the Angular version and local conventions before introducing standalone components, signals or new state patterns.
- Review component boundaries, inputs/outputs, services, guards, interceptors, resolvers, typed forms and routing.
- Check RxJS subscription lifecycle, async pipe usage, teardown and error handling.
- Check accessibility, responsive behavior, loading/empty/error states and visual consistency.
- Validate tests and Playwright/screenshots when UI behavior changes.

### React / Next.js

- Identify App Router vs Pages Router and client/server component boundaries.
- Review hooks, dependency arrays, memoization, stale closures, global state and unnecessary re-renders.
- Check SSR/CSR hydration, caching, server actions, route handlers, suspense/loading and error boundaries.
- Validate accessibility, responsive behavior, visual states and bundle impact.

## Backend Criteria

### Java / Spring Boot / Quarkus

- Review package/module boundaries, dependency direction, use cases/services/repositories and transaction scope.
- Check JPA/Panache queries, N+1 risks, indexes, migrations, locking and connection pools.
- Check blocking vs non-blocking code, thread safety, memory allocation and JVM performance.
- For Quarkus, check CDI scopes, build-time/runtime config, native-image impact and OpenTelemetry/health readiness.
- For microservices, check service boundaries, distributed transaction avoidance, eventual consistency, outbox/inbox and compensation.
- For Kafka, check schema compatibility, keys, partitions, ordering, retries, dead-letter handling and replay behavior.
- For Kubernetes/OpenShift, check readiness/liveness/startup probes, resource requests/limits, graceful shutdown and config/secrets.

### NestJS / Node.js

- Review module boundaries, controllers, providers, DTOs, guards, interceptors, pipes and exception filters.
- Check async error handling, request lifecycle, background jobs, queue consumers and backpressure.
- Check ORM transaction boundaries, migrations, query plans, connection pools and data validation.
- Validate lint, unit tests and e2e tests where the project supports them.

### Python

- Identify whether the code is API, automation, ETL, data pipeline or script before changing structure.
- Check type hints, pydantic/schema validation, logging, retries, idempotency and failure recovery.
- Watch memory use for large files/dataframes; prefer streaming or chunking when needed.
- Validate with pytest and representative data/failure cases.

### PHP

- Identify Laravel, CodeIgniter or custom architecture before changing structure.
- Check request validation, middleware, auth/authz, SQL injection, CSRF, escaping and file upload safety.
- Preserve legacy behavior unless the SPEC/test plan explicitly defines a migration.
- Validate with the project's available test, lint or framework commands.

## Database Criteria

- PostgreSQL, Oracle, MySQL, DB2 and SQL Server changes must include index and query-plan thinking.
- Check transaction isolation, lock scope, deadlocks, batch size, pagination and migration rollback.
- Never assume production write access; default database MCP access should be read-only unless explicitly approved.

## Review Output Format

For code review, return:

1. Findings first, ordered by severity.
2. File and line references when available.
3. Why it is a problem.
4. Production impact.
5. Recommended fix.
6. Improved code example only when useful.
7. Tests or validation still required.
`;

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

function copyGitSubdir(repoUrl, subdir, target) {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "mcp-control-skill-"));
  try {
    execFileSync("git", ["clone", "--depth", "1", repoUrl, temp], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });
    fs.cpSync(path.join(temp, subdir), target, { recursive: true });
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
}

function assertRepoPath(repoPath) {
  const resolved = path.resolve(repoPath || DEFAULT_REPO);
  const allowedPrefix = `${SITES_DIR}${path.sep}`;
  if (!resolved.startsWith(allowedPrefix)) {
    throw new Error(`Refusing path outside $HOME/Sites: ${resolved}`);
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

function parseCredentialFile(file) {
  if (!exists(file)) return {};
  const env = {};
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const idx = trimmed.indexOf("=");
    if (idx < 0) continue;
    const key = trimmed.slice(0, idx).trim();
    let value = trimmed.slice(idx + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    env[key] = value;
  }
  return env;
}

function repoCredentials(repoPath) {
  const repo = assertRepoPath(repoPath);
  const file = process.env.MCP_CREDENTIAL_FILE || path.join(repo, "credential_mcp.env");
  return {
    repo,
    file,
    env: parseCredentialFile(file),
  };
}

function firstValue(env, keys) {
  for (const key of keys) {
    if (env[key]) return env[key];
    if (process.env[key]) return process.env[key];
  }
  return "";
}

function basicAuth(user, token) {
  return `Basic ${Buffer.from(`${user}:${token}`).toString("base64")}`;
}

function authHeaders(env, service) {
  if (service === "jira") {
    const bearer = firstValue(env, ["JIRA_BEARER_TOKEN", "ATLASSIAN_REMOTE_PERSONAL_ACCESS_TOKEN"]);
    if (bearer) return { Authorization: `Bearer ${bearer}` };
    const email = firstValue(env, ["JIRA_EMAIL", "ATLASSIAN_EMAIL"]);
    const token = firstValue(env, ["JIRA_API_TOKEN", "ATLASSIAN_API_TOKEN"]);
    if (email && token) return { Authorization: basicAuth(email, token) };
    throw new Error("Missing Jira credentials. Set JIRA_EMAIL + JIRA_API_TOKEN, or JIRA_BEARER_TOKEN, in credential_mcp.env.");
  }

  if (service === "bitbucket") {
    const bearer = firstValue(env, ["BITBUCKET_BEARER_TOKEN", "BITBUCKET_PERSONAL_ACCESS_TOKEN"]);
    if (bearer) return { Authorization: `Bearer ${bearer}` };
    const user = firstValue(env, ["BITBUCKET_USERNAME"]);
    const token = firstValue(env, ["BITBUCKET_HTTP_TOKEN", "BITBUCKET_PASSWORD"]);
    if (user && token) return { Authorization: basicAuth(user, token) };
    throw new Error("Missing Bitbucket credentials. Set BITBUCKET_BEARER_TOKEN or BITBUCKET_USERNAME + BITBUCKET_HTTP_TOKEN in credential_mcp.env.");
  }

  return {};
}

function normalizeBaseUrl(url, name) {
  if (!url) throw new Error(`Missing ${name} in credential_mcp.env.`);
  return url.replace(/\/+$/, "");
}

async function httpJson(url, headers) {
  const response = await fetch(url, {
    headers: {
      Accept: "application/json",
      ...headers,
    },
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`HTTP ${response.status} for ${url}: ${text.slice(0, 800)}`);
  }
  if (!text.trim()) return null;
  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

function jiraIssueKey(issueKeyOrUrl) {
  const value = String(issueKeyOrUrl || "").trim();
  const selectedIssue = value.match(/[?&]selectedIssue=([A-Z][A-Z0-9]+-\d+)/i);
  if (selectedIssue) return selectedIssue[1].toUpperCase();
  const direct = value.match(/\b([A-Z][A-Z0-9]+-\d+)\b/i);
  if (direct) return direct[1].toUpperCase();
  throw new Error("Could not parse Jira issue key. Provide TXP-1175 or a Jira URL with selectedIssue=TXP-1175.");
}

function bitbucketRepoDefaults(env, overrides = {}) {
  const projectKey = overrides.projectKey || firstValue(env, ["BITBUCKET_PROJECT_KEY"]);
  const repoSlug = overrides.repoSlug || firstValue(env, ["BITBUCKET_REPO_SLUG"]);
  if (!projectKey) throw new Error("Missing Bitbucket project key. Set BITBUCKET_PROJECT_KEY in credential_mcp.env or pass projectKey.");
  if (!repoSlug) throw new Error("Missing Bitbucket repository slug. Set BITBUCKET_REPO_SLUG in credential_mcp.env or pass repoSlug.");
  return { projectKey, repoSlug };
}

async function readJiraIssue(repoPath, issueKeyOrUrl) {
  const { repo, file, env } = repoCredentials(repoPath);
  const baseUrl = normalizeBaseUrl(firstValue(env, ["JIRA_BASE_URL", "ATLASSIAN_JIRA_BASE_URL"]), "JIRA_BASE_URL");
  const key = jiraIssueKey(issueKeyOrUrl);
  const fields = [
    "summary",
    "description",
    "status",
    "issuetype",
    "priority",
    "assignee",
    "reporter",
    "labels",
    "components",
    "fixVersions",
    "parent",
    "issuelinks",
    "subtasks",
    "created",
    "updated",
  ].join(",");
  const issue = await httpJson(`${baseUrl}/rest/api/3/issue/${encodeURIComponent(key)}?fields=${fields}`, authHeaders(env, "jira"));
  return {
    repo,
    credentialFile: file,
    issueKey: key,
    url: `${baseUrl}/browse/${key}`,
    issue,
  };
}

async function listBitbucketPullRequests(repoPath, options = {}) {
  const { repo, file, env } = repoCredentials(repoPath);
  const baseUrl = normalizeBaseUrl(firstValue(env, ["BITBUCKET_BASE_URL", "STASH_BASE_URL"]), "BITBUCKET_BASE_URL");
  const { projectKey, repoSlug } = bitbucketRepoDefaults(env, options);
  const state = options.state || "OPEN";
  const limit = Number(options.limit || 25);
  const url = `${baseUrl}/rest/api/1.0/projects/${encodeURIComponent(projectKey)}/repos/${encodeURIComponent(repoSlug)}/pull-requests?state=${encodeURIComponent(state)}&limit=${encodeURIComponent(limit)}`;
  const pullRequests = await httpJson(url, authHeaders(env, "bitbucket"));
  return {
    repo,
    credentialFile: file,
    baseUrl,
    projectKey,
    repoSlug,
    state,
    pullRequests,
  };
}

async function readBitbucketPullRequest(repoPath, options = {}) {
  const { repo, file, env } = repoCredentials(repoPath);
  const baseUrl = normalizeBaseUrl(firstValue(env, ["BITBUCKET_BASE_URL", "STASH_BASE_URL"]), "BITBUCKET_BASE_URL");
  const { projectKey, repoSlug } = bitbucketRepoDefaults(env, options);
  const prId = options.prId || options.pullRequestId;
  if (!prId) throw new Error("Missing prId.");
  const headers = authHeaders(env, "bitbucket");
  const root = `${baseUrl}/rest/api/1.0/projects/${encodeURIComponent(projectKey)}/repos/${encodeURIComponent(repoSlug)}/pull-requests/${encodeURIComponent(prId)}`;
  const [pullRequest, activities, changes] = await Promise.all([
    httpJson(root, headers),
    httpJson(`${root}/activities?limit=${encodeURIComponent(Number(options.activityLimit || 100))}`, headers),
    httpJson(`${root}/changes?limit=${encodeURIComponent(Number(options.changeLimit || 300))}`, headers),
  ]);
  const result = {
    repo,
    credentialFile: file,
    baseUrl,
    projectKey,
    repoSlug,
    prId,
    pullRequest,
    activities,
    changes,
  };
  if (options.includeDiff) {
    result.diff = await httpJson(`${root}/diff?contextLines=${encodeURIComponent(Number(options.contextLines || 10))}`, headers);
  }
  return result;
}

function globalStatus() {
  const codexConfig = path.join(HOME, ".codex/config.toml");
  const antigravityConfig = path.join(HOME, ".gemini/antigravity/mcp_config.json");
  const antigravityJson = readJson(antigravityConfig);
  const codexText = exists(codexConfig) ? fs.readFileSync(codexConfig, "utf8") : "";

  return {
    codex: {
      config: codexConfig,
      hasMcpControl: codexText.includes("[mcp_servers.mcp-control]"),
      hasOpenAiDocs: codexText.includes("[mcp_servers.openaiDeveloperDocs]"),
      hasJetBrains: codexText.includes("[mcp_servers.jetbrains]"),
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
      configured: listFiles(profileDir, (name) => name.endsWith(".md"))
        .map((file) => path.basename(file, ".md"))
        .filter((name) => name !== "README"),
      expected: Object.keys(PROFILE_TEXT),
      defaultSkills: PROFILE_SKILLS,
    },
    rules: {
      agentRules: listFiles(path.join(repo, ".agents/rules")).map((file) => path.relative(repo, file)),
      workflows: listFiles(path.join(repo, ".agents/workflows")).map((file) => path.relative(repo, file)),
      profileEngineeringRules: exists(path.join(repo, ".agents/rules/profile-engineering.md")),
    },
    skills: {
      graphifyGlobal: exists(path.join(HOME, ".agents/skills/graphify/SKILL.md")),
      graphifyProjectRules: exists(path.join(repo, ".agents/rules/graphify.md")),
      impeccableProjectHints: exists(path.join(repo, "PRODUCT.md")) || exists(path.join(repo, "DESIGN.md")),
      tasteProjectProfile: exists(path.join(repo, ".agents/skills/taste.md")) || exists(path.join(repo, "docs/design/TASTE.md")),
      huashuProjectHints: exists(path.join(repo, ".agents/skills/huashu.md")),
      huashuDesignSkill: exists(path.join(repo, ".agents/skills/huashu-design/SKILL.md")),
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
  const skillsToInstall = new Set();
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
    for (const skill of PROFILE_SKILLS[profile]) {
      skillsToInstall.add(skill);
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
- code-review

Default skills by profile:
- frontend: Impeccable, Taste, Graphify
- backend: Impeccable, Graphify
- product-architecture: Impeccable, Huashu, Graphify
- code-review: Impeccable, Taste, Graphify
`, "utf8");
  }

  const profileRules = path.join(repo, ".agents/rules/profile-engineering.md");
  changes.push({ action: exists(profileRules) ? "update" : "create", target: profileRules });
  if (apply) {
    fs.mkdirSync(path.dirname(profileRules), { recursive: true });
    fs.writeFileSync(profileRules, PROFILE_RULES_TEXT, "utf8");
  }

  const skillResults = [];
  for (const skill of skillsToInstall) {
    skillResults.push(installSkill(repo, skill, apply));
  }

  return {
    repo,
    apply,
    changes,
    defaultSkills: Object.fromEntries(wanted.map((profile) => [profile, PROFILE_SKILLS[profile]])),
    skillResults,
    next: apply ? "Review git diff and commit in the target repository." : "Re-run with apply=true to write files.",
  };
}

function installSkill(repoPath, skill, apply) {
  const repo = assertRepoPath(repoPath);
  const commands = [];
  const fileChanges = [];
  const dirChanges = [];
  const symlinkChanges = [];

  if (skill === "graphify") {
    commands.push(["graphify", "antigravity", "install"]);
  } else if (skill === "impeccable") {
    for (const name of ["PRODUCT.md", "DESIGN.md"]) {
      const source = path.join(MCP_REPO, "templates/frontend", `${name}.example`);
      const target = path.join(repo, name);
      fileChanges.push({ source, target });
    }
    commands.push(["npx", "skills", "add", "pbakaus/impeccable"]);
  } else if (skill === "huashu") {
    fileChanges.push({
      target: path.join(repo, ".agents/skills/huashu.md"),
      content: `# Huashu Design

Use Huashu for visual exploration, prototypes, decks, animations and infographics.

Rules:
- Use it for ideation and visual proposals.
- Validate generated UI with Playwright or screenshots.
- Do not replace an existing design system without review.
`,
    });
    dirChanges.push({
      target: path.join(repo, ".agents/skills/huashu-design"),
      repoUrl: "https://github.com/alchaincyf/huashu-skills.git",
      subdir: "huashu-design",
    });
    symlinkChanges.push({
      target: path.join(repo, ".agent/skills/huashu-design"),
      linkTo: "../../.agents/skills/huashu-design",
    });
  } else if (skill === "taste") {
    fileChanges.push({
      target: path.join(repo, ".agents/skills/taste.md"),
      content: TASTE_TEXT,
    });
    fileChanges.push({
      target: path.join(repo, "docs/design/TASTE.md"),
      content: TASTE_TEXT,
    });
  } else {
    throw new Error("Unknown skill. Allowed: graphify, impeccable, huashu, taste");
  }

  const results = [];
  for (const change of fileChanges) {
    const existsAlready = exists(change.target);
    results.push({
      file: change.target,
      status: apply ? (existsAlready ? "kept-existing" : "created") : (existsAlready ? "would-keep-existing" : "would-create"),
    });
    if (apply && !existsAlready) {
      fs.mkdirSync(path.dirname(change.target), { recursive: true });
      if (change.source) {
        fs.copyFileSync(change.source, change.target);
      } else {
        fs.writeFileSync(change.target, change.content, "utf8");
      }
    }
  }

  for (const change of dirChanges) {
    const existsAlready = exists(change.target);
    results.push({
      directory: change.target,
      status: apply ? (existsAlready ? "kept-existing" : "created") : (existsAlready ? "would-keep-existing" : "would-create"),
    });
    if (apply && !existsAlready) {
      fs.mkdirSync(path.dirname(change.target), { recursive: true });
      copyGitSubdir(change.repoUrl, change.subdir, change.target);
    }
  }

  for (const change of symlinkChanges) {
    const existsAlready = exists(change.target);
    results.push({
      symlink: change.target,
      linkTo: change.linkTo,
      status: apply ? (existsAlready ? "kept-existing" : "created") : (existsAlready ? "would-keep-existing" : "would-create"),
    });
    if (apply && !existsAlready) {
      fs.mkdirSync(path.dirname(change.target), { recursive: true });
      fs.symlinkSync(change.linkTo, change.target);
    }
  }

  for (const command of commands) {
    if (!apply) {
      results.push({ command: command.join(" "), status: "dry-run" });
      continue;
    }
    try {
      const env = { ...process.env };
      if (command[0] === "npx") {
        env.NPM_CONFIG_REGISTRY = "https://registry.npmjs.org/";
        env.npm_config_registry = "https://registry.npmjs.org/";
        env.npm_config_always_auth = "false";
      }
      const output = execFileSync(command[0], command.slice(1), {
        cwd: repo,
        env,
        encoding: "utf8",
        stdio: ["ignore", "pipe", "pipe"],
      });
      results.push({ command: command.join(" "), status: "applied", output: output.trim() });
    } catch (error) {
      results.push({
        command: command.join(" "),
        status: "failed",
        error: String(error.stderr || error.message).trim(),
      });
    }
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
        description: "Inspect global MCP configuration status for Codex and Antigravity.",
        inputSchema: { type: "object", properties: {} },
      },
      {
        name: "inspect_repository_profiles",
        description: "Inspect profiles, skills, rules and Graphify artifacts in a repository.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string", description: "Repository path under $HOME/Sites" },
          },
        },
      },
      {
        name: "install_repository_profiles",
        description: "Create or update standard agent profile files and their default skills inside a repository.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            profiles: {
              type: "array",
              items: { type: "string", enum: ["frontend", "backend", "product-architecture", "code-review"] },
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
            skill: { type: "string", enum: ["graphify", "impeccable", "huashu", "taste"] },
            apply: { type: "boolean", description: "When false, returns commands only." },
          },
          required: ["skill"],
        },
      },
      {
        name: "read_jira_issue",
        description: "Read a Jira issue using per-repository credential_mcp.env. Read-only.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            issueKeyOrUrl: { type: "string", description: "Issue key like TXP-1175 or a Jira URL." },
          },
          required: ["issueKeyOrUrl"],
        },
      },
      {
        name: "list_bitbucket_pull_requests",
        description: "List Bitbucket Server/Data Center pull requests using per-repository credential_mcp.env. Read-only.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            projectKey: { type: "string" },
            repoSlug: { type: "string" },
            state: { type: "string", enum: ["OPEN", "MERGED", "DECLINED", "ALL"] },
            limit: { type: "number" },
          },
        },
      },
      {
        name: "read_bitbucket_pull_request",
        description: "Read Bitbucket Server/Data Center PR metadata, activities, changed files and optional diff. Read-only.",
        inputSchema: {
          type: "object",
          properties: {
            repoPath: { type: "string" },
            projectKey: { type: "string" },
            repoSlug: { type: "string" },
            prId: { type: "number" },
            includeDiff: { type: "boolean" },
            contextLines: { type: "number" },
            activityLimit: { type: "number" },
            changeLimit: { type: "number" },
          },
          required: ["prId"],
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
    } else if (request.params.name === "read_jira_issue") {
      result = await readJiraIssue(args.repoPath, args.issueKeyOrUrl);
    } else if (request.params.name === "list_bitbucket_pull_requests") {
      result = await listBitbucketPullRequests(args.repoPath, args);
    } else if (request.params.name === "read_bitbucket_pull_request") {
      result = await readBitbucketPullRequest(args.repoPath, args);
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
