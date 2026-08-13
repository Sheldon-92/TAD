---
name: ai-prompt-engineering
description: Production prompt lifecycle toolkit. Gives AI agents the ability to design, test, optimize, version, and deploy prompts like a senior prompt engineer — with automated testing (promptfoo), programmatic optimization (DSPy), quality metrics (DeepEval), and CI/CD gates. Use for writing system prompts, testing prompt suites, diagnosing hallucination/drift, setting up CI/CD pipelines, or auditing existing prompts.
keywords: ["prompt", "prompt engineering", "LLM", "system prompt", "hallucination", "提示词", "幻觉", "漂移", "DSPy", "promptfoo", "CI/CD", "测试"]
type: reference-based
---

**CONSUMES**: User prompt engineering task + optional existing system prompts or eval dataset
**PRODUCES**: Tested prompt suite + optimization results + CI/CD gate configuration

# AI Prompt Engineering Capability Pack

**Version**: 1.0.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0 — see LICENSE-ATTRIBUTION.md for source credits

---

## What This Pack Does

AI agents can write prompts. What they cannot do:
- Test prompts against regression suites before deploying
- Diagnose *why* a prompt hallucinates or drifts format
- Set up CI/CD pipelines that block bad prompts from shipping
- Handle model updates that silently break existing prompts

This pack encodes the **production prompt lifecycle** — 4 phases with specific CLI tools at
each phase — that most prompt engineering guides skip.

**This pack teaches "how to run prompts in production"**, not "how to write a prompt."
The Anthropic tutorial covers writing. This covers testing, versioning, drift detection, CI/CD.

**Pack = prompt production knowledge. Your workflow system = process constraints. No overlap.**

---

## Contents / Navigation Index

| Section | Loads | Use when |
|---------|-------|----------|
| Step 0: Context Detection Router | this file | Always — entry routing |
| Phase 1: Write | `references/phase1-write.md` | Designing a new prompt |
| Phase 2: Test | `tools/selection-matrix.md`, `tools/promptfoo-starter.yaml` | Building a regression/eval suite |
| Phase 3: Optimize | `references/failure-catalog.md`, `tools/selection-matrix.md` | Diagnosing/optimizing a prompt |
| Phase 4: Ship | `references/ci-cd-templates.md` | Versioning + CI/CD + deploy |
| Anti-Skip Table | this file | When tempted to skip a phase |
| Anti-Slop Rules | this file | Every phase |
| Claude target rules | `references/claude.md` | Target model is Claude (model IDs, adaptive thinking, structured outputs) |
| Validation | `tools/prompt-lint.sh` | Deterministic pre-ship check (assertions/model-pin/aggressive-language) |

**References**: `claude.md` (Claude API rules + model-pinning), `phase1-write.md` (Phase 1 detail),
`few-shot-design.md`, `output-format.md`, `failure-catalog.md` (FM-1..FM-6), `ci-cd-templates.md`.
**Tools**: `selection-matrix.md` (promptfoo/DSPy/GEPA/DeepEval), `promptfoo-starter.yaml`, `prompt-lint.sh`.

---

## Step 0: Context Detection Router

When the user mentions prompt work, detect context and load the right references:

| User Signal | Entry Mode | Load Reference |
|-------------|------------|----------------|
| "write prompt", "design prompt", "system prompt for" | `/write` → Phase 1 | `references/phase1-write.md` (+ `references/claude.md` if Claude target) |
| "few-shot", "examples", "shots", "demonstrations" | `/write` → Phase 1 | `references/phase1-write.md` + `references/few-shot-design.md` |
| "output format", "JSON schema", "structured output", "format lock" | `/write` → Phase 1 | `references/phase1-write.md` + `references/output-format.md` |
| "hallucinating", "drifting", "broken prompt", "inconsistent" | `/audit` → Phase 3 | `references/failure-catalog.md` |
| "optimize", "improve this prompt", "scoring low" | `/audit` → Phase 3 | `references/failure-catalog.md` |
| "CI/CD", "pipeline", "deploy prompt", "version", "ship" | Phase 4 direct | `references/ci-cd-templates.md` |
| "test prompt", "eval", "promptfoo", "red team", "golden set" | Phase 2 direct | `tools/selection-matrix.md` |
| "model update", "prompt drift", "regression", "silent change" | `/audit` → Phase 3 | `references/failure-catalog.md` + `references/claude.md` |
| "everything", "full audit", "review this prompt" | `/audit` → Phase 3 | All references |

