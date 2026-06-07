# Phase-1 Impl Review (CR) — nondev-verdict-shapes

**Reviewer:** independent code-reviewer (Gate 3, YOLO Y6)
**Date:** 2026-06-06
**File under review:** `.claude/skills/gate/SKILL.md`
**Spec:** `HANDOFF-20260606-nondev-verdict-shapes-p1.md` §3 Edits A-F, §4 AC1-AC8
**Method:** full `git diff` read + per-AC disk verification (not self-report)

---

## Verdict per AC

| AC | Result | Evidence |
|----|--------|----------|
| AC1 verdict_shape_guard allows {weighted,categorical,checklist}, BLOCKs unknown | PASS | diff L383-385: `rule:` now `NOT IN {weighted, categorical, checklist} → BLOCK`; `supported: [weighted, categorical, checklist]` added; message lists all 3 + "unrecognized shape must NOT be silently mis-scored" |
| AC2 weighted ladder byte-preserved | PASS | See byte-preservation analysis below. `numstat` = 62 added / **4 removed**; the weighted `rule:` 3 lines (SKILL L450-452), `on_pass:` (L499), `on_partial_or_fail:` (L500) are byte-identical and present verbatim |
| AC3 categorical branch + rigor decoupling + order-of-emission firewall | PASS | SKILL L453-479: `rigor_independence` ("rigorously-argued KILL is `rigorous`"); `decoupling_firewall` item 1 = "ORDER OF EMISSION … `band:` … BEFORE … `content_verdict:`"; swap test present. Disk order confirmed: `band:` L476 < `content_verdict:` L477 |
| AC4 checklist branch maps required/optional + ≥1-required malformed_guard | PASS | SKILL L480-498: `malformed_guard` ("MUST define ≥1 REQUIRED item … BLOCK"); `rule:` maps ALL-required→PASS / ≥1-optional-fail→PARTIAL / any-required-fail→FAIL; `evidence_independence` artifact-channel guard present |
| AC5 `verdict:` mandated for all shapes (Edit D) | PASS | SKILL L414 new bullet: "the `verdict:` machine-readable line is REQUIRED for ALL shapes (shape-agnostic Gate 4 token)" added after weighted_score bullet; existing weighted bullets unedited |
| AC6 diff scoped to ONE file, deliverable branches only | PASS | Only `.claude/skills/gate/SKILL.md` in this review's scope. 5 hunks start at new-lines 380, 398, 450, 530, 839 — ALL ≥380 (inside `task_type: deliverable` branch, which begins L343). Code-task Gate 3 block (L78-222) and all non-deliverable paths untouched |
| AC7 no codex mirror | PASS | `grep -l verdict_shape .tad/codex/*.md` → empty (AC7-no-codex-verdict_shape-mirror printed) |
| AC8 no weighted-only judge framing / Critical-Check left | PASS | Old blue-team line replaced → L398 "Report per the resolved verdict_shape…"; old Critical-Check item replaced → L529 "Rubric verdict PASS per resolved verdict_shape — weighted/categorical/checklist". No stale weighted-only framing remains (see note on L402 below) |
| §7 YAML/markdown integrity | PASS | `categorical:`/`checklist:` are 2-space siblings of `rule:`/`on_pass:`/`on_partial_or_fail:` under `Verdict_Mapping:` (no nesting error). Code fences even (`fences-even`) |
| §8 handoff verification block | PASS | All 10 OK tokens print: AC1-OK, AC2-weighted-line-OK, AC3-decouple-OK, AC3-firewall-OK, AC4-OK, AC4-guard-OK, AC7-no-codex-verdict_shape-mirror, AC8-judgeframing-OK, AC8-criticalcheck-OK, fences-even |

---

## AC2 byte-preservation — deep verification (load-bearing SAFETY AC)

`git diff --numstat` = **4 removed lines**. The 4 removed lines, classified:

1. `-    rule: "If the resolved verdict_shape != weighted → BLOCK Gate 3"` — old guard rule (sanctioned, Edit A)
2. `-    message: "Phase-4 categorical/checklist verdict shapes unimplemented …"` — old guard message (sanctioned, Edit A)
3. `-    against the rubric at {rubric_ref}. Report dimension scores + weighted average + verdict."` — old blue-team weighted line (sanctioned, Edit F1)
4. `-  - [ ] Rubric weighted score ≥ pass_threshold (scored by independent judge)` — old Critical-Check item (sanctioned, Edit F2)

This EXACTLY matches the spec's expected deletion set (old guard rule+message = 2, old blue-team weighted line = 1, old Critical-Check item = 1). **Zero weighted-ladder lines were modified.** The weighted `rule:` ladder (`IF weighted_score ≥ pass_threshold … → PASS / PARTIAL / FAIL`), `on_pass:`, and `on_partial_or_fail:` survive byte-identical and are confirmed present on disk (SKILL L450-452, L499, L500). The two new sub-blocks are INSERTED between the weighted `rule:` and `on_pass:` as additive siblings — exactly as Edit B mandates.

---

## P0 (must fix)
None.

## P1 (should fix)
None.

## P2 (consider)
- **P2-1 (informational, not a defect):** The string "weighted average + verdict" still matches at SKILL L402 — but this is the *legitimate* new `weighted   → "Report dimension scores + weighted average + verdict." (existing)` entry inside `judge_prompt_by_shape` (Edit C), i.e. the per-shape instruction for the weighted shape, NOT residual stale framing. Correct by design. Noted only so a future grep-based audit does not flag it as a false positive.

---

## Notes
- This is `task_type: yaml` (prose/YAML protocol edit): no build/test/lint applies; review = Layer-2 expert review on the diff per handoff §6.
- P1-4 (zero-dogfood checklist = validation theater) was correctly deferred to Phase 3 by the Gate-2 audit trail (§5b) — out of scope for this Phase-1 impl review.
- Implementer self-report matches disk on every checked point; no discrepancy found.

---

## Overall: PASS

All 8 ACs satisfied, byte-preservation SAFETY AC verified line-by-line (4 deletions, all sanctioned; weighted ladder byte-identical), structure valid, diff scoped to the deliverable branches of a single file. 0 P0, 0 P1.
