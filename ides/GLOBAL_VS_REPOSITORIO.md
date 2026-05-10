# Global vs por repositorio

## Objetivo

Definir o que deve ser instalado uma vez na maquina, o que deve ser configurado por IDE e o que deve ficar dentro de cada repositorio.

Regra principal:

- Ferramenta de execucao pode ser global.
- Contexto, rules, specs, prompts, grafos, design system e acesso a dados devem ser por repositorio/projeto.
- MCP com credencial ou dados sensiveis nunca deve ser global sem escopo e aprovacao.

## Inventario atual em `/Users/rafaelpereirafreitas/Sites`

### Grupos corporativos/monorepos

| Caminho | Stacks detectadas | Tratamento |
| --- | --- | --- |
| `/Users/rafaelpereirafreitas/Sites/Cresol` | Java/Maven, Docker, Next.js/React/Chakra | Por repositorio/grupo, com IntelliJ + Cursor + Graphify. |
| `/Users/rafaelpereirafreitas/Sites/PortoSeguro` | Angular, TypeScript, jQuery | Por repositorio/grupo, com Cursor + Playwright + Impeccable. |
| `/Users/rafaelpereirafreitas/Sites/easysuite` | Java/Maven, Python, Airflow, React/Vite, Kafka, OpenSearch, Docker | Por repositorio/grupo, com Graphify, gateway e specs obrigatorios. |
| `/Users/rafaelpereirafreitas/Sites/livelo` | Java/Maven, Next.js, React, React Native, single-spa, Docker | Por repositorio/grupo, com perfis frontend/backend/mobile. |
| `/Users/rafaelpereirafreitas/Sites/rafaelfreitas` | Angular, Java/Maven, Docker | Por repositorio/grupo, bom piloto fullstack. |

### Projetos menores/especificos

| Caminho | Stacks detectadas | Tratamento |
| --- | --- | --- |
| `/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk` | React/Vite/Vitest | Por repositorio, frontend + seguranca no fluxo QR. |
| `/Users/rafaelpereirafreitas/Sites/automacao-pontos` | Python/Streamlit/RPA | Por repositorio, automacao desktop e evidencias. |
| `/Users/rafaelpereirafreitas/Sites/rpa_automation` | Python/RPA | Por repositorio, automacao e browser/desktop controlado. |
| `/Users/rafaelpereirafreitas/Sites/development-setting` | Docker Compose para bancos/infra | Infra local compartilhada, nao tratar como app. |
| `/Users/rafaelpereirafreitas/Sites/mcp` | Documentacao/configuracao MCP | Repo de controle e inventario. |
| `/Users/rafaelpereirafreitas/Sites/easysearch` | Java/Maven | Por repositorio. |
| `/Users/rafaelpereirafreitas/Sites/api_qrcode_movidesk` | README apenas detectado | Verificar manualmente antes de configurar. |
| `/Users/rafaelpereirafreitas/Sites/imetrics` | Docker Compose/README | Verificar manualmente antes de configurar. |
| `/Users/rafaelpereirafreitas/Sites/mvno-bb` | OpenAPI docs | Docs/API, nao app completo pelo inventario atual. |
| `/Users/rafaelpereirafreitas/Sites/Omni` | Sem manifesto detectado | Verificar manualmente. |
| `/Users/rafaelpereirafreitas/Sites/gestor-pessoal` | Sem manifesto detectado | Verificar manualmente. |

## Matriz dos complementos opcionais

### RTK

| Escopo | Decisao |
| --- | --- |
| Instalacao | Global na maquina via Homebrew. |
| Config por IDE | Sim, ativar por IDE depois que cada uma estiver validada. |
| Config por repositorio | Nao precisa, salvo excecoes. |
| Usar em Codex | Sim, primeiro. |
| Usar em IntelliJ | Indireto, via terminal/agentes; nao e plugin da IDE. |
| Usar em Cursor | Sim, depois da fase Cursor. |
| Usar em Antigravity | Sim, depois dos perfis/gateway. |
| Risco | Saida comprimida pode esconder detalhe de teste/log. Desativar quando precisar de output completo. |

Comandos:

