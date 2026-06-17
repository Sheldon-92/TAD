# Spec Compliance Review: HANDOFF-20260616-skillopt-tad-methodology

**Reviewer**: Spec-Compliance-Reviewer (Blake sub-agent)
**Date**: 2026-06-17
**Handoff**: `.tad/active/handoffs/HANDOFF-20260616-skillopt-tad-methodology.md`

---

## Summary

| Verdict | Count |
|---------|-------|
| SATISFIED | 15 |
| PARTIALLY_SATISFIED | 0 |
| NOT_SATISFIED | 0 |

**Overall**: ALL 15 ACs SATISFIED.

---

## AC-by-AC Verification

### AC1: pack-upgrade Upgrade stage prompt starts with "BOUNDED EDIT mode", retains JSON.stringify(plan) + research-honoring rules

**Status**: SATISFIED

**Evidence** (pack-upgrade.workflow.js L265-289):

The Upgrade stage prompt opens with:
```js
`Apply this upgrade plan to capability pack "${p.name}" using BOUNDED EDIT mode.\n\n` +
`STEP 1: Read the CURRENT .claude/skills/${p.name}/SKILL.md and all references/*.md files.\n` +
`STEP 2: For each change in the plan, generate a structured edit:\n` +
...
```

The existing body is preserved verbatim after the bounded-edit block:
```js
`The plan was produced from a DEEP-RESEARCH report (research-engine). HONOR THE RESEARCH...`
`PLAN (each layerB_additions entry carries its source_url + retrieval date):\n${JSON.stringify(plan, null, 2)}\n\n`
`REQUIREMENTS (read ${QB} for exact criteria):\n...`
`RESEARCH-HONORING RULES (calibrated honesty > false precision -- MANDATORY):\n...`
```

All three required elements (bounded-edit block, plan JSON, research-honoring rules) are present.

---

### AC2: UPGRADE_SCHEMA.required includes 'edit_list', properties includes edit_list array schema

**Status**: SATISFIED

**Evidence** (pack-upgrade.workflow.js L126-137):

```js
required: ['pack', 'files_changed', 'body_lines_after', 'fixture_written', 'summary', 'edit_list'],
```

Properties include:
```js
edit_list: { type: 'array', items: { type: 'object', required: ['op', 'file', 'content'],
  properties: { op: { type: 'string' }, file: { type: 'string' }, rule_id: { type: 'string' },
  content: { type: 'string' }, rationale: { type: 'string' } } } },
```

Both `required` and `properties` contain `edit_list` with the correct array-of-objects schema.

---

### AC3: Prompt includes full-rewrite escape hatch (layerA_gaps restructure/reorganize/split/merge) + "set edit_list to []"

**Status**: SATISFIED

**Evidence** (pack-upgrade.workflow.js L276-278):

```js
`EXCEPTION: If the plan's layerA_gaps include structural reorganization (restructure/` +
`reorganize/split/merge), full rewrite is acceptable for the affected files. State this ` +
`explicitly in your summary and set edit_list to [].\n\n` +
```

All four keywords (restructure, reorganize, split, merge) and the "set edit_list to []" instruction are present.

---

### AC4: pack-dogfood has baseline snapshot loop before pipeline (copies existing dogfood-{pack}.md to .prev.md)

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L83-93):

```js
// -- Snapshot: copy existing baselines for regression comparison ----
phase('Snapshot')
for (let i = 0; i < packs.length; i++) {
  const p = typeof packs[i] === 'string' ? packs[i] : packs[i].name
  await agent(
    `If the file ${EV}/dogfood-${p}.md exists, copy it to ${EV}/dogfood-${p}.prev.md (overwrite if exists). ` +
    `If it does not exist, do nothing. Report what you did.`,
    { label: `snapshot:${p}`, phase: 'Snapshot' }
  )
}
```

The snapshot loop is located BEFORE the `pipeline()` call (L97), uses a dedicated agent per pack, and copies to `.prev.md`.

---

### AC5: pack-dogfood has fixture persistence stage between Stage 1 (task extraction) and Stage 2 (answers), writes to fixtures/{pack}.task.md

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L104-112):

```js
// Stage 2: persist fixture for future regression baselines
async (task, pack) => {
  await agent(
    `Write the following task text to ${EV}/fixtures/${pack}.task.md (create dir if needed, ` +
    `overwrite if exists):\n\n${task}`,
    { label: `persist:${pack}`, phase: 'Task' }
  )
  return task
},
```

This is a dedicated persist stage placed between Stage 1 (task extraction, L99-103) and Stage 3 (answers, L114). It writes to `fixtures/{pack}.task.md` and passes `task` through unchanged.

---

### AC6: Stage 3 (Judge) .then() includes `task: b.task` (does not discard task text)

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L141):

```js
.then((j) => ({ pack, pack_is: b.pack_is, task: b.task, verdict: j || { winner: 'tie', wrong_claims: ['judge failed'] } })),
```

The `task: b.task` field is explicitly threaded through the Judge `.then()` return object, making task text available to the Regression stage.

---

### AC7: Regression stage reads .prev.md baseline (not the current-run dogfood-{pack}.md)

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L143-157):

```js
(judged, pack) => agent(
  `REGRESSION CHECK for capability pack "${pack}".\n\n` +
  `1. Check if ${EV}/dogfood-${pack}.prev.md exists. If NOT -> return regression_found=false\n` +
  `   (no previous baseline -- this is the first run or first run after adding regression).\n` +
  `2. Read ${EV}/dogfood-${pack}.prev.md -- this is the PREVIOUS run's judgment (baseline).\n` +
  ...
```

The prompt explicitly references `.prev.md` (the snapshot from before the current run), NOT the current `dogfood-{pack}.md`.

---

### AC8: REGRESSION_SCHEMA includes regression_found (boolean) + lost_knowledge (array)

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L73-81):

```js
const REGRESSION_SCHEMA = {
  type: 'object',
  required: ['regression_found', 'lost_knowledge'],
  properties: {
    regression_found: { type: 'boolean', description: 'true if any correct knowledge from the previous baseline was lost in the current version' },
    lost_knowledge: { type: 'array', items: { type: 'string' }, description: 'list of specific knowledge/rules/thresholds that the previous version had correctly but the current version lost or weakened' },
    analysis: { type: 'string', description: 'brief explanation of the regression comparison methodology and findings' },
  },
}
```

Both `regression_found` (boolean) and `lost_knowledge` (array of strings) are in `required` and `properties`.

---

### AC9: meta.phases includes Snapshot + Regression (5 phases total)

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L5-11):

```js
phases: [
  { title: 'Snapshot', detail: 'Copy existing dogfood baselines to .prev.md for regression comparison' },
  { title: 'Task', detail: 'Extract user-facing scenario from each pack fixture' },
  { title: 'Answers', detail: 'Control + with-pack answers; blind order by index parity' },
  { title: 'Judge', detail: 'Blind rubric scoring + WebSearch fact-check' },
  { title: 'Regression', detail: 'Compare current-pack vs previous-baseline; detect lost knowledge' }
]
```

5 phases: Snapshot, Task, Answers, Judge, Regression. Both Snapshot and Regression are present.

---

### AC10: Return value includes regression dimension data

**Status**: SATISFIED

**Evidence** (pack-dogfood.workflow.js L176, L186, L189-190):

Row-level regression data:
```js
regression: r.regression || {},
```

Top-level aggregation:
```js
packs_with_regression: rows.filter((r) => r.regression && r.regression.regression_found).map((r) => r.pack),
```

Updated note:
```js
note: '...regression_found = knowledge lost in upgrade. Conductor must read dogfood-*.md before judging.',
```

The return value includes per-pack `regression` data in rows, a top-level `packs_with_regression` array, and an updated note mentioning regression.

---

### AC11: Spike script is Python stdlib, located at correct path, executable

**Status**: SATISFIED

**Evidence**:

File exists at `.tad/evidence/spikes/pack-evolve-spike/spike.py`.

Imports are all stdlib (spike.py L6-10):
```python
import json
import glob
import os
import sys
from collections import Counter, defaultdict
```

Execution test:
```
$ python3 .tad/evidence/spikes/pack-evolve-spike/spike.py
Report written to .tad/evidence/spikes/pack-evolve-spike/spike-report.md
```

No errors, no external dependencies.

---

### AC12: Spike greps for real trace event types (domain_pack_step etc., not capability_pack)

**Status**: SATISFIED

**Evidence** (spike.py L15-17):

```python
PACK_EVENTS = {"domain_pack_step", "domain_pack_created"}
OUTCOME_EVENTS = {"gate_result", "tool_call_outcome", "task_completed"}
FEEDBACK_EVENTS = {"reflexion_diagnosis", "expert_review_finding"}
```

All event types match the real TAD trace v2 schema. None of the incorrect types (`capability_pack`, `pack_loaded`) are present. The spike report confirms these event types match actual trace data (386 events found across 47 trace files).

---

### AC13: Spike results written to spike-report.md

**Status**: SATISFIED

**Evidence**: File exists at `.tad/evidence/spikes/pack-evolve-spike/spike-report.md` with meaningful content:

```markdown
# Pack-Evolve Spike Report

**Scan**: 47 trace files, 2525 lines, 0 parse errors

## Signal Summary (386 relevant events)
...
## Feasibility Assessment

**SIGNAL PRESENT**: Pack events and outcome/feedback events co-occur on the same days.
```

The report contains real signal data (not just a placeholder) with event type distribution, pack mentions, temporal co-occurrence analysis, and a feasibility assessment.

---

### AC14: Plan/Eval/Review stages unchanged (only Upgrade stage + schema + constants changed)

**Status**: SATISFIED

**Evidence** (`git diff HEAD -- .claude/workflows/pack-upgrade.workflow.js`):

The diff shows exactly 19 changed lines, all confined to:
1. **UPGRADE_SCHEMA** (L126): `required` array gained `'edit_list'`
2. **UPGRADE_SCHEMA properties** (L134-136): added `edit_list` schema
3. **Upgrade stage prompt** (L266-278): replaced opening line with bounded-edit block

The following stages are **completely untouched**:
- Plan stage (L171-263): no changes
- Eval stage (L292-299): no changes
- Review stage (L301-329): no changes
- PLAN_SCHEMA, EVAL_SCHEMA, VERDICT_SCHEMA: no changes
- Return block: no changes

---

### AC15: Functional test -- pack-dogfood run with Regression stage outputting regression_found

**Status**: SATISFIED

**Evidence**: Two regression reports produced by actual pack-dogfood runs:

1. `.tad/evidence/pack-dogfood/regression-code-security.md`:
   - Verdict: "No regression found."
   - Methodology: claim-by-claim comparison of 10 verified-correct claims from previous winner
   - All 10 claims marked RETAINED
   - Two pre-existing errors correctly identified as NOT regressions

2. `.tad/evidence/pack-dogfood/regression-rag-retrieval.md`:
   - Verdict: "No regression found."
   - Methodology: compared 20+ knowledge points from previous winner
   - All major points marked PRESERVED
   - One negligible omission ("93 datasets" supplementary context) correctly assessed

Both reports demonstrate the Regression stage executed successfully, read `.prev.md` baselines, compared against current pack versions, and produced structured `regression_found` assessments.

---

## Conclusion

All 15 acceptance criteria are SATISFIED. The implementation faithfully follows the handoff's technical design:

- **FR1 (bounded edit)**: AC1-3 all satisfied -- prompt prepends bounded-edit instructions, schema requires edit_list, escape hatch for structural reorganization present.
- **FR2 (regression gate)**: AC4-10 all satisfied -- snapshot loop, fixture persistence, task threading, regression stage, schema, meta phases, and return value all implemented correctly.
- **FR3 (spike)**: AC11-13 all satisfied -- Python stdlib, correct event types, real signal detected in report.
- **Backward compat**: AC14 satisfied -- only Upgrade stage and UPGRADE_SCHEMA touched in pack-upgrade.
- **Functional test**: AC15 satisfied -- regression stage ran successfully on two packs with meaningful output.
