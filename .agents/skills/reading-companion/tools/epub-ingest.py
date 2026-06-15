#!/usr/bin/env python3
"""epub-ingest.py — EPUB -> normalized content.json (Python STDLIB ONLY).

Pipeline:
  EPUB (zip) -> read OPF (container.xml -> rootfile) -> spine order ->
  per-XHTML extract paragraphs -> stable pid `c{spine_idx}-p{n}` ->
  source_hash (sha256 of normalized concatenated text).

stdlib-only constraints honored (§4.2 three traps):
  1. XML namespaces: OPF/XHTML elements come back as `{ns}tag`; we strip ns.
  2. spine -> manifest idref -> href; href is relative to the OPF dir, not zip root.
  3. malformed XHTML: xml.etree may raise ParseError -> fall back to html.parser.

pid stability contract: pids are stable only within the same source_hash.
"""
import argparse
import hashlib
import json
import re
import sys
import zipfile
from html.parser import HTMLParser
from pathlib import PurePosixPath

# xml.etree is stdlib, but on some Python builds its C accelerator (pyexpat) is
# broken/missing. We try it; if importing/using it fails we transparently fall
# back to a pure-Python html.parser-based scanner (also stdlib). Either way the
# tool stays STDLIB-ONLY (AC8) and portable.
try:
    from xml.etree import ElementTree as ET  # noqa: F401

    _et_ok = True
    try:
        ET.fromstring("<a/>")
    except Exception:
        _et_ok = False
except Exception:  # pragma: no cover
    ET = None
    _et_ok = False

CONTAINER_PATH = "META-INF/container.xml"

# Block-level tags whose text we lift into paragraphs.
BLOCK_TAGS = {"p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote", "pre", "dd", "dt"}
# Tags whose content we drop entirely.
SKIP_TAGS = {"script", "style", "head", "title"}
# Inline tags we keep (lightly) inside paragraph html.
INLINE_KEEP = {"em", "i", "strong", "b", "a", "code", "sup", "sub", "span", "br"}


def _localname(tag):
    """Strip an XML namespace: '{http://...}p' -> 'p'. Lowercased."""
    if tag is None:
        return ""
    if "}" in tag:
        tag = tag.split("}", 1)[1]
    return tag.lower()


def _norm_ws(text):
    """Collapse runs of whitespace to single spaces and strip."""
    return re.sub(r"\s+", " ", text or "").strip()


class _BlockExtractor(HTMLParser):
    """Walk XHTML, emit (heading_level_or_None, plain_text, minimal_html) per block.

    Used both as the primary lenient parser and as the malformed-XHTML fallback.
    """

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.blocks = []           # list of dicts: {tag, text, html}
        self._skip_depth = 0       # >0 while inside a SKIP_TAGS subtree
        self._block_tag = None     # current block tag name, or None
        self._text_parts = []      # plain text buffer for current block
        self._html_parts = []      # minimal html buffer for current block

    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag in SKIP_TAGS:
            self._skip_depth += 1
            return
        if self._skip_depth:
            return
        if tag in BLOCK_TAGS:
            # A block opens; if one was already open, flush it first.
            if self._block_tag is not None:
                self._flush_block()
            self._block_tag = tag
            self._text_parts = []
            self._html_parts = []
            return
        if self._block_tag is not None and tag in INLINE_KEEP:
            if tag == "br":
                self._text_parts.append(" ")
                self._html_parts.append("<br/>")
            else:
                self._html_parts.append("<%s>" % tag)

    def handle_startendtag(self, tag, attrs):
        tag = tag.lower()
        if self._skip_depth:
            return
        if self._block_tag is not None and tag == "br":
            self._text_parts.append(" ")
            self._html_parts.append("<br/>")

    def handle_endtag(self, tag):
        tag = tag.lower()
        if tag in SKIP_TAGS:
            if self._skip_depth:
                self._skip_depth -= 1
            return
        if self._skip_depth:
            return
        if tag in BLOCK_TAGS and self._block_tag == tag:
            self._flush_block()
            return
        if self._block_tag is not None and tag in INLINE_KEEP and tag != "br":
            self._html_parts.append("</%s>" % tag)

    def handle_data(self, data):
        if self._skip_depth or self._block_tag is None:
            return
        self._text_parts.append(data)
        # Escape for html storage.
        self._html_parts.append(
            data.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        )

    def _flush_block(self):
        text = _norm_ws("".join(self._text_parts))
        if text:
            self.blocks.append(
                {
                    "tag": self._block_tag,
                    "text": text,
                    "html": _norm_ws("".join(self._html_parts)),
                }
            )
        self._block_tag = None
        self._text_parts = []
        self._html_parts = []

    def close(self):
        # Flush a dangling open block (common in malformed XHTML).
        if self._block_tag is not None:
            self._flush_block()
        super().close()


