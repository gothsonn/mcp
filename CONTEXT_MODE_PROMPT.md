# Context Mode Prompt

Use context-mode como camada principal de economia de contexto.

## Regra obrigatoria para Codex e Codex CLI

Ao iniciar trabalho neste projeto, faca uma ingestao leve antes de analisar ou
responder sobre arquitetura, stack, testes, tarefas, logs ou documentacao.

Use `ctx_batch_execute` para coletar e indexar o contexto inicial com comandos
seguros e saida limitada, por exemplo:

- `pwd`;
- `git status --short --branch`;
- `find . -maxdepth 2 -type f \( -name package.json -o -name pom.xml -o -name build.gradle -o -name pyproject.toml -o -name requirements.txt -o -name composer.json -o -name README.md -o -name AGENTS.md -o -name GEMINI.md -o -name CLAUDE.md -o -name CONTEXT_MODE_PROMPT.md \)`;
- `rg -n "scripts|dependencies|plugins|spring|quarkus|nestjs|angular|react|next|pytest|maven|gradle" package.json pom.xml build.gradle pyproject.toml composer.json README.md AGENTS.md GEMINI.md CLAUDE.md CONTEXT_MODE_PROMPT.md 2>/dev/null`.

Depois da ingestao inicial:

- use `ctx_index` para documentacao relevante encontrada no projeto;
- use `ctx_search` para responder a partir do material indexado;
- use `ctx_execute_file` para analisar logs, specs, Swagger/OpenAPI ou arquivos grandes;
- use `ctx_batch_execute` para diagnosticos de build, testes e estrutura.

Sempre que houver analise de repositorio, comandos, logs, documentacao ou
arquivos grandes:

- use `ctx_batch_execute` para comandos e diagnostico;
- use `ctx_execute_file` para arquivos grandes e logs;
- use `ctx_index` para documentacao relevante;
- use `ctx_search` para responder com base no conteudo indexado.

Nao despeje outputs grandes no contexto.

Retorne apenas:

- achados relevantes;
- evidencias curtas;
- caminhos de arquivos;
- riscos;
- proximos passos.
