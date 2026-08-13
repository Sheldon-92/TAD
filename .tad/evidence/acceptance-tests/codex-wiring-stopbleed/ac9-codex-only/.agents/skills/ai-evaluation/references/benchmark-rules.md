# Benchmark Testing Rules
<!-- capability: benchmark_testing -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| B1 | Tool selection: promptfoo for YAML-driven, deepeval for pytest | deterministic |
| B2 | Golden dataset: 50-100 representative trajectories | deterministic |
| B3 | Test scenario coverage: core/edge/error/performance | deterministic |
| B4 | Assertions: structural + behavioral + qualitative per scenario | semi-deterministic |
| B5 | Multi-run: ≥3 repeats for variance bounding | semi-deterministic |
| B6 | Outcomes over steps: check results not tool invocations | semi-deterministic |
| B7 | Mocks hide SDK shape validation | deterministic |
| B8 | Pass@k AND Pass^k reporting | deterministic |

---

## Rules

### B1: Tool Selection by Context

When choosing a benchmark tool, match to the team's workflow:

| Context | Tool | Command | Why |
|---------|------|---------|-----|
| YAML-driven eval + CI/CD integration | promptfoo | `npx promptfoo@latest eval --config config.yaml` | CLI-native, npx zero-install, 90+ providers |
| Python pytest integration | deepeval | `deepeval test run test_benchmark.py` | 50+ metrics, pytest native, G-Eval + DAG |
| RAG pipeline evaluation | ragas | `ragas quickstart --template rag_eval` | Faithfulness, context relevancy, reference-free |
| Tracing + experiment management | langfuse + deepeval | `deepeval test run` with langfuse tracing | Visual history, experiment comparison |
| Unsure | promptfoo | `npx promptfoo@latest init` | Widest coverage, lowest barrier |

**determinismLevel**: deterministic — tool selection is a one-time architectural decision.

### B2: Golden Dataset Requirements

When building a golden dataset for benchmarks:

- **Size**: 50-100 representative trajectories (not single-turn prompts — full agent traces)
- **Living baseline**: golden dataset grows with production failures (every prod incident adds a test case)
- **VeRO pattern**: git-version agent snapshots + structured experiment DB with execution traces + per-sample scores
- Include entire trajectories, not just final outputs — intermediate steps reveal capability gaps

**determinismLevel**: deterministic — dataset composition is a design decision.

### B3: Test Scenario Coverage Matrix

When designing benchmark scenarios, cover all four quadrants:

| Category | Minimum Count | Examples |
|----------|--------------|---------|
| Core functionality (must-pass) | ≥2 | Primary task completion, correct tool selection |
| Edge cases (boundary) | ≥1 | Ambiguous input, missing context, conflicting instructions |
| Error handling (resilience) | ≥1 | Invalid input, tool failure, timeout recovery |
| Performance (efficiency) | ≥1 | Large input, complex multi-step task, cost constraints |

Total: ≥5 scenarios minimum. Each scenario defines: `input`, `expected_behavior` (outcomes, not steps), `assertions` (≥3), `cost_budget`, `latency_budget`.

**determinismLevel**: deterministic — scenario design is structural.

### B4: Assertion Layering

When writing assertions for each scenario, layer three types:

1. **Structural** (deterministic): `contains-json`, file existence, schema validation
2. **Behavioral** (semi-deterministic): JavaScript/Python function checks on output shape and content
3. **Qualitative** (non-deterministic): `llm-rubric` with anchored scoring criteria, threshold ≥0.7

promptfoo example:
```yaml
assert:
  - type: contains-json          # structural
  - type: javascript             # behavioral
    value: "output.includes('completed')"
  - type: llm-rubric             # qualitative
    value: "Output addresses all requirements with actionable specifics"
    threshold: 0.7
  - type: cost
    threshold: 0.25
```

**ALWAYS set an explicit `threshold` on `llm-rubric`/`g-eval`.** Per the promptfoo model-graded contract: scores are normalized to **0.0–1.0**, and an assertion passes only when **BOTH `grader.pass === true` AND `score >= threshold`**. With **no `threshold`, the assertion passes on `grader.pass` alone** — so `{pass: true, score: 0}` silently passes. An un-thresholded model-graded assertion is a **no-op gate**. Concrete defaults to teach: `threshold: 0.66` = 2-of-3 majority on an assert-set; `threshold: 0.7` = common qualitative bar.

**determinismLevel**: semi-deterministic — structural assertions are deterministic; qualitative assertions require ≥3 runs.

### B5: Multi-Run Variance Bounding

When running benchmarks on non-deterministic systems:

- Run ≥3 repeats per scenario: `npx promptfoo eval --repeat 3`
- If same scenario crosses the pass/fail boundary across runs → flag as unreliable
- Report both Pass@k (at least 1 of k passes) and Pass^k (all k pass)
- Pass@k reveals capability floor; Pass^k reveals production reliability

**determinismLevel**: semi-deterministic.

### B6: Outcomes Over Steps

When writing evaluation criteria:

- **DO**: "File was correctly modified" / "API returns valid response" / "Task completed successfully"
- **DO NOT**: "Agent called the grep tool" / "Agent ran 5 commands" / "Agent used the correct function"

Checking steps instead of outcomes penalizes creative solutions that achieve the same result through different paths.

**determinismLevel**: semi-deterministic — outcome verification may involve LLM judgment.

### B7: Mocks Hide SDK Shape Validation

When benchmark tests mock the agent's SDK calls (Anthropic SDK, OpenAI SDK, vendor SDK), the mock returns whatever response shape the test author imagined. If the real SDK's response shape drifts (new field added, optional field becomes required, type narrows), the mock-based benchmark continues to PASS while production breaks.

**Rule**: Hit the real SDK in at least one integration-tier benchmark (cheap models, low-cost prompts) so SDK shape regressions surface in CI, not production. Mocks are fine for capability/coverage benchmarks — never the SOLE benchmark layer.

**determinismLevel**: deterministic — integration test either runs against real SDK or not.

### B8: Dual Pass-Rate Reporting

When reporting benchmark results, always compute both:

| Metric | Formula | What It Shows |
|--------|---------|---------------|
| Pass@k | ≥1 of k runs passes | Capability floor — can the agent do it at all? |
| Pass^k | All k runs pass | Production reliability — will it work every time? |

A system with Pass@3=100% but Pass^3=60% is capable but unreliable. Both numbers are needed for production decisions.

**determinismLevel**: deterministic — computation from run results.

---

## Anti-Patterns

- **Testing knowledge, not capability**: "Explain X" tests recall, not agent behavior. Benchmark tests should require the agent to DO something.
- **Single-run conclusions**: Non-deterministic systems need ≥3 runs. One pass ≠ reliable.
- **Pass/fail only**: Without continuous scores (0.0-1.0), you cannot track gradual improvement or regression.
- **No baseline comparison**: Pure LLM vs agent comparison reveals whether tool use actually helps.
- **Mocks as sole layer**: See B7 — mock-only benchmarks miss SDK shape drift.
