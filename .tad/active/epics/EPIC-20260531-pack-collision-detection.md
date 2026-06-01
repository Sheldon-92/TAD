# Epic: Pack Collision Detection

**Epic ID**: EPIC-20260531-pack-collision-detection
**Created**: 2026-05-31
**Owner**: Alex

---

## Objective
Give TAD the ability to detect when two co-loaded capability packs issue *contradicting* directives (e.g. one bans `Inter`, another endorses it), auto-resolve cross-category collisions by precedence, escalate same-category ties to the human, and surface the verdict to Alex/Blake. Closes the cross-model-audit gap "zero collision detection" (architecture.md YOLO Audit Findings 2026-05-15). Orthogonal to the lean-trustworthy Epic's P5 (per-pack behavioral eval): P5 asks "is each pack good alone?", this asks "do two co-loaded packs contradict?".

## Success Criteria
- [ ] `scan-collisions.sh` (grep-seed) + LLM-confirm pass produce a `pack-collisions.yaml` registry of confirmed cross-pack contradictions.
- [ ] The 3 known real contradictions (Inter / APCA-vs-WCAG / testing-pyramid) are caught, hand-re-derived at acceptance (count≠signal), and routed correctly (cross-category→auto-resolve, same-category→escalate).
- [ ] Precedence engine (security>correctness>a11y>performance>style) auto-resolves cross-category collisions with a VISIBLE log; same-category collisions escalate.
- [ ] Surfacing wired into Alex step4_5 AND Blake 1_5a (P2 — done LAST, after the other Alex lands lean-trustworthy P4/P5).

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Collision detector engine + data + fixtures (no SKILL edits) | ✅ Done | HANDOFF-20260531-pack-collision-detection-phase1.md (d296374 + 1b714f4) | scan-collisions.sh + LLM-confirm contract + pack-collisions.yaml + 3 fixtures + reference doc |
| 2 | Wire surfacing into Alex step4_5 + Blake 1_5a | ⬚ Planned | — | Consumers read pack-collisions.yaml and surface resolution one-liner |

### Phase Dependencies
P2 depends on P1 (needs pack-collisions.yaml schema + the surfacing one-liner format). P2 ALSO gated on the OTHER Alex finishing lean-trustworthy P4/P5 (both edit alex/SKILL.md) → P2 starts only after that file is free, to avoid a 5825-line merge conflict.

### Derived Status
- **Status**: In Progress (P1 🔄)
- **Progress**: 0/2

---

## Phase Details

### Phase 1: Collision detector engine + data + fixtures

**Status:** ✅ Done (d296374 + 1b714f4) — Gate 3+4 PASS, 4 reviewers 0 P0, all P1s fixed, hand-re-derivation confirmed real
**Execution:** YOLO full-auto

#### Scope
Build the collision-detection engine and its data/fixtures using ONLY new files — zero edits to `alex/SKILL.md` or `blake/SKILL.md` (those are P2, and alex/SKILL.md is concurrently owned by the other Alex). Deliver: (1) `scan-collisions.sh` that mirrors `scan-packs.sh` conventions and does the GREP-SEED half of the hybrid detector — for each pack pair sharing ≥1 keyword, grep curated opposing-directive signatures and emit CANDIDATE collisions; (2) a documented LLM-CONFIRM contract (how an agent confirms each candidate is a true opposing directive, assigns a category per side, and computes resolution) producing the final `pack-collisions.yaml`; (3) the precedence resolution engine semantics; (4) 3 acceptance fixtures from the verified real contradictions; (5) a reference doc. NOT in scope: editing Alex step4_5 / Blake 1_5a (P2); auto-fixing packs; runtime per-session detection; touching pack-registry.yaml (read-only — P5 owns its writes).

#### Input
- Grounding: `.tad/evidence/yolo/pack-collision-detection/phase1-grounding.md` (verified contradictions + engine semantics + mirror conventions).
- `.tad/scripts/scan-packs.sh` (sibling to mirror), `.tad/capability-packs/pack-registry.yaml` (READ-ONLY input).
- The 3 verified contradiction sources (file:line in grounding).

