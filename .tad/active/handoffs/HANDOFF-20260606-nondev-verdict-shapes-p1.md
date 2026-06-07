---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/gate"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Gate verdict_shape implementation (categorical + checklist)

**From:** Alex (Conductor) · **To:** Blake sub-agent
**Epic:** EPIC-20260606-nondev-verdict-shapes.md (Phase 1/3)
**Date:** 2026-06-06

## 1. Executive Summary
The Gate 3 deliverable branch in `.claude/skills/gate/SKILL.md` only supports
`verdict_shape: weighted`. The `verdict_shape_guard` HARD-BLOCKs `categorical` and
`checklist`, so product-thinking / ai-voice / video-creation deliverables cannot pass a
gate. Implement both shapes — purely ADDITIVE; the `weighted` ladder and all non-deliverable
code paths stay BYTE-UNCHANGED.

## 2. Grounded Against (Alex read these heads at design time)
- `.claude/skills/gate/SKILL.md` Gate 3 deliverable branch: verdict_shape_guard L382-384, Required_Subagent.judge_prompt_constraint L395-399, output_format L401-406, Verdict_Mapping L437-443
- `.claude/skills/gate/SKILL.md` Gate 4 deliverable branch L758-821 (already greps `^verdict: PASS` — shape-agnostic)
- `.tad/capability-packs/deliverable-rubrics.yaml` (verdict_shape field present per pack: academic-research=weighted, product-thinking=categorical, ai-voice/video=checklist)

## 3. Exact Edits (apply precisely — do not improvise structure)

### Edit A — `verdict_shape_guard` (replace the 3 lines at ~L382-384)
Replace:
```yaml
  verdict_shape_guard:
    rule: "If the resolved verdict_shape != weighted → BLOCK Gate 3"
    message: "Phase-4 categorical/checklist verdict shapes unimplemented — the weighted-0-1 ladder (Verdict_Mapping) must NOT silently mis-score a non-weighted pack. Only verdict_shape: weighted is supported in Phase 2/3."
```
With:
```yaml
  verdict_shape_guard:
    rule: "If the resolved verdict_shape NOT IN {weighted, categorical, checklist} → BLOCK Gate 3"
    supported: [weighted, categorical, checklist]
    message: "Unknown verdict_shape — supported: weighted (0-1 ladder), categorical (rigor band), checklist (export-spec pass/fail). An unrecognized shape must NOT be silently mis-scored."
```

### Edit B — `Verdict_Mapping` (extend; KEEP the existing weighted `rule:` block byte-identical)
The existing block is:
```yaml
Verdict_Mapping:
  rule: |
    IF weighted_score ≥ pass_threshold           → PASS
    ELSE IF weighted_score ≥ partial_threshold    → PARTIAL   (default partial_threshold = 0.60)
    ELSE                                          → FAIL
  on_pass: "Gate 3 proceeds (KA + git checks)."
  on_partial_or_fail: "BLOCK Gate 3; the producer (§B.6) revises and re-runs — a FRESH judge re-scores the revised artifact (each re-score is a new judge spawn)."
```
INSERT the two sub-blocks BETWEEN the weighted `rule:` block and `on_pass:` — do NOT alter
the `rule:`, `on_pass:`, or `on_partial_or_fail:` lines:
```yaml
  # ── verdict_shape: categorical (e.g. product-thinking BUILD/PIVOT/KILL) ──
  categorical:
    rule: |
      The judge assigns a RIGOR band from the rubric: rigorous | partial | superficial.
      rigorous → PASS · partial → PARTIAL · superficial → FAIL
    rigor_independence: |
      ⚠️ The band scores the RIGOR of the analysis, NOT its content conclusion. For
      BUILD/PIVOT/KILL packs: a rigorously-argued KILL is `rigorous` (PASS); a hand-wavy
      BUILD is `superficial` (FAIL). The judge MUST NOT raise or lower the band based on
      whether the artifact concluded BUILD vs PIVOT vs KILL.
    decoupling_firewall: |
      (P1-1 hardening — structural, not just prose:)
      1. ORDER OF EMISSION: the judge MUST write `band:` WITH its per-dimension rigor
         justification BEFORE it states `content_verdict:`. The band is committed before the
         conclusion is named, so the conclusion cannot anchor the band.
      2. CONCLUSION-NEUTRAL CRITERIA: the rubric's band criteria (Phase 2) MUST be phrased
         about rigor (evidence depth, fatal-flaw coverage, FACT/ASSUMPTION discipline,
         adapter use) — NEVER "concludes BUILD" / "is optimistic".
      3. SWAP TEST (stated in the judge prompt): "If you flipped this artifact's final
         BUILD/PIVOT/KILL word and changed nothing else, would the band change? If yes, you
         are scoring the conclusion — re-score on rigor only."
    extra_output: |
      The rubric-eval ALSO emits (own lines, for traceability — NOT gate-determining):
        band: rigorous|partial|superficial
        content_verdict: BUILD|PIVOT|KILL   (the artifact's own conclusion; recorded, never maps to gate verdict)
      The machine-readable `verdict: PASS|PARTIAL|FAIL` line (derived from band) remains the Gate 4 token.
      ⚠️ `band:` (with justification) MUST appear ABOVE `content_verdict:` in the file (order firewall).
  # ── verdict_shape: checklist (e.g. ai-voice / video-creation export specs) ──
  checklist:
    malformed_guard: |
      (P1-2 guard:) the rubric MUST define ≥1 REQUIRED item. A checklist rubric with zero
      required items → BLOCK Gate 3 ("malformed checklist rubric — cannot ever FAIL, define
      ≥1 required item"). This prevents an all-optional rubric from becoming a gate that
      always PASSes.
    rule: |
      The rubric lists REQUIRED items + OPTIONAL items (export-spec pass/fail: dB / format / duration).
      ALL required pass                     → PASS
      ALL required pass, ≥1 optional fail   → PARTIAL
      ANY required fail                     → FAIL
    evidence_independence: |
      (P1-2 artifact-channel guard:) the judge derives each item's pass/fail from the
      artifact's substance / measurable specs it independently checks — NEVER from the
      artifact's own claim that it passed (same Judge_Not_Producer artifact-channel rule).
    extra_output: |
      The rubric-eval emits a per-item | item | required? | pass/fail | table; the
      `verdict:` line is derived per the rule above.
```

