# Stack recomendado de MCPs e skills

## Principio central

Nao instalar tudo em todos os lugares.

Para o seu perfil, a melhor arquitetura e:

1. Codex como agente executor principal.
2. IntelliJ IDEA como fonte de contexto profundo para Java/backend.
3. Cursor como editor fullstack rapido.
4. Antigravity como agente autonomo controlado, com gateway/perfis para nao estourar limite de tools.
5. Obsidian como segundo cerebro, mas com acesso controlado e preferencialmente por arquivos/projeto.

## Camadas

### Camada 1 - Foundation

Instalar primeiro porque melhora quase qualquer fluxo.

| Item | Tipo | Onde usar | Motivo |
| --- | --- | --- | --- |
| OpenAI Developer Docs | MCP | Codex, Cursor | Docs atuais para OpenAI APIs, Codex, Agents e MCP. |
| JetBrains MCP Server | MCP | Codex, Cursor | Contexto real do IntelliJ: modulos, run configs, problemas, inspecoes. |
| GitHub | Plugin/MCP | Codex primeiro | PR, review, issues, CI e repos. |
| Playwright MCP | MCP | Cursor, Antigravity, Codex quando necessario | UI automation por accessibility snapshots, testes e screenshots. |
| Docker MCP Gateway | Gateway | Cursor e Antigravity | Agrega MCPs e reduz configuracao duplicada por cliente. |
| RTK | CLI/proxy | Codex, Cursor, Antigravity | Reduz tokens em comandos shell comuns. |

### Camada 2 - Conhecimento e memoria

| Item | Tipo | Onde usar | Motivo |
| --- | --- | --- | --- |
| Obsidian | Segundo cerebro | Codex e Cursor, por vault/projeto | Decisoes, arquitetura, runbooks, contexto de negocio e retrospectivas. |
| Graphify | Skill/MCP | Codex, Cursor | Gera grafo de conhecimento do repo, bom para arquitetura e repos grandes. |
| Memory/Knowledge Graph | MCP | Avaliar por cliente | Memoria persistente; usar com escopo e privacidade claros. |

Observacao: Obsidian ainda e ecossistema comunitario para MCP. Nao tratar como server oficial unico. Para comecar, prefira vault com arquivos Markdown versionaveis e acesso somente ao caminho necessario.

### Camada 3 - Frontend e produto

| Item | Tipo | Onde usar | Motivo |
| --- | --- | --- | --- |
| Impeccable | Skill | Codex, Cursor | Design review, polish, audit, harden, UX writing e anti-patterns. |
| Huashu Design | Skill | Codex, Cursor, Antigravity | Prototipos HTML, slides, animacoes, infograficos e revisao visual. |
| UI/UX Pro Max | Skill | Cursor, Codex | Biblioteca/guia de estilos UI quando precisar idear telas. |
| Taste | Skill/MCP | Codex, Cursor | Perfil de gosto visual e anti-preferencias para UI consistente. |
| Figma | MCP | Cursor e Codex por projeto | Quando houver design real para consultar. |
| Playwright MCP | MCP | Cursor, Antigravity | Validar telas, fluxos, responsividade e screenshots. |

### Camada 4 - Backend, dados e cloud

| Item | Tipo | Onde usar | Motivo |
| --- | --- | --- | --- |
| MCP Toolbox for Databases | MCP | Antigravity via gateway, Cursor por projeto | Postgres, MySQL, SQL Server e Cloud SQL com ferramentas declaradas. |
| AWS MCP Suite | MCP | Codex/Antigravity por projeto | Docs, custos, recursos AWS e Bedrock quando houver projeto AWS. |
| Cloudflare MCP | MCP/plugin | Codex, se houver Workers/R2/D1/DNS | Hoje esta desativado no Codex; ativar so quando precisar. |
| Grafana/Sentry | MCP | Codex/Antigravity por projeto | Incidentes, traces, logs, stack traces e observabilidade. |
| Semgrep | MCP/CLI | Codex, CI, Cursor | Code review de seguranca e padroes. |

Para Oracle e DB2, nao recomendo liberar MCP generico direto em producao. Use primeiro docs/schema exportado, usuario read-only e queries predefinidas. Se usar MCP, prefira gateway com allowlist e ambiente isolado.

## Skills citadas e decisao

### Caveman

Uso: compressao de resposta e comandos para reduzir tokens.

