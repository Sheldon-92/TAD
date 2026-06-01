---
name: synthetic-data-finetune-pipeline-review
description: "Tests the Decontaminate-Before-You-Trust cross-cutting rule + Self-Instruct ROUGE-L 0.7 filter + exact-vs-near dedup + chat-template token mapping on a fine-tune dataset pipeline"
pack: synthetic-data
tests_rules:
  - "Cross-Cutting Rule: Decontaminate Before You Trust the Score (SWE-bench −35pp / 90% SQuADv2)"
  - "GEN1: Self-Instruct ROUGE-L > 0.7 rejection filter"
  - "DEDUP3/DEDUP5: near-duplicate pass (MinHashLSH / LSHBloom)"
  - "PA5: Axolotl roles_to_train / Unsloth map_eos_token"
  - "P0/P1/P2 finding output format"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-UNIQUE markers a no-pack frontier LLM would NOT emit from training data.
# Deliberately EXCLUDES well-known terms a competent no-pack control DOES emit (Self-Instruct, Evol-Instruct,
# MinHashLSH, ROUGE-L, GRPO, RRHF, Ask-LLM, SQuADv2, 0.7) — those are generic ML vocabulary, not pack signal.
# Negative control (zero pack loaded) MUST score < min_discriminative against this pattern.
discriminative_pattern: "LSHBloom|map_eos_token|roles_to_train|eot_tokens|ConTAM|CoDeC|SWE.?bench Pro|35 ?(pp|percentage)|Output.?First|skip_budget"
min_discriminative: 4
---

# Fixture: Fine-Tune Dataset Pipeline Review

## Input Scenario

"I'm building a fine-tune dataset. I prompt GPT-4 to generate 50k instructions from my docs, drop exact-duplicate rows, format them as JSON, and train. Then I'll report accuracy on a public benchmark. Review my dataset pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the synthetic-data pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Decontaminate before scoring** [structural]: the agent BLOCKS the "report accuracy on a public benchmark" step pending a contamination audit, citing the specific inflation numbers — not a generic "watch for overfitting"
   grep pattern: `SQuADv2|DROP|90%|SWE.?bench Pro|35 ?(pp|percentage)|13%|ConTAM|CoDeC|contamination (rate|audit)`
2. **Self-Instruct ROUGE-L 0.7 filter** [structural]: the agent flags the missing diversity filter and prescribes the specific ROUGE-L threshold + 6-human/2-machine mix
   grep pattern: `ROUGE.?L|> ?0\\.7|6 human|2 machine|Self.?Instruct|Evol.?Instruct`
3. **Near-duplicate dedup pass**: the agent rejects exact-only dedup and names the near-duplicate architecture
   grep pattern: `MinHashLSH|LSHBloom|near.?duplicate|NFC|uint32`
4. **Chat-template / token mapping**: the agent flags raw JSON training without template alignment
   grep pattern: `map_eos_token|roles_to_train|train_on_eos|chat template|ShareGPT|pad token`
5. **Severity-tagged findings**: P0/P1/P2 output structure with rule references
   grep pattern: `\[P0\]|\[P1\]|\[P2\]|Rule (GEN|DEDUP|PA|CON|QF)[0-9]`

## Verification Command

```bash
# Discriminative gate: ONLY pack-unique markers. A no-pack negative control MUST score < 4.
grep -oE 'LSHBloom|map_eos_token|roles_to_train|eot_tokens|ConTAM|CoDeC|SWE.?bench Pro|35 ?(pp|percentage)|Output.?First|skip_budget' synthetic-data-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4 (WITH pack); a competent no-pack control scores < 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "ROUGE-L > 0.7 rejection" (the pack's specific Self-Instruct redundancy threshold — not "remove duplicates")
- ✅ "MinHashLSH / LSHBloom near-duplicate pass" (the pack's named dedup architectures + the 270%/54× scaling numbers)
- ✅ "SWE-bench Verified 80.9% → Pro 45.9% (−35pp), 90% of SQuADv2/DROP contaminated" (the pack's quantified contamination inflation — not "watch for data leakage")
- ✅ "Axolotl roles_to_train / Unsloth map_eos_token" (the pack's named token-mapping config that prevents training on pad tokens)
- ✅ "ConTAM mincount 1 / skip_budget 0, CoDeC in-context diagnostic" (the pack's named contamination detectors)
- ❌ "deduplicate your data" (generic — any agent says this without MinHashLSH / NFC / uint32)
- ❌ "use a good benchmark" (generic — lacks the SWE-bench Pro / 35pp specifics)
- ❌ "format the data correctly" (restates the input; lacks roles_to_train / map_eos_token)

**Excluded from the DISCRIMINATIVE gate** (well-known terms a competent no-pack frontier LLM emits from
training data — present in Expected Markers above, but NOT counted by the discriminative gate, else the gate
fails to separate WITH-pack from a knowledgeable no-pack control): `Self-Instruct`, `Evol-Instruct`,
`MinHashLSH`, `ROUGE-L`, `0.7`, `GRPO`, `RRHF`, `Ask-LLM`, `SQuADv2`. The gate counts ONLY the pack-unique
markers (`LSHBloom`, `map_eos_token`, `roles_to_train`, `eot_tokens`, `ConTAM`, `CoDeC`, `SWE-bench Pro`,
`35pp/percentage`, `Output-First`, `skip_budget`) — a no-pack negative control scores < 4 on these.
- ❌ "generate diverse instructions" (generic — lacks the ROUGE-L 0.7 + 6:2 mix)
