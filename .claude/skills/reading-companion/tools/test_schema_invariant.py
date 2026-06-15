#!/usr/bin/env python3
"""test_schema_invariant.py — guard the core content.json invariant against drift.

epub-ingest.py predates Phase 4 and still hand-rolls _norm_ws / _escape_text /
source_hash (byte-equal to _rc_common TODAY). Rather than refactor the proven
EPUB parser (risk: the SKIP_TAGS asymmetry — _rc_common adds nav/footer/aside/
header for url-ingest, which EPUB must NOT start dropping), this regression test
FAILS LOUD if any of those primitives ever drift apart, and asserts every
adapter's output is schema-shape-identical to epub's (P1#3).

Run: python3 tools/test_schema_invariant.py   (exit 0 = invariant holds)
STDLIB ONLY.
"""
import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.realpath(__file__))
FIX = os.path.join(os.path.dirname(HERE), "fixtures")
PASS, FAIL = [], []


def _load(modname, filename):
    spec = importlib.util.spec_from_file_location(modname, os.path.join(HERE, filename))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def check(name, cond, detail=""):
    (PASS if cond else FAIL).append(name)
    print("  %s %s%s" % ("PASS" if cond else "FAIL", name, (" — " + detail) if detail else ""))


def main():
    rc = _load("_rc_common", "_rc_common.py")
    epub = _load("rc_epub", "epub-ingest.py")

    # 1) normalize primitive byte-identical across a spread of inputs.
    samples = [
        "  hello   world \n\n  x ", "tabs\tand\nnewlines\r\n  ", "",
        "  ", "CJK 中文  全角　空格", "trailing   ", "a b",
        "multi   space\tmix\n\nline", "  leading and trailing  \t",
    ]
    norm_ok = all(epub._norm_ws(s) == rc.normalize_ws(s) for s in samples)
    check("epub._norm_ws == rc.normalize_ws (9 samples)", norm_ok)

    # 2) escape primitive identical (epub._escape_text vs rc.escape_text).
    esc_samples = ["<a> & </a>", "plain", "x < y && z > w", "&amp;<script>"]
    esc_ok = all(epub._escape_text(s) == rc.escape_text(s) for s in esc_samples)
    check("epub._escape_text == rc.escape_text (4 samples)", esc_ok)

    # 3) source_hash identical: build epub content, recompute hash via rc, compare.
    fixture = os.path.join(FIX, "sample.epub")
    content = epub.ingest(fixture)
    epub_hash = content["source_hash"]
    rc_hash = rc.source_hash(content["chapters"])
    check("epub source_hash == rc.source_hash(chapters)", epub_hash == rc_hash,
          "epub=%s rc=%s" % (epub_hash[:12], rc_hash[:12]))

    # 4) schema SHAPE of every adapter == epub (the AC1 invariant, automated).
    def shape(d):
        out = set()

        def walk(node, path):
            if isinstance(node, dict):
                for k, v in node.items():
                    walk(v, path + "." + k if path else k)
            elif isinstance(node, list):
                for v in node:
                    walk(v, path + ".N")
            else:
                out.add(path)
        walk(d, "")
        # fold numeric list indices already collapsed to .N; return sorted keyset
        return tuple(sorted(out))

    epub_shape = shape(content)

    text = _load("rc_text", "text-ingest.py")
    url = _load("rc_url", "url-ingest.py")
    pdf = _load("rc_pdf", "pdf-ingest.py")

    adapters = []
    adapters.append(("text-md", text.ingest(os.path.join(FIX, "sample.md"))))
    adapters.append(("text-txt", text.ingest(os.path.join(FIX, "sample.txt"))))
    raw = open(os.path.join(FIX, "sample.html"), encoding="utf-8").read()
    adapters.append(("url", url.ingest("http://x/a", _html=raw)))
    import shutil
    if shutil.which("pdftotext"):
        adapters.append(("pdf", pdf.ingest(os.path.join(FIX, "sample.pdf"))))
    else:
        print("  (pdf adapter skipped — pdftotext absent)")

    for name, c in adapters:
        check("schema shape %s == epub" % name, shape(c) == epub_shape,
              "diff=%s" % (set(shape(c)) ^ set(epub_shape)))

    print("\n==== TALLY: PASS=%d FAIL=%d ====" % (len(PASS), len(FAIL)))
    if FAIL:
        print("FAILURES:", FAIL)
    return 1 if FAIL else 0


if __name__ == "__main__":
    raise SystemExit(main())
