# Context Mode Prompt

Use context-mode como camada principal de economia de contexto.

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
