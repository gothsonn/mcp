# MCP Control global

## Objetivo

Ter um MCP global em Codex, Cursor e Antigravity para controlar a configuracao de perfis, regras e skills por repositorio.

Servidor:

```text
/Users/rafaelpereirafreitas/Sites/mcp/mcp-control/src/server.js
```

Nome MCP:

```text
mcp-control
```

## Tools

| Tool | Uso |
| --- | --- |
| `global_mcp_status` | Verifica se Codex, Cursor e Antigravity tem `mcp-control` configurado. |
| `inspect_repository_profiles` | Lista perfis, regras, skills e artefatos Graphify de um repositorio. |
| `install_repository_profiles` | Cria perfis padrao em `.agents/profiles/` e instala as skills padrao do perfil dentro do repo. |
| `install_repository_skill` | Instala regras/skills suportadas por repo: `graphify`, `impeccable`, `huashu`, `taste`. |

## Perfis padrao

- `frontend`: especialista frontend + code review.
- `backend`: especialista backend + code review.
- `product-architecture`: PO + PM + Arquiteto + Engenheiro de software.
- `code-review`: review especializado depois da implementacao.

## Skills padrao por perfil

| Perfil | Skills instaladas no repo |
| --- | --- |
| `frontend` | Impeccable, Taste, Graphify |
| `backend` | Impeccable, Graphify |
| `product-architecture` | Impeccable, Huashu, Graphify |
| `code-review` | Impeccable, Taste, Graphify |

## Configuracao

```bash
APPLY=1 ./scripts/12-configure-global-mcp-control.sh
./scripts/13-validate-global-mcp-control.sh
```

Codex, Cursor e Antigravity sao configurados automaticamente pelo script.

Para JetBrains AI / Junie, usar o JSON em:

```text
templates/jetbrains/mcp-control.json
```

A documentacao atual da JetBrains orienta adicionar MCPs externos por configuracao JSON na UI/Junie. Nao editar `llm.mcpServers.xml` manualmente enquanto o IDE nao expuser o formato completo de `command` e `args` nesse arquivo.

## Politica de seguranca

- O MCP so aceita repos em `/Users/rafaelpereirafreitas/Sites/`.
- Instalar perfis/skills exige `apply=true`; sem isso ele retorna dry-run.
- Skills suportadas inicialmente: Graphify, Impeccable, Huashu e Taste.
- Caveman continua fora do fluxo automatico ate aprovacao explicita.
- Banco/cloud/producao nao entram nesse MCP.

## Uso esperado

Exemplo:

```text
Use mcp-control para inspecionar /Users/rafaelpereirafreitas/Sites/rafaelfreitas e diga quais perfis, regras e skills estao configurados.
```

Exemplo com instalacao:

```text
Use mcp-control para instalar os perfis frontend, backend, product-architecture e code-review no repo rafaelfreitas com apply=true.
```
