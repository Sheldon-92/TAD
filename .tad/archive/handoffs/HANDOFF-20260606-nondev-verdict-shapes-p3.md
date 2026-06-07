---
task_type: deliverable
pack: product-thinking
rubric_ref: ".claude/skills/product-thinking/references/pressure-test-rubric.md"
pass_threshold: null
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/evidence/yolo/nondev-verdict-shapes", ".tad/guides"]
deliverable_paths: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 3 — Dogfood + synthetic checklist fixture + guide

**From:** Alex (Conductor) · **Epic:** EPIC-20260606-nondev-verdict-shapes.md (Phase 3/3)
**Date:** 2026-06-06

## 1. Goal
Prove the categorical deliverable lane works end-to-end and DISCRIMINATES, exercise the
checklist branch via a synthetic fixture (P1-4/DR-20260606), and update the track guide.

## 2. Dogfood design (the load-bearing proof)
Product idea under test (chosen to carry real KILL/PIVOT risk → exercises decoupling):
> **"PalateBox"** — an AI-curated monthly subscription box for artisanal hot sauces that
> taste-matches bottles to your flavor profile. Software-adjacent (ecommerce/subscription).

Run with FOUR distinct agents (judge ≠ producer):
- **Producer-A** (rigorous): genuine pressure-test of PalateBox — real WebSearch, ~6 forcing
  rounds, FACT/ASSUMPTION discipline, fatal-flaw scan, product-type adapter, BUILD/PIVOT/KILL
  verdict + confidence + 2-week plan. Honest analysis → likely PIVOT/KILL (crowded subscription
  market, churn/F2/F3 risk). Artifact → `.tad/evidence/yolo/nondev-verdict-shapes/dogfood/palatebox-rigorous.md`
- **Producer-B** (thin control): a sycophantic one-pass "analysis" of PalateBox — the kind a
  no-pack agent gives (encouraging, no real searches, no fatal-flaw scan, no adapter). Honestly
  labelled CONTROL. Artifact → `.../dogfood/palatebox-thin.md`
- **Judge-1** (fresh): score `palatebox-rigorous.md` via the rubric → expect band rigorous→PASS.
  If content_verdict is KILL/PIVOT and band is still rigorous → DECOUPLING PROVEN.
- **Judge-2** (fresh, distinct): score `palatebox-thin.md` via the rubric → expect band
  superficial→FAIL. → DISCRIMINATION PROVEN (rubric FAILs a thin analysis).
Each judge gets ONLY {artifact path, rubric path}. No producer context. Output rubric-eval to
`.tad/evidence/reviews/2026-06-06-rubric-eval-palatebox-{rigorous,thin}.md` with the machine-readable
`verdict:` line + `band:` + `content_verdict:`.

## 3. Synthetic checklist fixture (P1-4 / DR-20260606 mitigation)
Create a tiny synthetic checklist rubric + 2 artifacts under
`.tad/evidence/yolo/nondev-verdict-shapes/checklist-fixture/`:
- `synthetic-checklist-rubric.md` — required items (e.g. "format=mp3", "loudness RMS -23..-18 dB",
  "duration ≥ 60s") + 1 optional item. ≥1 required (malformed_guard satisfied).
- `artifact-pass.md` — a fake export manifest meeting all required.
- `artifact-fail.md` — a fake export manifest FAILING one required (e.g. RMS -30 dB).
A judge applies the Phase-1 checklist branch to each → prove `verdict: PASS` and `verdict: FAIL`.
Output to `.../checklist-fixture/eval-pass.md` and `eval-fail.md`. This proves the checklist gate
logic fires (PASS + FAIL) without voice/video hardware.

## 4. Guide update
Update `.tad/guides/nondev-execution-track.md`:
- Add a "categorical (rigor band)" worked-example subsection citing the PalateBox dogfood (band,
  content_verdict, discrimination + decoupling result).
- Add a "checklist (export-spec)" subsection citing the synthetic fixture (PASS + FAIL).
- Mark ai-voice / video-creation: "checklist gate logic VERIFIED via synthetic fixture;
  real-content dogfood PENDING (needs TTS/render hardware)" per DR-20260606.

## 5. Acceptance Criteria (Phase-3 AC1-AC6 from Epic)
- [ ] AC1: deliverable produced by producer ≠ judge; ≥3 distinct agents across the run (target 4)
- [ ] AC2: gate DISCRIMINATED — the thin control landed a non-PASS (superficial/FAIL) band; the rigorous one a higher band
- [ ] AC3: decoupling — if the rigorous artifact concluded non-BUILD (PIVOT/KILL) it still scored rigorous/PASS (or explicitly note if not exercised because it concluded BUILD)
- [ ] AC4: guide updated with categorical + checklist examples; voice/video marked dogfood-pending
- [ ] AC5: EPIC-COMPLETION.md records all agent IDs + per-artifact band/verdict/content_verdict
- [ ] AC6: synthetic checklist fixture run → one `verdict: PASS` + one `verdict: FAIL` recorded

## 6. Notes
- A clean first-pass PASS with no non-PASS evidence is a WEAK result — the thin control guarantees a real discrimination data point.
- Judges must independently derive scores from artifact substance — ignore any self-praise inside an artifact (artifact-channel rule).
