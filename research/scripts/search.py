#!/usr/bin/env python3
"""Local Wiki retrieval: read-only Markdown search and deterministic evaluation."""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import sqlite3
import stat
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Callable, Iterable, Sequence


REPO_ROOT = Path(__file__).resolve().parents[2]
VALID_SCOPES = ("all", "wiki", "canon", "raw", "governance")
LAYER_PRIORITY = {"wiki": 0, "canon": 1, "governance": 2, "raw": 3}
EXCLUDED_PATHS = {
    "research/canon/_index.md",
    "research/wiki/index.md",
    "research/wiki/log.md",
    "research/wiki/topics/_clusters.md",
}


class SearchError(RuntimeError):
    """A concise, user-actionable retrieval failure."""


@dataclass(frozen=True)
class Document:
    path: str
    layer: str
    file_path: Path


@dataclass(frozen=True)
class Chunk:
    path: str
    layer: str
    title: str
    heading: str
    body: str
    start_line: int
    end_line: int


@dataclass(frozen=True)
class Result:
    path: str
    layer: str
    heading: str
    start_line: int
    end_line: int
    snippet: str
    score: float


def _is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def classify_path(relative_path: str) -> str | None:
    """Return the closed Local Wiki layer for a repository-relative path."""
    if relative_path in ("research/CLAUDE.md", "research/canon/README.md"):
        return "governance"
    if relative_path in EXCLUDED_PATHS:
        return None
    parts = Path(relative_path).parts
    if len(parts) < 3 or parts[0] != "research":
        return None
    if parts[1] in ("eval", "tests", "scripts"):
        return None
    if parts[1] in ("wiki", "canon", "raw"):
        if Path(relative_path).name.startswith("_"):
            return None
        return parts[1]
    return None


def discover_documents(repo_root: Path = REPO_ROOT) -> list[Document]:
    repo_root = repo_root.resolve()
    research_root = repo_root / "research"
    if research_root.is_symlink():
        raise SearchError(f"unsafe research root symlink rejected: {research_root}")
    if not research_root.is_dir():
        raise SearchError(f"research corpus not found: {research_root}")
    resolved_research = research_root.resolve()
    if not _is_relative_to(resolved_research, repo_root):
        raise SearchError(f"research root escapes repository: {research_root}")
    documents: list[Document] = []
    for candidate in sorted(research_root.rglob("*.md")):
        lexical_rel = candidate.relative_to(repo_root).as_posix()
        layer = classify_path(lexical_rel)
        if layer is None:
            continue
        try:
            mode = os.lstat(candidate).st_mode
        except OSError as exc:
            raise SearchError(f"cannot inspect corpus path {lexical_rel}: {exc}") from exc
        if stat.S_ISLNK(mode):
            raise SearchError(f"unsafe corpus symlink rejected: {lexical_rel}")
        if not stat.S_ISREG(mode):
            raise SearchError(f"corpus path is not a regular file: {lexical_rel}")
        try:
            resolved = candidate.resolve(strict=True)
        except OSError as exc:
            raise SearchError(f"cannot resolve corpus path {lexical_rel}: {exc}") from exc
        if not _is_relative_to(resolved, resolved_research):
            raise SearchError(f"corpus path escapes research root: {lexical_rel}")
        try:
            rel = resolved.relative_to(repo_root).as_posix()
        except ValueError as exc:
            raise SearchError(f"corpus path escapes repository: {lexical_rel}") from exc
        if ".." in Path(rel).parts:
            raise SearchError(f"unsafe result path rejected: {rel}")
        documents.append(Document(path=rel, layer=layer, file_path=resolved))
    if not documents:
        raise SearchError("no eligible Local Wiki Markdown files found")
    return documents


