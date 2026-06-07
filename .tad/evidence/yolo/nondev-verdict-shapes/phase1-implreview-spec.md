# Phase-1 Implementation Review (spec-compliance) — nondev-verdict-shapes Y6

**Reviewer:** independent spec-compliance reviewer (verified against disk, not implementer claims)
**Spec:** `.tad/active/handoffs/HANDOFF-20260606-nondev-verdict-shapes-p1.md`
**Changed file:** `.claude/skills/gate/SKILL.md` (git diff: 62 insertions, 4 deletions — clean additive)
**Date:** 2026-06-06

---

## Overall: PASS

- **P0: 0**
- **P1: 0**
- **P2: 2** (both advisory, neither blocks acceptance)

The implementation matches the spec semantics on every checked dimension. All six edits (A–F)
landed verbatim where the spec mandated. The weighted path is byte-preserved (only the 4 sanctioned
replacements were deleted). The categorical decoupling is structurally enforceable (not pure assertion).
Gate 4 stays shape-agnostic. No internal contradiction introduced.

---

## Check-by-check

### 1. Categorical branch encodes "Gate judges RIGOR, not BUILD/PIVOT/KILL" — enforceable? — PASS

Not pure assertion. Three independent firewalls present on disk (L458–479):

- `rigor_independence` (L458–462) states the principle: "a rigorously-argued KILL is `rigorous` (PASS);
  a hand-wavy BUILD is `superficial` (FAIL)."
- `decoupling_firewall` (L463–473) gives STRUCTURAL enforcement, not just prose:
  - **Order-of-emission firewall** (L465–467): "the judge MUST write `band:` WITH its per-dimension
    rigor justification BEFORE it states `content_verdict:`. The band is committed before the conclusion
    is named, so the conclusion cannot anchor the band." — this is a committed-before-revealed firewall, the
    real anti-anchoring mechanism.
  - **Conclusion-neutral criteria** (L468–470): pushes the rubric's band criteria to be phrased about rigor.
  - **Swap test** (L471–473): "If you flipped this artifact's final BUILD/PIVOT/KILL word and changed
    nothing else, would the band change? If yes, you are scoring the conclusion — re-score on rigor only."
- `extra_output` (L474–479) re-states the order constraint: "⚠️ `band:` (with justification) MUST appear
  ABOVE `content_verdict:` in the file (order firewall)."

Order-firewall + swap test both present. Verdict: enforceable, not assertion-only.

### 2. `content_verdict:` does NOT feed the gate verdict — PASS

The mapping derives the gate verdict from the RIGOR band only:

> L455–457: "rigorous → PASS · partial → PARTIAL · superficial → FAIL"
> L477: "content_verdict: BUILD|PIVOT|KILL   (the artifact's own conclusion; recorded, never maps to gate verdict)"
> L478: "The machine-readable `verdict: PASS|PARTIAL|FAIL` line (derived from band) remains the Gate 4 token."

`content_verdict` is explicitly "recorded, never maps to gate verdict." No remaining path lets a
categorical deliverable's gate verdict be derived from BUILD/PIVOT/KILL. The judge-prompt-by-shape
line (L403–406) reinforces it: "do NOT reward/punish the BUILD/PIVOT/KILL conclusion … `content_verdict:`
(recorded, not gate-determining)."

### 3. checklist branch: PASS/PARTIAL/FAIL unambiguous + malformed_guard + evidence_independence — PASS

- Mapping (L487–491) is unambiguous and total over the input space:
  > "ALL required pass → PASS / ALL required pass, ≥1 optional fail → PARTIAL / ANY required fail → FAIL"
  No gap: the three branches partition on (any-required-fail) then (any-optional-fail). PASS requires ALL
  required pass AND zero optional fail (implicit but unambiguous given the PARTIAL clause).
- `malformed_guard` (L482–486) present: "the rubric MUST define ≥1 REQUIRED item … zero required items →
  BLOCK Gate 3 ('malformed checklist rubric — cannot ever FAIL, define ≥1 required item')." Closes the
  always-PASS hole.
- `evidence_independence` (L492–495) present: "the judge derives each item's pass/fail from the artifact's
  substance / measurable specs it independently checks — NEVER from the artifact's own claim that it passed
  (same Judge_Not_Producer artifact-channel rule)." Correctly cross-links to Judge_Not_Producer's
  artifact-channel VIOLATION (L444).

### 4. Gate 4 deliverable branch shape-agnostic + no weighted_score assumption + shape_agnostic_note (Edit E) — PASS

- Still greps the shape-agnostic token (L840): `grep -E '^verdict: PASS' .tad/evidence/reviews/*-rubric-eval-*.md`.
- `shape_agnostic_note` (Edit E) present at L842: "The `^verdict: PASS` token is shape-agnostic —
  weighted/categorical/checklist all emit it. Gate 4 needs no per-shape branch."
- Disk grep of the entire Gate 4 deliverable branch (L815–879) for `weighted|score` returns ONLY the
  shape_agnostic_note line itself. No weighted_score / threshold / score arithmetic anywhere in Gate 4.
  Confirmed shape-agnostic.

### 5. Edit F generalized BOTH weighted-only spots — PASS

