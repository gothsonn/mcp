---
name: feature-done
description: Finalize a feature by updating Obsidian and Graphify.
---

# /feature-done {optional issue key}

Use when the user finishes a feature and asks to close the work.

Default behavior:

- Resolve the current repository as the target repo.
- Use the optional issue key when provided, for example `/feature-done TXP-1175`.
- Run Graphify by default.
- Update the Obsidian project note.
- Append the project `Decision Log.md`.
- Validate the Obsidian project.

Command:

```bash
cd "$HOME/Sites/mcp"

TARGET_REPO="<current-repository>" \
FEATURE_KEY="<optional-issue-key>" \
APPLY=1 \
./scripts/16-feature-done.sh
```

Only set `RUN_GRAPHIFY=0` when the user explicitly asks to skip Graphify.