def _frontmatter(lines: Sequence[str]) -> tuple[int, str, list[str]]:
    """Return body start index, title, and topics from minimal YAML frontmatter."""
    if not lines or lines[0].strip() != "---":
        return 0, "", []
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        return 0, "", []
    title = ""
    topics: list[str] = []
    in_topics = False
    for line in lines[1:end]:
        title_match = re.match(r"^title:\s*(.+?)\s*$", line)
        if title_match:
            title = title_match.group(1).strip().strip("'\"")
            in_topics = False
            continue
        topics_match = re.match(r"^topics:\s*(.*)$", line)
        if topics_match:
            value = topics_match.group(1).strip()
            in_topics = not bool(value)
            if value.startswith("[") and value.endswith("]"):
                topics.extend(
                    item.strip().strip("'\"")
                    for item in value[1:-1].split(",")
                    if item.strip()
                )
            continue
        if in_topics:
            item = re.match(r"^\s*-\s*(.+?)\s*$", line)
            if item:
                topics.append(item.group(1).strip().strip("'\""))
            elif line and not line[0].isspace():
                in_topics = False
    return end + 1, title, topics


def parse_document(document: Document) -> list[Chunk]:
    try:
        lines = document.file_path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError) as exc:
        raise SearchError(f"cannot read {document.path}: {exc}") from exc
    body_start, frontmatter_title, topics = _frontmatter(lines)
    first_h1 = next(
        (m.group(1).strip() for line in lines[body_start:] if (m := re.match(r"^#\s+(.+)$", line))),
        "",
    )
    title = frontmatter_title or first_h1 or Path(document.path).stem.replace("-", " ")
    indexed_title = " ".join([title, *topics]).strip()

    headings: list[tuple[int, str]] = []
    for index in range(body_start, len(lines)):
        match = re.match(r"^#{1,6}\s+(.+?)\s*$", lines[index])
        if match:
            headings.append((index, match.group(1).strip()))

    chunks: list[Chunk] = []
    if not headings:
        body = "\n".join(lines[body_start:]).strip()
        if body:
            chunks.append(
                Chunk(
                    path=document.path,
                    layer=document.layer,
                    title=indexed_title,
                    heading=title,
                    body=body,
                    start_line=body_start + 1,
                    end_line=len(lines),
                )
            )
        return chunks

    first_heading_index = headings[0][0]
    intro = "\n".join(lines[body_start:first_heading_index]).strip()
    if intro:
        chunks.append(
            Chunk(
                path=document.path,
                layer=document.layer,
                title=indexed_title,
                heading=title,
                body=intro,
                start_line=body_start + 1,
                end_line=first_heading_index,
            )
        )
    for position, (start, heading) in enumerate(headings):
        next_start = headings[position + 1][0] if position + 1 < len(headings) else len(lines)
        body = "\n".join(lines[start + 1 : next_start]).strip()
        chunks.append(
            Chunk(
                path=document.path,
                layer=document.layer,
                title=indexed_title,
                heading=heading,
                body=body,
                start_line=start + 1,
                end_line=max(start + 1, next_start),
            )
        )
    return chunks


def load_chunks(repo_root: Path = REPO_ROOT) -> list[Chunk]:
    chunks = [chunk for document in discover_documents(repo_root) for chunk in parse_document(document)]
    if not chunks:
        raise SearchError("Local Wiki corpus contains no indexable Markdown content")
    return chunks


def build_index(
    chunks: Iterable[Chunk], connect_factory: Callable[..., sqlite3.Connection] | None = None
) -> sqlite3.Connection:
    connect = connect_factory or sqlite3.connect
    try:
        connection = connect(":memory:")
        connection.execute(
            """
            CREATE VIRTUAL TABLE chunks USING fts5(
                title, heading, body,
                path UNINDEXED, layer UNINDEXED,
                start_line UNINDEXED, end_line UNINDEXED,
                tokenize='trigram'
            )
            """
        )
        connection.executemany(
            "INSERT INTO chunks VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                (c.title, c.heading, c.body, c.path, c.layer, c.start_line, c.end_line)
                for c in chunks
            ),
        )
        return connection
    except (sqlite3.Error, OSError) as exc:
        try:
            connection.close()  # type: ignore[possibly-undefined]
        except Exception:
            pass
        raise SearchError(f"SQLite FTS5 trigram unavailable: {exc}") from exc


def _literal_terms(query: str) -> list[str]:
    return [term for term in re.findall(r"\S+", query) if len(term) >= 3]


def _fts_expression(query: str) -> str:
    terms = _literal_terms(query)
    return " OR ".join('"' + term.replace('"', '""') + '"' for term in terms)


