# Cursor

## Objetivo

Usar o Cursor como ambiente rapido para edicao fullstack, especialmente Angular, React, TypeScript, Nest.js, ajustes multiarquivo, refatoracoes pontuais e prototipacao.

O Cursor nao deve concentrar todos os MCPs globais. Ele deve ficar leve e orientado a produtividade de codigo.

Guias complementares:

- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/USO_POR_PAPEL_E_STACK.md`

## Estado atual encontrado

- Arquivo global: `/Users/rafaelpereirafreitas/.cursor/mcp.json`
- MCPs atuais:
  - `MCP_DOCKER`
  - `GitKraken`

Configuracao atual encontrada:

```json
{
  "mcpServers": {
    "MCP_DOCKER": {
      "command": "docker",
      "args": ["mcp", "gateway", "run"]
    },
    "GitKraken": {
      "command": "/Users/rafaelpereirafreitas/Library/Application Support/Cursor/User/globalStorage/eamodio.gitlens/gk",
      "type": "stdio",
      "name": "GitKraken",
      "args": ["mcp", "--host=cursor", "--source=gitlens", "--scheme=cursor"],
      "env": {}
    }
  }
}
```

## Plugins e MCPs para instalar ou manter

### Manter por enquanto

- Docker MCP Gateway: util para ferramentas em container, se estiver conectando corretamente.
- GitKraken/GitLens: util para contexto Git, historico e autoria.

### Instalar primeiro

OpenAI Developer Docs MCP, se voce for usar Cursor para projetos com OpenAI:

```json
{
  "mcpServers": {
    "openaiDeveloperDocs": {
      "url": "https://developers.openai.com/mcp"
    }
  }
}
```

Importante: mesclar essa entrada dentro do `mcpServers` existente, sem apagar `MCP_DOCKER` e `GitKraken`.

### Instalar depois

JetBrains MCP Server, somente depois de configurar o IntelliJ IDEA:

- Preferir Auto-Configure pelo JetBrains.
- Usar quando precisar de contexto da IDE Java dentro do Cursor.

Playwright MCP para projetos frontend:

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

Configuracao Cursor validada na maquina:

- `MCP_DOCKER`
- `GitKraken`
- `openaiDeveloperDocs`
- `playwright`
- `jetbrains`

Validar com:

```bash
./scripts/07-validate-cursor-mcp.sh
```

Skills recomendadas:

- Impeccable em Angular/React/Next.js.
- Huashu Design para prototipos e demos visuais.
- Graphify em repos grandes.
- Taste quando houver perfil visual exportado.

## Configuracao por projeto

Para ferramentas especificas de um projeto, usar:

```text
<projeto>/.cursor/mcp.json
```

Exemplos de MCPs que devem ser por projeto:

- Banco de dados.
- AWS/GCP/Azure.
- Supabase/Firebase.
- Figma/shadcn quando acoplado ao frontend daquele projeto.
- Ferramentas com token pessoal.

## O que evitar

- Nao transformar o Cursor no concentrador global de todos os MCPs.
- Nao colocar credenciais em `~/.cursor/mcp.json` quando puder usar variaveis de ambiente.
- Nao manter MCPs que aparecem como desconectados ou que poluem o contexto.

## Validacao

Se o `cursor-agent` estiver instalado:

```bash
cursor-agent mcp list
cursor-agent mcp list-tools <nome-do-servidor>
```

Checklist:

- `MCP_DOCKER` conecta.
- `GitKraken` conecta.
- O MCP novo aparece no editor e no agent.
- Nenhum segredo ficou salvo direto no arquivo global.
