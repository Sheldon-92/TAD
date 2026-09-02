from __future__ import annotations

import os
import subprocess
import tempfile
import threading
import unittest
import importlib.util
from unittest import mock
from pathlib import Path

from research.scripts import search as local_search

ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "research" / "fixtures" / "browser-clips"
SPEC = importlib.util.spec_from_file_location("import_clip", ROOT / "research/scripts/import-clip.py")
assert SPEC and SPEC.loader
import_clip = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(import_clip)

def init_root(root: Path) -> None:
    (root / "research/raw/articles").mkdir(parents=True)
    (root / "research/raw/transcripts").mkdir(parents=True)

class ImportClipTests(unittest.TestCase):
    def test_article_maps_to_raw_articles_and_preserves_body(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            output = import_clip.import_clip(FIXTURES / "article.md", root, None, False)
            text = output.read_text(encoding="utf-8")
            self.assertEqual(output.parent, root / "research/raw/articles")
            self.assertIn('original_url: "https://example.test/research/page"', text)
            self.assertIn("source_type: rendered_page_export", text)
            self.assertIn('keywords: ["local wiki", "capture"]', text)
            self.assertIn("This body was already rendered", text)

    def test_youtube_routes_to_transcripts_and_searches_timestamp_body(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            output = import_clip.import_clip(FIXTURES / "youtube-transcript.md", root, None, False)
            self.assertEqual(output.parent, root / "research/raw/transcripts")
            self.assertIn("source_type: youtube_transcript", output.read_text(encoding="utf-8"))
            results = local_search.search("Agent memory starts", scope="raw", repo_root=root)
            self.assertEqual(results[0].path, "research/raw/transcripts/a-public-youtube-transcript.md")

    def test_loopback_http_clip_is_allowed_but_remote_http_is_rejected(self) -> None:
        content = '---\ntitle: "Local fixture"\nsource_url: "http://localhost:8123/article"\nsaved_at: "2026-09-02T00:00:00Z"\n---\nbody\n'
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            source = root / "local.md"; source.write_text(content, encoding="utf-8")
            output = import_clip.import_clip(source, root, None, False)
            self.assertIn('original_url: "http://localhost:8123/article"', output.read_text(encoding="utf-8"))

    def test_invalid_input_rejected_without_output(self) -> None:
        cases = {
            "bad-url.md": '---\ntitle: "x"\nsource_url: "http://example.test"\nsaved_at: "2026-09-02T00:00:00Z"\n---\nbody\n',
            "secret.md": '---\ntitle: "x"\nsource_url: "https://example.test"\nsaved_at: "2026-09-02T00:00:00Z"\nauthorization: "secret"\n---\nbody\n',
            "bad-yaml.md": '---\ntitle: x\nsource_url: "https://example.test"\nsaved_at: "2026-09-02T00:00:00Z"\n---\nbody\n',
        }
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            for name, content in cases.items():
                source = root / name; source.write_text(content, encoding="utf-8")
                with self.subTest(name=name), self.assertRaises(import_clip.ImportError):
                    import_clip.import_clip(source, root, None, False)
            self.assertEqual(list((root / "research/raw/articles").iterdir()), [])

    def test_symlink_size_and_escape_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            target = root / "target.md"; target.write_text((FIXTURES / "article.md").read_text(encoding="utf-8"), encoding="utf-8")
            link = root / "link.md"; os.symlink(target, link)
            with self.assertRaises(import_clip.ImportError): import_clip.import_clip(link, root, None, False)
            huge = root / "huge.md"; huge.write_bytes(b"x" * (import_clip.MAX_BYTES + 1))
            with self.assertRaises(import_clip.ImportError): import_clip.import_clip(huge, root, None, False)
            invalid_utf8 = root / "invalid.md"; invalid_utf8.write_bytes(b"\xff\xfe")
            with self.assertRaises(import_clip.ImportError): import_clip.import_clip(invalid_utf8, root, None, False)
            with self.assertRaises(import_clip.ImportError): import_clip.import_clip(FIXTURES / "article.md", root, "research/raw/articles/../escape.md", False)

    def test_symlinked_destination_parent_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp, tempfile.TemporaryDirectory() as outside:
            root = Path(tmp); init_root(root)
            articles = root / "research/raw/articles"
            articles.rmdir()
            os.symlink(outside, articles)
            with self.assertRaises(import_clip.ImportError):
                import_clip.import_clip(FIXTURES / "article.md", root, None, False)
            self.assertEqual(list(Path(outside).iterdir()), [])

    def test_collision_is_non_overwriting_and_no_temp_residue(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            first = import_clip.import_clip(FIXTURES / "article.md", root, None, False)
            first.write_text("sentinel", encoding="utf-8")
            second = import_clip.import_clip(FIXTURES / "article.md", root, None, False)
            self.assertNotEqual(first, second); self.assertEqual(first.read_text(encoding="utf-8"), "sentinel")
            self.assertFalse(list(first.parent.glob(".import-clip-*")))

    def test_short_writes_are_completed_before_publish(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            original_write = import_clip.os.write
            def short_write(fd, data):
                return original_write(fd, data[:max(1, len(data) // 3)])
            with mock.patch.object(import_clip.os, "write", side_effect=short_write):
                output = import_clip.import_clip(FIXTURES / "article.md", root, None, False)
            self.assertIn("This body was already rendered", output.read_text(encoding="utf-8"))

    def test_concurrent_importers_publish_complete_distinct_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            outputs, errors = [], []
            def run():
                try: outputs.append(import_clip.import_clip(FIXTURES / "article.md", root, None, False))
                except Exception as exc: errors.append(exc)
            threads = [threading.Thread(target=run) for _ in range(5)]
            for thread in threads: thread.start()
            for thread in threads: thread.join()
            self.assertFalse(errors); self.assertEqual(len({path.name for path in outputs}), 5)
            for output in outputs: self.assertIn("authorized user", output.read_text(encoding="utf-8"))

    def test_cli_dry_run_does_not_write(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); init_root(root)
            completed = subprocess.run(["python3", str(ROOT / "research/scripts/import-clip.py"), str(FIXTURES / "article.md"), "--repo-root", str(root), "--dry-run"], check=True, capture_output=True, text=True)
            self.assertIn("research/raw/articles/authorized-research-page.md", completed.stdout)
            self.assertFalse(list((root / "research/raw/articles").iterdir()))

if __name__ == "__main__": unittest.main()
