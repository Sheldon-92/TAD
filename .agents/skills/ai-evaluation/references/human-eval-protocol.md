# Human Evaluation Protocol — Structured Workflow
<!-- capability: human_eval_protocol, human_eval -->

## Quick Rule Index

| # | Step | determinismLevel |
|---|------|-----------------|
| HE1 | Calibration: 2-3 experts, 100-200 samples, behaviorally anchored rubrics | non-deterministic |
| HE2 | Inter-rater reliability: ICC(2,1) > 0.92 target | non-deterministic |
| HE3 | Spearman bridge: ≥0.80 correlation between automated and human scores | non-deterministic |
| HE4 | Recalibration trigger: automated-human gap exceeds 0.05 | deterministic |
| HE5 | Risk-adjusted oversight: dense review for high-stakes, sampling for routine | deterministic |

---

## Workflow: Calibration → Scoring → Bridge → Monitoring

### Step 1 (HE1): Evaluator Calibration

Before starting human evaluation:

**Team composition**: 2-3 domain experts minimum. Single-evaluator scores cannot be validated.

**Calibration protocol**:
1. Select 100-200 representative agent outputs (stratified: ≥25% high quality, ≥25% low quality, ≥50% mid-range)
2. Write behaviorally anchored rubrics (see `eval-framework-workflow.md` Step 3)
3. Have all evaluators independently score 10-15 calibration samples
4. Compare scores — discuss disagreements (score difference ≥2 on 5-point scale)
5. Refine rubric anchors based on disagreement patterns
6. Re-score calibration samples until agreement stabilizes

**Entropy-based calibration reweighting**: When an evaluator's score distribution has significantly lower entropy than peers (e.g., always scores 3-4, never 1 or 5), reweight their contributions. Low-entropy scoring often indicates insufficient engagement with rubric anchors.

**determinismLevel**: non-deterministic — human scoring inherently varies; calibration reduces but does not eliminate variation.

→ Proceed to Step 2.

### Step 2 (HE2): Inter-Rater Reliability Measurement

After calibration, measure agreement quality:

| Metric | Target | Interpretation |
|--------|--------|---------------|
| Krippendorff's alpha (α) | α ≥ 0.78 | Enterprise-grade reliability threshold |
| ICC(2,1) — single evaluator | > 0.92 | A single evaluator's score is reliable |
| ICC(2,K) — panel average | > 0.97 | Average of K evaluators is reliable |

**Panel sizing**:
- 4 evaluators: sufficient for continuous monitoring
- 8-12 evaluators: needed for periodic audits or high-stakes assessments

**Rule**: If ICC(2,1) < 0.92 after calibration → rubric anchors are insufficiently discriminating. Refine anchors and recalibrate before proceeding.

**Output**: ICC scores per dimension, with flagged dimensions that fall below threshold.

**determinismLevel**: non-deterministic — ICC is computed from inherently variable human scores.

→ Proceed to Step 3.

### Step 3 (HE3): Automated-Human Bridge

After establishing human evaluation baselines, bridge to automated scoring:

**Target**: ≥0.80 Spearman rank correlation between LLM judge scores and human expert consensus. State-of-the-art pipelines achieve 0.86.

**Bridge process**:
1. Score 50-100 outputs with both human panel and LLM-as-Judge
2. Compute Spearman correlation per evaluation dimension
3. For dimensions with correlation < 0.80:
   - Check if rubric anchors are sufficiently specific for LLM consumption
   - Check if the dimension is inherently subjective (creativity, naturalness) — may not be automatable
   - Refine LLM judge prompt with examples from human-scored samples

**Layered routing after bridge**:
```
Deterministic rules (structural checks)
  → Automated LLM judge (correlation ≥ 0.80 with human)
    → Human escalation (high-stakes, ambiguous, or correlation < 0.80 dimensions)
```

**determinismLevel**: non-deterministic — correlation measurement depends on variable human and LLM scores.

→ Proceed to Step 4.

### Step 4 (HE4): Recalibration Triggers

After deployment, monitor the automated-human alignment:

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Automated-human gap on spot-checks | Exceeds 0.05 on 0-1 scale | Recalibrate: re-run human scoring on 20-30 samples |
| New evaluation dimension added | Always | Full calibration cycle (Step 1) |
| Model change (judge or generator) | Always | Re-validate bridge correlation (Step 3) |
| Evaluator roster change | >30% of panel replaced | Re-run calibration (Step 1) |

**Rule**: Calibration is not one-time. Any change to the evaluation system (new model, new rubric, new evaluators) requires revalidation.

**determinismLevel**: deterministic — trigger detection is threshold-based.

→ Proceed to Step 5.

### Step 5 (HE5): Risk-Adjusted Human Oversight

When human evaluation resources are limited, allocate by risk:

| Risk Level | Human Oversight | Automated Eval |
|------------|----------------|----------------|
| High-stakes (financial, safety, legal) | Dense review: 100% of outputs | Supplementary signal |
| Medium (customer-facing, brand) | Sampling: 10-20% of outputs | Primary signal, human validates |
| Low (internal tooling, dev aids) | Random spot-check: 2-5% of outputs | Full automation |

**Rule**: Never fully automate evaluation for high-stakes outputs. The Spearman bridge (Step 3) justifies automation only for dimensions where correlation ≥ 0.80.

**determinismLevel**: deterministic — risk classification and sampling rates are design decisions.

---

## Anti-Patterns

- **Unanchored rubrics**: "Rate 1-5" without behavioral descriptions → every evaluator uses a different internal scale.
- **Single evaluator**: No inter-rater reliability measurement possible. Scores are one person's opinion, not calibrated judgment.
- **Human-automated disconnect**: Running human eval and automated eval on different samples or with different rubrics → cannot build a bridge.
- **One-time calibration**: Calibration decays when models, rubrics, or evaluators change. Schedule recalibration per HE4 triggers.
- **Equal oversight for all risk levels**: Dense human review of low-risk outputs wastes expert time. Risk-adjust.
- **Fabricated agreement scores**: If ICC is below target, report it honestly. Inflated reliability claims undermine the entire evaluation system.
