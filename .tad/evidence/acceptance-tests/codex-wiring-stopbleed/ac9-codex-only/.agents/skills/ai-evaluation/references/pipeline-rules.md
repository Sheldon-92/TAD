# Automated Pipeline Rules
<!-- capability: automated_pipeline -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| PL1 | Layered evaluation: deterministic → LLM judge → human escalation | semi-deterministic |
| PL2 | Path-filtered triggers: only eval on relevant file changes | deterministic |
| PL3 | Cost budget: per-eval and per-month limits | deterministic |
| PL4 | Fail = block merge: CI exit code must gate deployment | deterministic |
| PL5 | pytest integration for PR-level quality gates | deterministic |
| PL6 | Timeout protection: prevent eval from blocking CI | deterministic |

---

## Rules

### PL1: Layered Evaluation Architecture

When building an evaluation pipeline, layer checks from cheapest to most expensive:

```
Layer 1: Deterministic checks (free, instant)
  → JSON schema validation, file existence, structural assertions
  ↓ (pass)
Layer 2: LLM-as-Judge (moderate cost, seconds)
  → Rubric-based scoring with anchored criteria
  ↓ (pass, or edge case)
Layer 3: Human escalation (expensive, async)
  → High-stakes decisions, ambiguous cases, calibration
```

**Rule**: Never skip Layer 1 to jump to LLM judge. Deterministic checks catch 40-60% of failures at zero cost. LLM judge handles nuance. Human handles uncertainty.

**determinismLevel**: semi-deterministic — architecture is deterministic; LLM layer results vary.

### PL2: Path-Filtered CI Triggers

When configuring CI evaluation, trigger only on relevant file changes:

```yaml
# .github/workflows/eval.yml
on:
  pull_request:
    paths:
      - 'prompts/**'
      - 'config/**'
      - 'skills/**'
      - 'src/agent/**'
```

**Rule**: Never trigger full evaluation on every push. Evaluation cost scales with frequency. Path filters ensure evals run only when agent behavior might change.

For safety-critical changes, add label-triggered red-team:
```yaml
- name: Run red team
  run: npx promptfoo redteam run --config eval/redteam.yaml --ci
  if: contains(github.event.pull_request.labels.*.name, 'safety-check')
```

**determinismLevel**: deterministic — trigger config is structural.

### PL3: Cost Budget Controls

When deploying evaluation pipelines, enforce cost limits:

| Budget Type | How to Enforce | Example |
|-------------|---------------|---------|
| Per-eval assertion | promptfoo cost assertion | `- type: cost` / `threshold: 0.25` |
| Per-run estimate | count scenarios × repeats × avg cost | 50 scenarios × 3 repeats × $0.05 = $7.50/run |
| Per-month projection | runs/month × per-run cost | 100 PRs × $7.50 = $750/month |

**Rule**: Eval cost per run must be documented. If eval costs more than the agent operation it tests, the pipeline is misconfigured.

**determinismLevel**: deterministic — cost computation is mechanical.

### PL4: Merge Blocking on Eval Failure

When integrating evaluation into CI:

- promptfoo: `npx promptfoo eval --ci` exits non-zero on failure → blocks merge automatically
- deepeval: `deepeval test run` uses pytest exit codes → blocks merge automatically
- **Rule**: Never configure eval as "informational only" in CI. If eval fails but merge proceeds, the pipeline is decorative.

GitHub Actions example:
```yaml
jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run evaluation
        run: npx promptfoo eval --config eval/golden-suite.yaml --ci --repeat 3
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

The `--ci` flag ensures proper exit codes for CI integration.

**determinismLevel**: deterministic — CI config is structural.

### PL5: pytest Integration for PR Gates

When using deepeval with Python projects:

```python
# test_eval.py
from deepeval import assert_test
from deepeval.test_case import LLMTestCase
from deepeval.metrics import TaskCompletionMetric

def test_core_task_completion():
    test_case = LLMTestCase(
        input="...",
        actual_output=agent.run("..."),
    )
    metric = TaskCompletionMetric(threshold=0.7)
    assert_test(test_case, [metric])
```

Run with: `deepeval test run test_eval.py`

This integrates evaluation into the standard test framework — no separate eval system needed.

Braintrust alternative: GitHub Actions with configurable quality gates and experiment tracking.
LangSmith alternative: pytest and Vitest integration with GitHub workflows.

**determinismLevel**: deterministic — test config is structural; individual test results are semi-deterministic.

### PL6: Timeout Protection

When running evaluation in CI:

- Set explicit timeouts on eval steps: `timeout-minutes: 15`
- Set per-eval timeouts in tool configs where supported
- A stuck eval should not block CI for hours

```yaml
- name: Run evaluation
  run: npx promptfoo eval --config golden-suite.yaml --ci --repeat 3
  timeout-minutes: 15
```

**determinismLevel**: deterministic — timeout config is structural.

---

## Anti-Patterns

- **Every-push full eval**: Cost explosion. Use path filters (PL2).
- **Local-only evaluation**: Regression slips into production when eval only runs on developer machines.
- **Eval failure doesn't block merge**: Decorative pipeline. Fix: `--ci` flag + required status check.
- **No cost budget**: Eval costing more than the agent it evaluates is a pipeline design failure.
- **No timeout**: One stuck LLM call blocks the entire CI queue.
- **Skipping deterministic layer**: Jumping to LLM judge for checks that `jq` could do wastes money and time.
