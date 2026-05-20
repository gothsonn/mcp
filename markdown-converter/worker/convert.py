#!/usr/bin/env python3
import argparse
import csv
import html
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert documents to Markdown for MCP/RAG ingestion.")
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--repo", required=True)
    args = parser.parse_args()

    source = Path(args.input)
    output = Path(args.output)
    repo = Path(args.repo)
    output.parent.mkdir(parents=True, exist_ok=True)

    try:
        markdown, engine = convert(source, repo)
        output.write_text(markdown, encoding="utf-8")
        print(json.dumps({"engine": engine, "output": str(output)}, ensure_ascii=False))
        return 0
    except Exception as exc:
        print(f"{type(exc).__name__}: {exc}", file=sys.stderr)
        return 1


def convert(source: Path, repo: Path) -> tuple[str, str]:
    suffix = source.suffix.lower()
    rel = source.relative_to(repo)

    if suffix in {".drawio"}:
        body = convert_drawio(source)
        return wrap(source, repo, body, "drawio-xml"), "drawio-xml"

    if suffix in {".json", ".jsonc"} and looks_like_openapi_or_postman(source):
        body = convert_api_json(source)
        return wrap(source, repo, body, "api-json"), "api-json"

    if suffix in {".csv", ".tsv"}:
        body = convert_table_text(source, delimiter="\t" if suffix == ".tsv" else ",")
        return wrap(source, repo, body, "csv-tsv"), "csv-tsv"

    if suffix in {".md", ".mdx"}:
        return wrap(source, repo, source.read_text(encoding="utf-8", errors="replace"), "markdown"), "markdown"

    if suffix in {
        ".txt",
        ".xml",
        ".html",
        ".htm",
        ".yaml",
        ".yml",
        ".toml",
        ".js",
        ".jsx",
        ".ts",
        ".tsx",
        ".java",
        ".kt",
        ".kts",
        ".py",
        ".php",
        ".sql",
        ".sh",
        ".bash",
        ".zsh",
        ".properties",
        ".gradle",
        ".graphql",
        ".gql",
        ".proto",
        ".puml",
        ".plantuml",
    } or source.name.lower() in {"dockerfile", "makefile", "readme", "license", "changelog"}:
        text = source.read_text(encoding="utf-8", errors="replace")
        body = f"```{language_hint(source)}\n{text}\n```" if should_fence(source) else text
        return wrap(source, repo, body, "plain-text"), "plain-text"

    markdown = convert_with_unstructured(source)
    return wrap(source, repo, markdown, "unstructured"), "unstructured"


def wrap(source: Path, repo: Path, body: str, engine: str) -> str:
    rel = source.relative_to(repo)
    title = rel.as_posix()
    return "\n".join(
        [
            "---",
            "type: converted-markdown",
            f"source: {json.dumps(str(source), ensure_ascii=False)}",
            f"source_relative: {json.dumps(title, ensure_ascii=False)}",
            f"engine: {engine}",
            "---",
            "",
            f"# {title}",
            "",
            body.rstrip(),
            "",
        ]
    )


def convert_with_unstructured(source: Path) -> str:
    try:
        from unstructured.partition.auto import partition
    except Exception as exc:
        raise RuntimeError(
            "unstructured is not installed. Run scripts/24-install-markdown-converter.sh"
        ) from exc

    kwargs = {"filename": str(source)}
    if source.suffix.lower() == ".pdf":
        kwargs["strategy"] = "fast"
    elements = partition(**kwargs)
    lines: list[str] = []
    for element in elements:
        text = str(element).strip()
        if not text:
            continue
        category = getattr(element, "category", element.__class__.__name__)
        if category in {"Title", "Header"}:
            lines.append(f"\n## {text}\n")
        elif category == "ListItem":
            lines.append(f"- {text}")
        elif category == "Table":
            lines.append("\n### Table\n")
            lines.append(text)
        else:
            lines.append(text)
            lines.append("")
    return "\n".join(lines).strip()


