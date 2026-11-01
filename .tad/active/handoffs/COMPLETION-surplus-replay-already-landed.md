# Completion Report — surplus-replay-already-landed

**Task ID:** replay-already-landed
**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-replay-already-landed.md`
**Role:** Blake (Execution Master), YOLO Epic Phase 1, inline step runner
**Date:** 2026-10-31
**Result:** Implementation complete; all handoff verification steps run, all pass (Layer 1).

## Deliverables Produced

1. `.tad/workflows/claude/surplus-execute.workflow.js` — the only source file
   changed. One insertion (+54 lines, single diff hunk at the Report phase)
   adds a `## Token Usage by Mode` section to the surplus-execute completion
   digest, placed immediately after the Summary block and before
   `## Executed Tasks`, exactly as the handoff specifies.
2. This completion report:
   `.tad/active/handoffs/COMPLETION-surplus-replay-already-landed.md`.

No other repo files were created or modified. Verification scratch (fixture
harness, pre-change copy, diff, outputs) was kept outside the repo in the
workflow working directory, per the handoff's note that evidence files are
not deliverables of this phase.

## What Was Implemented

- The table is computed at Report time from data already in scope:
  executed tokens summed from `results.executed[].tokens` grouped by
  `ex.step_mode` (falling back to `caps.steps` when a row lacks `step_mode`,
  so no row is dropped); failed tokens summed from `results.failed[].tokens`
  attributed to `caps.steps`; routed (pre-flight) tokens summed from
  `results.routed[].tokens`, also attributed to `caps.steps`.
- Assumption A1 is followed: grouping is by step mode; the section header
  line names the run's single budget mode so the accounting basis is stated.
- Routed tokens are shown in their own `Routed Tokens` column (the separate-
  column option in handoff note 1), are included in each row's `Total`, and
  are never counted as Executed; the header line states this treatment.
- Columns: `| Mode | Tasks | Executed Tokens | Failed Tokens | Routed Tokens | Total |`,
  one row per step mode present, plus a final `| **All modes** |` total row.
  Token figures use the digest's existing `~<N>K` convention
  (`Math.round(x / 1000)`).
- `Tasks` counts every task contributing spend in that mode (executed +
  failed + routed rows), so the All-modes Tasks figure is the total number
  of processed tasks.
- Ledger caveat: when `caps.budget === 'ledger'` and `ledgerEstimated > 0`,
  ` (ledger est.)` is appended to the All-modes total, mirroring the existing
  `totalSpentLine` suffix rule.
- Zero-run case: with zero executed, zero failed, and zero routed tasks the
  section renders a single `(none)` line (the digest's existing empty-section
  style); no table, no NaN/undefined cells.
- Nothing outside the Report phase was touched: no filtering, routing,
  execution, budget-facade, or returned-object changes.

## Acceptance Criteria — Verification and Evidence

Verification harness: a Node script that (a) syntax-compiles the actual
workflow file and (b) extracts the actual Report-phase assembly from the
file (from `var reportLines = []` through the `reportMarkdown` join) and
executes it against fixture stubs, so the code tested is the code shipped,
not a copy. Full harness output was captured during the run.

- **AC1 (section present):** Fixture run RP1 produced a digest containing
  exactly one `## Token Usage by Mode` section (harness assertion plus
  `grep -c` on the generated digest = 1), positioned after `## Summary`
  and before `## Executed Tasks`, with a Markdown table.
- **AC2 (figures derived from per-task data, no hardcoded numbers):**
  RP1 fixture: one executed row (120000 tokens, step_mode inline), one
  failed row (30000), one routed row (5000). Hand sum: 120K / 30K / 5K.
  Generated row: `| inline | 3 | ~120K | ~30K | ~5K | ~155K |` — exact match.
- **AC3 (grand total reconciles):** Same fixture: All-modes total `~155K`
  equals the digest's own `- Total budget spent: ~155K tokens` line
  (120000 + 30000 + 5000 = 155000, same `spentTotal` accounting basis;
  executed + failed + routed partition all per-task spend in the loop).
- **AC4 (zero-run renders, does not throw):** Fixture with zero executed /
  failed / routed and two SAFETY (Needs You) rows rendered the section
  with `(none)`, returned a complete digest normally, and contained no
  NaN/undefined text.
- **AC5 (nothing outside Report phase changes):** `diff -u` of the workflow
  file against a pre-change copy taken before editing shows exactly one
  hunk (63 diff lines), an insertion only, confined to the reportLines
  assembly between the Summary block and `## Executed Tasks`. No deletions,
  no reformatting of untouched lines, no other file touched.
- **AC6 (script still parses):** Bare `node --check` rejects this workflow
  file's pre-existing top-level `return` — identically on the pre-change
  baseline (line 650) and the post-change file (line 704, shifted by
  exactly the 54 inserted lines) — which is the case the handoff
  anticipates. The substitute load check therefore applies: the full file
  (with `export` stripped and wrapped in an async function so top-level
  await/return parse, mimicking the workflow harness) compiles cleanly
  under Node's `vm.Script` — "AC6 syntax compile: OK".
- **Extra check (implementation notes 1 and 5):** A third fixture with
  `caps.budget = 'ledger'`, `ledgerEstimated = 2`, and an executed row
  missing `step_mode` rendered the row under `nested` (the `caps.steps`
  fallback) and the All-modes total as `~42K (ledger est.)`.

All fixture assertions printed PASS; harness exit code 0.

## Friction Encountered

- `node --check` cannot parse any workflow script in this repo (top-level
  `return`/`await` by design); resolved per the handoff's own fallback
  clause with the wrapped `vm.Script` compile check, with the identical
  baseline failure recorded above as evidence the limitation pre-dates
  this change.
- One design detail needed a judgment call within the handoff's bounds:
  handoff note 3 lists five table columns while note 1 requires routed
  tokens be shown separately; I used note 1's explicit "separate column"
  option, adding a `Routed Tokens` column, rather than silently merging
  routed spend into Executed or dropping the reconciliation with
  `Total budget spent`.

## Knowledge Usage

- Handoff frontmatter set `skip_knowledge_assessment: yes`; no project-
  knowledge patterns were required. The repo `AGENTS.md` rules were
  followed: no git commands were run in this repo, and all work stayed
  inside the single file the handoff names.

## Layer 1 Self-Check

Layer 1: I ran every verification step the handoff lists (AC1 grep,
AC2/AC3 RP1 fixture hand-sum comparison, AC4 zero-run fixture, AC5 diff
hunk review, AC6 parse check with the handoff's stated fallback) and they
all passed on the shipped file. The change implements exactly what the
handoff specifies — one new digest section, Report phase only, no scope
expansion. **layer1_passed: true.**
