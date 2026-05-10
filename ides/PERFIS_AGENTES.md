# Perfis de agentes

## Decisao

Usar perfis separados por responsabilidade, nao perfis gigantes.

Modelo aprovado:

| Perfil | Responsabilidade | Nao deve fazer |
| --- | --- | --- |
| `frontend` | Especialista frontend + code review de UI/frontend. | PO, PM, arquitetura ampla, banco/cloud. |
| `backend` | Especialista backend + code review de backend/API/servicos. | PO, PM, design visual, planejamento de sprint. |
| `product-architecture` | PO + PM + Arquiteto + Engenheiro de software. | Implementar codigo direto sem gerar SPEC/ADR/plano. |
| `code-review` | Review especializado apos implementacao. | Planejar produto, assumir escopo novo ou reescrever sem pedido explicito. |

## Skills padrao

Sempre que um perfil for instalado via `mcp-control`, as skills abaixo tambem entram no repositorio:

| Perfil | Skills |
| --- | --- |
| `frontend` | Impeccable, Taste, Graphify |
| `backend` | Impeccable, Graphify |
| `product-architecture` | Impeccable, Huashu, Graphify |
| `code-review` | Impeccable, Taste, Graphify |

## Regras padrao por repositorio

Todo repo configurado por `mcp-control` recebe:

```text
.agents/rules/profile-engineering.md
```

Essa regra contem criterios genericos e especificos para Angular, React/Next.js, Java/Spring/Quarkus, NestJS/Node.js, Python, PHP, bancos SQL/NoSQL, Kafka e Kubernetes/OpenShift.

Referencia detalhada no kit:

```text
ides/CRITERIOS_PERFIS_E_STACKS.md
```

## Por que nao misturar tudo em frontend/backend

Evitar este modelo como padrao:

```text
frontend Especialista + code review + PO + PM + Arquiteto + Engenheiro
backend Especialista + code review + PO + PM + Arquiteto + Engenheiro
```

Motivos:

- Aumenta contexto e tools em cada perfil.
- Piora o limite do Antigravity.
- Mistura discovery, produto, arquitetura e implementacao na mesma execucao.
- Faz o agente tentar decidir escopo e codar ao mesmo tempo.
- Dificulta auditoria: nao fica claro se a resposta e plano, review ou implementacao.

## Como usar na pratica

### Fluxo frontend

1. `product-architecture`: transforma demanda em `RESEARCH.md`, `SPEC.md`, riscos, criterios de aceite e decisoes.
2. `frontend`: implementa a menor mudanca correta seguindo a SPEC.
3. `code-review`: faz review especializado, validacao visual, Playwright e screenshot.

Prompt:

```text
Use o perfil frontend. Implemente somente o que esta na SPEC aprovada.

Depois use o perfil code-review para revisar frontend, validar com Playwright/screenshot e apontar regressoes.
```

### Fluxo backend

1. `product-architecture`: define contrato, regras de negocio, riscos, ADR e criterio de aceite.
2. `backend`: implementa endpoint, servico, persistencia e testes.
3. `code-review`: faz review especializado, contratos, logs, seguranca e performance.

Prompt:

```text
Use o perfil backend. Leia a SPEC aprovada, implemente a mudanca no menor escopo e rode testes.

Depois use o perfil code-review para revisar contrato, logs, erros, seguranca e performance.
```

### Fluxo de planejamento

Usar somente `product-architecture` quando a demanda ainda nao esta pronta para codigo.

Prompt:

```text
Use o perfil product-architecture. Atue como PO, PM, Arquiteto e Engenheiro de software. Gere RESEARCH, SPEC, criterios de aceite, riscos, trade-offs e ADR. Nao implemente codigo ainda.
```

## Mapeamento por IDE

| IDE | Perfil principal | Observacao |
| --- | --- | --- |
| Codex | `product-architecture`, `frontend`, `backend`, `code-review` | Codex pode orquestrar a sequencia e versionar docs/scripts. |
| Cursor | `frontend`, `backend`, `code-review` | Melhor para iteracao rapida de codigo. Produto/arquitetura entram como contexto aprovado. |
| IntelliJ IDEA | `backend` | Principalmente Java/Spring/Quarkus, run configs, problemas e modulos. |
| Antigravity | `frontend`, futuro `backend`, futuro `product-architecture` | Manter poucos tools por perfil por causa do limite de 100 tools. |
| Obsidian | `product-architecture` | Segundo cerebro, decisoes, ADRs, specs e runbooks. |

## Perfis Docker MCP Gateway

### `antigravity-frontend`

Responsabilidade:

- Especialista frontend.
- Code review frontend.
- Validacao visual e funcional.

Tools esperadas:

- Playwright.
- Context7.
- Sequential Thinking.

Nao incluir:

- Banco.
- Cloud admin.
- Obsidian com escrita.
- GitHub amplo.

### Futuro `antigravity-backend`

Responsabilidade:

- Especialista backend.
- Code review backend/API.
- Testes, contratos, logs, seguranca e performance.

Possiveis tools:

- JetBrains MCP proxy, quando fizer sentido.
- Semgrep.
- GitHub scoped.
- Filesystem scoped ao repo.

Nao incluir:

- Browser visual, salvo backend com UI admin acoplada.
- Banco com escrita.
- Cloud admin.

### Futuro `antigravity-product-architecture`

Responsabilidade:

- PO.
- PM.
- Arquiteto.
- Engenheiro de software.
- Specs, ADRs, riscos, trade-offs e criterios de aceite.

Possiveis tools:

- Obsidian scoped.
- Graphify.
- GitHub issues/PR read.
- Filesystem scoped a docs/specs.

Nao incluir:

- Execucao de deploy.
- Escrita em banco.
- Cloud admin.
- Implementacao automatica sem gate humano.

## Regra de composicao

Quando a tarefa exigir produto + arquitetura + codigo + review, executar em etapas:

```text
product-architecture -> frontend/backend -> code-review
```

Nao transformar `frontend` e `backend` em perfis universais.
