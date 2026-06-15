# Phase 3 Grounding — Live Co-Read Bridge

> Conductor (Alex) grounding before YOLO implement. Builds on Phase 2 (accepted).

## Authoritative spec
- Handoff: `.tad/active/handoffs/HANDOFF-20260613-ai-reading-companion-phase3-live-bridge.md` (Gate 2 PASS; 8 P0 + 11 P1 from security-auditor + code-reviewer integrated).
- Design rules: `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md`.

## Builds on (exists, don't break)
- `.claude/skills/reading-companion/templates/reader.html` (515 ln; notebar L149, captureSelection L264, notebarFocusables L419, textContent-only render).
- `.claude/skills/reading-companion/tools/render.py` (reading-state `thread:[]` init L310; `{{…}}` token replace + `</`→`<\/` STATE escape L224-233 — bridge markup MUST NOT collide).

## Load-bearing constraints (Gate 2 — failing these = Gate 3 FAIL)
SECURITY (security-auditor P0s):
1. FR9 Host-header allowlist == bound 127.0.0.1:PORT (DNS-rebind defense) — live AC2b.
2. FR8 prompt-injection isolation: reader content = delimited DATA; loop never follows embedded instructions; least-agency (poll/reply/append/close only) — behavioral AC11.
3. FR10 token: per-start, never on disk, compare_digest, HEADER for /send//reply//close, ?t= only for / and /events.
4. FR11 headers: Referrer-Policy:no-referrer + CSP + nosniff + no-store; no external resources.
5. FR12 path-traversal: realpath containment + allowlist — live AC7b.
6. §9.1 security ACs are RUNTIME/BEHAVIORAL, not grep.
CONCURRENCY (code-reviewer P0s, §4.2):
7. ThreadingHTTPServer + daemon_threads=True + allow_reuse_address.
8. inbox = queue.Queue (get(timeout=25)→IDLE); client poll timeout 30s > server 25s.
9. SSE: bounded wait + heartbeat + check closed each wake + event:closed + client eventSource.close().
10. /close: set closed → wake waiters → 200 → shutdown() on a SEPARATE thread (never inline).

## stdlib-only (hard): http.server/socketserver/threading/queue/json/secrets/socket/urllib/html/mimetypes/signal/datetime/os/sys/pathlib/time/functools. AC13 ast allow-set.

## Verification (Conductor will independently re-run)
§9.1 AC1-AC15 (mostly via tools/test_bridge.py — stdlib client + raw-socket SSE) + REAL-BROWSER end-to-end (send msg in reader → reply appears in panel; XSS message renders inert; file:// degrade). Phase-2 lesson: code-green ≠ working UI; Conductor opens it in Chrome.
