# Non-Dev Execution Track — Reference Guide (`task_type: deliverable`)

> The **non-dev execution track** runs a content artifact (a research report, an
> audiobook chapter, a video cut, a PRD) through TAD's quality gates when the unit
> of work is **NOT code**. Its acceptance is a **rubric score from an independent
> judge**, not build/test/lint.
>
> This is an **additive lane**. It only fires when a handoff is
> `task_type: deliverable`; the five existing task_types (`code | yaml | research |
> e2e | mixed`) take their original gate paths byte-unchanged.

Closes the Epic gap: TAD's Gate 3/Gate 4 assumed every accepted artifact had a code
surface (test-runner, 3 code subagents). A non-dev deliverable has none — so it
needed its own gate semantics. The design contract is
`.tad/evidence/yolo/nondev-execution-track/phase1-architecture-contract.md` (§A–§F);
the proven end-to-end run is
`.tad/evidence/yolo/nondev-execution-track/phase3-dogfood-report.md`.

---

## 1. When to use it — `deliverable` vs `research` vs `code`

Alex classifies the unit of work BEFORE selecting a handoff template
(`alex/SKILL.md` `step0_6_deliverable_classification`, the **Touchpoint 0**
producer step). The rule of thumb (contract §A.4):

| If the unit of work is… | task_type | Gate path |
|---|---|---|
| A **pack-produced content artifact** — the artifact **IS the product** (report / audiobook / video cut / PRD), judged by a pack rubric | **`deliverable`** | NEW deliverable branch (this guide) |
| A research **spike** whose output **feeds a downstream code/yaml handoff** | `research` | existing path (no Gate-3 branch — unchanged) |
| Code / config that builds + tests + lints | `code` / `yaml` / `e2e` / `mixed` | existing code path (test-runner, 3 code subagents — unchanged) |

The discriminator is **"is the artifact the product, or does it inform a build?"**
An academic-research report shipped to a user is `deliverable` (rubric = scholar-eval,
≥0.75). A "go survey the literature so Alex can design the API" spike stays `research`.

---

## 2. The 4-touchpoint flow (end-to-end)

The classification is set at **one producer touchpoint** and acted on at **three
consumer touchpoints** (contract §A.2):

```
Touchpoint 0  Alex classifies (step0_6_deliverable_classification)
  PRODUCER    → sets task_type: deliverable + selects deliverable-handoff.md
              (alex/SKILL.md ~:2654; tad-handoff/SKILL.md template selection ~:36-37)
        │
        ▼
Touchpoint 1  Handoff frontmatter (.tad/templates/deliverable-handoff.md)
  CONSUMER     task_type: deliverable · pack · rubric_ref · pass_threshold ·
               deliverable_paths: []   ("Files to Modify" → "Deliverables to Produce")
        │
        ▼
   PRODUCE     Conductor-spawned PRODUCER sub-agent (or the Conductor) writes the
               artifact to deliverable_paths (research tools are Conductor-side —
               NOT Blake; contract §B.6)
        │
        ▼
Touchpoint 2  Gate 3 — Deliverable Branch (gate/SKILL.md ~:341)
  CONSUMER     spawns a FRESH independent JUDGE → scores artifact vs rubric →
               .tad/evidence/reviews/{date}-rubric-eval-{task}.md → verdict ladder
        │
        ▼
Touchpoint 3  Completion report (.tad/templates/deliverable-completion.md)
  CONSUMER     Rubric Scores table + Artifacts Produced table + gate3_verdict: marker
        │
        ▼
              Gate 4 — Deliverable Branch (gate/SKILL.md ~:758)
              rubric PASS + meets-brief + human approval (3 code subagents SKIPPED)
```

### Worked example — the Phase-3 dogfood (the proof it discriminates)

From `phase3-dogfood-report.md`, a real (not mocked) academic-research deliverable —
a literature brief on mitigating LLM-as-a-judge self-enhancement bias — ran the full
loop with **three distinct agents**:

