---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake"]
skip_knowledge_assessment: no
gate4_delta: []
---

# HANDOFF — Pack Collision Detection P2: Wire surfacing into Alex step4_5 + Blake 1_5a

**From:** Alex (YOLO Conductor) · **To:** Blake · **Epic:** EPIC-20260531-pack-collision-detection.md (Phase 2/2)
**Date:** 2026-05-31 · **Version:** 1.0

## 1. Task
Wire the P1 `pack-collisions.yaml` registry into the two pack-loading consumers so that when ≥2 packs co-load, the relevant collision row is surfaced. **ADDITIVE edits only** — insert new sub-steps, remove/modify NOTHING. This is SAFETY-adjacent (live routing SKILLs): constraint-token counts MUST hold.

## 2. ⚠️ SAFETY baselines (verify BEFORE and AFTER)
- `alex/SKILL.md`: 5839 lines; `grep -cE 'MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|NOT_via_alex_auto'` = **132** (must stay ≥132).
- `blake/SKILL.md`: 1971 lines; same grep = **49** (must stay ≥49).
- The inserted content carries ZERO constraint tokens → counts will hold. If either count changes, STOP — you removed something.

## 3. Edit 1 — Alex `step4_5` (alex/SKILL.md, "Pack Awareness Scan")
INSERT a new sub-step between step 5 (ends "Pack content is now in context…") and step 6 ("If no match: skip silently"). Exact text to insert (indented to match the surrounding `action: |` block, same indent as `5.` and `6.`):

```
        5b. Collision check (only if ≥2 packs were loaded in step 5):
           → Read .tad/capability-packs/pack-collisions.yaml (if absent or parse error → skip silently)
           → For each collision row where BOTH pack_a AND pack_b are in the loaded set:
             - resolution: auto → "⚙️ resolved: {winner} over {loser} ({rule}) — {topic}. loser said: \"{loser quote}\" (verify it isn't independently violated)"
             - resolution: escalate → "⚠️ unresolved: {pack_a} vs {pack_b} — human decides ({topic}); full quotes in pack-collisions.yaml"
           → Advisory surfacing ONLY — does NOT block, does NOT auto-edit packs, does NOT change which packs loaded.
```

## 4. Edit 2 — Blake `1_5a_pack_detection` (blake/SKILL.md)
INSERT a new sub-step between step 2 (the matched-pack load loop, ends "applying quality rules during implementation") and step 3 ("If no pack matches: skip silently"). Exact text (indent to match `3.` under the `action: |`):

```
          2.5 Collision check (only if ≥2 packs loaded above):
             → Read .tad/capability-packs/pack-collisions.yaml (if absent or parse error → skip silently)
             → For each row where BOTH pack_a AND pack_b are loaded:
               - resolution: auto → "⚙️ resolved: {winner} over {loser} ({rule}) — {topic}"
               - resolution: escalate → "⚠️ unresolved: {pack_a} vs {pack_b} — human decides ({topic})"
             → Advisory only; does NOT block implementation.
```

## 5. Files to Modify
- `.claude/skills/alex/SKILL.md` — step4_5 only (additive 5b).
- `.claude/skills/blake/SKILL.md` — 1_5a_pack_detection only (additive 2.5).

## 6. Acceptance Criteria (§9.1)
| # | AC | Verification | Expected |
|---|----|-----|------|
| AC1 | alex constraint count held | `grep -cE 'MUST NOT\|VIOLATION\|MANDATORY\|forbidden_implementations\|NOT_via_alex_auto' .claude/skills/alex/SKILL.md` | **≥132** (use bare `\|`→`|` when running; this table-cell shows escaped) |
| AC2 | blake constraint count held | same grep on blake/SKILL.md | **≥49** |
| AC3 | step4_5 5b present + reads pack-collisions.yaml | `grep -c 'pack-collisions.yaml' .claude/skills/alex/SKILL.md` | ≥1 |
| AC4 | 1_5a 2.5 present | `grep -c 'pack-collisions.yaml' .claude/skills/blake/SKILL.md` | ≥1 |
| AC5 | both one-liner forms in each | `grep -cF '⚙️ resolved:'` and `grep -cF '⚠️ unresolved:'` in BOTH files | ≥1 each |
| AC6 | additive only — no lines removed | `git diff .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` shows only `+` lines (zero `-` lines except pure context) | only insertions |
| AC7 | YAML still well-formed | the inserted blocks sit inside the existing `action: |` literal scalar (no structural break); eyeball indent | consistent indent |
| AC8 | co-load reasoning fixture | manually: if web-ui-design + web-frontend both loaded → step4_5 5b would surface "⚙️ resolved: web-frontend over web-ui-design (performance>style) — inter-font" (trace the logic against pack-collisions.yaml) | logic produces the Inter line |

## 7. Important Notes
- ADDITIVE ONLY. The single most important check is AC6 (zero `-` lines) + AC1/AC2 (counts held). The "rewiring prose can trip a grep -c SAFETY count" lesson (architecture.md 2026-05-31) — here we avoid it entirely by adding, not rewording.
- Do NOT touch step1d (other Alex's P4 AC-linter wiring), the anti_rationalization_registry, or any forbidden_implementations block.
- Scoped `git add .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` only.

## Required Evidence Manifest
```yaml
required_evidence:
  - path: .claude/skills/alex/SKILL.md
    proves: "AC1/AC3/AC5/AC6 — additive 5b, count held"
  - path: .claude/skills/blake/SKILL.md
    proves: "AC2/AC4/AC5/AC6 — additive 2.5, count held"
  - path: .tad/evidence/yolo/pack-collision-detection/phase2-gate-report.md
    proves: "Conductor Gate 3+4 — constraint counts re-derived, AC8 fixture traced"
```
