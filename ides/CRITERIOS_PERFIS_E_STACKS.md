# Criterios de perfis e stacks

## Base do perfil

Os perfis foram calibrados para um engenheiro senior fullstack/arquiteto com experiencia em:

- Java, Quarkus, Spring Boot, Kotlin, Node.js, NestJS, Python, PHP, .NET.
- Angular, React, Next.js, TypeScript e componentes reutilizaveis.
- Microservicos, Kafka, Redis, SQS/SNS, REST/SOAP, AWS, Docker, Kubernetes, OpenShift e CI/CD.
- PostgreSQL, Oracle, MySQL, SQL Server, DB2, MongoDB, DynamoDB e outros bancos SQL/NoSQL.
- Dados/ETL, observabilidade, seguranca, arquitetura limpa/hexagonal, SOLID, TDD e code review.

## Regra global de engenharia

Todo perfil deve avaliar:

- Consistencia arquitetural com o repositorio.
- SOLID, clean architecture, clean code, nomes e manutencao.
- Contratos de API, DTOs, validacao, versionamento e compatibilidade.
- Seguranca: auth/authz, input validation, injection, secrets, logs sensiveis e dependencias.
- Confiabilidade: timeouts, retries, idempotencia, backpressure, circuit breakers e degradacao graciosa.
- Dados: transacoes, consistencia, migracoes, indices, custo de query e rollback.
- Observabilidade: logs, metricas, traces, correlation IDs, health checks e erros acionaveis.
- Testes: unitarios, integracao, e2e, bordas, regressao e dados representativos.
- Operacao: Docker, Kubernetes/OpenShift, resources, startup/shutdown, readiness/liveness e rollback.

## Frontend

### Angular

- Detectar versao do Angular e convencoes locais antes de introduzir standalone components, signals ou novo padrao de estado.
- Revisar componentes, inputs/outputs, services, guards, interceptors, resolvers, typed forms e roteamento.
- Revisar ciclo de vida RxJS, async pipe, teardown, tratamento de erro e escopo de providers.
- Validar acessibilidade, responsividade, estados de loading/empty/error e consistencia visual.
- Rodar testes e Playwright/screenshots quando houver mudanca de UI.

### React / Next.js

- Detectar App Router vs Pages Router, client/server components e estrategia de data fetching.
- Revisar hooks, dependencies, memoizacao, stale closures, estado global e custo de re-render.
- Validar SSR/CSR hydration, cache, route handlers, server actions, suspense/loading e error boundaries.
- Nao usar memoizacao como muleta: corrigir pureza, estado local e efeitos desnecessarios antes de otimizar.
- Validar acessibilidade, responsividade, estados visuais e impacto no bundle.

## Backend

### Java / Spring Boot / Quarkus

- Revisar limites de modulo/pacote, direcao de dependencias, use cases/services/repositories e escopo transacional.
- Revisar JPA/Panache, N+1, indices, migrations, locking, connection pools e lazy loading.
- Validar blocking vs non-blocking, thread safety, alocacao de memoria e performance JVM.
- Em Quarkus, revisar CDI scopes, config build-time/runtime, impacto native-image e readiness de health/OpenTelemetry.
- Em microservicos, evitar transacao distribuida quando possivel; preferir consistencia eventual, outbox/inbox e compensacao.
- Em Kafka, revisar schema, chave, particionamento, ordering, retries, DLQ, replay e compatibilidade.
- Em Kubernetes/OpenShift, revisar startup/readiness/liveness probes, resources, graceful shutdown e config/secrets.

### NestJS / Node.js

- Revisar modulos, controllers, providers, DTOs, guards, interceptors, pipes e exception filters.
- Validar erros async, lifecycle da request, jobs, consumers de fila e backpressure.
- Revisar transacoes ORM, migrations, query plans, pools e validacao de dados.
- Rodar lint, testes unitarios e e2e quando existirem.

### Python

- Identificar se e API, automacao, ETL, pipeline de dados ou script antes de mexer na estrutura.
- Revisar type hints, schema validation, logging, retries, idempotencia e recuperacao de falhas.
- Para grandes volumes, revisar memoria e preferir streaming/chunking quando necessario.
- Validar com pytest e dados representativos, incluindo falhas.

### PHP

- Identificar Laravel, CodeIgniter ou arquitetura propria antes de mudar estrutura.
- Revisar validacao, middleware, auth/authz, SQL injection, CSRF, escaping e upload de arquivos.
- Preservar comportamento legado salvo quando SPEC/testes definirem migracao.
- Seguir PSR-12 quando nao houver padrao local mais forte.

## Banco de dados

- PostgreSQL, Oracle, MySQL, DB2 e SQL Server exigem raciocinio de plano de execucao e indices.
- Revisar isolamento transacional, lock scope, deadlocks, lote, paginacao e rollback de migracao.
- MCP de banco deve ser read-only por padrao; escrita em banco exige aprovacao explicita.

## Fontes usadas

- Google Engineering Practices: code review deve olhar design, funcionalidade, complexidade, testes, nomes, comentarios e cada linha humana relevante.
- OWASP Code Review Guide: security review manual continua importante no SDLC e deve buscar classes de vulnerabilidade no codigo.
- OWASP SQL Injection Prevention: evitar query dinamica por concatenacao, usar parametrizacao e menor privilegio.
- Angular Style Guide: convencoes locais e organizacao Angular devem orientar componentes e arquivos.
- React docs: memoizacao e `useCallback` sao otimizacoes, nao correcoes de comportamento.
- Quarkus transaction/Panache docs: escrita de banco deve estar em transacao.
- Kubernetes probes docs: startup, readiness e liveness tem propositos diferentes e afetam trafego/restart.
- Confluent Schema Registry docs: contratos Kafka precisam de compatibilidade e evolucao de schema.
- PHP-FIG PSR-12: estilo PHP base quando o repo nao define padrao proprio.
- Python logging docs: usar logging padrao para diagnostico integrado entre modulos.
