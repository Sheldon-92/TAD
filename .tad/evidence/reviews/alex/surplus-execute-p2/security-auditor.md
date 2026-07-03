# Security Audit: HANDOFF-20260702-surplus-execute-p2

**Reviewer**: security-auditor
**Date**: 2026-07-02
**Scope**: SAFETY routing completeness, blast radius, input validation, budget safety
**Verdict**: **CONDITIONAL** (2 P0, 4 P1, 2 P2 -- P0s must be resolved before implementation)

---

## P0 Findings (Blocking)

### P0-1: safety_flag Absence Is Fail-Open (CWE-754: Improper Check for Unusual Conditions)

**Location**: Handoff section 4.2A, pseudocode line `eligible = sidecar_rows.filter(r => r.auto_eligible && !r.safety_flag)`

**Description**: The filter `!r.safety_flag` evaluates `!undefined` as `true` in JavaScript. If a sidecar row is missing the `safety_flag` field entirely (due to a corrupted file, a future surplus-scan regression, or manual editing), AND has `auto_eligible: true`, it passes both guards and enters the execution loop as if it were explicitly marked safe.

**Impact**: A task that should require human review could be auto-executed. In the current sidecar all 48 rows have both fields present, but the design has no schema validation gate to guarantee this invariant holds for future sidecars.

**Proof of Concept**:
```json
{ "id": "evil-task", "auto_eligible": true, "title": "Delete all evidence files", "summary": "..." }
```
Missing `safety_flag` --> `!undefined === true` --> enters execution loop.

**Remediation**: Add an explicit fail-closed guard before the filter:
```js
// Reject any row without explicit boolean safety_flag
const validated = sidecar_rows.filter(r => {
  if (typeof r.safety_flag !== 'boolean') {
    log('SAFETY HALT: row ' + r.id + ' has non-boolean safety_flag (' + typeof r.safety_flag + ') — treating as UNSAFE')
    return false  // exclude from ALL processing, log as anomaly
  }
  return true
})
eligible = validated.filter(r => r.auto_eligible === true && r.safety_flag === false)
```
Use strict equality (`=== false`) instead of truthiness negation (`!r.safety_flag`). This also defends against edge values like `0`, `""`, `null`, which would all pass the truthiness check.

---

### P0-2: No Schema Validation of Sidecar Input Before Loop Entry (CWE-20: Improper Input Validation)

**Location**: Handoff section 4.2B step 2 ("read latest sidecar") and section 4.2A (no validation step between read and filter)

**Description**: The sidecar JSON is read from disk and passed directly to the filter/loop with zero structural validation. There is no check that:
- Every row has the required fields (`id`, `safety_flag`, `auto_eligible`, `title`, `summary`)
- Field types match expectations (`safety_flag` is boolean, `auto_eligible` is boolean, `expected_value` is number)
- The top-level structure contains `rows` as an array
- Row count matches `totals.total`

A corrupted, truncated, or manually-tampered sidecar could inject rows that bypass safety classification.

**Impact**: Combined with P0-1, a malformed sidecar causes silent fail-open behavior. Even without P0-1, a row with `auto_eligible: "yes"` (string, truthy) instead of `true` (boolean) would pass the filter since `"yes" && !false === true`.

**Remediation**: Add a validation step between sidecar read and loop entry:
```js
const REQUIRED_FIELDS = ['id', 'safety_flag', 'auto_eligible', 'title', 'summary']
const BOOLEAN_FIELDS = ['safety_flag', 'auto_eligible']

for (const row of sidecar_rows) {
  for (const f of REQUIRED_FIELDS) {
    if (!(f in row)) throw new Error('Sidecar row ' + row.id + ' missing required field: ' + f)
  }
  for (const f of BOOLEAN_FIELDS) {
    if (typeof row[f] !== 'boolean') throw new Error('Sidecar row ' + (row.id || '?') + '.' + f + ' must be boolean, got ' + typeof row[f])
  }
}
```
Fail the entire workflow on first invalid row. Do not skip-and-continue (that would silently reduce the needs_you list).

---

## P1 Findings (Should Fix)

### P1-1: No Mechanical File-Scope Constraint on yolo-epic Execution (CWE-284: Improper Access Control)

**Location**: yolo-epic.workflow.js lines 276-294 (Blake implementation agent prompt)

**Description**: The yolo-epic Blake agent receives only a prompt-level instruction to "Only modify files within the current project root." There is no mechanical enforcement of file scope. The sidecar's `target_paths` field (e.g., `["tad.sh", ".tad/hooks/lib/release-verify.sh"]`) is advisory metadata not consumed by the execution engine as a constraint.

