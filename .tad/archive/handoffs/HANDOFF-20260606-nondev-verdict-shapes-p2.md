---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/product-thinking", ".tad/capability-packs/product-thinking"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: product-thinking categorical rubric

**From:** Alex (Conductor) · **To:** Blake sub-agent
**Epic:** EPIC-20260606-nondev-verdict-shapes.md (Phase 2/3)
**Date:** 2026-06-06

## 1. Executive Summary
Author a CATEGORICAL rubric for product-thinking deliverables (pressure-test analyses) that
scores ANALYSIS RIGOR and maps to bands {rigorous|partial|superficial} — consumed by the
Phase-1 Gate-3 categorical branch. Register it in deliverable-rubrics.yaml (status active).
The rubric is the DISCRIMINATION instrument: it must be able to give a thin pressure-test a
non-PASS band, and it must score rigor INDEPENDENT of the BUILD/PIVOT/KILL conclusion.

## 2. Grounded Against (Alex read these)
- `.claude/skills/product-thinking/skills/pressure-test.md` — 6 forcing rounds, anti-sycophancy rules, Step-0 product-type detection + adapter load, real-data search per round, BUILD/PIVOT/KILL verdict + confidence + 2-week validation plan
- `.claude/skills/product-thinking/checklists/fatal-flaws.md` — 15 universal killers, rule "2+ fatal flaws = KILL"
- `.claude/skills/product-thinking/adapters/*.md` — software/hardware/ecommerce/service/content/marketplace
- `.claude/skills/product-thinking/examples/pressure-test-verdict.md` — discriminative markers (/pressure-test, 6 rounds, BUILD/PIVOT/KILL, adapter, FACT/ASSUMPTION)
- `.tad/capability-packs/deliverable-rubrics.yaml` product-thinking row (rubric-tbd → make active)
- Source dir EXISTS at `.tad/capability-packs/product-thinking/` → rubric must live in source dir + be mirrored to `.claude/skills/` installed location

## 3. Deliverable Spec

### 3a. CREATE the rubric (identical bytes in BOTH locations)
Path A (canonical source): `.tad/capability-packs/product-thinking/references/pressure-test-rubric.md`
Path B (installed, judge reads here): `.claude/skills/product-thinking/references/pressure-test-rubric.md`

The rubric MUST contain:
1. **Header** stating: verdict_shape categorical; the Gate judges RIGOR not the BUILD/PIVOT/KILL
   conclusion; a rigorously-argued KILL is `rigorous` (PASS). Cite the Phase-1 decoupling firewall.
2. **5 rigor dimensions**, each with explicit rigorous / partial / superficial criteria:
   - D1 **Adversarial rigor** — ran ~6 forcing rounds, took hard positions, challenged the
     STRONGEST claim, refused category-level answers (demanded real names). [cite pressure-test.md]
   - D2 **Evidence grounding** — real data searched each round; FACT vs ASSUMPTION labeled;
     behavior over opinion ("actively tried to solve" not "would be interested"). [cite pressure-test.md]
   - D3 **Fatal-flaw analysis** — scanned the 15 killers, named ≤3 most relevant, applied the
     "2+ fatal flaws = KILL" rule. [cite fatal-flaws.md]
   - D4 **Verdict justification** — BUILD/PIVOT/KILL tied to the evidence, with confidence +
     a concrete 2-week validation plan; not a vague "could work". [cite pressure-test.md]
   - D5 **Product-type adapter use** — detected the product type and actually applied that
     adapter's data sources / wedge wording. [cite adapters/]
3. **Band decision tree** (aggregation):
   - `rigorous` (→PASS): ≥4 of 5 dimensions rigorous AND zero dimension superficial AND D1 (adversarial rigor) is rigorous
   - `superficial` (→FAIL): D1 superficial OR ≥2 dimensions superficial
   - `partial` (→PARTIAL): everything else
   (D1 is load-bearing — a sycophantic non-adversarial analysis can never be `rigorous`.)
