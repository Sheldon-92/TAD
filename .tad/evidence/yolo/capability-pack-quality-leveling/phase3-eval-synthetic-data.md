# Phase 3 Behavioral Discriminative Eval — synthetic-data

**Date**: 2026-06-13
**Pack**: synthetic-data (v0.1.0)
**Fixture**: `.claude/skills/synthetic-data/examples/synthetic-data-fixture.md`
**Eval type**: Discriminative behavioral (WITH-pack vs CONTROL, no-pack negative control)

---

## Fixture parameters

- `discriminative_pattern`:
  `LSHBloom|map_eos_token|roles_to_train|eot_tokens|ConTAM|CoDeC|SWE.?bench Pro|35 ?(pp|percentage)|Output.?First|skip_budget|ArmoRM|pre-query template|R_dedup|SemDeDup .?50%|HelpSteer2|RPO|Nemotron-4|persona-driven|PersonaHub`
- `min_discriminative`: **4**
- Gate rule: PASS iff `with-pack disc >= 4` **AND** `control disc < 4`.

## Scenario

User pipeline: prompt GPT-4 for 50k instructions from docs, raise temperature for
diversity, drop only exact-duplicate rows (MinHash), hand-pick chosen/rejected
preference pairs, format as JSON, train, then report accuracy on a public benchmark.

## Method

1. WITH-PACK answer produced by applying SKILL.md Step 0 context detection ("full
   dataset pipeline" → load all references) + Step 1 rule application + Step 2 output
   format. Pack-unique research specifics drawn from the loaded references
   (synthetic-generation, deduplication, preference-alignment, contamination-detection).
   Output: `with-pack-output.md`.
2. CONTROL answer produced as a competent generalist frontier LLM with NO pack loaded —
   correct generic ML advice (Self-Instruct, MinHash+LSH, ROUGE-L ~0.7, DPO/RRHF/GRPO,
   reward model, chat template, n-gram contamination check) but no pack-unique research
   identifiers. Output: `control-output.md`.
3. Applied `grep -oE PATTERN | sort -u | wc -l` to each.

## Results

| Output | Command | Unique markers | Count |
|--------|---------|----------------|-------|
| WITH-PACK | `grep -oE PATTERN with-pack-output.md \| sort -u \| wc -l` | 35pp, ArmoRM, CoDeC, ConTAM, eot_tokens, HelpSteer2, LSHBloom, map_eos_token, Nemotron-4, persona-driven, PersonaHub, pre-query template, R_dedup, roles_to_train, RPO, skip_budget, SWE-bench Pro | **17** |
| CONTROL | `grep -oE PATTERN control-output.md \| sort -u \| wc -l` | RPO (false-positive: substring of "GRPO", a generic term) | **1** |

### Control match analysis
The single control hit is the substring `RPO` inside "GRPO" — GRPO is generic ML
vocabulary a no-pack frontier model legitimately emits. It is NOT a deliberate
reproduction of the pack's "Reward-aware Preference Optimization (RPO)" rule. Control
emits zero of the genuine pack-unique markers (no ArmoRM, no SemDeDup config, no
ConTAM/CoDeC, no HelpSteer2 5-attr, no Nemotron-4 340B reward pipeline, no Magpie
pre-query template, no roles_to_train/map_eos_token, no LSHBloom, no SWE-bench Pro
35pp, no PersonaHub). Control stays at generic "deduplicate / use a reward model /
check for contamination" advice.

## Gate evaluation

- with-pack disc = 17  >= min_discriminative (4)  → PASS
- control disc   = 1   <  min_discriminative (4)  → PASS

**discriminative_pass = TRUE** — the pattern cleanly separates pack-loaded behavior
(17 unique research specifics) from a knowledgeable no-pack control (1 incidental
substring hit). The pack adds genuine, reproducible signal beyond a frontier model's
training-data baseline.

## Artifacts
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/yolo/capability-pack-quality-leveling/with-pack-output.md`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/yolo/capability-pack-quality-leveling/control-output.md`
