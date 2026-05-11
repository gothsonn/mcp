# Bootstrap de novo repositorio

## Objetivo

Padronizar um repositorio novo ou existente com:

- deteccao de stack;
- perfis e skills padrao;
- `.gitignore` inicial;
- `credential_mcp.env.example` por repositorio;
- Graphify;
- nota no Obsidian;
- ajuste de orientacao por tipo de repo.

Script:

```bash
scripts/15-bootstrap-repo.sh
```

## Uso seguro

Dry-run:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/NOME_DO_REPO \
./scripts/15-bootstrap-repo.sh
```

Aplicar:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/NOME_DO_REPO \
APPLY=1 \
./scripts/15-bootstrap-repo.sh
```

Aplicar sem gerar Graphify:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/NOME_DO_REPO \
APPLY=1 \
RUN_GRAPHIFY=0 \
./scripts/15-bootstrap-repo.sh
```

Use `RUN_GRAPHIFY=0` para repositorios corporativos ou sensiveis ate aprovar
explicitamente a indexacao do conteudo pelo backend configurado do Graphify.

## Tipos detectados

| Tipo | Indicadores | Perfis |
| --- | --- | --- |
| `angular` | `angular.json` ou `@angular/core` | `product-architecture`, `frontend` |
| `react` | `react` em `package.json` | `product-architecture`, `frontend` |
| `react-next` | `next` em `package.json` | `product-architecture`, `frontend` |
| `java-quarkus` | Maven/Gradle com Quarkus | `product-architecture`, `backend` |
| `java-spring` | Maven/Gradle com Spring Boot | `product-architecture`, `backend` |
| `nestjs` | `nest-cli.json` ou `@nestjs/core` | `product-architecture`, `backend` |
| `python` | `pyproject.toml`, `requirements.txt`, `setup.py` ou `Pipfile` | `product-architecture`, `backend` |
| `php` | `composer.json`, `artisan` ou `index.php` | `product-architecture`, `backend` |
| `fullstack-monorepo` | frontend + backend no mesmo repo | `product-architecture`, `frontend`, `backend` |

## Artefatos criados

No repositorio alvo:

```text
.agents/profiles/
.agents/profiles/repo-stack.md
.agents/rules/profile-engineering.md
.agents/rules/graphify.md
.agents/workflows/graphify.md
.cursor/rules/graphify.mdc
PRODUCT.md
DESIGN.md
docs/design/TASTE.md
credential_mcp.env.example
.gitignore
graphify-out/
```

No Obsidian:

```text
10-Projects/NOME_DO_REPO/
  Project Overview.md
  Repo Snapshot.md
  Decision Log.md
  Runbook.md
  AI Agent Operating Model.md
```

## Politica

- O script so aceita repos em `/Users/rafaelpereirafreitas/Sites/`.
- `APPLY=0` e sempre dry-run.
- `graphify-out/` fica local por padrao.
- Obsidian recebe resumo operacional, nao logs brutos.
- `.gitignore` recebe apenas padroes ausentes sob o marcador `# mcp bootstrap defaults`.
- Skills instaladas via `npx`, como Impeccable, sao executadas pelo MCP global
  com registry publico do npm para nao herdar `.npmrc` corporativo do repo alvo.
- `credential_mcp.env` e sempre local por repositorio e nunca deve ser
  versionado; `credential_mcp.env.example` e o contrato versionavel.

## Fechamento de feature

Ao finalizar uma feature, usar:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/NOME_DO_REPO \
FEATURE_KEY=ISSUE-123 \
APPLY=1 \
./scripts/16-feature-done.sh
```

Esse comando atualiza Obsidian, registra a feature no `Decision Log.md`, atualiza
Graphify e valida o projeto no vault.
