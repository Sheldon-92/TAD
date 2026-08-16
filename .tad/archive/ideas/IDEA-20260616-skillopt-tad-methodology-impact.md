# Idea: SkillOpt-Informed TAD Methodology Improvements

**ID:** IDEA-20260616-skillopt-tad-methodology-impact
**Date:** 2026-06-16
**Status:** promoted
**Scope:** medium
**Source:** Deep research of microsoft/SkillOpt (7,761 stars, arXiv 2605.23904)

---

## Summary & Problem

SkillOpt treats agent skill documents as trainable state, optimized with a DL-analogous
loop (rollout → reflect → aggregate → select → update → validation gate). Three specific
findings directly impact how TAD manages its own capability packs:

1. **Full rewrite = catastrophic forgetting risk.** TAD's `pack-upgrade` workflow currently
   does full-text rewrite of pack content. SkillOpt proves bounded edit (add/delete/replace)
   with an LR schedule (cosine decay: explore early, refine late) is safer — verified rules
   survive because they're never rewritten, only new/changed rules are touched.

2. **No regression gate = drift.** TAD's `pack-dogfood` only tests "WITH-PACK vs CONTROL"
   (does the pack help vs no pack?). It does NOT test "NEW-VERSION vs OLD-VERSION" (did the
   upgrade lose anything?). SkillOpt's catastrophic data: without a validation gate, a
   self-modifying agent went from 0.554 → 0.026 accuracy (−52.8 pts). Our pack-upgrade has
   the same structural vulnerability — a rewrite that scores well on new test cases but
   silently drops proven rules from the old version.

3. **Auto-evolve blueprint.** TAD's auto-evolve Epic (2026-05-20, trace v2 + Reflexion +
   Dream + Optimize) was retired (18→1 yield). SkillOpt-Sleep explains why: missing
   validation gate, missing experience replay (associative recall of relevant past tasks),
   missing contrastive reflection (learn from good/bad contrast, not just failures). The
   Sleep six-stage pipeline (harvest → mine → replay → consolidate+gate → stage → adopt)
   is a validated blueprint if TAD revisits auto-evolve.

## Proposed Changes

### A. pack-upgrade: bounded edit mode (priority: high)

Modify `.claude/workflows/pack-upgrade.js` Upgrade stage prompt:
- FROM: "Rewrite the entire pack incorporating research findings"
- TO: "Generate a structured edit list: for each change, specify {op: add|modify|delete,
  rule_id, content, rationale}. Apply edits to the existing pack. Do not rewrite unchanged
  rules."

### B. pack-dogfood: add regression dimension (priority: high)

Modify `.claude/workflows/pack-dogfood.js`:
- After the existing CONTROL vs WITH-PACK blind eval, add a second eval:
  OLD-PACK vs NEW-PACK on the SAME test scenario.
- Persist test scenarios to `.tad/evidence/pack-evals/{pack-name}/` so they're reusable
  across upgrades (currently they're ephemeral).
- Judge rubric adds: "Which answer loses knowledge the other has?" (regression signal).

### C. Auto-evolve blueprint (priority: low — record for future)

If TAD revisits auto-evolve, the pipeline must include:
- Validation gate (strictly-greater-than on held-out tasks)
- Experience replay (recall_k most-similar past tasks via token Jaccard)
- Contrastive reflection (K rollouts per task, learn from spread)
- Staging + human adopt (never directly mutate live SKILL.md)

## Open Questions

- Should bounded edit mode be the DEFAULT for pack-upgrade, or offered as an option
  alongside full rewrite? (Full rewrite may still be needed for major restructuring.)
- What's the minimum viable regression test set size per pack? (SkillOpt uses ~20 items
  for slow update comparison.)
- Can we reuse pack-dogfood's existing CONTROL scenarios as the regression baseline, or
  do we need dedicated regression fixtures?

## Evidence

- SkillOpt paper: arXiv 2605.23904 (Microsoft, 2026-06-02)
- SkillOpt-Sleep: docs/sleep/RESULTS.md — gate stress test (−52.8 without gate)
- SkillOpt trainer.py: 3 update modes, cosine LR, selection cache
- TAD auto-evolve retirement: project_self-evolution-pruning.md (2026-06-10)
- Full repo cloned at /tmp/SkillOpt for reference

---
**Promoted To:** Handoff (via *analyze — 2026-06-16)
