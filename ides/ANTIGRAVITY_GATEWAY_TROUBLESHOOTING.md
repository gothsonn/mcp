# Antigravity Gateway troubleshooting

## Filesystem

Status: resolvido.

O erro ocorria porque o servidor `filesystem` exige `filesystem.paths`.

Configuracao aplicada:

```bash
docker mcp profile config antigravity-backend \
  --set "filesystem.paths=[\"$HOME/Sites\"]"

docker mcp profile config antigravity-product-architecture \
  --set "filesystem.paths=[\"$HOME/Sites\"]"
```

O script `scripts/14-create-antigravity-docker-profiles.sh` agora aplica essa configuracao automaticamente. Dry-run validado:

- `antigravity-backend`: 86 tools.
- `antigravity-product-architecture`: 73 tools.

## Semgrep

Status: pendente.

O servidor remoto do catalogo Docker retornou `Unauthorized` no gateway. A documentacao atual da Semgrep recomenda instalar a CLI, fazer login e entao instalar/configurar o MCP.

Caminho recomendado:

```bash
brew install semgrep
semgrep login
semgrep install-semgrep-pro
```

Depois validar fora do gateway:

```bash
semgrep --version
semgrep scan --config auto $HOME/Sites/rafaelfreitas
```

So depois reativar no gateway:

```bash
docker mcp profile create --id antigravity-backend --name "Antigravity Backend" ...
```

Alternativa futura: usar o MCP local da Semgrep via `uvx semgrep-mcp` ou container `ghcr.io/semgrep/mcp`, se o Docker MCP Gateway permitir modelar comando/args de forma segura no profile.

## Database Server

Status: pendente.

O `database-server` do catalogo Docker foi testado com:

```bash
docker pull --platform linux/amd64 souhardyak/mcp-db-server@sha256:0c530cfd08ac28a497e8ccd6365b2e1ca87f7fc3676b3175235d0e301da25d17
docker mcp profile config tmp-db-test --set 'database-server.database_url=sqlite+aiosqlite:///data/test.db'
docker mcp gateway run --profile tmp-db-test --dry-run
```

Mesmo assim, o gateway retornou EOF ao inicializar o servidor. Por isso ele nao deve entrar no perfil automatico ainda.

Caminho recomendado:

- Manter `antigravity-database-readonly` com Oracle MCP, que subiu com 5 tools e allowlist sem `execute_query`.
- Para PostgreSQL/MySQL/SQL Server/DB2, criar MCP dedicado read-only por banco quando houver conexao real e usuario sem escrita.
- Nunca colocar connection string com senha em repositorio; usar Docker MCP secrets ou variaveis locais.

## Politica

- `filesystem` pode ficar em backend/product-architecture com escopo `$HOME/Sites`.
- `semgrep` entra somente depois de login/config validado.
- `database-server` fica fora ate existir imagem/servidor compativel e read-only confiavel.
