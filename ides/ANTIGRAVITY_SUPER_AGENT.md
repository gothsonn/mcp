# Antigravity com super agent e limite de tools

## Problema

O Antigravity pode ficar ruim quando muitos MCPs estao ativos ao mesmo tempo. Alem do consumo de contexto, existe limite pratico de ferramentas habilitadas. Como voce mencionou o limite de 100 tools, a configuracao deve evitar expor todos os MCPs diretamente para o agente.

## Decisao

Usar um modelo de "super agent" com gateway/perfis:

- O Antigravity enxerga poucos endpoints.
- Cada endpoint representa um perfil de trabalho.
- O gateway faz roteamento para MCPs internos.
- Cada perfil tem allowlist de ferramentas.

## Gateway recomendado

### Opcao 1 - Docker MCP Gateway

Ja existe no Cursor atual como `MCP_DOCKER`.

Vantagens:

- Centraliza servidores MCP.
- Gerencia ciclo de vida.
- Isola servidores em containers.
- Pode aplicar configuracao, credenciais e controle de acesso.
- Reduz duplicacao entre Cursor, Codex e Antigravity.

Comando base:

```bash
docker mcp gateway run
```

Perfil dedicado:

```bash
docker mcp gateway run --profile frontend
docker mcp gateway run --profile backend
docker mcp gateway run --profile database-readonly
```

### Opcao 2 - Gateway/proxy dedicado

Avaliar depois:

- routermcp.
- MetaMCP.
- MCP-X.
- Reflow Gateway.

Eu nao instalaria esses antes de testar o Docker MCP Gateway, porque voce ja tem Docker configurado no Cursor.

## Perfis recomendados

### Perfil `frontend`

Ferramentas:

- Playwright.
- GitHub.
- Filesystem scoped ao projeto.
- Figma, se houver design.
- Impeccable/Huashu como skill, nao necessariamente MCP.

Usar para:

- Angular.
- React.
- Next.js.
- Validacao visual.
- Prototipos.

Nao incluir:

- Banco de producao.
- AWS/GCP admin.
- Slack/Gmail.

### Perfil `backend`

Ferramentas:

- GitHub.
- Filesystem scoped ao projeto.
- Docker.
- JetBrains MCP, se o projeto principal estiver aberto no IntelliJ.
- Semgrep.

Usar para:

- Java.
- NestJS.
- Python.
- PHP.
- Testes.
- CI/CD.

Nao incluir:

- Browser se nao houver UI.
- Figma.
- Banco com escrita.

### Perfil `database-readonly`

Ferramentas:

- MCP Toolbox for Databases.
- Ferramentas SQL com usuario read-only.
- Schema docs.

Usar para:

- PostgreSQL.
- MySQL.
- SQL Server.
- Oracle e DB2 somente com cuidado adicional.

Regras:

- Proibir `DROP`, `ALTER`, `TRUNCATE`, `DELETE`, `UPDATE`, `INSERT` por padrao.
- Permitir somente `SELECT`, `EXPLAIN`, leitura de metadata e views controladas.
- Mascarar PII.
- Logar toda consulta.

### Perfil `architecture`

Ferramentas:

- Graphify.
- Obsidian.
- GitHub.
- Filesystem scoped.
- JetBrains MCP.

Usar para:

- ADR.
- desenho de solucao.
- analise de legado.
- planejamento tecnico.

### Perfil `product-delivery`

Ferramentas:

- Obsidian.
- GitHub issues.
- Notion ou docs, se houver.
- Sem acesso a banco por padrao.

Usar para:

- PO.
- Scrum Master.
- especificacao.
- backlog.
- criterios de aceite.

## Configuracao do Antigravity

Arquivo:

```text
/Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json
```

Exemplo com gateway local:

```json
{
  "mcpServers": {
    "gateway-frontend": {
      "serverUrl": "http://localhost:8931/mcp"
    }
  }
}
```

Se o cliente exigir `url` em vez de `serverUrl`, ajustar conforme o formato aceito pela versao instalada.

## Como usar

### Frontend

```text
Use o perfil frontend. Rode a aplicacao, valide o fluxo com Playwright, capture screenshot e proponha correcoes antes de editar arquivos.
```

### Backend

```text
Use o perfil backend. Leia a SPEC, identifique stack e testes, implemente a menor mudanca correta e rode a validacao.
```

### Banco

```text
Use o perfil database-readonly. Nao escreva no banco. Gere diagnostico, explain e recomendacao de indice, sem executar DDL/DML.
```

### Arquitetura

```text
Use o perfil architecture. Gere mapa de componentes, riscos, trade-offs e ADR. Nao implemente ainda.
```

### PO/Scrum

```text
Use o perfil product-delivery. Transforme a demanda em epico, historias, criterios de aceite, riscos e plano de sprint.
```

## Politica de seguranca

- Nunca habilitar todos os MCPs ao mesmo tempo.
- Preferir perfis com menos de 30 tools.
- Separar leitura e escrita.
- Produção somente read-only no inicio.
- Todo MCP com token deve ficar fora do repositorio.
- Todo acesso a banco deve ter usuario proprio para agente.
- Toda tarefa com ferramenta externa deve deixar log/auditoria.

## Checklist de validacao

```bash
jq . /Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json
docker mcp gateway run --help
```

Validar no Antigravity:

- O perfil aparece como conectado.
- A lista de tools fica abaixo do limite.
- O agente usa apenas tools do perfil.
- Uma tarefa simples executa ponta a ponta.
- Logs do gateway mostram quais tools foram chamadas.

