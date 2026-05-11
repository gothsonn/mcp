# Guia de uso: perfis, skills e Obsidian

## Regra principal

Use perfis em sequencia, nao tudo ao mesmo tempo:

```text
product-architecture -> frontend/backend -> code review do proprio frontend/backend
```

O perfil `code-review` existe em Codex/Cursor como modo de revisao, mas no Antigravity nao existe gateway separado: review roda dentro de `antigravity-frontend` ou `antigravity-backend`.

## Quando usar cada perfil

| Perfil | Usar quando | Nao usar para |
| --- | --- | --- |
| `product-architecture` | demanda ambigua, discovery, SPEC, ADR, backlog, risco, trade-off, planejamento | implementar codigo direto |
| `frontend` | Angular, React, Next.js, UI, acessibilidade, Playwright, responsividade | decisao ampla de produto/arquitetura |
| `backend` | Java/Quarkus/Spring, NestJS/Node, Python, PHP, API, banco, fila, testes, seguranca | design visual ou planejamento de sprint |
| `database-readonly` | diagnostico de schema/indices/constraints/queries aprovadas | escrita em banco |

## Prompts base

### Planejamento

```text
Use o perfil product-architecture.
Leia o contexto do repo e, se existir, Graphify/Obsidian.
Gere RESEARCH, SPEC, criterios de aceite, riscos, trade-offs e ADR.
Nao implemente codigo ainda.
```

### Frontend

```text
Use o perfil frontend.
Stack: [Angular/React/Next.js].
Leia a SPEC aprovada e implemente somente o escopo descrito.
Use Impeccable/Taste para qualidade visual quando houver UI.
Valide com testes, build e Playwright/screenshot quando aplicavel.
Depois faca code review frontend no mesmo contexto.
```

### Backend

```text
Use o perfil backend.
Stack: [Java/Quarkus/Spring/NestJS/Python/PHP].
Leia a SPEC aprovada, preserve contratos e implemente a menor mudanca correta.
Valide testes, logs, seguranca, transacoes, observabilidade e performance.
Depois faca code review backend no mesmo contexto.
```

### Banco

```text
Use o perfil database-readonly.
Nao execute DDL ou DML.
Use apenas leitura de schema, constraints, indices, EXPLAIN e diagnostico.
Retorne recomendacoes sem alterar o banco.
```

## Skills por perfil

| Skill | Onde usar | Como usar |
| --- | --- | --- |
| Graphify | todos os perfis quando o repo for grande ou legado | gerar/consultar grafo para entender arquitetura, dependencias e comunidades |
| Impeccable | frontend, product-architecture, code review visual | auditar UX/UI, acessibilidade, hierarquia, estados e qualidade visual |
| Taste | frontend e review visual | aplicar preferencias/anti-preferencias visuais do projeto |
| Huashu | product-architecture e exploracao visual | gerar direcoes visuais, prototipos, decks e referencias de estilo |
| Playwright | frontend e validacao funcional | validar fluxo real, screenshot, responsividade e regressao visual |

## Ordem pratica por tipo de tarefa

### Feature nova

1. `product-architecture`: SPEC + criterios de aceite + riscos.
2. `frontend` ou `backend`: implementacao.
3. Mesmo perfil especialista: code review.
4. Atualizar Obsidian com decisao/resumo.

### Bug

1. `frontend` ou `backend`: reproduzir, localizar causa e corrigir.
2. Mesmo perfil: revisar regressao e testes.
3. Atualizar Obsidian somente se mudou regra, arquitetura, runbook ou incidente.

### Refatoracao

1. `product-architecture`: justificar risco/beneficio e plano.
2. `frontend` ou `backend`: aplicar em escopo pequeno.
3. Mesmo perfil: revisar compatibilidade, performance e testes.
4. Registrar ADR se mudar arquitetura ou contrato.

## Como instalar perfis e skills em um repo

Pelo MCP global:

```text
Use mcp-control para instalar os perfis frontend, backend e product-architecture no repo $HOME/Sites/NOME_DO_REPO com apply=true.
```

Isso cria/atualiza:

```text
.agents/profiles/
.agents/rules/profile-engineering.md
.agents/rules/graphify.md
.agents/workflows/graphify.md
.cursor/rules/graphify.mdc
PRODUCT.md
DESIGN.md
docs/design/TASTE.md
```

## Como atualizar Graphify

Depois de mudancas relevantes:

