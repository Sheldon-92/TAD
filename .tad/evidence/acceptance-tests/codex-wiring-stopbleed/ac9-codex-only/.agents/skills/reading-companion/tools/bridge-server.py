#!/usr/bin/env python3
"""bridge-server.py — localhost Live Co-Read Bridge (Phase 3). STDLIB ONLY.

Security model (load-bearing — see handoff §4.5):
  - Binds 127.0.0.1 ONLY (never 0.0.0.0). Loopback bind is NOT a boundary on its
    own, so we ALSO enforce a Host-header allowlist == "127.0.0.1:PORT" (FR9,
    DNS-rebinding defense).
  - Session token: secrets.token_urlsafe(), minted per start, NEVER written to
    disk, compared with secrets.compare_digest (constant time). State-changing
    endpoints (/send,/reply,/close) require it in the X-Coread-Token HEADER
    (CSRF-safe); / and /events accept ?t= query (EventSource can't set headers).
  - Every response carries strict security headers (FR11): no-referrer, CSP,
    nosniff, no-store. No CORS reflection ever.
  - Path traversal guard (FR12): realpath containment + explicit allowlist.
  - Resource bounds (FR13): /send body-size cap -> 413; redacted rejection log.

Concurrency model (handoff §4.2):
  - ThreadingHTTPServer, daemon_threads=True, allow_reuse_address=True.
  - inbox = queue.Queue; /poll does get(timeout=25) -> Empty => IDLE.
  - SSE: bounded wait + heartbeat + checks `closed` each wake + event: closed.
  - /close: set closed -> wake waiters -> 200 -> shutdown() on a SEPARATE thread.

Endpoints:
  GET  /            -> reader index.html        (?t=)
  GET  /<asset>     -> allowlisted workspace file (?t=)
  POST /send        -> enqueue user message     (header token)        {message,anchor?,passage?}
  GET  /poll        -> long-poll next message   (header OR ?t=)       -> message|idle|closed
  POST /reply       -> push AI reply via SSE     (header token)        {text}
  GET  /events      -> SSE stream of replies     (?t=)
  POST /close       -> close session + shutdown  (header token)
"""
import argparse
import json
import os
import queue
import secrets
import socket
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

# ---- Tunables -------------------------------------------------------------
POLL_TIMEOUT = 25          # server long-poll block (s); client MUST use > this
SSE_HEARTBEAT = 15         # SSE keepalive interval (s)
MAX_BODY = 64 * 1024       # /send body cap (bytes) -> 413 above this (FR13)
MAX_SSE_SUBSCRIBERS = 8    # P1#3: cap concurrent /events streams (self-DoS guard)
REPLY_RING = 16            # P2#6: recent-reply ring buffer replayed on (re)subscribe
ALLOWED_ASSETS = {         # FR12 explicit serve allowlist (basenames)
    "index.html", "content.json", "plan.md", "reading-state.json",
}
TEXT_TYPES = {
    ".html": "text/html; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".md": "text/markdown; charset=utf-8",
    ".txt": "text/plain; charset=utf-8",
}
SENTINEL = {"__sentinel__": True}   # used to wake a parked /poll on close


