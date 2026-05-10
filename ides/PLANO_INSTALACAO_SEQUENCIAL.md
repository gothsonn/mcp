# Plano sequencial de instalacao e configuracao

## Regra de execucao

Configurar uma IDE por vez.

Nao passar para a proxima enquanto a atual nao cumprir:

- Backup dos arquivos de configuracao feito.
- Configuracao aplicada.
- Validacao tecnica executada.
- Teste funcional simples concluido.
- Inventario final registrado.
- Decisao explicita: `APROVADO PARA PROXIMA IDE`.

## Ordem

1. Codex.
2. Base compartilhada antes das demais IDEs: specs, gateway, Obsidian minimo e ferramentas estruturais.
3. IntelliJ IDEA / JetBrains AI.
4. Cursor.
5. Antigravity.
6. Complementos opcionais por projeto: Impeccable, Huashu, Taste, UI/UX Pro Max e outros.

Motivo da ordem:

- Codex precisa vir primeiro porque sera o executor e validador principal.
- A base compartilhada vem logo depois para evitar configurar cada IDE com MCPs duplicados ou conflitantes.
- IntelliJ, Cursor e Antigravity entram depois ja consumindo uma estrategia comum.
- Antigravity depende especialmente dessa base por causa do limite pratico de 100 tools.

## Politica de seguranca

- Nao gravar tokens em arquivos versionados.
- Nao copiar tokens para docs.
- Banco de dados sempre com usuario read-only no primeiro ciclo.
- Producao nao entra no primeiro ciclo, salvo aprovacao explicita.
- Antigravity nao deve receber todos os MCPs direto.
- Todo arquivo alterado deve ter backup antes.

## Fase 0 - Baseline antes de qualquer instalacao

### Objetivo

Registrar o estado atual para permitir rollback e comparacao.

### Comandos

```bash
mkdir -p /Users/rafaelpereirafreitas/Sites/mcp/backups
date +%Y%m%d-%H%M%S
codex mcp list
jq . /Users/rafaelpereirafreitas/.cursor/mcp.json
jq . /Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json
sed -n '1,220p' /Users/rafaelpereirafreitas/.codex/config.toml
```

### Backups

```bash
ts=$(date +%Y%m%d-%H%M%S)
cp /Users/rafaelpereirafreitas/.codex/config.toml /Users/rafaelpereirafreitas/Sites/mcp/backups/config.toml.$ts.bak
cp /Users/rafaelpereirafreitas/.cursor/mcp.json /Users/rafaelpereirafreitas/Sites/mcp/backups/cursor-mcp.json.$ts.bak
cp /Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json /Users/rafaelpereirafreitas/Sites/mcp/backups/antigravity-mcp_config.json.$ts.bak
cp "/Users/rafaelpereirafreitas/Library/Application Support/JetBrains/IntelliJIdea2025.3/options/llm.mcpServers.xml" "/Users/rafaelpereirafreitas/Sites/mcp/backups/intellij-llm.mcpServers.xml.$ts.bak"
```

### Criterio de pronto

- Backups existem.
- Configs atuais foram lidas sem erro.
- Inventario salvo ou anotado no resultado da execucao.

## Fase 1 - Codex

### Objetivo

Deixar o Codex como agente principal, com docs oficiais e plugins atuais preservados.

### Instalar/configurar

1. Confirmar plugins atuais.
2. Adicionar OpenAI Developer Docs MCP.
3. Nao adicionar banco/cloud/producao ainda.

### Comandos

```bash
codex mcp list
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
sed -n '1,260p' /Users/rafaelpereirafreitas/.codex/config.toml
```

### Teste funcional

No Codex, pedir:

```text
Use o OpenAI Developer Docs MCP e me diga qual documentacao oficial consultar para MCP e Agents SDK.
```

### Criterio de pronto

- `openaiDeveloperDocs` aparece em `codex mcp list`.
- Plugins atuais continuam ativos.
- Nenhum secret foi gravado.
- Codex responde usando docs oficiais.

### Gate

Somente seguir para a base compartilhada quando a fase estiver marcada como:

```text
APROVADO PARA PROXIMA FASE: Base compartilhada
```

## Fase 2 - Base compartilhada antes das demais IDEs

### Objetivo

Preparar as pecas comuns que vao orientar IntelliJ, Cursor e Antigravity, antes de configurar cada IDE.

