#!/usr/bin/env python3
"""_rc_common.py — shared schema + determinism helpers for ALL ingest adapters.

This is the SINGLE enforcement point for the content.json schema and the
determinism contract (handoff §4.3). Every adapter (text/url/pdf, and ideally
epub) imports these so the schema + source_hash invariant cannot drift between
adapters. Lifted from epub-ingest.py's normalize / hash / write / escape logic.

STDLIB ONLY.

content.json schema (MUST match epub-ingest exactly):
  { "source_hash": "<sha256>", "title": "<non-empty>",
    "chapters": [ { "chapter_id": "c{n}", "title": "...", "href": "...",
        "paragraphs": [ { "pid": "c{n}-p{m}", "tag": "p|h1|h2|h3|li|blockquote|...",
                          "text": "<normalized>", "html": "<escaped+inline-whitelist>" } ] } ] }
"""
import hashlib
import json
import re
import sys
from pathlib import Path

# Shared with the extractor adapters (kept identical to epub-ingest sets).
BLOCK_TAGS = {"p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote", "pre", "dd", "dt"}
# Phase-4 url-ingest adds nav/footer/aside/header to the drop set (FR2).
SKIP_TAGS = {"script", "style", "head", "title", "nav", "footer", "aside", "header"}
INLINE_KEEP = {"em", "i", "strong", "b", "a", "code", "sup", "sub", "span", "br"}


def normalize_ws(text):
    """Collapse runs of whitespace to single spaces and strip.

    Byte-identical to epub-ingest._norm_ws — the determinism invariant depends on
    EVERY adapter normalizing text the same way."""
    return re.sub(r"\s+", " ", text or "").strip()


# Back-compat alias (epub-ingest names it _norm_ws).
_norm_ws = normalize_ws


def escape_text(text):
    """Escape plain text for the `html` field (epub _escape_text discipline).

    Stored-XSS guard: only &/</> escaped; never embeds raw source markup."""
    return (text or "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def source_hash(chapters):
    """sha256 over each paragraph's text + b"\\n" in order (handoff §4.3).

    NOTE: paragraph text MUST already be normalize_ws'd (adapters normalize at
    extraction time, exactly like epub-ingest). This reproduces epub-ingest's
    hash byte-for-byte so annotations re-attach identically across formats."""
    h = hashlib.sha256()
    for ch in chapters:
        for p in ch["paragraphs"]:
            h.update(p["text"].encode("utf-8"))
            h.update(b"\n")
    return h.hexdigest()


def make_paragraph(chapter_n, para_n, tag, text, html=None):
    """Build one schema-conformant paragraph dict (text already normalized)."""
    norm = normalize_ws(text)
    return {
        "pid": "c%d-p%d" % (chapter_n, para_n),
        "tag": tag if tag in BLOCK_TAGS else "p",
        "text": norm,
        "html": html if html is not None else escape_text(norm),
    }


def make_chapter(chapter_n, title, paragraphs, href=None):
    """Build one schema-conformant chapter dict.

    href KEY must always exist (epub emits it); synthetic adapters use '#c{n}'."""
    return {
        "chapter_id": "c%d" % chapter_n,
        "title": title or ("c%d" % chapter_n),
        "href": href if href is not None else ("#c%d" % chapter_n),
        "paragraphs": paragraphs,
    }


def build_content(title, chapters):
    """Assemble the final content dict + compute source_hash. title non-empty."""
    return {
        "source_hash": source_hash(chapters),
        "title": title if (title and title.strip()) else "Untitled",
        "chapters": chapters,
    }


class IngestError(Exception):
    """Raised by adapters to fail loud (non-zero exit + reason, NO content.json)."""


HEADING_TAGS = {"h1", "h2", "h3", "h4", "h5", "h6"}


def require_nonempty(content, what="document"):
    """Fail-loud guard (handoff §4.3 "never a silent NEAR-empty book"): require ≥1
    chapter AND ≥1 paragraph whose `tag` is a real BODY block (NOT a heading).

    Headings are stored as paragraphs, so a heading-only document (e.g. a `# Title`
    -only .md) WOULD pass a naive `any(paragraphs)` check while carrying no actual
    content — that is the near-empty book we must refuse."""
    chapters = content.get("chapters", [])
    if not chapters or not any(ch.get("paragraphs") for ch in chapters):
        raise IngestError(
            "%s produced no readable text (no chapters/paragraphs) — refusing to "
            "write an empty book" % what)
    has_body = any(
        p.get("tag") not in HEADING_TAGS
        for ch in chapters
        for p in ch.get("paragraphs", [])
    )
    if not has_body:
        raise IngestError(
            "%s produced only headings (no body text) — refusing to write a "
            "near-empty book" % what)
    return content


def write_content(content, out):
    """Write content.json with the EXACT epub-ingest convention.

    json.dumps(ensure_ascii=False, indent=2, sort_keys=False) + trailing newline;
    stderr one-line summary. out='-' => stdout. Single shared writer so every
    adapter emits byte-identical formatting."""
    text = json.dumps(content, ensure_ascii=False, indent=2, sort_keys=False)
    if out == "-":
        sys.stdout.write(text + "\n")
    else:
        Path(out).write_text(text + "\n", encoding="utf-8")
        sys.stderr.write(
            "wrote %s: %d chapters, source_hash=%s\n"
            % (out, len(content.get("chapters", [])), content.get("source_hash", "")[:12]))


def slugify(title):
    s = re.sub(r"[^\w\s-]", "", (title or "").lower(), flags=re.UNICODE)
    s = re.sub(r"[\s_-]+", "-", s).strip("-")
    return s or "untitled"
