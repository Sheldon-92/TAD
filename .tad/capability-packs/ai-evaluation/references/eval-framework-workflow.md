# Evaluation Framework Design — Structured Workflow
<!-- capability: eval_framework_design -->

## Quick Rule Index

| # | Step | determinismLevel |
|---|------|-----------------|
| EF1 | Dimensional analysis: 5 mandatory dimensions | deterministic |
| EF2 | Metric specification: measurable, not vague | deterministic |
| EF3 | Rubric derivation: anchored at 1.0/0.7/0.3/0.0 | semi-deterministic |
| EF4 | Evaluation method selection: deterministic → LLM → human | semi-deterministic |
| EF5 | determinismLevel annotation per rubric item | deterministic |

---

## Workflow: 5-Step Dimensional Analysis → Rubric Derivation

### Step 1 (EF1): Dimensional Analysis

Analyze the target agent against 5 evaluation dimensions. For each dimension, assess applicability and assign priority (P0/P1/P2). Skip inapplicable dimensions honestly.

| Dimension | What It Measures | Example Metrics |
|-----------|-----------------|-----------------|
| **Capability** | Can the agent do the task? | Task Completion (binary/continuous), Tool Correctness, Plan Quality |
| **Reliability** | Does it do it consistently? | Pass@k (capability floor), Pass^k (production reliability), Output Variance |
| **Quality** | How good is the output? | G-Eval score, Faithfulness, Role Adherence, Answer Relevancy |
| **Safety** | Does it stay within bounds? | Bias, Toxicity, PII Leakage, Excessive Agency, Autonomous Drift |
| **Efficiency** | What does it cost? | Token consumption, Latency, Step count |

**Output**: Table with columns: Dimension | Applicable? | Priority | Specific Metrics

**Rule**: Use specific metric names ("Task Completion", "Faithfulness"), never vague labels ("quality", "accuracy"). Vague labels produce unreproducible evaluations.

**Efficiency heuristic**: "10 steps at 85% per-step accuracy → 80% failure rate" — fewer steps is exponentially more reliable.

**determinismLevel**: deterministic — dimension selection is a design decision.

→ Proceed to Step 2.

### Step 2 (EF2): Metric Specification

For each P0/P1 metric identified in Step 1, define the scoring type:

| Scoring Type | When to Use | Example |
|-------------|-------------|---------|
| Binary (pass/fail) | Clear success criteria exist | "File was created: yes/no" |
| Continuous (0.0-1.0) | Gradual quality spectrum | "Response addresses 0-100% of requirements" |
| Ordinal (1-5 scale) | Human evaluation dimensions | "Helpfulness on anchored 5-point scale" |

**Rule**: Every metric must have a production threshold. Recommended: ≥0.7 for production readiness. Document why if you choose a different threshold.

**Output**: Table with columns: Metric | Scoring Type | Threshold | Justification

**determinismLevel**: deterministic — metric definition is structural.

→ Proceed to Step 3.

### Step 3 (EF3): Anchored Rubric Derivation

For each metric, write behavioral anchors at 4 scale points:

```yaml
metric: task_completion
scoring_type: continuous
threshold: 0.7
anchors:
  1.0: "All requirements met. Output directly usable without modification."
  0.7: "Core requirements met. Minor issues present but do not affect usability."
  0.3: "Partial completion. Significant rework needed before output is usable."
  0.0: "Task not completed or output is harmful/irrelevant."
```

**Rules**:
- Each anchor describes observable behavior, not internal state
- Anchors must be discriminating — a rater must be able to classify an output into exactly one level
- "Outcomes over steps" principle: anchors describe what was achieved, not what tools were called
- If you cannot write discriminating anchors for a metric → the metric is too vague, refine it

**Output**: YAML block per metric with anchors at 1.0/0.7/0.3/0.0

**determinismLevel**: semi-deterministic — rubric design is deterministic; application involves judgment.

→ Proceed to Step 4.

### Step 4 (EF4): Evaluation Method Selection

For each rubric item, assign the evaluation method:

| Method | Cost | Reliability | When to Use |
|--------|------|-------------|-------------|
| **Deterministic** (shell/code check) | Free | Highest | Structural properties: file exists, JSON valid, schema matches |
| **LLM-as-Judge** (G-Eval, rubric-based) | Moderate | Medium | Semantic quality: relevance, faithfulness, coherence |
| **Human** (expert scoring) | High | Highest (when calibrated) | Subjective quality: helpfulness, creativity, natural interaction |

**Rules**:
- Default to deterministic when possible — it is free and perfectly reliable
- LLM-as-Judge requires anchored rubrics (Step 3) to be meaningful
- Human evaluation requires calibration protocol (see `human-eval-protocol.md`)
- When deterministic and LLM-as-Judge disagree, deterministic wins

**Output**: Table with columns: Metric | Method | Justification

**determinismLevel**: semi-deterministic — method selection is deterministic; LLM/human execution varies.

→ Proceed to Step 5.

### Step 5 (EF5): determinismLevel Annotation

For each rubric item, annotate its determinismLevel — this tells the eval runner how many samples to draw:

| Level | Definition | Sample Count | Example |
|-------|-----------|-------------|---------|
| `deterministic` | Output is byte-stable across runs | 1 run sufficient | File existence, exact string match, hash equality |
| `semi-deterministic` | Stable shape, variable surface form | ≥3 runs, bound variance | LLM-as-Judge with anchored rubric, JSON schema validation |
| `non-deterministic` | Output meaningfully varies | ≥10 runs, report distribution | Free-form prose quality, creative output scoring |

**Rule**: Pass@k on deterministic rubric = wasted compute. Pass@1 on non-deterministic rubric = statistical noise. The annotation prevents both waste patterns.

**Output**: Complete evaluation framework document with all metrics, rubrics, methods, and determinismLevel annotations.

**determinismLevel**: deterministic — annotation is a classification exercise.

---

## Anti-Patterns

- **Vague dimensions**: "Quality" and "accuracy" are not metrics. "Task Completion rate" and "Faithfulness score" are.
- **All-LLM evaluation**: If file existence or JSON validity can be checked deterministically, using an LLM is waste.
- **Unanchored rubrics**: "Rate 1-5" without behavioral anchors means every rater uses a different scale.
- **Checking steps, not outcomes**: "Agent called grep" is not the same as "agent found the right file." Evaluate results.
- **Missing determinismLevel**: Without this metadata, the eval runner doesn't know whether to run 1x or 10x. Either wasted compute or noisy results.
- **Fabricated rubrics**: If you don't know what "good" looks like for a metric, mark it `[NEEDS CALIBRATION]` and schedule human evaluation.
