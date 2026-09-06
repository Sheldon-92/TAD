# Phase 3R Grounding

- Node `v24.7.0` exposes built-in `fetch` and `WebSocket`.
- Chrome `152.0.7977.66` is installed at `/Applications/Google Chrome.app`.
- A temporary headless Chrome launched with a fixed isolated profile and port returned CDP
  protocol `1.3` from `http://127.0.0.1:9223/json/version`.
- No Playwright/Crawl4AI CLI or browser MCP is available; the Codex Chrome connector currently
  has an internal package-version mismatch.
- `research/scripts/import-clip.py` already provides strict metadata parsing, no-follow input,
  descriptor-anchored atomic publication, collision handling, and raw routing.
- `research/scripts/search.py` automatically indexes newly created raw Markdown.
- The external plugin was restored to original hashes: popup `7f873c...eee73`, runner
  `f8e355...d95f`, lifecycle test absent.

Selection: L1 deterministic Chrome/CDP plus local Markdown extraction; direct CLI rather than
MCP. This is the lowest available layer that can access rendered/authenticated DOM and
YouTube page context without an external runtime dependency.

