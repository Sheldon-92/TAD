---
name: synthetic-data
description: Synthetic data & fine-tune dataset curation capability pack. Gives AI agents the judgment rules for pretraining/SFT data quality filtering, document-level deduplication, synthetic instruction generation, preference-pair curation, and benchmark contamination detection. Research-grounded rules from Self-Instruct, Evol-Instruct/WizardLM, LSHBloom, distilabel, Axolotl/Unsloth, DPO/RRHF/GRPO, and the ConTAM/CoDeC contamination literature. Use for any synthetic dataset build, fine-tune data prep, dedup pipeline, preference dataset, or contamination audit task.
keywords: ["合成数据", "synthetic data", "数据集", "dataset", "微调数据", "fine-tune data", "去重", "deduplication", "数据清洗", "data filtering", "Self-Instruct", "Evol-Instruct", "偏好数据", "preference data", "DPO", "污染检测", "contamination", "蒸馏", "distillation", "指令数据", "instruction tuning"]
type: reference-based
---

**CONSUMES**: User dataset-curation task + raw corpus / seed tasks / fine-tune data description + target model + optional existing pipeline configs
**PRODUCES**: Applied data-curation judgment rules + filtering thresholds + dedup architecture choice + synthetic-generation pipeline + preference-pair config + chat-template alignment + contamination audit results

# Synthetic Data & Fine-Tune Dataset Curation Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents build fine-tune datasets by dumping a model's raw generations into a JSONL and training on it. They skip deduplication, so the model memorizes repeated documents. They prompt a single model to generate instructions with no diversity controls and no ROUGE-L filtering, so the set collapses into near-duplicates. They evaluate the fine-tuned model on public benchmarks that leaked into the data and celebrate inflated scores. They mis-map chat templates and train on pad tokens.

This pack embeds the judgment rules that data-curation engineers apply automatically — rules from the Self-Instruct and Evol-Instruct/WizardLM papers, LSHBloom-scale dedup architectures, distilabel pipeline practice, Axolotl/Unsloth fine-tuning docs, and the ConTAM/CoDeC contamination-detection literature.

**Pack = data-curation judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Decontaminate Before You Trust the Score

> **Before reporting ANY benchmark number for a model trained on web-scraped or synthetic data, run contamination detection against the eval set.** Public benchmarks leak into training corpora at high rates — one study flagged up to ~90% of examples in datasets like SQuADv2 and DROP as contaminated (a single-source, definition-specific figure, not a universal rate). Contamination is not binary; it is a spectrum that silently inflates leaderboard scores. The GSM1k study showed accuracy drops of up to 13% on uncontaminated math problems, and Claude Opus 4.5 dropped 35 percentage points (80.9% → 45.9%) from SWE-bench Verified to the contamination-resistant SWE-bench Pro.

This rule applies to: synthetic generation (your generated set may regurgitate benchmark items), preference curation, and every "our fine-tune scores X%" claim. It is surfaced here because a clean number on a contaminated benchmark is the most expensive silent failure in the whole pipeline.

---

## Step 0: Context Detection

When the user mentions dataset-curation work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "data quality", "filter corpus", "perplexity filter", "Ask-LLM", "quality score", "数据清洗", "质量过滤" | `references/quality-filtering-rules.md` |
| "deduplicate", "dedup", "MinHash", "LSH", "near-duplicate", "去重" | `references/deduplication-rules.md` |
| "synthetic data", "Self-Instruct", "Evol-Instruct", "WizardLM", "generate instructions", "distilabel", "合成数据", "指令生成" | `references/synthetic-generation-rules.md` |
| "preference data", "DPO", "RRHF", "GRPO", "chat template", "ShareGPT", "Axolotl", "Unsloth", "偏好数据", "微调格式" | `references/preference-alignment-rules.md` |
| "contamination", "benchmark leak", "data leakage", "ConTAM", "CoDeC", "污染检测", "基准泄漏" | `references/contamination-detection-rules.md` |
| "full dataset pipeline", "build a fine-tune dataset end to end", "curate everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's corpus, pipeline config, or generation setup
3. **For each violated rule**: state the violation clearly, then give the specific fix (with the threshold/command from the reference)
4. **Enforce the Decontaminate-Before-You-Trust-the-Score cross-cutting rule** before reporting any benchmark number
5. **Check stage annotations** — they tell you where in the pipeline a rule applies:
   - `pretraining`: corpus-scale filtering/dedup (millions–billions of docs)
   - `post-training`: SFT / preference / instruction-tuning data (thousands–millions of examples)
   - `eval`: contamination audit before scoring

Output format per finding:
```
[P0] Rule DEDUP3 (deduplication): No near-duplicate pass — only exact SHA-256 dedup is configured.
→ Add a MinHashLSH (or LSHBloom) near-duplicate pass; exact-match misses copyedited/reformatted duplicates.

[P1] Rule GEN1 (synthetic-generation): Self-Instruct loop has no ROUGE-L overlap filter.
→ Reject any generated instruction whose ROUGE-L with an existing pool instruction exceeds 0.7.
```

---

## Step 2: Output

Produce a structured curation report:

```
## Dataset Curation Review: [area reviewed]

### P0 — Blocking (must fix before training / shipping the dataset)
- [finding + specific fix]

### P1 — Required (fix before trusting the dataset)
- [finding + specific fix]

### P2 — Advisory (improves dataset quality)
- [finding + specific fix]

### Pipeline Stage Audit
[table: filter → dedup → generate → align → decontaminate, with status per stage]

### Tool Recommendation
[distilabel / Axolotl / Unsloth / Milvus-BINARY_VECTOR / fastText based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "Exact dedup is enough" | Exact SHA-256 only catches verbatim copies. Copyediting, reformatting, and versioning produce near-duplicates that inflate memorization — you need MinHashLSH or LSHBloom. |
| "We'll just prompt the model to generate a lot of instructions" | Without ROUGE-L > 0.7 rejection and the Self-Instruct 6-human/2-machine sampling mix, your set collapses into near-duplicates. Flat Self-Instruct also underperforms Evol-Instruct evolution. |
| "Perplexity filtering picks the good data" | Perplexity has in-distribution bias: it discards niche/long-tail documents (high PPL) and keeps repetitive boilerplate (low PPL). Ask-LLM has near-zero ranking correlation with perplexity for a reason. |
| "Our fine-tune scores 80% on the benchmark" | Did you decontaminate first? One study flagged up to ~90% of SQuADv2/DROP as contaminated (single-source figure). GSM1k dropped 13%, and SWE-bench Verified→Pro is a 35pp gap on a harder contamination-resistant suite. |
| "DPO is all we need" | DPO is structurally pairwise and lacks exploration. For >2 candidates use RRHF ranking loss; for verifiable math/logic use GRPO. And map your chat template, or you train on pad tokens. |

---

## Tool Quick Reference

| Tool | Install / Invocation | Primary Use |
|------|----------------------|-------------|
| distilabel | `pip install distilabel` | DAG-based synthetic generation pipelines (load → generate → ultrafeedback → to_argilla) |
| Axolotl | `pip install axolotl` | SFT/preference fine-tuning; `roles_to_train`, `train_on_eos`, `eot_tokens` config |
| Unsloth | `pip install unsloth` | Fast fine-tuning; `standardize_sharegpt`, `map_eos_token` |
| fastText | `pip install fasttext` | Language identification filtering in the heuristic gate |
| Milvus / Zilliz | `pip install pymilvus` | `MINHASH_LSH` index over a `BINARY_VECTOR` MinHash field (avoids float32 precision loss) |