```bash
cd $HOME/Sites/NOME_DO_REPO
graphify extract . --backend gemini
graphify cluster-only .
```

Arquivos locais esperados:

```text
graphify-out/GRAPH_REPORT.md
graphify-out/graph.html
graphify-out/graph.json
```

Por padrao, `graphify-out/` fica fora do Git. Registrar no Obsidian apenas o resumo relevante.

## Como atualizar Obsidian

Vault validado:

```text
$HOME/Documents/Obsidian Vault
```

Projeto do kit:

```text
10-Projects/mcp/
```

Atualize Obsidian quando houver:

- decisao de arquitetura;
- mudanca de perfil/agente/MCP;
- novo runbook;
- resultado de validacao importante;
- incidente ou correcao operacional;
- resumo de Graphify que altere entendimento do sistema.

Nao atualize Obsidian para:

- cada commit pequeno;
- log bruto de terminal;
- tokens, secrets, connection strings ou dados sensiveis;
- detalhes temporarios que pertencem ao Git ou issue tracker.

## Notas recomendadas por tipo

| Nota | Quando atualizar | Conteudo |
| --- | --- | --- |
| `Decision Log.md` | decisao tomada | data, decisao, motivo, impacto |
| `AI Agent Operating Model.md` | mudanca em perfis/MCPs/skills | modelo atual, responsabilidades e proximas decisoes |
| `Runbook.md` | procedimento operacional | comandos, pre-condicoes, validacao e rollback |
| `Repo Snapshot.md` | mudanca estrutural do repo | paths, remotes, branch, artefatos importantes |
| `Pipeline.md` | mudanca em instalacao/validacao | ordem de execucao e checkpoints |

## Template de atualizacao do Obsidian

```markdown
## YYYY-MM-DD - Titulo

Contexto:
- [o que mudou]

Decisao:
- [decisao tomada]

Impacto:
- [repos, IDEs, perfis ou skills afetados]

Validacao:
- [comandos ou evidencias]

Proximo passo:
- [acao concreta]
```

## Prompts para atualizar Obsidian

### Registrar decisao

```text
Atualize o Obsidian em 10-Projects/mcp/Decision Log.md com a decisao abaixo.
Nao inclua secrets.
Use data de hoje e uma entrada curta.

Decisao: [texto]
Motivo: [texto]
Impacto: [texto]
Validacao: [texto]
```

### Atualizar modelo operacional

```text
Atualize 10-Projects/mcp/AI Agent Operating Model.md com o estado atual dos perfis, skills e gateways.
Preserve o formato da nota.
Nao remova historico relevante.
```

### Registrar resumo Graphify

```text
Leia graphify-out/GRAPH_REPORT.md do repo [repo].
Atualize a nota Obsidian do projeto com resumo de comunidades, riscos arquiteturais e proximas acoes.
Nao copie o relatorio inteiro.
```

## Checklist antes de finalizar uma tarefa

- Perfil correto foi usado.
- Skills foram usadas somente quando agregaram valor.
- Testes/build/screenshot foram executados quando aplicavel.
- Obsidian foi atualizado se houve decisao duravel.
- Git nao contem secrets.
- Repo ficou limpo ou com pendencias explicadas.

## Comando de fechamento de feature

Ao finalizar uma feature, rode sempre o fluxo de fechamento:

```text
/feature-done {numero-opcional-da-tarefa}
```

Exemplo:

```text
/feature-done TXP-1175
```

Equivalente via terminal:

```bash
cd $HOME/Sites/mcp

TARGET_REPO=$HOME/Sites/livelo/liv-mfe-transfer-details \
FEATURE_KEY=TXP-1175 \
FEATURE_TITLE="WEB | Alteracoes na jornada por Tier" \
FEATURE_SUMMARY="UI passou a refletir minimoAplicavel retornado pela API." \
VALIDATION="lint/testes/review executados conforme repo." \
APPLY=1 \
./scripts/16-feature-done.sh
```

Graphify fica ativo por padrao. Para pular Graphify em um caso especifico,
somente quando solicitado explicitamente:

```bash
TARGET_REPO=$HOME/Sites/livelo/liv-mfe-transfer-details \
FEATURE_KEY=TXP-1175 \
RUN_GRAPHIFY=0 \
APPLY=1 \
./scripts/16-feature-done.sh
```

O script cria ou atualiza a nota `Feature <ID>.md`, registra entrada no
`Decision Log.md`, atualiza Graphify quando habilitado e valida o projeto no
Obsidian.
