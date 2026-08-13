# Tool Selection Matrix

> When to use promptfoo vs DSPy vs DeepEval.
> All three are CLI-native and terminal-runnable. No web UI required.

---

## Primary Selection Matrix

| Tool | Best For | Install | When to Use |
|------|----------|---------|-------------|
| **promptfoo** | Testing + CI/CD + red teaming | `npx promptfoo@latest init` | You need automated regression testing, CI/CD gates, or adversarial scanning |
| **DSPy** | Programmatic prompt optimization (MIPROv2 scalar-metric search, or **GEPA** reflective evolution for tiny trainset + textual feedback) | `pip install -U dspy` | You want the compiler to optimize your prompt rather than writing it manually |
| **DeepEval** | Quality metrics + debugging | `pip install deepeval` | You need measurable scores (hallucination, faithfulness, relevancy) with explanations |

**Decision flow**:
1. **Building a test suite or CI/CD pipeline?** → promptfoo
2. **Have a metric function and training examples, want to compile the best prompt?** → DSPy
3. **Need a score on a specific quality dimension (hallucination rate, faithfulness)?** → DeepEval

---

## promptfoo — Prompt Testing and CI/CD

**Strength**: CLI-first, YAML-driven, integrates with GitHub Actions, 50+ vulnerability types.

**Primary CLI commands**:
```bash
npx promptfoo@latest init           # Initialize project
npx promptfoo eval --no-cache       # Run evaluation suite
npx promptfoo view                  # View results in browser
npx promptfoo redteam generate      # Generate adversarial test cases
npx promptfoo redteam run           # Run adversarial tests
```

**Use for**:
- Golden dataset regression testing
- CI/CD pipeline gates (Tier 1/2/3 per `references/ci-cd-templates.md`)
- Red teaming and vulnerability scanning
- A/B testing prompt variants
- Multi-provider comparison

**Not for**:
- Programmatic prompt optimization (DSPy is better)
- Detailed quality scoring with explanations (DeepEval is better)

**Pricing**: Open-source (MIT). Cloud features available but not required for CLI use.

---

## DSPy — Programmatic Prompt Optimization

**Strength**: Compiles prompts via Bayesian optimization. Better than manual iteration for
prompts with well-defined metrics.

**Install**:
```bash
pip install -U dspy  # Package was renamed from dspy-ai in 2024; use 'dspy' not 'dspy-ai'
```

**Basic usage**:
```python
import dspy

# Configure LLM
lm = dspy.LM("anthropic/claude-sonnet-4-6")
dspy.configure(lm=lm)

# Define task signature
class YourTask(dspy.Signature):
    """[Task description — this becomes the prompt]"""
    input_text = dspy.InputField(desc="[what the input is]")
    output = dspy.OutputField(desc="[what the output should be]")

# Compile with optimizer
program = dspy.Predict(YourTask)
```

**Use for**:
- Tasks with well-defined metric functions
- Large search spaces where manual iteration would take >3 days
- When you have 5-10 labeled training examples

**Not for**:
- Tasks without a measurable metric (DSPy needs a score function)
- One-time prompts (overhead not justified)
- When you need specific prompt wording (DSPy chooses wording)

---

## DSPy Optimizer Sub-Matrix

Choose the right optimizer based on your constraints:

| Optimizer | When to Use | Input Required | LLM Calls | Cost |
|-----------|-------------|----------------|-----------|------|
| **GEPA** | Rich textual feedback (traces/errors) + tiny trainset; reflective evolution | metric + `reflection_lm` (required) + as few as 3 examples | 100–500 (`max_metric_calls`) | Medium |
| **MIPROv2** | Best quality on pure scalar-metric search; large search space; can afford compute | 5–10 examples + metric function | 200+ | High |
| **COPRO** | Fast iteration; coordinate ascent; moderate quality | Metric function + `depth` parameter | 50–100 | Medium |
| **BootstrapFewShot** | Need demonstrations, not instruction tuning; few-shot focused | Teacher module + `max_demos` | Low (few-shot only) | Low |

### GEPA (Genetic-Pareto reflective evolution) — tiny trainset + textual feedback

```python
import dspy
optimizer = dspy.GEPA(
    metric=your_metric_fn,
    max_metric_calls=150,
    reflection_lm="openai/gpt-4.1",  # REQUIRED — separate, usually stronger reflection model
)
optimized = optimizer.compile(program, trainset=train_examples)  # works with as few as 3 examples
```

**Decision rule**: choose GEPA over MIPROv2 when you have **rich textual feedback** (test traces,
error messages) and a **tiny trainset** — GEPA reads execution traces, diagnoses failures in natural
language, and keeps a Pareto frontier of candidates. Grounded results (ICLR 2026 oral,
arXiv:2507.19457): **>10pp over MIPROv2** (+10pp on AIME-2025, GPT-4.1-mini 46.6%→56.6%), **~20% over
GRPO with ~35× fewer rollouts** (100–500 evals vs 5,000–25,000+), discovered an agent architecture
lifting ARC-AGI **32%→89%**. Source: https://github.com/gepa-ai/gepa + https://dspy.ai/api/optimizers/GEPA/overview/.
MIPROv2 stays the right tool for pure scalar-metric search with no trace narrative.

