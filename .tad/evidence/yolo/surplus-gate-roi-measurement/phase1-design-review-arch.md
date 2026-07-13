# Phase 1 Design Review — Backend/Data-Pipeline Architecture Lens

**Handoff**: HANDOFF-surplus-gate-roi-measurement.md
**Reviewer**: Backend architecture expert (data-analysis pipeline / methodology focus)
**Date**: 2026-07-05
**Domain auto-detect**: Files to Modify = none; Files to Create = 1 markdown report. Not frontend / not API-DB / not auth → **default: backend architecture**. The system under review is a read-only archival **measurement pipeline** (traces + archives → sample → classify → verdict), so the architecture axis that matters is *data-pipeline/measurement validity*, not service topology.

**Scope of review**: architecture quality, blast radius, design completeness. NOT re-writing the handoff — findings only.

---

## Summary Verdict

**CONDITIONAL** — the pipeline's *engineering* blast radius is excellent (read-only, single file, baseline-diff guard). But the pipeline is a **measurement instrument**, and as a measurement instrument it has two structural defects that let it produce an unreproducible or upward-biased verdict while passing every AC. Both must be closed before implement, because the whole deliverable is "a falsifiable verdict a skeptic could recompute" and these two defeat exactly that.

- P0: 2
- P1: 3
- P2: 3

---

## Strengths (architecture done right)

- **Blast radius is genuinely minimal and mechanically fenced.** NFR1 read-only + AC7 pre/post `git status` baseline-diff (with the protected-path grep) is the correct design for a zero-mutation deliverable. Baseline-excluding pre-existing untracked files (e.g. the already-present `2026-07-04.jsonl`) is the right call — a naive `git status` check would false-positive on it. This is a model read-only guard.
- **Two-store data-flow separation is correct.** Recognizing traces = *event timeline* (WHEN/WHETHER) and archives = *defect content* (WHAT), joined by slug, is the right data model (§4.1, MQ3, Learning §11.1). Either store alone would give a hollow number; the design names this explicitly.
- **De-dup rule is present** (§4.3: same defect in Audit Trail + COMPLETION fix log counts once) — the classic double-count trap is pre-empted.
- **Dependency surface is honest** — jq/grep/BSD userland, dry-run-verified, python3 fallback pre-staged in the Friction Preflight. No supply-chain surface.

---

## P0 Findings (block implement)

### P0-1 — The verdict has NO defined decision rule; it is therefore not reproducible, contradicting the deliverable's own success criterion

FR5 requires exactly one `**Verdict**: net-positive|neutral|negative` line "with a numeric basis … and reasoning vs the no-gate baseline — no hedged 'it depends'." AC10 only checks that ≥3 numbers *appear* in the Verdict section. **Nowhere in the design is there a function mapping the aggregates (total defects, P0+P1 count, zero-catch ratio) to the three-valued verdict.** What zero-catch ratio flips net-positive → net-neutral? What P0+P1 count is required for net-positive? Undefined.

Why this is P0, not stylistic: the stated definition of success (§1.2, FR6, NFR2) is *"a skeptic could recompute the verdict from the table alone."* A skeptic cannot recompute a categorical verdict when the categorization threshold does not exist — they can recompute the *counts* but not the *verdict*, which is the actual deliverable. The report would pass AC5 (one enum line present) and AC10 (three numbers present) while the central claim remains a subjective judgment dressed as a measurement. This is precisely the "Validation Theater" failure the handoff itself cites as a lesson to avoid (Project Knowledge item 2).

**Required fix**: add to §4 (Data Models) a stated, pre-registered decision rule the report must restate verbatim in `## Method` *before* the counts are known — e.g. "net-positive iff ≥N non-cosmetic (broken-ship + silent-degradation) defects caught AND zero-catch ratio < X; net-negative iff non-cosmetic catches = 0; else net-neutral." Exact thresholds are the author's to choose, but they must be fixed and stated so the mapping is mechanical. Add an AC that greps for the decision rule in `## Method`.

