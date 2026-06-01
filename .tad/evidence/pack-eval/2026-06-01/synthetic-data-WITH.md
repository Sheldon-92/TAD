## Dataset Curation Review: GPT-4 → 50k instructions → exact-dedup → JSON → train → benchmark

Your pipeline has four stages — **generate → dedup → format → eval** — and every stage is missing the mandatory control for its phase. The single most expensive failure is at the end: you plan to report accuracy on a public benchmark with **zero contamination detection**, so I'm leading with that.

---

### Cross-Cutting Violation (read this first): Decontaminate Before You Trust the Score

> **You cannot report ANY benchmark number for this model until you run contamination detection against the eval set.** This is the most expensive silent failure in the whole pipeline.

Your docs were used to prompt GPT-4, and GPT-4's training corpus very likely overlaps the public benchmark you intend to score on. Contamination is **a spectrum, not binary** (Rule CON1) — up to **90% of examples in datasets like SQuADv2 and DROP are flagged as contaminated**. The quantified impact (Rule CON2): GSM1k showed accuracy drops of **up to 13%** on uncontaminated math; Claude Opus 4.5 dropped **35 percentage points (80.9% → 45.9%)** moving from SWE-bench Verified to the contamination-resistant SWE-bench Pro. A clean-looking number on a contaminated benchmark measures **memorization, not generalization**.

---

### P0 — Blocking (must fix before training / before reporting any number)

