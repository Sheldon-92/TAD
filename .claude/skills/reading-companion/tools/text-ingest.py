#!/usr/bin/env python3
"""text-ingest.py — TXT + Markdown -> content.json (Python STDLIB ONLY).

- Markdown: `#`/`##`/`###` headings start chapters and emit tag h1/h2/h3; body
  paragraphs split on blank lines. List items (`- `/`* `/`1. `) -> tag=li.
- Plain TXT: split on blank lines into paragraphs; the whole file is one chapter
  titled by the filename stem.

Deterministic pure function of input bytes (shared hash/write helper). Fails loud
(non-zero exit + reason, NO content.json) on empty/whitespace-only input.
"""
import argparse
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import _rc_common as rc  # noqa: E402

HEADING_RE = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
LIST_RE = re.compile(r"^\s*(?:[-*+]\s+|\d+[.)]\s+)(.*\S)\s*$")
HR_RE = re.compile(r"^\s*([-*_])(?:\s*\1){2,}\s*$")   # markdown thematic break


def _filename_title(path):
    stem = Path(path).stem
    return stem.replace("_", " ").replace("-", " ").strip() or "Untitled"


def _looks_markdown(path, raw):
    if path.lower().endswith((".md", ".markdown")):
        return True
    # heuristic: any ATX heading line
    return any(HEADING_RE.match(ln) for ln in raw.splitlines())


def _blocks_to_paragraphs(blocks, chap_n):
    """blocks: list of (tag, text). -> schema paragraphs with stable pids."""
    paras = []
    for i, (tag, text) in enumerate(blocks, start=1):
        paras.append(rc.make_paragraph(chap_n, i, tag, text))
    return paras


def ingest_markdown(raw, title_fallback):
    """Split Markdown into chapters at top-level-ish headings; emit tag per block."""
    lines = raw.splitlines()
    # chapters: list of {title, blocks:[(tag,text)]}
    chapters = []
    cur = {"title": None, "blocks": []}
    para_buf = []

    def flush_para():
        if para_buf:
            text = " ".join(para_buf).strip()
            if text:
                cur["blocks"].append(("p", text))
            para_buf.clear()

    def start_chapter(title):
        nonlocal cur
        flush_para()
        # only start a new chapter if the current one has content or a title
        if cur["blocks"] or cur["title"] is not None:
            chapters.append(cur)
        cur = {"title": title, "blocks": []}

    in_code = False
    for ln in lines:
        if ln.strip().startswith("```"):
            flush_para()
            in_code = not in_code
            continue
        if in_code:
            # treat code lines as preformatted body, one block each (kept simple)
            if ln.strip():
                cur["blocks"].append(("pre", ln))
            continue
        m = HEADING_RE.match(ln)
        if m:
            level = len(m.group(1))
            htext = m.group(2).strip()
            tag = "h%d" % min(level, 3)
            # h1/h2 start a new chapter; h3+ are in-chapter headings
            if level <= 2:
                start_chapter(htext)
                cur["blocks"].append((tag, htext))
            else:
                flush_para()
                cur["blocks"].append((tag, htext))
            continue
        if HR_RE.match(ln):
            flush_para()
            continue
        lm = LIST_RE.match(ln)
        if lm:
            flush_para()
            cur["blocks"].append(("li", lm.group(1).strip()))
            continue
        if ln.strip() == "":
            flush_para()
            continue
        para_buf.append(ln.strip())
    flush_para()
    if cur["blocks"] or cur["title"] is not None:
        chapters.append(cur)

    # Build schema chapters (drop empty ones).
    out_chapters = []
    n = 0
    for ch in chapters:
        if not ch["blocks"]:
            continue
        n += 1
        title = ch["title"] or title_fallback
        paras = _blocks_to_paragraphs(ch["blocks"], n)
        out_chapters.append(rc.make_chapter(n, title, paras))
    title = out_chapters[0]["title"] if out_chapters else title_fallback
    # The document title: first h1 if present, else filename fallback.
    doc_title = title_fallback
    for ch in out_chapters:
        for p in ch["paragraphs"]:
            if p["tag"] == "h1":
                doc_title = p["text"]
                break
        if doc_title != title_fallback:
            break
    return rc.build_content(doc_title, out_chapters)


def ingest_plain(raw, title_fallback):
    """Plain TXT -> single chapter, paragraphs split on blank lines."""
    # split on one-or-more blank lines
    chunks = re.split(r"\n[ \t]*\n", raw)
    blocks = []
    for chunk in chunks:
        text = " ".join(line.strip() for line in chunk.splitlines() if line.strip())
        text = text.strip()
        if text:
            blocks.append(("p", text))
    if not blocks:
        return rc.build_content(title_fallback, [])
    paras = _blocks_to_paragraphs(blocks, 1)
    chapter = rc.make_chapter(1, title_fallback, paras)
    return rc.build_content(title_fallback, [chapter])


def ingest(path):
    raw = Path(path).read_text(encoding="utf-8", errors="replace")
    title_fallback = _filename_title(path)
    if _looks_markdown(path, raw):
        content = ingest_markdown(raw, title_fallback)
    else:
        content = ingest_plain(raw, title_fallback)
    return rc.require_nonempty(content, what="text/markdown file '%s'" % os.path.basename(path))


def main(argv=None):
    ap = argparse.ArgumentParser(description="TXT/Markdown -> content.json (stdlib only)")
    ap.add_argument("path", help="path to .txt or .md file")
    ap.add_argument("-o", "--output", required=True, help="output content.json path ('-' for stdout)")
    args = ap.parse_args(argv)
    try:
        content = ingest(args.path)
    except rc.IngestError as e:
        sys.stderr.write("BLOCKED: %s\n" % e)
        return 1
    rc.write_content(content, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