### P0-2 — The sample frame selects FOR gate-wins and does not guarantee a single zero-catch (`none`) row — structurally inflating ROI, the exact bias FR2 forbids, with no AC enforcing the guard

FR2 and §10.1 are emphatic: zero-catch handoffs MUST appear as `none` rows or "ROI is faked upward." But the sampling rule that actually *produces* the frame pulls from (a) `gate_result` trace slugs and (b) FR1(b) "COMPLETION reports **containing explicit Gate 3/4 sections or P0/P1 fix logs**." The AC-P2 pool is literally `grep -l 'P0' … = 137`. Both selectors **condition on a catch having occurred.** A COMPLETION with no defects and no P0 fix log is filtered out of the frame by construction — so the zero-catch class the ROI honesty depends on can be systematically absent, and the numerator (catches) is guaranteed non-empty.

Compounding it: with 70 distinct gate_result slugs, the trace∪archive join almost certainly yields ≥20 pairs, so the FR1(b) "every-Nth COMPLETION" *neutral* extension likely **never triggers**. The frame collapses to "handoffs that reached a formal gate event and/or logged a P0" — the most catch-dense subpopulation on disk.

AC8 only verifies each row *carries* an enum value; it does **not** verify any `none` rows exist. So the single most important anti-bias control (FR2) is enforced by zero acceptance criteria. Intent present, verification absent.

Why P0: this inverts the measurement. A frame that conditions on catches can only ever return "gates catch things," making the verdict a foregone conclusion and the whole exercise circular. It directly violates FR1's own "NOT cherry-picked for gate wins."

**Required fix**: the sample frame must be drawn from a **catch-agnostic population** — e.g. a systematic every-Nth sample over *all* archived handoffs/COMPLETIONs sorted by name (regardless of P0 presence), THEN classify each (including `none`). Trace-gate slugs can be a stratum but not the whole frame. Add an AC asserting the sample contains ≥1 `none` row OR the Method documents why the catch-agnostic frame legitimately produced zero (with the population denominator shown).

---

## P1 Findings (fix strongly recommended)

### P1-1 — "ROI" is measured on the benefit side only; gate COST is never captured, so the deliverable cannot honestly be an ROI verdict and cannot honestly engage the 2026-04-15 principle it is required to engage

ROI = benefit ÷ cost. The design measures *gross defects caught* (benefit) and the counterfactual severity of each. It measures **nothing on the cost side**: gate overhead time, false-positive churn, blocked-ship friction, recovery cost. Yet AC6 *requires* the recommendation to engage "Mechanical Enforcement Rejected on Single-User CLI" — a principle whose entire content is a **cost** argument ("日常恢复成本 > 防偶尔跳步骤收益"). A report that measured only benefit cannot genuinely engage a cost-based prior; it can only cite the date to satisfy the grep (AC6 is a presence check).

Why P1 not P0: the report is salvageable by honest reframing — either (a) rename the measured quantity "gate defect-catch effectiveness" and scope cost explicitly to Limitations, or (b) add a coarse cost proxy (e.g. count of gate-blocked-then-fixed cycles, or expert-review rounds per handoff from the `expert_review_finding` = 79 events already on disk). Option (b) is cheap and lives in the same data. Recommend at minimum (a) with a Limitations paragraph stating cost is unmeasured, so the verdict is not overclaimed as ROI.

### P1-2 — Selection bias toward formal, high-ceremony, post-2026-05-19 handoffs; express/small-edit population under-represented; N unspecified

`gate_result` traces begin 2026-05-19 and only fire for handoffs that reach a formal gate. Express handoffs and single-file fixes (which the framework explicitly de-ceremonializes) rarely emit gate events and rarely produce COMPLETION P0 logs — so they fall out of the frame. The verdict then generalizes from the subpopulation where gates are *most* likely to earn their keep to a claim about gates overall. The "every-Nth" N is never pinned (§6.1 task 2), so two runs could produce different samples → non-reproducible frame (violates NFR2).