### Edit C — `judge_prompt_constraint` (append a shape-aware paragraph after the existing weighted framing at ~L395-399; do NOT delete the existing blue-team text)
Append:
```yaml
  judge_prompt_by_shape: |
    weighted   → "Report dimension scores + weighted average + verdict." (existing)
    categorical→ "Assign a RIGOR band (rigorous|partial|superficial) per the rubric, then map
                  to verdict. Score the RIGOR of the analysis ONLY — a rigorously-argued KILL
                  is rigorous; do NOT reward/punish the BUILD/PIVOT/KILL conclusion. Emit
                  `band:`, `content_verdict:` (recorded, not gate-determining), and `verdict:`."
    checklist  → "Evaluate each required/optional export-spec item pass/fail per the rubric,
                  then map to verdict. Emit the item table and `verdict:`."
    All shapes keep judge≠producer + file-paths-only (no producer reasoning/persona/identity).
```

### Edit D — `output_format` (ADD one bullet noting shape-conditionality; do NOT edit the existing weighted bullets)
Add after the existing weighted_score bullet:
```yaml
    - "For verdict_shape categorical/checklist the weighted_score arithmetic bullet is replaced by the band line / item table respectively; the `verdict:` machine-readable line is REQUIRED for ALL shapes (shape-agnostic Gate 4 token)."
```

### Edit E — Gate 4 deliverable branch (~L782-784): add ONE clarifying note (no logic change)
After the `verify_note:` line, add:
```yaml
  shape_agnostic_note: "The `^verdict: PASS` token is shape-agnostic — weighted/categorical/checklist all emit it. Gate 4 needs no per-shape branch."
```

### Edit F — generalize the two remaining weighted-only spots in Gate 3 (P1-3, arch review)
These are weighted-hardcoded and would mis-instruct/mis-check a categorical/checklist deliverable.

**F1 — judge_prompt_constraint blue-team line (~L396-397).** Replace:
```yaml
    Blue-team framing: "You are an independent reviewer. Score the artifact at {deliverable_paths}
    against the rubric at {rubric_ref}. Report dimension scores + weighted average + verdict."
```
With:
```yaml
    Blue-team framing: "You are an independent reviewer. Score the artifact at {deliverable_paths}
    against the rubric at {rubric_ref}. Report per the resolved verdict_shape (see judge_prompt_by_shape) + the machine-readable verdict line."
```

**F2 — Gate 3 Critical Check item (~L473).** Replace:
```yaml
  - [ ] Rubric weighted score ≥ pass_threshold (scored by independent judge)
```
With:
```yaml
  - [ ] Rubric verdict PASS per resolved verdict_shape — weighted: score ≥ pass_threshold · categorical: band = rigorous · checklist: all required items pass (scored by independent judge)
```

