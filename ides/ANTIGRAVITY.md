# Antigravity

## Objetivo

Usar o Antigravity como ambiente agentic controlado para tarefas maiores, validacao com navegador, automacoes integradas e casos especificos com Google/GCP/Firebase.

Como o Antigravity tende a ter maior autonomia, a configuracao deve comecar limpa e ganhar MCPs apenas quando existir um caso de uso concreto.

Guias complementares:

- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/USO_POR_PAPEL_E_STACK.md`
- `ides/ANTIGRAVITY_SUPER_AGENT.md`

## Estado atual encontrado

- Arquivo: `$HOME/.gemini/antigravity/mcp_config.json`
- Estado recomendado para esta maquina:

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

## Plugins e MCPs para instalar ou manter

### Manter inicialmente

Manter sem MCPs globais ate validar um fluxo real.

### Instalar primeiro somente se houver projeto Google

Firebase/GCP MCP, quando houver necessidade real de:

- Firestore.
- Authentication.
- Cloud Functions.
- App Hosting.
- Logs e deploys ligados a Firebase/GCP.

Preferir autenticacao via CLI oficial quando possivel, por exemplo `firebase login` ou `gcloud auth login`, evitando tokens em arquivo.

### Instalar por necessidade

Possiveis MCPs futuros:

- Playwright/browser testing, para validacao de UI.
- GitHub, se o fluxo no Antigravity exigir PR/issues.
- Banco de dados, somente com escopo de projeto e credenciais via ambiente.
- shadcn/Figma, somente em projetos frontend onde isso gere valor real.

Por causa do limite pratico de tools, preferir gateway/perfis em vez de varios MCPs diretos. O desenho recomendado esta em `ides/ANTIGRAVITY_SUPER_AGENT.md`.

## Observacoes importantes

- O arquivo do Antigravity e global.
- Alguns MCPs remotos para Antigravity usam `serverUrl`, nao `url`.
- Reiniciar o editor apos editar `mcp_config.json`.
- Se usar token, tratar o valor como segredo pessoal.

## Modelo de configuracao

STDIO local:

```json
{
  "mcpServers": {
    "nomeDoServidor": {
      "command": "npx",
      "args": ["-y", "pacote-mcp"]
    }
  }
}
```

HTTP remoto, quando a integracao pedir `serverUrl`:

```json
{
  "mcpServers": {
    "nomeDoServidor": {
      "serverUrl": "https://exemplo.com/mcp"
    }
  }
}
```

Docker MCP Gateway via stdio, recomendado para o perfil validado nesta maquina:

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

Templates adicionais por perfil:

```text
templates/antigravity/mcp_config.gateway-backend-stdio.example.json
templates/antigravity/mcp_config.gateway-product-architecture-stdio.example.json
templates/antigravity/mcp_config.gateway-database-readonly-stdio.example.json
```

Aplicar um perfil por vez:

```bash
APPLY=1 PROFILE=gateway-backend-stdio ./scripts/05-configure-antigravity.sh
APPLY=1 PROFILE=gateway-product-architecture-stdio ./scripts/05-configure-antigravity.sh
APPLY=1 PROFILE=gateway-database-readonly-stdio ./scripts/05-configure-antigravity.sh
```

Criar ou validar os perfis Docker MCP Gateway:

```bash
APPLY=1 ./scripts/14-create-antigravity-docker-profiles.sh
```

## Comando de fechamento

Ao finalizar uma feature, use no Antigravity:

```text
/feature-done {numero-opcional-da-tarefa}
```

Exemplo:

```text
/feature-done TXP-1175
```

O Antigravity deve seguir `.agents/workflows/feature-done.md`: atualizar
Graphify por padrao, atualizar Obsidian e validar o vault. Se precisar pular
Graphify, isso deve ser pedido explicitamente.

## O que evitar

- Nao adicionar varios MCPs globais de uma vez.
- Nao ativar acesso a banco/producao sem tarefa concreta.
- Nao guardar tokens pessoais em repositorios ou dotfiles sincronizados.
- Nao usar Antigravity com autonomia alta em repositorios desconhecidos.

## Validacao

Depois de editar:

```bash
jq . $HOME/.gemini/antigravity/mcp_config.json
./scripts/08-validate-antigravity-mcp.sh
```

Checklist:

- JSON valido.
- Servidor aparece no painel MCP do Antigravity.
- Ferramentas aparecem como conectadas.
- Uma pergunta simples consegue usar explicitamente o MCP.
- Reiniciar o editor se o servidor nao carregar.
