# Regression Testing Rules
<!-- capability: regression_testing -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| R1 | Golden suite: git-versioned baseline with P0/P1 priorities | deterministic |
| R2 | Rubric consistency: same rubrics for pre-deploy and production | deterministic |
| R3 | Drift triggers: hallucination rate, path convergence, escalation rate | semi-deterministic |
| R4 | Scheduled evaluation against live traffic | semi-deterministic |
| R5 | Regression thresholds: P0=zero tolerance, P1=≤10% degradation | deterministic |
| R6 | Cost and latency regression checks | deterministic |

---

## Rules

### R1: Golden Suite as Version-Controlled Baseline

When establishing a regression baseline:

- Extract passing test cases from initial benchmarks into a `golden-suite.yaml`
- Store in version control alongside the agent code
- Each test case must have:
  - `id`: unique identifier
  - `priority`: P0 (zero regression tolerance) or P1 (≤10% degradation allowed)
  - `baseline_score`: score from baseline run
  - `baseline_pass_rate`: e.g., "3/3"

```yaml
golden_tests:
  - id: core-task-1
    priority: P0
    baseline_score: 0.85
    baseline_pass_rate: "3/3"
  - id: edge-case-1
    priority: P1
    baseline_score: 0.72
```

Run with: `npx promptfoo eval --config golden-suite.yaml --repeat 3`
Or: `deepeval test run test_golden.py --regression`

Golden suite grows with production failures — every production incident adds a new test case.

**determinismLevel**: deterministic — suite structure is a design artifact.

### R2: Rubric Consistency Across Environments

When deploying evaluation rubrics:

- **Same rubrics** must be used for pre-deployment testing AND production monitoring
- If you change a rubric for pre-deploy, change it for production too
- "Rubric drift" — using lenient rubrics in CI but strict rubrics in monitoring — causes false confidence

**Rule**: When updating any evaluation rubric, grep for all locations where it's referenced and update them simultaneously.

**determinismLevel**: deterministic — rubric identity check.

### R3: Drift Detection Triggers

When monitoring production agent behavior, track these drift signals:

| Signal | Threshold | Action |
|--------|-----------|--------|
| Hallucination rate spike | >2x baseline (e.g., 6% → 14%) | Immediate investigation |
| Agent Path Convergence drop | >15% below baseline | Review prompt/model changes |
| Escalation rate increase | >1.5x baseline | Check for capability regression |
| Mean quality score drop | >0.1 below baseline on 0-1 scale | Run full regression suite |

Tools for drift monitoring:
- Arize Phoenix: embedding drift detection for RAG pipelines
- Galileo AI: automatic "Signals" for failure pattern detection
- promptfoo scheduled runs: same golden suite on cron

**determinismLevel**: semi-deterministic — metric thresholds are deterministic, but underlying measurements have variance.

### R4: Scheduled Evaluation Cadence

When setting up production evaluation:

| Traffic Level | Eval Frequency | Sample Size |
|--------------|----------------|-------------|
| High (>1K req/hour) | Hourly | Random 5% of traffic |
| Medium (100-1K req/hour) | Every 4 hours | Random 10% of traffic |
| Low (<100 req/hour) | Daily | All traffic |

Use the same rubrics as pre-deployment testing (R2). Results feed back into drift detection (R3).

**determinismLevel**: semi-deterministic — scheduling is deterministic; individual eval results vary.

### R5: Regression Thresholds and Merge Decisions

When comparing current run vs baseline:

| Test Priority | Regression Detected When | Merge Decision |
|--------------|------------------------|----------------|
| P0 | ANY score decrease | BLOCK MERGE |
| P1 | Score decrease >10% | REVIEW NEEDED |
| P1 | Score decrease ≤10% | ALLOW (document) |
| Any | Pass^3 drops but Pass@3 holds | RELIABILITY REGRESSION — review |

Report per test case, not just aggregate:
```
| Test ID | Baseline | Current | Delta | Verdict |
|---------|----------|---------|-------|---------|
| core-1  | 0.85     | 0.87    | +0.02 | ✅ OK   |
| core-2  | 0.90     | 0.78    | -0.12 | ❌ P0 REGRESSION |
```

**determinismLevel**: deterministic — threshold comparison is mechanical.

### R6: Cost and Latency Regression

When evaluating regression, check non-quality metrics too:

- **Cost increase >20%** = COST REGRESSION — same quality at higher price is a regression
- **Latency increase >50%** = LATENCY REGRESSION — slower response is degraded UX
- Track token consumption (input + output) per scenario for cost attribution

**determinismLevel**: deterministic — cost/latency are measured values.

---

## Anti-Patterns

- **No golden suite**: Without a baseline, there is no regression — only hope.
- **Single-run comparison**: Noise masquerades as regression. Always ≥3 runs.
- **Aggregate-only reporting**: A 2% aggregate improvement can hide a 30% regression on one critical test case. Report per test case.
- **Ignoring cost/latency**: Same quality at 5x the cost or 10x the latency is a regression.
- **Rubric drift between environments**: Lenient CI rubrics + strict production rubrics = false confidence.
