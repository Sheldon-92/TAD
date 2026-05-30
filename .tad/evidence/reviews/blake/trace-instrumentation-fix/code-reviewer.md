# Layer 2 Review — code-reviewer

**Handoff:** trace-instrumentation-fix
**Reviewer:** code-reviewer (narrow-scope: shell safety + parse correctness + BSD portability)
**Date:** 2026-05-30
**Verdict:** PASS (no blocking findings; 2 P2 telemetry-accuracy refinements)

## Scope
`.tad/hooks/post-write-sync.sh` (5 observational parse helpers + dedup + 4 modified case arms),
`.tad/hooks/lib/trace-writer.sh`, plus producer-side SKILL/template edits.

## Blocking dimensions — all CLEAN (no P0, no P1)
- **NFR1 never fail-closed**: no `set -e`/`set -u`; all 4 parse helpers wrapped `|| true`; verified
  malformed input (embedded `|`, CRLF, non-UTF8 bytes, short/over-long rows) → awk/grep exit 0,
  hook exit 0, valid JSON stdout, trace stays valid JSONL.
- **NFR4 injection/truncation**: `extract_slug` strips shell metacharacters via `tr -cd 'A-Za-z0-9._-'`
  + `cut -c1-100`; slug used only as `grep -F` literal and JSON string value, never a path/eval target.
  Tested `$(rm -rf foo)`, `;`, backtick, `../../etc.md` — all rejected/neutralized.
- **Trace corruption**: `grep -F` dedup patterns include trailing quote (`"slug":"x"`) → no
  `feat`/`feat-extra` collision. Greedy sed fallback only runs when HAS_JQ=false and only affects
  skip-vs-emit, never JSONL validity.
- **NFR3 BSD regex**: no `grep -P`/`.*?`/`\d`; compact `"type":"x"` membership format.
- **Case order**: traces guard → `reviews/blake/*/*.md` → `evidence/*` (first-match-wins correct).
- **Double-parse**: `reflexion_already_emitted` uses single-pass `jq '...(.context|fromjson|...)'`.

## P2 findings (telemetry accuracy only — non-blocking)

#### P2-1 — Inline `<!-- -->` on a section-header line could drop the table
Original comment-skip ran before the `/^##/` rule, so `## 11. Decision Summary <!-- TODO -->`
would be consumed and the section never opened.
**Resolution (applied):** comment-skip now guarded with `$0 !~ /^##/` in both awk blocks;
reflexion awk `/^##/` rule gained the missing `next`. Re-tested: inline-comment header → table
parsed, decision_point emitted (count=1).

#### P2-2 — P-finding count can over-count with both summary-row and per-finding headings
`grep -cE '(^#+ *P0...|\| *P0...)'` counts both a `| P0 |` summary cell and `### P0-1` headings,
and a verdict cell `| Result | P2 |` in the last column. This matches the handoff FR3 spec
("grep -cE 数行") exactly — observational count only, never affects emit/skip or JSONL validity.
**Disposition:** kept as specified (FR3 contract); documented as a known telemetry-precision limit.

## Result
Ship-able. No P0/P1. Both P2s addressed or accepted-per-spec. NFR1 never-fail-closed contract holds.
