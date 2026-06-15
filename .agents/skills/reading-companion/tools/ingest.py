#!/usr/bin/env python3
"""ingest.py — unified ingest dispatcher (handoff FR5). STDLIB ONLY.

Routes a file path or URL to the right adapter by extension / scheme:
  .epub                 -> epub-ingest.py
  .pdf                  -> pdf-ingest.py
  .txt / .md/.markdown  -> text-ingest.py
  http:// / https://    -> url-ingest.py
  anything else         -> clear non-zero error (no content.json)

Each adapter is imported as a module (hyphenated filenames loaded via importlib)
and shares the _rc_common schema/determinism/write helpers, so routing changes
nothing about the output. Passes -o through; surfaces the adapter's exit code.
"""
import argparse
import importlib.util
import os
import sys
from urllib.parse import urlparse

HERE = os.path.dirname(os.path.realpath(__file__))


def _load(modname, filename):
    spec = importlib.util.spec_from_file_location(modname, os.path.join(HERE, filename))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def route(target):
    """Return (module_filename, kind) for a target, or (None, reason)."""
    scheme = urlparse(target).scheme.lower()
    if scheme in ("http", "https"):
        return "url-ingest.py", "url"
    if scheme in ("file",):
        return None, "file:// not supported — pass a local path without the scheme"
    ext = os.path.splitext(target)[1].lower()
    if ext == ".epub":
        return "epub-ingest.py", "epub"
    if ext == ".pdf":
        return "pdf-ingest.py", "pdf"
    if ext in (".txt", ".md", ".markdown"):
        return "text-ingest.py", "text"
    return None, "unsupported input %r (ext=%r). Supported: .epub .pdf .txt .md or http(s) URL" % (target, ext)


def main(argv=None):
    ap = argparse.ArgumentParser(description="Unified ingest dispatcher (ext/scheme routing)")
    ap.add_argument("target", help="path to .epub/.pdf/.txt/.md OR an http(s) URL")
    ap.add_argument("-o", "--output", required=True, help="output content.json ('-' for stdout)")
    args, extra = ap.parse_known_args(argv)

    fname, kind = route(args.target)
    if fname is None:
        sys.stderr.write("ERROR: %s\n" % kind)
        return 2

    mod = _load("rc_adapter_" + kind, fname)
    # epub-ingest's main uses positional `epub`; others use positional `path/url/pdf`.
    # All accept `-o`. Delegate by calling the adapter's main with reconstructed argv.
    adapter_argv = [args.target, "-o", args.output] + extra
    sys.stderr.write("[ingest] routing %r -> %s (%s)\n" % (args.target, fname, kind))
    return mod.main(adapter_argv)


if __name__ == "__main__":
    raise SystemExit(main())