Instalacao segura para avaliar:

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash -s -- --dry-run
```

Depois, instalar somente no perfil desejado:

```bash
npx skills add JuliusBrussee/caveman -a codex
npx skills add JuliusBrussee/caveman -a cursor
npx skills add JuliusBrussee/caveman -a antigravity
```

Recomendacao: opcional. Bom para sessoes longas, mas nao e prioridade antes de Graphify, Playwright e Impeccable.

### RTK

Uso: comprimir saida de comandos como `git status`, `git diff`, `rg`, `npm test`, `pytest`, `docker ps`.

Instalacao:

```bash
brew install rtk
rtk --version
rtk init -g --codex
rtk init -g --agent cursor
rtk init --agent antigravity
```

Recomendacao: instalar depois que Codex/IntelliJ estiverem estaveis.

### Graphify

Uso: arquitetura, code review em repos grandes, onboarding em projeto desconhecido, entendimento de dependencias e decisoes.

Instalacao:

```bash
uv tool install 'graphifyy[gemini]'
graphify install --platform codex
```

Uso por projeto:

```bash
graphify extract /caminho/do/projeto --backend gemini
graphify cluster-only /caminho/do/projeto
```

Artefatos esperados:

- `graphify-out/graph.html`
- `graphify-out/GRAPH_REPORT.md`
- `graphify-out/graph.json`

Recomendacao: instalar por projeto quando o repo passar de tamanho medio ou tiver varias tecnologias.

### Impeccable

Uso: elevar qualidade de UI gerada por IA, revisar tela, reduzir visual generico, melhorar UX writing, responsividade e hardening visual.

Comandos principais:

```text
$impeccable audit tela-de-login
$impeccable critique dashboard
$impeccable polish checkout
$impeccable harden formulario
```

Recomendacao: instalar em projetos frontend Angular, React e Next.js.

### Huashu Design

Uso: prototipo HTML clicavel, deck, animacao, infografico e revisao visual.

Instalacao:

```bash
npx skills add alchaincyf/huashu-design
```

Recomendacao: usar para ideacao e entregaveis visuais. Validar sempre com Playwright/screenshot antes de aceitar.

### UI/UX Pro Max

Uso: repertorio de estilos e geracao de design system.

Recomendacao: avaliar como complemento ao Impeccable. Nao instalar globalmente antes de testar em um projeto frontend real.

### Taste

Uso: transformar preferencias visuais em skill/perfil para Codex e Claude/Cursor; MCP com OAuth existe no produto.

Recomendacao: interessante para manter consistencia visual entre projetos. Antes de usar MCP, prefira exportar como skill/perfil local.

### Playwright MCP

Uso: automacao de browser, testes de UI, fluxo completo, screenshot, estado autenticado e mock de rede.

Config padrao:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Modo isolado para evitar misturar sessoes:

```json
{
  "mcpServers": {
    "playwright-isolated": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--isolated"]
    }
  }
}
```

## Ordem recomendada

1. Codex: OpenAI Docs MCP.
2. IntelliJ IDEA: habilitar JetBrains MCP Server e auto-configurar Codex.
3. Cursor: validar MCP_DOCKER e GitKraken; adicionar Playwright por projeto frontend.
4. Criar padrao de `docs/specs/[FEATURE]-RESEARCH.md` e `[FEATURE]-SPEC.md`.
5. Instalar Impeccable em um projeto frontend piloto.
6. Instalar Graphify em um repo grande ou legado.
7. Configurar Antigravity com Docker MCP Gateway e perfis por tipo de trabalho.
8. Avaliar Obsidian como segundo cerebro conectado por vault/projeto.
9. Avaliar RTK e Caveman para reducao de tokens.

## Fontes consultadas

- Google Drive: `guia-30-mcp-servers.pdf`
- Google Drive: `spec-driven-dev-templates.md`
- Google Drive: `guia-cyber.pdf`
- Playwright MCP: https://playwright.dev/docs/getting-started-mcp
- Docker MCP Gateway: https://docs.docker.com/ai/mcp-gateway/
- RTK: https://github.com/rtk-ai/rtk
- Caveman: https://github.com/JuliusBrussee/caveman
- Graphify: https://graphify.net/hk/
- Impeccable: https://github.com/pbakaus/impeccable
- Huashu Design: https://github.com/alchaincyf/huashu-design
- Taste: https://www.alexkehr.com/projects/taste