- **F1 (judge_prompt_constraint blue-team line, L397–398):** now reads "Report per the resolved
  verdict_shape (see judge_prompt_by_shape) + the machine-readable verdict line." — the weighted-only
  "Report dimension scores + weighted average + verdict." was removed from the blue-team framing and
  relocated (correctly) into `judge_prompt_by_shape.weighted` (L402, marked "(existing)").
- **F2 (Gate 3 Critical Check item, L530):** now reads "Rubric verdict PASS per resolved verdict_shape —
  weighted: score ≥ pass_threshold · categorical: band = rigorous · checklist: all required items pass
  (scored by independent judge)." — generalized across all three shapes. The old weighted-only
  "Rubric weighted score ≥ pass_threshold" line is deleted (confirmed in diff).

Both spots generalized. AC8 satisfied.

### 6. judge≠producer + file-paths-only preserved for new shapes — PASS

- `judge_prompt_by_shape` closes with L409: "All shapes keep judge≠producer + file-paths-only (no
  producer reasoning/persona/identity)."
- `judge_prompt_constraint` body (L399–400) unchanged: "The judge prompt MUST NOT include the producer's
  reasoning, chat transcript, persona, identity…"
- `Judge_Not_Producer` block (L431–445) byte-unchanged (no diff hunk touches it); its artifact-channel
  VIOLATION (L444) is now explicitly reused by checklist `evidence_independence` and categorical scoring.

### 7. No contradiction vs rest of deliverable branch — PASS

- `Rubric_Resolution` (L367–385): the guard's supported-list `{weighted, categorical, checklist}` is
  consistent with `verdict_shape` resolution (L368, L376). No contradiction.
- `Required_Subagent.output_format` (L411–417): the new conditional bullet (L414) correctly says the
  weighted_score arithmetic bullet is "replaced by" the band line / item table for non-weighted shapes,
  while the machine-readable `verdict:` line (L415) stays REQUIRED for all shapes — consistent with Gate 4's
  shape-agnostic grep.
- `output_format_constraint` (L418–423, P-label-heading guard) untouched and still applies to all shapes.
- `Verdict_Mapping` (L447–500): weighted `rule:` (L449–452), `on_pass:` (L499), `on_partial_or_fail:`
  (L500) are byte-identical to pre-change — the new `categorical:`/`checklist:` sub-blocks were INSERTED
  between the weighted `rule:` and `on_pass:` exactly as Edit B mandated. No weighted line modified
  (verified: diff shows zero `-` lines among weighted ladder / on_pass / on_partial).

---

## P2 (advisory, non-blocking)

- **P2-1 (structural-vs-judgment limit, inherited not introduced):** The order-of-emission firewall and
  swap test are enforced by JUDGE PROMPT INSTRUCTION, not by a mechanical post-write check on the
  rubric-eval file. A non-compliant judge could still emit `content_verdict:` above `band:`, or score on
  conclusion despite the swap-test instruction. There is no grep/parser asserting `band:` precedes
  `content_verdict:` in the produced evidence file. This is the strongest enforceable form within a
  prompt-only protocol layer (consistent with the project's "soft reminders for single-user CLI" principle),
  so it is acceptable for Phase 1 — but a Phase-3 mechanical check ("in rubric-eval, line(`band:`) <
  line(`content_verdict:`)") would convert assertion → verification. Note this is already flagged in the
  handoff audit trail as P1-4 "validation theater / Deferred-to-P3."

- **P2-2 (checklist PASS edge wording):** The checklist `rule:` (L488–491) defines PASS as "ALL required
  pass" on its own line, then PARTIAL as "ALL required pass, ≥1 optional fail." A literal reader could
  briefly read the bare "ALL required pass → PASS" as PASS even when an optional fails. The PARTIAL clause
  disambiguates it correctly (PARTIAL wins when an optional fails), so the mapping is sound as written, but
  a one-word tightening ("ALL required pass AND no optional fail → PASS") would remove the momentary
  ambiguity. Cosmetic only — does not affect correctness.

---

## Mechanical verification (run against disk)

- `git diff --stat`: 62 insertions, 4 deletions — additive, matches expected Edit A–F footprint.
- Deletions confined to: guard `rule:` + guard `message:` (Edit A), blue-team "weighted average + verdict"
  line (Edit F1), Critical-Check "Rubric weighted score" line (Edit F2). No other `-` lines. AC2/AC6 ✅.
- Fence balance: even (no code-fence imbalance).
- AC1: `supported: [weighted, categorical, checklist]` present (L384). ✅
- AC3: `rigorously-argued KILL` (L460) + `ORDER OF EMISSION` (L465) present. ✅
- AC4: `ALL required pass → PASS` (L489) + `malformed checklist rubric` (L483) present. ✅
- AC5: `verdict:` REQUIRED-for-all-shapes bullet (L414–415) present. ✅
- AC7: `grep -l verdict_shape .tad/codex/*.md` → empty; no codex mirror, no parity regen needed. ✅
- AC8: blue-team `Report per the resolved verdict_shape` (L398) + critical-check `Rubric verdict PASS per
  resolved verdict_shape` (L530) present. ✅

All 8 ACs structurally satisfied on disk.
