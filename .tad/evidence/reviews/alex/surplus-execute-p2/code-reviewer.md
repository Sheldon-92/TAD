# Code Review: HANDOFF-20260702-surplus-execute-p2

**Reviewer**: code-reviewer
**Date**: 2026-07-02
**Scope**: yolo-epic args contract, budget math, circuit breaker, SAFETY guarantee, AC coverage
**Verdict**: **FAIL** (3 P0, 3 P1, 2 P2)

---

## P0 — Critical (Must Fix Before Gate 2)

### P0-1: yolo-epic args contract mismatch — entire loop will silently produce zero output

**Location**: Handoff section 4.2A line 161 vs `yolo-epic.workflow.js` lines 66-89

The handoff specifies:
```
result = await workflow('yolo-epic', { epic_context, phase_definition derived from task })
```

But yolo-epic.workflow.js (lines 66-89) parses these **exact keys**:
- `epic_path` (string, REQUIRED — file path to an Epic .md on disk)
- `epic_slug` (string, REQUIRED)
- `phase_number` (number, REQUIRED, must be >= 1)
- `phase_name` (string, REQUIRED)
- `handoff_path` (string, REQUIRED — where design agent WRITES the handoff)
- `completion_path` (string, REQUIRED — where Blake WRITES the completion report)
- `steps` (array of strings from `['design', 'review', 'implement', 'impl_review']`, REQUIRED)
- `grounding_path` (optional)
- `reviewer_count` (optional, default 2)

If any required key is missing, yolo-epic returns `{ error: 'missing required args' }` at line 85-88. The handoff's `{ epic_context, phase_definition }` matches zero required keys. Every loop iteration will get the missing-args error return.

**Fix required**: Section 4.2A must specify the exact args object with all 7 required keys and how each is derived from a sidecar row. For example:
```js
{
  epic_path: task.target_paths[0] || synthesized_epic_path,
  epic_slug: task.id,
  phase_number: 1,
  phase_name: task.title,
  handoff_path: '.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md',
  completion_path: '.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md',
  steps: ['design', 'review', 'implement', 'impl_review']
}
```

### P0-2: yolo-epic returns error objects — never throws — try/catch is dead code

**Location**: Handoff section 4.2A pseudocode lines 158-166 vs `yolo-epic.workflow.js` lines 85-100, 164-170, 243-248, 261-265

The handoff designs the error path as:
```
try:
  result = await workflow('yolo-epic', { ... })
  results.executed.push(...)
catch:
  results.failed.push(...)
```

But yolo-epic **never throws**. Every failure mode is a normal `return`:
- Missing args: `return { error: 'missing required args' }` (line 85)
- Invalid steps: `return { error: 'steps required' }` (line 94)
- Design circuit breaker: `return { error: 'design_circuit_breaker' }` (line 164)
- Review circuit breaker: `return { error: 'review_circuit_breaker' }` (line 243)
- P0 stop: `return result` with `result.stop_reason` set (line 265)
- Impl failure: `return result` with `result.implementation.error` set (line 306)
- All reviewers failed: `return result` with `result.stop_reason = 'all_reviewers_failed'` (line 386)

**Consequence**: Every yolo-epic failure will be caught by the `try` (success) branch and pushed to `results.executed`. The `catch` never triggers. The circuit breaker counter never increments. Failed tasks are recorded as successes. The report is wrong.

**Fix required**: Replace `try/catch` with result inspection:
```
result = await workflow('yolo-epic', { ... })
if (result.error || result.stop_reason || (result.implementation && result.implementation.error)) {
  results.failed.push({ slug, error: result.error || result.stop_reason, ... })
  consecutiveFailures++
} else {
  results.executed.push({ slug, result_summary, ... })
  consecutiveFailures = 0  // reset on success
}
```

### P0-3: Epic file derivation is unspecified — sidecar rows are not Epics

**Location**: Handoff section 4.2A line 161: "epic_context, phase_definition derived from task"

yolo-epic requires `epic_path` — a file path to an existing Epic document on disk that it READs at line 126: `'Read the Epic: ' + epicPath + ' — find Phase N Detail Block'`.

Sidecar rows have `source` values like `"next"`, `"ideas"`, `"epics-parked"` — these are free-form backlog items. Most do NOT have a corresponding Epic file. For example, sidecar row `id: "publish-sync-pack-quality-upgrades"` (source: "next") has no Epic file — it is a NEXT.md item.

