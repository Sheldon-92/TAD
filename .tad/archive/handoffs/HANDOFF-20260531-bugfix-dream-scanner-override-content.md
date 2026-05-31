---
task_type: code
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .tad/hooks/lib
---

# Mini-Handoff: Bugfix — dream-scanner Pass C discards override rationale
**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Type:** Express Bugfix (skip Socratic; KEEP ≥1 expert review per AR-001)
**Priority:** P2

## Bug Description
Auto-dream produced 6 "human_override" candidates (2026-05-30, slug `trace-instrumentation-fix`)
that were all empty shells — Discovery = "Human explicitly overrode agent suggestion for 'X'",
Action = "Document the override rationale for future reference". They carried the decision
*title* but no actual content, so they duplicated (worse) an existing `architecture.md` entry
and added pure noise. All 6 were rejected by Alex on review (dream-state total_rejected: 6).

## Root Cause Analysis
The `decision_point human_overridden` trace events DO contain rich content:
`context = {"decision": "...", "chosen": "...", "rationale": "..."}`.
But `dream-scanner.sh` **Pass C** (lines 179–194) reads only `.decision` and then passes
hardcoded boilerplate strings to `generate_candidate` for the Discovery and Action fields.
`.chosen` and `.rationale` are never extracted → the captured rationale is thrown away.

Passes A (`recurring_failure`, uses `$pattern`) and D (`reflexion_insight`, uses
`.revised_approach`) already weave real content in. Pass C is the only offender.

## Proposed Fix (single file: `.tad/hooks/lib/dream-scanner.sh`, Pass C)
Inside the `while IFS= read -r event_json` loop (after the existing `decision=...` /
`[ "$decision" = "unknown" ] && continue` lines), extract the two missing fields and build
content-rich Discovery/Action, falling back to the old boilerplate only when absent:

```bash
    chosen=$(echo "$event_json" | jq -r '(.context | fromjson | .chosen) // ""')
    rationale=$(echo "$event_json" | jq -r '(.context | fromjson | .rationale) // ""')
    scope=$(classify_scope "$file" "$slug")

    if [ -n "$chosen" ]; then
      disc="On '$decision', human chose: $chosen"
      [ -n "$rationale" ] && disc="$disc. Rationale: $rationale"
    else
      disc="Human explicitly overrode agent suggestion for '$decision'"
    fi
    if [ -n "$rationale" ]; then
      act="Captured rationale present — verify it is reflected in project-knowledge; reject if already documented"
    else
      act="Document the override rationale for future reference"
    fi

    generate_candidate \
      "human_override" \
      "Human override: $decision → ${chosen:-?}" \
      "$disc" \
      "$act" \
      "decision_point human_overridden slug=$slug" \
      "$scope" \
      "high"
```
Remove the two hardcoded boilerplate argument strings that previously occupied the
Discovery/Action positions. Keep `evidence`, `scope`, `confidence` args unchanged.

## Affected Files
- `.tad/hooks/lib/dream-scanner.sh` (Pass C only — lines ~179–194)

## Acceptance Criteria
- [ ] AC1: Pass C extracts `.chosen` and `.rationale` from `context | fromjson`.
- [ ] AC2: Generated candidate Discovery contains the actual `chosen` value (and `rationale` when present), NOT the old boilerplate "Human explicitly overrode agent suggestion for".
      ⚠️ AC-SELF-LEAK GUARD (code-reviewer P1-1): the test strings (`观测式为主`,
      `reflexion 唯一命令式调用只触发 1 次`) ALSO appear in `architecture.md` and the
      `trace-instrumentation-fix` COMPLETION/review files — do NOT grep the whole candidate
      dir or trace tree (false PASS risk). Verify against the SPECIFIC newly-generated CAND file:
      `grep -F '观测式为主' <new-cand-file>` returns count ≥1 AND the match is on the
      `- **Discovery**:` line. Pin the exact file path produced by the scratch run.
- [ ] AC3: Fallback path intact — when `.chosen`/`.rationale` absent, old boilerplate still emitted (no crash, no empty field).
- [ ] AC4: `bash -n .tad/hooks/lib/dream-scanner.sh` passes; BSD-safe (no GNU-only flags); script still `exit 0` always (advisory contract preserved).
- [ ] AC5: No change to Passes A/B/D, frontmatter schema, or candidate filename format.

## Test Approach (suggested)
Pass C reads `$FILTERED_TRACES`. To exercise without polluting real candidates, Blake may
copy the 6 existing 2026-05-30 `decision_point human_overridden` lines into a temp JSONL,
point a local run at it (or temporarily clear last_scan_ts in a scratch state file), and
eyeball the generated CAND content. Clean up scratch candidates after.
- To exercise the AC3 fallback branch (code-reviewer P2-1): the 6 real events all have
  populated `chosen`+`rationale`, so they only drive the true-branch. Add ONE synthetic
  scratch line with `context={"decision":"X"}` (no chosen/rationale) to confirm the `else`
  paths still emit the old boilerplate without crashing under `set -u`.

## Audit Trail (Expert Review)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P1-1: AC2 strings collide with architecture.md prose (AC Self-Leak) → false PASS risk | §AC2 AC-SELF-LEAK GUARD | Resolved |
| code-reviewer | P1-2: `file=null` → all override candidates classify as `project` even when framework-scoped | §Out of Scope (deferred) | Deferred |
| code-reviewer | P2-1: fallback branch not exercised by real data | §Test Approach (synthetic line) | Resolved |
| code-reviewer | P0 check (quoting/heredoc/set-u/arg-order/BSD) | n/a — all verified safe | Resolved (no P0) |

## Blake Instructions
- Express bugfix — no Socratic, no e2e.
- ⚠️ NOT review-exempt (AR-001): run **code-reviewer** in Layer 2 (Gate 3) — shell/jq quoting,
  BSD compat, and the fallback branch are the risk surface.
- Apply fix → Ralph Loop Layer 1 (`bash -n` + manual regenerate check) → verify AC1–5 → Gate 3 → COMPLETION.
- If the fix turns out to need touching the emission side (`post-write-sync.sh`) — it should NOT —
  STOP and escalate to Alex; that would change scope.

## Out of Scope (follow-ups, do NOT bundle)
- Dedup Pass C candidates against existing `project-knowledge` entries (deeper design — separate handoff).
- `expert_review_finding` parser heading-only tightening (different parser in post-write-sync.sh; already tracked in NEXT.md).
- Scope mis-classification (code-reviewer P1-2): `decision_point` events have `file=null`, so
  `classify_scope` falls back to slug and tags override candidates `project` even when the
  override concerns framework hooks. Pre-existing weakness, not introduced here; defer to the
  dedup handoff above (both touch Pass C scope handling).
