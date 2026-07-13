# Phase 1 Design Review (Round 2) — code-reviewer lens

**Handoff**: `.tad/active/handoffs/HANDOFF-surplus-gate-roi-measurement.md`
**Reviewer**: code-reviewer (AC command correctness, frontmatter, verifiability, coherence)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL — no P0 blockers; 3 P1 should-fix before implement stage.

> Round-1 review items are RESOLVED in this revision: AC7 now uses the BASELINE-DIFF
> (`comm -13 /tmp/gate-roi-baseline.txt`) so pre-existing untracked trace files no longer
> false-fail (closes prior P0-1); AC10 now counts numeric *occurrences* not lines (closes
> prior P1-1); protected-dir list broadened (closes prior P2-4). This round is a fresh pass
> that surfaced 3 new open defects.

---

## Summary

Strong, well-grounded research handoff. All grounding numbers reproduce exactly on disk
(70 gate_result slugs, 137 P0-mentioning COMPLETIONs, 56 trace files, 69/3/1 outcomes). The
six-section report contract makes most ACs mechanically checkable; I re-ran the
AC2/AC3/AC4/AC5/AC6/AC8/AC10 grep/sed commands against a mock report — they behave as
specified and are BSD-portable. The zero-catch `none` rows, honest-partial escape hatch, and
insider-bias guard show the design internalized the relevant SAFETY principles.

Three verification-integrity / consistency gaps remain that a skeptic could exploit.

---

## P0 — Blocking

None. Grounding is real (re-measured), file list is complete, no scope hazard.

---

## P1 — Should Fix (before implement stage)

### P1-1 — AC10 is always-green on the MANDATORY date; it verifies nothing (validation theater)
`AC10` requires `≥ 3 numeric occurrences` inside the Verdict section via
`sed -n '/^## Verdict$/,/^## /p' | grep -oE '[0-9]+(\.[0-9]+)?%?' | wc -l`.
But `AC6` **mandates** the string `2026-04-15` appear in that same section. I verified live: a
Verdict section whose only content is "See 2026-04-15 principle." yields exactly **3** numeric
matches (`2026`, `04`, `15`) and PASSES AC10 — with zero real numeric basis (no defect count,
no P0+P1, no zero-catch ratio). AC10 thus re-checks a condition AC6 already forces and cannot
fail when the intended metrics are absent. This is precisely the "structural check proves
nothing about soundness" failure AC10 exists to prevent (Validation Theater, 2026-05-15).
**Fix**: exclude the date before counting, e.g.
`... | grep -v '2026-04-15' | grep -oE '[0-9]+(\.[0-9]+)?%?' | wc -l` ≥ 3, or require the
three LABELLED metrics: `grep -ciE 'defects?|P0.?\+?.?P1|zero-catch' ` ≥ 3.

### P1-2 — `git_tracked_dirs: []` contradicts the new tracked-file deliverable (Gate-3 hook gap)
Frontmatter sets `git_tracked_dirs: []` with the comment "already-tracked dir", but the
deliverable is a **new** file `.tad/evidence/research/gate-roi-measurement-2026-07.md`.
`.tad/evidence/research/` is git-tracked (163 tracked files), yet the new file stays untracked
until `git add`. A sibling surplus handoff creating a new tracked doc correctly lists
`git_tracked_dirs: ["docs"]  # new docs/...md must be git-tracked at Gate 3`. The frontmatter
header states "Phase 4 Hook 将基于此阻塞 Gate 3" — under that stated model, `[]` lets the
deliverable pass Gate 3 while untracked. The dir-tracked vs file-tracked conflation is the bug.
**Fix**: set `git_tracked_dirs: [".tad/evidence/research"]` (matches sibling convention), or
if the tracked-file hook is genuinely retired, drop the "Phase 4 Hook 将阻塞 Gate 3" comment
so the frontmatter isn't self-contradictory.

### P1-3 — The verdict's linchpin (counterfactual enum) has no verification; "skeptic can recompute" overstates objectivity
FR5 requires reasoning "vs the no-gate baseline", which in this data IS the sum of per-defect
counterfactual enum values (`broken-ship`/`silent-degradation`/`cosmetic`/`none`). The
net-positive/negative verdict is driven almost entirely by that enum. Yet the only mechanical
guard (`AC8`) checks that *an* enum value is present, never that it is correctly assigned —
assignment is pure analyst discretion, by an analyst structurally inside TAD. FR6's bias guard
claims "raw counts let a skeptic recompute the verdict from the table alone", but the skeptic
recomputes using the analyst's own subjective counterfactuals: the transparency is
arithmetic-only, not classification-level. The handoff names this exact risk (Validation
Theater) but leaves the classification step un-instrumented.
**Fix**: add a fixed counterfactual rubric to `## Method` (2–3 concrete criteria per enum
value); have Gate 3 / the methodology reviewer spot-check N rows' enum against the rubric so
classification, not just arithmetic, is auditable. Soften FR6 from "recompute the verdict" to
"recompute the arithmetic, given the stated rubric".

---

## P2 — Nice to Have

### P2-1 — Sample-frame framing ("went through Gate 3 and/or Gate 4") vs defects actually counted (mostly Gate 2)
FR1 defines the frame by Gate 3/4 passage, but FR3 counts Gate-2 expert-review catches and
§10.2 says that's where the real signal lives. FR1(b)'s "P0/P1 fix logs" clause partially
reconciles this, so it isn't broken — but the header sentence risks under-sampling
Gate-2-rich, Gate-3/4-thin handoffs. **Fix**: reword FR1 to "handoffs that went through any
TAD gate/review (Gate 2 expert review, Gate 3, or Gate 4)".

### P2-2 — AC5 honest-partial branch is not mechanically distinguishable
AC5 expects `1`, "or documented honest-partial per NFR3". The `net-*` grep returns `0` for an
"unmeasurable" verdict, and the command can't tell "0 = honest-partial" from "0 = missing
verdict". Unlikely given 137 P0-COMPLETIONs. **Fix**: give honest-partial its own anchored line
(`**Verdict**: unmeasurable-with-current-evidence`) and add it to the AC5 alternation.

### P2-3 — AC3 second half is semi-manual
"`test -f` on 3 randomly chosen cited paths" is an operator step, not a runnable command.
Acceptable, but a one-liner extracting the last pipe-cell of every GR row and `test -f`-ing all
of them would upgrade a spot-check to a full check.

---

## Verified During Review

- Pre-impl grounding re-measured on disk: 70 slugs / 137 P0-COMPLETIONs / 56 traces / 69-3-1
  outcomes — all match the handoff exactly.
- Ran AC2/AC3/AC4/AC5/AC6/AC8/AC10 grep/sed against a mock report: correct + BSD-portable;
  `sed` ranges terminate at the next `## ` as intended.
- Confirmed AC10 date-gaming (3 matches from `2026-04-15` alone) and the `git_tracked_dirs`
  file-vs-dir-tracked gap against a sibling handoff's convention.

## File-List Completeness
Complete. One create (the report), zero modifies; COMPLETION/Epic bookkeeping files are
standard Blake outputs, correctly excluded from AC7's scope grep.

## Frontmatter
`task_type: research`, `e2e_required: no`, `research_required: yes` correct for a report-only
deliverable. Only defect is `git_tracked_dirs` (P1-2).
