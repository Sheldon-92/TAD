#!/usr/bin/env python3
"""render.py — content.json + reading-state.json -> self-contained index.html.

Implements the §4.4 re-attach algorithm SERVER-SIDE (so it is deterministic and
verifiable without a browser):

  For each annotation:
    1. source_hash gate: if reading-state.source_hash != content.source_hash ->
       mark stale:true, still best-effort attach, NEVER silently re-anchor.
    2. scope quote-match to the refinedBy.pid paragraph ONLY (never doc-wide indexOf).
    3. within that paragraph, if `exact` occurs more than once, use prefix/suffix to
       pick the unique occurrence.
    4. fallback: if still ambiguous/not found -> mark stale:true, keep annotation
       data (no loss); the highlight is not painted but the record survives.

The chosen occurrence is baked into the paragraph as a <mark class="hl"> span with
data-annot / data-pid so AC5 can assert the enclosing pid == refinedBy.pid.

`--save <annot.json>` merges a browser-exported annotations file into
reading-state.json (de-dup by id) BEFORE rendering — the Phase-2 persistence path.

STDLIB ONLY.
"""
import argparse
import html as htmlmod
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TEMPLATE = HERE.parent / "templates" / "reader.html"


# ----------------------------------------------------------------------------
# §4.4 Re-attach core
# ----------------------------------------------------------------------------
def find_occurrence(para_text, exact, prefix, suffix):
    """Return the char offset of the disambiguated occurrence, or -1.

    Scoped to a SINGLE paragraph's text. If `exact` occurs once, return it.
    If multiple, use prefix/suffix to select the unique match. If still
    ambiguous or absent, return -1 (caller marks stale).
    """
    if not exact:
        return -1
    # All occurrences of exact within the paragraph.
    starts = []
    i = para_text.find(exact)
    while i != -1:
        starts.append(i)
        i = para_text.find(exact, i + 1)
    if not starts:
        return -1
    if len(starts) == 1:
        return starts[0]
    # Multiple -> disambiguate with prefix/suffix.
    candidates = []
    for s in starts:
        ok = True
        if prefix:
            pre = para_text[max(0, s - len(prefix)):s]
            if not pre.endswith(prefix):
                ok = False
        if ok and suffix:
            end = s + len(exact)
            suf = para_text[end:end + len(suffix)]
            if not suf.startswith(suffix):
                ok = False
        if ok:
            candidates.append(s)
    if len(candidates) == 1:
        return candidates[0]
    # Ambiguous even with context (or none matched) -> caller marks stale.
    return -1


def reattach(content, state):
    """Annotate `state['annotations']` in place with resolved offsets + stale flags.

    Returns a dict: pid -> list of resolved annotations to paint, in order.
    Each resolved entry: {ann, start, end}.
    """
    src_hash = content.get("source_hash", "")
    st_hash = state.get("source_hash", "")
    # source_hash gate (step 1).
    source_changed = bool(st_hash) and st_hash != src_hash

    # Build pid -> paragraph text map (scope for step 2).
    pid_text = {}
    for ch in content.get("chapters", []):
        for p in ch.get("paragraphs", []):
            pid_text[p["pid"]] = p["text"]

    painted = {}
    for ann in state.get("annotations", []):
        anchor = ann.get("anchor", {})
        refined = anchor.get("refinedBy", {}) or {}
        pid = refined.get("pid")
        exact = anchor.get("exact", "")
        prefix = anchor.get("prefix", "")
        suffix = anchor.get("suffix", "")

        # Default: clear any prior stale flag; we recompute every render.
        ann["stale"] = False

        # Gate-4 guard: an empty/whitespace-only exact can never be a real
        # highlight -> mark stale, never bake an empty <mark>. Keep data (no loss).
        if not exact or not exact.strip():
            ann["stale"] = True
            continue

        if source_changed:
            # step 1: source changed -> best effort but flag stale, never silent.
            ann["stale"] = True

        para = pid_text.get(pid)
        if para is None:
            # paragraph gone entirely -> stale, keep data (no loss).
            ann["stale"] = True
            continue

        # step 2+3: scoped quote-match within the paragraph, prefix/suffix tiebreak.
        off = find_occurrence(para, exact, prefix, suffix)
        if off < 0 or off + len(exact) <= off:
            # step 4 fallback: cannot uniquely locate (or zero-length) -> stale,
            # keep data. A zero-length resolve must never paint an empty mark.
            ann["stale"] = True
            continue

        # Resolved. (If source_changed it stays stale=True per step 1, but we
        # still record the painted position as a best-effort visual.)
        painted.setdefault(pid, []).append(
            {"ann": ann, "start": off, "end": off + len(exact)}
        )

    # Sort each paragraph's paints by start offset (paint left-to-right).
    for pid in painted:
        painted[pid].sort(key=lambda d: d["start"])
    return painted


