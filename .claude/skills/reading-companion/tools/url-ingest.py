#!/usr/bin/env python3
"""url-ingest.py — fetch a URL -> extract main text -> content.json (STDLIB ONLY).

Security / robustness (handoff FR2, load-bearing):
  - http(s) scheme ONLY; reject file://, ftp://, etc.
  - SSRF guard: reject hosts that resolve to loopback/private/link-local/reserved
    IPs, and reject any redirect that lands on a non-http(s)/internal target.
  - urlopen(timeout=…); read at most MAX_BYTES; require Content-Type text/html
    (else fail loud, no content.json).
  - Boilerplate strip: reuse the epub block-extractor discipline + SKIP_TAGS PLUS
    nav/footer/aside/header (from _rc_common.SKIP_TAGS).
  - The `html` field is ESCAPED text with the inline whitelist ONLY — never raw
    source markup, so a fetched <script>/onerror= can't become stored XSS.
  - Empty extraction -> fail loud (no silent empty book).

Determinism: identical fetched bytes -> identical content.json (shared hash
helper). Re-fetching later may yield new bytes -> new source_hash (new identity).
"""
import argparse
import ipaddress
import os
import socket
import sys
from html.parser import HTMLParser
from urllib.parse import urlparse
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import _rc_common as rc  # noqa: E402

MAX_BYTES = 5 * 1024 * 1024     # 5 MB read cap
TIMEOUT = 15                    # seconds
USER_AGENT = "reading-companion-url-ingest/1.0 (+stdlib)"


