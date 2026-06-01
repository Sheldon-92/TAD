# Review: Synthetic Fine-Tune Dataset Pipeline

**Pipeline under review:** Prompt GPT-4 → generate 50k instructions from docs → drop exact-duplicate rows → format as JSON → train → report accuracy on a public benchmark.

**Verdict:** The skeleton is reasonable, but as described this pipeline has several gaps that will likely produce a model that looks better on paper than it is in reality. The two most serious issues are (1) **near-duplicate / semantic redundancy is not addressed** by exact-dedup, and (2) **benchmark contamination + evaluation design** could make your reported accuracy meaningless. Details below, roughly in priority order.

---

## 1. Deduplication: exact-match is far too weak (HIGH)

Dropping exact-duplicate rows only catches byte-identical strings. LLM-generated instruction data is dominated by **near-duplicates and semantic redundancy**: the same question reworded, the same doc paragraph paraphrased 40 different ways, trivial template variations ("Explain X" / "Can you explain X?" / "Tell me about X").

What to do instead:
- **Fuzzy/normalized dedup:** lowercase, strip whitespace/punctuation, then hash. Catches trivial variants exact-match misses.
- **N-gram near-dup:** MinHash + LSH (e.g. `datasketch`) on shingled tokens, or the dedup tooling in `text-dedup`. Cluster at a Jaccard threshold (commonly ~0.7–0.85) and keep one representative per cluster.
- **Semantic dedup:** embed instructions (a small sentence-transformer is fine) and remove pairs above a cosine threshold. This is what catches paraphrase duplication that MinHash misses.
- **Dedup against your eval/benchmark set** (see §2) — not just within the training set.

Expect to remove a *large* fraction. On Self-Instruct-style pipelines it's common for 20–60% of raw generations to be redundant. Report the dedup funnel (raw → exact → near → semantic) so you can see what's happening.

## 2. Benchmark contamination — likely fatal to your accuracy claim (HIGH)

You generate instructions *from your docs* and then *report accuracy on a public benchmark*. Two contamination risks:

- **Train/test leakage:** if your docs overlap in content with the benchmark's source material, or if GPT-4 happens to regenerate benchmark-like items, your training set may contain near-copies of test questions. This is the single most common way fine-tune accuracy numbers get inflated.
- **GPT-4's own contamination:** GPT-4 may have memorized the public benchmark. Asking it to "generate instructions" can surface benchmark items verbatim or paraphrased.

Mitigations (do all of these):
- Run **n-gram contamination detection** (e.g. 13-gram overlap, the standard from GPT-3/Llama reports) between your training set and the *full benchmark test set*. Remove any training item that overlaps.
- Also check embedding-level near-match against test items, not just exact n-grams.
- Prefer a **held-out benchmark released after GPT-4's training cutoff**, or a private eval set you build yourself, to reduce the "model already saw the test" problem.
- Report the decontamination stats explicitly. A reviewer will not trust the accuracy number without them.

## 3. No quality filtering of generated instructions (HIGH)

Dedup ≠ quality. Raw GPT-4 generations contain: instructions that don't match any source content (hallucinated), answers that contradict the doc, malformed/empty outputs, off-topic chit-chat, refusals, and "As an AI language model…" boilerplate. Training on these directly degrades the model and teaches it to hallucinate confidently.

Add a quality stage:
- **Heuristic filters:** length bounds, non-empty answer, language ID, drop instructions with no recoverable answer, drop refusals/meta-text.
- **Groundedness check:** for doc-derived data, verify the answer is actually supported by the cited source chunk (LLM-as-judge or NLI/entailment). Drop or flag ungrounded pairs — otherwise you're training the model to make things up.
- **LLM-as-judge scoring** (e.g. a 1–5 quality rubric) and keep only above a threshold. Be aware of self-preference bias if the judge is also GPT-4; calibrate against a small human-labeled set.
- **Hold out a human spot-check** of ~100–200 random rows. Read them. This catches systematic failure modes no automated filter will.

## 4. Diversity & coverage are not controlled (MEDIUM)

