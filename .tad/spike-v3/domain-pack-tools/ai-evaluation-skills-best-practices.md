# AI Evaluation Skills Best Practices — Research Summary

**Date**: 2026-04-02
**Sources**: 6 repos/frameworks researched (Blake Phase 1)
**Purpose**: ai-evaluation.yaml capability design reference

---

## Sources Researched

| Source | Type | Stars/Adoption | Key Strength |
|--------|------|----------------|--------------|
| Skill-Eval (Google/Minko Gechev) | Blog + framework | Google internal | Pass@k/Pass^k reliability metrics, Docker isolation, multi-trial testing |
| Promptfoo | CLI framework | 300K+ devs, 127 Fortune 500 | YAML-driven eval, 90+ providers, red teaming, CI/CD native |
| DeepEval (Confident AI) | Python framework | High (PyPI) | 50+ metrics, pytest integration, agentic metrics (task completion, tool correctness) |
| DeepTeam (Confident AI) | Red teaming framework | Growing | 37+ vulnerability types, OWASP Top 10 for Agents 2026, adversarial attacks |
| Langfuse | Observability platform | YC W23, high adoption | Tracing + evaluation, dataset experiments, iterative improvement |
| AgentEvals (LangChain) | Trajectory evaluators | LangChain ecosystem | Trajectory matching (strict/unordered/subset), LLM-as-judge |

---

## By Capability: Extracted Best Practices

### Eval Framework Design (Type A: Document)

**Best Step Design** (from DeepEval + Skill-Eval):
1. Define evaluation dimensions — what aspects of agent behavior to measure
2. For each dimension, select metric type: deterministic (binary pass/fail) vs LLM-as-judge (0.0-1.0 scored)
3. Define test case structure: input, expected_output, actual_output, context
4. Set thresholds: what score = PASS (default 0.5, recommend ≥0.7 for production)
5. Design scoring rubric with specific criteria (not "is it good?" but "did it find 3 intentional bugs?")

**Best Analysis Framework** (from DeepEval metrics taxonomy):
- Custom metrics: G-Eval (natural language criteria → LLM scoring), DAG (decision tree judgment)
- Agentic metrics: Task Completion, Tool Correctness, Argument Correctness, Step Efficiency, Plan Adherence
- Safety metrics: Bias, Toxicity, PII Leakage, Role Violation
- RAG metrics: Faithfulness, Answer Relevancy, Contextual Precision/Recall

**Quality Standards** (from Skill-Eval):
- "Follow outcomes, not steps" — check that the file was fixed, not that the agent ran a specific command
- Multi-trial requirement: minimum 5 runs to account for non-determinism
- Pass@k (capability): can agent solve at least once in k tries?
- Pass^k (reliability): does agent solve every time in k tries?

**Anti-patterns**:
- ❌ Single run = no signal about reliability (Skill-Eval)
- ❌ Grading steps instead of outcomes prevents creative solutions (Skill-Eval)
- ❌ "Is it good?" subjective criteria → replace with "Did it find 3 intentional bugs?" (Promptfoo)
- ❌ String-matching for LLM output → use semantic assertions (Promptfoo)

---

### Benchmark Testing (Type B: Code)

**Best Step Design** (from Promptfoo agent eval guide):
1. Define test scenarios in YAML with structured prompts specifying multi-step tasks
2. Configure provider (model + tools + permissions + working directory)
3. Run tests with assertions stacked: contains-json + javascript validators + llm-rubric
4. Measure: cost (threshold), latency (threshold), step count (min tool calls), token distribution
5. Run with `--repeat N` for variance/stability assessment

**Promptfoo YAML structure**:
```yaml
tests:
  - vars: { scenario: "..." }
    assert:
      - type: contains-json           # structural check
      - type: javascript              # behavioral validation
        value: "const r = JSON.parse(output); return { pass: r.score > 0.8 };"
      - type: llm-rubric              # qualitative check
        value: "Are recommendations specific and actionable?"
        threshold: 0.7
      - type: trajectory:step-count   # agent behavior check
        value: { type: command, pattern: 'pytest*', min: 1 }
      - type: cost
        threshold: 0.25
      - type: latency
        threshold: 30000
```