**Fix**: pin N (or a deterministic rule) in Method; add a Limitations sentence that the frame skews to formal handoffs and cannot speak to express/small-edit ROI.

### P1-3 — FR5 "no hedged verdict" collides with the honestly-large unmeasurable portion; the honest-partial escape is wired only for the <20-sample case

NFR3's "unmeasurable with current evidence" route is triggered *only* by <20 usable samples. But the more likely honesty problem is different: samples ≥20 yet **half the ROI equation (false negatives + cost) is structurally unmeasurable** (FR6 admits both). FR5 forbids "it depends," pushing the author toward a confident categorical verdict on a quantity where two of the four inputs are unknown. That is the setup for an overconfident verdict.

**Fix**: extend the honest-partial trigger to "benefit measurable, cost/false-negatives not" → allow a scoped verdict ("net-positive *on caught-defect value alone*, cost-side unmeasured") that is still one line and still falsifiable, but not overclaimed.

---

## P2 Findings (polish / risk notes)

### P2-1 — AC6 and AC10 are mechanical presence greps → validation-theater surface
`grep -ci '2026-04-15'` and "≥3 numeric occurrences" are satisfiable without genuine engagement (a bare date citation, three irrelevant numbers/dates). The handoff's own knowledge base flags this class. Low-cost hardening: AC6 could additionally require a keyword from the principle's cost claim (e.g. `cost|overhead|recovery`) in the Verdict section; AC10 could scope the number-count to a labeled "numeric basis:" line rather than the whole section.

### P2-2 — Counterfactual enum has no classification rubric or tie-break; single analyst, no second lens
`broken-ship / silent-degradation / cosmetic / none` are one-line definitions. The verdict is dominated by how each defect is bucketed (silent-degradation is called "the worst class"), yet a single inside-TAD analyst classifies with no rubric and no inter-rater check. Two reasonable analysts could swing the aggregate. Cheap mitigation: add 1-2 concrete anchor examples per enum value in §4.3, and (optional) route a sample of classifications through a second reader agent for agreement, given §10.3 already permits one.

### P2-3 — 20/184 (~11%) with heavy class imbalance may be underpowered for a categorical verdict
Given 69/73 gate_result = pass and pass-heaviness, 20 samples is a thin base for a three-valued verdict. Acceptable for a surplus-budget ephemeral report, but the confidence statement (FR6) should explicitly state the sample fraction and that it is a lower-bound-effort, not a powered study.

---

## Design Completeness Check

| Dimension | State | Note |
|-----------|-------|------|
| Architecture complete | OK | Four-stage read-only pipeline is well-formed |
| Blast radius bounded | OK (strong) | AC7 baseline-diff is exemplary |
| Data model / dedup | OK | §4.3 count-once rule present |
| **Sample frame validity** | FAIL P0-2 | Conditions on catches; no `none`-row guarantee |
| **Verdict reproducibility** | FAIL P0-1 | No aggregate→verdict decision rule |
| Cost side of ROI | FAIL P1-1 | Only benefit measured |
| Reproducibility of frame | WARN P1-2 | N unspecified |
| Honesty escape coverage | WARN P1-3 | Only wired for <20 samples |
| Verification anti-theater | WARN P2-1/2 | Presence greps + no classification rubric |

---

## Bottom Line

The *plumbing* is safe to ship — read-only, single file, well-fenced. The *instrument* is not yet sound: it can pass all ten ACs while (a) drawing a catch-conditioned sample and (b) emitting a categorical verdict with no defined threshold. Close P0-1 (pre-registered decision rule in Method) and P0-2 (catch-agnostic frame + `none`-row AC) before the implement stage; fold P1-1/P1-3 into an honest reframing of "ROI" scope. Everything else is polish.
