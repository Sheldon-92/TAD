# Epic: Non-Dev Deliverable Lane — Categorical + Checklist verdict_shapes

**Epic ID**: EPIC-20260606-nondev-verdict-shapes
**Created**: 2026-06-06
**Owner**: Alex
**Execution**: YOLO (autonomous, no pause between phases)

---

## Objective
Make the Non-Dev Execution Track's deliverable lane actually runnable for non-`weighted`
packs. Today the Gate 3 deliverable branch only supports `verdict_shape: weighted`; the
`verdict_shape_guard` HARD-BLOCKs `categorical` (product-thinking BUILD/PIVOT/KILL) and
`checklist` (ai-voice / video-creation export specs) — so those packs have a registered
rubric slot but cannot pass a gate. This Epic implements both shapes (Gate 3 + Gate 4),
authors the product-thinking categorical rubric, and PROVES the lane works by dogfooding
product-thinking end-to-end with three distinct agents.

## Success Criteria
- [ ] Gate 3 + Gate 4 deliverable branches support `verdict_shape: categorical` and `checklist` (weighted path byte-unchanged)
- [ ] `verdict_shape_guard` allows {weighted, categorical, checklist}; BLOCKs only unknown shapes
- [ ] categorical Gate judges ANALYSIS RIGOR, independent of the artifact's BUILD/PIVOT/KILL conclusion (a rigorously-argued KILL PASSes)
- [ ] product-thinking categorical rubric authored + registered in deliverable-rubrics.yaml (status active, thresholds cited to source)
- [ ] Real dogfood: product-thinking deliverable runs the full lane (producer ≠ judge, ≥3 distinct agents); gate demonstrably DISCRIMINATES (an honest non-PASS landed before a PASS)
- [ ] voice/video checklist gate-logic in place + honestly marked "dogfood needs hardware — gate verified, dogfood pending"
- [ ] nondev-execution-track guide updated with categorical + checklist worked examples

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Gate verdict_shape implementation | ✅ Done | HANDOFF-20260606-nondev-verdict-shapes-p1.md | Gate 3+4 deliverable branches support categorical + checklist (additive, weighted byte-unchanged) |
| 2 | product-thinking categorical rubric | ✅ Done | HANDOFF-20260606-nondev-verdict-shapes-p2.md | pressure-test-rubric.md (rigor bands) + deliverable-rubrics.yaml registration |
| 3 | Dogfood + guide | ✅ Done | HANDOFF-20260606-nondev-verdict-shapes-p3.md | Real end-to-end product-thinking run (4 distinct agents, discrimination + decoupling proof) + checklist fixture + guide update |

### Phase Dependencies
All phases sequential. Phase 2 needs Phase 1's categorical semantics fixed. Phase 3 needs both.

### Derived Status
- **Status**: ✅ COMPLETE (all 3 phases Done)
- **Progress**: 3/3

---

## Phase Details

### Phase 1: Gate verdict_shape implementation

**Status:** ⬚ Planned
**Execution:** YOLO

#### Scope
Extend the Gate 3 deliverable branch (gate/SKILL.md ~:341) and Gate 4 deliverable branch
(~:758) to handle `verdict_shape: categorical` and `verdict_shape: checklist` in ADDITION
to `weighted`. Purely additive — the `weighted` Verdict_Mapping ladder and every non-deliverable
code path stay BYTE-UNCHANGED. NOT in scope: authoring any rubric (Phase 2), running any
deliverable (Phase 3).

#### Input
- gate/SKILL.md Gate 3 deliverable branch (verdict_shape_guard :382-384, Verdict_Mapping :437-443) + Gate 4 deliverable branch (:758-821)
- deliverable-rubrics.yaml (verdict_shape field already present per pack)
- Contract §B.5 (Verdict_Mapping), §C (judge≠producer)

#### Output
- `verdict_shape_guard` rewritten: allow {weighted, categorical, checklist}; BLOCK only unknown
- `Verdict_Mapping` extended with categorical + checklist branches (weighted branch unchanged)
- categorical: judge assigns RIGOR band {rigorous→PASS, partial→PARTIAL, superficial→FAIL}; judge prompt MUST score rigor independent of BUILD/PIVOT/KILL; emit `verdict:` (gate token) + `band:` + `content_verdict:` (artifact conclusion, recorded, NOT gate-determining)
- checklist: required-items all-pass→PASS, optional-fail→PARTIAL, required-fail→FAIL
- Gate 4 branch: confirm it stays shape-agnostic (greps `^verdict: PASS`); add a one-line note that the token is shape-agnostic
- judge_prompt_constraint extended per shape (still file-paths-only, judge≠producer intact)

