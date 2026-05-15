---
name: ai-evaluation
description: AI evaluation capability pack. Gives AI agents the judgment rules for professional benchmarking, regression testing, A/B comparison, adversarial red-teaming, CI/CD evaluation pipelines, evaluation framework design, and human evaluation calibration. Research-grounded rules from promptfoo, deepeval, deepteam, ragas, and enterprise evaluation practices. Use for any LLM/agent evaluation, benchmark design, safety testing, or evaluation pipeline task.
keywords: ["评估", "evaluation", "eval", "benchmark", "基准测试", "回归测试", "regression", "adversarial", "对抗", "A/B test", "自动化评估", "promptfoo", "deepeval", "红队", "red team", "rubric", "评分"]
type: reference-based
---

**CONSUMES**: User evaluation task + target agent/LLM description + optional existing eval configs
**PRODUCES**: Applied evaluation judgment rules + benchmark configs + regression baselines + safety audit results + CI/CD pipeline configs + calibrated rubrics

# AI Evaluation Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents set up evaluation by copying tutorial configs. They run promptfoo once with default assertions. They skip statistical rigor — declaring a winner from n=20. They use the same model as judge and generator, hiding self-enhancement bias behind high scores. They never build regression baselines, so prompt changes break production silently.

This pack embeds the judgment rules that evaluation engineers apply automatically — rules from real evaluation frameworks, red-team tooling documentation, and statistical testing literature.

**Pack = evaluation judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Judge ≠ Optimizer

> **When comparing or optimizing LLM outputs, the judge model MUST be a different model family from the generator.** Same-family judging inflates scores by 10-15% due to self-enhancement bias. If forced to use the same family, document the bias explicitly and flag results as "internally consistent only — needs cross-family validation."

This rule applies to: benchmark scoring, A/B testing, regression comparison, and any LLM-as-Judge workflow. It is surfaced here because burying it in one reference file causes agents to miss it.

---

## Step 0: Context Detection

When the user mentions evaluation work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "design eval", "evaluation framework", "rubric", "dimensions", "scoring criteria", "评估框架" | `references/eval-framework-workflow.md` |
| "benchmark", "baseline", "golden dataset", "test scenarios", "基准测试" | `references/benchmark-rules.md` |
| "regression", "drift", "golden suite", "before/after", "回归测试" | `references/regression-rules.md` |
| "A/B test", "compare prompts", "compare models", "which is better", "对比测试" | `references/ab-testing-rules.md` |
| "red team", "adversarial", "safety test", "attack", "jailbreak", "OWASP", "对抗测试" | `references/adversarial-rules.md` |
| "CI/CD", "pipeline", "automation", "GitHub Actions", "PR gate", "自动化评估" | `references/pipeline-rules.md` |
| "human eval", "annotator", "inter-rater", "calibration", "人工评估" | `references/human-eval-protocol.md` |
| "full evaluation", "complete eval setup", "evaluate everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's evaluation setup, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce the Judge ≠ Optimizer cross-cutting rule** on every LLM-as-Judge configuration
5. **Check determinismLevel annotations** — they tell the eval runner how many samples to draw:
   - `deterministic`: 1 run sufficient (byte-stable output)
   - `semi-deterministic`: run ≥3x to bound variance
   - `non-deterministic`: run ≥10x and report distribution

Output format per finding:
```
[P0] Rule 3 (benchmark): Golden dataset has only 12 cases — minimum is 50 representative trajectories.
→ Expand dataset to ≥50 cases covering core/edge/error/performance scenarios.

[P1] Rule 7 (ab-testing): Same model (claude-sonnet) used as both generator and judge.
→ Switch judge to a different family (e.g., gpt-4o) or document self-enhancement bias.
```

---

## Step 2: Output

Produce a structured evaluation report:

```
## Evaluation Review: [area reviewed]

### P0 — Blocking (must fix before running eval)
- [finding + specific fix]

### P1 — Required (fix before trusting results)
- [finding + specific fix]

### P2 — Advisory (improves eval quality)
- [finding + specific fix]

### determinismLevel Audit
[table of rubric items with their determinism classification]

### Tool Recommendation
[promptfoo / deepeval / deepteam based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We only need a quick eval" | Quick evals with n=20 have ±10pp confidence intervals. You cannot tell a 70% from an 80% system. At minimum use n=100. |
| "We'll add regression later" | Without a golden suite today, tomorrow's prompt change breaks production silently. Baselines cost 10 minutes to establish. |
| "Same model judge is fine" | Self-enhancement bias is 10-15% documented. Your "improvement" may be the judge preferring its own style. |
| "Manual red-teaming is enough" | Manual tests are not reproducible, not CI-integrated, and miss multi-turn escalation attacks. Use deepteam or promptfoo-redteam. |
| "Our evals pass so we're good" | Are your assertions checking outcomes or steps? "Agent called the right tool" ≠ "Agent produced the right result." |

---

## Tool Quick Reference

| Tool | Install | Primary Use |
|------|---------|-------------|
| promptfoo | `npx promptfoo@latest init` | YAML-driven eval, regression, red-team |
| deepeval | `pip install deepeval` | Python pytest eval, 50+ metrics |
| deepteam | `pip install deepteam` | OWASP-aligned adversarial red-teaming |
| ragas | `pip install ragas` | RAG-specific evaluation (faithfulness, relevancy) |
