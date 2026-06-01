# Epic: Non-Dev Execution Track (TAD beyond code)

**Epic ID**: EPIC-20260531-nondev-execution-track
**Created**: 2026-05-31
**Owner**: Alex
**Execution**: YOLO (full-auto, pause_between_phases: false)

---

## Objective
Give TAD a first-class NON-CODE delivery lane: a `task_type: deliverable` route whose Gate 3 verifies **deliverable quality via a pack-specific rubric scored by an independent judge** (not `tsc/test/lint`), with content-artifact handoff/completion templates. Turns the 4-5 orphaned non-dev capability packs (academic-research, ai-voice-production, video-creation, product-thinking/content) into a runnable pipeline — directly delivering on "TAD beyond software dev."

## Success Criteria
- [ ] A `task_type: deliverable` handoff can pass Gate 3 via rubric score (judge ≠ producer) without any code build/test step.
- [ ] Existing code/yaml/research/e2e/mixed flows are byte-unchanged (augment, not replace — zero regression).
- [ ] academic-research runs a real small deliverable end-to-end through the track and Gate 3 rubric PASSES on genuine output (not a mock).
- [ ] The 4 non-dev packs are registered against the track with their rubric source + threshold; voice/video/content marked dogfood-pending (no hardware).
- [ ] The track is documented (a guide) + Knowledge Assessment captured.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Spike: Architecture Contract | ✅ Done | phase1-architecture-contract.md (v2.1) | Design contract: 4 touchpoints, additive-sibling Gate 3+4 branches, judge≠producer, pack→rubric side-file. Gate PASS. |
| 2 | Templates + Gate 3 **+ Gate 4** branch + producer routing | ✅ Done | 23339a9 + 897bed9 | Lane machinery built byte-safe; 2-reviewer review + fixes; Gate 3+4 PASS |
| 3 | Wire academic-research + real dogfood | ✅ Done | dogfood (9986de8) | Real brief → judge-A 0.737 PARTIAL → revise → fresh judge-B 0.7725 PASS. 5/5 ACs. Lane proven not-theater. |
| 4 | Generalize + Gate 4 + document | ✅ Done | 179556d | track guide + registry enrichment + KA; 5/5 success criteria PASS |

### Phase Dependencies
All phases sequential. P2 depends on P1's contract. P3 depends on P2's machinery. P4 depends on P3's proven lane.

### Derived Status
- **Status**: Planning (all ⬚) — will move to In Progress on Phase 1 activation.

---

## Phase Details

### Phase 1: Spike — Architecture Contract

**Status:** ✅ Done (Gate PASS 2026-05-31)
**Execution:** YOLO full-auto
**Completed:** contract v2.1 at phase1-architecture-contract.md; 2-reviewer design review + 1 verification re-review; 4 P0 + 6 P1 resolved. Gate report: phase1-gate-report.md.

#### Scope
Decide and document the architecture of the non-dev track BEFORE building anything. Define: (a) the `task_type: deliverable` semantics and how it routes; (b) the Gate-3 non-dev branch contract (what replaces build/test/lint); (c) the judge≠producer mechanism to avoid self-enhancement bias; (d) the pack→rubric mapping (which packs declare which rubric file + pass threshold). NOT in scope: writing any template, editing gate/SKILL.md, or running a deliverable. Output is a spec document only (Light TAD spike).

#### Input
- Existing `gate/SKILL.md` Gate 3 (hard-wires test-runner/build/test/lint — gate/SKILL.md:124-158) and Gate 4 (gate/SKILL.md:340+).
- `academic-research/SKILL.md:145-146` already declares Gate3=ScholarEval≥0.75 / Gate4=completeness-per-tier (informal contract to formalize); rubric at `.claude/skills/academic-research/references/scholar-eval.md`.
- `experiment_path_protocol` (alex/SKILL.md) as the augment-not-replace precedent.
- handoff/completion templates frontmatter (`task_type: code|yaml|research|e2e|mixed`).
- ai-evaluation pack's self-enhancement-bias rule (judge ≠ optimizer/producer).