**[P0] Rule CON1 + CON3/CON4 (contamination-detection): No contamination audit before benchmark reporting.**
→ Before you report accuracy, run a post-hoc overlap audit of your 50k set (and GPT-4's likely exposure) against the benchmark using **ConTAM** token-level metrics. Use **`LONGEST-MATCH`** to suppress false positives from incidental short overlaps and **`NGRAM-MATCH`** for sequence-level leakage (Rule CON3 — a single token-overlap metric is fragile). Configure ConTAM at the empirically optimal **`mincount: 1`, `skip_budget: 0`, `n < 8`** (Rule CON4 — raising either understates contamination). Report a contamination **rate** alongside the score, not a clean/dirty verdict.

**[P0] Rule CON2 + CON6 (contamination-detection): Reporting a single static-benchmark number.**
→ Report what the number **drops to** on a contamination-resistant / dynamic variant of the benchmark, not just the headline. The durable fix is a **dynamic, refreshed eval set plus a contamination-resistant variant** (Rule CON6) — don't chase a perfect static detector. Add **CoDeC** (Rule CON5) as a behavioral cross-check: feed few-shot context from the benchmark; if added context **fails to lift (or lowers) confidence**, treat that benchmark as contaminated.

**[P0] Rule DEDUP3 (deduplication): Exact-duplicate-row drop is an incomplete dedup pass — no near-duplicate stage.**
→ "Drop exact-duplicate rows" is only DEDUP1 (the cheapest first pass). Exact match cannot catch instructions that differ from **copyediting, reformatting, or versioning** — and GPT-4 generating 50k instructions from a small doc set will produce exactly those near-duplicates. Add a **MinHashLSH** near-duplicate pass: MinHash signatures (probability of signature match = Jaccard similarity), LSH bucketing into `b` bands of `r` rows so full Jaccard is computed only on candidate pairs (avoids `O(N²)`). Exact-only dedup is a **P0 gap**, not advisory — redundancy directly **accelerates memorization** (Rule DEDUP6).

**[P0] Rule GEN1 (synthetic-generation): No ROUGE-L > 0.7 rejection on the 50k generated instructions.**
→ A single-model generation loop with no overlap filter **collapses into near-duplicate instructions** — this is the dominant failure mode for "prompt GPT-4 to make 50k instructions." Reject any generated instruction whose **ROUGE-L overlap with an existing pool instruction exceeds 0.7**. Also apply the Self-Instruct heuristic filters: blacklist keywords for things the model can't do (*image*, *graph*, *file*), and reject instructions starting with punctuation or non-target-language characters. This filter is **mandatory, not optional**.

---

### P1 — Required (fix before trusting the dataset)

**[P1] Rule DEDUP2 (deduplication): No NFC normalization before dedup hashing.**
→ Apply **NFC (Canonical Composition) normalization before** you compute the exact-match hash. Visually identical text encoded as NFC vs NFD hashes differently, so encoding-only duplicates survive an un-normalized exact pass. NFC-before-hash yields an **8%–18% additional document removal** depending on language. Also use **SHA-256** for the exact pass (Rule DEDUP1 — zero false positives, ~2–3 GB RAM for tens of millions of docs).

**[P1] Rule GEN2 (synthetic-generation): Single-prompt generation has no human/machine seed mix.**
→ You're prompting GPT-4 with (presumably) your docs alone. Self-Instruct's documented sampling mix is **8 instructions per few-shot prompt = 6 human-written + 2 previously machine-generated**: the 2 machine tasks promote diversity, the 6 human tasks anchor quality. Machine-only seeding causes diversity drift; human-only gives no novelty. Seed from a balanced human pool, not just raw doc dumps.

**[P1] Rule GEN4 (synthetic-generation): Flat single-pass generation — no Evol-Instruct evolution or Elimination.**
→ Flat Self-Instruct-style generation produces simple, low-difficulty instructions and **leaves measured performance on the table**. Add **Evol-Instruct (WizardLM)**: In-Depth Evolution (5 mutations — add constraints, deepen, concretize, complicate input, augment logical steps), In-Breadth Evolution (new diverse instructions), and critically the **Elimination Evolving** step (an eliminator model filters corrupted/unsolvable evolutions). Evolution **without** Elimination ships broken tasks. (Applying this to Alpaca seeds produced the 250k WizardLM set that significantly outperforms standard Self-Instruct data.)

**[P1] Rule PA4 + PA3 (preference-alignment): "Format as JSON" is underspecified — chat template is unmapped.**
→ "JSON" is not a fine-tune format. Pick by turn count (Rule PA3): **Alpaca** (`instruction`/`input`/`output`) for single-turn, **ShareGPT** (`conversations` array of `{from, value}`) for multi-turn. Then map the model's **exact Jinja2 chat template** (Rule PA4) — hand-formatting role markers or mis-mapping `<|start_header_id|>` / `<|eot_id|>` / `bos_token` silently corrupts role boundaries and causes speaker-turn confusion across both training and inference.

**[P1] Rule PA5 (preference-alignment): No `roles_to_train` / `train_on_eos` / `map_eos_token` config — you risk training on user turns and pad tokens.**
→ In **Axolotl** set `roles_to_train: ["assistant"]` (isolates gradients to assistant tokens — otherwise you train on the user's turns too), `train_on_eos: last` (prevents premature generation cutoff), and `eot_tokens` if end-of-turn ≠ end-of-sequence. In **Unsloth** use `standardize_sharegpt` + `map_eos_token` (maps EOS so you **don't train on pad tokens**). These are load-bearing, not defaults to ignore.

---

### P2 — Advisory (improves dataset quality)

**[P2] Rule QF5 (quality-filtering): No label-noise screening on generated (instruction, output) pairs.**
→ GPT-4 outputs are not automatically clean labels. Before SFT, screen pairs with the **Complexity Gap (CG) score**: `CG(x,y) = C(x,ỹ) − C(x,y)` (C = Kolmogorov-complexity estimate, ỹ = permuted label). High CG → label likely correct; low/negative CG → probable label noise. This needs no model training.

**[P2] Rule QF1 (quality-filtering): No heuristic gate before training.**
→ Run a cheap statistical gate first: length (discard < 5 or > 2000 tokens), symbol/char-ratio, **fastText** langID, Shannon entropy (flag extreme low = boilerplate / high = garbled), and n-gram diversity (low = repetitive template text). Near-free, removes the worst rows before any model-based step.

**[P2] Rule QF4 (quality-filtering): Quality scoring without coverage sampling collapses diversity.**
→ If you add an LLM quality score (e.g. Ask-LLM, which captures a different signal than perplexity — Rule QF3), pair it with **latent density sampling** (Inverse Propensity Sampling, selection prob ∝ 1/Density(x)) so you don't over-sample the dense, redundant regions a small-doc-derived 50k set will inevitably have.

---

### Pipeline Stage Audit

| Stage | Your pipeline | Status | Required control |
|-------|---------------|--------|------------------|
| **Filter (quality)** | none | ❌ MISSING | QF1 heuristic gate; QF5 CG label-noise screen on generated pairs |
| **Generate** | prompt GPT-4 for 50k | ❌ NO DIVERSITY CONTROL | GEN1 ROUGE-L > 0.7 reject; GEN2 6:2 seed mix; GEN4 Evol-Instruct + Elimination |
| **Dedup** | drop exact-duplicate rows | ⚠️ INCOMPLETE (exact only) | DEDUP2 NFC-before-hash; **DEDUP3 MinHashLSH near-dup pass (P0)** |
| **Align (format)** | "format as JSON" | ❌ UNMAPPED | PA3 Alpaca vs ShareGPT; PA4 exact Jinja2 template; PA5 roles_to_train / map_eos_token |
| **Decontaminate** | none | ❌ MISSING (P0) | CON3/CON4 ConTAM LONGEST-MATCH + NGRAM-MATCH @ mincount 1 / skip 0 / n<8; CON5 CoDeC; CON2/CON6 report resistant-variant drop |

**Net:** 0 of 5 stages is correctly controlled. The benchmark number you plan to report is uninterpretable until decontamination runs.

---

### Tool Recommendation

- **distilabel** (`pip install distilabel`) — replace your single GPT-4 prompt with a DAG: `load → self_instruct → expand_columns → parallel generate → combine → ultrafeedback (judge) → to_argilla`. The `ultrafeedback` judge step (GEN5) gives you a triage signal before human review.
- **Milvus / Zilliz** (`pip install pymilvus`) — host the MinHashLSH buckets with native **`uint32` / binary vectors** (Rule DEDUP4: `float32` is exact only to 16,777,216 and silently corrupts bucket collisions above that — at 50k you're fine now, but build it right).
- **Axolotl** (`pip install axolotl`) — SFT with `roles_to_train: ["assistant"]`, `train_on_eos: last`, `eot_tokens`.
- **Unsloth** (`pip install unsloth`) — fast SFT with `standardize_sharegpt` + `map_eos_token`.
- **fastText** (`pip install fasttext`) — langID in the QF1 heuristic gate.

> Note: at 50k examples (post-training scale, thousands–millions) you do **not** need LSHBloom (DEDUP5) — that's a trillion-token pretraining-scale migration. MinHashLSH is the right near-dup tool at your scale.