**Quality Standards**:
- ≥5 test scenarios per capability being evaluated
- Each test has ≥3 assertion types (structural + behavioral + qualitative)
- Cost and latency budgets defined
- Variance measured across ≥3 runs

**Anti-patterns**:
- ❌ Testing knowledge ("explain X") instead of capability ("do X") (Promptfoo)
- ❌ No baselines — plain LLM vs agent comparison reveals capability gaps (Promptfoo)
- ❌ Checking only final output, ignoring intermediate steps/trajectory (Promptfoo)

---

### A/B Testing (Type B: Code)

**Best Step Design** (from Promptfoo + Langfuse):
1. Define identical test dataset (same inputs for both configurations)
2. Configure two providers (different prompts/models/settings)
3. Run side-by-side evaluation with same assertions
4. Compare: per-test scores, aggregate pass rate, cost, latency
5. Statistical significance check before declaring winner

**From Langfuse iterative workflow**:
- Phase 1: Create dataset of representative inputs
- Phase 2: Run baseline experiment with Config A
- Phase 3: Run experiment with Config B
- Phase 4: Compare traces — success rates, error patterns, cost
- Phase 5: "Single-word changes (marking parameters 'mandatory' vs 'optional') significantly impacted success rates"

**Quality Standards**:
- Same dataset for both configs (≥20 test cases for statistical relevance)
- Blind evaluation (evaluator doesn't know which config produced output)
- Measure both quality AND cost/latency (better quality at 10x cost may not win)

**Anti-patterns**:
- ❌ Different test inputs for A and B → invalid comparison
- ❌ Single metric comparison → must compare multi-dimensional (quality + cost + latency)
- ❌ No statistical significance → small sample = noise

---

### Regression Testing (Type B: Code)

**Best Step Design** (from Skill-Eval + Promptfoo CI/CD):
1. Maintain golden test suite (baseline passing tests)
2. Before change: run suite, record baseline scores
3. Apply change (prompt edit, config update, model swap)
4. After change: run same suite
5. Compare: any test that previously passed now fails = regression
6. Gate: zero regressions on critical tests, ≤N% degradation on non-critical

**From Skill-Eval**:
- "Small change can silently break the agent's behavior" → automated regression catches this
- Pass@5 and Pass^5 both tracked — capability AND reliability regression
- Multi-trial (≥5) to distinguish real regression from noise

**Quality Standards**:
- Golden suite maintained in version control alongside prompts/configs
- CI/CD integration: eval runs on every PR/commit
- Regression report: which tests degraded, by how much, with traces

**Anti-patterns**:
- ❌ No golden suite → no baseline to compare against
- ❌ Single-run comparison → noise looks like regression
- ❌ Ignoring latency/cost regression → quality same but 5x slower = regression

---

### Adversarial Testing (Type B: Code)

**Best Step Design** (from DeepTeam + Promptfoo red team):
1. Define target agent's safety constraints (what it must NOT do)
2. Select vulnerability categories to test (from 37+ DeepTeam types or Promptfoo 67+ plugins)
3. Configure attacks: single-turn (prompt injection, Leetspeak, ROT-13) + multi-turn (crescendo, tree jailbreak)
4. Run red team scan against target
5. Score: binary 0/1 per vulnerability (0 = safe, 1 = vulnerable)
6. Generate report with attack traces and remediation recommendations

**DeepTeam 6 categories**:
- Responsible AI: Bias, Toxicity, Child Protection, Ethics, Fairness
- Data Privacy: PII Leakage, Prompt Leakage
- Security: BFLA, BOLA, RBAC, Shell/SQL Injection, SSRF, Debug Access
- Safety: Illegal Activity, Graphic Content, Personal Safety
- Business: Misinformation, IP Violation, Competition
- Agentic: Goal Theft, Recursive Hijacking, Excessive Agency, Autonomous Drift, Tool Abuse

**Quality Standards**:
- ≥3 vulnerability categories tested (minimum: Responsible AI + Security + Agentic)
- Both single-turn and multi-turn attacks used
- Zero tolerance for critical vulnerabilities (PII leakage, shell injection)
- Mapped to OWASP Top 10 for LLMs/Agents

**Anti-patterns**:
- ❌ Only testing prompt injection → agents have action-level risks too (DeepTeam agentic category)
- ❌ Manual-only red teaming → not repeatable, not CI-integrated
- ❌ Testing model safety but not agent safety (tool abuse, excessive agency) (DeepTeam)

---

### Automated Evaluation Pipeline (Type B: Code)

**Best Step Design** (from Promptfoo CI/CD + Langfuse + Skill-Eval):
1. Define eval config (YAML/Python) with test cases + assertions + thresholds
2. Set up CI trigger (on PR, on commit, on schedule)
3. Run eval in isolated environment (Docker container per Skill-Eval)
4. Collect results: pass/fail per test, aggregate scores, cost, latency
5. Gate: block merge if critical tests fail; warn on non-critical degradation
6. Store results for trend tracking (Langfuse dashboard / Promptfoo history)

**Promptfoo CI/CD pattern**:
```bash
npx promptfoo eval --config eval-config.yaml --output results.json
npx promptfoo eval --config eval-config.yaml --ci  # exits non-zero on failure
```

**Skill-Eval Docker isolation**:
- Each eval runs in fresh Docker container
- Agent discovers skills from standard paths
- Results stored with trial metadata

**Quality Standards**:
- Pipeline runs on every PR that changes prompts/config/skills
- ≥5 trials for non-deterministic tests (Pass@5)
- Cost budget per eval run (prevent runaway costs)
- Results dashboard with historical trends

**Anti-patterns**:
- ❌ Eval only in dev, not in CI → regressions ship to production
- ❌ No cost budget → eval pipeline itself costs too much to run
- ❌ No Docker/sandbox isolation → eval side effects contaminate environment

---

### Human Evaluation Protocol (Type Mixed)

**Best Step Design** (from Langfuse + DeepEval + TAD 4D Protocol):
1. Define evaluation rubric: dimensions + scoring scale + examples for each score level
2. Create evaluation dataset: ≥20 representative inputs spanning edge cases
3. Collect agent outputs (with full traces)
4. Human evaluators score each output against rubric
5. Calculate inter-rater agreement (≥2 evaluators per output)
6. Calibrate: resolve disagreements, update rubric if needed
7. Compare human scores with automated metrics (validate automation)

**From Langfuse**:
- LLM-as-judge + human labeling used together
- Human feedback collection integrated into trace review
- Iterative: refine evaluation criteria based on disagreement patterns

**From DeepEval**:
- Role Adherence metric (human validates character consistency)
- Conversation Completeness (human judges if user need was satisfied)
- Knowledge Retention (human checks information maintained across turns)

**Quality Standards**:
- Rubric has specific examples for each score level (1-5 scale with anchored descriptions)
- ≥2 independent evaluators per output
- Inter-rater agreement ≥70% (Cohen's kappa ≥0.4)
- Human eval validates/calibrates automated metrics

**Anti-patterns**:
- ❌ Unanchored rubric ("rate quality 1-5" without examples) → inconsistent scoring
- ❌ Single evaluator → no reliability measure
- ❌ Human eval only, no automation → doesn't scale, can't run in CI
- ❌ Human eval disconnected from automated metrics → no calibration

---

## Cross-Cutting Insights

### Tool Ecosystem (2026 state)

| Tool | Best For | CLI | CI/CD | Free |
|------|----------|-----|-------|------|
| Promptfoo | Prompt/agent eval + red teaming | ✅ `npx promptfoo eval` | ✅ native | ✅ OSS |
| DeepEval | Python-native LLM testing | ✅ `deepeval test run` | ✅ pytest | ✅ OSS |
| DeepTeam | Red teaming / adversarial | ✅ CLI + Python | ✅ YAML config | ✅ OSS |
| Langfuse | Tracing + eval experiments | ❌ (web UI + SDK) | ✅ via SDK | ✅ self-host |
| AgentEvals | Trajectory matching | ❌ (Python lib) | ✅ via pytest | ✅ OSS |

### Key Principle: Outcomes Over Steps
Every source agrees: grade what the agent accomplished, not how it got there. Allow creative solutions within constraints.

### Key Metric Taxonomy
- **Capability**: Can it do it? (Pass@k)
- **Reliability**: Does it do it consistently? (Pass^k)
- **Quality**: How good is the output? (G-Eval, LLM-rubric, 0.0-1.0)
- **Safety**: Does it stay within bounds? (Binary: vulnerable/safe)
- **Efficiency**: How much does it cost? (tokens, latency, dollars)
