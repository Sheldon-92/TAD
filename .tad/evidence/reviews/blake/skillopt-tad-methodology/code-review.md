# Code Review: HANDOFF-20260616-skillopt-tad-methodology

**Reviewer**: code-reviewer
**Date**: 2026-06-17
**Scope**: pack-upgrade.workflow.js, pack-dogfood.workflow.js, spike.py

---

## P0 (Blocking)

### P0-1: Regression stage compares CURRENT pack answer vs PREVIOUS judgment's "winning answer" -- but the baseline (.prev.md) is a JUDGE REPORT, not a raw answer

**File**: `.claude/workflows/pack-dogfood.workflow.js` L142-157

The Regression stage prompt says:

> "6. Compare your answer against the PREVIOUS judgment's winning answer."

But `dogfood-{pack}.prev.md` is the **judge's full judgment report** (rubric scores, rationale, wrong_claims analysis), not the raw winning answer text. The regression agent must:
1. Parse the judgment report to find which answer won (Answer 1 or Answer 2)
2. Extract that answer's text from the report

However, the judge report written by Stage 4 (`Write full judgment to ${EV}/dogfood-${pack}.md`) is an **unstructured markdown analysis** -- the raw answer texts may or may not be quoted in full. The regression agent is told to "compare your answer against the PREVIOUS judgment's winning answer" but has no reliable way to extract the winning answer's content from an unstructured judgment file.

**Impact**: The regression agent may hallucinate what the "winning answer" contained, or compare against the judge's rationale text rather than the actual answer, producing meaningless regression verdicts.

**Fix options**:
- (a) Persist the winning answer separately (e.g., `${EV}/baseline-${pack}.answer.md`) alongside the judgment file
- (b) Change the regression prompt to specify: "The .prev.md file is a JUDGE REPORT. Look for the quoted answer text marked as the winner, extract its content, then compare"
- (c) Persist the full pipeline output (both answers + winner identity) in a structured JSON sidecar

---

## P1 (Should Fix)

### P1-1: `judged.task` string interpolation in template literal creates injection risk

**File**: `.claude/workflows/pack-dogfood.workflow.js` L149

```js
`   Fallback: use this task text: "${judged.task || '(unavailable)'}"\n` +
```

The `judged.task` value is a free-form string extracted from pack fixtures. If the task text contains double-quotes or backticks, it will break the prompt structure or cause JS template literal injection. While this is a fallback path (the primary path reads from the fixture file), it should still be sanitized.

**Fix**: Escape quotes in the interpolation, or move the fallback task to a separate file write rather than inline in the prompt.

### P1-2: Snapshot loop is sequential (await in for-loop), not parallelized

**File**: `.claude/workflows/pack-dogfood.workflow.js` L86-93

```js
for (let i = 0; i < packs.length; i++) {
  // ...
  await agent(...)
}
```

Each snapshot agent call is awaited sequentially. For N packs, this is N serial agent invocations for what is a trivial file copy operation. The handoff design (section 4.2.1) uses the same pattern, so the implementation matches the spec. However, this could be parallelized with `Promise.all` or the workflow's `parallel()` API since snapshots are independent.

**Impact**: Performance -- adds N serial agent roundtrips before the pipeline even starts. For 10+ packs this is measurable.

### P1-3: Fixture persist stage uses an agent for a file write -- overkill and fragile

**File**: `.claude/workflows/pack-dogfood.workflow.js` L105-112

The handoff's expert review (section 4.2.2) specifically called out that fixture persistence should NOT be delegated to an agent as a side-effect, and redesigned it as a "dedicated persist stage." The implementation does create a dedicated stage, but it still uses `agent()` to write a file. The Workflow API likely has a `Bash` or direct file-write capability that would be more reliable and faster than spawning a full agent just to write a text file.

That said, this matches the handoff's design verbatim, so it's spec-compliant. Flagging as P1 because agent-based file writes are less deterministic than direct writes.

### P1-4: The `old prompt "Edit ONLY files under"` line was correctly removed, but the replacement lost the concurrency safety note

**File**: `.claude/workflows/pack-upgrade.workflow.js` L266 (diff)

The old prompt included: `Edit ONLY files under .claude/skills/${p.name}/ (disjoint from other packs -- safe concurrent)`. The "safe concurrent" annotation was useful for the pipeline's parallel execution model. The new bounded-edit prompt does say "Do NOT rewrite files that have no edits" which implicitly preserves the scoping, but the explicit concurrency safety note is gone.