4. **Anti-theater / decoupling rule** (verbatim intent): "Score rigor ONLY. If flipping the
   final BUILD/PIVOT/KILL word would change your band, you are scoring the conclusion — re-score.
   A rigorously-argued KILL is rigorous. content_verdict is recorded separately, never gates."
5. **Judge output contract**: emit per-dimension band table → `band:` (with justification)
   ABOVE `content_verdict:` → derived `verdict: PASS|PARTIAL|FAIL`. (Matches Phase-1 order firewall.)
6. **Judge-usable from file-path-only** — no producer context needed; everything the judge
   needs is in the rubric + the artifact.

### 3b. REGISTER in deliverable-rubrics.yaml — update the product-thinking row
```yaml
  product-thinking:
    rubric_ref: ".claude/skills/product-thinking/references/pressure-test-rubric.md"
    pass_threshold: null        # categorical uses bands, not a numeric threshold
    partial_threshold: null
    verdict_shape: categorical
    dogfood_capable: yes
    status: active              # was rubric-tbd
```
Keep the existing `interim_rubric_source` line as a comment/provenance anchor (or remove — your judgment; if removed, note why). Do NOT touch other packs' rows.

## 4. Acceptance Criteria (Phase-2 AC1-AC5)
- [ ] AC1: rubric defines ≥4 named rigor dimensions (spec has 5), each with rigorous/partial/superficial criteria
- [ ] AC2: rubric explicitly states a rigorously-argued KILL PASSes (decoupling), AND has the swap-test sentence
- [ ] AC3: thresholds/rules cited to real on-disk sources — "2+ fatal flaws = KILL" cited to fatal-flaws.md; 6 rounds cited to pressure-test.md (not interpolated)
- [ ] AC4: deliverable-rubrics.yaml product-thinking row: rubric_ref non-null + points to an EXISTING file, verdict_shape categorical, status active
- [ ] AC5: both rubric file copies (source + installed) are byte-identical (`diff` shows no difference)

## 5. Verification Commands
```bash
cd "/Users/sheldonzhao/01-on progress programs/TAD"
SRC=.tad/capability-packs/product-thinking/references/pressure-test-rubric.md
INST=.claude/skills/product-thinking/references/pressure-test-rubric.md
test -f "$SRC" && test -f "$INST" && echo AC-files-exist
diff "$SRC" "$INST" >/dev/null && echo AC5-byte-identical || echo AC5-DIFFER
grep -qc 'rigorous' "$INST" && echo AC1-dims-present
grep -q 'rigorously-argued KILL' "$INST" && echo AC2-decouple-OK
grep -qi 'swap' "$INST" && echo AC2-swaptest-OK
grep -q '2+ fatal flaws = KILL\|2+ = KILL\|two or more fatal' "$INST" && echo AC3-cite-OK
# AC4: registry points to an existing file
RUBREF=$(yq '.packs.product-thinking.rubric_ref' .tad/capability-packs/deliverable-rubrics.yaml 2>/dev/null | tr -d '"')
test -f "$RUBREF" && echo "AC4-rubric_ref-exists: $RUBREF"
yq '.packs.product-thinking.verdict_shape' .tad/capability-packs/deliverable-rubrics.yaml | grep -q categorical && echo AC4-shape-OK
yq '.packs.product-thinking.status' .tad/capability-packs/deliverable-rubrics.yaml | grep -q active && echo AC4-active-OK
```

## 6. Important Notes
- The rubric must be able to FAIL a thin pressure-test — Phase 3 dogfood will deliberately test discrimination. Make the superficial criteria concrete (e.g. "single encouraging answer, no adversarial pushback, 0-1 real searches" = D1 superficial).
- Do NOT make band criteria reference the conclusion (BUILD/PIVOT/KILL) — only rigor. This is the load-bearing decoupling.
- task_type yaml — Gate 3 = Layer 2 expert review on the rubric + registry.
