# EPIC-20260902 — Local Wiki Native Browser Capture

**Status:** Complete — Gate 4 PASS
**Corrects:** `.tad/archive/epics/EPIC-20260902-local-wiki-browser-ingest.md`
**Decision:** `.tad/decisions/DR-20260902-local-wiki-native-browser-capture.md`

## Outcome

Local Wiki itself can launch/connect to an isolated Chrome session and capture the active
rendered page or a YouTube transcript directly into `research/raw/`. No separate browser
extension, download plugin, cloud extraction service, MCP server, or npm package is required.

## Phase map

| Phase | Name | Status |
|---|---|---|
| 3R | Native Chrome capture | Done (`7cce3f78`) |

## Phase 3R boundaries

In scope: TAD-owned Node CLI, local Chrome DevTools Protocol connection, rendered-page text
to Markdown, YouTube caption discovery/fetch in page context, reuse of safe Local Wiki
publication, isolated profile launcher, focused tests, one public YouTube live probe.

Out of scope: paywall bypass, automatic credential entry, copying the external extension,
Whisper/audio/video download, anti-bot evasion, broad crawling, browser-agent frameworks,
MCP, continuous sync, screenshots/images.

## Success

- One TAD command captures without the external project being installed.
- Page capture only reads already-rendered DOM from the connected tab.
- YouTube capture preserves timestamps and provenance.
- The CLI never reads or serializes cookie/storage/header data.
- Existing Local Wiki tests remain green.