def convert_drawio(source: Path) -> str:
    raw = source.read_text(encoding="utf-8", errors="replace")
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        return f"```xml\n{raw}\n```"

    lines = ["## Draw.io Diagram", ""]
    for diagram in root.findall(".//diagram"):
        name = diagram.attrib.get("name", "diagram")
        lines.append(f"### {name}")
        lines.append("")
        text = "".join(diagram.itertext()).strip()
        if text:
            lines.append(text)
            lines.append("")
    if len(lines) <= 2:
        lines.append("```xml")
        lines.append(raw)
        lines.append("```")
    return "\n".join(lines)


def looks_like_openapi_or_postman(source: Path) -> bool:
    try:
        data = json.loads(source.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return False
    return any(key in data for key in ["openapi", "swagger", "info", "paths", "item"])


def convert_api_json(source: Path) -> str:
    data = json.loads(source.read_text(encoding="utf-8", errors="replace"))
    lines: list[str] = []
    info = data.get("info") if isinstance(data, dict) else None
    if isinstance(info, dict):
        lines.append(f"## {info.get('title', source.name)}")
        if info.get("version"):
            lines.append(f"- Version: `{info.get('version')}`")
        if info.get("description"):
            lines.append("")
            lines.append(str(info.get("description")))
            lines.append("")

    paths = data.get("paths") if isinstance(data, dict) else None
    if isinstance(paths, dict):
        lines.append("## Endpoints")
        for endpoint, methods in paths.items():
            if not isinstance(methods, dict):
                continue
            for method, spec in methods.items():
                if method.lower() not in {"get", "post", "put", "patch", "delete", "options", "head"}:
                    continue
                summary = spec.get("summary") if isinstance(spec, dict) else ""
                lines.append(f"### {method.upper()} {endpoint}")
                if summary:
                    lines.append(summary)
                lines.append("")

    items = data.get("item") if isinstance(data, dict) else None
    if isinstance(items, list):
        lines.append("## Postman Items")
        flatten_postman_items(items, lines)

    lines.append("## Raw JSON")
    lines.append("```json")
    lines.append(json.dumps(data, ensure_ascii=False, indent=2))
    lines.append("```")
    return "\n".join(lines)


def flatten_postman_items(items, lines: list[str], prefix: str = "") -> None:
    for item in items:
        if not isinstance(item, dict):
            continue
        name = item.get("name", "item")
        request = item.get("request")
        if isinstance(request, dict):
            method = request.get("method", "")
            url = request.get("url", "")
            lines.append(f"### {prefix}{name}")
            lines.append(f"- Method: `{method}`")
            lines.append(f"- URL: `{url}`")
            lines.append("")
        nested = item.get("item")
        if isinstance(nested, list):
            flatten_postman_items(nested, lines, f"{prefix}{name} / ")


def convert_table_text(source: Path, delimiter: str) -> str:
    rows = []
    with source.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.reader(handle, delimiter=delimiter)
        for row in reader:
            rows.append(row)
            if len(rows) >= 200:
                break
    if not rows:
        return ""
    width = max(len(row) for row in rows)
    normalized = [row + [""] * (width - len(row)) for row in rows]
    header = normalized[0]
    lines = [
        "| " + " | ".join(escape_cell(c) for c in header) + " |",
        "| " + " | ".join("---" for _ in header) + " |",
    ]
    for row in normalized[1:]:
        lines.append("| " + " | ".join(escape_cell(c) for c in row) + " |")
    return "\n".join(lines)


def escape_cell(value: str) -> str:
    return html.escape(value).replace("|", "\\|")


def should_fence(source: Path) -> bool:
    return source.suffix.lower() not in {".txt", ".html", ".htm"}


def language_hint(source: Path) -> str:
    return {
        ".js": "javascript",
        ".jsx": "jsx",
        ".ts": "typescript",
        ".tsx": "tsx",
        ".java": "java",
        ".kt": "kotlin",
        ".kts": "kotlin",
        ".py": "python",
        ".php": "php",
        ".sql": "sql",
        ".sh": "bash",
        ".bash": "bash",
        ".zsh": "zsh",
        ".xml": "xml",
        ".yaml": "yaml",
        ".yml": "yaml",
        ".json": "json",
        ".toml": "toml",
        ".graphql": "graphql",
        ".gql": "graphql",
        ".proto": "proto",
        ".gradle": "groovy",
    }.get(source.suffix.lower(), "")


if __name__ == "__main__":
    raise SystemExit(main())
