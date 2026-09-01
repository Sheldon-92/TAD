from __future__ import annotations

import json
import os
import sqlite3
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from research.scripts import search as local_search


ROOT = Path(__file__).resolve().parents[2]
DATASET = ROOT / "research" / "eval" / "retrieval-queries.json"


def write(root: Path, relative: str, content: str) -> Path:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return path


class SearchTests(unittest.TestCase):
    def test_real_query_returns_traceable_headingless_page(self) -> None:
        results = local_search.search("MCP prompt injection", limit=5, repo_root=ROOT)
        match = next(result for result in results if result.path.startswith("research/wiki/"))
        self.assertGreaterEqual(match.start_line, 1)
        self.assertGreaterEqual(match.end_line, match.start_line)
        self.assertTrue(match.heading)

    def test_raw_scope_json_contract_is_non_empty_and_typed(self) -> None:
        results = local_search.search("agent memory vector database", scope="raw", repo_root=ROOT)
        self.assertTrue(results)
        for result in results:
            payload = local_search.asdict(result)
            self.assertEqual(set(payload), {"path", "layer", "heading", "start_line", "end_line", "snippet", "score"})
            self.assertEqual(result.layer, "raw")
            self.assertIsInstance(result.score, float)
            self.assertGreaterEqual(result.start_line, 1)
            self.assertGreaterEqual(result.end_line, result.start_line)

    def test_all_four_scopes_have_results(self) -> None:
        queries = {
            "wiki": "prompt injection",
            "canon": "prompt injection",
            "raw": "agent memory",
            "governance": "Iron Rule",
        }
        for scope, query in queries.items():
            with self.subTest(scope=scope):
                results = local_search.search(query, scope=scope, repo_root=ROOT)
                self.assertTrue(results)
                self.assertTrue(all(result.layer == scope for result in results))

    def test_cjk_and_short_query_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            write(root, "research/raw/cjk.md", "# 向量检索基础\n\nAI 本地知识。\n")
            cjk = local_search.search("向量检索", repo_root=root)
            short = local_search.search("AI", repo_root=root)
            self.assertEqual(cjk[0].path, "research/raw/cjk.md")
            self.assertEqual(short[0].path, "research/raw/cjk.md")

    def test_fts_control_characters_are_literal_and_safe(self) -> None:
        results = local_search.search('" OR * NOT ( )', repo_root=ROOT)
        self.assertIsInstance(results, list)

    def test_invalid_inputs_fail(self) -> None:
        for query, limit, scope in (("", 5, "all"), ("x", 0, "all"), ("x", 5, "private")):
            with self.subTest(query=query, limit=limit, scope=scope):
                with self.assertRaises(local_search.SearchError):
                    local_search.search(query, limit=limit, scope=scope, repo_root=ROOT)

    def test_symlink_escape_is_rejected_in_temporary_git_repo(self) -> None:
        with tempfile.TemporaryDirectory() as tmp, tempfile.TemporaryDirectory() as outside:
            root = Path(tmp)
            (root / "research" / "raw").mkdir(parents=True)
            external = Path(outside) / "secret.md"
            external.write_text("outside secret", encoding="utf-8")
            os.symlink(external, root / "research" / "raw" / "escape.md")
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            subprocess.run(["git", "add", "research/raw/escape.md"], cwd=root, check=True)
            with self.assertRaisesRegex(local_search.SearchError, "symlink"):
                local_search.search("secret", repo_root=root)

    def test_research_root_symlink_is_rejected_without_traceback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp, tempfile.TemporaryDirectory() as outside:
            root = Path(tmp)
            external = Path(outside) / "research"
            write(external.parent, "research/raw/external.md", "# External\n\nneedle\n")
            os.symlink(external, root / "research")
            with self.assertRaisesRegex(local_search.SearchError, "research root symlink"):
                local_search.search("needle", repo_root=root)

    def test_unavailable_fts5_fails_closed(self) -> None:
        with self.assertRaisesRegex(local_search.SearchError, "FTS5"):
            local_search.search(
                "prompt injection",
                repo_root=ROOT,
                connect_factory=mock.Mock(side_effect=sqlite3.OperationalError("no fts5")),
            )

    def test_evaluation_passes_real_queries(self) -> None:
        report = local_search.evaluate(DATASET, repo_root=ROOT)
        self.assertTrue(report["passed"], report)
        self.assertEqual(report["recall_at_5"], 1.0)
        self.assertGreaterEqual(report["mrr"], 0.75)

    def test_evaluation_rejects_unknown_expected_path(self) -> None:
        payload = json.loads(DATASET.read_text(encoding="utf-8"))
        payload["cases"][0]["expected_paths"] = ["research/raw/missing.md"]
        with tempfile.TemporaryDirectory() as tmp:
            dataset = Path(tmp) / "bad.json"
            dataset.write_text(json.dumps(payload), encoding="utf-8")
            with self.assertRaisesRegex(local_search.SearchError, "unknown expected path"):
                local_search.evaluate(dataset, repo_root=ROOT)

    def test_evaluation_rejects_duplicate_ids_and_queries(self) -> None:
        payload = json.loads(DATASET.read_text(encoding="utf-8"))
        payload["cases"][1]["id"] = payload["cases"][0]["id"]
        with tempfile.TemporaryDirectory() as tmp:
            dataset = Path(tmp) / "duplicate.json"
            dataset.write_text(json.dumps(payload), encoding="utf-8")
            with self.assertRaisesRegex(local_search.SearchError, "duplicate id"):
                local_search.evaluate(dataset, repo_root=ROOT)

    def test_no_result_case_fails_metrics_honestly(self) -> None:
        payload = {
            "version": 1,
            "cases": [
                {
                    "id": "no-result",
                    "query": "zzzzzzzzzzzz impossible query",
                    "scope": "wiki",
                    "expected_paths": ["research/wiki/topics/mcp-security.md"],
                }
            ],
        }
        with tempfile.TemporaryDirectory() as tmp:
            dataset = Path(tmp) / "no-result.json"
            dataset.write_text(json.dumps(payload), encoding="utf-8")
            report = local_search.evaluate(dataset, repo_root=ROOT)
            self.assertFalse(report["passed"])
            self.assertEqual(report["recall_at_5"], 0.0)

    def test_search_does_not_write_corpus(self) -> None:
        paths = [path for path in (ROOT / "research").rglob("*") if path.is_file()]
        before = {path: (path.stat().st_mtime_ns, path.read_bytes()) for path in paths}
        local_search.search("prompt injection", repo_root=ROOT)
        after = {path: (path.stat().st_mtime_ns, path.read_bytes()) for path in paths}
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