#### Output
- `.tad/evidence/yolo/nondev-execution-track/phase1-architecture-contract.md` containing:
  - `task_type: deliverable` definition + routing rules (how *analyze/handoff/gate detect & branch).
  - Gate-3 non-dev branch contract: inputs (deliverable artifact paths + rubric ref + threshold), the judge≠producer spawn rule, the pass/fail/partial verdict mapping, and where evidence is written.
  - Gate-4 non-dev branch contract (business acceptance for deliverables = meets brief, not user-facing-code-behavior).
  - pack→rubric map table: pack | rubric file | pass threshold | dogfood-capable (yes/no + why).
  - Explicit "what stays unchanged" list (the 5 existing task_types) proving augment-not-replace.

#### Acceptance Criteria
- [ ] AC1: Design doc exists and specifies `task_type: deliverable` routing in all 3 touchpoints (handoff frontmatter, gate branch, completion).
- [ ] AC2: judge≠producer mechanism explicitly specified (the producing sub-agent MUST NOT score its own deliverable; a separate judge sub-agent scores against the rubric).
- [ ] AC3: pack→rubric map covers ≥4 packs with a concrete rubric file path + numeric threshold per pack; academic-research row points to scholar-eval.md ≥0.75.
- [ ] AC4: "Unchanged" list enumerates code/yaml/research/e2e/mixed and asserts their Gate 3 path is untouched.
- [ ] AC5: doc identifies the exact files Phase 2 will edit (no edits made in Phase 1).

#### Files Likely Affected
- `.tad/evidence/yolo/nondev-execution-track/phase1-architecture-contract.md` (CREATE)

