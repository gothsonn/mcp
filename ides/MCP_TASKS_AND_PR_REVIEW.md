# MCPs para tarefas e PRs

## Objetivo

Separar dois fluxos:

1. `task-intake`: ler Jira ou Azure DevOps Boards, entender demanda,
   criterios de aceite, dependencias, anexos e links.
2. `pr-review`: ler PR/MR em Bitbucket, GitHub, GitLab ou Azure DevOps,
   avaliar diff, comentarios, status de pipeline e aderencia a tarefa.

Essa separacao evita carregar ferramentas demais em uma IDE, reduz conflito de
nomes e respeita o limite de tools do Antigravity.

## Recomendacao por provedor

| Provedor | Fluxo | MCP recomendado | Observacao |
| --- | --- | --- | --- |
| Jira Cloud | `task-intake` | Atlassian Rovo MCP | OAuth 2.1; respeita permissoes do usuario. |
| Azure DevOps Boards | `task-intake` | `@azure-devops/mcp` | Usar dominios `core`, `work`, `work-items`. |
| GitHub PR | `pr-review` | GitHub Official MCP / plugin GitHub do Codex | Preferir plugin no Codex; gateway no Antigravity. |
| GitLab MR | `pr-review` | GitLab MCP HTTP | Requer GitLab Premium/Ultimate e recurso MCP disponivel. |
| Bitbucket PR | `pr-review` | Atlassian Rovo / Bitbucket MCP | Usar somente com scopes de PR/pipeline necessarios. |
| Azure DevOps PR | `pr-review` | `@azure-devops/mcp` | Usar dominios `core`, `repositories`, `pipelines`. |

## Antigravity

Criar os perfis Docker MCP Gateway:

```bash
APPLY=1 PROFILE=task-intake ./scripts/14-create-antigravity-docker-profiles.sh
APPLY=1 PROFILE=pr-review ./scripts/14-create-antigravity-docker-profiles.sh
```

Configurar um perfil por vez:

```bash
APPLY=1 PROFILE=gateway-task-intake-stdio ./scripts/05-configure-antigravity.sh
PROFILE=antigravity-task-intake ./scripts/08-validate-antigravity-mcp.sh

APPLY=1 PROFILE=gateway-pr-review-stdio ./scripts/05-configure-antigravity.sh
PROFILE=antigravity-pr-review ./scripts/08-validate-antigravity-mcp.sh
```

O Azure DevOps nao entra no Docker Gateway neste kit porque o catalogo local
validado nao expos um servidor Azure DevOps dedicado. Use o MCP oficial via
`npx @azure-devops/mcp` no Codex/Cursor.

Autenticacao necessaria:

```bash
docker mcp oauth authorize atlassian-remote
docker mcp secret set github.personal_access_token
docker mcp secret set gitlab.personal_access_token
```

Use tokens com escopo minimo. Para Bitbucket/Jira Cloud, prefira OAuth do
Atlassian Rovo MCP quando a sua organizacao permitir.

## Cursor

Templates:

```text
templates/cursor/mcp.task-intake.example.json
templates/cursor/mcp.pr-review.example.json
```

Antes de habilitar Azure DevOps:

```bash
export AZURE_DEVOPS_ORG="sua-organizacao"
```

Depois mesclar no `~/.cursor/mcp.json` apenas os provedores usados no dia.

## Codex

Template complementar:

```text
templates/codex/config.task-intake-pr-review.toml.example
```

No Codex, manter GitHub pelo plugin `github@openai-curated` quando possivel.
Adicionar MCP direto para Atlassian, GitLab ou Azure DevOps somente quando a
tarefa exigir.

## Fluxo de uso

### Ler tarefa

Prompt base:

```text
Use o MCP de task-intake para ler a tarefa <ID ou URL>.
Extraia: objetivo, contexto de negocio, criterios de aceite, escopo fora,
dependencias, riscos, links, anexos e impacto tecnico.
Depois gere um FEATURE-SPEC.md antes de implementar.
```

### Avaliar PR

Prompt base:

```text
Use o MCP de pr-review para avaliar o PR <URL>.
Compare contra a tarefa/spec vinculada, leia comentarios existentes,
diff, arquivos alterados, status de pipeline e testes.
Responda com findings por severidade, impacto em producao e sugestao objetiva.
Nao aprove, mergeie ou comente no PR sem confirmacao explicita.
```

## Segurança

- Nunca versionar tokens, PATs, refresh tokens ou `.env`.
- Usar OAuth quando o provedor suportar.
- Habilitar somente o provedor necessario para o trabalho atual.
- Para PR review, começar read-only; comentarios/aprovacao/merge exigem
  confirmacao humana.
- Para Azure DevOps, usar dominios filtrados para nao carregar todas as tools.

## Referencias

- Atlassian Rovo MCP: https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/
- Bitbucket Cloud MCP: https://support.atlassian.com/bitbucket-cloud/docs/interacting-with-bitbucket-via-mcp/
- Azure DevOps MCP: https://github.com/microsoft/azure-devops-mcp
- GitLab MCP: https://docs.gitlab.com/user/gitlab_duo/model_context_protocol/mcp_server/
- Docker MCP Catalog: https://docs.docker.com/ai/mcp-catalog-and-toolkit/catalog/
