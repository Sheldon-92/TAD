---
name: llm-judge-ab-eval
description: "Tests Judge≠Optimizer self-enhancement-bias rule + sample-size rigor + determinismLevel sampling on an A/B eval setup"
pack: ai-evaluation
tests_rules:
  - "Cross-Cutting Rule: Judge ≠ Optimizer (self-enhancement bias, MT-Bench >80% human-agreement ceiling)"
  - "Anti-Skip: n=20 confidence interval"
  - "determinismLevel sampling rule"
  - "AB2: paired McNemar significance test, not raw win-count"
  - "AB8: position SENSITIVITY → dual-pass swapped-order, win-in-both"
  - "HE6: judge calibration-validity (Spearman ~0.5 SOTA ceiling for open NLG)"
  - "P0/P1/P2 finding output format"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules, pack-introduced terms,
# research-grounded numbers an LLM cannot restate without the source).
# Excludes severity tags [P0]/[P1]/[P2], generic stats (n=20, confidence interval),
# and generic nouns any senior practitioner emits. These are the markers a WITH-pack
# agent produces but a no-pack agent does NOT (proven: CONTROL scored 0 here).
# Refreshed 2026-06-13 to align with the Layer B depth additions (dual-pass position
# sensitivity, McNemar significance, MT-Bench/G-Eval correlation ceilings).
discriminative_pattern: "self.?enhancement bias|Judge ≠ Optimizer|cross.?family|determinismLevel|dual.?pass|win in both|position sensitivity|McNemar|Spearman 0\\.5|0\\.514"
min_discriminative: 3
---

# Fixture: LLM-as-Judge A/B Evaluation Review

## Input Scenario

"I'm A/B testing two prompts for our chatbot. I run each on 20 cases and use claude-sonnet to judge which output is better — and I also use claude-sonnet to generate. Whichever prompt has more wins, we ship. Review my eval setup."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-evaluation pack loaded,
the output MUST contain these markers:

1. **Self-enhancement bias / Judge≠Optimizer** [structural]: the agent flags that the judge is the same family as the generator, names self-enhancement bias as one of MT-Bench's three judge failure modes, and prescribes a cross-family judge — not a generic "use a good judge"
   grep pattern: `self.?enhancement bias|MT.?Bench|different (model )?family|cross.?family|[Jj]udge ≠|[Jj]udge .?= Optimizer`
2. **Sample-size rigor with confidence interval**: the agent rejects n=20 with a specific statistic
   grep pattern: `n=20|±10|confidence interval|n ?≥ ?100|n=100|n=550`
3. **Statistical significance, not raw win-count (AB2)**: the agent demands a paired significance test instead of "more wins → ship"
   grep pattern: `McNemar|paired .*test|bootstrap|effect size|win.?count`
4. **Position SENSITIVITY / dual-pass (AB8)**: the agent prescribes running the judge with swapped A/B order and requiring a win in both passes
   grep pattern: `dual.?pass|win in both|position sensitivity|swap.*order|reversal rate`
5. **Judge calibration-validity (HE6)**: the agent requires correlating the judge against a human-labeled set and cites the ~0.5 SOTA ceiling
   grep pattern: `Spearman|0\.5(0|14)?|calibration.?valid|human.?labeled|correlation`
6. **Severity-tagged findings**: P0/P1/P2 output structure with rule references
   grep pattern: `\[P0\]|\[P1\]|\[P2\]|Rule [0-9].*(benchmark|ab.?testing)`

## Verification Command

```bash
grep -oE 'self.?enhancement bias|MT.?Bench|cross.?family|Judge ≠ Optimizer|n=20|±10|confidence interval|n ≥ 100|McNemar|bootstrap|effect size|dual.?pass|win in both|position sensitivity|Spearman|0\.514|determinismLevel|\[P0\]|\[P1\]|\[P2\]' llm-judge-ab-eval-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3 (combined / SECONDARY context count — NOT the discriminative gate)
```

## Anti-Slop Check

These markers are pack-specific + research-grounded (would NOT appear without the pack):
- ✅ "self-enhancement bias — one of MT-Bench's three judge failure modes" (named+sourced, not a generic caution)
- ✅ "n=20 → ±20pp Wilson CI (±10pp is the n=100 figure); need n≥100 AND a paired McNemar test + bootstrap CI + effect size" (significance, not win-count)
- ✅ "dual-pass: swap A/B order, declare a winner only if it wins in BOTH; else tie" (position SENSITIVITY procedure)
- ✅ "correlate the judge vs a ≥50-item human set; ~0.5 (G-Eval 0.514) is the SOTA ceiling for open NLG" (HE6)
- ✅ "Judge ≠ Optimizer" (the pack's named cross-cutting rule)
- ❌ "use more test cases" (generic — any agent might suggest this without the n=100 threshold)
- ❌ "beware position bias" (obsolete generic framing — AB8 replaces it with the dual-pass procedure)
- ❌ "make sure it's accurate" (generic, non-discriminative)