Concretely: 8 of 12 auto_eligible tasks have `target_paths` pointing to framework infrastructure files (`tad.sh`, `.tad/hooks/lib/*.sh`, various `SKILL.md` files). The Blake agent reads the generated handoff and modifies whatever it deems necessary -- if it decides a fix to `tad.sh` also requires changing `principles.md`, nothing prevents that.

**Impact**: An auto-executed surplus task could modify TAD SAFETY entries (principles.md), SKILL constraint zones, or hook libraries. These changes would be committed in the worktree and potentially merged without targeted human review of those specific files.

**Remediation**: Option A (preferred): Pass `target_paths` from the sidecar row as an allowlist to the yolo-epic Blake agent and add a post-implementation diff check:
```
files_changed = git diff --name-only
for f in files_changed:
  if f not in task.target_paths:
    log('SCOPE VIOLATION: ' + f + ' modified but not in target_paths')
    return { error: 'scope_violation', file: f }
```
Option B (lighter): Add a DENY list of never-auto-modifiable paths to surplus-execute:
```js
const NEVER_AUTO_MODIFY = [
  'principles.md', '.tad/project-knowledge/principles.md',
  'CLAUDE.md', '.claude/settings.json', '.claude/settings.local.json'
]
```
Check against `files_changed` in the yolo-epic result.

---

### P1-2: Budget Guard Disabled When budget.total Is Null (CWE-754)

**Location**: Handoff section 4.2A, pseudocode line `if budget.total && budget.remaining() < per_task_reserve: break`

**Description**: The handoff's own Project Knowledge item #5 warns: "budget.total can be null -- if user doesn't give budget, remaining()=Infinity." The pseudocode guard short-circuits on `budget.total` being falsy, which disables the entire budget check. The loop then processes ALL eligible tasks (up to 12 in the current sidecar) with no spending limit.

**Impact**: If the user invokes `*surplus +500K` but the budget argument is lost or unparsed before reaching the workflow, or if the workflow API provides budget differently than expected, the loop runs unbounded. Twelve yolo-epic cycles could consume 1.2M+ tokens.

**Remediation**: Make budget a hard requirement for the execution workflow:
```js
if (!budget || !budget.total || typeof budget.remaining !== 'function') {
  log('SAFETY HALT: budget not available — refusing to auto-execute without budget guard')
  return { error: 'no_budget', message: 'surplus-execute requires a budget. Use *surplus +<amount>.' }
}
```
If you want to allow budget-less runs, cap at a single task maximum (execute 1, report, stop).

---

### P1-3: No Per-Task Token Ceiling (CWE-770: Allocation Without Limits)

**Location**: Handoff section 4.2A, per_task_reserve = 100000

**Description**: The budget guard checks `budget.remaining() < per_task_reserve` at loop START but does not cap how much a single yolo-epic call may consume. A single yolo-epic cycle spawns up to 6 sub-agents (design + 2 reviewers + implement + 2 impl-reviewers). In production usage, yolo-epic phases have consumed 200-500K tokens each. The 100K reserve is approximately 2-5x too small to accurately predict the cost of one full cycle.

The delta tracking (`budget.spent() delta` per the pseudocode) is reporting-only, not enforcement.

**Impact**: A task reserved at 100K could actually consume 400K, leaving the loop with negative effective budget but no circuit-breaker trip (since the check only runs at loop start). The next iteration then starts with insufficient budget and may fail mid-execution, wasting partial work.