| Step | Agent | Result |
|------|-------|--------|
| Produce | Producer sub-agent (`ac467…`, WebSearch-grounded, Conductor-side) | brief v1, 6 verified refs |
| Judge round 1 | Judge-A (`a8cc6…`, given ONLY artifact+rubric paths) | weighted **0.737 → PARTIAL** (0.013 below 0.75) → Gate 3 **BLOCK** |
| Revise | Producer (added methodology + ethics §4a + novelty framing) | brief v2, 7 refs |
| Judge round 2 | Judge-B (`a066b…`, **FRESH** — never saw Judge-A's score) | weighted **0.7725 → PASS** (≥0.75) → Gate 3 **PASS** |
| Gate 4 | Conductor | `^verdict: PASS` satisfied; 3 code subagents correctly SKIPPED |

This is the load-bearing finding: **the gate discriminated** — round 1 landed an honest
0.737 PARTIAL and blocked, not a rubber-stamp. The +0.035 in round 2 came exactly from
the methodology/ethics/reproducibility fixes that were actually made (novelty stayed
0.55). A fresh judge each round prevents anchoring on the prior score.

---

## 3. judge ≠ producer (the load-bearing rule)

> The deliverable is produced by ONE agent. The rubric score is computed by a
> **SEPARATE judge sub-agent**, spawned fresh by the gate/Conductor, whose prompt
> references **ONLY** `{deliverable_paths} + {rubric_ref} + {pass_threshold}` —
> never the producer's reasoning, persona, identity, or self-assessment.

**Why** (contract §C.2): the ai-evaluation pack's foundational rule is
**Judge ≠ Optimizer/Producer**. An agent scoring its own output exhibits measurable
**self-enhancement bias (~10–15% inflation)** — it rationalizes its own choices and
scores generously. Independent judging is the only defense; a self-scored rubric is
validation theater (the same "count ≠ signal" lesson the project repeats).

The **4 VIOLATION patterns** (contract §C.3, enforced in `gate/SKILL.md`
`Judge_Not_Producer.forbidden`):

1. The producing agent (or same session/persona) computes the rubric score for its own deliverable.
2. Passing the producer's reasoning / "why this is good" notes into the judge prompt.
3. Reusing the producer sub-agent (or its conversation) as the judge.
4. **Artifact-channel**: the judge crediting self-praise / a producer-written self-scored
   rubric embedded *inside* the artifact. The judge scores on rubric evidence it
   independently derives from the artifact's substance — never the artifact's own claims
   about its quality.

(And the "the producer already self-scored, so skip the judge" rationalization is itself
the forbidden "Express → exempt" anti-pattern applied to scoring.) If the Conductor
itself produced the artifact, the judge MUST be a distinct sub-agent — the Conductor
cannot judge its own output.

---

## 4. Gate 3 — Deliverable semantics

Lives at `gate/SKILL.md` `## Gate 3 — Deliverable Branch` (~:341), an additive sibling
section selected by a guard line when `task_type == deliverable`.

- **Rubric + threshold resolution** (BLOCKING, precedence — §5 below) runs first.
- **verdict_shape guard**: if the resolved `verdict_shape != weighted` → **BLOCK**
  (only the weighted-0-1 ladder is implemented; see §6).
- **Required subagent = an independent JUDGE** (replaces `test-runner`). Judge prompt
  is **file paths only**; output to `.tad/evidence/reviews/{date}-rubric-eval-{task}.md`
  with a per-dimension scores table, the explicit weighted-sum arithmetic, and a
  machine-readable verdict line.
- **Verdict ladder** (contract §B.5):

  ```
  IF weighted_score ≥ pass_threshold            → PASS
  ELSE IF weighted_score ≥ partial_threshold     → PARTIAL   (default 0.60)
  ELSE                                           → FAIL
  ```

  PASS → Gate 3 proceeds (KA + git checks). PARTIAL / FAIL → **BLOCK**; the producer
  revises and a **fresh judge** re-scores the revised artifact.

- **The machine-readable `verdict:` contract** — the rubric-eval file MUST contain an
  exact line on its own (lowercase key, uppercase value, no bold/emoji):
  `verdict: PASS` | `verdict: PARTIAL` | `verdict: FAIL`. This is the token **Gate 4
  greps** (`grep -E '^verdict: PASS'`). The human-readable `**Verdict**: ✅ PASS` prose
  is NOT matched by that anchor — the machine line is required.
- **gate3_verdict marker**: the Conductor edits the deliverable-completion report's
  `gate3_verdict:` frontmatter to the lowercased verdict (`pass|fail|partial`) as a
  Gate 3 post-step, so `post-write-sync.sh` emits the `gate_result` telemetry event.
- **Rubric-eval format constraint**: weaknesses MUST NOT use the `^#+ *P[0-9]-` heading
  form — that self-triggers `post-write-sync.sh`'s `expert_review_finding` parser and
  fabricates false P0/P1 telemetry. Use prose ("Weakness 1: …") or a severity table cell.

KEPT unchanged from the code path: the completion-report prerequisite, acceptance
verification (artifact ACs), risk translation, git-commit verification, and the
**Knowledge Assessment** (BLOCKING).

---

## 5. Gate 4 — Deliverable business-acceptance semantics

Lives at `gate/SKILL.md` `## Gate 4 — Deliverable Branch` (~:758), the additive sibling
that satisfies the Epic's "document Gate-4 non-dev acceptance" AC.

- **Prerequisite** (replaces the `*-testing-review-*` glob): Gate 3 passed, evidenced by
  `.tad/evidence/reviews/*-rubric-eval-*.md` containing the exact line `verdict: PASS`
  (verified by `grep -E '^verdict: PASS'`).
- **The 3 code subagents are SKIPPED for deliverables**: security-auditor /
  performance-optimizer / code-reviewer are required ONLY when `task_type != deliverable`
  — a report/audio/video artifact has no code surface. ux-expert-reviewer stays
  conditional ("if UI involved") and is N/A for these packs. The original Gate 4 block's
  3 BLOCKING code subagents apply to code task_types only and are left byte-unchanged.
- **Business acceptance = three conditions**: (a) the Gate-3 rubric verdict is PASS,
  AND (b) the artifact **meets the brief** (the handoff's artifact ACs are satisfied —
  Alex's judgment), AND (c) **explicit human approval**.
- **Knowledge Assessment** stays BLOCKING and unchanged.

`rubric-eval` is registered as a **DISTINCT** evidence type (own glob `*-rubric-eval-*`)
in the sibling section — it is never aliased into `testing-review` / `code-review`, and
the original Gate 4 block's `types:` enum stays byte-identical.

---

## 6. The pack → rubric registry (`deliverable-rubrics.yaml`)

`.tad/capability-packs/deliverable-rubrics.yaml` is a **name-keyed side-file**
(NOT `pack-registry.yaml`, which `scan-packs.sh` regenerates and would clobber — the
documented "Auto-Generated Registry → Persisted Decision State Belongs in a Side-File"
lesson). It binds each capability pack to its rubric + thresholds.

**Resolution precedence** (contract §A.2, enforced in the Gate 3 `Rubric_Resolution`
block):

1. Per-handoff frontmatter `rubric_ref` / `pass_threshold` → **frontmatter WINS**
   (per-handoff override).
2. Else → fall back to the `deliverable-rubrics.yaml` row keyed by `pack`.
3. **BOTH absent** (no frontmatter value AND no registry row / null) → **Gate 3 BLOCKS**.
   No silent default.

**`verdict_shape` field** declares how the verdict is computed:
`weighted` (Σ score×weight, ladder pass/partial/fail) · `categorical` (e.g.
BUILD/PIVOT/KILL band membership) · `checklist` (export-spec pass/fail items).
**Only `weighted` is implemented** — the Gate 3 `verdict_shape_guard` BLOCKs any
non-weighted shape so the weighted ladder cannot silently mis-score a categorical or
checklist pack.

### Current status (honest)

| pack | status | rubric | verdict_shape | dogfood |
|------|--------|--------|---------------|---------|
| **academic-research** | **active** | `scholar-eval.md`, 0.75 / 0.60 | **weighted** (implemented) | **proven** (Phase-3 dogfood) |
| ai-voice-production | **rubric-tbd** | null — `interim_rubric_source` → `audiobook-pipeline.md` (ACX RMS −23 to −18 dB) | checklist (NOT yet implemented) | no — needs TTS hardware |
| video-creation | **rubric-tbd** | null — `interim_rubric_source` → `quality.md` (export specs) | checklist (NOT yet implemented) | no — needs render hardware |
| product-thinking | **rubric-tbd** | null — `interim_rubric_source` → `checklists/fatal-flaws.md` + `per-type-validation.md` | categorical / BUILD-PIVOT-KILL (NOT yet implemented) | no — rubric authoring pending (no hardware barrier) |

- **academic-research** is the only pack that is `active` / weighted / dogfood-proven:
  it has a real 8-dim 0-1 rubric with a threshold ladder, and ran end-to-end in Phase 3.
- The other three are **registered but `rubric-tbd`**: they carry an
  `interim_rubric_source` pointer to a real on-disk reference (a source anchor for
  Phase-4 rubric authoring), but their `rubric_ref` / `pass_threshold` stay `null`.
  Their declared `verdict_shape` (categorical / checklist) is **a documented follow-up,
  not yet implemented** — the Gate 3 `verdict_shape_guard` deliberately BLOCKs them until
  a real weighted rubric (or a second verdict-shape implementation) exists. They are NOT
  usable as deliverable packs today.

Phase-4 rubric authoring must follow the project's provenance rule (*"Per-Tool Numeric
Thresholds Require Research Provenance, Not Interpolation"*) — thresholds cited to their
actual source, never interpolated. The `interim_rubric_source` files are the citation
anchors, not finished rubrics.

---

## 7. Known limitations / follow-ups

- **verdict_shape generalization is NOT done.** Only `weighted` (the scholar-eval 0-1
  ladder) is implemented. `categorical` (BUILD/PIVOT/KILL) and `checklist` (export-spec
  pass/fail) shapes are declared in the registry but **BLOCKED** by the Gate 3
  `verdict_shape_guard`. A second verdict-shape implementation (or converting each pack
  to a genuine weighted 0-1 rubric with research provenance) is the Phase-4 work.
- **ai-voice-production and video-creation cannot be dogfooded without hardware** —
  TTS compute (16GB-Mac batch-mode limits, per architecture.md) and render hardware
  respectively. Their rubrics remain TBD until a real dogfood is possible.
- **product-thinking has no hardware barrier** but its checklist/categorical validation
  is not yet a scored rubric — rubric authoring is the only blocker.
- **The producer is Conductor-side, not Blake.** Research tools (NotebookLM is
  stateful/sequential, WebSearch) cannot run inside a Blake sub-agent, so research/content
  deliverables are produced by a Conductor-spawned producer sub-agent (or the Conductor),
  and `judge ≠ producer` is defined relative to THAT producer (contract §B.6).
