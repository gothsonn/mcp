# Codex

## Objetivo

Usar o Codex como agente principal para execucao de tarefas no repositorio: leitura de codigo, alteracoes controladas, testes, documentacao, automacoes, revisao tecnica e integracao com GitHub.

Este setup combina melhor com o perfil de trabalho atual: Java/Spring/Quarkus, Angular/TypeScript, Python para automacoes e dados, AWS, Kafka/SQS, Docker/Kubernetes, CI/CD e documentacao arquitetural.

Guias complementares:

- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/USO_POR_PAPEL_E_STACK.md`

## Estado atual encontrado

- Arquivo principal: `/Users/rafaelpereirafreitas/.codex/config.toml`
- Modelo atual: `gpt-5.5`
- Raciocinio: `medium`
- MCP externo: vazio em `[mcp_servers]`
- Plugins ativos:
  - `github@openai-curated`
  - `computer-use@openai-bundled`
  - `documents@openai-primary-runtime`
  - `spreadsheets@openai-primary-runtime`
  - `presentations@openai-primary-runtime`
  - `browser-use@openai-bundled`
- Plugin desativado:
  - `cloudflare@openai-curated`

## Plugins e MCPs para instalar ou manter

### Manter ativos

- GitHub: PRs, issues, revisao, CI e publicacao de alteracoes.
- Browser: validacao visual/localhost de frontends.
- Computer Use: automacao pontual de apps macOS quando necessario.
- Documents, Spreadsheets e Presentations: gerar ou editar entregaveis profissionais.

### Instalar primeiro

OpenAI Developer Docs MCP:

```bash
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
```

Uso esperado:

- Consultar documentacao atualizada de OpenAI APIs, Codex, Agents SDK, ChatGPT Apps e MCP.
- Evitar respostas baseadas em memoria antiga quando o assunto for OpenAI.

### Instalar depois

JetBrains MCP Server, apos configurar o IntelliJ IDEA:

- Usar o Auto-Configure do JetBrains para Codex, quando disponivel.
- Validar no Codex com:

```bash
codex mcp list
```

Uso esperado:

- Ler problemas de arquivos via inspecoes do IntelliJ.
- Consultar modulos, dependencias e run configurations.
- Abrir arquivos e rodar configuracoes do projeto pelo contexto da IDE.

Skills recomendadas por tipo de tarefa:

- Graphify: arquitetura, onboarding em repos grandes e analise de dependencias.
- Impeccable: auditoria e polimento de UI.
- Huashu Design: prototipos, slides, animacoes e infograficos.
- Caveman/RTK: reducao de tokens em sessoes longas.
- Cybersecurity scan: auditoria mensal, pre-release ou PR sensivel.

## O que evitar

- Nao adicionar MCPs de banco, cloud ou producao globalmente.
- Nao colocar secrets em `~/.codex/config.toml`.
- Nao habilitar servidores que executam comandos sem necessidade clara.
- Nao duplicar no Codex o que ja e melhor resolvido por plugin oficial.

## Validacao

Depois de cada alteracao:

```bash
codex mcp list
sed -n '1,220p' /Users/rafaelpereirafreitas/.codex/config.toml
```

Checklist:

- O servidor novo aparece em `codex mcp list`.
- O nome do MCP e curto e descritivo.
- Nenhum token ou secret ficou gravado em texto puro.
- O Codex consegue usar o MCP em uma pergunta simples.