def _short_search(chunks: Sequence[Chunk], query: str, scope: str, limit: int) -> list[Result]:
    needle = query.casefold()
    ranked: list[Result] = []
    for chunk in chunks:
        if scope != "all" and chunk.layer != scope:
            continue
        title_hits = chunk.title.casefold().count(needle)
        heading_hits = chunk.heading.casefold().count(needle)
        body_hits = chunk.body.casefold().count(needle)
        weighted = title_hits * 8 + heading_hits * 5 + body_hits
        if not weighted:
            continue
        compact = re.sub(r"\s+", " ", chunk.body).strip()
        ranked.append(
            Result(
                path=chunk.path,
                layer=chunk.layer,
                heading=chunk.heading,
                start_line=chunk.start_line,
                end_line=chunk.end_line,
                snippet=compact[:240],
                score=-float(weighted),
            )
        )
    ranked.sort(key=lambda r: (r.score, LAYER_PRIORITY[r.layer], r.path, r.start_line))
    return ranked[:limit]


def search(
    query: str,
    *,
    limit: int = 5,
    scope: str = "all",
    repo_root: Path = REPO_ROOT,
    connect_factory: Callable[..., sqlite3.Connection] | None = None,
) -> list[Result]:
    query = query.strip()
    if not query:
        raise SearchError("query must not be empty")
    if scope not in VALID_SCOPES:
        raise SearchError(f"invalid scope {scope!r}; choose from {', '.join(VALID_SCOPES)}")
    if isinstance(limit, bool) or not isinstance(limit, int) or not 1 <= limit <= 100:
        raise SearchError("limit must be an integer between 1 and 100")

    chunks = load_chunks(repo_root)
    expression = _fts_expression(query)
    if not expression:
        return _short_search(chunks, query, scope, limit)
    connection = build_index(chunks, connect_factory)
    try:
        where = "chunks MATCH ?"
        params: list[object] = [expression]
        if scope != "all":
            where += " AND layer = ?"
            params.append(scope)
        params.append(limit)
        rows = connection.execute(
            f"""
            SELECT path, layer, heading, start_line, end_line,
                   snippet(chunks, 2, '[', ']', ' … ', 24) AS snippet,
                   bm25(chunks, 8.0, 5.0, 1.0, 0.0, 0.0, 0.0, 0.0) AS score
            FROM chunks
            WHERE {where}
            ORDER BY score ASC,
                     CASE layer WHEN 'wiki' THEN 0 WHEN 'canon' THEN 1
                                WHEN 'governance' THEN 2 ELSE 3 END ASC,
                     path ASC, CAST(start_line AS INTEGER) ASC
            LIMIT ?
            """,
            params,
        ).fetchall()
    except sqlite3.Error as exc:
        raise SearchError(f"search query failed safely: {exc}") from exc
    finally:
        connection.close()
    results = [
        Result(
            path=str(row[0]),
            layer=str(row[1]),
            heading=str(row[2]),
            start_line=int(row[3]),
            end_line=int(row[4]),
            snippet=re.sub(r"\s+", " ", str(row[5])).strip(),
            score=float(row[6]),
        )
        for row in rows
    ]
    if any(not math.isfinite(result.score) for result in results):
        raise SearchError("search produced a non-finite ranking score")
    return results


def _validate_dataset(payload: object, indexed_paths: set[str]) -> list[dict[str, object]]:
    if not isinstance(payload, dict) or set(payload) != {"version", "cases"}:
        raise SearchError("dataset must contain exactly version and cases")
    if payload["version"] != 1 or not isinstance(payload["cases"], list) or not payload["cases"]:
        raise SearchError("dataset version must be 1 and cases must be a non-empty list")
    seen_ids: set[str] = set()
    seen_queries: set[str] = set()
    validated: list[dict[str, object]] = []
    for index, case in enumerate(payload["cases"]):
        if not isinstance(case, dict) or set(case) != {"id", "query", "scope", "expected_paths"}:
            raise SearchError(f"case {index} has invalid fields")
        case_id, query, scope, expected = (
            case["id"],
            case["query"],
            case["scope"],
            case["expected_paths"],
        )
        if not isinstance(case_id, str) or not case_id.strip() or case_id in seen_ids:
            raise SearchError(f"case {index} has empty or duplicate id")
        if not isinstance(query, str) or not query.strip() or query in seen_queries:
            raise SearchError(f"case {case_id} has empty or duplicate query")
        if scope not in VALID_SCOPES:
            raise SearchError(f"case {case_id} has invalid scope")
        if not isinstance(expected, list) or not expected or len(expected) != len(set(expected)):
            raise SearchError(f"case {case_id} expected_paths must be non-empty and unique")
        for path in expected:
            if (
                not isinstance(path, str)
                or Path(path).is_absolute()
                or ".." in Path(path).parts
                or path not in indexed_paths
            ):
                raise SearchError(f"case {case_id} has unsafe or unknown expected path: {path}")
        seen_ids.add(case_id)
        seen_queries.add(query)
        validated.append(case)
    return validated