**Remediation**: (a) Raise per_task_reserve to a realistic floor (300K based on yolo-epic's observed 6-agent structure). (b) Add a post-task overshoot check:
```js
const preSpent = budget.spent()
result = await workflow('yolo-epic', ...)
const postSpent = budget.spent()
const taskCost = postSpent - preSpent
if (taskCost > per_task_reserve * 3) {
  log('BUDGET WARNING: task ' + slug + ' consumed ' + taskCost + ' (3x reserve). Adjusting reserve.')
  per_task_reserve = Math.max(per_task_reserve, taskCost)  // adaptive reserve
}
```

---

### P1-4: Sidecar File Selection Trusts Filesystem mtime With No Integrity Check (CWE-345: Insufficient Verification of Data Authenticity)

**Location**: Handoff section 4.2B step 2, SKILL.md line 46 (`.json` sidecar is the Phase-2 contract)

**Description**: The SKILL selects the sidecar via `ls -t .tad/active/SURPLUS-PLAN-*.json | head -1`, trusting the filesystem to provide the most recent legitimate scan output. There are currently 3 JSON files in that directory (dates 2026-06-08, 2026-06-13, 2026-06-14). Any file matching the glob pattern with a newer mtime would be selected -- including a manually created or maliciously placed file.

There is no checksum, no `generated_from: surplus-scan` verification (the field exists in the JSON but is not checked), and no signature.

**Impact**: In the single-user CLI context (per principles.md "Mechanical Enforcement Rejected on Single-User CLI"), this is more of a correctness risk than an adversarial risk. The realistic scenario is: a debugging session creates a test sidecar, which then gets picked up by a real `*surplus +500K` run.

**Remediation**: Verify the `generated_from` field after parsing:
```js
if (sidecar.generated_from !== 'surplus-scan') {
  log('ERROR: sidecar was not generated by surplus-scan (found: ' + sidecar.generated_from + ')')
  return { error: 'invalid_sidecar_source' }
}
```
Also consider date-matching: if the user runs `*surplus +500K` on 2026-07-02, warn if the newest sidecar is from 2026-06-14 (18 days stale).

---

## P2 Findings (Nice to Have)

### P2-1: Report Drops 9 Rows Silently (Neither Eligible Nor Needs-You)

**Location**: Handoff section 4.2A pseudocode, needs_you filter

**Description**: The design produces two lists: `eligible = auto_eligible && !safety_flag` and `needs_you = safety_flag`. Rows where `safety_flag=false AND auto_eligible=false` (9 of 48 in current sidecar) appear in neither list and are absent from the SURPLUS-REPORT. The report template (section 4.2C) has no section for these.

**Impact**: Informational completeness only. These tasks are correctly NOT executed, but they also don't appear in the "Needs You" section, so the user has no visibility into what was skipped and why.

**Remediation**: Add a fourth section to the report: "Skipped (not auto-eligible)" listing these rows with their id and reason (e.g., "auto_eligible=false, not in scope for auto-burn").

---

### P2-2: Circuit Breaker Only Counts Consecutive Failures

**Location**: Handoff section 4.2A, "if 3 consecutive failures -> stop loop"

**Description**: The circuit breaker resets on any success. A pattern like [fail, success, fail, success, fail, success, ...] never trips the breaker despite a 50% failure rate. With 12 eligible tasks and alternating outcomes, 6 tasks would fail (wasting ~600K tokens) before the loop completes normally.

**Impact**: Token waste on a predominantly-failing task set. Not a safety issue per se, but a budget efficiency concern.

**Remediation**: Add a cumulative failure rate check: if `failed.length / (executed.length + failed.length) > 0.5 && failed.length >= 3`, trigger the breaker.

---

## Summary Table

| # | Severity | Title | Status |
|---|----------|-------|--------|
| P0-1 | P0 | safety_flag absence = fail-open | MUST FIX |
| P0-2 | P0 | No schema validation of sidecar input | MUST FIX |
| P1-1 | P1 | No mechanical file-scope constraint on yolo-epic | SHOULD FIX |
| P1-2 | P1 | Budget guard disabled when budget.total is null | SHOULD FIX |
| P1-3 | P1 | No per-task token ceiling (100K reserve vs 300-500K actual) | SHOULD FIX |
| P1-4 | P1 | Sidecar file selection trusts mtime with no integrity check | SHOULD FIX |
| P2-1 | P2 | Report drops 9 rows silently | NICE TO HAVE |
| P2-2 | P2 | Circuit breaker only counts consecutive failures | NICE TO HAVE |

---

## Overall Assessment

**CONDITIONAL** -- the design demonstrates sound safety intent (SAFETY tasks filtered before loop, circuit breaker, budget guard, worktree isolation for impl). However, two critical gaps undermine the safety guarantees:

1. The safety_flag filter uses JavaScript truthiness instead of strict boolean equality, creating a fail-open path for any row with a missing or non-boolean safety_flag.
2. The sidecar is consumed without schema validation, so the safety_flag invariant that protects the entire system has no enforcement point.

These are design-level issues that should be addressed in the handoff pseudocode before implementation, not left as "Blake will figure it out" -- because Blake implementing the pseudocode faithfully would reproduce both vulnerabilities.

The P1 findings (especially P1-1 file-scope and P1-2 null-budget) are significant for defense-in-depth but have mitigations in the current environment (single-user CLI, worktree isolation, yolo-epic's internal review gates).

**Recommendation**: Resolve P0-1 and P0-2 in the handoff pseudocode. Address P1-1 through P1-3 either in the handoff or as explicit Blake implementation instructions. P1-4 and P2s can be deferred.

---

*Reviewed by: security-auditor (Agent type: security-auditor)*
*Review scope: Handoff sections 4.2A, 9.1, 10.1 + SURPLUS-PLAN-2026-06-14.json + surplus/SKILL.md + yolo-epic.workflow.js*