#### Dependencies
None (can execute independently — it's the contract spike).

#### Notes
Light TAD spike (per architecture.md "Insert Light TAD spike as Phase 1 for mechanism unknowns"). The big risk is designing a rubric gate that's validation theater (self-scored). D2 (judge≠producer) is the load-bearing decision — Phase 1 must nail it.

### Phase 2: Templates + Gate 3 rubric branch

**Status:** ✅ Done (Gate 3+4 PASS 2026-05-31)
**Execution:** YOLO full-auto
**Completed:** commits 23339a9 + 897bed9. Byte-safe (original Gate 3/4 blocks IDENTICAL vs 9fc6c50). 2-reviewer review → 1 P0 (dead gate3 telemetry) + 4 P1 all fixed. Gate report: phase2-gate-report.md.

#### Scope
Build the machinery per Phase 1's contract: (a) `deliverable-handoff` + `deliverable-completion` templates; (b) add the non-code branch to `gate/SKILL.md` Gate 3 (route on `task_type: deliverable` → rubric+judge instead of build/test/lint); (c) Blake-side execution notes for deliverable type. NOT in scope: wiring a specific pack's content or running a real deliverable (that's Phase 3). Editing must be ADDITIVE — existing Gate 3 code-path text byte-unchanged.

#### Input
- Phase 1 contract doc (the spec).
- Existing templates: `.tad/templates/handoff-a-to-b.md`, `.tad/templates/completion-report.md`.
- `gate/SKILL.md` Gate 3/4 sections.
- `blake/SKILL.md` Gate 3 v2 execution.

#### Output
- `.tad/templates/deliverable-handoff.md` (CREATE) — content-artifact handoff (Deliverables to Produce instead of Files to Modify; rubric ref + threshold in frontmatter).
- `.tad/templates/deliverable-completion.md` (CREATE) — deliverable completion (rubric scores + artifact paths instead of tsc/test).
- `gate/SKILL.md` (MODIFY, additive) — Gate 3 `task_type: deliverable` branch: spawn judge sub-agent → score against rubric → verdict; Gate 4 deliverable branch.
- `blake/SKILL.md` (MODIFY, additive) — deliverable execution lane reference.

#### Acceptance Criteria
- [ ] AC1: Both templates exist with deliverable-specific frontmatter (`task_type: deliverable`, `rubric_ref`, `pass_threshold`).
- [ ] AC2: gate/SKILL.md Gate 3 has a `task_type == deliverable` branch that routes to rubric+judge and does NOT require test-runner/build for deliverables.
- [ ] AC3: The existing code Gate 3 path (test-runner mandatory, build/test/lint) is byte-unchanged for non-deliverable task_types — verify with a diff/grep that the code-path block is intact.
- [ ] AC4: judge≠producer is enforced in the gate text (the judge sub-agent is spawned by the gate/Conductor, distinct from whoever produced the deliverable).
- [ ] AC5: blake/SKILL.md references the deliverable lane without breaking existing constraint counts (forbidden_implementations / VIOLATION counts unchanged).

#### Files Likely Affected (authoritative plan = contract §F)
- `.tad/templates/deliverable-handoff.md` (CREATE — §F.1)
- `.tad/templates/deliverable-completion.md` (CREATE — §F.2)
- `.claude/skills/gate/SKILL.md` (MODIFY — §F.3: Gate 3 sibling branch **AND Gate 4 deliverable carve-out**, both additive sibling sections + guard lines; `types:` enum gains `rubric-eval`)
- `.claude/skills/alex/SKILL.md` (MODIFY — §F.7: Touchpoint-0 producer classification, additive)
- `.claude/skills/blake/SKILL.md` (MODIFY — §F.4: deliverable lane note; Blake does NOT produce/score research deliverables)
- `.tad/capability-packs/deliverable-rubrics.yaml` (CREATE — §F.5: academic-research active, 3 packs rubric-tbd)

#### Dependencies
Phase 1 (contract v2.1)

#### Notes
SCOPE EXPANDED per Phase-1 gate4_delta: Gate 4 deliverable carve-out + alex Touchpoint-0 routing pulled INTO Phase 2 (review found Gate 4 would deadlock the Phase-3 dogfood otherwise). Highest blast-radius phase. Safety invariants: additive-sibling-not-ELSE-wrap (byte-identical original Gate 3+4 fenced blocks, offset-aware byte-check per contract §B.1/§E); preserve MUST NOT/VIOLATION/MANDATORY constraint-token counts in gate + blake + alex SKILLs (line-set diff before/after).

### Phase 3: Wire academic-research + real dogfood

**Status:** ✅ Done (Gate PASS 2026-05-31)
**Execution:** YOLO full-auto
**Completed:** real PARTIAL→PASS loop (3 distinct agents); 5/5 ACs; phase3-dogfood-report.md; committed 9986de8.

#### Scope
Prove the lane works end-to-end with ONE pack. Wire academic-research into the track (declare its rubric=scholar-eval.md, threshold 0.75), then run a SMALL REAL research deliverable through the full lane (deliverable handoff → produce → judge-scored Gate 3). The judge sub-agent must be distinct from the producer. NOT in scope: voice/video (no hardware), or generalizing to other packs (Phase 4).

#### Input
- Phase 2 machinery (templates + Gate 3 branch).
- academic-research pack + scholar-eval.md rubric.
- WebSearch/NotebookLM availability (academic-research needs only these — no hardware).

#### Output
- academic-research registered against the track (rubric + threshold declared in its pack metadata or the pack→rubric registry from Phase 1).
- A real small research deliverable artifact (a short scoped research output) in `.tad/evidence/yolo/nondev-execution-track/dogfood/`.
- `.tad/evidence/yolo/nondev-execution-track/phase3-dogfood-report.md` — the judge sub-agent's ScholarEval scoring of the real deliverable + Gate 3 verdict.

#### Acceptance Criteria
- [ ] AC1: A real (not mocked) small research deliverable is produced through a `task_type: deliverable` handoff.
- [ ] AC2: A judge sub-agent (distinct from the producer sub-agent) scores it against scholar-eval.md and writes a scored evidence file.
- [ ] AC3: Gate 3 verdict is computed from the rubric score vs threshold (pass if ≥0.75), NOT from build/test.
- [ ] AC4: The dogfood report shows the producer and judge were different agents (anti-self-scoring proven in practice).
- [ ] AC5: If the deliverable scores below threshold, the lane correctly reports FAIL/PARTIAL (negative path works) — or if it passes, the report notes what a failing case would look like.

#### Files Likely Affected
- `.claude/skills/academic-research/SKILL.md` (MODIFY — formalize rubric/threshold declaration) or pack→rubric registry (CREATE/MODIFY)
- `.tad/evidence/yolo/nondev-execution-track/dogfood/*` (CREATE — real artifact)
- `.tad/evidence/yolo/nondev-execution-track/phase3-dogfood-report.md` (CREATE)

#### Dependencies
Phase 2

#### Notes
This is the validation-theater-killer: a real deliverable, scored by an independent judge, gated on the score. Keep the research deliverable SMALL/bounded (a single focused question) so the dogfood is fast.

### Phase 4: Generalize + Gate 4 + document

**Status:** ✅ Done (Gate PASS 2026-05-31) — EPIC COMPLETE
**Execution:** YOLO full-auto
**Completed:** track guide + rubrics registry interim_rubric_source + KA (architecture.md). All 5 Epic success criteria PASS. EPIC-COMPLETION.md written. Commit 179556d.

#### Scope
Extend the track to the remaining non-dev packs and close it out: register ai-voice-production / video-creation / product-thinking(content) against the track with their rubric refs + thresholds (marked dogfood-pending where hardware is required); define Alex's Gate-4 non-dev business-acceptance semantics; write the track guide; capture Knowledge Assessment. NOT in scope: real dogfood of voice/video (no hardware).

#### Input
- Phase 3 proven lane + dogfood report.
- The non-dev packs' existing quality criteria.

#### Output
- pack→rubric registry rows for voice/video/content (dogfood-pending flag + reason).
- Gate-4 non-dev acceptance semantics in gate/SKILL.md or alex/SKILL.md (deliverable acceptance = meets brief + rubric threshold + human approval).
- `.tad/guides/nondev-execution-track.md` (CREATE) — how to run a deliverable through TAD.
- Knowledge Assessment entry in project-knowledge (architecture.md or a new category).

#### Acceptance Criteria
- [ ] AC1: ≥3 additional non-dev packs registered with rubric ref + threshold + dogfood-capable flag.
- [ ] AC2: Gate-4 non-dev acceptance semantics documented (deliverable business acceptance distinct from code Gate 4).
- [ ] AC3: Track guide exists and a non-expert could follow it to run a deliverable.
- [ ] AC4: KA entry written capturing the architecture decisions + the judge≠producer lesson.
- [ ] AC5: Epic success criteria re-verified; existing flows confirmed unchanged.

#### Files Likely Affected
- pack→rubric registry (MODIFY)
- `.claude/skills/gate/SKILL.md` or `.claude/skills/alex/SKILL.md` (MODIFY — Gate 4 non-dev)
- `.tad/guides/nondev-execution-track.md` (CREATE)
- `.tad/project-knowledge/architecture.md` (MODIFY — KA)

#### Dependencies
Phase 3

#### Notes
Closing phase. Voice/video dogfood is explicitly deferred (hardware). The guide + KA make the track adoptable and the lesson durable.

---

## Context for Next Phase
{Conductor updates after each phase}

### Completed Work Summary
- Phase 1 ✅: architecture contract v2.1 (phase1-architecture-contract.md). 4 touchpoints (1 producer Touchpoint-0 + 3 consumers), additive-sibling Gate 3 + Gate 4 branches (byte-safe, NOT ELSE-wrap), judge≠producer, pack→rubric side-file. 2-reviewer review + verification re-review; 4 P0 + 6 P1 closed.

### Decisions Made So Far
- D1: Augment not replace — `task_type: deliverable` routes Gate 3 **and Gate 4** to additive sibling sections; existing 5 task_types byte-untouched.
- D2: judge ≠ producer — deliverable scored by an independent judge sub-agent (anti self-enhancement bias); producer = Conductor-spawned agent (NOT Blake — research tools are Conductor-side).
- D3: academic-research is the first/only real dogfood (scholar-eval.md ≥0.75, no hardware).
- D4 (new, from P1 review): Gate 4 carve-out + alex Touchpoint-0 routing moved into Phase 2 (Gate 4 would otherwise deadlock the dogfood).

### Known Issues / Carry-forward
- Voice/video/content dogfood deferred (hardware). Registered rubric-tbd.
- Phase-4 OPEN RISK: weighted-0-1 verdict ladder may NOT fit categorical rubrics (voice pass/fail dB; product BUILD/PIVOT/KILL) → Phase 4 converts to weighted-0-1 OR adds a 2nd verdict_shape.
- Phase 4 NARROWED (Gate 4 machinery now in Phase 2): Phase 4 = generalize packs + Alex business-acceptance semantics doc + track guide + consolidated KA (4 candidates in phase1-gate-report.md).

### Next Phase Scope
Phase 2: build per contract §F — 2 templates, gate Gate3+Gate4 sibling branches, alex Touchpoint-0, blake note, deliverable-rubrics.yaml. Safety: offset-aware byte-check on original Gate 3+4 blocks; constraint-token counts preserved.

---

## Notes
YOLO Epic, full-auto. Conductor = Alex main session. Evidence base: `.tad/evidence/yolo/nondev-execution-track/`.