def evaluate(dataset: Path, *, repo_root: Path = REPO_ROOT) -> dict[str, object]:
    try:
        payload = json.loads(dataset.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise SearchError(f"cannot load evaluation dataset {dataset}: {exc}") from exc
    indexed_paths = {chunk.path for chunk in load_chunks(repo_root)}
    cases = _validate_dataset(payload, indexed_paths)
    details: list[dict[str, object]] = []
    reciprocal_ranks: list[float] = []
    hits: list[int] = []
    for case in cases:
        results = search(str(case["query"]), limit=100, scope=str(case["scope"]), repo_root=repo_root)
        unique_paths: list[str] = []
        for result in results:
            if result.path not in unique_paths:
                unique_paths.append(result.path)
        expected = set(case["expected_paths"])  # type: ignore[arg-type]
        rank = next((i for i, path in enumerate(unique_paths, start=1) if path in expected), None)
        hit = int(rank is not None and rank <= 5)
        reciprocal = 0.0 if rank is None else 1.0 / rank
        hits.append(hit)
        reciprocal_ranks.append(reciprocal)
        details.append(
            {
                "id": case["id"],
                "hit_at_5": bool(hit),
                "rank": rank,
                "first_paths": unique_paths[:5],
            }
        )
    recall_at_5 = sum(hits) / len(hits)
    mrr = sum(reciprocal_ranks) / len(reciprocal_ranks)
    return {
        "cases": len(cases),
        "recall_at_5": recall_at_5,
        "mrr": mrr,
        "thresholds": {"recall_at_5": 1.0, "mrr": 0.75},
        "passed": recall_at_5 == 1.0 and mrr >= 0.75,
        "results": details,
    }


def _print_results(query: str, scope: str, results: Sequence[Result], as_json: bool) -> None:
    if as_json:
        print(
            json.dumps(
                {"query": query, "scope": scope, "results": [asdict(result) for result in results]},
                ensure_ascii=False,
                indent=2,
            )
        )
        return
    if not results:
        print("No local matches.")
        return
    for index, result in enumerate(results, start=1):
        print(
            f"{index}. {result.path}:{result.start_line}-{result.end_line} "
            f"[{result.layer}] {result.heading}"
        )
        print(f"   {result.snippet}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Search the local canon → raw → wiki corpus")
    subparsers = parser.add_subparsers(dest="command", required=True)
    query_parser = subparsers.add_parser("query", help="search Local Wiki Markdown")
    query_parser.add_argument("text")
    query_parser.add_argument("--limit", type=int, default=5)
    query_parser.add_argument("--scope", choices=VALID_SCOPES, default="all")
    query_parser.add_argument("--json", action="store_true", dest="as_json")
    eval_parser = subparsers.add_parser("eval", help="run the checked-in retrieval evaluation")
    eval_parser.add_argument("--dataset", type=Path, required=True)
    eval_parser.add_argument("--json", action="store_true", dest="as_json")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "query":
            results = search(args.text, limit=args.limit, scope=args.scope)
            _print_results(args.text, args.scope, results, args.as_json)
            return 0
        report = evaluate(args.dataset)
        if args.as_json:
            print(json.dumps(report, ensure_ascii=False, indent=2))
        else:
            print(
                f"Recall@5={report['recall_at_5']:.3f} "
                f"MRR={report['mrr']:.3f} cases={report['cases']} "
                f"verdict={'PASS' if report['passed'] else 'FAIL'}"
            )
        return 0 if report["passed"] else 1
    except SearchError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