Essa fase nao deve transformar tudo em global. Ela cria a base para que cada IDE seja configurada com menos retrabalho.

### Itens desta fase

1. Padrao de specs.
2. Estrategia de gateway/perfis para MCPs.
3. Obsidian minimo como segundo cerebro.
4. Graphify para repos grandes, se ja houver repo piloto.
5. RTK, se quisermos reduzir tokens de comandos desde o inicio.
6. Matriz global vs por repositorio.

### 2.1 - Padrao de specs

Criar o padrao que toda IDE deve respeitar:

```text
docs/specs/[FEATURE]-RESEARCH.md
docs/specs/[FEATURE]-SPEC.md
```

Uso:

- PO: transformar demanda em RESEARCH/SPEC.
- Arquiteto: validar decisoes e trade-offs antes de codigo.
- Dev: implementar apenas o que esta no SPEC.
- Code review: comparar PR contra SPEC.

### 2.2 - Gateway/perfis MCP

Definir antes de Cursor e Antigravity para evitar MCP duplicado.

Perfis planejados:

- `frontend`.
- `backend`.
- `database-readonly`.
- `architecture`.
- `product-delivery`.

Validacao inicial:

```bash
docker mcp gateway run --help
```

Nao precisa ativar todos os perfis agora. Nesta fase basta confirmar que o caminho tecnico existe e documentar qual perfil cada IDE vai consumir.

### 2.3 - Obsidian minimo

Definir o vault e a estrutura minima antes das IDEs:

```text
AI-Second-Brain/
  Projetos/
  Arquitetura/
  Operacao/
  Produto/
```

Primeiro ciclo:

- Sem MCP com escrita ampla.
- Leitura por arquivos Markdown quando necessario.
- Escrita sempre com aprovacao.

### 2.4 - Graphify

Instalar somente se houver repo piloto grande/legado para validar:

```bash
pip install graphifyy
graphify install
graphify /caminho/do/projeto
```

Se nao houver repo piloto, deixar como pendente e seguir.

### 2.5 - RTK

Opcional nesta fase. Faz sentido instalar cedo se vamos executar muitos comandos em Codex/Cursor/Antigravity.

```bash
brew install rtk
rtk --version
rtk init -g --codex
```

Nao ativar ainda para Cursor/Antigravity se essas IDEs ainda nao foram configuradas.

### 2.6 - Matriz global vs por repositorio

Antes de configurar IntelliJ/Cursor/Antigravity, revisar:

```text
ides/GLOBAL_VS_REPOSITORIO.md
```

Decisoes principais:

- RTK e Docker MCP Gateway podem ser globais.
- Graphify instala globalmente, mas outputs ficam por repo.
- Impeccable, Huashu e Taste devem ser por projeto inicialmente.
- MCPs de banco/cloud devem ser por projeto/perfil, nunca globais no primeiro ciclo.

### Criterio de pronto

- Estrategia de specs definida.
- Perfis MCP planejados.
- Obsidian minimo definido ou marcado como pendente com motivo.
- Docker MCP Gateway validado por `--help` ou marcado como pendente.
- Graphify/RTK instalados somente se houver decisao explicita.
- `ides/GLOBAL_VS_REPOSITORIO.md` revisado.
- Nenhum MCP sensivel foi ativado globalmente.

### Gate

Somente seguir para IntelliJ quando:

```text
APROVADO PARA PROXIMA IDE: IntelliJ IDEA
```

## Fase 3 - IntelliJ IDEA / JetBrains AI

### Objetivo

Transformar o IntelliJ IDEA na fonte de contexto Java/backend para Codex e, depois, Cursor.

### Instalar/configurar

1. Abrir IntelliJ IDEA 2025.3.
2. Confirmar plugin MCP Server.
3. Ir em `Settings | Tools | MCP Server`.
4. Habilitar MCP Server.
5. Usar `Clients Auto-Configuration` para Codex.
6. Manter execucao de run configurations com confirmacao humana.

### Arquivos envolvidos

```text
/Users/rafaelpereirafreitas/Library/Application Support/JetBrains/IntelliJIdea2025.3/options/llm.mcpServers.xml
/Users/rafaelpereirafreitas/.codex/config.toml
```

### Validacao

```bash
sed -n '1,220p' "/Users/rafaelpereirafreitas/Library/Application Support/JetBrains/IntelliJIdea2025.3/options/llm.mcpServers.xml"
codex mcp list
```

