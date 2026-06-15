#!/usr/bin/env python3
"""pdf-ingest.py — PDF -> content.json via the system `pdftotext` (poppler).

No Python PDF dependency: we shell out to `pdftotext -layout <pdf> -` with
subprocess.run([...], shell=False) (filename is user-controlled — NEVER a shell
string). Page breaks (\\f from pdftotext) drive the chapter/paragraph ladder.

Chapterization ladder (handoff FR3):
  1. Split the extracted text on form-feed (\\f) into PAGE units.
  2. Within a page, split on blank lines into paragraphs.
  3. Best-effort promote ALL-CAPS / short standalone lines to tag=h2 (LOSSY —
     noted; heuristic only). A promoted heading also names its chapter.
  4. ALWAYS emit ≥1 chapter.

Fail loud (honest_partial):
  - `pdftotext` not on PATH        -> BLOCKED, non-zero, `brew install poppler` hint, NO file.
  - image-only / no text layer
    (< MIN_TEXT_CHARS non-ws chars) -> BLOCKED, "no text layer / OCR unsupported", NO file.

Deterministic: same PDF bytes -> same pdftotext output -> identical content.json
(shared hash/write helper).
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import _rc_common as rc  # noqa: E402

MIN_TEXT_CHARS = 24          # below this many non-whitespace chars => image-only
PDFTOTEXT_TIMEOUT = 60


def _find_pdftotext(explicit_bin=None):
    if explicit_bin:
        return explicit_bin if (os.path.isfile(explicit_bin) or shutil.which(explicit_bin)) else None
    return shutil.which("pdftotext")


def _run_pdftotext(pdf_path, binpath):
    """Run `pdftotext -layout <pdf> -` (shell=False). Returns stdout text."""
    try:
        proc = subprocess.run(
            [binpath, "-layout", pdf_path, "-"],
            shell=False,                       # filename is user-controlled — no shell
            capture_output=True,
            timeout=PDFTOTEXT_TIMEOUT,
        )
    except (OSError, subprocess.TimeoutExpired) as e:
        raise rc.IngestError("pdftotext failed to run: %s" % e)
    if proc.returncode != 0:
        err = (proc.stderr or b"").decode("utf-8", "replace").strip()
        raise rc.IngestError("pdftotext exited %d: %s" % (proc.returncode, err[:200]))
    return proc.stdout.decode("utf-8", "replace")


_CAPS_RE = re.compile(r"^[^a-z]*[A-Z][^a-z]*$")  # has caps, no lowercase letters


def _is_heading_line(line):
    """Heuristic (LOSSY): a short standalone line that is ALL-CAPS / titley."""
    s = line.strip()
    if not s or len(s) > 64:
        return False
    letters = [c for c in s if c.isalpha()]
    if not letters:
        return False
    # all-caps and reasonably short -> promote
    if _CAPS_RE.match(s) and len(letters) >= 2:
        return True
    return False


def _page_to_blocks(page_text):
    """One page -> list of (tag, text). Blank-line paragraph split + heading promote."""
    blocks = []
    for chunk in re.split(r"\n[ \t]*\n", page_text):
        lines = [ln for ln in chunk.splitlines() if ln.strip()]
        if not lines:
            continue
        # A standalone heading line (single line in its chunk) may be promoted.
        if len(lines) == 1 and _is_heading_line(lines[0]):
            blocks.append(("h2", lines[0].strip()))
            continue
        # otherwise join into a paragraph; but split out a leading heading line
        if _is_heading_line(lines[0]):
            blocks.append(("h2", lines[0].strip()))
            rest = lines[1:]
        else:
            rest = lines
        if rest:
            text = " ".join(ln.strip() for ln in rest)
            if text.strip():
                blocks.append(("p", text))
    return blocks


def ingest(pdf_path, pdftotext_bin=None):
    binpath = _find_pdftotext(pdftotext_bin)
    if not binpath:
        raise rc.IngestError(
            "pdftotext not found on PATH — install poppler: `brew install poppler` "
            "(macOS) or `apt-get install poppler-utils` (Linux). v1 has no Python "
            "PDF fallback.")
    raw = _run_pdftotext(pdf_path, binpath)

    # image-only / no-text-layer guard (count non-whitespace chars)
    nonws = re.sub(r"\s", "", raw)
    if len(nonws) < MIN_TEXT_CHARS:
        raise rc.IngestError(
            "extracted %d non-whitespace chars (< %d) — this PDF has no usable text "
            "layer (likely scanned/image-only). v1 does not do OCR."
            % (len(nonws), MIN_TEXT_CHARS))

    title = os.path.splitext(os.path.basename(pdf_path))[0].replace("_", " ").strip() or "Untitled"

    # \f page-split ladder -> chapters (a promoted heading renames its chapter).
    pages = raw.split("\f")
    chapters = []
    chap_n = 0
    cur_blocks = []
    cur_title = title

    def commit():
        nonlocal chap_n, cur_blocks, cur_title
        if not cur_blocks:
            return
        chap_n += 1
        paras = [rc.make_paragraph(chap_n, i, tag, text)
                 for i, (tag, text) in enumerate(cur_blocks, start=1)]
        chapters.append(rc.make_chapter(chap_n, cur_title, paras))
        cur_blocks = []

    for page in pages:
        blocks = _page_to_blocks(page)
        if not blocks:
            continue
        # each page is a chapter boundary; title from a leading promoted heading
        commit()
        cur_title = blocks[0][1] if blocks and blocks[0][0] == "h2" else ("Page %d" % (chap_n + 1))
        cur_blocks = blocks
    commit()

    content = rc.build_content(title, chapters)
    return rc.require_nonempty(content, what="PDF '%s'" % os.path.basename(pdf_path))


def main(argv=None):
    ap = argparse.ArgumentParser(description="PDF -> content.json via system pdftotext")
    ap.add_argument("pdf", help="path to .pdf file")
    ap.add_argument("-o", "--output", required=True, help="output content.json ('-' for stdout)")
    ap.add_argument("--pdftotext-bin", default=None,
                    help="override pdftotext binary path (testing the no-pdftotext path)")
    args = ap.parse_args(argv)
    try:
        content = ingest(args.pdf, pdftotext_bin=args.pdftotext_bin)
    except rc.IngestError as e:
        sys.stderr.write("BLOCKED: %s\n" % e)
        return 1
    rc.write_content(content, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