**Impact**: Minor -- the `STEP 1: Read the CURRENT .claude/skills/${p.name}/SKILL.md` implicitly scopes to the right directory. But if a future change adds cross-pack references, the explicit "disjoint from other packs" guardrail is no longer stated.

---

## P2 (Suggestion)

### P2-1: UPGRADE_SCHEMA edit_list items lack `enum` constraint on `op` field

**File**: `.claude/workflows/pack-upgrade.workflow.js` L134

```js
properties: { op: { type: 'string' }, ...
```

The prompt defines exactly 3 valid operations: `add_rule`, `modify_rule`, `delete_rule`. But the schema's `op` field is unconstrained `type: 'string'`. Adding `enum: ['add_rule', 'modify_rule', 'delete_rule']` would ensure the agent produces valid operations and catch typos/hallucinated ops.

### P2-2: spike.py pack name extraction tries 4 different field paths but none are verified against live data

**File**: `.tad/evidence/spikes/pack-evolve-spike/spike.py` L60-62

```python
pack_name = (ev.get("domain") or ev.get("context", {}).get("pack")
             or ev.get("pack") or ev.get("slug", ""))
```

The spike correctly finds 41 `domain_pack_created` events (report shows pack names extracted), so at least one of these paths works. However, 46 `domain_pack_step` events are also present but the report only shows ~41 pack mentions total, suggesting some events may not have extractable pack names. The spike could log which extraction path succeeded to help future development.

### P2-3: spike.py co-occurrence analysis uses date-level granularity, which is too coarse

**File**: `.tad/evidence/spikes/pack-evolve-spike/spike.py` L66-75

Co-occurrence is measured by "same day" (date extracted from filename). A day with 100 unrelated events will show co-occurrence even if the pack event and outcome event are hours apart and unrelated. For a spike this is acceptable, but the feasibility assessment ("SIGNAL PRESENT") may be overly optimistic.

### P2-4: Regression stage re-answers the task from scratch (step 5) -- expensive

**File**: `.claude/workflows/pack-dogfood.workflow.js` L153

> "5. Answer the task using the CURRENT pack rules."

The regression agent generates a fresh answer to the task using the current pack, then compares it against the previous baseline's winning answer. But Stage 3 + Stage 4 of the CURRENT run already produced a with-pack answer. The regression stage could compare the current run's with-pack answer against the previous baseline instead of re-answering from scratch, saving one full agent generation.

The counter-argument is that the regression agent's fresh answer is "clean" (not contaminated by judge feedback), but the with-pack answer from Stage 3 was also generated before the judge ran. This is a pure efficiency concern.

### P2-5: Snapshot phase uses `phase('Snapshot')` outside the pipeline, then pipeline stages use `phase` inside options

**File**: `.claude/workflows/pack-dogfood.workflow.js` L85 vs L102, L109, etc.

The `phase('Snapshot')` call at L85 sets the workflow phase before the pipeline starts. But each stage callback in the pipeline also passes `phase: 'Task'`, `phase: 'Answers'`, etc. in its options. This is consistent with the existing workflow convention and works fine, but the Snapshot phase is the only one not inside the pipeline -- it's a pre-pipeline loop. This architectural difference is worth noting but not a problem.

---

## Positive Observations

1. **pack-upgrade changes are surgical**: Only the Upgrade stage prompt and UPGRADE_SCHEMA were modified. Plan, Eval, and Review stages are untouched (verified via `git diff --stat`).

2. **Spike event types match live traces**: The spike correctly uses `domain_pack_step`, `domain_pack_created`, `gate_result`, `tool_call_outcome`, `task_completed`, `reflexion_diagnosis`, `expert_review_finding` -- all verified present in the live trace data (386 events across 48 files).

3. **Spike runs successfully**: `python3 spike.py` executes without errors, produces a meaningful report, and correctly identifies signal presence.

4. **task threading through Judge .then()** is correctly implemented at L141: `task: b.task` is added to the returned object.

5. **REGRESSION_SCHEMA** correctly has `regression_found` (boolean) and `lost_knowledge` (array) as required fields, with an optional `analysis` string.

6. **Return value** correctly adds `packs_with_regression` and per-row `regression` data.

---

## Summary

| Severity | Count | Blocking? |
|----------|-------|-----------|
| P0 | 1 | Yes -- regression stage may not reliably extract the "winning answer" from an unstructured judge report |
| P1 | 4 | No, but should fix before production use |
| P2 | 5 | No |

**Recommendation**: Fix P0-1 before accepting. The regression stage's entire value proposition depends on comparing the current pack's answer against a reliable baseline, but the baseline source (unstructured judge markdown) does not guarantee the winning answer is extractable.