# ----------------------------------------------------------------------------
# HTML rendering
# ----------------------------------------------------------------------------
def paint_paragraph(text, paints):
    """Return HTML for a paragraph's text with <mark> spans for `paints`.

    Handles overlapping/adjacent paints by painting non-overlapping segments in
    order; if two paints overlap, the later one is skipped (kept stale by caller
    is not needed here — overlap is rare and we prioritize the first).
    """
    if not paints:
        return htmlmod.escape(text)
    out = []
    cursor = 0
    for p in paints:
        s, e = p["start"], p["end"]
        if s < cursor:
            continue  # overlap with a previous paint; skip painting this one
        if e <= s or not text[s:e].strip():
            continue  # Gate-4: never emit an empty/whitespace-only <mark>
        out.append(htmlmod.escape(text[cursor:s]))
        ann = p["ann"]
        cls = "hl stale" if ann.get("stale") else "hl"
        note = htmlmod.escape(ann.get("note", ""), quote=True)
        out.append(
            '<mark class="%s" data-annot="%s" data-pid="%s" data-note="%s">%s</mark>'
            % (
                cls,
                htmlmod.escape(ann.get("id", ""), quote=True),
                htmlmod.escape(ann["anchor"]["refinedBy"]["pid"], quote=True),
                note,
                htmlmod.escape(text[s:e]),
            )
        )
        cursor = e
    out.append(htmlmod.escape(text[cursor:]))
    return "".join(out)


def render_content_html(content, painted):
    parts = []
    for ch in content.get("chapters", []):
        parts.append('<section class="chapter" id="%s">' % htmlmod.escape(ch["chapter_id"]))
        for p in ch.get("paragraphs", []):
            tag = p.get("tag", "p")
            if tag not in ("p", "h1", "h2", "h3", "h4", "h5", "h6",
                           "li", "blockquote", "pre", "dd", "dt"):
                tag = "p"
            pid = p["pid"]
            inner = paint_paragraph(p["text"], painted.get(pid, []))
            data_text = htmlmod.escape(p["text"], quote=True)
            parts.append(
                '<%s data-pid="%s" data-text="%s">%s</%s>'
                % (tag, htmlmod.escape(pid, quote=True), data_text, inner, tag)
            )
        parts.append("</section>")
    return "\n".join(parts)


def render_toc_html(content):
    parts = []
    for ch in content.get("chapters", []):
        parts.append(
            '<a href="#%s">%s</a>'
            % (htmlmod.escape(ch["chapter_id"], quote=True), htmlmod.escape(ch.get("title", ch["chapter_id"])))
        )
    return "\n".join(parts)


def build_html(content, state, lang="en", bridge=False):
    painted = reattach(content, state)
    tmpl = TEMPLATE.read_text(encoding="utf-8")
    title = content.get("title", "Untitled")
    state_json = json.dumps(
        {"source_hash": content.get("source_hash", ""),
         "annotations": state.get("annotations", [])},
        ensure_ascii=False,
    )
    # Embed source_hash as an attribute on the state script for the client.
    state_tag_attr = 'data-source-hash="%s"' % htmlmod.escape(content.get("source_hash", ""), quote=True)
    out = tmpl
    out = out.replace("{{LANG}}", htmlmod.escape(lang, quote=True))
    out = out.replace("{{TITLE}}", htmlmod.escape(title))
    out = out.replace("{{TOC}}", render_toc_html(content))
    out = out.replace("{{CONTENT}}", render_content_html(content, painted))
    # Inject the data-source-hash attribute onto the state script element.
    out = out.replace(
        '<script id="reading-state" type="application/json">',
        '<script id="reading-state" type="application/json" %s>' % state_tag_attr,
    )
    out = out.replace("{{STATE_JSON}}", state_json.replace("</", "<\\/"))
    # Bridge-MODE markup ONLY (FR10 / P1-6): mark the file as bridge-capable so the
    # reader's runtime knows it may be served by the bridge. The TOKEN is NEVER
    # baked in here — the server injects it at request time (the URL carries ?t=),
    # and the reader reads it from window.location. This only flips a data flag;
    # the actual panel still only activates when an http origin + ?t= are present.
    if bridge:
        out = out.replace("<body data-mode=\"scroll\">",
                          "<body data-mode=\"scroll\" data-bridge-capable=\"1\">", 1)
    return out


