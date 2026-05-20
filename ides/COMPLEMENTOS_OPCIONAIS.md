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
| Context Mode | Instalado via npm publico. | Principal camada de economia de contexto para Codex; configurar tambem em Antigravity, Cursor e Claude quando usados. |
| RTK | Instalado em `/opt/homebrew/bin/rtk`, versao `0.39.0`. | Auxiliar aprovado; nao e mais a camada principal de economia de contexto. |
| uv | Instalado via Homebrew. | Usar para instalar CLIs Python isoladas. |
| npx | Instalado via Node/NVM. | Usar para skills por projeto, sempre com registry publico quando instalar skills abertas. |
| Graphify | Instalado via `uv tool install 'graphifyy[gemini]'`; binario em `~/.local/bin/graphify`. | CLI global aprovado; regras e grafo por repo. |
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

Antes de instalar qualquer skill publica via `npx`, confirmar que o npm global
nao esta herdando registry corporativo:

```bash
npm config get registry --location=user
```

O resultado esperado e `https://registry.npmjs.org/`. Registries corporativos
devem ficar no repo alvo, nunca em `$HOME/.npmrc`.

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
TARGET_REPO=$HOME/Sites/rafaelfreitas \
APPLY=1 INSTALL_GRAPHIFY_PROJECT=1 \
./scripts/11-install-optional-complements.sh
```

4. Escolher um repo piloto para UI:

```bash
TARGET_REPO=$HOME/Sites/projeto_qrcode_movidesk \
APPLY=1 INSTALL_IMPECCABLE=1 \
./scripts/11-install-optional-complements.sh
```

5. Instalar Huashu apenas quando houver demanda visual concreta:

```bash
TARGET_REPO=$HOME/Sites/projeto_qrcode_movidesk \
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
uv tool install 'graphifyy[gemini]'
graphify install --platform codex
```

Estado aplicado neste repo:

```text
.agents/rules/graphify.md
.agents/workflows/graphify.md
```

Essas regras foram geradas para o repo `mcp`. Elas nao geram o grafo por si so. No terminal, o grafo e criado com `graphify extract . --backend gemini`. Dentro de agentes que suportam slash commands, a skill pode aceitar `/graphify .`.

Regras por projeto:

```bash
cd /caminho/do/repo
graphify antigravity install
```

Uso por projeto:

```bash
cd /caminho/do/repo
graphify extract . --backend gemini
graphify cluster-only .
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
- Para atualizacoes depois de mudancas de codigo, usar `graphify update .`.

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
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ \
npm_config_registry=https://registry.npmjs.org/ \
npm_config_always_auth=false \
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
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ \
npm_config_registry=https://registry.npmjs.org/ \
npm_config_always_auth=false \
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
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ npm_config_registry=https://registry.npmjs.org/ npm_config_always_auth=false npx skills add JuliusBrussee/caveman -a codex
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/ npm_config_registry=https://registry.npmjs.org/ npm_config_always_auth=false npx skills add JuliusBrussee/caveman -a antigravity
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
| Frontend React/Vite | `$HOME/Sites/projeto_qrcode_movidesk` | Impeccable, Taste, Playwright |
| Frontend Angular | `$HOME/Sites/PortoSeguro/auto-cotacao-web` | Impeccable, Playwright |
| Fullstack pessoal | `$HOME/Sites/rafaelfreitas` | Graphify, Impeccable, Taste |
| Monorepo grande | `$HOME/Sites/easysuite` | Graphify, product-architecture profile |
| Java/Next corporativo | `$HOME/Sites/Cresol` | Graphify, JetBrains, Playwright por UI |

## Por IDE

