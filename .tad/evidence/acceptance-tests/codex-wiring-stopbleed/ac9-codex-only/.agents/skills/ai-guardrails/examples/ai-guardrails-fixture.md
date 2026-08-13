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
# a no-pack agent does NOT — the Rule-of-Two name (a.k.a. lethal trifecta), the A/B/C
# condition count, the exact tools (sqlglot AST / Presidio / DeanonymizeEngine), the
# F2 (β=2) recall rule, the OWASP LLM05/LLM06/LLM07 codes, and the pack's research-grounded
# markers (Spotlighting/datamarking, Llama Guard 4, AgentDojo/InjecAgent) — an LLM cannot
# emit these unprompted.
discriminative_pattern: "Rule of Two|lethal trifecta|A/B/C|sqlglot|Presidio|DeanonymizeEngine|F2 ?\\(?β ?= ?2\\)?|β ?= ?2|LLM05|LLM06|LLM07|system prompt leakage|decode.?then.?validate|canary token|Spotlighting|datamarking|Llama Guard 4|AgentDojo|InjecAgent"
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
4. **OWASP LLM-risk mapping**: maps findings to specific OWASP 2025 LLM codes
   grep pattern: `LLM01|LLM05|LLM06|LLM07|system prompt leakage|excessive agency|improper output`
5. **(bonus, research-grounded)** names a pack-introduced specific: lethal-trifecta synonym, Spotlighting/datamarking indirect-injection defense, the current Llama Guard 4 classifier, or an injection ASR benchmark (AgentDojo/InjecAgent)
   grep pattern: `lethal trifecta|Spotlighting|datamarking|Llama Guard 4|AgentDojo|InjecAgent`

At least one marker MUST be [structural] — distinguishes "applied the rule" from "mentioned the rule".

## Verification Command

```bash
grep -oE 'Rule of Two|lethal trifecta|A/B/C|all three|human.?in.?the.?loop|sqlglot|AST|read-only SELECT|structured ≠ validated|three-layer|Presidio|AnonymizerEngine|DeanonymizeEngine|F2|β ?= ?2|recall over precision|LLM01|LLM05|LLM06|LLM07|system prompt leakage|excessive agency|decode.?then.?validate|canary token|Spotlighting|datamarking|Llama Guard 4|AgentDojo|InjecAgent' ai-guardrails-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Deterministic Validator Assertion (A10 — wires the script into the eval)

The machine-readable form of this scenario lives in `over-privileged-agent.config.yaml`.
Run the pack's validator against it and assert findings are present (exit code 1):

```bash
# from .claude/skills/ai-guardrails/
bash scripts/check-guardrail-config.sh examples/over-privileged-agent.config.yaml
echo "exit=$?"   # Expected: exit=1 (RULE-OF-TWO + RAW-SINK + NO-PII-DEID findings)
```

This is the gold-pattern second assertion: a deterministic check (not "punt to Claude")
that the over-privileged scenario trips the lethal-trifecta / raw-SQL-sink / no-PII-de-id
rules. A clean config (e.g. one leg dropped + sqlglot AST + Presidio + human gate) returns exit 0.

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