# ----------------------------------------------------------------------------
# Persistence: --save merge
# ----------------------------------------------------------------------------
def _content_key(a):
    """Stable de-dup key for an annotation that has no id.

    Derived from anchor fields so two genuinely-distinct id-less highlights get
    distinct keys (P1#3: zero-loss — never collapse them under a single None).
    """
    anchor = a.get("anchor", {}) or {}
    refined = anchor.get("refinedBy", {}) or {}
    return (
        "ck:",
        refined.get("pid", ""),
        anchor.get("exact", ""),
        anchor.get("prefix", ""),
        anchor.get("suffix", ""),
    )


def merge_annotations(state, save_path):
    """Merge a browser-exported annotations JSON into state, zero-loss.

    De-dup by id when present; for id-less annotations use a content-derived key
    so distinct highlights are never collapsed (FR4 zero-loss). Accepts either a
    {"annotations": [...]} object OR a bare top-level JSON list (P2#10).
    """
    data = json.loads(Path(save_path).read_text(encoding="utf-8"))
    # P2#10: handle bare-list form BEFORE calling .get (list has no .get).
    if isinstance(data, list):
        incoming = data
    elif isinstance(data, dict):
        incoming = data.get("annotations", [])
    else:
        incoming = []

    def keyof(a):
        aid = a.get("id")
        return aid if aid else _content_key(a)

    existing = {}
    for a in state.get("annotations", []):
        existing[keyof(a)] = a
    for a in incoming:
        existing[keyof(a)] = a  # incoming wins on key collision
    state["annotations"] = list(existing.values())
    return state


def load_json(path, default):
    p = Path(path)
    if not p.exists():
        return default
    return json.loads(p.read_text(encoding="utf-8"))


def main(argv=None):
    ap = argparse.ArgumentParser(description="content.json + state -> index.html")
    ap.add_argument("content", help="path to content.json")
    ap.add_argument("-o", "--output", required=True, help="output index.html path")
    ap.add_argument("-s", "--state", help="path to reading-state.json (read/written)")
    ap.add_argument("--save", help="browser-exported annotations JSON to merge into state")
    ap.add_argument("--lang", default="en", help="html lang attribute (default: en)")
    ap.add_argument("--bridge", action="store_true",
                    help="mark the rendered HTML bridge-capable (markup only; the bridge "
                         "server injects the token at request time — never baked to disk)")
    args = ap.parse_args(argv)

    content = json.loads(Path(args.content).read_text(encoding="utf-8"))

    # Default state path: alongside content.json.
    state_path = args.state or str(Path(args.content).with_name("reading-state.json"))
    # P1#2: a NEW/empty state must start with source_hash="" so the §4.4 gate can
    # adopt the source_hash an annotation was actually made against (from --save)
    # rather than silently inheriting the current content's hash (which would
    # always look "unchanged" and defeat the stale gate).
    state = load_json(state_path, {"source_hash": "",
                                   "current": {}, "annotations": [], "thread": []})
    if "annotations" not in state:
        state["annotations"] = []

    # --save merge (Phase-2 persistence path).
    if args.save:
        merge_annotations(state, args.save)
        # The export records the source_hash the annotations were made against.
        # ALWAYS prefer the export's hash so the gate at render time compares
        # "source the annotations came from" vs "current content" (§4.4 step 1).
        # An export carrying an OLD hash against changed content => stale, never
        # silently adopted. We only fall back to the existing state hash when the
        # export omits one.
        try:
            exp = json.loads(Path(args.save).read_text(encoding="utf-8"))
            if isinstance(exp, dict) and exp.get("source_hash"):
                state["source_hash"] = exp["source_hash"]
        except Exception:
            pass

    html_out = build_html(content, state, lang=args.lang, bridge=args.bridge)
    Path(args.output).write_text(html_out, encoding="utf-8")

    # Persist state (with recomputed stale flags) back to the sidecar.
    Path(state_path).write_text(
        json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    sys.stderr.write(
        "wrote %s (%d annotations, %d stale)\n"
        % (
            args.output,
            len(state.get("annotations", [])),
            sum(1 for a in state.get("annotations", []) if a.get("stale")),
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
