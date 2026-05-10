# Complementos opcionais por projeto

## Decisao principal

Complementos como Graphify, Impeccable, Huashu, Taste e Caveman nao devem ser instalados em todos os repositorios automaticamente.

Regra:

- Binarios utilitarios podem ser globais.
- Skills de UI/produto devem ser por projeto.
- Outputs, perfis visuais e grafos devem ficar no repositorio ou no vault do projeto.
- MCPs com OAuth, credenciais ou escrita devem entrar apenas depois de escopo e auditoria.

## Estado validado nesta maquina

| Item | Estado | Decisao |
| --- | --- | --- |
| RTK | Instalado em `/opt/homebrew/bin/rtk`, versao `0.39.0`. | Global aprovado. |
| uv | Instalado via Homebrew. | Usar para instalar CLIs Python isoladas. |
| npx | Instalado via Node/NVM. | Usar para skills por projeto. |
| Graphify | Instalado via `uv tool install graphifyy`; binario em `~/.local/bin/graphify`. | CLI global aprovado; regras e grafo por repo. |
| Caveman | Nao instalado ainda. | Primeiro rodar dry-run, depois por IDE/perfil. |
| Impeccable | Nao instalado globalmente. | Instalar por projeto frontend piloto. |
| Huashu Design | Nao instalado globalmente. | Instalar por projeto visual/piloto. |
| Taste | Nao instalado globalmente. | Comecar como perfil local por projeto, sem MCP remoto. |

## Fontes atuais

- Graphify oficial: `https://github.com/safishamsi/graphify`
- Pacote Graphify correto no PyPI: `graphifyy`
- Impeccable: `https://github.com/pbakaus/impeccable`
- Impeccable getting started: `https://impeccable.style/tutorials/getting-started/`
- Caveman: `https://github.com/JuliusBrussee/caveman`
- Huashu Design: `https://playbooks.com/skills/alchaincyf/huashu-skills/huashu-design`

## Ordem recomendada

1. Validar inventario:

```bash
./scripts/10-validate-optional-complements.sh
```

2. Instalar Graphify CLI, se aprovado:

```bash
APPLY=1 INSTALL_GRAPHIFY=1 ./scripts/11-install-optional-complements.sh
```

3. Instalar regras Graphify no repo piloto escolhido:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/rafaelfreitas \
APPLY=1 INSTALL_GRAPHIFY_PROJECT=1 \
./scripts/11-install-optional-complements.sh
```

4. Escolher um repo piloto para UI:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk \
APPLY=1 INSTALL_IMPECCABLE=1 \
./scripts/11-install-optional-complements.sh
```

5. Instalar Huashu apenas quando houver demanda visual concreta:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk \
APPLY=1 INSTALL_HUASHU=1 \
./scripts/11-install-optional-complements.sh
```

6. Rodar Caveman primeiro em dry-run:

```bash
CHECK_CAVEMAN=1 ./scripts/10-validate-optional-complements.sh
```

## Graphify

Uso:

- Arquitetura.
- Onboarding em repos grandes.
- Code review estrutural.
- Relacao entre frontend, backend, scripts, docs e banco.

Instalacao segura:

```bash
uv tool install graphifyy
graphify install --platform codex
```

Estado aplicado neste repo:

```text
.agents/rules/graphify.md
.agents/workflows/graphify.md
.cursor/rules/graphify.mdc
```

Essas regras foram geradas para o repo `mcp`. Elas nao geram o grafo por si so; o grafo continua sendo criado por projeto com `/graphify .` ou `graphify .`.

Regras por projeto:

```bash
cd /caminho/do/repo
graphify cursor install
graphify antigravity install
```

Uso por projeto:

```bash
cd /caminho/do/repo
graphify .
```

Artefatos esperados:

```text
graphify-out/
  GRAPH_REPORT.md
  graph.html
  graph.json
