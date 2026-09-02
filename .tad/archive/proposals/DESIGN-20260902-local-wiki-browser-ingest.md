# SUPERSEDED Design — Local Wiki Phase 3 Browser Ingest Bridge

> Runtime dependency rejected by Human on 2026-09-02. Kept only as audit history;
> replaced by `DESIGN-20260902-local-wiki-native-capture.md`.

## User flow

1. In Chrome, use the existing extension to download a Markdown article or YouTube transcript.
2. Run `python3 research/scripts/import-clip.py ~/Downloads/file.md`.
3. The command prints the created repository-relative raw path.
4. Search it with `python3 research/scripts/search.py query "..." --scope raw`.

## Components

### Local Wiki importer

`research/scripts/import-clip.py` is a stdlib CLI. It accepts one `.md` input and optional
`--repo-root`, `--dry-run`, and `--out`. It opens input with no-follow semantics and validates
the opened descriptor. Output is deliberately restricted to a direct `.md` child of either
`research/raw/articles/` or `research/raw/transcripts/`; directory descriptors and exclusive
same-directory temporary creation prevent symlink/overwrite races. A fully written and
synced temp is published with a non-replacing hard link, so readers see either no file or a
complete file. It maps extension metadata through a closed allowlist.

The accepted input grammar is the extension's actual small subset, not general YAML:
unique top-level keys; quoted one-line string scalars, `null`, and bounded lists of quoted
strings. Unsupported keys, tags, anchors, aliases, block scalars, duplicate keys, and control
characters are rejected.

YouTube URLs or timestamped transcript bodies route to `raw/transcripts` with
`source_type: youtube_transcript`; other HTTPS pages route to `raw/articles` with
`source_type: rendered_page_export`. This records transport provenance without claiming
that authorization was independently verified.

### Extension hardening

The existing popup interception gets one active capture per document and an idempotent
settle/cleanup path. URL
matching must parse the URL and accept only HTTPS `youtube.com`/`www.youtube.com` with the
exact `/api/timedtext` path. Captured responses are rejected before messaging when over the
existing 5 MiB bound. Cleanup retains timer/listener handles and restores globals only if
they are still this invocation's wrappers. Re-entry fails clearly. Player pause behavior
must not be broadened.

### Evidence

Focused importer unit/CLI tests cover positive mapping, timestamps/search, collision,
dry-run, malformed input, traversal, symlink, size, unsafe URL, and secret metadata.
Extension tests add deterministic interception-helper coverage. Existing regression suites
run once. A public YouTube smoke test is attempted with bounded time; inability caused by
YouTube/browser environment is recorded as experimental degradation, not product failure.

## Data flow

`rendered browser DOM/player → extension Markdown download → import-clip.py validation →
research/raw/{transcripts|articles}/unique.md → existing search.py`

## Rollback

Delete the TAD feature commit and restore the external popup from the immutable pre-change
backup plus reverse patch recorded in task evidence. Imported raw files are never deleted
automatically.