class _TagScanner(HTMLParser):
    """Pure-Python (no expat) scanner: collects start tags + attrs + text runs.

    Used to parse container.xml / OPF without requiring xml.etree's C accelerator.
    Emits self.events: ('start', localname, attrs_dict) and ('text', localname, text)
    where localname is namespace-stripped lowercase (html.parser lowercases tags
    but keeps any 'ns:' prefix, which we strip here).
    """

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.events = []
        self._stack = []

    @staticmethod
    def _ln(tag):
        if ":" in tag:
            tag = tag.split(":", 1)[1]
        return tag.lower()

    def handle_starttag(self, tag, attrs):
        ln = self._ln(tag)
        self._stack.append(ln)
        self.events.append(("start", ln, dict(attrs)))

    def handle_startendtag(self, tag, attrs):
        ln = self._ln(tag)
        self.events.append(("start", ln, dict(attrs)))

    def handle_endtag(self, tag):
        ln = self._ln(tag)
        if self._stack and self._stack[-1] == ln:
            self._stack.pop()

    def handle_data(self, data):
        cur = self._stack[-1] if self._stack else None
        if data.strip():
            self.events.append(("text", cur, data))


def _scan_xml(data):
    """Parse XML-ish bytes with the pure-Python scanner. Returns list of events."""
    s = _TagScanner()
    s.feed(data.decode("utf-8", "replace") if isinstance(data, bytes) else data)
    s.close()
    return s.events


def _extract_blocks_via_etree(xhtml_bytes):
    """Try strict XML parse; return blocks or raise ParseError."""
    if not _et_ok:
        raise ET.ParseError("expat unavailable") if ET else RuntimeError("no ET")
    root = ET.fromstring(xhtml_bytes)
    blocks = []

    def walk(el, skip):
        tag = _localname(el.tag)
        if tag in SKIP_TAGS:
            return
        if tag in BLOCK_TAGS:
            text = _norm_ws("".join(el.itertext()))
            if text:
                blocks.append({"tag": tag, "text": text, "html": _escape_text(text)})
            # Block text already captured via itertext; don't recurse into nested
            # blocks for the html (text-level fidelity is sufficient for anchoring).
            return
        for child in el:
            walk(child, skip)

    walk(root, False)
    return blocks


def _escape_text(text):
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def extract_blocks(xhtml_bytes):
    """Extract block paragraphs from one XHTML file.

    Trap #3: strict xml.etree first; on ParseError fall back to html.parser.
    """
    try:
        blocks = _extract_blocks_via_etree(xhtml_bytes)
        if blocks:
            return blocks
        # Empty (e.g. namespace weirdness) -> fall through to lenient parser.
    except Exception:
        # ParseError, missing-expat RuntimeError, or anything else -> lenient path.
        pass
    parser = _BlockExtractor()
    try:
        parser.feed(xhtml_bytes.decode("utf-8", "replace"))
        parser.close()
    except Exception:
        pass
    return parser.blocks


def _find_opf_path(zf):
    """Read META-INF/container.xml to locate the OPF rootfile (trap #1: ns)."""
    data = zf.read(CONTAINER_PATH)
    if _et_ok:
        root = ET.fromstring(data)
        for el in root.iter():
            if _localname(el.tag) == "rootfile":
                full = el.get("full-path")
                if full:
                    return full
    else:
        for kind, ln, payload in _scan_xml(data):
            if kind == "start" and ln == "rootfile":
                full = payload.get("full-path")
                if full:
                    return full
    raise ValueError("container.xml has no rootfile/@full-path")