## 4. Acceptance Criteria (Phase-1 AC1-AC8)
- [ ] AC1: verdict_shape_guard BLOCKs only shapes ∉ {weighted, categorical, checklist}
- [ ] AC2: weighted Verdict_Mapping `rule:` + on_pass/on_partial_or_fail byte-identical to pre-change (`git diff` shows only INSERTED lines around them, no modified weighted lines)
- [ ] AC3: categorical branch present + judge prompt explicitly decouples rigor from BUILD/PIVOT/KILL (grep `rigor` + `KILL` decoupling sentence) + order-of-emission firewall present (`band:` justified before `content_verdict:`)
- [ ] AC4: checklist branch maps required/optional → verdict AND has the ≥1-required malformed_guard
- [ ] AC5: `verdict:` machine-readable line still mandated for all shapes (Edit D bullet)
- [ ] AC6: diff scoped to gate/SKILL.md deliverable-branch additive lines only — no non-deliverable path touched (Edits A-F all inside the Gate 3/4 deliverable branches)
- [ ] AC7: confirm no codex mirror of gate verdict_shape logic exists (`grep -l verdict_shape .tad/codex/*.md` → empty; manual-gates.md is a generic guide, 0 verdict_shape refs) so no parity regen needed
- [ ] AC8: Edit F applied — no weighted-only judge framing (L397) or Critical-Check item (L473) left that a categorical/checklist deliverable cannot satisfy

## 5. Verification Commands (run after edit)
```bash
cd "/Users/sheldonzhao/01-on progress programs/TAD"
# AC1: guard supported-list line present (P1 fix: grep the supported: line directly, not -A1)
grep -q 'supported: \[weighted, categorical, checklist\]' .claude/skills/gate/SKILL.md && echo AC1-OK
# AC2: weighted ladder line still present verbatim
grep -q 'IF weighted_score ≥ pass_threshold           → PASS' .claude/skills/gate/SKILL.md && echo AC2-weighted-line-OK
# AC3: categorical decoupling + order firewall
grep -q 'rigorously-argued KILL' .claude/skills/gate/SKILL.md && echo AC3-decouple-OK
grep -q 'ORDER OF EMISSION' .claude/skills/gate/SKILL.md && echo AC3-firewall-OK
# AC4: checklist branch + malformed guard
grep -q 'ALL required pass                     → PASS' .claude/skills/gate/SKILL.md && echo AC4-OK
grep -q 'malformed checklist rubric' .claude/skills/gate/SKILL.md && echo AC4-guard-OK
# AC7: no codex mirror of verdict_shape logic (manual-gates.md is generic — 0 refs)
test -z "$(grep -l verdict_shape .tad/codex/*.md 2>/dev/null)" && echo AC7-no-codex-verdict_shape-mirror
# AC8: no weighted-only judge framing left
grep -q 'Report per the resolved verdict_shape' .claude/skills/gate/SKILL.md && echo AC8-judgeframing-OK
grep -q 'Rubric verdict PASS per resolved verdict_shape' .claude/skills/gate/SKILL.md && echo AC8-criticalcheck-OK
# sanity: code-fence balance even
python3 -c "print('fences-even' if open('.claude/skills/gate/SKILL.md').read().count('\`\`\`')%2==0 else 'FENCE-IMBALANCE')"
```

## 5b. Audit Trail (Gate 2 design review — 2 independent reviewers)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P1: AC1 `grep -A1` misses `supported:` line | §5 AC1 cmd rewritten to grep `supported:` line | Resolved |
| code-reviewer | P1: AC7 `grep -i gate` false-matches manual-gates.md | §5 AC7 cmd → `grep -l verdict_shape .tad/codex/*.md` | Resolved |
| backend-architect | P1-1: rigor/conclusion decoupling prose-only | Edit B `decoupling_firewall` (order-of-emission + swap test) | Resolved |
| backend-architect | P1-2: checklist collapses on zero-required + artifact-channel leak | Edit B checklist `malformed_guard` + `evidence_independence` | Resolved |
| backend-architect | P1-3: weighted-only Critical-Check L473 + judge framing L397 not in edit set | Edit F (F1+F2) added | Resolved |
| backend-architect | P1-4: checklist shipped with zero dogfood = validation theater | Phase 3 AC6 synthetic checklist fixture + DR-20260606 | Deferred-to-P3 (mitigated) |
| code-reviewer / backend-architect | P0 count | — | 0 P0 (both CONDITIONAL PASS) |

## 6. Important Notes
- Byte-preservation of the weighted path is the load-bearing SAFETY AC (lean-trustworthy byte-identity lesson). Use surgical Edit, not rewrite.
- gate/SKILL.md is NOT a codex-mirrored file (only alex/blake are) — no regen-codex needed.
- This is `task_type: yaml` (prose/YAML protocol edit) — no build/test/lint; Gate 3 = Layer 2 expert review on the diff.
