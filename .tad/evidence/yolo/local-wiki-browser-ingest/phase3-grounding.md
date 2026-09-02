# Phase 3 Grounding — Browser Ingest Bridge

## Files inspected

- `research/scripts/ingest.sh`: URL detector and placeholder writer; not suitable for a
  local exported Markdown file and must remain backward compatible.
- `research/scripts/search.py`: discovers regular Markdown below `research/`, rejects
  symlinks, and indexes `raw` files without a persisted database.
- `research/CLAUDE.md` and `research/canon/README.md`: raw is file truth; timestamp is a
  valid exact locator; raw sources are immutable after ingest.
- External `web-to-markdown/background/service-worker.js`: writes `title`, `source_url`,
  `saved_at`, `summary`, `keywords`, and optional safe extras.
- External `web-to-markdown/content/youtube-subtitle.js`: emits transcript body with
  `**[MM:SS]**` timestamp anchors and YouTube URL metadata.
- External `web-to-markdown/popup/popup.js`: captures timed-text via temporary fetch/XHR
  monkeypatches, but restoration is not unconditional and matching uses broad substring logic.

## Existing conventions

- Local Wiki raw files use `original_url`, `source_type`, `medium`, `slug`, `fetched_on`,
  and `title` frontmatter.
- Python code is stdlib-only and exposes concise `SearchError`-style failures.
- Raw destination paths are repository-relative and must remain within `research/raw/`.
- Existing retrieval is read-only and automatically sees newly imported Markdown.

## Design implications

- Add a separate import command; do not overload URL-only `ingest.sh`.
- Parse only the small top-level frontmatter subset needed from the extension. Do not add
  a YAML dependency.
- Preserve the body bytes/text apart from newline normalization; metadata normalization
  belongs at the boundary.
- Use resolved-path containment and reject symlink inputs/destinations.
- Do not make a live YouTube UI probe a release blocker for the deterministic bridge.

