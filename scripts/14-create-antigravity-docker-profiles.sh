#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
PROFILE="${PROFILE:-all}"

CATALOG="mcp/docker-mcp-catalog:latest"

create_profile() {
  local id="$1"
  local name="$2"
  shift 2

  echo
  echo "== $id =="
  if docker mcp profile show "$id" >/dev/null 2>&1; then
    echo "OK   profile already exists"
    return 0
  fi

  if [ "$APPLY" != "1" ]; then
    echo "DRY  would create profile '$id' ($name)"
    printf '     %s\n' "$@"
    return 0
  fi

  docker mcp profile create --id "$id" --name "$name" "$@"
}

configure_database_allowlist() {
  local id="antigravity-database-readonly"

  if [ "$APPLY" != "1" ]; then
    echo "DRY  would restrict database profile tools to read-only metadata/query tools"
    return 0
  fi

  docker mcp profile tools "$id" \
    --disable-all oracle \
    --enable oracle.list_schemas \
    --enable oracle.list_tables \
    --enable oracle.describe_table \
    --enable oracle.get_table_constraints \
    --enable oracle.get_table_indexes
}

echo "== Antigravity Docker MCP profile creation =="
echo "PROFILE=$PROFILE"
echo "APPLY=$APPLY"
echo

docker mcp catalog pull "$CATALOG" >/dev/null

case "$PROFILE" in
  all|frontend|backend|product-architecture|database-readonly)
    ;;
  *)
    echo "Unknown PROFILE=$PROFILE"
    echo "Allowed: all, frontend, backend, product-architecture, database-readonly"
    exit 1
    ;;
esac

if [ "$PROFILE" = "frontend" ]; then
  echo "INFO antigravity-frontend is managed by the existing setup flow."
fi

if [ "$PROFILE" = "all" ] || [ "$PROFILE" = "backend" ]; then
  create_profile \
    antigravity-backend \
    "Antigravity Backend" \
    --server "catalog://$CATALOG/github-official" \
    --server "catalog://$CATALOG/context7" \
    --server "catalog://$CATALOG/sequentialthinking" \
    --server "catalog://$CATALOG/docker-docs" \
    --server "catalog://$CATALOG/maven-tools-mcp" \
    --server "catalog://$CATALOG/javadocs" \
    --server "catalog://$CATALOG/openapi" \
    --server "catalog://$CATALOG/node-code-sandbox"
fi

if [ "$PROFILE" = "all" ] || [ "$PROFILE" = "product-architecture" ]; then
  create_profile \
    antigravity-product-architecture \
    "Antigravity Product Architecture" \
    --server "catalog://$CATALOG/github-official" \
    --server "catalog://$CATALOG/obsidian" \
    --server "catalog://$CATALOG/context7" \
    --server "catalog://$CATALOG/sequentialthinking" \
    --server "catalog://$CATALOG/docker-docs" \
    --server "catalog://$CATALOG/openapi"
fi

if [ "$PROFILE" = "all" ] || [ "$PROFILE" = "database-readonly" ]; then
  create_profile \
    antigravity-database-readonly \
    "Antigravity Database Readonly" \
    --server "catalog://$CATALOG/oracle"
  configure_database_allowlist
fi

echo
echo "Profiles:"
docker mcp profile list