# ---- block extractor (epub discipline + Phase-4 SKIP additions via rc.SKIP_TAGS) ----
class _BlockExtractor(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.blocks = []          # [{tag,text,html}]
        self.title = None
        self._in_title = False
        self._skip_depth = 0
        self._block_tag = None
        self._text_parts = []
        self._html_parts = []

    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag == "title":
            self._in_title = True
            return
        if tag in rc.SKIP_TAGS:
            self._skip_depth += 1
            return
        if self._skip_depth:
            return
        if tag in rc.BLOCK_TAGS:
            if self._block_tag is not None:
                self._flush()
            self._block_tag = tag
            self._text_parts = []
            self._html_parts = []
            return
        if self._block_tag is not None and tag in rc.INLINE_KEEP:
            if tag == "br":
                self._text_parts.append(" ")
                self._html_parts.append("<br/>")
            else:
                # keep ONLY the bare inline tag (no attributes -> no onerror=, no href js:)
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
        if tag == "title":
            self._in_title = False
            return
        if tag in rc.SKIP_TAGS:
            if self._skip_depth:
                self._skip_depth -= 1
            return
        if self._skip_depth:
            return
        if tag in rc.BLOCK_TAGS and self._block_tag == tag:
            self._flush()
            return
        if self._block_tag is not None and tag in rc.INLINE_KEEP and tag != "br":
            self._html_parts.append("</%s>" % tag)

    def handle_data(self, data):
        if self._in_title:
            self.title = (self.title or "") + data
            return
        if self._skip_depth or self._block_tag is None:
            return
        self._text_parts.append(data)
        self._html_parts.append(rc.escape_text(data))

    def _flush(self):
        text = rc.normalize_ws("".join(self._text_parts))
        if text:
            self.blocks.append({"tag": self._block_tag, "text": text,
                                "html": rc.normalize_ws("".join(self._html_parts))})
        self._block_tag = None
        self._text_parts = []
        self._html_parts = []

    def close(self):
        if self._block_tag is not None:
            self._flush()
        super().close()


def _is_internal_ip(host):
    """True if host resolves to a loopback/private/link-local/reserved address."""
    try:
        infos = socket.getaddrinfo(host, None)
    except socket.gaierror:
        # can't resolve -> treat as unsafe (fail loud later on fetch anyway)
        return True
    for fam, _, _, _, sockaddr in infos:
        ip = sockaddr[0]
        try:
            addr = ipaddress.ip_address(ip)
        except ValueError:
            return True
        if (addr.is_loopback or addr.is_private or addr.is_link_local
                or addr.is_reserved or addr.is_multicast or addr.is_unspecified):
            return True
    return False


def _check_url_safe(url):
    p = urlparse(url)
    if p.scheme not in ("http", "https"):
        raise rc.IngestError("only http(s) URLs allowed (got scheme %r)" % p.scheme)
    if not p.hostname:
        raise rc.IngestError("URL has no host")
    if _is_internal_ip(p.hostname):
        raise rc.IngestError("refusing to fetch internal/loopback/private host %r (SSRF guard)"
                             % p.hostname)
    return p


class _SafeRedirectHandler:
    pass  # placeholder; redirect validation done via a custom opener below


def _validate_response(final_url, status, ctype, read_body):
    """The SHARED refusal logic for ANY fetched response — runs for both the live
    network path and the offline injection seam, so the security branch is
    actually EXECUTED by tests (not merely code-read). `read_body` is a callable
    returning up to MAX_BYTES+1 bytes.

    Enforces: 404/non-2xx -> fail; final-landing host safe (SSRF); Content-Type
    must be HTML; body size cap. Returns (final_url, ctype, body)."""
    if status is not None and not (200 <= status < 300):
        raise rc.IngestError("HTTP %s for %s" % (status, final_url))
    _check_url_safe(final_url)                       # final landing must be safe too
    ctype = (ctype or "").lower()
    if "text/html" not in ctype and "application/xhtml" not in ctype:
        raise rc.IngestError("Content-Type is not HTML (%r) — refusing to ingest %s"
                             % (ctype or "unknown", final_url))
    body = read_body(MAX_BYTES + 1)
    if len(body) > MAX_BYTES:
        body = body[:MAX_BYTES]                      # cap; truncated is fine
    return final_url, ctype, body


def _fetch(url):
    """Fetch with SSRF + redirect validation. Returns (final_url, content_type, body)."""
    _check_url_safe(url)
    from urllib.request import HTTPRedirectHandler, build_opener

    class _Guard(HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            # validate EVERY redirect target before following (SSRF / scheme)
            _check_url_safe(newurl)
            return super().redirect_request(req, fp, code, msg, headers, newurl)

    opener = build_opener(_Guard)
    req = Request(url, headers={"User-Agent": USER_AGENT, "Accept": "text/html"})
    try:
        resp = opener.open(req, timeout=TIMEOUT)
    except HTTPError as e:
        raise rc.IngestError("HTTP %s for %s" % (e.code, url))
    except URLError as e:
        raise rc.IngestError("fetch failed for %s: %s" % (url, e.reason))
    status = getattr(resp, "status", None) or resp.getcode()
    return _validate_response(resp.geturl(), status,
                              resp.headers.get("Content-Type"), resp.read)


def _fetch_offline(final_url, raw_bytes, content_type, status):
    """Offline injection seam (testing): run the EXACT same response-validation
    refusal path as the live fetch, against caller-supplied bytes/ctype/status.
    Proves the Content-Type gate / non-2xx (404) / final-landing SSRF recheck
    actually EXECUTE (P1#1 — closes the AC3c validation-theater gap)."""
    _check_url_safe(final_url)                       # scheme/SSRF of the target
    buf = {"b": raw_bytes}

    def _read(n):
        return buf["b"][:n]

    return _validate_response(final_url, status, content_type, _read)


def _decode(body, ctype):
    enc = "utf-8"
    if "charset=" in ctype:
        enc = ctype.split("charset=", 1)[1].split(";")[0].strip() or "utf-8"
    try:
        return body.decode(enc, "replace")
    except (LookupError, UnicodeDecodeError):
        return body.decode("utf-8", "replace")


def ingest(url, _html=None, _fetched=None):
    """Fetch+extract a URL into content.json.

    `_html`    : pass already-extracted main-content HTML (skips fetch+validation;
                 the AC3 happy-path local-fixture seam).
    `_fetched` : (final_url, raw_bytes, content_type, status) — runs the FULL fetch
                 RESPONSE-VALIDATION path offline (Content-Type gate / 404 / SSRF
                 final-landing). Used by AC3c to execute the security branch."""
    if _html is not None:
        html_text = _html
        title_fallback = "Untitled"
    elif _fetched is not None:
        final_url, raw_bytes, content_type, status = _fetched
        final_url, ctype, body = _fetch_offline(final_url, raw_bytes, content_type, status)
        html_text = _decode(body, ctype)
        p = urlparse(final_url)
        title_fallback = (p.netloc + p.path).strip("/") or final_url
    else:
        final_url, ctype, body = _fetch(url)
        html_text = _decode(body, ctype)
        p = urlparse(final_url)
        title_fallback = (p.netloc + p.path).strip("/") or final_url

    ex = _BlockExtractor()
    ex.feed(html_text)
    ex.close()
    blocks = ex.blocks
    doc_title = rc.normalize_ws(ex.title or "") or title_fallback

    # Chapterize by <h1>/<h2>; everything before the first heading is chapter 1.
    chapters = []
    cur_blocks = []
    cur_title = doc_title
    chap_n = 0

    def commit():
        nonlocal chap_n, cur_blocks, cur_title
        if not cur_blocks:
            return
        chap_n += 1
        paras = [rc.make_paragraph(chap_n, i, b["tag"], b["text"], b["html"])
                 for i, b in enumerate(cur_blocks, start=1)]
        chapters.append(rc.make_chapter(chap_n, cur_title, paras))
        cur_blocks = []

    for b in blocks:
        if b["tag"] in ("h1", "h2") and cur_blocks:
            commit()
            cur_title = b["text"]
        cur_blocks.append(b)
    commit()

    content = rc.build_content(doc_title, chapters)
    return rc.require_nonempty(content, what="URL '%s'" % url)


def main(argv=None):
    ap = argparse.ArgumentParser(description="URL -> content.json (stdlib only)")
    ap.add_argument("url", help="http(s) URL")
    ap.add_argument("-o", "--output", required=True, help="output content.json ('-' for stdout)")
    ap.add_argument("--html-file", help="(testing) extracted-HTML local fixture (skips fetch)")
    ap.add_argument("--raw-bytes", help="(testing) file of raw RESPONSE bytes — runs the full "
                                        "fetch response-validation path offline")
    ap.add_argument("--content-type", default="text/html; charset=utf-8",
                    help="(testing, with --raw-bytes) the response Content-Type")
    ap.add_argument("--status", type=int, default=200,
                    help="(testing, with --raw-bytes) the response HTTP status code")
    args = ap.parse_args(argv)
    try:
        if args.html_file:
            from pathlib import Path
            raw = Path(args.html_file).read_text(encoding="utf-8", errors="replace")
            content = ingest(args.url, _html=raw)
        elif args.raw_bytes:
            from pathlib import Path
            data = Path(args.raw_bytes).read_bytes()
            content = ingest(args.url, _fetched=(args.url, data, args.content_type, args.status))
        else:
            content = ingest(args.url)
    except rc.IngestError as e:
        sys.stderr.write("BLOCKED: %s\n" % e)
        return 1
    rc.write_content(content, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