### MIPROv2 (best quality)

```python
from dspy.teleprompt import MIPROv2

optimizer = MIPROv2(
    metric=your_metric_fn,
    auto="medium"  # "light" for fast, "heavy" for thorough
)
optimized = optimizer.compile(
    program,
    trainset=train_examples,
    num_trials=25  # number of optimization iterations
)
optimized.save("optimized_program.json")
```

**Decision rule**: Use MIPROv2 when you want the best possible prompt and can afford 200+ LLM calls (typically $5–50 in API costs). For production prompts that run millions of times, this cost is justified.

### COPRO (fast iteration)

```python
from dspy.teleprompt import COPRO

optimizer = COPRO(
    metric=your_metric_fn,
    depth=5  # number of coordinate ascent iterations
)
optimized = optimizer.compile(
    program,
    trainset=train_examples
)
```

**Decision rule**: Use COPRO when you need fast iteration (< 1 hour) and accept 80–90% of MIPROv2 quality.

### BootstrapFewShot (demonstration generation)

```python
from dspy.teleprompt import BootstrapFewShot

optimizer = BootstrapFewShot(
    metric=your_metric_fn,
    max_bootstrapped_demos=4,  # number of generated demonstrations
    max_labeled_demos=8
)
optimized = optimizer.compile(
    program,
    trainset=train_examples
)
```

**Decision rule**: Use BootstrapFewShot when your task benefits primarily from few-shot examples
(demonstrations) rather than optimized instructions. Lowest cost, good for classification and extraction tasks.

---

## DeepEval — Quality Metrics and Debugging

**Strength**: 50+ typed metrics returning both a score (0–1) and a natural-language explanation
of why the score was assigned. Pytest-native.

**Install**:
```bash
pip install deepeval
```

**Basic usage**:
```python
from deepeval import assert_test
from deepeval.test_case import LLMTestCase
from deepeval.metrics import AnswerRelevancyMetric, HallucinationMetric

def test_answer_quality():
    test_case = LLMTestCase(
        input="What is the capital of France?",
        actual_output="The capital of France is Paris.",
        retrieval_context=["France is a country in Europe. Paris is its capital city."]
    )
    assert_test(test_case, [
        AnswerRelevancyMetric(threshold=0.8),
        HallucinationMetric(threshold=0.2)
    ])
```

**Key metrics by use case**:

| Use Case | Metric | Threshold | Notes |
|----------|--------|-----------|-------|
| RAG accuracy | `FaithfulnessMetric` | ≥0.8 | grounding to retrieval context |
| Hallucination detection | `HallucinationMetric` | ≤0.2 | contradiction against context |
| Answer quality | `AnswerRelevancyMetric` | ≥0.7 | |
| Context recall | `ContextualRecallMetric` | ≥0.8 | |
| Any custom criteria | `GEval` | Custom rubric | LLM-as-judge with CoT over arbitrary criteria |
| **Reproducible pass/fail** | `DAGMetric` | deterministic | graph-based deterministic LLM-judge builder — use when a noisy 0–1 score is unacceptable and you need stable pass/fail |

**Two constructs the single-turn golden-set model can't express** (add when needed):
- **`DAG` (DagMetric)** — a decision-graph metric builder where each node is a deterministic LLM
  judgment. Use instead of `GEval` when you need **reproducible** pass/fail rather than a score that
  jitters between runs (e.g. CI gates that must not flake).
- **`ConversationalTestCase`** — a sequence of `LLMTestCase` turns for chatbot / multi-turn prompts.
  The pack's default single-turn `LLMTestCase` golden set cannot represent multi-turn behavior;
  switch to `ConversationalTestCase` for any conversational prompt.

```python
from deepeval.test_case import ConversationalTestCase, LLMTestCase
convo = ConversationalTestCase(turns=[
    LLMTestCase(input="Hi", actual_output="Hello! How can I help?"),
    LLMTestCase(input="Cancel my order", actual_output="Which order ID?"),
])
```

Source: https://deepeval.com/docs/metrics-llm-evals (retrieved 2026-06-13).

**Use for**:
- Measuring specific quality dimensions with natural-language explanations (`GEval`)
- Reproducible deterministic gating (`DAG`) and multi-turn prompts (`ConversationalTestCase`)
- Debugging why a specific test case is failing; baseline metrics before optimization

**Not for**:
- CI/CD pipeline integration (promptfoo handles this better)
- Programmatic optimization (DSPy/GEPA handle this)

---

## Evaluated but Not Included

These tools were evaluated for this pack but excluded:

**Braintrust**: Evaluated in research Q1. Braintrust's Loop AI feature (auto-generates test
datasets from production logs) requires a Braintrust account and web UI for configuration.
The CLI is available but the unique value proposition (automated dataset generation) requires
the SaaS platform. Not suitable for "AI agent runs from terminal" constraint.
*For teams:* Braintrust is a strong choice for collaborative prompt management with non-technical stakeholders.

**Agenta**: Git-like branching and version management for prompts, collaborative editing UI.
SDK-first rather than CLI-first. The core differentiator (prompt branching and team collaboration)
requires the web platform. *For teams:* Agenta is useful for non-technical stakeholders who need
to edit prompts without touching code.