#### Output
- `.tad/scripts/scan-collisions.sh` (CREATE) — grep-seed candidate detector. `set -euo pipefail`, BSD-safe, NOT a hook, MUST NOT be added to settings.json.
- `.tad/capability-packs/pack-collisions.yaml` (CREATE) — confirmed-collision registry (final, post-LLM-confirm). Separate file from pack-registry.yaml.
- `.tad/scripts/collision-signatures.txt` or inline signature list (CREATE) — curated opposing-directive grep signatures (seed set covers the 3 fixtures).
- `.tad/guides/pack-collision-detection.md` (CREATE) — reference doc: hybrid flow, precedence engine, category list, resolution semantics, surfacing one-liner formats, LLM-confirm contract, anti-validation-theater acceptance rule.
- `.tad/evidence/fixtures/pack-collisions/` (CREATE) — the 3 fixtures + expected-classification (cross-cat-resolve / same-cat-escalate) for each.

#### Acceptance Criteria
- [ ] AC1: `bash .tad/scripts/scan-collisions.sh --help` runs clean (exit 0); script mirrors scan-packs.sh conventions (set -euo pipefail, BSD-safe awk/grep, arg-parse-before-derive-OUTPUT, anchored frontmatter extraction). Verify: `bash -n` passes + `grep -c 'set -euo pipefail' scan-collisions.sh` == 1.
- [ ] AC2: scan-collisions.sh, run over the real packs, emits CANDIDATE collisions for all 3 known pairs (web-ui-design×web-frontend Inter; web-ui-design×web-frontend/web-testing contrast; web-frontend×web-testing pyramid). Verify by hand-re-deriving each candidate's two file:line refs against the live pack files (NOT a count — count≠signal, 2026-05-30 lesson).
- [ ] AC3: `pack-collisions.yaml` schema documented + populated for the 3 confirmed collisions, each with: {pack_a, pack_b, topic, a_says(file:line+quote), b_says(file:line+quote), category_a, category_b, resolution}. Inter → resolution=auto, winner=web-frontend(performance), loser=web-ui-design(style), rule="performance>style". Contrast → resolution=escalate, reason=same-category(a11y). Pyramid → resolution=escalate, reason=same-category(testing).
- [ ] AC4: precedence engine semantics documented in the reference doc: ordered categories security/safety/compliance/data-integrity(1)>correctness(2)>a11y(3)>performance(4)>style(5); CROSS-category→auto-resolve(lower wins)+visible log; SAME-category→escalate (no silent pick). Every resolution (auto AND escalated) is logged (no-silent-caps rule).
- [ ] AC5: surfacing one-liner formats specified (for P2 consumers): cross-cat → "⚙️ resolved: {winner} over {loser} ({rule})"; same-cat → "⚠️ unresolved: {a} vs {b} — human decides ({topic})".
- [ ] AC6: anti-validation-theater guard documented + applied: acceptance hand-re-derives every flagged collision's file:line; the reference doc states "N collisions found" is NOT acceptance.
- [ ] AC7: scan-collisions.sh is NOT registered in `.claude/settings.json` (grep confirms absence); reference doc states it's a CLI tool, not a hook.
- [ ] AC8: ZERO edits to alex/SKILL.md and blake/SKILL.md in this phase (git diff confirms only new files). pack-registry.yaml unmodified (read-only).

#### Files Likely Affected
- `.tad/scripts/scan-collisions.sh` (CREATE)
- `.tad/scripts/collision-signatures.txt` (CREATE, or inline in script)
- `.tad/capability-packs/pack-collisions.yaml` (CREATE)
- `.tad/guides/pack-collision-detection.md` (CREATE)
- `.tad/evidence/fixtures/pack-collisions/*.md` (CREATE)

#### Dependencies
None (can execute independently; reads pack-registry.yaml + pack files only).

#### Notes
- ⚠️ Concurrency: the other Alex runs lean-trustworthy P4/P5 in this repo. P1 creates only new files; commits interleave safely. Blake sub-agent uses worktree isolation.
- The Inter fixture IS the dangerous case (silent auto-resolve would kill a legit next/font use) — it validates "auto-resolve + visible log".
- Same-category collisions (contrast, pyramid) prove precedence has a deliberate boundary → escalate, never silent-pick within a category.
- Hybrid split keeps determinism (grep) AND false-positive defense (LLM-confirm). Per 2026-05-30, a pure grep collision-scanner is itself validation-theater-prone.

