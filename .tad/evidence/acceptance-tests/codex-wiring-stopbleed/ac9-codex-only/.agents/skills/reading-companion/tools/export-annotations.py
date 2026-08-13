#!/usr/bin/env python3
"""export-annotations.py — reading-state.json -> highlights-in-context Markdown.

Research lesson (DESIGN-FINDINGS §2): "Highlights shown as an isolated list LOSE
their context — a major UX failure." So each highlight is exported WITH its
surrounding paragraph context as a blockquote (`> `), never as a bare list item.

Optionally takes content.json (-c) to pull the full paragraph text for context;
if omitted, falls back to the annotation's prefix+exact+suffix as context.

STDLIB ONLY.
"""
import argparse
import json
import sys
from pathlib import Path


def load(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def build_pid_index(content):
    idx = {}
    for ch in content.get("chapters", []):
        for p in ch.get("paragraphs", []):
            idx[p["pid"]] = {"text": p["text"], "chapter": ch.get("title", ch["chapter_id"])}
    return idx


def context_for(ann, pid_idx):
    anchor = ann.get("anchor", {})
    pid = (anchor.get("refinedBy") or {}).get("pid", "")
    if pid in pid_idx:
        return pid_idx[pid]["text"], pid_idx[pid]["chapter"]
    # fallback: reconstruct from prefix/exact/suffix
    ctx = (anchor.get("prefix", "") + anchor.get("exact", "") + anchor.get("suffix", "")).strip()
    return ctx, ann.get("chapter_id", "")


def quote_block(text):
    """Render text as a Markdown blockquote (each line prefixed with '> ')."""
    text = " ".join(text.split())
    return "> " + text


def build_md(state, content=None):
    pid_idx = build_pid_index(content) if content else {}
    anns = state.get("annotations", [])
    lines = ["# Highlights & Notes", ""]
    if not anns:
        lines.append("_No annotations yet._")
        lines.append("")
        return "\n".join(lines)

    # group by chapter for readable structure
    by_chapter = {}
    order = []
    for ann in anns:
        ctx_text, chapter = context_for(ann, pid_idx)
        if chapter not in by_chapter:
            by_chapter[chapter] = []
            order.append(chapter)
        by_chapter[chapter].append((ann, ctx_text))

    for chapter in order:
        lines.append("## %s" % (chapter or "Untitled"))
        lines.append("")
        for ann, ctx_text in by_chapter[chapter]:
            exact = ann.get("anchor", {}).get("exact", "").strip()
            stale = ann.get("stale")
            head = "**“%s”**" % exact
            if stale:
                head += "  _(⚠ source changed — location may be approximate)_"
            lines.append("- %s" % head)
            note = ann.get("note", "").strip()
            if note:
                lines.append("  - note: %s" % note)
            # The context paragraph as a blockquote — NEVER an isolated list item.
            lines.append("")
            lines.append("  " + quote_block(ctx_text))
            lines.append("")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description="reading-state.json -> highlights-in-context.md")
    ap.add_argument("state", help="path to reading-state.json")
    ap.add_argument("-o", "--output", required=True, help="output markdown path")
    ap.add_argument("-c", "--content", help="optional content.json for full paragraph context")
    args = ap.parse_args(argv)

    state = load(args.state)
    content = load(args.content) if args.content else None
    md = build_md(state, content)
    if args.output == "-":
        sys.stdout.write(md)
    else:
        Path(args.output).write_text(md, encoding="utf-8")
        sys.stderr.write("wrote %s\n" % args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
