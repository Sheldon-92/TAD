# Training Data Preparation Rules

> Loaded on signal: training data, 训练数据, chat logs, 聊天记录, data prep.
> Format schemas + quality gates + synthetic bootstrap. Validate output with `scripts/dataset-check.sh`.

---

## Dataset Quality Rule (quality > quantity)

- **500 clean examples outperform 5,000 noisy ones** (sitepoint 2026).
- Working range **500–10,000** after dedup + length filtering.
- Practical floor **100** examples — below this, do NOT fine-tune (see `lora-finetune.md`).
- Dogfood evidence (Colin voice project): **117 clean segments outperformed 248 dirty
  segments** at the same step count — confirming the ratio rule on a real run.

Source: https://www.sitepoint.com/fine-tune-local-llms-2026/ (retrieved 2026-06-13)

---

## LLM Data Pipeline (chat logs → trainable)

1. **Extract** raw chat logs / documents.
2. **Clean**: strip system noise, dedup near-duplicates, length-filter (drop empty + outlier-long).
3. **Format** into one of the accepted schemas below.
4. **Validate** schema with `scripts/dataset-check.sh <file.jsonl>`.

### ShareGPT schema (multi-turn)
```json
{"conversations": [
  {"from": "human", "value": "..."},
  {"from": "gpt", "value": "..."}
]}
```
One JSON object per line (JSONL). `from` ∈ {human, gpt, system}; alternating human/gpt.

### ChatML / Alpaca
Accepted alternatives. ChatML uses `messages:[{role,content}]`; Alpaca uses
`{instruction, input, output}`. Pick one and keep it consistent across the file.

---

## Preference-Pair Data (for DPO / GRPO)

DPO/GRPO need **triples**, not single completions:
```json
{"prompt": "...", "chosen": "...", "rejected": "..."}
```
Build `chosen` from the preferred answer, `rejected` from a worse one (model sample,
older model, or deliberately degraded). Then apply DPO config in `lora-finetune.md`.

---

## Voice Data Pipeline (defer audio thresholds to ai-voice-production)

audio → **VAD** (voice-activity split) → **transcript** (ASR) → **annotation list**
(audio_path | transcript | speaker). Audio quality thresholds (SNR, sample rate,
segment length) are owned by the **ai-voice-production** pack — defer there.

---

## AI Bootstrap Technique (reach the 500-example floor)

When real data is below the practical floor, use a frontier model to **generate synthetic
training pairs** seeded from the few real examples you have:
1. Few-shot the frontier model with 5–20 real examples.
2. Generate candidates; **dedup** (synthetic data collapses to near-duplicates fast).
3. Length-filter + human spot-check a sample.
4. Mix synthetic with real; keep real-to-synthetic ratio documented.

This is how a personality-clone task reaches 500+ examples without 500 real conversations.

---

## Cross-references
- How many examples your task needs → `lora-finetune.md` §When to Fine-Tune
- Schema validator → `scripts/dataset-check.sh`
- Voice tool specifics → ai-voice-production pack
