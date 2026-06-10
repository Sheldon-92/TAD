---
name: agent-guardrail-review
description: "Tests the Agentic Rule of Two + LLM05 tool-call AST gating + Presidio PII + OWASP-mapped findings on an over-privileged agent pipeline"
pack: ai-guardrails
tests_rules:
  - "Cross-Cutting Rule: The Agentic Rule of Two (A/B/C conditions)"
  - "OV2/OV3: structured ≠ validated + three-layer tool-call gating (sqlglot AST)"
  - "PII1/PII4: Presidio Analyzer→Anonymizer + F2 score (β=2)"
  - "DA5: OWASP LLM-risk mapping (LLM01/LLM05/LLM06)"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific named rules / pack-introduced tools+thresholds.
# Excludes generic security nouns (sanitize, validate, secure, attack), severity tags,
# and words from the input scenario. These are the markers a WITH-pack agent emits but
# a no-pack agent does NOT — the Rule-of-Two name, the A/B/C condition count, the exact
# tools (sqlglot AST / Presidio / DeanonymizeEngine), the F2 (β=2) recall rule, and the
# OWASP LLM05/LLM06 codes.
discriminative_pattern: "Rule of Two|A/B/C|sqlglot|Presidio|DeanonymizeEngine|F2 ?\\(?β ?= ?2\\)?|β ?= ?2|LLM05|LLM06|decode.?then.?validate|canary token"
min_discriminative: 4
---

# Fixture: Over-Privileged Agent Guardrail Review

## Input Scenario

"Our support agent reads the customer's incoming email (free-form), summarizes any web links they send, then writes a follow-up to our orders database and emails the customer back. To answer order questions it generates a SQL query and runs it against the orders DB. We pass the customer's full email text (names, addresses, card numbers) straight to the model. There's no filtering — the model returns JSON and we trust it. Review the security."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-guardrails pack loaded,
the output MUST contain these markers:

1. **Agentic Rule of Two** [structural]: the agent enumerates the A/B/C conditions for THIS agent (A = untrusted email/web input, B = sensitive order DB / PII, C = writes DB + sends email), concludes all three are satisfied, and prescribes dropping a leg OR a human-in-the-loop gate — not a generic "limit permissions"
   grep pattern: `Rule of Two|all three|A/B/C|untrusted input.*sensitive.*state|human.?in.?the.?loop`
2. **Tool-call AST gating** [structural]: rejects "model returns JSON, we trust it" with the structured≠validated rule and the three-layer gate, naming sqlglot AST to allow read-only SELECT
   grep pattern: `sqlglot|AST|read-only SELECT|structured ≠ validated|three-layer`
3. **Presidio PII de-identification**: requires Analyzer→Anonymizer on the raw PII before it reaches the model, with the recall-first F2 score
   grep pattern: `Presidio|AnonymizerEngine|DeanonymizeEngine|F2|β ?= ?2|recall over precision`
4. **OWASP LLM-risk mapping**: maps findings to specific OWASP LLM codes
   grep pattern: `LLM01|LLM05|LLM06|excessive agency|improper output`

At least one marker MUST be [structural] — distinguishes "applied the rule" from "mentioned the rule".

## Verification Command

```bash
grep -oE 'Rule of Two|A/B/C|all three|human.?in.?the.?loop|sqlglot|AST|read-only SELECT|structured ≠ validated|three-layer|Presidio|AnonymizerEngine|DeanonymizeEngine|F2|β ?= ?2|recall over precision|LLM01|LLM05|LLM06|excessive agency|decode.?then.?validate|canary token' ai-guardrails-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Agentic Rule of Two — A/B/C all three satisfied" (the pack's named cross-cutting rule + its exact condition triad)
- ✅ "sqlglot AST → read-only SELECT only" (the pack's specific Layer-2 tool-gating mechanism, not generic "parameterize SQL")
- ✅ "Presidio AnalyzerEngine→AnonymizerEngine / DeanonymizeEngine" (the pack's named PII tooling + round-trip operator)
- ✅ "F2 score (β=2), recall over precision" (the pack's specific PII scoring rule — an LLM defaults to F1)
- ✅ "structured ≠ validated" and "LLM05 / LLM06" (the pack's named principle + OWASP codes)
- ❌ "sanitize the input" (generic — any agent says this without the decode-then-validate or Rule-of-Two specifics)
- ❌ "validate the SQL query" (generic — without sqlglot AST / read-only-SELECT it's training-data default)
- ❌ "don't send sensitive data to the model" (restates the scenario; no Presidio/F2 mechanism)
- ❌ "add guardrails" / "make it secure" (non-discriminative)
