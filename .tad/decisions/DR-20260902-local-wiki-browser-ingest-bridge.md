# DR-20260902 — Local Wiki Browser Ingest Bridge

**Status:** Superseded by Human correction on 2026-09-02

> The Markdown importer remains useful internal plumbing, but the separate extension is
> not an accepted runtime dependency. See `DR-20260902-local-wiki-native-browser-capture.md`.

## Context

Local Wiki already has file-backed storage and retrieval, but its URL ingest creates a
placeholder rather than importing browser-visible content. A separate local Chrome
extension already extracts readable pages and YouTube captions to Markdown. Rebuilding
those capabilities inside TAD would duplicate working code and introduce browser/auth
complexity into the research core.

## Decision

Keep a boundary architecture:

1. The existing extension remains the browser/session-aware capture tool.
2. Local Wiki adds a stdlib `import-clip.py` command that consumes an exported Markdown
   file, normalizes metadata, and writes a new immutable raw source.
3. The extension keeps its existing export format. Only its YouTube interception is
   hardened where a concrete lifecycle/security defect was found.
4. The boundary is a Markdown file, not an API, daemon, MCP server, or shared state.

The human selected **Light TAD + YOLO autonomous completion** and explicitly accepted
reuse of the extension. The implementation may make the bounded cross-project hardening
edit described above; it must record pre/post digests because the extension directory is
not a Git repository.

## Consequences

- Positive: lowest coupling; Local Wiki stays local and stdlib-only; the browser keeps
  responsibility for authenticated DOM access.
- Positive: YouTube and rendered-page capture can evolve independently of retrieval.
- Tradeoff: capture and import are two user actions rather than continuous sync.
- Tradeoff: extension installation and YouTube UI drift remain first-use operational risks.

## Safety boundary

“Authenticated page” means content the user is authorized to view and which is already
rendered in the current DOM. This design does not discover, unlock, or bypass restricted
content. Import must not persist cookies, authorization headers, or credential-shaped
frontmatter.

## Rejected alternatives

- Copy the entire extension into TAD: duplicate vendored libraries and maintenance.
- Fetch YouTube captions directly from Local Wiki: public captions require page-specific
  player context and are prone to access/token drift.
- Add an MCP server: needless process and protocol overhead for a one-user inner loop.
