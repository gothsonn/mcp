# Inventario de repos piloto

## Objetivo

Mapear onde cada complemento opcional deve ser testado primeiro, sem instalar nada automaticamente em todos os repositorios.

## Candidatos detectados

| Repo | Sinais detectados | Uso recomendado |
| --- | --- | --- |
| `/Users/rafaelpereirafreitas/Sites/projeto_qrcode_movidesk` | `package.json`, `vite.config.ts`, testes, `src/` | Piloto frontend React/Vite para Impeccable, Taste e Playwright. |
| `/Users/rafaelpereirafreitas/Sites/PortoSeguro/auto-cotacao-web` | `angular.json`, `package.json` | Piloto Angular corporativo para Impeccable e Playwright. |
| `/Users/rafaelpereirafreitas/Sites/PortoSeguro/auto-individual-web` | `angular.json`, `package.json` | Segundo piloto Angular depois do `auto-cotacao-web`. |
| `/Users/rafaelpereirafreitas/Sites/rafaelfreitas` | `frontend/angular.json`, `backend/pom.xml`, Docker no backend | Piloto fullstack pessoal para Graphify e Taste. |
| `/Users/rafaelpereirafreitas/Sites/easysuite` | Java, Python, Vite, Docker, Airflow, Kafka, OpenSearch | Piloto Graphify para monorepo/grupo grande. |
| `/Users/rafaelpereirafreitas/Sites/Cresol` | Varios `pom.xml`, UIs Next.js, Docker | Piloto Graphify + JetBrains + Playwright por UI. |
| `/Users/rafaelpereirafreitas/Sites/livelo` | Java, Next.js, React Native, Docker | Piloto por perfil frontend/backend/mobile. |
| `/Users/rafaelpereirafreitas/Sites/automacao-pontos` | Python, Streamlit, RPA, testes | Piloto de runbook/evidencia, nao Impeccable. |

## Ordem de piloto

1. `projeto_qrcode_movidesk`: menor blast radius para Impeccable/Taste.
2. `rafaelfreitas`: fullstack pessoal para Graphify.
3. `easysuite`: Graphify em grupo grande depois de validar custo/tempo.
4. `PortoSeguro/auto-cotacao-web`: Angular corporativo com cuidado de design system.

## Politica

- Antes de alterar qualquer repo piloto, verificar `git status --short --branch`.
- Nunca sobrescrever `PRODUCT.md`, `DESIGN.md`, `.agents/`, `.cursor/` ou `graphify-out/` se ja existirem sem revisar.
- Commitar complementos no repo de destino somente quando o usuario aprovar.
- Manter artefatos grandes fora do Git ate decidir explicitamente.
