# Dogfood Judgment: synthetic-data pack — dataset pipeline review

**Task**: Review a GPT-4 → SFT → preference-tuning → public-benchmark pipeline.
**Date**: 2026-06-13
**Judge**: independent technical judge (blind to which answer used the skill)

## Which answer used the skill
Answer 1 unambiguously used the `synthetic-data` SKILL: it cites the exact rule IDs (CON1-5, GEN1/GEN8, DEDUP1-4, PA1-7, QF1/QF5), the cross-cutting decontaminate-before-score rule, the `validate-curation-config.sh` deterministic checker, and the BINARY_VECTOR/Milvus tool quick-reference — all matching SKILL.md verbatim. Answer 2 is strong general knowledge with no rule IDs or script.

## WebSearch verification of key specifics

| Claim | Answer | Verdict |
|-------|--------|---------|
| PersonaHub ~1B personas (Tencent) | 1 | CORRECT — arXiv 2406.20094, "1,000,000,000 Personas" |
| Nemotron-Personas 100K, Census-grounded | 1 | CORRECT — 100k records, US Census distribution-aligned |
| Nemotron-4-340B-Reward; HelpSteer2 5 attrs (Help/Correct/Coherence/Complexity/Verbosity), Likert 0-4 | 1 | CORRECT — matches HF model card + HelpSteer2 (CC-BY-4.0, Likert-5 scale 0-4) |
| GSM1k accuracy drop "up to 13%" | 1 | CORRECT — Scale AI 2405.00332 |
| ConTAM LONGEST-MATCH + NGRAM-MATCH metrics | 1 | CORRECT — arXiv 2411.03923, both metrics named exactly |
| CoDeC behavioral detector (in-context confidence lift) | 1 | CORRECT — Contamination Detection via Context, gray-box token probs |
| ROUGE-L > 0.7 rejection (Self-Instruct) | 1 | CORRECT — Self-Instruct convention |
| 13-gram = "GPT-3/Llama convention" | 2 | MOSTLY CORRECT — GPT-3 popularized 13-gram (8-13 range); Llama-2 actually used token-level skipgram matching, NOT strictly 13-gram. Slightly loose attribution but not materially wrong. |
| DPO length/verbosity bias (chosen longer) | 2 | CORRECT — well-documented (SamPO/R-DPO literature) |
| On-policy: sample rejected from the policy model | 2 | CORRECT — standard on-policy preference best practice |
| MinHash Jaccard ~0.7-0.8 SFT starting point | 2 | CORRECT — common range |
| JSONL preferred over JSON for 50k rows | 2 | CORRECT — standard |
| OpenAI ToS on using GPT-4 outputs | 2 | CORRECT and a genuinely valuable catch neither rubric forced |

## Wrong claims found
- Answer 2: attributing the 13-gram convention to "GPT-3/Llama" — GPT-3 is correct, but Llama-2 used a token-level skipgram approach, not 13-gram. Minor, does not invalidate the (correct) core advice to run n-gram overlap on the test split.
- Answer 1: no factually wrong specifics found. Every cited tool, model, metric, and number verified against primary sources.

## Scoring

### Answer 1 (used skill)
- Correctness: 5 — every specific verified, zero wrong claims. The contamination dual-path (corpus n-gram + behavioral CoDeC for the GPT-4-corpus-you-don't-control case) is exactly right.
- Actionability: 5 — concrete configs (num_perm=256, J=0.7, 20 bands, BINARY_VECTOR), named tools, a runnable checker, ordered pipeline-stage audit table.
- Specificity: 5 — densely specific AND the specifics are correct, which is the bar.
- Completeness: 5 — covers all six declared stages plus the missing filter/decontam stages; P0/P1/P2 tiers.

### Answer 2 (general)
- Correctness: 4 — one minor loose attribution (13-gram/Llama); everything else sound. The two "leak paths" framing (docs↔benchmark source + GPT-4 regurgitation) is excellent and arguably clearer than Answer 1's.
- Actionability: 4 — concrete corrected-pipeline ordering, length-bias control, on-policy rejected sampling, stage-count logging. Slightly fewer hard numbers/tool configs.
- Specificity: 3 — fewer named tools/thresholds; "~0.7-0.8", "13-gram" are about it.
- Completeness: 5 — actually adds two things Answer 1 underweights: (a) groundedness/faithfulness filter against source docs (the whole point is teaching *your docs*), and (b) OpenAI ToS/licensing risk. Both are real and material.

## Winner: 1 (clear)

Answer 1 wins on CORRECT specifics, not verbosity. Its density of claims is the kind that usually hides errors, yet every single one — PersonaHub, Nemotron-Personas, Nemotron-4-340B-Reward + HelpSteer2 attributes, GSM1k 13%, ConTAM's two named metrics, CoDeC's mechanism — checked out against primary sources. That is the decisive factor: it gives the user runnable configurations and a verification script, and it correctly diagnoses the subtle "MinHash configured to drop exact-only defeats its purpose" contradiction with a fix at a pinned reference config.

Answer 2 is genuinely good and is NOT a strawman — its leak-path framing is arguably more pedagogically clear, and it raises two valid points Answer 1 underweights (doc-groundedness filter, OpenAI ToS). If Answer 1 had any wrong specifics this would be close to a tie. But the rubric explicitly penalizes confident-wrong over honest-general, and Answer 1 paid zero such penalty while delivering far more actionable, verified specificity. Margin is "clear" rather than "decisive" because Answer 2's correctness is nearly as high and it surfaces material content Answer 1 misses (groundedness, licensing).
