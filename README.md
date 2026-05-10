# MCP / IDE Setup Kit

Kit para replicar e manter a configuracao de agentes, IDEs, MCPs, skills e complementos entre maquinas macOS.

## Objetivo

Padronizar a configuracao de:

- Codex.
- IntelliJ IDEA / JetBrains AI.
- Cursor.
- Antigravity.
- Obsidian / segundo cerebro.
- Complementos: RTK, Caveman, Graphify, Impeccable, Huashu Design e Taste.

## Regra principal

Este repositorio pode versionar:

- Documentacao.
- Templates sem secrets.
- Scripts de check, backup e configuracao.
- Inventarios.
- Planos de instalacao.

Este repositorio nao deve versionar:

- Tokens.
- `.env`.
- Chaves privadas.
- Arquivos com credenciais reais.
- Sessoes de navegador.
- Dumps de banco.
- Backups reais de configuracao local.

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
| `scripts/04-configure-cursor.sh` | Prepara configuracao Cursor a partir de template. | Sim, com confirmacao por variavel |
| `scripts/05-configure-antigravity.sh` | Prepara configuracao Antigravity a partir de template. | Sim, com confirmacao por variavel |

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
- Python/pip.
- Docker Desktop.
- IntelliJ IDEA.
- Cursor.
- Codex.
- Antigravity.
- ripgrep.
- RTK.

## Documentacao principal

- `ides/PLANO_INSTALACAO_SEQUENCIAL.md`
- `ides/GLOBAL_VS_REPOSITORIO.md`
- `ides/MCP_STACK_RECOMENDADO.md`
- `ides/ANTIGRAVITY_SUPER_AGENT.md`
