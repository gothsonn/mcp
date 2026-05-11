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

Perfil validado nesta maquina:

```bash
docker mcp catalog pull mcp/docker-mcp-catalog:latest
docker mcp profile create \
  --name "Antigravity Frontend" \
  --id antigravity-frontend \
  --server catalog://mcp/docker-mcp-catalog/playwright \
  --server catalog://mcp/docker-mcp-catalog/context7 \
  --server catalog://mcp/docker-mcp-catalog/sequentialthinking
docker mcp gateway run --profile antigravity-frontend --dry-run
```

Resultado esperado do dry-run: 26 tools dos servidores do perfil, abaixo do limite de 100. O Docker MCP Gateway tambem pode listar tools internas de gerenciamento dinamico depois dessa contagem.

Perfis adicionais criados nesta maquina:

```bash
APPLY=1 ./scripts/14-create-antigravity-docker-profiles.sh
```

| Perfil | Servidores | Dry-run observado |
| --- | --- | --- |
| `antigravity-backend` | GitHub Official, Filesystem scoped, Context7, Sequential Thinking, Docker Docs, Maven Tools, Javadocs, OpenAPI, Node.js Sandbox | 86 tools |
| `antigravity-product-architecture` | GitHub Official, Filesystem scoped, Obsidian, Context7, Sequential Thinking, Docker Docs, OpenAPI | 73 tools |
| `antigravity-database-readonly` | Oracle Database com allowlist read-only | 5 tools |

Observacoes:

- `filesystem` foi reabilitado nos perfis automaticos com `filesystem.paths=["$HOME/Sites"]`.
- `semgrep` remoto ficou fora do perfil automatico porque o gateway retornou `Unauthorized`; usar Semgrep local/CLI ou autenticar a integracao antes de reativar.
- `database-server` ficou fora do perfil automatico porque falhou no gateway mesmo com imagem `linux/amd64` pre-puxada e `database_url` configurado; usar Oracle read-only no gateway e tratar PostgreSQL/MySQL/SQL Server/DB2 em MCP dedicado depois.
- GitHub e Obsidian podem listar tools em dry-run, mas tarefas reais ainda exigem secrets/config local no Docker MCP.

### Opcao 2 - Gateway/proxy dedicado

Avaliar depois:

- routermcp.
- MetaMCP.
- MCP-X.
- Reflow Gateway.

Eu nao instalaria esses antes de testar o Docker MCP Gateway, porque voce ja tem Docker configurado no Cursor.

## Perfis recomendados

Decisao fixa: `frontend` e `backend` sao perfis de execucao especializada + code review. PO, PM, Arquiteto e Engenheiro de software ficam em perfil separado de governanca, chamado `product-architecture`.

Referencia: `ides/PERFIS_AGENTES.md`.

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
- Code review frontend.

Nao incluir:

- Banco de producao.
- AWS/GCP admin.
- Slack/Gmail.
- PO/PM/arquitetura ampla.

### Perfil `backend`

Ferramentas:

- GitHub Official.
- Filesystem scoped a `$HOME/Sites`.
- Context7.
- Sequential Thinking.
- Docker Docs.
- Maven Tools.
- Javadocs.
- OpenAPI.
- Node.js Sandbox.

Usar para:

- Java.
- NestJS.
- Python.
- PHP.
- Testes.
- CI/CD.
- Code review backend/API.

Nao incluir:

- Browser se nao houver UI.
- Figma.
- Banco com escrita.
- PO/PM/planejamento de sprint.

### Perfil `database-readonly`

Ferramentas:

- Oracle Database MCP com allowlist sem `execute_query`.
- PostgreSQL/MySQL/SQL Server/DB2 entram depois de validar MCP read-only compativel com esta maquina.

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

### Perfil `product-architecture`

Ferramentas:

- Obsidian.
- GitHub Official.
- Filesystem scoped a `$HOME/Sites`.
- Context7.
- Sequential Thinking.
- Docker Docs.
- OpenAPI.

Usar para:

- PO.
- PM.
- ADR.
- desenho de solucao.
- analise de legado.
- planejamento tecnico.
- criterios de aceite.
- riscos e trade-offs.

Nao incluir:

- implementacao automatica sem SPEC aprovada.
- deploy.
- banco/cloud com escrita.

## Configuracao do Antigravity

Arquivo:

```text
$HOME/.gemini/antigravity/mcp_config.json
```

Exemplo com gateway local:

```json
{
  "mcpServers": {
    "gateway-frontend": {
      "command": "docker",
      "args": ["mcp", "gateway", "run", "--profile", "antigravity-frontend"]
    }
  }
}
```

Se for usar um gateway HTTP externo em vez do stdio local, ajustar para `serverUrl` ou `url` conforme o formato aceito pela versao instalada.

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
Use o perfil product-architecture. Gere mapa de componentes, riscos, trade-offs, RESEARCH, SPEC e ADR. Nao implemente ainda.
```

### PO/PM

```text
Use o perfil product-architecture. Transforme a demanda em epico, historias, criterios de aceite, riscos e plano de entrega.
```

## Politica de seguranca

- Nunca habilitar todos os MCPs ao mesmo tempo.
- Preferir perfis com menos de 30 tools.
- Separar leitura e escrita.
- Produção somente read-only no inicio.
- Todo MCP com token deve ficar fora do repositorio.
- Todo acesso a banco deve ter usuario proprio para agente.
- Toda tarefa com ferramenta externa deve deixar log/auditoria.
- Nao criar perfil separado para `code-review`: review roda junto com `frontend` ou `backend`.

## Checklist de validacao

```bash
jq . $HOME/.gemini/antigravity/mcp_config.json
docker mcp gateway run --help
./scripts/08-validate-antigravity-mcp.sh
```

Validar no Antigravity:

- O perfil aparece como conectado.
- A lista de tools fica abaixo do limite.
- O agente usa apenas tools do perfil.
- Uma tarefa simples executa ponta a ponta.
- Logs do gateway mostram quais tools foram chamadas.