class Session:
    """Single-session (v1) shared state.

    Concurrency invariants (P2#9 — documented):
      - INBOX is a single-consumer queue: the v1 design assumes ONE terminal
        listen-loop calling /poll. If two /poll requests race, queue.Queue hands
        each message to exactly one of them (no duplication, no loss) — a second
        poller simply "steals" the next message. That is acceptable for the
        single-session/single-terminal v1 contract.
      - `closed` is set/read across threads. Writes happen under `_lock`
        (close()/in handlers via mark_closed); the long-poll fast-path read is a
        plain bool read, which is atomic under CPython's GIL. To avoid relying on
        the GIL we ALSO funnel the authoritative close through `_lock` and wake
        every waiter, so a missed fast-path read is corrected within one wake.
    """

    def __init__(self, token, workspace, port):
        self.token = token
        self.workspace = workspace          # realpath of the served root
        self.port = port
        self.inbox = queue.Queue()          # user messages waiting for the loop
        self._lock = threading.Lock()
        self._closed = False
        # SSE plumbing: each subscriber gets its own queue of reply events.
        self._subscribers = []              # list[queue.Queue]
        self._cond = threading.Condition(self._lock)
        # P2#6: bounded ring buffer of recent replies, replayed on (re)subscribe
        # so a reply pushed during an EventSource reconnect gap isn't lost live.
        self._reply_ring = []               # list[str]

    # `closed` as a property -> reads under no lock are fine (atomic bool), and
    # all writes go through close()/_lock.
    @property
    def closed(self):
        return self._closed

    # --- inbox (user -> terminal) ---
    def put_message(self, msg):
        self.inbox.put(msg)

    def poll(self, timeout):
        """Block up to `timeout`s for a message; ('message',m) | ('idle',) | ('closed',)."""
        if self._closed:
            return ("closed",)
        try:
            item = self.inbox.get(timeout=timeout)
        except queue.Empty:
            return ("closed",) if self._closed else ("idle",)
        if item is SENTINEL or self._closed:
            return ("closed",)
        return ("message", item)

    # --- outbox (terminal -> browser via SSE) ---
    def subscribe(self):
        """Register an SSE subscriber. Returns (queue, backlog) or (None, None)
        if the subscriber cap is hit (P1#3 self-DoS guard)."""
        q = queue.Queue()
        with self._lock:
            if len(self._subscribers) >= MAX_SSE_SUBSCRIBERS:
                return None, None
            self._subscribers.append(q)
            backlog = list(self._reply_ring)   # P2#6 replay recent replies
        return q, backlog

    def unsubscribe(self, q):
        with self._lock:
            if q in self._subscribers:
                self._subscribers.remove(q)

    def push_reply(self, text):
        with self._lock:
            self._reply_ring.append(text)
            if len(self._reply_ring) > REPLY_RING:
                self._reply_ring = self._reply_ring[-REPLY_RING:]
            for q in self._subscribers:
                q.put({"type": "reply", "text": text})

    def close(self):
        """Mark closed and wake every waiter (parked /poll + every SSE sub)."""
        with self._lock:
            self._closed = True
            for q in self._subscribers:
                q.put({"type": "closed"})
            self._cond.notify_all()
        # wake a parked /poll (outside the lock; queue has its own lock)
        self.inbox.put(SENTINEL)


def _redact(s, token):
    if not s:
        return s
    return s.replace(token, "<redacted-token>") if token else s


def _inject_nonce(html_bytes, nonce):
    """Add nonce="<n>" to every <script ...> and <style ...> opening tag (P0#1).

    Byte-level regex on the in-memory HTML at serve time (the file on disk stays
    nonce-free; each response gets a fresh nonce). Matches both `<script>` and
    `<script id="x" type="y">` forms; idempotent-safe (won't double-add)."""
    import re as _re
    pattern = _re.compile(rb"<(script|style)(?![^>]*\bnonce=)([^>]*)>", _re.IGNORECASE)
    nb = nonce.encode("ascii")

    def _add(m):
        tag = m.group(1)
        attrs = m.group(2)
        return b"<" + tag + b' nonce="' + nb + b'"' + attrs + b">"

    return pattern.sub(_add, html_bytes)