#### Acceptance Criteria
- [ ] AC1: `verdict_shape_guard` BLOCKs only shapes not in {weighted, categorical, checklist}
- [ ] AC2: weighted Verdict_Mapping ladder is byte-identical to pre-change (verify with git diff — weighted lines unchanged)
- [ ] AC3: categorical branch maps rigor band→verdict AND judge prompt explicitly decouples rigor from BUILD/PIVOT/KILL (grep the decoupling sentence)
- [ ] AC4: checklist branch maps required/optional pass-fail→verdict
- [ ] AC5: machine-readable `verdict: PASS|PARTIAL|FAIL` line still required for ALL shapes (Gate 4 token contract preserved)
- [ ] AC6: every non-deliverable Gate path + the weighted deliverable path unchanged (diff scoped to deliverable-branch additive lines)
- [ ] AC7: Codex-edition parity NOT required this phase (gate/SKILL.md is not a codex-mirrored file) — confirm no codex mirror exists for gate

#### Files Likely Affected
- .claude/skills/gate/SKILL.md (MODIFY — Gate 3 + Gate 4 deliverable branches only)

#### Dependencies
None (can start immediately)

#### Notes
- byte-preservation of the weighted path is the load-bearing SAFETY AC (mirrors the lean-trustworthy byte-identity lessons).
- Do NOT register gate/SKILL.md as a settings.json hook (single-user-CLI principle).

### Phase 2: product-thinking categorical rubric

**Status:** ⬚ Planned
**Execution:** YOLO

#### Scope
Author a categorical rubric for product-thinking deliverables (pressure-test analyses) and
register it. The rubric scores ANALYSIS RIGOR across named dimensions and maps to bands
{rigorous|partial|superficial}. Thresholds cited to source (fatal-flaws.md, the pack's
named protocol). NOT in scope: gate logic (Phase 1), running a deliverable (Phase 3).

#### Input
- Phase 1 categorical semantics (rigor band, not content verdict)
- product-thinking pack: checklists/fatal-flaws.md (15 killers, "2+ fatal flaws = KILL"), skills/pressure-test.md, examples/pressure-test-verdict.md (discriminative markers)
- deliverable-rubrics.yaml product-thinking row (currently rubric-tbd, interim_rubric_source set)

#### Output
- .claude/skills/product-thinking/references/pressure-test-rubric.md (CREATE) — categorical rubric: dimensions (adversarial rigor / FACT-ASSUMPTION evidence grounding / fatal-flaw analysis depth / verdict justification / product-type adapter use), band criteria, decision tree, anti-theater rule (rigor ≠ conclusion)
- deliverable-rubrics.yaml product-thinking row updated: rubric_ref set, status active, partial-band semantics defined
- Mirror to .tad/capability-packs/product-thinking/ source dir if it exists (sync portability)

#### Acceptance Criteria
- [ ] AC1: rubric defines ≥4 named rigor dimensions, each with rigorous/partial/superficial criteria
- [ ] AC2: rubric explicitly states a rigorously-argued KILL PASSes (decoupling rule from Phase 1)
- [ ] AC3: thresholds cited to a real on-disk source (e.g. fatal-flaws.md "2+ = KILL"), not interpolated
- [ ] AC4: deliverable-rubrics.yaml product-thinking row: rubric_ref non-null, verdict_shape categorical, status active
- [ ] AC5: rubric is judge-usable from file-path-only (no producer context needed)

#### Files Likely Affected
- .claude/skills/product-thinking/references/pressure-test-rubric.md (CREATE)
- .tad/capability-packs/deliverable-rubrics.yaml (MODIFY)
- .tad/capability-packs/product-thinking/ (MODIFY if source dir exists)

#### Dependencies
Phase 1

#### Notes
- The rubric is the discrimination instrument — it must be able to give a superficial pressure-test a non-PASS.

### Phase 3: Dogfood + guide

**Status:** ⬚ Planned
**Execution:** YOLO

