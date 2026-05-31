---
type: completion
handoff: HANDOFF-20260531-hook-hardening.md
date: 2026-05-31
gate3_verdict: pass
e2e_required: no
---

# COMPLETION: Hook Code Hardening (Debt Bundle 2/2)

**From:** Blake | **Date:** 2026-05-31
**Handoff:** HANDOFF-20260531-hook-hardening.md

## Summary

Implemented 3 hook-code fixes (bug a, b, d). bug(c) dedup was DROPPED from this handoff
(per §11 #1) — no dedup/duplicate_of/status_override code was added. No emission code
(trace-writer.sh / record_trace) was touched. No `set -e` was introduced.

## Files Changed

1. `.tad/hooks/lib/dream-scanner.sh`
   - **bug(a)** Pass C (~lines 183, 185-186): replaced fragile `fromjson | .field // "unknown"`
     with try-guarded parse `(.context | (try fromjson catch null) | .field?) // "unknown"`
     for `decision`/`chosen`/`rationale`; the `decision` guard is now
     `[ "$decision" = "unknown" ] || [ -z "$decision" ] && continue` (skips both
     unknown AND empty, closing the malformed-context junk-emit leak).
   - **bug(a)** Pass D (~lines 222, 225): same try-guard applied to `confidence`/`revised_approach`.
   - **bug(b)** `classify_scope` (~lines 109-127): added optional 3rd arg `decision_text="${3:-}"`;
     extended slug keywords to TAD-specific tokens (`*hook*|*trace*|*evolve*|*dream*|*registry*`
     in addition to existing `*capability-pack*|*skill*`); added a decision_text case matching
     ONLY TAD-specific signals (`trace schema`, `emission`, plus the two Chinese emission phrases).
     Did NOT add generic `sync`/`schema` (backend-architect P1-2). Pass C call site updated to
     `classify_scope "$file" "$slug" "$decision"`.

2. `.tad/hooks/post-write-sync.sh`
   - **bug(d)** (~line 162): REPLACED the heading-OR-cell alternation regex with heading-only
     `re="^#+[[:space:]]*P${n}-[0-9]"` (numbered-heading findings only). Rewrote the stale
     comment on ~lines 160-161 to describe heading-only behavior (label tokens paraphrased per
     self-trigger discipline).

## Layer 1 Results (per AC)

Full fixture commands + raw outputs:
`.tad/evidence/acceptance-tests/hook-hardening/fixture-results.md`

| AC | Description | Result |
|----|-------------|--------|
| AC1 | Malformed-context fixture (a decision-point AND a reflexion-diagnosis, both `context:"not-json"`) → 0 junk candidates; valid control event still emits 1; scanner exit 0 | PASS |
| AC2 | classify_scope: framework recovered via slug keyword (`trace`) AND via TAD-specific decision text | PASS |
| AC2b | classify_scope: generic `sync` / `schema` decision text → `project` (NOT framework) — proves generic-word pruning | PASS |
| AC3 | expert_finding on fixture with a numbered priority-zero heading + a pipe-delimited table cell + prose "no issues" → counts exactly 1 (heading only); colon-no-number header excluded; verified on BSD grep | PASS |
| AC4 | `bash -n` on both files exits 0; no `set -e` | PASS |

All fixtures used throwaway `/tmp` paths only; the real `.tad/evidence/traces/` was never
written to. Throwaway dirs cleaned up after the run.

## Gate 3 Verdict

**gate3_verdict: pass** — all Layer 1 ACs PASS, contract preserved (exit 0 always,
`|| true` / `2>/dev/null` on parse paths, BSD-safe POSIX-ERE regex, no `set -e`).

## ⚠️ Known Limitation — bug(b) is a PARTIAL heuristic

bug(b) is a scanner-side best-effort heuristic, NOT a full fix. **Framework scope is
NOT fully fixed.** A framework override remains UNRECOVERABLE when ALL of the following
hold simultaneously:
- the event's `file` field is empty (common — emission omits the file path), AND
- the slug carries no TAD-specific keyword, AND
- the decision text is generic (e.g. a decision titled "Persona count" with no TAD signal).

In that case classify_scope correctly falls through to `project`. The proper fix would
require the EMISSION side (`trace-writer.sh` / `record_trace` / decision_point emission) to
populate the file path or an explicit scope field — which is OUT OF SCOPE for this handoff
(architecture.md 2026-05-31). This residual class is documented here and in the handoff §10/§11
and is accepted; it is intentionally not addressed by the scanner-side heuristic.

## Escalations

None. No fix required touching emission code.

## Project Knowledge Candidate

No new parser-hardening lesson surfaced beyond what is already captured in architecture.md
("Parser Self-Trigger" 2026-05-30 and "A Parser Feeding a Review Queue Must Propagate VALUE"
2026-05-31) — bug(a)/bug(d) are direct applications of those existing entries.
