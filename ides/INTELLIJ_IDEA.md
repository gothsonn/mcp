# IntelliJ IDEA / JetBrains AI

## Objetivo

Usar o IntelliJ IDEA como centro principal para Java, Spring Boot, Quarkus, arquitetura backend, testes, modulos, dependencias, run configurations e inspecoes.

Pelo perfil tecnico atual, esta e a integracao mais importante depois do Codex.

Guias complementares:

- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/USO_POR_PAPEL_E_STACK.md`

## Estado atual encontrado

Arquivos relevantes:

- `$HOME/Library/Application Support/JetBrains/IntelliJIdea2025.3/options/llm.mcpServers.xml`
- `$HOME/Library/Application Support/JetBrains/IntelliJIdea2025.3/plugins/mcpserver`

Estado encontrado no IntelliJ IDEA 2025.3:

- `google-ai-mcp-local` habilitado.
- Plugin `mcpserver` instalado.

Estado encontrado no IntelliJ IDEA 2026.1:

- `google-ai-mcp-local` habilitado.
- Plugin `mcpserver` instalado.

Outros IDEs JetBrains encontrados:

- WebStorm 2025.3 tem `google-ai-mcp-local`, mas desabilitado.
- DataGrip 2025.3 nao tem servidor MCP configurado.

## Plugins e MCPs para instalar ou manter

### Manter ou habilitar

- JetBrains AI Assistant.
- MCP Server plugin.
- Junie, se estiver licenciado e util para tarefas agentic dentro da IDE.

### Configurar primeiro

No IntelliJ IDEA:

1. Abrir `Settings`.
2. Ir em `Tools | MCP Server`.
3. Clicar em `Enable MCP Server`.
4. Em `Clients Auto-Configuration`, usar Auto-Configure para:
   - Codex.
   - Cursor, se fizer sentido.
5. Reiniciar o cliente configurado.

### Configurar AI Assistant para consumir MCPs externos

No IntelliJ IDEA:

1. Abrir `Settings`.
2. Ir em `Tools | AI Assistant | Model Context Protocol (MCP)`.
3. Adicionar servidores MCP externos quando necessario.
4. Preferir nivel por projeto quando o MCP for especifico de um projeto.

## Ferramentas esperadas via JetBrains MCP Server

Uso esperado pelo Codex/Cursor:

- Listar modulos do projeto.
- Listar dependencias.
- Ler run configurations.
- Executar run configurations.
- Obter problemas de arquivo via inspecoes da IDE.
- Abrir arquivo no editor.
- Reformatar arquivo.
- Navegar arvore do projeto.

Uso recomendado:

- Java/Spring/Quarkus: usar IntelliJ como fonte de verdade para modulos, dependencias, run configs e inspecoes.
- Angular/React/Next em monorepo Java: usar IntelliJ para contexto do backend e Cursor/Codex para iterar frontend.
- Code review Java: combinar inspecoes do IntelliJ com review rigoroso no Codex.

## Comando de fechamento

Ao finalizar uma feature com JetBrains AI/Junie, use:

```text
/feature-done {numero-opcional-da-tarefa}
```

Exemplo:

```text
/feature-done TXP-1175
```

O comportamento esperado e seguir o workflow local
`.agents/workflows/feature-done.md`, rodando Graphify por padrao e atualizando o
Obsidian do projeto.

## O que evitar

- Nao habilitar `brave mode` de execucao sem confirmacao no comeco.
- Nao expor projetos sensiveis para todos os clientes sem necessidade.
- Nao misturar configuracao de IntelliJ, WebStorm e DataGrip sem decidir o papel de cada um.
- Nao usar JetBrains MCP para substituir testes reais no terminal; usar como complemento.

## Validacao

No IntelliJ IDEA:

- Verificar se o MCP Server aparece como habilitado.
- Abrir a lista de ferramentas disponiveis.
- Confirmar que o projeto Java correto esta aberto.

No Codex, depois do Auto-Configure:

```bash
codex mcp list
codex mcp get jetbrains
./scripts/06-validate-jetbrains-mcp.sh
```

Checklist:

- Servidor JetBrains aparece no cliente configurado.
- O cliente consegue listar ferramentas.
- Uma consulta simples retorna modulos ou problemas do projeto.
- Run configurations so executadas com confirmacao enquanto o setup nao estiver maduro.
