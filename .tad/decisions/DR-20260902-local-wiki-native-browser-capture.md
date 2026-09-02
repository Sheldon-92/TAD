# DR-20260902 — Native Chrome Capture for Local Wiki

**Status:** Accepted by Human correction on 2026-09-02
**Supersedes:** `DR-20260902-local-wiki-browser-ingest-bridge.md` as the runtime architecture

## Decision

Internalize capture as a TAD-owned inner-loop CLI. Use Node 24's built-in `fetch` and
`WebSocket` to speak Chrome DevTools Protocol directly to a dedicated Chrome profile.
The CLI evaluates a bounded extraction function in the selected page, receives only
metadata plus Markdown/text, and invokes Local Wiki's existing safe importer internally.

Commands:

```bash
node research/scripts/browser-capture.mjs launch [URL]
node research/scripts/browser-capture.mjs tabs
node research/scripts/browser-capture.mjs capture [--tab ID] [--kind auto|page|youtube]
```

`launch` uses a dedicated profile outside the repository, defaulting to
`~/.tad-browser/local-wiki-profile`, and loopback CDP. It never attaches to the default
Chrome profile. The user may log into that isolated browser normally when an authorized
page requires it. Capture never requests credentials and never accesses cookies, local
storage, request headers, or Chrome profile files.

## Why this architecture

- Inner-loop, one-user operation: CLI is cheaper and simpler than MCP.
- Existing Chrome + Node are sufficient; a new Playwright/Crawl4AI dependency is unnecessary.
- Page execution is required for rendered/authenticated DOM and YouTube player context.
- Markdown remains the durable boundary into Local Wiki; browser state is ephemeral.

## Correction and recovery

The prior external extension dependency was a product error. All three external changes
were reversed and their original hashes reverified before this decision was implemented.
The earlier importer remains internal plumbing and testable file import fallback, not a
required companion application.