### Phase 2: Wire surfacing into Alex step4_5 + Blake 1_5a

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Wire the P1 collision registry into the two pack-loading consumers: Alex `step4_5` (Pack Awareness Scan) and Blake `1_5a` (independent pack re-detection). When ≥2 packs load, the consumer reads `pack-collisions.yaml`, finds rows where both pack_a and pack_b are in the loaded set, and surfaces the P1 one-liner (auto-resolved or escalated). NOT in scope: changing P1 detection/resolution logic.

#### Input
- P1 outputs: pack-collisions.yaml schema + surfacing one-liner formats + reference doc.
- alex/SKILL.md step4_5, blake/SKILL.md 1_5a (now free — other Alex's P4/P5 landed).

#### Output
- alex/SKILL.md step4_5 (MODIFY) — read pack-collisions.yaml after pack match, surface collisions for the loaded pair.
- blake/SKILL.md 1_5a (MODIFY) — same surfacing on Blake's side.

#### Acceptance Criteria
- [ ] AC1: step4_5 reads pack-collisions.yaml when ≥2 packs load and surfaces the correct one-liner for any loaded colliding pair.
- [ ] AC2: Blake 1_5a does the same independently.
- [ ] AC3: both edits are additive (no removal of constraint rules); MUST/VIOLATION/forbidden counts in both SKILLs unchanged.
- [ ] AC4: a co-load fixture (web-ui-design+web-frontend) produces the Inter "⚙️ resolved: web-frontend over web-ui-design (performance>style)" line.

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — step4_5 only)
- `.claude/skills/blake/SKILL.md` (MODIFY — 1_5a only)

#### Dependencies
Phase 1 + the other Alex's lean-trustworthy P4/P5 landing (alex/SKILL.md free). **Conductor PAUSES here in YOLO; resumes P2 on explicit go.**

#### Notes
Smallest phase. Gated on file-availability, not logic. Byte-careful additive edits (mirror P3 progressive-disclosure SAFETY discipline: constraint-token counts must hold).

---

## Context for Next Phase
{updated after each *accept}

### Completed Work Summary
- Phase 1 ✅ (d296374 + 1b714f4): `scan-collisions.sh` (grep-seed, scans `.claude/skills/` canonical tree, 2.2s) + `collision-signatures.txt` (@@@-delimited, 3 seeds) + `pack-collisions.yaml` (3 confirmed: inter→auto perf>style, contrast→escalate a11y, pyramid→escalate correctness) + `pack-collision-detection.md` guide (precedence engine + LLM-confirm contract + anti-theater rule) + 3 fixtures. Gate 3+4 PASS; 4 reviewers 0 P0.

### Decisions Made So Far
- Hybrid detect (grep-seed + LLM-confirm) — anti-validation-theater.
- Build-time, not runtime. Output separate pack-collisions.yaml (pack-registry.yaml read-only to dodge P5 write-conflict).
- **Canonical scan tree = `.claude/skills/`** (runtime-loaded tree, where contradictions live + P2 consumers load) — NOT `.tad/capability-packs/` (design-review P0-2).
- Auto-resolve cross-category by precedence (security>correctness>a11y>perf>style) + VISIBLE log; escalate same-category; uncategorizable→escalate.
- P1 = new files only (zero SKILL edits) so it's concurrency-safe with the other Alex; P2 wiring deferred until alex/SKILL.md is free.

### Known Issues / Carry-forward
- ✅ P2 UNBLOCKED — the other Alex's lean-trustworthy Epic (P4/P5) completed + archived 2026-05-31; alex/SKILL.md is now free.
- Bonus video-creation candidate was a FALSE POSITIVE (CJK comm LC_ALL=C bug) — fixed; the anti-theater spot-check caught it.
- P2 surfacing one-liner (`⚙️/⚠️`) is specified in the guide; P2 must also carry the loser's quote for the human spot-check (architect P2-B).
- Candidate `confirmed_by`/`drop_rationale` fields are advisory (single-user enforcement stance) — acceptable.

### Next Phase Scope
P2 (READY): wire pack-collisions.yaml into Alex step4_5 + Blake 1_5a (additive, byte-careful; constraint-token counts must hold per P3 progressive-disclosure SAFETY discipline).

---

## Notes
Triggered 2026-05-31 by a parallel-audit *discuss session (6 scouts) while the primary Alex drove lean-trustworthy P4/P5; this Epic is the chosen non-colliding optimization direction.
