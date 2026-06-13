# Phase 3 Adversarial Review — synthetic-data — fact-api lens

**Lens**: fact-api (factual / API errors: wrong class names, deprecated/renamed APIs, wrong metric types, wrong constants/versions)
**Reviewer**: Claude Opus 4.8 (subagent), 2026-06-13
**Verdict (meets_bar)**: true (with one P1 factual fix recommended)

This lens replaces cross-model review. Every version-sensitive claim was checked against CURRENT primary documentation via WebSearch. NEVER-blind-trust applied: I independently verified, did not trust prior reviewers.

---

## Verdict

**meets_bar = true.** The pack is unusually disciplined about factual grounding: nearly every numeric claim carries a source URL + retrieval date, single-source figures are explicitly hedged ("single-source figure, not a universal rate"), and the SWE-bench gap is correctly de-conflated (contamination vs suite-difficulty vs harness). API names, model ids, config keys, and metric types are accurate against current docs. One genuine factual error found (CON4 `n < 8` should be `n = 8`), classified P1 — it does not collapse the pack's value but should be corrected.

---

## Findings

### F1 [P1 — factual error] CON4 / contamination Quick Rule Index: `n < 8` contradicts the ConTAM paper's `n = 8`
- `contamination-detection-rules.md` CON4 states: "`n < 8` — for NGRAM-MATCH and LONGEST-MATCH, n-gram length below 8" and the Quick Rule Index row CON4 says "n < 8".
- The ConTAM paper ("Evaluation data contamination in LLMs", arXiv:2411.03923) reports the optimal hyperparameters as **n = 8, mincount = 1, skip_budget = 0** — n is set TO 8, not below 8.
- Fix: change CON4 and its index row to `n = 8` (or "n-gram length 8"). The `mincount: 1` / `skip_budget: 0` parts are correct.
- Severity P1 not P0: the surrounding config (mincount 1, skip_budget 0) is right and the rule's intent (don't understate contamination) survives, but the specific constant is wrong on a version-sensitive claim.

### F2 [observation, not a defect] LSHBloom dual framing is internally consistent
- DEDUP5 says "≈270% faster (≈3.7× throughput) on peS2o, using 18× less disk; 54× at billions, ≈250% speedup". The paper's abstract states BOTH "270% faster on peS2o", "12× faster" (throughput), "18× less disk", and "54× space advantage / 250% speedup at billions". The pack's 270%/18×/54×/250% all match the paper's own numbers. The "3.7×" gloss = 270% faster framing, internally consistent. No error.

### F3 [strength] Milvus MINHASH_LSH API claim is precise and current
- DEDUP4 claims `BINARY_VECTOR` field + `MINHASH_LSH` index + `MHJACCARD` metric + `mh_element_bit_width` param, and "no native uint32-vector type". All confirmed against Milvus 2.6 docs (MinHash LSH natively integrated in 2.6; signatures stored as BINARY_VECTOR; MHJACCARD is the dedicated metric; mh_element_bit_width is a real index param). The float32-exact-to-16,777,216 constant = 2^24, mathematically correct.