class Handler(BaseHTTPRequestHandler):
    # Bound at server-construction time (see make_server).
    session = None
    server_version = "CoReadBridge/1.0"
    protocol_version = "HTTP/1.1"

    # ---- logging (redacted) ----
    def log_message(self, fmt, *args):
        sys.stderr.write("[bridge] %s - %s\n" % (self.address_string(),
                                                 _redact(fmt % args, self.session.token)))

    def _reject(self, code, reason):
        tok = self.session.token if self.session else ""
        sys.stderr.write("[bridge] REJECT %s %s -> %d (%s)\n"
                         % (self.command, _redact(self.path, tok), code, reason))
        # P1#2: the reason MUST be a Content-Length-counted body, or the extra
        # bytes desync the NEXT response on a reused keep-alive connection.
        body = (reason + "\n").encode("utf-8", "replace")
        self._send_headers(code, "text/plain; charset=utf-8", body=body)
        try:
            self.wfile.write(body)
        except Exception:
            pass

    def _csp(self, nonce=None):
        """CSP header value. With a nonce, allow ONLY nonce'd inline script/style
        (P0#1) — injected inline (EPUB/message) stays blocked (no 'unsafe-inline')."""
        if nonce:
            return ("default-src 'self'; "
                    "script-src 'nonce-%s'; style-src 'nonce-%s'; "
                    "img-src 'self' data:; connect-src 'self'" % (nonce, nonce))
        return "default-src 'self'; img-src 'self' data:; connect-src 'self'"

    # ---- common response headers (FR11) ----
    def _security_headers(self, nonce=None):
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Content-Security-Policy", self._csp(nonce))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Cache-Control", "no-store")

    def _send_headers(self, code, ctype, body=None, extra=None, length=None,
                      nonce=None, close=False):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self._security_headers(nonce=nonce)
        if close:
            self.send_header("Connection", "close")
        if extra:
            for k, v in extra.items():
                self.send_header(k, v)
        # P1#2: ALWAYS set Content-Length on a (non-SSE) keep-alive response so
        # the framing is unambiguous. body has priority; explicit length next.
        if length is not None:
            self.send_header("Content-Length", str(length))
        elif body is not None:
            self.send_header("Content-Length", str(len(body)))
        else:
            self.send_header("Content-Length", "0")
        self.end_headers()

    def _json(self, code, obj):
        body = json.dumps(obj).encode("utf-8")
        self._send_headers(code, "application/json; charset=utf-8", body=body)
        self.wfile.write(body)

    # ---- security gates ----
    def _host_ok(self):
        """FR9: Host header MUST be exactly the bound 127.0.0.1:PORT."""
        host = self.headers.get("Host", "")
        return host == ("127.0.0.1:%d" % self.session.port)

    def _token_from_query(self):
        q = parse_qs(urlparse(self.path).query)
        vals = q.get("t", [])
        return vals[0] if vals else ""

    def _token_ok_query(self):
        supplied = self._token_from_query()
        return bool(supplied) and secrets.compare_digest(supplied, self.session.token)

    def _token_ok_header(self):
        supplied = self.headers.get("X-Coread-Token", "")
        return bool(supplied) and secrets.compare_digest(supplied, self.session.token)

    def _read_body(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except (TypeError, ValueError):
            return None, 411
        if length > MAX_BODY:
            return None, 413
        if length <= 0:
            return b"", 200
        return self.rfile.read(length), 200

    # ---- routing ----
    def do_GET(self):
        if not self._host_ok():
            return self._reject(403, "bad-host")
        path = urlparse(self.path).path
        if path == "/poll":
            # poll accepts header OR query token (terminal client may use either)
            if not (self._token_ok_header() or self._token_ok_query()):
                return self._reject(403, "bad-token")
            return self._handle_poll()
        if path == "/events":
            if not self._token_ok_query() and not self._token_ok_header():
                return self._reject(403, "bad-token")
            return self._handle_events()
        # Static serve (/ or an allowlisted asset). Query token required.
        if not self._token_ok_query() and not self._token_ok_header():
            return self._reject(403, "bad-token")
        return self._handle_static(path)

    def do_POST(self):
        if not self._host_ok():
            return self._reject(403, "bad-host")
        path = urlparse(self.path).path
        # State-changing endpoints require the HEADER token (CSRF-safe, FR10).
        if path in ("/send", "/reply", "/close"):
            if not self._token_ok_header():
                return self._reject(403, "bad-token")
        else:
            return self._reject(404, "no-such-endpoint")
        if path == "/send":
            return self._handle_send()
        if path == "/reply":
            return self._handle_reply()
        if path == "/close":
            return self._handle_close()

    # Reject any other method (FR12 "reject unexpected HTTP methods").
    def _method_not_allowed(self):
        if not self._host_ok():
            return self._reject(403, "bad-host")
        return self._reject(405, "method-not-allowed")

    do_PUT = do_DELETE = do_PATCH = do_HEAD = do_OPTIONS = _method_not_allowed

    # ---- handlers ----
    def _handle_static(self, path):
        # FR12: realpath-contained allowlist serve.
        name = path.lstrip("/")
        if name == "" or name == "/":
            name = "index.html"
        # reject anything not on the basename allowlist outright
        base = os.path.basename(name)
        if base not in ALLOWED_ASSETS or base != name:
            # base != name means there was a path component (dir/traversal) — reject
            return self._reject(404, "not-allowlisted")
        candidate = os.path.realpath(os.path.join(self.session.workspace, base))
        root = self.session.workspace
        # containment: candidate must live directly under the workspace root
        if os.path.commonpath([candidate, root]) != root or os.path.dirname(candidate) != root:
            return self._reject(404, "traversal")
        if not os.path.isfile(candidate):
            return self._reject(404, "not-found")
        ext = os.path.splitext(candidate)[1].lower()
        ctype = TEXT_TYPES.get(ext, "application/octet-stream")
        try:
            with open(candidate, "rb") as f:
                data = f.read()
        except OSError:
            return self._reject(404, "not-found")
        # P0#1: for the HTML reader, mint a PER-RESPONSE nonce and inject it into
        # every <script>/<style> opening tag, then advertise that nonce in the
        # CSP. The strict CSP (default-src 'self', script-src 'nonce-…', NO
        # 'unsafe-inline') means the reader's own inline JS/CSS runs, while any
        # injected inline (from a malicious EPUB or a chat message) stays blocked.
        nonce = None
        if ext == ".html":
            nonce = secrets.token_urlsafe(16)
            data = _inject_nonce(data, nonce)
        self._send_headers(200, ctype, body=data, nonce=nonce)
        self.wfile.write(data)

    def _handle_send(self):
        body, code = self._read_body()
        if code == 413:
            return self._reject(413, "oversized-body")
        if code == 411 or body is None:
            return self._reject(411, "length-required")
        try:
            obj = json.loads(body.decode("utf-8")) if body else {}
        except (ValueError, UnicodeDecodeError):
            return self._reject(400, "bad-json")
        message = obj.get("message", "")
        if not isinstance(message, str) or not message.strip():
            return self._reject(400, "empty-message")
        msg = {
            "type": "message",
            "message": message,
            "anchor": obj.get("anchor"),
            "passage": obj.get("passage"),
            "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }
        self.session.put_message(msg)
        return self._json(200, {"ok": True})

    def _handle_poll(self):
        result = self.session.poll(POLL_TIMEOUT)
        if result[0] == "message":
            return self._json(200, result[1])
        if result[0] == "closed":
            return self._json(200, {"type": "closed"})
        return self._json(200, {"type": "idle"})

    def _handle_reply(self):
        body, code = self._read_body()
        if code == 413:
            return self._reject(413, "oversized-body")
        if body is None:
            return self._reject(411, "length-required")
        try:
            obj = json.loads(body.decode("utf-8")) if body else {}
        except (ValueError, UnicodeDecodeError):
            return self._reject(400, "bad-json")
        text = obj.get("text", "")
        # P2#5: mirror /send — reject empty/missing/blank text so the panel never
        # shows a blank assistant bubble.
        if not isinstance(text, str) or not text.strip():
            return self._reject(400, "empty-text")
        self.session.push_reply(text)
        return self._json(200, {"ok": True})

    def _handle_close(self):
        # P1#4: drain+discard any request body so no unread bytes linger on the
        # keep-alive socket (every other POST reads its body; /close must too).
        _body, _code = self._read_body()
        if _code == 413:
            return self._reject(413, "oversized-body")
        self.session.close()
        self._json(200, {"ok": True, "closed": True})
        # P0-3: shutdown() MUST run off the request thread or it deadlocks.
        srv = self.server

        def _shutdown():
            time.sleep(0.05)
            try:
                srv.shutdown()
            except Exception:
                pass
        threading.Thread(target=_shutdown, daemon=True).start()

    def _handle_events(self):
        # SSE stream. Bounded wait + heartbeat + check closed each wake (§4.2 inv 4).
        # P1#3: cap concurrent subscribers to prevent an EventSource-reconnect
        # storm from exhausting threads/FDs.
        q, backlog = self.session.subscribe()
        if q is None:
            return self._reject(503, "too-many-sse-subscribers")
        try:
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream; charset=utf-8")
            # P1#2: the SSE stream ends when the session closes; tell the client
            # not to reuse this connection (no Content-Length on a stream).
            self.send_header("Connection", "close")
            self.send_header("Cache-Control", "no-store")
            self._security_headers()
            self.end_headers()
            # initial comment so the client's onopen fires promptly
            self.wfile.write(b": connected\n\n")
            # P2#6: replay any replies buffered before this (re)subscribe.
            for text in (backlog or []):
                payload = json.dumps({"text": text})
                self.wfile.write(("event: reply\ndata: %s\n\n" % payload).encode("utf-8"))
            self.wfile.flush()
            while True:
                if self.session.closed:
                    self.wfile.write(b"event: closed\ndata: {}\n\n")
                    self.wfile.flush()
                    return
                try:
                    evt = q.get(timeout=SSE_HEARTBEAT)
                except queue.Empty:
                    # heartbeat keepalive; loop re-checks closed
                    self.wfile.write(b": keepalive\n\n")
                    self.wfile.flush()
                    continue
                if evt.get("type") == "closed":
                    self.wfile.write(b"event: closed\ndata: {}\n\n")
                    self.wfile.flush()
                    return
                payload = json.dumps({"text": evt.get("text", "")})
                self.wfile.write(("event: reply\ndata: %s\n\n" % payload).encode("utf-8"))
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            # lost-SSE / closed tab is a soft signal; just exit the thread.
            return
        finally:
            self.session.unsubscribe(q)


def make_server(workspace, port=0, fallback=True):
    """Bind 127.0.0.1:port (0 => ephemeral). Returns (server, session).

    P1#8: if a fixed `port` is already in use, fall back to an ephemeral free
    port (port 0) rather than crashing — unless fallback=False (the AC8 re-bind
    test passes fallback=False so it can assert the EXACT port re-binds)."""
    workspace = os.path.realpath(workspace)
    token = secrets.token_urlsafe(32)

    class _Server(ThreadingHTTPServer):
        daemon_threads = True
        allow_reuse_address = True

    try:
        server = _Server(("127.0.0.1", port), Handler)
    except OSError:
        if port != 0 and fallback:
            sys.stderr.write("[bridge] port %d in use; falling back to an ephemeral port\n" % port)
            server = _Server(("127.0.0.1", 0), Handler)
        else:
            raise
    bound_port = server.server_address[1]
    session = Session(token, workspace, bound_port)
    Handler.session = session
    return server, session


def main(argv=None):
    ap = argparse.ArgumentParser(description="Live Co-Read Bridge server (stdlib, 127.0.0.1)")
    ap.add_argument("--workspace", "-w", required=True,
                    help="reading workspace dir (.reading/<slug>/) — serves index.html etc.")
    ap.add_argument("--port", "-p", type=int, default=0,
                    help="port (default 0 = ephemeral free port)")
    ap.add_argument("--print-token", action="store_true",
                    help="print the token to stdout (default: printed in the URL line)")
    args = ap.parse_args(argv)

    if not os.path.isdir(args.workspace):
        sys.stderr.write("workspace not found: %s\n" % args.workspace)
        return 2

    server, session = make_server(args.workspace, args.port)
    port = session.port
    url = "http://127.0.0.1:%d/?t=%s" % (port, session.token)
    # Token appears only in the URL line on stdout (never written to disk).
    sys.stdout.write("CO-READ BRIDGE READY\n")
    sys.stdout.write("PORT %d\n" % port)
    sys.stdout.write("TOKEN %s\n" % session.token)
    sys.stdout.write("URL %s\n" % url)
    sys.stdout.flush()
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        session.close()
    finally:
        try:
            server.server_close()
        except Exception:
            pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