### Teste funcional

Com um projeto Java aberto no IntelliJ:

```text
Use o MCP do JetBrains para listar os modulos do projeto, problemas conhecidos e run configurations disponiveis. Nao execute nada ainda.
```

### Criterio de pronto

- JetBrains MCP Server aparece habilitado no IntelliJ.
- Codex consegue enxergar o servidor JetBrains.
- O agente consegue consultar informacao do projeto aberto.
- Nenhuma run configuration foi executada sem aprovacao.

### Gate

Somente seguir para Cursor quando:

```text
APROVADO PARA PROXIMA IDE: Cursor
```

## Fase 4 - Cursor

### Objetivo

Configurar o Cursor como editor fullstack rapido, sem virar concentrador global de todos os MCPs.

### Estado inicial esperado

Arquivo:

```text
/Users/rafaelpereirafreitas/.cursor/mcp.json
```

MCPs atuais:

- `MCP_DOCKER`.
- `GitKraken`.

### Instalar/configurar

1. Validar `MCP_DOCKER`.
2. Validar `GitKraken`.
3. Adicionar OpenAI Developer Docs MCP se fizer sentido no Cursor.
4. Adicionar Playwright MCP por projeto frontend, nao obrigatoriamente global.
5. Adicionar JetBrains MCP via Auto-Configure somente se o fluxo Java no Cursor for util.

### Config recomendado

Adicionar sem apagar os existentes:

```json
{
  "mcpServers": {
    "openaiDeveloperDocs": {
      "url": "https://developers.openai.com/mcp"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Validacao

```bash
jq . /Users/rafaelpereirafreitas/.cursor/mcp.json
```

Se `cursor-agent` estiver disponivel:

```bash
cursor-agent mcp list
cursor-agent mcp list-tools MCP_DOCKER
cursor-agent mcp list-tools GitKraken
```

### Teste funcional

Em um projeto frontend:

```text
Use Playwright MCP para abrir o localhost do projeto, listar os elementos principais da tela e capturar um screenshot. Nao altere arquivos.
```

### Criterio de pronto

- JSON valido.
- `MCP_DOCKER` e `GitKraken` continuam configurados.
- Playwright funciona em um projeto frontend piloto ou fica documentado como pendente.
- Cursor nao recebeu MCPs de banco/cloud globais.

### Gate

Somente seguir para Antigravity quando:

```text
APROVADO PARA PROXIMA IDE: Antigravity
```

## Fase 5 - Antigravity

### Objetivo

Configurar Antigravity com perfis/gateway para respeitar o limite de 100 tools e evitar exposicao excessiva.

### Decisao

Nao instalar todos os MCPs diretamente.

Usar:

- Docker MCP Gateway primeiro.
- Perfis por tipo de trabalho.
- Menos de 30 tools por perfil quando possivel.

### Arquivo

```text
/Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json
```

### Perfis

1. `frontend`.
2. `backend`.
3. `database-readonly`.
4. `architecture`.
5. `product-delivery`.

### Configuracao inicial recomendada

Comecar so com um perfil, por exemplo `frontend`:

```json
{
  "mcpServers": {
    "gateway-frontend": {
      "serverUrl": "http://localhost:8931/mcp"
    }
  }
}
```

Se a versao do cliente exigir `url`, trocar para:

```json
{
  "mcpServers": {
    "gateway-frontend": {
      "url": "http://localhost:8931/mcp"
    }
  }
}
```

### Comandos

```bash
docker mcp gateway run --help
jq . /Users/rafaelpereirafreitas/.gemini/antigravity/mcp_config.json
```

### Teste funcional

No Antigravity:

```text
Use o perfil frontend. Liste as tools disponiveis, confirme que esta abaixo do limite, abra uma pagina local simples com Playwright e capture evidencia. Nao edite arquivos.
```

### Criterio de pronto

- Antigravity carrega o perfil.
- Lista de tools fica abaixo do limite.
- O agente usa somente tools do perfil ativo.
- Logs do gateway mostram chamadas.
- Nenhum MCP de banco/cloud foi adicionado globalmente.

### Gate

Somente seguir para Obsidian quando:

```text
APROVADO PARA PROXIMA IDE: Obsidian / segundo cerebro
```

## Fase 6 - Obsidian / segundo cerebro completo

### Objetivo

Evoluir o Obsidian minimo da Fase 2 para uma base de conhecimento completa: decisoes, ADRs, specs, runbooks, aprendizados, arquitetura e contexto de negocio.

### Decisao inicial

Comecar sem MCP com escrita automatica ampla.

Preferir:

- Vault local.
- Pastas por projeto.
- Markdown versionavel.
- Acesso scoped por caminho.
- Escrita com aprovacao.

### Estrutura sugerida

```text
AI-Second-Brain/
  Projetos/
    automacao-pontos/
    projeto_qrcode_movidesk/
    mcp/
  Arquitetura/
    ADRs/
    Patterns/
  Operacao/
    Runbooks/
    Incidentes/
  Produto/
    Research/
    Specs/
    Backlog/
