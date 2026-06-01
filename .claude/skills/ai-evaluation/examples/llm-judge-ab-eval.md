---
name: llm-judge-ab-eval
description: "Tests Judge≠Optimizer self-enhancement-bias rule + sample-size rigor + determinismLevel sampling on an A/B eval setup"
pack: ai-evaluation
tests_rules:
  - "Cross-Cutting Rule: Judge ≠ Optimizer (self-enhancement bias)"
  - "Anti-Skip: n=20 confidence interval"
  - "determinismLevel sampling rule"
  - "P0/P1/P2 finding output format"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules, pack-introduced terms).
# Excludes severity tags [P0]/[P1]/[P2], generic stats (n=20, confidence interval),
# and generic nouns any senior practitioner emits. These are the markers a WITH-pack
# agent produces but a no-pack agent does NOT (proven: CONTROL scored 0 here).
discriminative_pattern: "self.?enhancement bias|Judge ≠ Optimizer|cross.?family|determinismLevel|Spearman"
min_discriminative: 3
---

# Fixture: LLM-as-Judge A/B Evaluation Review

## Input Scenario

"I'm A/B testing two prompts for our chatbot. I run each on 20 cases and use claude-sonnet to judge which output is better. Whichever wins, we ship. Review my eval setup."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-evaluation pack loaded,
the output MUST contain these markers:

1. **Self-enhancement bias / Judge≠Optimizer** [structural]: the agent flags that the judge model is the same family as the generator and quantifies the inflation, then prescribes a cross-family judge — not a generic "use a good judge"
   grep pattern: `self.?enhancement bias|10.?15%|different (model )?family|cross.?family|[Jj]udge ≠|[Jj]udge .?= Optimizer`
2. **Sample-size rigor with confidence interval**: the agent rejects n=20 with a specific statistic
   grep pattern: `n=20|±10|confidence interval|n ?≥ ?100|n=100`
3. **determinismLevel sampling**: the pack's rule that determinism class dictates run count
   grep pattern: `determinism[Ll]evel|non.?deterministic|run ≥(3|10)|report distribution`
4. **Severity-tagged findings**: P0/P1/P2 output structure with rule references
   grep pattern: `\[P0\]|\[P1\]|\[P2\]|Rule [0-9].*(benchmark|ab.?testing)`

## Verification Command

```bash
grep -oE 'self.?enhancement bias|10.?15%|different family|cross.?family|Judge ≠ Optimizer|n=20|±10|confidence interval|n ≥ 100|determinismLevel|non.?deterministic|run ≥3|run ≥10|\[P0\]|\[P1\]|\[P2\]' llm-judge-ab-eval-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "self-enhancement bias (10-15%)" (the pack's specific named+quantified failure mode for same-family judging)
- ✅ "n=20 → ±10pp confidence interval" (the pack's specific statistical counter to small samples)
- ✅ "determinismLevel → run ≥3 / ≥10x" (the pack's sampling-count rule keyed to determinism class)
- ✅ "Judge ≠ Optimizer" (the pack's named cross-cutting rule)
- ❌ "use more test cases" (generic — any agent might suggest this without the n=100 threshold)
- ❌ "compare the two prompts" (restates the input)
- ❌ "make sure it's accurate" (generic, non-discriminative)
