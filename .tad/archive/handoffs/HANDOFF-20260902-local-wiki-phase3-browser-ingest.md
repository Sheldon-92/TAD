---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: ["research/scripts", "research/tests"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff — Local Wiki Phase 3 Browser Ingest Bridge

**From:** Alex
**To:** Blake implementation worker
**Date:** 2026-09-02
**Task ID:** TASK-20260902-LOCAL-WIKI-P3-BROWSER-INGEST
**Epic:** `.tad/active/epics/EPIC-20260902-local-wiki-browser-ingest.md` (Phase 3/3)
**Decision:** `.tad/decisions/DR-20260902-local-wiki-browser-ingest-bridge.md`

## Gate 2 — Design completeness

| Check | Status | Evidence |
|---|---|---|
| Architecture | PASS | Markdown boundary in design/DR |
| Components | PASS | importer, tests, bounded popup hardening |
| Functions grounded | PASS | Phase grounding lists current call sites |
| Data flow | PASS | browser → file → raw → existing search |

**Gate 2 result: PASS.** Two independent reviews found P0=0. Their P1 findings were
integrated into §§3–6 before implementation.

## 1. Outcome and intent

Build the smallest bridge that turns Markdown already captured by the user's browser into
a safe, searchable Local Wiki raw source. Reuse the existing extension; do not recreate
its Readability/Turndown/YouTube parser stack.

This is not media downloading, transcription, paywall bypass, MCP, vector search, or sync.
Browser capture is limited to content already rendered for an authorized user.

## 2. Required reading

- `.tad/active/epics/EPIC-20260902-local-wiki-browser-ingest.md`
- `.tad/active/designs/DESIGN-20260902-local-wiki-browser-ingest.md`
- `.tad/evidence/yolo/local-wiki-browser-ingest/phase3-grounding.md`
- `.tad/project-knowledge/principles.md`
- `.tad/project-knowledge/patterns/ac-verification.md`
- `research/CLAUDE.md`
- `research/canon/README.md`

## 3. Files and ownership

Create in TAD:

- `research/scripts/import-clip.py`
- `research/tests/test_import_clip.py`
- `research/fixtures/browser-clips/` with minimal synthetic article/transcript fixtures
- `research/README.md` or the smallest existing user-facing guide location

Modify only if needed:

- `research/CLAUDE.md`
- `research/canon/README.md`
- `NEXT.md`

Bounded external edit explicitly authorized by Human:

- `/Users/sheldonzhao/01-on progress programs/下载md插件/web-to-markdown/popup/popup.js`
- matching focused test(s) under that extension's `tests/`
- `/Users/sheldonzhao/01-on progress programs/下载md插件/web-to-markdown/tests/run.js`

The external directory is not Git-backed. Before editing, save an immutable byte-for-byte
`popup.js.before` evidence copy with its SHA-256. Record the post digest, a forward unified
patch, and a reverse patch; prove the backup digest equals the pre digest.
Do not edit vendored libraries, manifests, service worker, or content extractor unless a
test proves it is required; escalate rather than expand.

## 4. Import contract

- CLI: `python3 research/scripts/import-clip.py INPUT.md [--repo-root ROOT] [--out research/raw/...md] [--dry-run]`.
- Input: open with `O_NOFOLLOW`, validate the opened descriptor is regular and at most 5 MiB,
  then read UTF-8 Markdown with closed, bounded `---` frontmatter and non-empty body.
- Required source fields: non-empty `title`, HTTPS `source_url`, parseable `saved_at` date/time.
- Output frontmatter: `original_url`, `source_type`, `medium`, `slug`, `fetched_on`, `title`,
  plus safe provenance fields such as `summary`, `keywords`, `channel`, and
  `subtitle_language` when present.
- Input keys are closed to `title`, `source_url`, `saved_at`, `summary`, `keywords`,
  `channel`, and `subtitle_language`. Reject every other key, duplicate key, YAML tag/anchor/
  alias/block scalar, control/newline injection, or unsupported scalar/list form.
- Output is a direct `.md` child of only `research/raw/articles/` or
  `research/raw/transcripts/`; reject all other `--out` shapes.
- Default destination: YouTube/timestamp transcript → `research/raw/transcripts`; otherwise
  → `research/raw/articles`. Open the fixed root/medium directories via no-follow directory
  descriptors. Create a private same-directory temp with `O_CREAT|O_EXCL|O_NOFOLLOW`, write
  and `fsync`, then publish with a non-replacing `link(temp, candidate)` loop. Retry suffixes
  only on `FileExistsError`; unlink the temp in all terminal paths. Never overwrites.
- Preserve Markdown body content and timestamp anchors.
- Stdlib only; do not add a dependency.

## 5. Extension hardening contract

- Replace substring timed-text matching with parsed URL validation: HTTPS, hostname exactly
  `youtube.com` or `www.youtube.com`, pathname exactly `/api/timedtext`.
- Permit one active capture per tab/document; reject overlapping re-entry.
- Restore `window.fetch`, `XMLHttpRequest.prototype.open`, and `.send` on success, timeout,
  player-not-found, thrown error, and response rejection.
- Cap captured response text at 5 MiB before returning it from MAIN world.
- Keep the timeout bounded; use one idempotent `settle()` that retains and removes timer and
  listener handles. Restore a global only if it still equals this invocation's wrapper.
- No cookies, headers, page storage, or subtitle URL are logged or persisted.

## 6. Acceptance criteria

| ID | Criterion | Verification |
|---|---|---|
| AC1 | Article fixture imports to `raw/articles` with normalized safe frontmatter and preserved body | focused unittest + CLI assertion |
| AC2 | YouTube fixture imports to `raw/transcripts`, keeps timestamp anchors, and is found by `search.py --scope raw` | focused E2E test |
| AC3 | Invalid UTF-8/frontmatter/URL, >5 MiB, symlink input, traversal/outside output, secret fields fail closed without creating output | negative tests |
| AC4 | Existing destination is not overwritten; collision publication yields complete unique files and no temp residue | focused concurrent tests |
| AC5 | Popup interception accepts only exact trusted timed-text URLs, caps response, rejects re-entry, and restores owned patches on success/player-missing/throw/timeout/rejection/oversize | deterministic JS test registered in `tests/run.js` |
| AC6 | Existing Local Wiki retrieval tests, lint, idempotent generation, and extension npm tests pass | regression commands |
| AC7 | User guide documents the two-step workflow, authorization boundary, and first-use degradation | doc inspection |
| AC8 | One bounded public YouTube smoke probe is attempted; PASS is evidence, environmental/UI failure is recorded as `experimental_degraded` and does not invalidate AC1–AC7 | evidence report |

## 7. Commands

```bash
python3 -m unittest -v research.tests.test_import_clip research.tests.test_search
bash research/canon/lint.sh
diff <(python3 research/scripts/generate.py --emit all) <(python3 research/scripts/generate.py --emit all)
npm test --prefix '/Users/sheldonzhao/01-on progress programs/下载md插件/web-to-markdown'
```

## 8. Required evidence manifest

- Completion report with per-AC table and exact commands/results.
- Importer fixture/test outputs.
- External pre/post digests and unified patch.
- Live smoke disposition (`pass` or `experimental_degraded`) with reason; never claim a
  deterministic fixture is a live YouTube success.
- Independent code and security review reports with P0/P1/P2 counts.

## 9. Boundaries and retries

- Max three implementation/test repair loops.
- Do not broaden scope to browser automation infrastructure when the smoke probe fails.
- Do not delete imported user files or alter current corpus samples.
- Preserve unrelated worktree changes; other agents may be working in the repository.
- Stop with honest partial only for a real P0 or inability to satisfy AC1–AC7.

## 10. Grounded against

- `research/scripts/ingest.sh` existing URL-only placeholder path.
- `research/scripts/search.py` current raw discovery and symlink containment.
- External `popup/popup.js` current `handleYouTubeDownload` interception block.
- External `content/youtube-subtitle.js` existing 5 MiB/event caps and timestamp format.
- External `background/service-worker.js` current frontmatter schema.
