# Uso por papel, stack e IDE

## Regra operacional

Cada tarefa deve comecar com uma destas frases:

- "Atue como arquiteto de software..."
- "Atue como engenheiro de software senior..."
- "Atue como revisor de codigo..."
- "Atue como PO..."
- "Atue como Scrum Master..."
- "Atue como dev implementador..."

Depois informe:

- Projeto.
- Stack.
- Ambiente.
- Arquivos de entrada.
- O que pode alterar.
- Como validar.
- O que deve gerar no final.

## Frontend Angular

### Codex

Use para:

- Refatorar componentes.
- Corrigir testes.
- Criar documentacao tecnica.
- Revisar arquitetura de modulo.
- Rodar comandos reais.

Prompt base:

```text
Atue como engenheiro frontend senior Angular. Analise este projeto, respeite os padroes existentes, implemente [feature/correcao], rode testes/lint e me devolva os arquivos alterados e validacoes.
```

MCPs/skills:

- OpenAI Docs, se houver API OpenAI.
- Impeccable para qualidade visual.
- Playwright MCP para fluxo de tela.
- Graphify se o projeto for grande.

### Cursor

Use para:

- Edicao rapida de componentes.
- Ajuste de CSS/SCSS.
- Criacao de services, guards e interceptors.
- Navegacao no codigo.

Prompt base:

```text
Use o contexto do workspace Angular. Altere somente os componentes e services necessarios para [objetivo]. Preserve arquitetura atual e gere testes unitarios quando houver regra de negocio.
```

### IntelliJ IDEA

Use se o projeto Angular estiver junto de backend Java ou monorepo. Caso contrario, Cursor tende a ser mais ergonomico.

### Antigravity

Use para:

- Fluxos E2E longos.
- Validacao visual com navegador.
- Refatoracoes guiadas por spec.

MCP profile recomendado:

- Playwright.
- GitHub.
- Filesystem scoped ao projeto.
- Sem banco por padrao.

## Frontend React / Next.js

### Codex

Use para:

- App Router, Server Actions, API routes.
- Refatorar estado e hooks.
- Corrigir hydration, SSR/CSR e testes.
- Criar docs de arquitetura.

Skills:

- Impeccable para UI.
- Huashu Design para prototipos e landing/app flows.
- Taste se houver perfil visual.
- Playwright MCP para validar fluxo.

Prompt base:

```text
Atue como frontend/platform engineer React/Next.js. Antes de codar, identifique padrao de roteamento, estrategia de estado, componentes compartilhados e testes existentes. Implemente [objetivo] e valide em desktop/mobile.
```

### Cursor

Use para iterar UI rapidamente:

```text
Melhore esta tela React/Next.js com foco em usabilidade, responsividade e consistencia visual. Use Impeccable/Taste se disponivel e nao altere contratos de API.
```

### Antigravity

Use quando a tarefa envolver navegador, fluxo completo, captura de screenshots ou varias telas.

## Backend Java / Spring Boot / Quarkus

### IntelliJ IDEA

IDE principal.

Use para:

- Inspecoes.
- Run configurations.
- Debug.
- Modulos Maven/Gradle.
- Testes JUnit/Mockito.

MCP:

- JetBrains MCP Server habilitado.
- Codex ou Cursor consumindo o contexto do IntelliJ quando precisar.

Prompt no Codex usando contexto JetBrains:

```text
Atue como backend Java senior. Use o contexto do IntelliJ para entender modulos, dependencias e problemas atuais. Implemente [objetivo] em Spring/Quarkus, mantendo SOLID, Clean Architecture e testes JUnit/Mockito.
```

### Codex

Use para:

- Mudancas multiarquivo.
- Criar testes.
- Revisar arquitetura.
- Rodar `mvn test`, `gradle test`, `docker compose`.
- Documentar endpoints e decisoes.

### Cursor

Use menos para Java pesado. Bom para ajustes pontuais, README, YAML, Dockerfile e config.

### Antigravity

Use apenas com spec clara para refatoracoes longas ou investigacoes que combinem codigo, banco e logs.

## Backend NestJS / Node.js

### Codex

Use para:

- Modulos, providers, guards, interceptors.
- Testes unitarios/e2e.
- Integracao com filas, Kafka, SQS.
- Refatoracao de contratos.

Prompt:

```text
Atue como backend NestJS senior. Mapeie modulos, controllers, providers, DTOs e validacoes. Implemente [objetivo], preserve contratos existentes e rode testes/lint.
```

### Cursor

Excelente para:

- Ajuste de DTOs.
- Controllers.
- Prisma/TypeORM.
- Testes pequenos.

### Antigravity

Use com profile backend:

- GitHub.
- Filesystem scoped.
- Docker.
- Database read-only se necessario.

## Backend Python

### Codex

Use como principal para:

