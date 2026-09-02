---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: ["research/scripts", "research/tests"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff — Local Wiki Phase 3R Native Browser Capture

**From:** Alex
**To:** Blake implementation worker
**Date:** 2026-09-02
**Task ID:** TASK-20260902-LOCAL-WIKI-P3R-NATIVE-CAPTURE
**Epic:** `.tad/active/epics/EPIC-20260902-local-wiki-native-capture.md`

**Gate 2:** PASS after two independent design reviews (P0=0); all nine P1 findings and
both numeric-bound advisories were integrated before implementation.

## 1. Outcome

Replace the rejected external-plugin runtime boundary with a TAD-owned zero-package Node CLI
that captures a connected Chrome tab directly into Local Wiki.

## 2. Mandatory reading

- Epic, DR, design, and grounding named above.
- `.tad/project-knowledge/principles.md`
- `.tad/project-knowledge/patterns/ac-verification.md`
- `research/CLAUDE.md`, `research/canon/README.md`
- `research/scripts/import-clip.py`, `research/scripts/search.py`

## 3. Files

Create:

- `research/scripts/browser-capture.mjs`
- `research/tests/browser-capture.test.mjs`
- minimal local HTML fixture if needed

Modify:

- `research/canon/README.md` (required: replace companion-extension workflow)
- `research/CLAUDE.md` (required: add native capture command summary)
- importer only if a small reusable boundary is needed; keep its existing CLI compatible
- completion/evidence under the task paths

Do not modify or read at runtime from `/Users/sheldonzhao/01-on progress programs/下载md插件`.
It is prior art only and has already been restored.

## 4. CLI contract

- `launch [URL] [--port N] [--profile PATH] [--headless]`: accept only HTTPS URL or
  `about:blank`; start Chrome with an explicit owned non-default profile and
  `--remote-debugging-address=127.0.0.1`. Default port 0 lets Chrome choose a free port.
  Print only PID/port/profile, never a debugger WebSocket URL.
- `tabs [--port N] [--json]`: use loopback CDP discovery, show only page targets with id/title/url.
- `capture [--port N] [--tab ID] [--kind auto|page|youtube] [--language CODE]
  [--repo-root ROOT] [--dry-run]`: select an exact tab or the sole safe page, evaluate
  extractor, send only Markdown metadata/body through internal importer, print raw path.
- Unknown flags, unsafe endpoints, missing/multiple ambiguous tabs, non-HTTPS remote pages,
  devtools/file/chrome targets, oversized results, CDP timeouts, and protocol errors fail closed.
- More than one eligible page without `--tab` is an error. Explicit `--port` also requires
  `--tab`. Re-discover and validate type/URL immediately before extraction.
- Never print or request cookies, storage, authorization headers, profile contents, caption
  URLs, raw CDP exceptions, or debugger WebSocket URLs.

## 5. Extractor contract

### Rendered page

- Read only DOM already rendered in the selected tab.
- Remove non-content/interactive/script nodes and hidden elements.
- Convert common semantic elements to readable Markdown with bounded traversal/output.
- Preserve title, original URL, saved timestamp, and optional description.
- Mark resulting source as `rendered_page_export`; this does not attest authorization.

### YouTube

- Auto-detect exact YouTube host/watch URL; `--kind youtube` rejects other sites.
- Discover bounded player JSON, caption tracks, preferred language/manual/default selection.
- Validate caption endpoint as HTTPS exact YouTube host plus `/api/timedtext`.
- Fetch JSON3 inside page context; cap response at 5 MiB and 100k events.
- Merge into Markdown paragraphs with `**[MM:SS]**`/`**[HH:MM:SS]**` timestamps.
- Reject no captions/empty transcript/invalid response honestly.
- Bounds: DOM 50,000 nodes; script scan 50 × 5 MiB; output/subtitle 5 MiB; events 100,000.

## 6. Transport and process safety

- Node built-ins only; no npm install and no MCP.
- CDP HTTP endpoint is fixed to `127.0.0.1`; explicit port integer 1024–65535, default launch
  port 0; verify the port is unused before explicit-port launch.
- WebSocket URL must be `ws://127.0.0.1:<same-port>/devtools/page/...` from discovery.
- Request IDs, 15-second timeout, 6 MiB frame bound, cleanup, and rejection of pending calls
  on close/error.
- Get the global object with a fixed expression, then use `Runtime.callFunctionOn` with a fixed
  function declaration and structured arguments. Language must match the frozen BCP-47 subset.
- The extractor verifies current `location.href` and selected kind; navigation drift fails.
- Temporary capture files are mode 0600, outside repo, and removed in `finally`.
- `launch` rejects known default Chrome profile paths and existing unmarked directories. It
  creates/reuses only a 0700 TAD-owned profile with a 0600 marker containing magic, canonical
  path, PID, port, and start time. It never kills a pre-existing Chrome. Capture never controls
  unrelated tabs beyond the chosen target.

## 7. Acceptance criteria

| ID | Criterion | Verification |
|---|---|---|
| AC1 | No runtime or product-facing research documentation requires the external plugin; old active design is archived and old DR marked superseded | `rg -n 'companion browser extension|下载md插件' research` returns 0 |
| AC2 | Injected fake transport page capture plus real importer writes searchable `raw/articles` Markdown; real temporary Chrome proves actual CDP page extraction | deterministic integration + live local/HTTPS page |
| AC3 | Injected fake transport YouTube capture plus transcript transformation and importer writes timestamped searchable `raw/transcripts` Markdown | deterministic integration |
| AC4 | URL/port/target/WebSocket/result/timeout/protocol negatives fail closed without raw output | negative suite |
| AC5 | No cookie/storage/header/profile data is requested, logged, or persisted | test assertions + code review |
| AC6 | launch rejects default/unowned profiles and occupied ports; creates/reuses only owned 0700/0600 profile state; never mutates/kills default Chrome | argv/process tests |
| AC7 | One temporary-profile real Chrome HTTPS page capture and one public YouTube transcript probe attempted; YouTube failure may be honest live degradation only if deterministic AC3 passes | live evidence |
| AC8 | Existing importer/search tests, canon lint, generation, and new Node tests pass | regression commands |
| AC9 | Prior external plugin restoration is recorded once as migration evidence, with no portable/runtime test dependency on that absolute path | evidence inspection + scoped runtime search |

## 8. Required commands

```bash
node --test research/tests/browser-capture.test.mjs
python3 -m unittest -v research.tests.test_import_clip research.tests.test_search
bash research/canon/lint.sh
diff <(python3 research/scripts/generate.py --emit all) <(python3 research/scripts/generate.py --emit all)
```

## 9. Evidence and boundaries

- Completion report with AC table and exact outputs.
- Fake-CDP evidence plus live Chrome dispositions; never label fixture as live.
- External original hash/absence check.
- Two independent implementation reviews, final P0=0/P1=0.
- Maximum three repair rounds. Do not install frameworks, add anti-bot evasion, or reintroduce
  the external extension if live YouTube drifts.

## 10. Test seam

Export pure parsers, selection, transformation, fixed page-function declarations, and
`captureAndImport(options, transport)` from the `.mjs` module. The production CLI constructs
the real WebSocket transport; tests inject an object with the same `call(method, params)` and
`close()` interface. This avoids a fake RFC6455 server while still exercising selection,
structured call parameters, returned-shape validation, importer subprocess, and raw search.
