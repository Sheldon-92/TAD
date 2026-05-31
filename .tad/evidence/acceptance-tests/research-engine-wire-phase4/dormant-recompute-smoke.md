# Dormant Recompute Smoke — notebook-dormant-sync.sh (AC4.6)

**Handoff:** HANDOFF-20260531-research-engine-wire-phase4
**Date:** 2026-05-31 (threshold dormant_after_days=30, from config-workflow.yaml)
**Files under test:**
- `.tad/hooks/notebook-dormant-sync.sh` (SessionStart hook)
- `.tad/hooks/lib/notebook-lifecycle.sh` (recompute_notebook_dormancy)

All tests run on TEMP COPIES of REGISTRY — never the live file.

## Test setup

The live REGISTRY.yaml was normalized by yq during the §4.3 archive edit (mikefarah yq v4
strips blank lines + normalizes comment spacing on first touch, then is idempotent). The
recompute therefore produces byte-surgical diffs on the live file going forward. This test
copies the now-normalized live registry and injects ONE stale `last_queried`.

- Made `web-ui-design-rebuild` stale: `last_queried = 2026-02-15` (~104 days, > 30 threshold).
- Left 15 other non-archived entries recent (3-28 days, all <= 30 -> stay active).
- `ai-agent-tutorials` is archived -> must be skipped entirely.

## Recompute run

```
$ ( source .tad/hooks/lib/notebook-lifecycle.sh && recompute_notebook_dormancy "$T" ".tad/config-workflow.yaml" )
exit=0
```

## byte-diff (pre vs post recompute)

```
120c120
<     status: active
---
>     status: dormant
```

EXACTLY one line changed — the stale entry (web-ui-design-rebuild) flipped active -> dormant.
All 16 other entries byte-identical.

## YAML validity

```
$ yq -e '.notebooks' "$T" >/dev/null 2>&1 && echo VALID
VALID
```

## Archived-entry skip check

```
$ yq -r '.notebooks[] | select(.id=="ai-agent-tutorials") | .status' "$T"
archived          # untouched — recompute selects .status != "archived"
```

## Flipped entry confirmation

```
$ yq -r '.notebooks[] | select(.id=="web-ui-design-rebuild") | [.last_queried,.status] | @tsv'
2026-02-15	dormant
```

## Hook-level run (real SessionStart stdin path)

```
$ echo '{"source":"startup"}' | bash .tad/hooks/notebook-dormant-sync.sh
{}
hook-exit=0

$ echo '{"source":"resume"}' | bash .tad/hooks/notebook-dormant-sync.sh   # non-startup -> no-op
{}
hook-exit=0
```

Stdout is exactly `{}` and exit 0 in both cases. The hook never blocks, never emits a block
verdict, and on a today-run against the live registry produced no changes (all entries < 30 days)
and left the live file byte-identical (`git diff` empty after the startup run).

## Result: AC4.6 PASS

- [x] Flips EXACTLY the stale entry to dormant
- [x] Leaves the other 16 byte-identical
- [x] File stays valid YAML
- [x] Archived entry skipped
- [x] Hook exits 0, emits `{}`, non-blocking
