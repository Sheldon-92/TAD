# Phase 4 Behavioral Discriminative Eval — ai-evaluation

**Date**: 2026-06-13
**Pack**: ai-evaluation (v0.1.0, upgraded capability pack)
**Fixture**: `.claude/skills/ai-evaluation/examples/llm-judge-ab-eval.md`

## Fixture Parameters

- **discriminative_pattern**: `self.?enhancement bias|Judge ≠ Optimizer|cross.?family|determinismLevel|dual.?pass|win in both|position sensitivity|McNemar|Spearman 0\.5|0\.514`
- **min_discriminative**: 3
- **Method**: `grep -oE PATTERN | sort -u | wc -l` on both WITH-PACK and CONTROL answers.

## Scenario (from fixture)

> "I'm A/B testing two prompts for our chatbot. I run each on 20 cases and use
> claude-sonnet to judge which output is better — and I also use claude-sonnet to
> generate. Whichever prompt has more wins, we ship. Review my eval setup."

## WITH-PACK Answer (SKILL.md rules applied)

```
## Evaluation Review: A/B prompt comparison eval setup

### P0 — Blocking (must fix before running eval)
- [P0] Cross-Cutting Rule violation — Judge ≠ Optimizer: you use claude-sonnet to BOTH
  generate and judge. This triggers self-enhancement bias, one of the three documented
  judge failure modes in the MT-Bench paper (position, verbosity, self-enhancement).
  Your "winner" may simply be the judge preferring its own family's style. Fix: switch
  the judge to a different model family (cross-family judge, e.g. gpt-4o or gemini); if
  forced to reuse the family, label results "internally consistent only — needs
  cross-family validation."
- [P0] Rule AB2 (ab-testing): "more wins → ship" is raw win-count, not significance.
  With n=20 you cannot distinguish a 70% from an 80% system (±10pp confidence interval).
  Fix: raise to n≥100 and run a paired McNemar test (continuity-corrected) on discordant
  pairs + bootstrap 95% CI + effect size.

### P1 — Required (fix before trusting results)
- [P1] Rule AB8 (ab-testing): position SENSITIVITY is unhandled. A single-pass judge
  bakes in order bias. Fix: run dual-pass with swapped A/B order and declare a winner
  only if it wins in both passes; otherwise score a tie. Track reversal rate.
- [P1] Rule HE6 (human-eval): your judge is uncalibrated. Fix: correlate the judge
  against a ≥50-item human-labeled set and report Spearman; treat ~0.5 as the realistic
  SOTA ceiling for open NLG (G-Eval reaches Spearman 0.514 on summarization). Do not
  assume 0.9+ agreement.

### determinismLevel Audit
- LLM-judge verdict: non-deterministic → run ≥10x / use dual-pass to bound variance.
- McNemar test on fixed pairs: deterministic → 1 run.

### Tool Recommendation
promptfoo (YAML-driven A/B + paired stats + repeat sampling).
```

## CONTROL Answer (generalist, NO pack)

```
## Review of your A/B eval setup

1. Sample size: 20 cases is pretty small. I'd recommend using more test cases so your
   results are more reliable and statistically meaningful.
2. Using the same model to generate and judge: it's generally better to be careful here,
   since a model might be biased toward its own outputs. Consider a human review or a
   separate evaluator.
3. Just counting wins might be misleading. Make sure the difference is meaningful and
   not just noise.
4. Watch out for ordering effects — the position of A vs B could influence the judge, so
   consider randomizing the order.
5. Make sure your judging criteria are clear and accurate, and spot-check the judge.
6. Document your methodology so the eval is reproducible.
```

## Discriminative Measurement

Command: `grep -oE PATTERN <file> | sort -u | wc -l`

### WITH-PACK matches (7 unique)
```
cross-family
determinismLevel
dual-pass
Judge ≠ Optimizer
McNemar
self-enhancement bias
Spearman 0.5
```
**WITH-PACK disc count = 7**

### CONTROL matches (0 unique)
The generalist answer gestures at the same concerns ("use more test cases", "biased
toward its own outputs", "ordering effects", "spot-check the judge") but never emits a
single pack-specific marker: no named rule (Judge ≠ Optimizer), no failure-mode term
(self-enhancement bias), no statistical test name (McNemar), no procedure (dual-pass),
no research-grounded number (Spearman 0.5 / 0.514), no pack term (determinismLevel,
cross-family).
**CONTROL disc count = 0**

## Verdict

| Metric | Value | Threshold |
|--------|-------|-----------|
| WITH-PACK discriminative | 7 | ≥ 3 ✅ |
| CONTROL discriminative | 0 | < 3 ✅ |

**discriminative_pass = TRUE** — WITH-PACK (7) ≥ min_discriminative (3) AND CONTROL (0) < min_discriminative (3).

The pack produces named-rule + research-grounded markers (Judge ≠ Optimizer,
self-enhancement bias, McNemar, dual-pass, Spearman 0.514, determinismLevel, cross-family)
that a no-pack generalist does not, even when the generalist correctly senses the
underlying problems. The discriminative gate is met with margin.