- Scripts de dados.
- ETL.
- Automacoes.
- FastAPI.
- Testes `pytest`.
- Pipelines.

Prompt:

```text
Atue como engenheiro Python senior focado em automacao/dados. Analise dependencias, entradas, saidas e modos de falha. Implemente [objetivo] com testes pytest e logs claros.
```

### Cursor

Use para edicoes rapidas.

### Antigravity

Use para pipelines que envolvem navegador, APIs externas e execucao longa.

## Backend PHP

### Codex

Use para:

- Laravel/CodeIgniter.
- Refatorar controllers/services.
- Corrigir SQL.
- Revisar auth e validacao.
- Adicionar testes quando o projeto permitir.

Prompt:

```text
Atue como backend PHP senior. Identifique se o projeto usa Laravel, CodeIgniter ou estrutura propria. Preserve padroes locais, corrija [objetivo] e valide com os comandos disponiveis.
```

### Cursor

Bom para ajustes rapidos em views, controllers e rotas.

### IntelliJ IDEA

Se estiver usando plugin PHP ou projeto misto, use para navegacao e refatoracao.

## Banco de dados

### PostgreSQL

Melhor caminho:

- Desenvolvimento local: MCP Toolbox for Databases ou Docker Gateway.
- Produção: read-only, allowlist de queries, nunca acesso livre.

Prompt:

```text
Atue como engenheiro de dados/backend. Gere queries PostgreSQL seguras para [objetivo], explique plano de execucao esperado, indices necessarios e riscos de lock.
```

### MySQL

Mesmo criterio do PostgreSQL. Atencao a charset/collation, locks e diferencas de sintaxe.

### SQL Server

Usar MCP Toolbox/driver especifico quando disponivel. Separar ambientes e usar usuario read-only para analise.

### Oracle

Nao liberar agente direto em producao no inicio. Preferir:

- DDL exportado.
- Explain plan.
- Amostra mascarada.
- Usuario read-only.
- Queries pre-aprovadas.

### DB2

Tratar como banco sensivel/legado:

- Primeiro documentar schema e constraints.
- Depois permitir consultas read-only controladas.
- Nunca deixar agente criar/alterar objetos sem revisao humana.

## Code review

### Codex

Ferramenta principal.

Prompt:

```text
Faca code review em modo rigoroso. Priorize bugs, regressao, seguranca, performance, concorrencia, contratos quebrados e testes ausentes. Mostre achados por severidade com arquivo/linha.
```

MCPs/skills:

- GitHub.
- Semgrep.
- Playwright se houver UI.
- Cybersecurity scan para revisao mensal ou pre-release.

### Cursor

Use para revisar um arquivo ou conjunto pequeno.

### IntelliJ IDEA

Use inspecoes e problemas da IDE para Java.

### Antigravity

Use para PR grande com varias frentes, mas limite tools e exija plano antes de edicoes.

## Arquiteto de software

### Codex

Use para:

- ADRs.
- Diagrama Mermaid.
- Mapeamento de bounded contexts.
- Avaliar trade-offs.
- Especificar APIs.

MCPs/skills:

- Graphify.
- Obsidian.
- GitHub.
- JetBrains MCP para Java.

Prompt:

```text
Atue como arquiteto de software. Antes de propor solucao, mapeie contexto, constraints, riscos, dependencias, contratos e trade-offs. Gere ADR e plano incremental.
```

## PO

### Codex

Use para transformar demanda em:

- Research.
- SPEC.
- User stories.
- Criterios de aceite.
- Regras de negocio.
- Edge cases.

Prompt:

```text
Atue como PO tecnico. Transforme esta demanda em RESEARCH.md e SPEC.md com contexto de negocio, regras, criterios de aceite, contratos, edge cases e perguntas abertas.
```

Usar o modelo de `docs/specs/[FEATURE]-RESEARCH.md` e `[FEATURE]-SPEC.md`.

## Scrum Master

### Codex

Use para:

- Quebrar backlog.
- Identificar dependencias.
- Criar plano de sprint.
- Gerar pauta de daily/review/retro.
- Mapear riscos e impedimentos.

Prompt:

```text
Atue como Scrum Master tecnico. Quebre esta iniciativa em epicos, stories, tarefas, dependencias, riscos, Definition of Ready e Definition of Done.
```

## Dev implementador

### Codex

Use para executar ponta a ponta:

1. Ler contexto.
2. Implementar.
3. Rodar testes.
4. Corrigir.
5. Documentar.

Prompt:

```text
Atue como dev senior implementador. Execute a tarefa ate ficar validada. Nao pare em plano. Se houver bloqueio, tente resolver e me informe exatamente o que faltou.
```

### Cursor

Use para fluxo rapido de edicao.

### Antigravity

Use quando a tarefa puder ser delegada com spec clara e validacao automatica.