| IDE | Complementos |
| --- | --- |
| Codex | Context Mode global + regras por repo, Graphify skill, Impeccable por repo, Obsidian scoped. |
| IntelliJ IDEA | JetBrains MCP como contexto principal; Graphify como artefato externo. |
| Antigravity | Context Mode MCP direto; demais MCPs preferencialmente via Docker MCP Gateway/perfis. Graphify no perfil `product-architecture`, Huashu no perfil `frontend` quando necessario. |
| Cursor | Context Mode MCP/hooks quando usado pontualmente. |
| Claude | Context Mode MCP/hooks no Claude CLI e MCP no Claude UI/Desktop. |

## Context Mode por repositorio

O MCP `context-mode` fica global no Codex, mas as regras de roteamento podem ser
habilitadas por repositorio para evitar despejar arquivos, logs e saidas grandes
no contexto.

Dry-run:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
./scripts/17-enable-context-mode-repo.sh
```

Aplicar:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
APPLY=1 \
./scripts/17-enable-context-mode-repo.sh
```

Artefatos no repo alvo:

```text
AGENTS.context-mode.md
AGENTS.md
```

O script nao sobrescreve `AGENTS.md`; apenas adiciona a referencia
`@./AGENTS.context-mode.md` quando ela ainda nao existe.

## Uso em clientes sem hooks

Antigravity e Claude UI/Desktop nao oferecem hooks equivalentes aos do Codex ou
Claude CLI. Nesses clientes, a melhor ergonomia e usar o proprio `context-mode`
diretamente no prompt.

Para automatizar a instrucao por projeto:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
APPLY=1 \
./scripts/20-inject-context-mode-prompt.sh
```

Para aplicar em todos os projetos diretos dentro de `$HOME/Sites` e em
repositorios Git aninhados:

```bash
APPLY=1 ./scripts/21-inject-context-mode-all-sites.sh
```

Para criar ou atualizar a indexacao inicial padronizada do context-mode em um
repositorio:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
APPLY=1 \
$HOME/Sites/mcp/scripts/22-index-context-mode-repo.sh
```

Para aplicar a indexacao nos projetos diretos de `$HOME/Sites` e em
repositorios Git aninhados:

```bash
APPLY=1 $HOME/Sites/mcp/scripts/23-index-context-mode-all-sites.sh
```

O script usa manifesto incremental em `$HOME/.context-mode-kit/manifests`, entao
as proximas execucoes indexam apenas arquivos novos ou alterados.

Para uma carga inicial completa de todo conteudo textual seguro de um
repositorio, use:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
INDEX_ALL=1 \
FORCE_REINDEX=1 \
APPLY=1 \
$HOME/Sites/mcp/scripts/22-index-context-mode-repo.sh
```

## Markdown converter para futuro RAG

Antes de montar um RAG completo, use o MCP `markdown-converter` para transformar
PDF, DOCX, PPTX, XLSX, HTML, OpenAPI, Postman e Draw.io em Markdown cacheado.

Instalacao:

```bash
APPLY=1 $HOME/Sites/mcp/scripts/24-install-markdown-converter.sh
```

Conversao por repositorio:

```bash
TARGET_REPO=$HOME/Sites/NOME_DO_REPO \
APPLY=1 \
$HOME/Sites/mcp/scripts/25-convert-repo-markdown.sh
```

O cache fica em `$HOME/.context-mode-kit/markdown-cache`, fora do repositorio,
para nao poluir o Git.

O script cria `CONTEXT_MODE_PROMPT.md` e injeta a referencia em:

```text
AGENTS.md
GEMINI.md
CLAUDE.md
```

Exemplos recomendados:

```text
Use context-mode para analisar este repositorio sem despejar outputs grandes no contexto.
```

```text
Use ctx_batch_execute para rodar os comandos de diagnostico do projeto e retorne so os achados relevantes.
```

```text
Use ctx_execute_file para analisar este log grande e me diga apenas os erros e causas provaveis.
```

```text
Indexe a documentacao com ctx_index e depois use ctx_search para responder.
```

## Caso `rafaelfreitas`

O repo `$HOME/Sites/rafaelfreitas` deve ser tratado como grupo fullstack:

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
