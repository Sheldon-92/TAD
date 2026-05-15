# ai-evaluation Capability Pack — Deep Ask Research Findings

> Notebook: AI Evaluation — Agent Benchmarking, Testing, and Quality Assurance 2025-2026
> Notebook ID: ec2a0093-d7b7-4b74-bb29-e3eeb0bfdc28
> Sources: ~369 (22 manual GitHub + deep research auto-import)
> Date: 2026-05-15
> Rounds: 3

---

## Round 1: Evaluation Framework Design + Tool Selection

### promptfoo
- CLI: `npx promptfoo@latest init`, `npx promptfoo@latest eval`, `npx promptfoo@latest view`
- Focus: adversarial testing ("plugins" for specific failure modes), regression catching
- Scoring: pass/fail oriented (vulnerability detection)
- Runs 100% locally — prompts never leave machine
- Red-team plugins: Harmful content, BOLA, BFLA, Competitor endorsement, Prompt injection, Jailbreak, PAIR, tree-of-attacks, crescendo, many-shot

### DeepEval
- CLI: `deepeval login`, `deepeval test run`, `deepeval test run test_example.py`
- 50+ metrics including:
  - Agentic: Task Completion, Tool Correctness, Goal Accuracy, Step Efficiency, Plan Adherence, Plan Quality
  - RAG: Answer Relevancy, Faithfulness, Contextual Recall/Precision/Relevancy
  - Multi-Turn: Knowledge Retention, Conversation Completeness, Turn Relevancy, Role Adherence
  - MCP: MCP Task Completion, MCP Use, Multi-Turn MCP Use
  - Other: Hallucination, Summarization, Bias, Toxicity, JSON Correctness, Prompt Alignment
- G-Eval (LLM-as-judge) + DAG (deterministic graph-based metric builder)
- pytest integration (unit-test style)

### Ragas
- CLI: `ragas quickstart`, `ragas quickstart --template rag_eval`
- Metrics: Faithfulness (0-1), Answer relevancy, Context relevancy/precision, Contextual recall, Tool-call accuracy, Agent-goal accuracy, Aspect Critique (DiscreteMetric)
- Reference-free, LLM-assisted evaluation
- Templates: rag_eval (available), agent_evals/benchmark_llm/prompt_evals (coming soon)

### DeepTeam (Red-Teaming)
- CLI: `deepteam redteam run --model=gpt-4o --framework=OWASPTop10`
- 20+ SOTA adversarial attacks
- Single-turn: Prompt Injection, Roleplay, Leetspeak, ROT13, Base64, Gray Box, Math Problem, Multilingual, System Override, Permission Escalation, Goal Redirection, Context Poisoning, Embedded Instruction JSON
- Multi-turn: Linear/Tree/Crescendo/Sequential Jailbreaking, Bad Likert Judge

---

## Round 2: Regression, A/B Testing, Bias Patterns

### Baseline Management
- Golden dataset: 50-100 representative trajectories (living baseline, grows with production failures)
- VeRO pattern: Git-based versioning for agent snapshots + structured experiment DB with execution traces + per-sample scores
- Baselines must include entire trajectories, not just single outputs

### Drift Detection
- Scheduled online evaluations against live production traffic (hourly for high-traffic)
- Same rubrics as pre-deployment testing
- Trigger metrics: hallucination rate spike (6%→14%), Agent Path Convergence drop, escalation rate increase
- Tools: Arize Phoenix (embedding drift for RAG), Galileo AI (automatic "Signals" for failure patterns)

### A/B Testing Statistical Rigor
- n=100 binary trials → Wilson CI half-width ~7-9.5pp (differences <10% are noise)
- n=550 per configuration → 4-5pp bounds (tight enough for production decisions)
- Panel sizing: 4 agents for continuous monitoring, 8-12 for periodic audits
- Statistical tests: paired McNemar (binary), paired t-test (continuous), two-proportion z-test (protocol violations), Wilson 95% CI (success rates)
- Multiplicity correction: Benjamini-Hochberg and Benjamini-Yekutieli

