# MCP / IDE Setup Kit

Kit para replicar e manter a configuracao de agentes, IDEs, MCPs, skills e complementos entre maquinas macOS.

## Objetivo

Padronizar a configuracao de:

- Codex.
- IntelliJ IDEA / JetBrains AI.
- Antigravity.
- Obsidian / segundo cerebro.
- Complementos: Context Mode, Graphify, Impeccable, Huashu Design, Taste, Caveman e RTK auxiliar.
- MCP global `mcp-control` para inspecionar e instalar perfis/skills por repositorio.

## Regra principal

Este repositorio pode versionar:

- Documentacao.
- Templates sem secrets.
- `credential_mcp.env.example` como contrato de credenciais por repositorio.
- Scripts de check, backup e configuracao.
- Inventarios.
- Planos de instalacao.

Este repositorio nao deve versionar:

- Tokens.
- `.env`.
- `credential_mcp.env`.
- Chaves privadas.
- Arquivos com credenciais reais.
- Sessoes de navegador.
- Dumps de banco.
- Backups reais de configuracao local.

## Politica npm global

O npm global da maquina deve usar sempre o registry publico:

```bash
npm config set registry https://registry.npmjs.org/ --location=user
```

Registries corporativos, tokens de CodeArtifact/Artifactory/Nexus e ajustes
como `strict-ssl=false` nao devem ficar em `$HOME/.npmrc`. Quando um projeto
precisar de npm corporativo, a configuracao deve ser local do repositorio, por
exemplo em `.npmrc` do projeto ou em variaveis carregadas pelo
`credential_mcp.env`.

## Ordem de uso em uma nova maquina

1. Clonar este repositorio.
2. Rodar `scripts/00-check-system.sh`.
3. Rodar `APPLY=1 scripts/02-install-global-tools.sh` para instalar prerequisitos ausentes.
4. Rodar `scripts/01-backup-current.sh`.
5. Revisar `ides/PLANO_INSTALACAO_SEQUENCIAL.md`.
6. Aplicar uma IDE por vez.
7. Reautenticar manualmente servicos externos.
8. Validar cada fase antes de seguir.

## Scripts

| Script | Funcao | Altera configuracao? |
| --- | --- | --- |
| `scripts/00-check-system.sh` | Inventaria ferramentas, configs e paths. | Nao |
| `scripts/01-backup-current.sh` | Copia configs atuais para `backups/`. | Nao altera origem |
| `scripts/02-install-global-tools.sh` | Instala/valida prerequisitos e ferramentas globais aprovadas. | Sim, com confirmacao por variavel |
| `scripts/03-configure-codex.sh` | Prepara configuracao Codex a partir de template. | Sim, com confirmacao por variavel |
| `scripts/05-configure-antigravity.sh` | Prepara configuracao Antigravity a partir de template. | Sim, com confirmacao por variavel |
| `scripts/06-validate-jetbrains-mcp.sh` | Valida plugin/config MCP JetBrains e clientes externos. | Nao |
| `scripts/08-validate-antigravity-mcp.sh` | Valida Antigravity com Docker MCP Gateway e limite de tools. | Nao |
| `scripts/09-validate-obsidian-vault.sh` | Valida vault Obsidian e notas do projeto `mcp`. | Nao |
| `scripts/10-validate-optional-complements.sh` | Valida RTK, Graphify, npx, uv e repos piloto para complementos opcionais. | Nao |
| `scripts/11-install-optional-complements.sh` | Instala complementos opcionais aprovados, com escopo explicito. | Sim, com confirmacao por variavel |
| `scripts/12-configure-global-mcp-control.sh` | Configura o MCP global de controle em Codex e Antigravity. | Sim, com confirmacao por variavel |
| `scripts/13-validate-global-mcp-control.sh` | Valida o MCP global de controle. | Nao |
| `scripts/14-create-antigravity-docker-profiles.sh` | Cria perfis Docker MCP Gateway para Antigravity. | Sim, com confirmacao por variavel |
| `scripts/15-bootstrap-repo.sh` | Detecta stack e prepara perfis, skills, `.gitignore`, Graphify e Obsidian para um repo. | Sim, com confirmacao por variavel |
| `scripts/16-feature-done.sh` | Atualiza Obsidian e Graphify ao finalizar uma feature. | Sim, com confirmacao por variavel |
| `scripts/17-enable-context-mode-repo.sh` | Habilita regras context-mode por repositorio para Codex e registra no Obsidian. | Sim, com confirmacao por variavel |
| `scripts/18-configure-context-mode-clients.sh` | Configura context-mode em Antigravity, Cursor e Claude. | Sim, com confirmacao por variavel |

## Como rodar em modo seguro

Por padrao, scripts de configuracao nao devem aplicar mudancas destrutivas.

```bash
./scripts/00-check-system.sh
./scripts/01-backup-current.sh
```

Para scripts que instalam ou escrevem arquivos, usar explicitamente:

```bash
APPLY=1 ./scripts/02-install-global-tools.sh
```

Prerequisitos cobertos pelo script:

- Homebrew.
- Git.
- Node/npm/npx.
- npm global com registry publico.
- Python/pip.
- Docker Desktop.
- IntelliJ IDEA.
- Codex.
- Antigravity.
- ripgrep.
- Context Mode.
- RTK auxiliar.

## Documentacao principal

- `ides/PLANO_INSTALACAO_SEQUENCIAL.md`
- `ides/GLOBAL_VS_REPOSITORIO.md`
- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/ANTIGRAVITY_SUPER_AGENT.md`
- `ides/ANTIGRAVITY_GATEWAY_TROUBLESHOOTING.md`
- `ides/PERFIS_AGENTES.md`
- `ides/CRITERIOS_PERFIS_E_STACKS.md`
- `ides/GUIA_USO_PERFIS_SKILLS_OBSIDIAN.md`
- `ides/BOOTSTRAP_NOVO_REPOSITORIO.md`
- `ides/MCP_CONTROL_GLOBAL.md`
- `ides/MCP_TASKS_AND_PR_REVIEW.md`
- `ides/OBSIDIAN.md`
- `ides/COMPLEMENTOS_OPCIONAIS.md`