Generating 50k items from docs with a single prompt tends to collapse: the model over-samples a few easy patterns and under-covers the long tail. You can have 50k rows that behave like 3k.

- Track an **instruction-type / task-type distribution** (Self-Instruct seeded ~175 tasks for this reason; Evol-Instruct evolves complexity to broaden the distribution).
- Measure coverage against your docs: which sections/topics are represented? Are some chapters massively over-represented?
- Consider **complexity evolution** (Evol-Instruct/WizardLM style) to get harder, multi-step instructions rather than only shallow lookups.
- Measure **embedding-space diversity** (e.g. mean pairwise distance, or cluster count) before and after, so you can prove the 50k isn't redundant.

## 5. "Format as JSON" is underspecified (MEDIUM)

This is where silent data loss happens:
- Pick and document a **schema** (instruction / input / output, or messages/chat format matching your trainer's expectation — Alpaca vs ShareGPT vs OpenAI messages all differ).
- Use **JSONL**, not one big JSON array, for streaming and partial-failure tolerance.
- **Validate every row** against the schema; log and quarantine failures rather than dropping silently.
- Handle escaping/Unicode/code blocks (GPT-4 loves emitting ```fences``` and nested quotes that break naive JSON parsing).
- Decide on and enforce the **chat template / special tokens** that match the base model you fine-tune — a mismatch here is a very common cause of "fine-tune did nothing."

## 6. Train/eval split & the "report accuracy" plan (MEDIUM)

- Where's your **validation set**? You need a held-out split for early stopping and to detect overfitting — generating 50k and training on all of it gives you no signal.
- **One benchmark accuracy number is weak evidence.** Report: (a) the benchmark with decontamination stats, (b) at least one *capability* eval relevant to your actual docs/use-case, and (c) a regression check that the model didn't get worse at general tasks (catastrophic forgetting / alignment tax is real with narrow SFT).
- Define the metric precisely (exact match? normalized? LLM-judged?) and report variance across seeds — single-run accuracy deltas are often within noise.

## 7. Training-side concerns not mentioned (LOWER, but worth flagging)

- **Base model + method:** full fine-tune vs LoRA/QLoRA changes everything about cost, catastrophic forgetting, and required data volume. 50k is plenty for LoRA SFT; full FT of a large model on 50k may overfit.
- **Hyperparameters:** epochs (1–3 is typical for SFT; more overfits synthetic data fast), LR, loss masking (mask the prompt tokens — only train on the response, a very common bug).
- **Licensing / ToS:** generating training data with GPT-4 to train a competing model may violate OpenAI's terms depending on your use. Flagging as a real-world risk, not a code issue.

## 8. Reproducibility (LOWER)

- Pin the GPT-4 model version (snapshot), generation params (temperature, top_p), and seed where possible — "GPT-4" drifts over time.
- Version the dataset (hash the final file), log the full funnel counts, and store the generation prompts. You will want to regenerate or debug this later.

---

## Suggested pipeline (revised)

```
docs
 → generate (seeded task types, controlled temperature, logged prompts)
 → schema-validate each row (JSONL, quarantine failures)
 → exact dedup
 → near-dup dedup (MinHash/LSH)
 → semantic dedup (embedding cosine)
 → quality filter (heuristics + groundedness + LLM-judge, human spot-check)
 → diversity/coverage audit
 → DECONTAMINATE against benchmark test set (n-gram + embedding)
 → train/val split
 → train (LoRA/QLoRA, loss-masked, 1–3 epochs, early stop on val)
 → eval: benchmark (w/ decontam stats) + use-case eval + forgetting regression
 → report with full funnel + decontam numbers
```

## Top 3 things to fix first

1. **Add near-dup + semantic dedup** — exact-match alone leaves your set heavily redundant.
2. **Decontaminate against the benchmark** (n-gram + embedding) and report the stats — otherwise your accuracy claim isn't credible.
3. **Add a quality/groundedness filter + human spot-check** — dedup does not remove hallucinated or low-quality rows, and those actively harm the model.
