---
task_id: replay-already-landed
task_type: code
epic: EPHEMERAL-surplus-replay-already-landed
title: "Surplus-execute completion digest token table (replay sample)"
source: gate4-fixture
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
risk_triggers: [none]
look_first: "not-needed: change is confined to this repo's own workflow script and its generated digest text; no external system or real user data is acted on"
real_paths:
  - id: RP1
    path: "Maintainer runs surplus-execute on a small sidecar and reads the generated SURPLUS-REPORT digest"
    run: "Run the workflow on a 2-row fixture sidecar (one executed, one failed), then read the '## Token Usage by Mode' section of the returned report_markdown / report_path file and confirm the per-mode totals equal the sum of the per-task token figures in the Executed/Failed tables"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-31
**Project:** TAD Framework
**Task ID:** replay-already-landed
**Handoff Version:** 4.0.8
**Epic:** EPHEMERAL-surplus-replay-already-landed (Phase 1/1 — Digest Token Table)
**Supersedes:** the 26-line fixture stub previously at this path (same task_id; this version adds grounded file paths, data-flow notes, and runnable verification)

---

## 1. Context — Why This Phase, What It Delivers

The surplus-execute workflow (`.tad/workflows/claude/surplus-execute.workflow.js`)
already compiles a completion digest ("Surplus Report") at its Report phase.
Today that digest reports only one aggregate figure — `Total budget spent` —
plus per-task token columns inside the Executed Tasks and Failed Tasks tables.
A reader cannot tell how token spend splits across the execution modes the
run actually used, which makes cross-run cost comparison guesswork.