**The handoff must answer**: Does surplus-execute need to:
(a) CREATE an ephemeral Epic file per task (from the sidecar row's `summary` + `deliverable` fields), then pass its path as `epic_path`?
(b) Only run tasks that already have an Epic file on disk (filter further)?
(c) Modify yolo-epic to accept inline context instead of a file path (violates "do not modify yolo-epic" constraint)?

Option (a) seems most viable but requires explicit specification. The synthesized Epic needs enough structure for yolo-epic's design agent to produce a handoff from it.

---

## P1 — Important (Should Fix)

### P1-1: Circuit breaker consecutive-failure counter has no reset on success

**Location**: Handoff section 4.2A line 167

The pseudocode says `circuit_breaker: if 3 consecutive failures -> stop loop` but the counter logic is not shown inline. The word "consecutive" implies reset on success, but without explicit pseudocode, Blake may implement it as cumulative (3 total failures = stop, even if successes occurred between them).

**Fix**: Add explicit counter logic to the pseudocode:
```
consecutive_failures = 0
for each task in eligible:
  ...
  if (failed):
    consecutive_failures++
    if consecutive_failures >= 3: break  // circuit breaker
  else:
    consecutive_failures = 0  // RESET on success
```

### P1-2: per_task_reserve = 100K is likely too low for a full yolo-epic cycle

**Location**: Handoff section 4.2A line 155

A full yolo-epic run spawns at minimum 6 agents:
- 1 design agent (reads Epic + template, writes handoff)
- 2 review agents (reads handoff, writes review)
- 1 implement agent (reads handoff, writes code + completion)
- 2 impl_review agents (reads completion, writes review)

Each agent performing real file I/O and code generation consumes 15-40K tokens typically. Estimated total: 120-250K per full yolo-epic run.

With `per_task_reserve = 100K`, the loop will start tasks that cannot finish within budget. Per Workflow tool docs, "child shares this run's token budget" — when budget is exhausted mid-execution, agents are aborted, wasting all tokens spent so far on that task.

**Fix**: Either (a) increase `per_task_reserve` to 250K (conservative) or (b) make it configurable as an arg to surplus-execute, with 200K as default. Add a comment documenting the rationale.

### P1-3: AC2 SAFETY check is self-referential — no source-code-level guarantee

**Location**: Handoff section 9.1 AC2

AC2 verifies SAFETY by grepping the REPORT for `safety_flag.*true` in the needs-you section. But the report is authored by the same workflow — if the filter code is buggy (or the report rendering omits safety rows), AC2 passes while SAFETY tasks were actually executed.

The real guarantee is the code-level filter: `sidecar_rows.filter(r => r.auto_eligible && !r.safety_flag)`. There is no AC that greps the workflow SOURCE CODE for this filter.

**Fix**: Add AC (e.g., AC2b):
```
| AC2b | SAFETY filter in code | post-impl | grep -c 'safety_flag' .claude/workflows/surplus-execute.workflow.js | >= 1 |
```
This ensures the filter EXISTS in the source, independent of what the report says.

---

## P2 — Suggestions (Consider)

### P2-1: `steps` array not specified in yolo-epic call

**Location**: Handoff section 4.2A

yolo-epic requires a `steps` array. The handoff doesn't specify what to pass. Two conventions exist:
- All-at-once: `['design', 'review', 'implement', 'impl_review']` (4 steps, 1 call)
- Split: First call `['design']`, then `['review', 'implement', 'impl_review']` (2 calls per task)

The all-at-once approach is simpler for surplus but means if review finds P0s, yolo-epic stops and reports it — surplus-execute must handle this `stop_reason: 'design review found N P0(s)'` intermediate state.

**Recommendation**: Use all-at-once (`steps: ['design', 'review', 'implement', 'impl_review']`) and handle `stop_reason` as a specific failure type in the result inspection (distinct from hard errors).

### P2-2: `budget.total` null guard is correct but confusing

**Location**: Handoff section 4.2A line 159

`if budget.total && budget.remaining() < per_task_reserve: break` — when `budget.total` is null, `remaining()` returns Infinity per the docs, so the condition is `null && ...` which short-circuits to false (no break). Correct behavior, but the guard reads as if it protects against a crash when it actually protects against breaking on infinite remaining. A comment clarifying this would help.

---

## Positive Observations

- The SAFETY-first design (filter BEFORE the loop, not inside) is correct by construction — safety_flag rows never enter the eligible list.
- `safety_flag` in the JSON sidecar is a proper boolean (`true`/`false`), not a string. The `!r.safety_flag` filter works correctly. No type coercion risk.
- The "do not modify yolo-epic / surplus-scan" constraint is sound engineering — avoids regression on calibrated tools.
- The Friction Preflight table (section 8.4) correctly identifies the `budget.total` null risk.
- AC8 (`git diff` on yolo-epic = 0 lines) is a smart guard against accidental modification.

---

## Summary

Three P0s must be fixed before Gate 2 can pass. P0-1 and P0-2 together guarantee that the current design produces a workflow where every task silently fails (missing args) and every failure is recorded as a success (return-not-throw). P0-3 is an architectural gap: sidecar rows are not Epic files, and yolo-epic requires Epic files. All three are fixable without changing yolo-epic, but the handoff must specify the exact args derivation, the result-inspection error handling, and the Epic file synthesis strategy.