### Judge=Optimizer Bias
- Self-enhancement bias: LLMs rate own outputs more favorably
- Mitigation 1: Cross-model judging (different model family for judge vs generator)
- Mitigation 2: CollabEval — multi-agent referee team with distinct personas, multi-round debate consensus
- Mitigation 3: VERIMAP — embed Python verification functions (deterministic assertions) alongside LLM judge

---

## Round 3: Adversarial, CI/CD, Human Eval

### Adversarial Tools Summary
| Tool | Attack Count | Key CLI | Focus |
|------|-------------|---------|-------|
| DeepTeam | 20+ SOTA | `deepteam redteam run --model=X --framework=Y` | OWASP-aligned, single+multi-turn |
| promptfoo | PAIR, tree-of-attacks, crescendo | `npx promptfoo@latest eval` | Vulnerability scanning, BOLA/BFLA |
| PyRIT | 40+ built-in | (no CLI syntax in sources) | Microsoft framework, multi-turn |
| Giskard | 50+ probes | (no CLI syntax in sources) | Dynamic stress tests, Crescendo/GOAT |
| Garak | 50+ probes | (no CLI syntax in sources) | Vulnerability scanner |

### CI/CD Integration Patterns
- Braintrust: GitHub Actions with configurable quality gates
- LangSmith: pytest, Vitest, GitHub workflows
- DeepEval: pytest integration (eval as standard unit tests on every PR)
- promptfoo + Garak: CI/CD pipeline support (exact YAML configs not in sources)

### Human Evaluation Protocols
- Inter-rater reliability: Krippendorff's α (α=0.78 enterprise target), ICC(2,1) and ICC(2,K) (>0.92 single-agent, >0.97 multi-panel)
- Calibration: 2-3 domain experts score 100-200 samples with behaviorally anchored rubrics
- Entropy-based calibration reweighting for automated evaluator scores
- Bridge target: ≥0.80 Spearman correlation between LLM judge and human expert consensus (pipelines reaching 0.86)
- Layered routing: deterministic rules → automated LLM judge → human escalation for high-stakes
- Risk-adjusted oversight: dense human review for high-stakes, random sampling for routine

---

## Key Judgment Rules Extracted (for Capability Pack)

### eval_framework_design (Structured Workflow)
1. Start with 5 dimensions: Capability, Reliability, Quality, Safety, Efficiency
2. Each dimension must have specific measurable metrics (not "quality" or "accuracy")
3. determinismLevel per rubric item: deterministic / semi-deterministic / non-deterministic
4. Anchored rubric descriptions at 1.0/0.7/0.3/0.0 scale points
5. "Outcomes over steps" — check results, not tool invocations

### benchmark_testing
1. Default tool: promptfoo for YAML-driven eval, deepeval for Python pytest integration
2. Golden dataset: 50-100 representative trajectories (living, grows with prod failures)
3. "Mocks Hide SDK Shape Validation" — don't mock tool responses in benchmarks

### regression_testing
1. Same rubrics for pre-deployment and production monitoring (no rubric drift)
2. Drift triggers: hallucination rate, path convergence, escalation rate
3. Scheduled evaluations against live traffic (hourly for high-traffic)

### ab_testing
1. n=100 minimum for binary pass/fail; n=550 for tight confidence bounds
2. Paired McNemar for binary, paired t-test for continuous scores
3. Judge≠Optimizer (cross-model judging mandatory)
4. CollabEval multi-agent debate for bias cancellation

### adversarial_testing
1. DeepTeam for OWASP-aligned red-teaming (CLI-native)
2. Multi-turn attacks are harder to detect than single-turn (escalation patterns)
3. promptfoo for vulnerability scanning + BOLA/BFLA authorization testing

### automated_pipeline
1. DeepEval pytest for PR-level quality gates
2. Braintrust GitHub Actions for deployment gates
3. Layered: deterministic checks → LLM judge → human escalation

### human_eval_protocol (Structured Workflow)
1. 2-3 experts, 100-200 samples, behaviorally anchored rubrics
2. Target: ICC(2,1) > 0.92 for single evaluator reliability
3. Bridge: ≥0.80 Spearman correlation between automated and human
4. Calibration frequency: recalibrate when automated-human gap exceeds 0.05