```bash
brew install rtk
rtk --version
rtk init -g --codex
rtk init -g --agent cursor
rtk init --agent antigravity
```

### Caveman

| Escopo | Decisao |
| --- | --- |
| Instalacao | Preferir por IDE/perfil, nao global para todos de uma vez. |
| Config por IDE | Sim. |
| Config por repositorio | Opcional, apenas se quisermos regras sempre ativas em um repo. |
| Usar em Codex | Opcional para sessoes longas. |
| Usar em Cursor | Opcional. |
| Usar em Antigravity | Opcional, mas nao prioritario por causa do limite de tools/contexto. |
| Usar em IntelliJ | Indireto via Junie/agente, nao prioridade. |
| Risco | Pode reduzir contexto verbal demais em tarefas que exigem explicacao detalhada. |

Comandos seguros:

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash -s -- --dry-run
npx skills add JuliusBrussee/caveman -a codex
npx skills add JuliusBrussee/caveman -a cursor
npx skills add JuliusBrussee/caveman -a antigravity
```

### Graphify

| Escopo | Decisao |
| --- | --- |
| Instalacao | CLI global ou venv/tooling compartilhado. |
| Config por IDE | Skill pode ser adicionada ao Codex/Cursor, mas o grafo e por repositorio. |
| Config por repositorio | Sim, sempre. `graphify-out/` e `GRAPH_REPORT.md` devem ser por repo/grupo. |
| Usar em Codex | Sim, para arquitetura, code review e onboarding. |
| Usar em Cursor | Sim, para repos frontend/fullstack grandes. |
| Usar em Antigravity | Via perfil `product-architecture`, nao global. |
| Usar em IntelliJ | Indireto; o IntelliJ fornece contexto Java, Graphify fornece mapa do repo. |
| Risco | Artefatos podem ficar grandes; decidir se entram no git ou ficam locais. |

Repos candidatos para primeiro uso:

1. `/Users/rafaelpereirafreitas/Sites/easysuite`
2. `/Users/rafaelpereirafreitas/Sites/Cresol`
3. `/Users/rafaelpereirafreitas/Sites/livelo`
4. `/Users/rafaelpereirafreitas/Sites/rafaelfreitas`

Comandos:

```bash
pip install graphifyy
graphify install
graphify /Users/rafaelpereirafreitas/Sites/easysuite
```

### Impeccable

| Escopo | Decisao |
| --- | --- |
| Instalacao | Por repositorio frontend. Evitar global inicialmente. |
| Config por IDE | Codex e Cursor podem ler a skill local do repo. |
| Config por repositorio | Sim, em projetos Angular/React/Next. |
| Usar em Codex | Sim, quando for mexer em UI com validacao. |
| Usar em Cursor | Sim, principal uso para UI. |
| Usar em Antigravity | Como skill/contexto de projeto, nao como MCP global. |
| Usar em IntelliJ | Nao prioridade, exceto monorepo fullstack aberto. |
| Risco | Aplicar estilo generico se nao houver design system/brand context. |

Repos candidatos:

- `/Users/rafaelpereirafreitas/Sites/PortoSeguro/auto-cotacao-web`
- `/Users/rafaelpereirafreitas/Sites/PortoSeguro/auto-individual-web`
- `/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk`
- `/Users/rafaelpereirafreitas/Sites/easysuite/easysuites-frontend`
- `/Users/rafaelpereirafreitas/Sites/rafaelfreitas/frontend`
- UIs Next.js em `/Users/rafaelpereirafreitas/Sites/Cresol`
- MFEs em `/Users/rafaelpereirafreitas/Sites/livelo`

### Huashu Design

| Escopo | Decisao |
| --- | --- |
| Instalacao | Por projeto quando houver entrega visual concreta. Pode existir global, mas nao com uso automatico. |
| Config por IDE | Codex/Cursor/Antigravity podem usar, mas por brief. |
| Config por repositorio | Sim quando gerar prototipos, decks, animacoes ou infograficos. |
| Usar em Codex | Sim para prototipos e decks. |
| Usar em Cursor | Sim para UI/prototipos. |
| Usar em Antigravity | Sim via perfil `frontend`, validando com Playwright. |
| Usar em IntelliJ | Nao prioridade. |
| Risco | Pode criar artefatos visuais fora do design system se nao houver brand/assets. |

Uso recomendado:

- POCs.
- Slides tecnicos.
- Prototipos de novas features.
- Infograficos de arquitetura/produto.

Nao usar como padrao para todo ajuste frontend.

### Taste

| Escopo | Decisao |
| --- | --- |
| Instalacao | Perfil pessoal/global pode existir, mas aplicacao deve ser por projeto. |
| Config por IDE | Codex e Cursor primeiro; Antigravity depois. |
| Config por repositorio | Sim: perfil visual por produto/projeto. |
| Usar em Codex | Sim para manter preferencia visual. |
| Usar em Cursor | Sim, principalmente em frontend. |
| Usar em Antigravity | Somente depois de validar OAuth/auditoria do MCP. |
| Usar em IntelliJ | Nao prioridade. |
| Risco | Misturar gosto pessoal com constraints corporativas/design system. |

Decisao:

- Comecar com export local de perfil/skill.
- Nao ativar MCP remoto global antes de revisar privacidade, OAuth e escopo.

## Matriz por IDE

| Item | Codex | IntelliJ IDEA | Cursor | Antigravity |
| --- | --- | --- | --- | --- |
| RTK | Global + ativar primeiro | Indireto | Ativar depois do Cursor | Ativar depois do gateway |
| Caveman | Opcional por perfil | Nao prioridade | Opcional por perfil | Opcional, baixa prioridade |
| Graphify | Skill + grafo por repo | Contexto indireto | Skill + grafo por repo | Perfil `product-architecture` |
| Impeccable | Por repo frontend | Nao prioridade | Por repo frontend | Skill no perfil `frontend` |
| Huashu | Por projeto visual | Nao prioridade | Por projeto visual | Perfil `frontend`, com Playwright |
| Taste | Perfil local + por projeto | Nao prioridade | Perfil local + por projeto | Somente apos validar MCP/OAuth |

## Matriz por tipo de repositorio

| Tipo | Exemplos | Globais permitidos | Por repo obrigatorio |
| --- | --- | --- | --- |
| Java backend | Cresol APIs, easysearch, transfer-route, rafaelfreitas/backend | RTK, JetBrains MCP | specs, Graphify em repo grande, Semgrep config se aplicavel |
| Angular | PortoSeguro, rafaelfreitas/frontend | RTK | Playwright, Impeccable, specs, screenshots |
| React/Next/Vite | Cresol UIs, easysuite frontend, livelo MFEs, projeto QR | RTK | Playwright, Impeccable, Taste profile, specs |
| React Native | livelo/applivelo | RTK | specs, mobile runbook, screenshots/simulator evidence |
| Python/RPA | automacao-pontos, rpa_automation, easysuite Python | RTK | runbook, evidencias, browser/desktop rules, specs |
| Infra local | development-setting | RTK | docs de servicos, credenciais locais fora do git, gateway profiles |
| Banco/dados | development-setting, easysuite rds/documentdb | Nenhum MCP de escrita global | database-readonly, allowlist, usuario proprio, logs |

## Recomendacao final

### Global na maquina

- RTK binario.
- Docker MCP Gateway.
- OpenAI Developer Docs MCP no Codex.
- JetBrains MCP Server na IDE.
- GitHub plugin no Codex.

### Global por IDE, mas com cuidado

- Caveman, se aprovado apos dry-run.
- Graphify skill, desde que os grafos sejam por repo.

### Sempre por repositorio/projeto

- Graphify outputs.
- Impeccable.
- Huashu Design assets/outputs.
- Taste project profile.
- Playwright config quando ligado a app frontend.
- Specs `docs/specs`.
- MCP de banco/cloud.
- Obsidian notes do projeto.

## Proxima acao recomendada

Antes de instalar complementos, escolher um repo piloto por categoria:

1. Fullstack Java + Angular: `/Users/rafaelpereirafreitas/Sites/rafaelfreitas`
2. Frontend React/Vite: `/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk`
3. Monorepo grande: `/Users/rafaelpereirafreitas/Sites/easysuite`
4. RPA/Python: `/Users/rafaelpereirafreitas/Sites/automacao-pontos`
