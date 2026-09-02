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

- `research/canon/README.md` and/or `research/CLAUDE.md`
- importer only if a small reusable boundary is needed; keep its existing CLI compatible
- completion/evidence under the task paths

Do not modify or read at runtime from `/Users/sheldonzhao/01-on progress programs/下载md插件`.
It is prior art only and has already been restored.

## 4. CLI contract

- `launch [URL] [--port N] [--profile PATH] [--headless]`: validate loopback port and HTTPS/
  localhost URL; start Chrome with an explicit non-default profile. Print connection details.
- `tabs [--port N] [--json]`: use loopback CDP discovery, show only page targets with id/title/url.
- `capture [--port N] [--tab ID] [--kind auto|page|youtube] [--language CODE]
  [--repo-root ROOT] [--dry-run]`: select an exact tab or the sole/first safe page, evaluate
  extractor, send only Markdown metadata/body through internal importer, print raw path.
- Unknown flags, unsafe endpoints, missing/multiple ambiguous tabs, non-HTTPS remote pages,
  devtools/file/chrome targets, oversized results, CDP timeouts, and protocol errors fail closed.
- Never print or request cookies, storage, authorization headers, profile contents, or caption URLs.

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

## 6. Transport and process safety

- Node built-ins only; no npm install and no MCP.
- CDP HTTP endpoint is fixed to `127.0.0.1`; port integer 1024–65535.
- WebSocket URL must be `ws://127.0.0.1:<same-port>/devtools/page/...` from discovery.
- Request IDs, bounded timeout, cleanup, and rejection of pending calls on close/error.
- Temporary capture files are mode 0600, outside repo, and removed in `finally`.
- `launch` does not reuse default Chrome profile, overwrite an existing profile, or kill a
  pre-existing Chrome. Capture never controls unrelated tabs beyond chosen target.

## 7. Acceptance criteria

| ID | Criterion | Verification |
|---|---|---|
| AC1 | No runtime/documentation reference requires the external plugin | recursive scoped search + user flow |
| AC2 | Fake CDP page capture writes searchable `raw/articles` Markdown | deterministic E2E |
| AC3 | Fake CDP YouTube capture writes timestamped searchable `raw/transcripts` Markdown | deterministic E2E |
| AC4 | URL/port/target/WebSocket/result/timeout/protocol negatives fail closed without raw output | negative suite |
| AC5 | No cookie/storage/header/profile data is requested, logged, or persisted | test assertions + code review |
| AC6 | `launch` uses isolated explicit profile and never mutates/kills default Chrome | argv/process test |
| AC7 | One temporary-profile Chrome page capture and one public YouTube transcript probe attempted; YouTube failure may be honest live degradation only if deterministic AC3 passes | live evidence |
| AC8 | Existing importer/search tests, canon lint, generation, and new Node tests pass | regression commands |
| AC9 | Prior external plugin exact pre-state remains unchanged | three-state hash/absence check |

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

