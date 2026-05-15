# A/B Testing Rules
<!-- capability: ab_testing, ab_test -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| AB1 | Sample size: n≥100 for signal, n≥550 for tight bounds | deterministic |
| AB2 | Statistical tests: paired McNemar (binary), paired t-test (continuous) | deterministic |
| AB3 | Judge ≠ Optimizer: cross-model judging mandatory | non-deterministic |
| AB4 | CollabEval multi-agent debate for bias cancellation | non-deterministic |
| AB5 | Multiplicity correction: Benjamini-Hochberg for multiple comparisons | deterministic |
| AB6 | Multi-dimensional comparison: quality + cost + latency | deterministic |
| AB7 | Same test cases for both configurations | deterministic |

---

## Rules

### AB1: Sample Size Requirements

When designing an A/B comparison between prompts, models, or configurations:

| Sample Size | Wilson CI Half-Width | Sufficient For |
|-------------|---------------------|----------------|
| n=20 | ±15-20pp | Nothing — differences are noise |
| n=100 | ±7-9.5pp | Rough signal (differences >10% detectable) |
| n=550 | ±4-5pp | Production decisions (tight bounds) |

**Rule**: Never declare a winner from n<100. For production deployment decisions, use n≥550 per configuration.

promptfoo config:
```yaml
tests:
  # ≥100 test cases for signal, ≥550 for production decisions
  - vars: { ... }
    assert: [ ... ]
```

**determinismLevel**: deterministic — sample size is a design choice.

### AB2: Statistical Test Selection

When analyzing A/B results, match the test to the data type:

| Data Type | Statistical Test | When to Use |
|-----------|-----------------|-------------|
| Binary pass/fail | Paired McNemar test | Same test cases scored pass/fail by both configs |
| Continuous scores (0-1) | Paired t-test | Same test cases scored on continuous scale |
| Protocol violation rates | Two-proportion z-test | Comparing violation frequencies |
| Success rates with CI | Wilson 95% confidence interval | Reporting uncertainty bounds |

**Paired** tests are mandatory when both configs are evaluated on the same test cases (which they should be per AB7).

**determinismLevel**: deterministic — statistical computation is mechanical.

### AB3: Cross-Model Judging (Judge ≠ Optimizer)

When using LLM-as-Judge in A/B comparisons:

- **Self-enhancement bias**: LLMs rate their own outputs 10-15% more favorably
- **Rule**: Judge model MUST be a different model family from the generator/optimizer
  - Generator = Claude Sonnet → Judge = GPT-4o (different family)
  - Generator = GPT-4o → Judge = Claude Sonnet (different family)
- If same family is forced: document the bias explicitly, flag results as "internally consistent only — needs cross-family validation before production"

**VERIMAP mitigation**: Embed deterministic Python verification functions alongside LLM judge scores. When deterministic checks and LLM judge disagree, the deterministic check wins.

**determinismLevel**: non-deterministic — LLM judge scores vary; mitigation reduces but does not eliminate bias.

### AB4: CollabEval Multi-Agent Debate

When a single LLM judge is insufficient (high-stakes comparisons):

- Use multi-agent referee team with distinct personas
- Each persona evaluates independently, then multi-round debate to consensus
- Debate consensus cancels individual model biases more effectively than averaging

Reserve for high-stakes decisions (model migration, major prompt rewrite). Overkill for routine A/B checks.

**determinismLevel**: non-deterministic — debate outcomes vary across runs.

### AB5: Multiplicity Correction

When running multiple A/B comparisons simultaneously (e.g., comparing 4 prompt variants):

- Apply **Benjamini-Hochberg** correction for false discovery rate control
- Use **Benjamini-Yekutieli** when comparisons have dependencies
- Without correction, 20 independent tests at p=0.05 → expect 1 false positive

**Rule**: Any report with >2 simultaneous comparisons MUST include multiplicity correction.

**determinismLevel**: deterministic — correction computation is mechanical.

### AB6: Multi-Dimensional Comparison

When evaluating A/B results, never compare on a single dimension:

| Dimension | Weight (suggested) | Metric |
|-----------|-------------------|--------|
| Quality | 0.5-0.6 | Pass rate, mean rubric score |
| Cost | 0.2-0.3 | Total tokens × price, per-eval cost |
| Latency | 0.1-0.2 | P50 and P95 response time |

A configuration that improves quality by 5% but increases cost by 300% is usually not a win. Report all dimensions; let the decision-maker apply their own weights.

**determinismLevel**: deterministic — dimension computation is mechanical.

### AB7: Identical Test Data for Both Arms

When configuring an A/B comparison:

- Both configurations MUST use the exact same test cases with the same assertions
- Randomize presentation order to avoid sequence effects
- Use paired statistical tests (AB2) since observations are matched

promptfoo multi-provider config:
```yaml
providers:
  - id: anthropic:claude-sonnet
    label: "Config A"
  - id: openai:gpt-4o
    label: "Config B"
tests:
  - vars: { ... }   # identical for both providers
    assert: [ ... ]  # identical assertions
```

**determinismLevel**: deterministic — experimental design is structural.

---

## Anti-Patterns

- **Different test cases for A and B**: Invalidates comparison — effects are confounded with test case difficulty.
- **Single-dimension winner**: "Config B is 5% better on quality" while costing 10x more is not a win without context.
- **Small-sample declarations**: n=20 differences are noise. Stop declaring winners from demos.
- **Same-model judging**: Self-enhancement bias hides true quality differences. See AB3.
- **No multiplicity correction**: Testing 10 variants and picking the winner without correction = data dredging.
- **Aggregating across scenarios**: A 2% aggregate improvement may hide a 20% regression on critical scenarios. Always report per-scenario too.
