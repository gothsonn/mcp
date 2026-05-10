# Inventario do repo piloto rafaelfreitas

## Caminho

```text
/Users/rafaelpereirafreitas/Sites/rafaelfreitas
```

## GitHub

```text
origin: https://github.com/gothsonn/rafaelfreitas.git
remote main: 14caca5 Enrich agent profiles with stack criteria
```

O remote foi vinculado ao repo local, o baseline fullstack foi enviado para `origin/main` e o repo piloto recebeu os perfis/skills padrao.

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

Estado publicado:

```text
## main...origin/main
14caca5 Enrich agent profiles with stack criteria
5afcaaf Add default profile skills
5cfa8b5 Add standard agent profiles
736fc05 Add fullstack portfolio baseline and agent rules
```

Arquivos locais ignorados continuam fora do Git: `.DS_Store`, `.idea/`, `deploy/keys/`, `frontend/node_modules/`, `frontend/dist/`, `frontend/.angular/`, `backend/target/` e `backend/spring-petclinic/`.

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

1. Baseline Git publicado.
2. Regras Graphify instaladas no repo:

```bash
TARGET_REPO=/Users/rafaelpereirafreitas/Sites/rafaelfreitas \
APPLY=1 INSTALL_GRAPHIFY_PROJECT=1 \
/Users/rafaelpereirafreitas/Sites/mcp/scripts/11-install-optional-complements.sh
```

3. Gerar grafo inicial:

```bash
cd /Users/rafaelpereirafreitas/Sites/rafaelfreitas
graphify extract . --backend gemini
graphify cluster-only .
```

4. Revisar `graphify-out/GRAPH_REPORT.md` antes de decidir se algum artefato entra no Git.

Resultado validado:

```text
graphify-out/graph.json
graphify-out/graph.html
graphify-out/GRAPH_REPORT.md
```

Grafo inicial: 110 nodes, 156 edges, 15 communities.

## Perfis a usar

Perfis instalados em `.agents/profiles/`:

- `frontend`
- `backend`
- `product-architecture`
- `code-review`

Skills instaladas por padrao:

- `frontend`: Impeccable, Taste, Graphify
- `backend`: Impeccable, Graphify
- `product-architecture`: Impeccable, Huashu, Graphify
- `code-review`: Impeccable, Taste, Graphify

Regra enriquecida instalada:

```text
.agents/rules/profile-engineering.md
```

Ela cobre criterios genericos e especificos para Angular, React/Next.js, Java/Spring/Quarkus, NestJS/Node.js, Python, PHP, bancos, Kafka e Kubernetes/OpenShift.

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

Usar o `mcp-control` para instalar a mesma composicao em outros repositorios e validar se cada repo precisa de ajustes locais em `PRODUCT.md`, `DESIGN.md` e `docs/design/TASTE.md`.
