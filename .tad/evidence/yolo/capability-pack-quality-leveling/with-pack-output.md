# Dataset Curation Review: Fine-Tune Dataset Pipeline (WITH synthetic-data pack)

## P0 — Blocking (must fix before training / shipping)

[P0] Cross-Cutting Rule — Decontaminate Before You Trust the Score: You plan to "report accuracy on a public benchmark" with NO contamination audit. This step is BLOCKED until you run decontamination. Static public benchmarks leak into training/synthetic corpora at high rates — one study flagged up to ~90% of SQuADv2/DROP as contaminated; GSM1k dropped accuracy ~13% on uncontaminated math; Claude Opus 4.5 dropped 35pp (80.9% on SWE-bench Verified → 45.9% on the contamination-resistant SWE-bench Pro).
→ Run ConTAM token-overlap detection (mincount 1, skip_budget 0, n < 8) against your eval set; when the training corpus is unavailable, fall back to the CoDeC in-context behavioral diagnostic. Do not report any number until decontamination precedes the score step. Prefer a dynamic / contamination-resistant suite (SWE-bench Pro-style), and report the exact evaluator/harness/date.

[P0] Rule DEDUP3/DEDUP7 (deduplication): You drop only exact-duplicate rows (MinHash dedup as exact-only). Exact + lexical MinHashLSH still lets lexically-distinct paraphrases survive and inflate memorization.
→ Add a SemDeDup semantic pass after MinHash (embed → k-means cluster → drop near-centroid dups). SemDeDup removes ~50% of web data with minimal performance loss (~2× train speed). At trillion scale migrate MinHashLSH → LSHBloom (≈270% faster, 18–54× less disk). For a full efficiency+quality run, use the D4 chain: MinHash → SemDeDup R_dedup=0.75 → recluster → SSL-prototypes diversify, with an OPT-125M last-token embedder.

[P0] Rule PA5 (preference-alignment): You "format the result as JSON and train" with no chat-template alignment — you will train on pad tokens and the wrong roles.
→ Set Axolotl roles_to_train=["assistant"], train_on_eos=last, eot_tokens (Tekken); Unsloth map_eos_token / standardize_sharegpt. Without map_eos_token you train on pad tokens; without roles_to_train you train gradients on user turns.

## P1 — Required (fix before trusting the dataset)

[P1] Rule GEN1 (synthetic-generation): Your Self-Instruct-style loop has no ROUGE-L overlap filter, so the 50k instructions collapse into near-duplicates.
→ Reject any generated instruction whose ROUGE-L with an existing pool instruction exceeds 0.7, plus blacklist (image/graph/file) and start-character checks, and use the 6-human / 2-machine sampling mix.

[P1] Rule GEN8 (synthetic-generation): "Turn up the temperature for diversity" is the WRONG fix — raising temperature degrades quality without fixing topical collapse.
→ Use persona-driven synthesis: condition generation on a persona set — PersonaHub (~1B personas, web-scale breadth) or Census-grounded NVIDIA Nemotron-Personas (100K, distribution alignment) — instead of raising temperature.

[P1] Rule GEN7 (synthetic-generation): You hand-prompt GPT-4 with seeds when a cheaper self-synthesis path exists.
→ When you have an aligned model, use the Magpie pre-query template trick (prefill only the left-side chat template up to the user slot, let the model self-synthesize the instruction), then filter with the RLHFlow/ArmoRM-Llama3-8B-v0.1 reward score + quality/difficulty labels + FAISS min-neighbor-distance dedup.

[P1] Rule PA7 (preference-alignment): You hand-pick chosen/rejected pairs — labels drift and humans can't scale.
→ Use reward-model-as-judge: rank candidates with a multi-attribute RM scoring 5 HelpSteer2 attributes (Helpfulness/Correctness/Coherence/Complexity/Verbosity, Likert 0–4), form triplets, train via RPO (Reward-aware Preference Optimization) in a weak-to-strong loop the way Nemotron-4 340B aligned on >98% synthetic data with ~1% human.

## P2 — Advisory

[P2] Rule PA1: If you have >2 candidates, DPO is structurally pairwise — use RRHF ranking loss; for verifiable math/logic use GRPO.

### Pipeline Stage Audit
| Stage | Status |
|-------|--------|
| filter | MISSING quality gate |
| dedup | exact-only — add SemDeDup / LSHBloom (P0) |
| generate | no ROUGE-L 0.7, wrong temperature fix — Magpie/persona (P1) |
| align | no roles_to_train / map_eos_token (P0) |
| decontaminate | MISSING — ConTAM/CoDeC before score (P0) |