### F4 [strength] Model ids and config keys all real and correctly named
- `RLHFlow/ArmoRM-Llama3-8B-v0.1` (GEN7) — exact HF id, confirmed as Magpie's filter reward model.
- `Nemotron-4-340B-Reward` + 5 HelpSteer attributes (Helpfulness/Correctness/Coherence/Complexity/Verbosity, Likert 0–4) + RPO + >98% synthetic (PA7) — all confirmed against the NVIDIA blog + Technical Report (arXiv:2406.11704).
- Axolotl `roles_to_train` / `train_on_eos` / `eot_tokens` (PA5) — all real config keys (eot_tokens explicitly documented for Mistral V7 Tekken, matching the pack's exact example).
- Unsloth `standardize_sharegpt` / `map_eos_token` (PA5) — both real; map_eos_token maps `<|im_end|>`→EOS inside get_chat_template(), consistent with the pack's "prevent training on pad tokens" framing.

### F5 [strength] GRPO / RRHF / DPO characterizations are accurate
- PA1: GRPO described as critic-free, group-relative, for verifiable math/logic — matches DeepSeek's GRPO (Shao et al. 2024). RRHF length-normalized log-prob + ranking loss (PA2) is correctly described. DPO loss formula and pairwise limitation correct.

### F6 [strength] Self-Instruct constants exact
- 175 seeds (25 cls / 150 non-cls), 6 human + 2 machine sampling, ROUGE-L < 0.7 reject (GEN1/GEN2) — all confirmed against the Self-Instruct paper (arXiv:2212.10560).

### F7 [strength] SWE-bench / SemDeDup numbers verified and correctly hedged
- Opus 4.5 = 80.9% SWE-bench Verified, 45.9% SWE-bench Pro (Scale SEAL) — both exact (April 2026 leaderboards). The pack correctly warns the Verified→Pro gap is NOT pure contamination (conflates difficulty + harness) — a rare, correct nuance.
- SemDeDup ~50% LAION removal / halves training / OPT-125M last-layer last-token embedding (DEDUP7/DEDUP8) — confirmed against arXiv:2303.09540 + D4 (arXiv:2308.12284).

### F8 [strength] Magpie pipeline accurate
- 4M instructions from Llama-3-Instruct → 300K SFT (Magpie-Pro/Air), pre-query-template self-synthesis, ArmoRM filter — all confirmed against Magpie (arXiv:2406.08464, ICLR 2025).

### F9 [verified] validate-curation-config.sh runs correctly
- `bash -n` clean; run against a deliberately-bad config produced 4 P0s and exit 1 as designed. The 16,777,216 constant and BINARY_VECTOR fix message match DEDUP4.

---

## Fact-checks (every version-sensitive claim, against current primary docs)

1. Milvus MINHASH_LSH / BINARY_VECTOR / MHJACCARD / mh_element_bit_width — CONFIRMED (Milvus 2.6 docs). Native in 2.6, BINARY_VECTOR storage, MHJACCARD metric, mh_element_bit_width real param. float32 exact to 2^24=16,777,216 correct.
2. RLHFlow/ArmoRM-Llama3-8B-v0.1 — CONFIRMED (HF model id exact; is Magpie's reward filter).
3. Nemotron-4-340B-Reward, 5 HelpSteer attrs (Helpfulness/Correctness/Coherence/Complexity/Verbosity), Likert 0–4, RPO, >98% synthetic — CONFIRMED (NVIDIA blog + arXiv:2406.11704). [Nuance: paper says "HelpSteer" attributes; pack says "HelpSteer2 attributes" — HelpSteer2 is the dataset Nemotron-4-340B-Reward was trained on, so "HelpSteer2 5 attributes" is acceptable shorthand, not an error.]
4. Axolotl roles_to_train / train_on_eos / eot_tokens (Mistral V7 Tekken) — CONFIRMED (Axolotl docs + PR #2364).
5. Unsloth standardize_sharegpt / map_eos_token — CONFIRMED (Unsloth docs; map_eos_token boolean in get_chat_template).
6. Magpie 4M→300K from Llama-3-Instruct, pre-query template, ArmoRM filter — CONFIRMED (arXiv:2406.08464).
7. SWE-bench: Opus 4.5 80.9% Verified / 45.9% Pro (Scale SEAL) — CONFIRMED (2026 leaderboards). Pack's "not pure contamination" hedge is correct.
8. SemDeDup ~50% LAION removal, halves training, OPT-125M last-layer last-token — CONFIRMED (arXiv:2303.09540 + D4 2308.12284).
9. LSHBloom peS2o 39M, 270% faster / 18× less disk / 54× at billions / 250% speedup — CONFIRMED (arXiv:2411.04257; paper reports these exact figures).
10. Self-Instruct 175 seeds (25/150), 6 human + 2 machine, ROUGE-L < 0.7 — CONFIRMED (arXiv:2212.10560).
11. ConTAM 4 metrics (TOKEN-MATCH/NGRAM-MATCH/TOKEN-EXTEND/LONGEST-MATCH), mincount=1, skip_budget=0 — CONFIRMED, BUT paper says optimal **n = 8**, pack says **n < 8** → FACTUAL ERROR (F1, P1).
12. GRPO critic-free group-relative verifiable rewards (DeepSeek, Shao 2024) — CONFIRMED.
13. float32 max exact integer = 16,777,216 (2^24) — CONFIRMED (math fact).
