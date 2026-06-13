# Phase 4 Behavioral Discriminative Eval — ai-guardrails

**Date**: 2026-06-13
**Pack**: ai-guardrails (v0.1.0)
**Fixture**: `.claude/skills/ai-guardrails/examples/ai-guardrails-fixture.md`
**Scenario**: Over-privileged support agent (free-form email → web-link summarize → orders-DB write + model-generated SQL → email reply, raw PII to model, JSON trusted).

## Gate Parameters

- `discriminative_pattern`: `Rule of Two|lethal trifecta|A/B/C|sqlglot|Presidio|DeanonymizeEngine|F2 ?\(?β ?= ?2\)?|β ?= ?2|LLM05|LLM06|LLM07|system prompt leakage|decode.?then.?validate|canary token|Spotlighting|datamarking|Llama Guard 4|AgentDojo|InjecAgent`
- `min_discriminative`: 4
- `min_marker_count`: 4
- Method: `grep -oE PATTERN | sort -u | wc -l` on each answer.

## Results

| Answer | Distinct discriminative markers | Threshold |
|--------|---------------------------------|-----------|
| WITH-PACK (SKILL.md rules applied) | **16** | ≥ 4 |
| CONTROL (generalist, no pack) | **0** | must be < 4 |

### WITH-PACK markers hit (16 distinct)
A/B/C, AgentDojo, datamarking, DeanonymizeEngine, F2 (β=2), InjecAgent, lethal trifecta, Llama Guard 4, LLM05, LLM06, LLM07, Presidio, Rule of Two, Spotlighting, sqlglot, system prompt leakage

### CONTROL markers hit (0)
The generalist answer covered the same risks ("sanitize input", "don't send sensitive data to the model", "validate the SQL query", "don't blindly trust JSON", "least privilege", "add guardrails") but emitted ZERO pack-specific named rules, tools, codes, or thresholds — exactly the non-discriminative phrasing the fixture's Anti-Slop ❌ list predicts.

## Structural-marker check
At least one [structural] marker present: the WITH-PACK answer enumerates the A/B/C condition triad for THIS agent (A = untrusted email/web link, B = orders DB + PII, C = DB write + email send), concludes all three satisfied, and prescribes dropping a leg OR a human-in-the-loop gate — "applied the rule", not merely "mentioned" it.

## Deterministic validator (A10 assertion)
```
$ bash scripts/check-guardrail-config.sh examples/over-privileged-agent.config.yaml
[FINDING RULE-OF-TWO | LLM06] ... lethal trifecta. Drop one leg or add a human approval gate.
[FINDING RAW-SINK | LLM05] ... model-driven SQL sink with NO sqlglot/AST gate.
[FINDING NO-PII-DEID | LLM02] ... raw PII to external LLM with NO Presidio Analyzer->Anonymizer.
exit=1   # expected exit=1 ✓
```

## Verdict

**discriminative_pass = TRUE**

WITH-PACK (16) ≥ min_discriminative (4) AND CONTROL (0) < min_discriminative (4). The gate cleanly separates pack-driven judgment from generalist output, and the deterministic validator independently trips the same three findings (exit 1).
