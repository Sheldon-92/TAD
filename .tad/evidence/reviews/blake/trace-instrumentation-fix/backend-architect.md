# Layer 2 Review — backend-architect

**Handoff:** trace-instrumentation-fix
**Reviewer:** backend-architect (narrow-scope: hook output contract + consumer compatibility + schema integrity)
**Date:** 2026-05-30
**Verdict:** PASS after P1 resolution (1 P1 found + fixed + re-confirmed; 2 P2 non-blocking)

## Scope
Emitter side (`post-write-sync.sh`, `trace-writer.sh`) vs consumer side
(`dream-scanner.sh` Pass A/B/C/D, `alex/SKILL.md` analyzer step6/step8/step9).

## P1 — JSON-context truncation breaking fromjson  [RESOLVED]

#### P1-1 — decision_point/reflexion JSON `context` truncated to 200 chars → invalid JSON
`record_trace` truncates `context` to 200 chars at `detail_level=summary`. `trace_decision_point`
set `TRACE_OUTCOME=chosen` (not fail/error), so no auto-escalation → 200 budget. But
`emit_decision_points` caps each of decision/chosen/rationale at 200 individually, so the
assembled JSON object can exceed 200 → sliced mid-string → `jq '.context|fromjson|.decision'`
errors in dream-scanner Pass C / analyzer step8, yielding an empty-title candidate.
Latent (max real decision context ~85 chars), not yet firing.

**Resolution (applied + re-confirmed):** `trace_decision_point` and `trace_reflexion_diagnosis`
now set `TRACE_DETAIL="full"` (2048 budget). With each field capped at 200, assembled JSON
≤ ~640 (decision) / ~840 (reflexion) << 2048 — no mid-string slice for any realistic input.
Regression test: a ~250-char-context decision_point now emits `detail_level":"full"`, full
context JSON intact, `jq '.context|fromjson|.decision'` exit 0, dream-scanner exit 0, all JSONL valid.
Consumer-side `try/catch` hardening deferred as out-of-scope follow-up (dream-scanner is a
read-only consumer per handoff §2.3); source-side fix fully covers the realistic input range.

## P2 findings (non-blocking)

#### P2-1 — override marker only scanned in Rationale column
`emit_decision_points` matched override markers (用户选 etc.) only against `$r` (rationale),
missing a marker placed in the Chosen cell.
**Resolution (applied):** now scans `"$c $r"` (Chosen + Rationale). Re-tested: marker in Chosen
column → `actor_tag":"human_overridden"`.

#### P2-2 — handoff_created re-emits across day boundaries
Per-(slug,type,day) dedup is by design (Decision 7). Raw per-type counts over-count long-running
handoffs; analyzer normalizes to unique slugs so health metrics are immune. Cosmetic — accepted.

## Confirmed CLEAN (5 contract questions)
- (a) Field-shape: outcome (top-level), slug, agent, actor_tag, context all match consumer reads.
- (b) `"Gate 3: Gate 3"` context → analyzer extracts gate number; N=0 guard prevents Gate 2/4 false-0%.
- (c) step9 sum-integer-from-context consistent with one-event-per-priority emission; old `outcome=fail`
      events excluded by `.outcome=="P0"` selector.
- (d) No permanent suppression; dedup resets per-day; substring slug collision impossible (quoted grep -F).
- (e) decision_point dedup is INDEPENDENT (not gated on handoff_created) → §11-added-later case still emits.

## Result
Ship-able after the applied P1 + P2 fixes. Emitter/consumer contract intact; no schema change.
