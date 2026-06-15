#!/usr/bin/env python3
"""export-notes.py — content.json + reading-state.json (+ plan.md) -> session notes.

A durable, STRUCTURED-by-chapter Markdown sink (handoff FR4), distinct from
export-annotations.py's flat highlight list:

  ## {chapter title}
     - highlights in that chapter (each with its paragraph-context blockquote)
     - that chapter's open questions (if any)
  ## General / 未定位      (unanchored or cross-chapter items)
  ## Open Questions        (de-duped: plan.md `## Questions` + thread user `?` turns)
  ## 对话精华              (a digest of the co-read thread)

Question-extraction rules (explicit — no guessing, FR4):
  (a) plan.md questions = the list items UNDER the `## Questions` heading only
      (NOT a whole-file `?` grep).
  (b) thread questions  = thread turns where role=="user" AND text.rstrip() ends
      with "?" or "？" (excludes assistant rhetorical questions).
Grouping key for a highlight = the chapter that owns its anchor's refinedBy.pid;
unanchored / unknown-pid highlights go to the "General / 未定位" bucket.

STDLIB ONLY.
"""
import argparse
import json
import os
import re
import sys
from pathlib import Path


def load(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def build_pid_index(content):
    """pid -> {text, chapter_title, chapter_id}; and chapter_id -> title (ordered)."""
    pid_idx = {}
    chapters = []
    for ch in content.get("chapters", []):
        ctitle = ch.get("title", ch.get("chapter_id", ""))
        chapters.append((ch.get("chapter_id", ""), ctitle))
        for p in ch.get("paragraphs", []):
            pid_idx[p["pid"]] = {"text": p["text"], "chapter_title": ctitle,
                                 "chapter_id": ch.get("chapter_id", "")}
    return pid_idx, chapters


def quote_block(text):
    return "> " + " ".join((text or "").split())


GENERAL = "General / 未定位"


def chapter_for_annotation(ann, pid_idx):
    """Return (chapter_title, context_text). Unanchored/unknown pid -> GENERAL."""
    anchor = ann.get("anchor", {}) or {}
    pid = (anchor.get("refinedBy") or {}).get("pid", "")
    if pid in pid_idx:
        return pid_idx[pid]["chapter_title"], pid_idx[pid]["text"]
    # fallback context from prefix+exact+suffix; bucket = General
    ctx = (anchor.get("prefix", "") + anchor.get("exact", "") + anchor.get("suffix", "")).strip()
    return GENERAL, ctx


def parse_plan_questions(plan_path):
    """Extract list items strictly UNDER the `## Questions` heading (FR4a)."""
    if not plan_path or not os.path.isfile(plan_path):
        return []
    qs = []
    in_section = False
    for line in Path(plan_path).read_text(encoding="utf-8").splitlines():
        if re.match(r"^##\s+", line):
            in_section = bool(re.match(r"^##\s+Questions\b", line.strip()))
            continue
        if in_section:
            m = re.match(r"^\s*[-*+]\s+(.*\S)\s*$", line)
            if m:
                qs.append(m.group(1).strip())
    return qs


def thread_user_questions(state):
    """thread turns with role==user and text ending in ?/？ (FR4b)."""
    qs = []
    for turn in state.get("thread", []):
        if turn.get("role") != "user":
            continue
        text = (turn.get("text") or "").rstrip()
        if text.endswith("?") or text.endswith("？"):
            qs.append(text)
    return qs


def build_notes(content, state, plan_path=None):
    pid_idx, chapters = build_pid_index(content)
    title = content.get("title", "Untitled")
    anns = state.get("annotations", [])

    # group highlights by chapter title (preserve content chapter order; General last)
    by_chapter = {}
    for ann in anns:
        ctitle, ctx = chapter_for_annotation(ann, pid_idx)
        by_chapter.setdefault(ctitle, []).append((ann, ctx))

    plan_qs = parse_plan_questions(plan_path)
    thread_qs = thread_user_questions(state)

    lines = ["# Reading Notes — %s" % title, ""]

    # ordered chapter sections (content order), then General if present
    ordered_titles = [t for (_id, t) in chapters if t in by_chapter]
    for t in by_chapter:
        if t not in ordered_titles and t != GENERAL:
            ordered_titles.append(t)
    if GENERAL in by_chapter:
        ordered_titles.append(GENERAL)

    if not ordered_titles:
        lines.append("_No highlights yet._")
        lines.append("")
    for ctitle in ordered_titles:
        lines.append("## %s" % (ctitle or "Untitled"))
        lines.append("")
        for ann, ctx in by_chapter[ctitle]:
            exact = (ann.get("anchor", {}) or {}).get("exact", "").strip()
            stale = ann.get("stale")
            head = "**“%s”**" % exact if exact else "**(highlight)**"
            if stale:
                head += "  _(⚠ source changed — location may be approximate)_"
            lines.append("- %s" % head)
            note = (ann.get("note") or "").strip()
            if note:
                lines.append("  - note: %s" % note)
            lines.append("")
            lines.append("  " + quote_block(ctx))
            lines.append("")

    # ---- Open Questions (de-duped, both sources) ----
    lines.append("## Open Questions")
    lines.append("")
    seen = set()
    combined = []
    for q in plan_qs + thread_qs:
        key = q.strip()
        if key and key not in seen:
            seen.add(key)
            combined.append(q)
    if combined:
        for q in combined:
            lines.append("- %s" % q)
    else:
        lines.append("_No open questions captured._")
    lines.append("")

    # ---- 对话精华 (thread digest) ----
    lines.append("## 对话精华")
    lines.append("")
    thread = state.get("thread", [])
    if thread:
        for turn in thread:
            role = turn.get("role", "?")
            who = "**You**" if role == "user" else "**Claude**"
            text = " ".join((turn.get("text") or "").split())
            lines.append("- %s: %s" % (who, text))
    else:
        lines.append("_No co-read conversation yet._")
    lines.append("")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description="content.json + reading-state -> structured notes.md")
    ap.add_argument("state", help="path to reading-state.json")
    ap.add_argument("-c", "--content", required=True, help="content.json (for chapter grouping + context)")
    ap.add_argument("-p", "--plan", help="plan.md (for ## Questions extraction)")
    ap.add_argument("-o", "--output", required=True, help="output notes.md ('-' for stdout)")
    args = ap.parse_args(argv)

    state = load(args.state)
    content = load(args.content)
    md = build_notes(content, state, plan_path=args.plan)
    if args.output == "-":
        sys.stdout.write(md)
    else:
        Path(args.output).write_text(md, encoding="utf-8")
        sys.stderr.write("wrote %s\n" % args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