```

### Integracao com agentes

Primeiro ciclo:

- Codex acessa arquivos Markdown via filesystem quando necessario.
- Cursor acessa somente notas do projeto aberto.
- Antigravity acessa Obsidian somente pelo perfil `architecture` ou `product-delivery`.

Segundo ciclo, se fizer sentido:

- Avaliar MCP comunitario de Obsidian.
- Avaliar Graphify exportando para Obsidian.
- Avaliar Memory/Knowledge Graph.

### Teste funcional

Criar uma nota manual:

```text
Projetos/mcp/IDE-MCP-Setup.md
```

Pedir ao Codex:

```text
Leia a nota do projeto mcp no vault Obsidian e gere um resumo operacional sem alterar o arquivo.
```

### Criterio de pronto

- Vault definido.
- Estrutura criada.
- Agente consegue ler nota scoped.
- Escrita automatica continua bloqueada ou exige aprovacao.

## Fase 7 - Complementos opcionais por projeto

Executar somente depois das IDEs principais estarem estaveis, exceto Graphify/RTK quando aprovados na Fase 2.

### RTK

Objetivo: reduzir tokens em comandos shell.

```bash
brew install rtk
rtk --version
rtk init -g --codex
rtk init -g --agent cursor
rtk init --agent antigravity
```

Gate:

- `rtk --version` funciona.
- Comandos comuns continuam corretos.
- Saida comprimida nao esconde informacao critica de testes.

### Caveman

Objetivo: reduzir verbosidade de resposta quando desejado.

Primeiro dry-run:

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash -s -- --dry-run
```

Instalar somente por IDE aprovada:

```bash
npx skills add JuliusBrussee/caveman -a codex
npx skills add JuliusBrussee/caveman -a cursor
npx skills add JuliusBrussee/caveman -a antigravity
```

### Graphify

Objetivo: conhecimento estrutural de repos grandes.

```bash
pip install graphifyy
graphify install
graphify /caminho/do/projeto
```

Gate:

- `graphify-out/GRAPH_REPORT.md` gerado.
- `graphify-out/graph.html` abre.
- O agente usa o report antes de refatorar.

### Impeccable

Objetivo: elevar UI/UX em Angular, React e Next.js.

Instalar primeiro em um projeto piloto, nao global:

```bash
# seguir README do projeto impeccable para copiar dist da skill no projeto
```

Gate:

- Comando `$impeccable audit` funciona.
- Uma tela piloto recebe achados uteis.
- Nenhuma mudanca visual e aceita sem screenshot.

### Huashu Design

Objetivo: prototipos, decks, animacoes e infograficos.

```bash
npx skills add alchaincyf/huashu-design
```

Gate:

- Gera um prototipo HTML simples.
- Valida com Playwright.
- Nao substitui design system real sem revisao.

### Taste

Objetivo: perfil visual pessoal/projeto.

Primeiro ciclo:

- Exportar perfil como skill/local context.
- Evitar MCP remoto ate validar privacidade e OAuth.

Gate:

- Perfil aplicado a uma tela piloto.
- Resultado visual melhora de forma consistente.
- Anti-preferencias ficam claras.

## Quadro de progresso

| Fase | Status | Evidencia | Aprovacao |
| --- | --- | --- | --- |
| 0 - Baseline | Pendente |  |  |
| 1 - Codex | Pendente |  |  |
| 2 - Base compartilhada | Pendente |  |  |
| 3 - IntelliJ IDEA | Pendente |  |  |
| 4 - Cursor | Pendente |  |  |
| 5 - Antigravity | Pendente |  |  |
| 6 - Obsidian completo | Pendente |  |  |
| 7 - Complementos por projeto | Pendente |  |  |