def _parse_opf(zf, opf_path):
    """Return (title, spine_hrefs) where hrefs are zip-root-relative paths.

    Trap #1: strip namespaces. Trap #2: href is relative to the OPF directory.
    """
    data = zf.read(opf_path)
    opf_dir = PurePosixPath(opf_path).parent

    title = None
    manifest = {}   # id -> href (relative to OPF dir)
    spine_ids = []  # ordered idrefs

    if _et_ok:
        root = ET.fromstring(data)
        for el in root.iter():
            ln = _localname(el.tag)
            if ln == "title" and title is None:
                title = _norm_ws("".join(el.itertext()))
            elif ln == "item":
                iid = el.get("id")
                href = el.get("href")
                if iid and href:
                    manifest[iid] = href
            elif ln == "itemref":
                idref = el.get("idref")
                if idref:
                    spine_ids.append(idref)
    else:
        in_title = False
        title_parts = []
        for kind, ln, payload in _scan_xml(data):
            if kind == "start":
                if ln == "title":
                    in_title = True
                elif ln == "item":
                    iid = payload.get("id")
                    href = payload.get("href")
                    if iid and href:
                        manifest[iid] = href
                elif ln == "itemref":
                    idref = payload.get("idref")
                    if idref:
                        spine_ids.append(idref)
            elif kind == "text" and in_title and ln == "title":
                title_parts.append(payload)
                in_title = False
        if title_parts:
            title = _norm_ws("".join(title_parts))

    spine_hrefs = []
    for sid in spine_ids:
        href = manifest.get(sid)
        if not href:
            continue
        # Trap #2: resolve relative to OPF dir, normalize, make zip-root path.
        resolved = (opf_dir / href) if str(opf_dir) not in ("", ".") else PurePosixPath(href)
        spine_hrefs.append(str(resolved))
    return title or "Untitled", spine_hrefs


def _zip_read_tolerant(zf, path):
    """Read a zip member, tolerating leading './' and case-path mismatches."""
    names = set(zf.namelist())
    if path in names:
        return zf.read(path)
    # Try without leading ./, and url-unescaped variants.
    cand = path.lstrip("./")
    if cand in names:
        return zf.read(cand)
    # Last resort: case-insensitive match on basename+path.
    low = path.lower()
    for n in names:
        if n.lower() == low:
            return zf.read(n)
    raise KeyError(path)


def ingest(epub_path):
    with zipfile.ZipFile(epub_path, "r") as zf:
        opf_path = _find_opf_path(zf)
        title, spine_hrefs = _parse_opf(zf, opf_path)

        chapters = []
        for spine_idx, href in enumerate(spine_hrefs, start=1):
            try:
                xhtml = _zip_read_tolerant(zf, href)
            except KeyError:
                continue
            blocks = extract_blocks(xhtml)
            if not blocks:
                continue
            # Chapter title: first heading block, else derived from filename.
            chap_title = None
            for b in blocks:
                if b["tag"] in ("h1", "h2", "h3"):
                    chap_title = b["text"]
                    break
            if not chap_title:
                chap_title = PurePosixPath(href).stem

            paragraphs = []
            for n, b in enumerate(blocks, start=1):
                paragraphs.append(
                    {
                        "pid": "c%d-p%d" % (spine_idx, n),
                        "tag": b["tag"],
                        "text": b["text"],
                        "html": b["html"],
                    }
                )
            chapters.append(
                {
                    "chapter_id": "c%d" % spine_idx,
                    "title": chap_title,
                    "href": href,
                    "paragraphs": paragraphs,
                }
            )

    # source_hash: sha256 of normalized concatenated paragraph text in spine order.
    # Deterministic across re-runs of the same EPUB.
    hasher = hashlib.sha256()
    for ch in chapters:
        for p in ch["paragraphs"]:
            hasher.update(p["text"].encode("utf-8"))
            hasher.update(b"\n")
    source_hash = hasher.hexdigest()

    return {"source_hash": source_hash, "title": title, "chapters": chapters}


def slugify(title):
    s = re.sub(r"[^\w\s-]", "", (title or "").lower(), flags=re.UNICODE)
    s = re.sub(r"[\s_-]+", "-", s).strip("-")
    return s or "untitled"


def main(argv=None):
    ap = argparse.ArgumentParser(description="EPUB -> content.json (stdlib only)")
    ap.add_argument("epub", help="path to .epub file")
    ap.add_argument("-o", "--output", required=True, help="output content.json path")
    args = ap.parse_args(argv)

    content = ingest(args.epub)
    out = json.dumps(content, ensure_ascii=False, indent=2, sort_keys=False)
    p = args.output
    if p == "-":
        sys.stdout.write(out + "\n")
    else:
        from pathlib import Path

        Path(p).write_text(out + "\n", encoding="utf-8")
        sys.stderr.write(
            "wrote %s: %d chapters, source_hash=%s\n"
            % (p, len(content["chapters"]), content["source_hash"][:12])
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