This phase (the Epic's only phase) adds ONE new section to that digest: a
per-mode token table summarizing token usage by execution mode. Nothing else
about the workflow's behavior changes: no filtering, routing, budget, or
execution logic is touched.

**Deliverable (Epic wording):** "Completion digest updated with the per-mode
token table." The digest is the `reportLines`/`reportMarkdown` built in the
Report phase of `surplus-execute.workflow.js` and returned as
`report_markdown` (also written by the caller to `report_path`,
`.tad/active/SURPLUS-REPORT-<stamp>.md`).

### 1.1 What "mode" means here (grounded in the script)

The script already records exactly two mode axes, both surfaced in the
digest's Summary block today (`- Budget mode:`, `- Step mode:`):

- **Budget mode** — `caps.budget`: `native` | `ledger` (probeCapabilities).
- **Step mode** — `caps.steps`: `nested` | `inline` (probeCapabilities);
  each executed row also carries its own `step_mode` field.

**Assumption A1 (recorded per design-verification step):** the per-mode table
groups token spend by **step mode** (`nested` / `inline`), because that is the
per-row execution mode the data supports; the run's single budget mode is
named in the section header line so the accounting basis is never ambiguous.
Grouping by budget mode per-row is impossible — a run has exactly one budget
mode — so a budget-mode "table" would always have one row and carry no
information. If Gate 4 disagrees, the fallback is a two-axis table
(budget mode × step mode) with the same row data.

## 2. Exact Files

### 2.1 Files to Modify
```
.tad/workflows/claude/surplus-execute.workflow.js
  # Report phase only (the reportLines assembly, currently lines ~566-651).
  # Add a "## Token Usage by Mode" section after the Summary block and
  # before "## Executed Tasks" (deterministic position; cost picture
  # reads top-down).
```

### 2.2 Files to Create
```
None. No new source, test, or doc files. (Evidence files produced during
verification live under .tad/evidence/ per normal Gate 3 practice and are
not deliverables of this phase.)
```

### 2.3 Explicitly Out of Scope
- `.tad/workflows/claude/surplus-scan.workflow.js` — untouched.
- The budget facade (`probeCapabilities`, `budgetSpent`, `chargeAgent`) — untouched.
- Row filtering, pre-flight routing, execution loops — untouched.
- The returned result object's shape — unchanged except that
  `report_markdown` gains the new section text.
- All pre-existing digest sections and their formatting — preserved verbatim.

## 3. Implementation Notes

1. Compute the table from data already in scope at Report time:
   - Executed spend per step mode: sum `ex.tokens` over `results.executed`,
     grouped by `ex.step_mode` (rows may lack `step_mode` in nested mode —
     fall back to `caps.steps` for those rows; do not drop them).
   - Failed spend per step mode: sum `fl.tokens || 0` over `results.failed`;
     failed rows carry no `step_mode`, so attribute them to `caps.steps`.
   - Routed-row tokens (`results.routed[].tokens`) are pre-flight costs:
     include them in the same step-mode row as a separate column or footnote,
     never silently merged into Executed.
2. Render with the digest's existing conventions: Markdown table, token
   figures as `~<N>K` using `Math.round(x / 1000)`, exactly like the
   existing per-task tables.
3. Table shape (columns): `| Mode | Tasks | Executed Tokens | Failed Tokens | Total |`
   with one row per step mode actually present, plus a final `| **All modes** |`
   total row. The total row MUST reconcile with the existing
   `- Total budget spent:` Summary line (same `spentTotal` basis); if routed
   tokens are included, the section's header line states so.
4. Zero-run case: if no tasks executed or failed, render the section with a
   single `(none)` line, matching the digest's existing empty-section style.
   Never emit a table with NaN or undefined cells.
5. Ledger caveat: when `caps.budget === 'ledger'` and `ledgerEstimated > 0`,
   append `(ledger est.)` to the section's total, mirroring the existing
   `totalSpentLine` suffix rule.
6. Keep the change inside the Report phase block; do not refactor adjacent
   report sections, rename variables, or reformat untouched lines.

## 4. Acceptance Criteria

- AC1: The digest produced by a surplus-execute run contains a
  `## Token Usage by Mode` section with a Markdown table listing each
  execution (step) mode present with its token counts.
- AC2: Every token figure in the per-mode table is derived from the run's
  own per-task token data (executed + failed, routed shown separately);
  no hardcoded or estimated numbers are introduced.
- AC3: The table's grand total equals the digest's existing
  `Total budget spent` figure for the same run (same accounting basis,
  modulo the stated routed-token treatment).
- AC4: A run with zero executed and zero failed tasks still renders the
  section (with `(none)`) and does not throw; populated and empty
  datasets both render correctly.
- AC5: No behavior outside the Report phase changes: filtering, routing,
  execution, budget accounting, returned object keys, and all existing
  digest content/formatting are unchanged.
- AC6: The script still parses/loads as a workflow script (no syntax errors).

## 5. Verification Steps (Gate 3 evidence)

| # | Criterion | Verification Method | Expected Evidence |
|---|-----------|---------------------|-------------------|
| AC1 | post-impl-verifiable | `grep -c '## Token Usage by Mode' <generated SURPLUS-REPORT or captured report_markdown>` | count ≥ 1 |
| AC2 | post-impl-verifiable | Fixture run (RP1): hand-sum the fixture's per-task tokens and compare to the table cells | figures match exactly |
| AC3 | post-impl-verifiable | Same fixture output: compare table grand total vs the `- Total budget spent:` line | equal (or differ only by the stated routed amount) |
| AC4 | post-impl-verifiable | Run with a sidecar whose rows are all SAFETY (needs-you only); inspect digest | section present with `(none)`, run returns normally |
| AC5 | post-impl-verifiable | `diff` of the workflow file against pre-change copy, hunk review | hunks confined to the Report phase reportLines assembly |
| AC6 | pre-impl-verifiable | `node --check .tad/workflows/claude/surplus-execute.workflow.js` (parse only; if bare node rejects workflow globals, use the harness's workflow load check instead) | exit 0 / no syntax error |

Real path RP1 (from frontmatter) is the primary end-to-end check: run the
workflow on a 2-row fixture sidecar (one executed, one failed) and read the
new section in the produced digest.

## 6. Gate 2 Self-Check (Alex)

| Check | Status | Note |
|-------|--------|------|
| Architecture Complete | ✅ | Single-section addition to an existing digest builder; no new components |
| Components Specified | ✅ | Report phase of surplus-execute.workflow.js, lines ~566-651, read at design time |
| Functions Verified | ✅ | `budgetSpent()`, `caps.budget`, `caps.steps`, per-row `tokens`/`step_mode` all confirmed present in the script as read |
| Data Flow Mapped | ✅ | sidecar rows → execution results (`results.executed/failed/routed` with token fields) → reportLines → report_markdown |

**Scope clarity:** CLEAR. The Epic's scope and deliverable are one bounded
sentence each; the only ambiguity ("mode") is resolved by Assumption A1
above with a named fallback. No blocking human decision is outstanding —
surplus rows are pre-approved per the Epic.

**Open questions:** 0.

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-10-31
**Version**: 4.0.8