```

Politica:

- `graphify-out/` deve ser local por padrao.
- Decidir por repo se o `GRAPH_REPORT.md` entra no Git.
- Nao rodar Graphify em repos com dados sensiveis sem revisar escopo.
- Se `graphify` nao estiver no PATH, usar `~/.local/bin/graphify` ou rodar `uv tool update-shell`.

## Impeccable

Uso:

- Auditoria visual.
- Polimento de UI.
- Design review.
- UX writing.
- Remocao de padroes visuais genericos de IA.

Instalacao por projeto:

```bash
cd /caminho/do/repo-frontend
npx skills add pbakaus/impeccable
```

Gates obrigatorios:

- Criar ou revisar `PRODUCT.md`.
- Criar ou revisar `DESIGN.md`.
- Validar mudanca com screenshot ou Playwright.
- Nao aplicar estilo pessoal por cima de design system corporativo.

## Huashu Design

Uso:

- Direcao visual.
- Prototipos.
- Decks.
- Infograficos.
- Comparacao de escolas/filosofias visuais.

Instalacao por projeto:

```bash
cd /caminho/do/repo
npx playbooks add skill alchaincyf/huashu-skills --skill huashu-design
```

Politica:

- Usar para ideacao e propostas.
- Validar resultado com Playwright quando gerar UI.
- Nao substituir Impeccable para hardening visual de produto.

## Caveman

Uso:

- Reduzir verbosidade quando a conversa esta longa.
- Comprimir contexto operacional.
- Alternar modo de resposta quando necessario.

Dry-run:

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash -s -- --dry-run --only codex
```

Instalacao seletiva:

```bash
npx skills add JuliusBrussee/caveman -a codex
npx skills add JuliusBrussee/caveman -a cursor
npx skills add JuliusBrussee/caveman -a antigravity
```

Politica:

- Nao ativar em todos os agentes de uma vez.
- Evitar em tarefas que exigem explicacao detalhada.

## Taste

Uso:

- Perfil visual pessoal/projeto.
- Preferencias e anti-preferencias.
- Consistencia entre telas.

Primeiro ciclo:

- Criar `PRODUCT.md` e `DESIGN.md` por projeto.
- Registrar preferencias em `docs/design/TASTE.md` ou no Obsidian.
- Nao ativar MCP remoto global antes de revisar OAuth, privacidade e logs.

## Repos piloto

| Categoria | Repo piloto | Complementos |
| --- | --- | --- |
| Frontend React/Vite | `/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk` | Impeccable, Taste, Playwright |
| Frontend Angular | `/Users/rafaelpereirafreitas/Sites/PortoSeguro/auto-cotacao-web` | Impeccable, Playwright |
| Fullstack pessoal | `/Users/rafaelpereirafreitas/Sites/rafaelfreitas` | Graphify, Impeccable, Taste |
| Monorepo grande | `/Users/rafaelpereirafreitas/Sites/easysuite` | Graphify, product-architecture profile |
| Java/Next corporativo | `/Users/rafaelpereirafreitas/Sites/Cresol` | Graphify, JetBrains, Playwright por UI |

## Por IDE

| IDE | Complementos |
| --- | --- |
| Codex | RTK global, Graphify skill, Impeccable por repo, Obsidian scoped. |
| Cursor | Playwright, Impeccable por repo, Graphify por repo. |
| IntelliJ IDEA | JetBrains MCP como contexto principal; Graphify como artefato externo. |
| Antigravity | Somente via perfis Docker MCP Gateway; Graphify no perfil `product-architecture`, Huashu no perfil `frontend` quando necessario. |

## Caso `rafaelfreitas`

O repo `/Users/rafaelpereirafreitas/Sites/rafaelfreitas` deve ser tratado como grupo fullstack:

```text
deploy/    -> infraestrutura, AWS, Cloudflare, Nginx, Caddy
frontend/  -> Angular
backend/   -> Java/Spring/Maven
```

Antes de instalar skills por projeto ou gerar grafo:

- criar `.gitignore` na raiz;
- excluir `deploy/keys`, `frontend/node_modules`, `frontend/dist`, `frontend/.angular`, `backend/target`, `.idea` e `.DS_Store`;
- decidir se `backend/spring-petclinic` e parte do produto ou apenas exemplo/vendor;
- instalar Graphify na raiz somente depois dessa baseline.

Detalhes: `inventories/rafaelfreitas.md`.
