# Obsidian / segundo cerebro

## Objetivo

Usar o Obsidian como base local de conhecimento para decisoes, arquitetura, specs, runbooks e contexto operacional dos projetos, sem transformar o vault em um MCP global com escrita ampla.

## Vault validado nesta maquina

```text
/Users/rafaelpereirafreitas/Documents/Obsidian Vault
```

Estrutura encontrada:

```text
00-Inbox/
01-Dashboards/
10-Projects/
20-Architecture/
30-ADRs/
40-RFCs/
50-Runbooks/
60-Incidents/
70-Daily/
80-AI/
90-System/
90-Templates/
```

Projeto criado para este kit:

```text
10-Projects/mcp/
  Project Overview.md
  Pipeline.md
  Repo Snapshot.md
  Decision Log.md
  Runbook.md
  AI Agent Operating Model.md
```

## Politica de acesso por IDE

### Codex

Usar leitura e escrita direta em Markdown somente quando a tarefa pedir atualizacao de memoria operacional, docs ou decisoes.

Prompt recomendado:

```text
Leia apenas o projeto Obsidian em 10-Projects/mcp e gere um resumo operacional. Nao altere arquivos sem aprovacao explicita.
```

### Cursor

Usar notas do projeto aberto como contexto auxiliar. Evitar apontar o Cursor para o vault inteiro quando estiver trabalhando em um unico repositorio.

Prompt recomendado:

```text
Use 10-Projects/mcp/Project Overview.md e Repo Snapshot.md como contexto do projeto. Compare a tarefa com Decision Log.md antes de sugerir alteracoes.
```

### IntelliJ IDEA / JetBrains AI

Usar Obsidian como referencia de arquitetura e decisoes, mas manter o contexto de codigo vindo do projeto aberto no IntelliJ.

Prompt recomendado:

```text
Consulte as notas de arquitetura do projeto no Obsidian e depois use o contexto do IntelliJ para validar se o codigo segue as decisoes registradas.
```

### Antigravity

Usar Obsidian somente no perfil `product-architecture`, nao nos perfis `frontend` ou `backend` validados para execucao.

Prompt recomendado:

```text
Use o perfil product-architecture. Leia as notas do projeto no Obsidian, gere riscos, trade-offs, SPEC e ADR. Nao implemente codigo ainda.
```

## MCP de Obsidian

Nao habilitar MCP comunitario de Obsidian no primeiro ciclo.

Motivos:

- O vault contem conhecimento amplo e pode misturar contexto pessoal, operacional e tecnico.
- O primeiro ciclo precisa provar valor com arquivos Markdown versionaveis e acesso por caminho.
- Escrita automatica ampla aumenta risco de ruido e alteracoes sem curadoria.

Reavaliar MCP de Obsidian somente depois de:

- Definir escopo por pasta.
- Confirmar logs/auditoria.
- Separar leitura e escrita.
- Ter pelo menos um projeto piloto com notas estaveis.

## Validacao

```bash
./scripts/09-validate-obsidian-vault.sh
```

Checklist:

- Vault existe.
- `.obsidian` existe.
- Estrutura principal existe.
- Projeto `10-Projects/mcp` existe.
- Notas obrigatorias existem.
- Repo Snapshot aponta para `/Users/rafaelpereirafreitas/Sites/mcp`.
