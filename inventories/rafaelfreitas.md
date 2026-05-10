# Inventario do repo piloto rafaelfreitas

## Caminho

```text
/Users/rafaelpereirafreitas/Sites/rafaelfreitas
```

## Estrutura

```text
rafaelfreitas/
  deploy/
  frontend/
  backend/
  docker-compose.yml
  README.md
```

## Estado Git observado

O repositorio existe, mas ainda esta sem commit inicial:

```text
## No commits yet on main
?? .DS_Store
?? .idea/
?? README.md
?? backend/
?? deploy/
?? docker-compose.yml
?? frontend/
```

Antes de instalar complementos por projeto ou gerar `graphify-out/`, criar uma baseline minima no proprio repo `rafaelfreitas`.

## Subprojetos

| Pasta | Stack detectada | Perfil de agente |
| --- | --- | --- |
| `frontend/` | Angular, Node, `angular.json`, `package.json` | `frontend` |
| `backend/` | Java/Maven, Spring Boot, `pom.xml`, Dockerfile | `backend` |
| `backend/spring-petclinic/` | Java/Maven/Gradle, app exemplo/vendor | `backend`, mas revisar se deve entrar no grafo principal |
| `deploy/` | AWS, Cloudflare, Caddy, Nginx, compose EC2 | `product-architecture` e `backend` para infraestrutura |

## Politica para Graphify

Rode Graphify na raiz somente depois de excluir artefatos pesados e sensiveis.

Incluir:

- `README.md`
- `docker-compose.yml`
- `frontend/src`
- `frontend/angular.json`
- `frontend/package.json`
- `backend/src`
- `backend/pom.xml`
- `backend/Dockerfile`
- `deploy/aws/*.md`
- `deploy/cloudflare/*.md`
- `deploy/nginx`
- `deploy/caddy`

Excluir:

- `.git/`
- `.idea/`
- `.DS_Store`
- `frontend/node_modules/`
- `frontend/dist/`
- `frontend/.angular/`
- `backend/target/`
- `backend/spring-petclinic/target/`
- `backend/spring-petclinic/build/`
- `deploy/keys/`
- `graphify-out/`

## Ordem segura

1. Ajustar `.gitignore` na raiz de `rafaelfreitas`.
2. Fazer commit inicial do repo `rafaelfreitas`, se esse for o plano.
3. Instalar regras Graphify no repo:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/rafaelfreitas \
APPLY=1 INSTALL_GRAPHIFY_PROJECT=1 \
/Users/rafaelpereirafreitas/Sites/mcp/scripts/11-install-optional-complements.sh
```

4. Gerar grafo inicial:

```bash
cd /Users/rafaelpereirafreitas/Sites/rafaelfreitas
graphify .
```

5. Revisar `graphify-out/GRAPH_REPORT.md` antes de decidir se algum artefato entra no Git.

## Perfis a usar

### product-architecture

Usar para:

- Definir escopo do produto pessoal.
- Criar SPEC/ADR.
- Mapear relacao entre frontend, backend e deploy.
- Decidir o que entra no grafo.

### frontend

Usar para:

- Angular.
- UI/UX.
- Playwright.
- Impeccable depois da baseline.

### backend

Usar para:

- Spring Boot/Maven.
- APIs.
- Dockerfile.
- Testes backend.

## Proxima acao recomendada

Criar uma `.gitignore` raiz no repo `rafaelfreitas` antes de rodar Graphify ou instalar complementos por projeto.