**Two entry modes:**
- `/write` — Design a new prompt from scratch → Phase 1 → 2 → 3 → 4
- `/audit` — Diagnose or optimize an existing prompt → Phase 3 (with escalation gate) → 2 → 4

**Interaction contract**: Challenge vague requirements with specific questions before proceeding
(e.g., "What's the output consumer — API code or human reader?", "What's the target model and
context window size?"). Present tradeoffs; human decides. Not adversarial — but not passive.
Do not refuse to proceed; clarify, then act.

---

## Phase 1: Write — Design the System Prompt

**Trigger**: `/write` entry, or user wants a new prompt from scratch.

### 1.1 Scope Clarification (ask before writing)

Before writing, confirm:
- **Target model**: Which LLM? (Claude 4.x? GPT-4o? Gemini?) → Load `references/claude.md` for Claude
- **Output consumer**: API code parsing JSON? Human reading text? Pipeline feeding next agent?
- **Primary task**: Classify/Extract/Generate/Transform/Reason?
- **Constraints**: Token budget? Latency SLA? Content policy?

### 1.2–1.7 Prompt Construction → load `references/phase1-write.md`

The full Phase 1 construction detail lives in **`references/phase1-write.md`** (load it now for any
`/write` task). It covers:

- **1.2 Role definition** — domain+value+consumer formula (never "You are a helpful assistant")
- **1.3 Constraint design** — ≤10 MUST/NEVER, front-load in first 30% (U-shaped attention)
- **1.4 Context architecture** — cache_control placement, model-specific min cacheable prefix (4096 Opus / 2048 Sonnet), token audit via `count_tokens` (not tiktoken)
- **1.5 Anti-hallucination** — grounding constraints + capability declaration (~23% reduction)
- **1.6 Injection defense** — delimiter isolation + reasoning scaffold (84% → ~12% success rate)
- **1.7 Conditional loading** — few-shot / output-format / Claude references

**Key constraint surfaced here so it isn't skipped**: "MUST USE"/"CRITICAL:"/"ALWAYS" over-trigger
on Claude 4.6+ — use direct language. If **target model is Claude**, also load `references/claude.md`
(adaptive thinking, structured outputs not prefill, model pinning, tool-triggering).

### Phase 1 Output

- Complete system prompt (ready to use)
- Optional: few-shot examples block (if applicable)
- Optional: output schema definition (if structured output required)
- Token count estimate (via `count_tokens`, model-specific)

---

## Phase 2: Test — Automated Prompt Evaluation

**Trigger**: After Phase 1, or user wants to test an existing prompt.

**Exit criteria**: All assertions pass. PASS rate ≥80% on golden dataset.

### 2.1 Create Golden Dataset

Minimum dataset (18 test cases per research findings):
- **10 core cases**: representative of normal usage (happy path)
- **5 edge cases**: boundary conditions, unusual inputs, empty inputs
- **3 adversarial cases**: injection attempts, constraint violations, jailbreak probes

For each test case, define:
- `input`: the prompt input
- `assert`: at least 1 measurable assertion (not just "looks good")

Common assertion types:
- `contains`: response contains specific text
- `not-contains`: response does NOT contain specific text
- `javascript`: custom JS assertion function
- `llm-rubric`: natural language quality check via LLM-as-judge

### 2.2 Generate promptfooconfig.yaml

Write the config file:
```yaml
# promptfooconfig.yaml
description: "[prompt name] evaluation suite"
prompts:
  - file://system-prompt.txt

providers:
  - anthropic:messages:claude-sonnet-4-6  # pin exact version

tests:
  # Core cases
  - description: "[case name]"
    vars:
      input: "[test input]"
    assert:
      - type: [assertion-type]
        value: "[expected value]"
  # ... 17 more cases per tools/promptfoo-starter.yaml template
```

→ See `tools/promptfoo-starter.yaml` for ready-to-use template with 18 test cases.

### 2.3 Execute Evaluation

```bash
# Install (first time)
npx promptfoo@latest init

# Run evaluation
npx promptfoo eval --no-cache

# View results
npx promptfoo view
```

### 2.4 Interpret Results

Key metrics from promptfoo output:
- **Pass rate**: target ≥80% on initial run, 100% after optimization
- **Consistency**: run same tests 3× and check variance (>5% variance = non-deterministic prompt)
- **Cost**: total token cost per test run (useful for budget planning)
- **Latency**: p50/p95 latency per provider

Failure analysis:
- Group failures by assertion type
- Check if failures cluster on edge cases vs core cases (different root causes)
- Failures on adversarial cases → fix security constraints (Phase 1.6)
- Failures on core cases → fundamental prompt issue (return to Phase 1 or escalate to Phase 3)

### 2.5 Red Teaming (optional, for security-critical prompts)

Map to the **OWASP LLM Top 10 2025** via promptfoo's `owasp:llm` plugin preset
(individual risks `owasp:llm:01`..`owasp:llm:10`):

```yaml
# promptfooconfig.yaml — red-team section
redteam:
  plugins:
    - owasp:llm          # all 10, or pin individual risks below
    - owasp:llm:01       # LLM01 Prompt Injection
    - owasp:llm:07       # LLM07 System Prompt Leakage (new in 2025)
  strategies:
    - prompt-injection   # wraps payload in injection frames
    - jailbreak          # DAN-style bypass
    - crescendo          # multi-turn escalation, each message builds on the last
```

```bash
npx promptfoo redteam generate --purpose "customer service chatbot"
npx promptfoo redteam run
```

2025 risk IDs to probe for a prompt: **LLM01** Prompt Injection, **LLM02** Sensitive Information
Disclosure, **LLM05** Improper Output Handling, **LLM06** Excessive Agency, **LLM07** System Prompt
Leakage (new in 2025), **LLM09** Misinformation. Delivery strategies map to attack shape:
`prompt-injection` (frames), `jailbreak` (bypass), `crescendo` (multi-turn escalation).

When to run: auth-adjacent prompts, multi-agent systems, user-facing production prompts.

### Phase 2 Output

- `promptfooconfig.yaml` (committed to repo)
- Test results (pass/fail per case with assertion details)
- Pass rate summary

---

## Phase 3: Optimize — Diagnose and Fix

**Trigger**: `/audit` entry, or Phase 2 tests failing.

**Entry criteria**: Test failures exist that need diagnosis, OR user explicitly requests optimization.

### 3.1 Escalation Gate

Before optimizing, score the prompt on 6 dimensions (1–10, ≤4 = needs fix):

| Dimension | Score | Assessment |
|-----------|-------|------------|
| Task clarity | __ | Is the primary task unambiguous? |
| Context sufficiency | __ | Does the prompt have enough context to succeed? |
| Format precision | __ | Is the output format fully specified? |
| Scope boundary | __ | Are the MUST/NEVER limits clear? |
| Reasoning support | __ | Does the prompt support the model's reasoning process? |
| Agentic safety | __ | Are injection and scope-creep defenses in place? |

**Escalation rule**: If ≥2 dimensions score ≤2 → escalate to **Phase 1 full redesign**.
Optimizing a broken foundation wastes effort. Diagnosis confirmed by the failure taxonomy:
- 46% of prompt failures are environment/infrastructure faults (not the prompt)
- 25% are configuration faults (wrong model, wrong temperature)
- Only ~29% are actual prompt wording issues

→ Before blaming the prompt, check: Is the failure in infra/config? Run `references/failure-catalog.md` diagnosis first.

### 3.2 Failure Mode Diagnosis

→ Load `references/failure-catalog.md` and match symptoms to failure modes:

| Symptom | Likely Failure Mode | Reference Section |
|---------|-------------------|-------------------|
| Ignoring format constraints | FM-1: Format Drift | §FM-1 |
| Hallucinated facts in RAG | FM-2: RAG Hallucination | §FM-2 |
| Broke after model update | FM-3: Silent Regression | §FM-3 |
| Losing context mid-conversation | FM-4: Context Overflow | §FM-4 |
| Executing injected instructions | FM-5: Prompt Injection | §FM-5 |
| Unstable despite prompt fixes | FM-6: Fix-Prompt Fallacy | §FM-6 |

### 3.3 Context and Format Diagnosis

Load context audit steps from Phase 1:
- Run token audit (Phase 1.4): is the prompt exceeding budget?
- Check U-shaped placement: are critical constraints in the first 30%?
- Check cache architecture: is the stable prefix truly stable?

Load `references/output-format.md`:
- Run compliance verification: is the format precisely defined?
- Check schema completeness: are all edge cases covered (empty arrays, null values)?

### 3.4 Fix with Tradeoff Presentation

For each diagnosed issue, present ≥2 options before applying:

```
Issue: [description]

Option A: [fix name]
  → Effect: [what changes]
  → Risk: [what might break]
  → Cost: [token/complexity impact]

Option B: [fix name]
  → Effect: [what changes]
  → Risk: [what might break]
  → Cost: [token/complexity impact]

Recommendation: [option] because [reason]
```

### 3.5 Pre-Delivery Check (6-point)

Before delivering the optimized prompt:
1. **Tool syntax**: All CLI commands in the prompt are syntactically valid
2. **Critical weight**: Most important constraint is in the first 30%
3. **Signal strength**: Constraints use direct language (not hedged)
4. **Fabrication audit**: No facts stated without source or grounding
5. **Token efficiency**: No redundant instructions (duplicates cancel each other)
6. **First-pass success**: Would a capable model succeed on the first try?

### 3.6 Programmatic Optimization — DSPy MIPROv2 or GEPA

When to use programmatic optimization (consult `tools/selection-matrix.md` optimizer sub-matrix):

```python
import dspy

class PromptTask(dspy.Signature):
    """[Your task description here]"""
    input_text = dspy.InputField()
    output = dspy.OutputField()

lm = dspy.LM("anthropic/claude-opus-4-8")
dspy.configure(lm=lm)
```

**MIPROv2** — Bayesian search over instructions+demos, best for pure scalar-metric search:
```python
from dspy.teleprompt import MIPROv2
optimizer = MIPROv2(metric=your_metric_fn, auto="medium")
optimized = optimizer.compile(PromptTask(), trainset=train_examples)
optimized.save("optimized_program.json")
```

**GEPA** (Genetic-Pareto reflective evolution, ICLR 2026 oral, arXiv:2507.19457) — reads execution
traces, diagnoses failures in natural language, maintains a Pareto frontier of candidates. Prefer it
over MIPROv2 when you have **rich textual feedback** (test traces / error messages) and a **tiny
trainset** (works with as few as 3 examples):
```python
optimizer = dspy.GEPA(
    metric=your_metric_fn,
    max_metric_calls=150,
    reflection_lm="openai/gpt-4.1",  # REQUIRED — the separate, usually stronger reflection model
)
optimized = optimizer.compile(PromptTask(), trainset=train_examples)
```
Grounded numbers: GEPA beats MIPROv2 by **>10pp** (+10pp on AIME-2025 with GPT-4.1-mini:
46.6%→56.6%), beats GRPO by **~20% with ~35× fewer rollouts** (100–500 evals vs 5,000–25,000+ for
GRPO), and discovered an agent architecture lifting ARC-AGI **32%→89%**. `reflection_lm` is a
required parameter — GEPA degrades to MIPROv2-like behavior without a capable reflection model.

**Decision rule**: tiny trainset + textual error feedback → GEPA; pure scalar metric, no trace
narrative → MIPROv2; need only demonstrations → BootstrapFewShot (see `tools/selection-matrix.md`).

### 3.7 Regression Verification

After applying fixes, re-run Phase 2 test suite to confirm:
- All previously-passing tests still pass
- Fixed tests now pass
- No new failures introduced

```bash
npx promptfoo eval --no-cache
```

Regression verification is distinct from Phase 2's initial test — its purpose is to confirm
the optimization didn't break what was working.

### Phase 3 Output

- Optimized prompt with before/after comparison
- Failure mode diagnosis report
- Tradeoff decisions log
- Regression test results

---

## Phase 4: Ship — Version, CI/CD, Deploy

**Trigger**: Phase 2 tests passing, ready to deploy.

### 4.1 Prompt Versioning (git-native)

Directory structure:
```
prompts/
├── customer-support/
│   ├── v1.0.0/
│   │   ├── system-prompt.txt
│   │   ├── promptfooconfig.yaml
│   │   └── test-results-2026-01-15.json   # Required: link to test run
│   ├── v1.1.0/
│   │   └── ...
│   └── CHANGELOG.md
```

**Semantic versioning rules**:
- **MAJOR**: behavior change (different output format, different task scope)
- **MINOR**: quality improvement (same behavior, better performance)
- **PATCH**: typo fix, whitespace, metadata only

**CHANGELOG entry format** (required per version):
```markdown
## v1.1.0 (2026-01-15)
**Why**: Format drift detected in 3% of production responses (FM-1)
**Fix**: Added explicit JSON schema constraint + format lock
**Test results**: 18/18 assertions pass (promptfoo eval 2026-01-15-results.json)
**Breaking change**: No
```

### 4.2 Model Version Pinning (critical)

❌ **Never**: `claude-sonnet` (alias — points to different weights over time → FM-3 silent regression)
✅ **Always**: `claude-opus-4-8` / `claude-sonnet-4-6` / `claude-haiku-4-5` / `claude-fable-5` (exact version; never append a date suffix to an alias)

Run `tools/prompt-lint.sh promptfooconfig.yaml system-prompt.txt` to mechanically catch unpinned
aliases, missing assertions, and over-triggering language before shipping (exit 2 = blocked).

⚠️ Model-upgrade API breakage (see `references/claude.md`): moving onto Opus 4.7/4.8/Fable 5 makes
`thinking.budget_tokens`, last-assistant-turn prefill, and `temperature`/`top_p`/`top_k` return
**HTTP 400** — a prompt that worked on 4.6 can hard-fail on upgrade. Check the migration table.

Upgrade checklist:
1. Pin new version in non-production environment
2. Run full regression suite against golden dataset
3. Compare outputs on 10 representative production samples
4. Check new model's release notes for behavior changes
5. Deploy with canary (5% traffic) for 24–48h before full rollout

### 4.3 CI/CD Pipeline Setup

→ Load `references/ci-cd-templates.md` for complete GitHub Actions templates.

**3-tier pipeline summary**:

| Tier | When | Duration | Gate |
|------|------|----------|------|
| Tier 1 | Per-commit | <2 min | JSON format, keywords, token budget |
| Tier 2 | Per-PR | 10–20 min | LLM-as-judge regression on golden set, blocks merge |
| Tier 3 | Weekly/pre-release | 60–90 min | Vulnerability scan, jailbreak, edge-case hallucination |

### 4.4 Prompt Drift Monitoring

Signals to monitor in production:
- **Refusal rate**: sudden spike = model update or context change
- **Format compliance rate**: drop = format drift (FM-1)
- **Semantic similarity drift**: outputs diverging from historical baseline
- **Token cost deviation**: >20% change = prompt or model behavior change

Set up alerting thresholds based on 7-day rolling baseline.

### Phase 4 Output

- Versioned prompt directory committed to git
- CI/CD config file (GitHub Actions YAML or equivalent)
- Model pinning confirmed
- Monitoring thresholds set

---

## Anti-Skip Table (why each phase is NOT optional)

Agents rationalize skipping the lifecycle. Each excuse below has a one-line counter:

| Excuse to skip | Counter |
|----------------|---------|
| "The prompt looks fine, skip Phase 2 testing" | "Looks fine" is not a measurement. 46% of failures are env/config, invisible to eyeballing — only a golden-set run surfaces them. |
| "It's just a small wording change, skip regression" | Wording changes are exactly what drift FM-1 catches. Re-run Phase 2; `prompt-lint.sh` is <1s. |
| "No time for a golden set" | 18 cases (10 core / 5 edge / 3 adversarial) is the floor, not a luxury — without it you ship blind and pay in production incidents. |
| "Just bump the model ID, it's a patch" | Model upgrades 400 on removed params (budget_tokens/prefill/temperature on 4.7+). Run the §4.2 upgrade checklist + regression. |
| "Skip red-team, it's internal only" | Internal prompts still process untrusted data (LLM01). Run `owasp:llm` if the prompt sees any user/external content. |
| "Optimize the wording, the prompt is the problem" | Don't blame the prompt first — 46% env / 25% config / 29% wording (Phase 3.1). Diagnose before editing. |
| "Ship without linking a test run" | A version with no test-results link is unauditable; CHANGELOG requires the run (Phase 4.1). |
| "Aggressive 'MUST USE' language is safer" | It over-triggers on Claude 4.6+ (claude.md Rule 4). `prompt-lint.sh` blocks it. |

---

## Anti-Slop Rules (applied at every phase)

Rules that prevent generic output:

1. **No "You are a helpful assistant"** — every prompt must have domain + value anchoring
2. **No manual CoT for reasoning-native models** — Claude 4.6+ uses adaptive thinking + the `effort`
   parameter (NOT `thinking.budget_tokens`, which 400s on Opus 4.7+); keep CoT only in few-shot examples
3. **No "MUST USE" aggressive language on Claude 4.6+** — causes over-triggering; use direct language
4. **No testing without assertions** — every test case needs ≥1 measurable assertion (`prompt-lint.sh` enforces)
5. **No version without test results** — every prompt version must link to a test run
6. **No prompt fix without root cause** — check failure taxonomy first (46% env, 25% config, 29% wording)
7. **No prefill for format-locking on Claude 4.6+** — use `output_config.format` (structured outputs); prefill 400s
