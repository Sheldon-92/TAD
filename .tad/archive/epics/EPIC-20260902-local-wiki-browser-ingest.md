# EPIC-20260902 — Local Wiki Browser Ingest Bridge

**Status:** Superseded — runtime dependency rejected by Human on 2026-09-02
**Previous:** Local Wiki Phase 2 Retrieval, Gate 4 PASS at `cbbb0303`
**Decision:** `.tad/decisions/DR-20260902-local-wiki-browser-ingest-bridge.md`

## Outcome

A researcher can save a YouTube transcript or an already-rendered authorized web page
with the existing Chrome extension, then import that Markdown into Local Wiki with one
local command. The imported file is immediately searchable and retains provenance.

## Phase map

| Phase | Name | Status |
|---|---|---|
| 3 | Browser Ingest Bridge | Done |

## Phase 3 detail

**Status:** Done — Gate 3 + Gate 4 PASS

### In scope

- Reuse `/Users/sheldonzhao/01-on progress programs/下载md插件/web-to-markdown` as the browser capture layer.
- Add a stdlib Local Wiki Markdown import command and focused tests.
- Map extension frontmatter into Local Wiki raw metadata without rewriting the body.
- Route YouTube captures to `research/raw/transcripts/`; rendered pages to `research/raw/articles/`.
- Harden the extension's current YouTube timed-text interception: strict endpoint matching,
  bounded response capture, and unconditional restoration of patched browser APIs.
- One public YouTube transcript proof plus one deterministic rendered-page fixture when feasible.

### Explicitly out of scope

- Audio/video download, Whisper, OCR, or new transcription.
- Paywall bypass or extracting content not already visible to the authorized user.
- MCP, vector databases, cloud sync, continuous browser-to-disk sync.
- Image ZIP or HTML snapshot import.
- A broad multi-browser or multi-video test matrix.

### Success criteria

1. A valid extension Markdown file imports safely and is discoverable by Local Wiki search.
2. YouTube timestamps remain present and can serve as exact locators.
3. Invalid, oversized, symlinked, or path-escaping inputs fail closed.
4. No cookies, authorization headers, or browser credentials are written into imported files.
5. Existing Local Wiki and extension deterministic tests remain green.
6. Experimental/live drift may degrade that adapter honestly; it does not block the completed local bridge.

## Supersession

The bridge architecture depended on a separate browser extension at runtime and therefore
did not internalize the research capability. Its importer remains reusable plumbing, but
the product acceptance is revoked. The external extension was restored exactly; the native
replacement is `EPIC-20260902-local-wiki-native-capture.md`.