#### Scope
Prove the lane works: a producer sub-agent writes a real product-thinking pressure-test
deliverable on a real product idea; a FRESH independent judge scores it via the Phase 2
categorical rubric through the Phase 1 Gate 3 branch. Demonstrate the gate DISCRIMINATES
(an honest non-PASS lands before a PASS, with distinct agents per round). Update the track
guide with categorical + checklist worked examples. NOT in scope: voice/video dogfood (hardware).

#### Input
- Phase 1 gate logic + Phase 2 rubric
- deliverable-handoff.md / deliverable-completion.md templates
- A real product idea to pressure-test (pick a concrete one — e.g. a TAD-adjacent idea)

#### Output
- A real product-thinking deliverable artifact (pressure-test analysis) under .tad/evidence/
- ≥2 rubric-eval files from DISTINCT judge agents showing band/verdict + the discrimination story
- .tad/evidence/yolo/nondev-verdict-shapes/EPIC-COMPLETION.md (run summary, agent IDs, discrimination proof)
- nondev-execution-track.md guide: add categorical + checklist worked example sections; mark voice/video "gate verified, dogfood pending (hardware)"

#### Acceptance Criteria
- [ ] AC1: deliverable produced by a producer agent distinct from the judge (judge≠producer, ≥3 distinct agents across the run)
- [ ] AC2: gate discriminated — at least one honest non-PASS (PARTIAL/FAIL band) was recorded before/without a rubber-stamp PASS
- [ ] AC3: a rigorously-argued non-BUILD conclusion (if it occurs) is NOT auto-failed (decoupling proven, or explicitly noted as not-exercised)
- [ ] AC4: guide updated with categorical + checklist examples; voice/video honestly marked dogfood-pending
- [ ] AC5: EPIC-COMPLETION.md records all agent IDs + per-round bands/verdicts
- [ ] AC6: SYNTHETIC checklist fixture (P1-4 mitigation) — a small fake export-spec manifest run through the checklist Gate-3 branch once, proving the checklist branch fires (PASS + FAIL cases), even though real voice/video content dogfood needs hardware. Converts "validation theater" risk → "gate-logic verified via fixture, real-content dogfood pending".

#### Files Likely Affected
- .tad/evidence/research/ or .tad/evidence/deliverables/ (CREATE — the artifact)
- .tad/evidence/reviews/*-rubric-eval-*.md (CREATE — judge outputs)
- .tad/evidence/yolo/nondev-verdict-shapes/EPIC-COMPLETION.md (CREATE)
- .tad/guides/nondev-execution-track.md (MODIFY)

#### Dependencies
Phase 1, Phase 2

#### Notes
- This is the anti-validation-theater proof. A clean first-pass PASS with no discrimination evidence is a WEAK result — engineer the dogfood so the rubric has a real chance to land a non-PASS (e.g. judge a deliberately thin v1, then a revised v2).

---

## Context for Next Phase
{updated after each phase accept}

### Completed Work Summary
- Phase 1 (864e64e): gate/SKILL.md Gate 3/4 deliverable branches support categorical + checklist (weighted byte-unchanged). 4 reviewers 0 P0.
- Phase 2 (cd065ee): product-thinking categorical rubric authored + registered active; citations source-traced. 2 reviewers 0 P0.
- Phase 3 (this branch): dogfood PROVED discrimination + decoupling (rigorous KILL→PASS, superficial BUILD→FAIL, 4 distinct agents) + checklist synthetic fixture (PASS+FAIL) + guide updated. KA → patterns/gate-design.md.
- Epic COMPLETE. Evidence: .tad/evidence/yolo/nondev-verdict-shapes/EPIC-COMPLETION.md

### Decisions Made So Far
- D1: categorical Gate judges RIGOR, not the BUILD/PIVOT/KILL conclusion (user decision 2026-06-06). A rigorously-argued KILL PASSes.
- D2: scope = implement categorical + checklist gate-side; dogfood only product-thinking (voice/video dogfood needs hardware, deferred) (user decision 2026-06-06).

### Known Issues / Carry-forward
- (none yet)

### Next Phase Scope
Phase 1: Gate verdict_shape implementation.

---

## Notes
Direction A chosen from a 3-candidate strategic analysis (2026-06-06): "make non-dev packs
runnable" — matches user's documented preference for generative work leveraging completed
assets, beyond software dev. Sibling of the completed Non-Dev Execution Track Epic.
