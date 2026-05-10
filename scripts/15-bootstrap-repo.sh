#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
TARGET_REPO="${TARGET_REPO:-${1:-}}"
RUN_GRAPHIFY="${RUN_GRAPHIFY:-1}"
UPDATE_OBSIDIAN="${UPDATE_OBSIDIAN:-1}"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-/Users/rafaelpereirafreitas/Documents/Obsidian Vault}"
MCP_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCP_SERVER="$MCP_REPO/mcp-control/src/server.js"

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: TARGET_REPO=/Users/rafaelpereirafreitas/Sites/repo APPLY=1 $0"
  exit 2
fi

REPO="$(cd "$TARGET_REPO" && pwd)"
case "$REPO" in
  /Users/rafaelpereirafreitas/Sites/*) ;;
  *)
    echo "Refusing path outside /Users/rafaelpereirafreitas/Sites: $REPO"
    exit 2
    ;;
esac

repo_name="$(basename "$REPO")"
today="$(date +%F)"

has_file() {
  local pattern="$1"
  find "$REPO" -maxdepth 5 -name "$pattern" \
    -not -path '*/node_modules/*' \
    -not -path '*/vendor/*' \
    -not -path '*/target/*' \
    -not -path '*/dist/*' \
    -print -quit | grep -q .
}

has_rg() {
  local pattern="$1"
  rg -q "$pattern" "$REPO" \
    --glob 'package.json' \
    --glob '!**/node_modules/**' \
    --glob '!**/dist/**' \
    --glob '!**/target/**' 2>/dev/null
}

has_angular=0
has_react=0
has_next=0
has_java=0
has_quarkus=0
has_spring=0
has_nest=0
has_node=0
has_python=0
has_php=0

if has_file angular.json || has_rg '"@angular/core"'; then has_angular=1; fi
if has_rg '"react"'; then has_react=1; fi
if has_rg '"next"'; then has_next=1; fi
if has_file pom.xml || has_file build.gradle || has_file build.gradle.kts; then has_java=1; fi
if rg -q "io.quarkus|quarkus-" "$REPO" --glob 'pom.xml' --glob 'build.gradle*' --glob '!**/target/**' 2>/dev/null; then has_quarkus=1; fi
if rg -q "spring-boot|org.springframework.boot" "$REPO" --glob 'pom.xml' --glob 'build.gradle*' --glob '!**/target/**' 2>/dev/null; then has_spring=1; fi
if has_file nest-cli.json || has_rg '"@nestjs/core"'; then has_nest=1; fi
if has_file package.json; then has_node=1; fi
if has_file pyproject.toml || has_file requirements.txt || has_file setup.py || has_file Pipfile; then has_python=1; fi
if has_file composer.json || has_file artisan || has_file index.php; then has_php=1; fi

has_frontend=0
has_backend=0
if [ "$has_angular" = "1" ] || [ "$has_react" = "1" ] || [ "$has_next" = "1" ]; then has_frontend=1; fi
if [ "$has_java" = "1" ] || [ "$has_nest" = "1" ] || [ "$has_python" = "1" ] || [ "$has_php" = "1" ]; then has_backend=1; fi

repo_type="unknown"
if [ "$has_frontend" = "1" ] && [ "$has_backend" = "1" ]; then
  repo_type="fullstack-monorepo"
elif [ "$has_angular" = "1" ]; then
  repo_type="angular"
elif [ "$has_next" = "1" ]; then
  repo_type="react-next"
elif [ "$has_react" = "1" ]; then
  repo_type="react"
elif [ "$has_quarkus" = "1" ]; then
  repo_type="java-quarkus"
elif [ "$has_spring" = "1" ]; then
  repo_type="java-spring"
elif [ "$has_java" = "1" ]; then
  repo_type="java"
elif [ "$has_nest" = "1" ]; then
  repo_type="nestjs"
elif [ "$has_python" = "1" ]; then
  repo_type="python"
elif [ "$has_php" = "1" ]; then
  repo_type="php"
elif [ "$has_node" = "1" ]; then
  repo_type="node"
fi

profiles=(product-architecture)
if [ "$has_frontend" = "1" ]; then profiles+=(frontend); fi
if [ "$has_backend" = "1" ] || [ "$repo_type" = "node" ]; then profiles+=(backend); fi
if [ "${#profiles[@]}" -eq 1 ]; then profiles+=(frontend backend); fi

profile_json="$(printf '%s\n' "${profiles[@]}" | jq -R . | jq -s .)"
apply_json="false"
if [ "$APPLY" = "1" ]; then apply_json="true"; fi

echo "== Repository bootstrap =="
echo "Repo:           $REPO"
echo "Type:           $repo_type"
echo "Profiles:       ${profiles[*]}"
echo "APPLY:          $APPLY"
echo "RUN_GRAPHIFY:   $RUN_GRAPHIFY"
echo "UPDATE_OBSIDIAN:$UPDATE_OBSIDIAN"
echo

write_file() {
  local target="$1"
  local content="$2"
  if [ "$APPLY" != "1" ]; then
    echo "DRY  would write $target"
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  printf '%s\n' "$content" > "$target"
  echo "OK   wrote $target"
}

append_gitignore_once() {
  local gitignore="$REPO/.gitignore"
  local marker="# mcp bootstrap defaults"
  if [ "$APPLY" != "1" ]; then
    echo "DRY  would append .gitignore defaults"
    return 0
  fi
  touch "$gitignore"
  if ! rg -q "^$marker$" "$gitignore"; then
    printf '\n%s\n' "$marker" >> "$gitignore"
  fi
  local patterns=(
    ".DS_Store"
    ".idea/"
    ".vscode/"
    ".env"
    ".env.*"
    "!.env.example"
    "credential_mcp.env"
    "!credential_mcp.env.example"
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"
    "node_modules/"
    "dist/"
    "build/"
    ".angular/"
    ".next/"
    "out/"
    "coverage/"
    "target/"
    ".venv/"
    "__pycache__/"
    ".pytest_cache/"
    "vendor/"
    "graphify-out/"
    "deploy/keys/"
  )
  for pattern in "${patterns[@]}"; do
    if ! rg -q --fixed-strings --line-regexp "$pattern" "$gitignore"; then
      echo "$pattern" >> "$gitignore"
    fi
  done
  echo "OK   updated $gitignore"
}

repo_stack_content="# Repository Stack Profile

Generated by: scripts/15-bootstrap-repo.sh
Date: $today

## Detected type

\`\`\`text
$repo_type
\`\`\`

## Detected stacks

- Angular: $has_angular
- React: $has_react
- Next.js: $has_next
- Java: $has_java
- Quarkus: $has_quarkus
- Spring Boot: $has_spring
- NestJS: $has_nest
- Node.js: $has_node
- Python: $has_python
- PHP: $has_php

## Active profiles

$(printf -- '- `%s`\n' "${profiles[@]}")

## Stack-specific guidance

- Angular: validate modules/routes, RxJS lifecycle, typed forms, accessibility and Playwright screenshots.
- React/Next.js: validate client/server boundaries, hooks, hydration, cache, loading/error states and bundle impact.
- Java/Quarkus/Spring: validate transactions, JPA/Panache, Kafka contracts, JVM behavior, health checks and Kubernetes/OpenShift settings.
- NestJS: validate modules, DTOs, pipes, guards, interceptors, async errors, ORM transactions and e2e tests.
- Python: validate typing, schema validation, logging, idempotency, retries, streaming/chunking and pytest.
- PHP: validate framework conventions, request validation, auth middleware, SQL safety, CSRF and output escaping.
- Fullstack/monorepo: plan with product-architecture first, then run frontend/backend separately.
"

request="$(jq -cn \
  --arg repo "$REPO" \
  --argjson profiles "$profile_json" \
  --argjson apply "$apply_json" \
  '{jsonrpc:"2.0", id:1, method:"tools/call", params:{name:"install_repository_profiles", arguments:{repoPath:$repo, profiles:$profiles, apply:$apply}}}')"

echo "== Installing profiles and default skills via mcp-control =="
printf '%s\n' "$request" | node "$MCP_SERVER" | sed -n '1,260p'

echo
echo "== Writing repository stack profile =="
write_file "$REPO/.agents/profiles/repo-stack.md" "$repo_stack_content"

echo
echo "== Updating .gitignore =="
append_gitignore_once

credential_example_content="# credential_mcp.env.example
#
# Copy to credential_mcp.env inside this repository and fill only the providers used by this repo.
# Do not commit credential_mcp.env.

# Azure DevOps MCP
AZURE_DEVOPS_ORG=
AZURE_DEVOPS_PROJECT=
AZURE_DEVOPS_TEAM=

# Jira Cloud / Jira Server
JIRA_BASE_URL=
JIRA_EMAIL=
JIRA_API_TOKEN=
JIRA_BEARER_TOKEN=

# Bitbucket Server/Data Center/Stash
BITBUCKET_BASE_URL=
BITBUCKET_PROJECT_KEY=
BITBUCKET_REPO_SLUG=
BITBUCKET_USERNAME=
BITBUCKET_HTTP_TOKEN=
BITBUCKET_BEARER_TOKEN=

# Docker MCP Gateway secrets file keys.
# Keep the dotted names because Docker MCP reads them as secret IDs.
github.personal_access_token=
gitlab.personal_access_token=
atlassian-remote.personal_access_token=

# Optional aliases for tools that expect environment-style names.
GITHUB_PERSONAL_ACCESS_TOKEN=
GITLAB_PERSONAL_ACCESS_TOKEN=
ATLASSIAN_REMOTE_PERSONAL_ACCESS_TOKEN=
"

echo
echo "== MCP credential template =="
if [ -f "$REPO/credential_mcp.env.example" ]; then
  echo "OK   credential_mcp.env.example already exists"
else
  write_file "$REPO/credential_mcp.env.example" "$credential_example_content"
fi

if [ "$RUN_GRAPHIFY" = "1" ]; then
  echo
  echo "== Graphify =="
  if ! command -v graphify >/dev/null 2>&1; then
    echo "MISS graphify command not found; skipping graph generation"
  elif [ "$APPLY" != "1" ]; then
    echo "DRY  would run: graphify extract . --backend gemini"
    echo "DRY  would run: graphify cluster-only ."
  else
    (cd "$REPO" && graphify extract . --backend gemini && graphify cluster-only .)
  fi
fi

if [ "$UPDATE_OBSIDIAN" = "1" ]; then
  echo
  echo "== Obsidian project note =="
  project_dir="$OBSIDIAN_VAULT/10-Projects/$repo_name"
  overview="$project_dir/Project Overview.md"
  snapshot="$project_dir/Repo Snapshot.md"
  decision="$project_dir/Decision Log.md"
  runbook="$project_dir/Runbook.md"
  model="$project_dir/AI Agent Operating Model.md"

  overview_content="---
type: project-overview
project: $repo_name
updated_at: $today
tags:
  - project
  - bootstrap
---

# $repo_name

Repository bootstrapped from the MCP setup kit.

## Path

\`\`\`text
$REPO
\`\`\`

## Detected type

\`\`\`text
$repo_type
\`\`\`
"

  snapshot_content="---
type: repo-snapshot
project: $repo_name
updated_at: $today
tags:
  - repo
  - snapshot
---

# Repo Snapshot

Path: \`$REPO\`

Detected stacks:
- Angular: $has_angular
- React: $has_react
- Next.js: $has_next
- Java: $has_java
- Quarkus: $has_quarkus
- Spring Boot: $has_spring
- NestJS: $has_nest
- Node.js: $has_node
- Python: $has_python
- PHP: $has_php

Profiles:
$(printf -- '- `%s`\n' "${profiles[@]}")
"

  decision_content="---
type: decision-log
project: $repo_name
updated_at: $today
tags:
  - decision-log
---

# Decision Log

## Entries

- $today: Repository bootstrapped with MCP profiles, default skills, stack profile, .gitignore defaults and Graphify workflow.
"

  runbook_content="---
type: runbook
project: $repo_name
updated_at: $today
tags:
  - runbook
---

# Runbook

## Bootstrap

\`\`\`bash
TARGET_REPO=$REPO APPLY=1 ./scripts/15-bootstrap-repo.sh
\`\`\`

## Graphify refresh

\`\`\`bash
cd $REPO
graphify extract . --backend gemini
graphify cluster-only .
\`\`\`
"

  model_content="---
type: operating-model
project: $repo_name
updated_at: $today
tags:
  - ai-engineering
  - operating-model
---

# AI Agent Operating Model

Use profiles in sequence:

\`\`\`text
product-architecture -> frontend/backend -> code review inside the specialist profile
\`\`\`

Active profiles:
$(printf -- '- `%s`\n' "${profiles[@]}")
"

  if [ "$APPLY" != "1" ]; then
    echo "DRY  would create/update $project_dir"
  else
    mkdir -p "$project_dir"
    [ -f "$overview" ] || printf '%s\n' "$overview_content" > "$overview"
    printf '%s\n' "$snapshot_content" > "$snapshot"
    if [ -f "$decision" ]; then
      if ! rg -q "Repository bootstrapped with MCP profiles" "$decision"; then
        printf '%s\n' "- $today: Repository bootstrapped with MCP profiles, default skills, stack profile, .gitignore defaults and Graphify workflow." >> "$decision"
      fi
    else
      printf '%s\n' "$decision_content" > "$decision"
    fi
    [ -f "$runbook" ] || printf '%s\n' "$runbook_content" > "$runbook"
    printf '%s\n' "$model_content" > "$model"
    echo "OK   updated $project_dir"
  fi
fi

echo
echo "Bootstrap completed."
