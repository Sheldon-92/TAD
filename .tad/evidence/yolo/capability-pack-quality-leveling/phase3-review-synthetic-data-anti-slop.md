# Phase 3 Adversarial Review — synthetic-data — Anti-Slop Lens

**Reviewer**: adversarial subagent (anti-slop lens)
**Date**: 2026-06-13
**Pack**: `.claude/skills/synthetic-data` (v0.1.0)
**Files read**: SKILL.md + 5 references/ + examples/synthetic-data-fixture.md + scripts/validate-curation-config.sh + QUALITY-BAR.md

## Lens

Anti-slop: Are the Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM could NOT emit from training), or generic rules dressed up? Flag vague/restatable rules masquerading as depth. Flag unsourced numbers.

## meets_bar: TRUE

specN = 50 (re-counted live → Layer B bucket 4/5, 40–59 band). The pack clears the anti-slop bar: the overwhelming majority of its specifics are paper-grounded, reproducibility-grade, and could NOT be emitted by a no-pack frontier LLM. Single-source / version-sensitive numbers are explicitly hedged rather than asserted, which is the opposite of slop. Every number-bearing rule carries a `> Source:` line (8/8/7/6/6 across the 5 refs). The validation script genuinely discriminates (tested: 4 P0 on a deliberately bad pipeline, exit 1). The fixture's discriminative_pattern deliberately EXCLUDES generic ML vocabulary (Self-Instruct, MinHashLSH, ROUGE-L, GRPO) and counts only pack-unique markers — a textbook anti-validation-theater fixture.

## Findings

### Genuinely research-grounded (LLM could NOT recite these from training) — PASS
- DEDUP4: `float32` integer-exact only to 16,777,216 (= 2^24, verifiably correct) → store MinHash as `BINARY_VECTOR` with `mh_element_bit_width`; Milvus `MINHASH_LSH`/`MHJACCARD`, "no native uint32-vector type". This is a real, non-obvious engineering constraint with a named index type — not restatable.
- DEDUP5: LSHBloom ≈270% faster / 18–54× less disk / peS2o 39M docs / 14–35h on 32-core / 200–300 GB / FP ≤ 10⁻⁵. Paper-specific tuple.
- DEDUP8: D4 config `R_dedup=0.75` + OPT-125M last-token-last-layer embedder + 6.7B/100B-tok → ~20% pretrain efficiency / ~2% over 16 NLP tasks. A no-pack LLM cannot produce this exact config.
- DEDUP3-refinement: pinned (5-gram, num_perm=256, J=0.7, ~20 bands) text-dedup/datatrove/FineWeb reference config — converts the otherwise-generic "use MinHashLSH" into an operational threshold tuple. Correctly flagged as P1 when unspecified.
- GEN7 Magpie: exact reward-model id `RLHFlow/ArmoRM-Llama3-8B-v0.1`, 4M→300K distillation, FAISS min-neighbor-distance dedup. Reproducibility-grade.
- PA7: HelpSteer2 5 named attributes (Helpfulness/Correctness/Coherence/Complexity/Verbosity), Likert 0–4, `Nemotron-4-340B-Reward`, RPO, >98% synthetic, ~1% human. Paper-specific, dual-sourced (NVIDIA blog + arXiv 2406.11704).
- CON4: ConTAM `mincount 1 / skip_budget 0 / n<8` optimal config. Config-specific, not guessable.
- QF6: downstream-average comparison table (Random 32.3% … QuaDMix-BMK 39.5%) with per-method downside column. Table-grounded; the "headline score meaningless without downside column" framing is genuine judgment, not slop.
- GEN1/GEN2/GEN3: ROUGE-L>0.7 reject, 175 seed (25 cls/150 non-cls), 6-human/2-machine sampling mix, 12-cls/19-non-cls classifier exemplars, Output-First-for-classification. These ARE in the Self-Instruct paper; the 6:2 mix and Output-First branch are non-obvious enough to count as depth (note: the fixture honestly excludes "Self-Instruct"/"ROUGE-L"/"0.7" from its DISCRIMINATIVE gate as generic — only the rarer markers count).

### Hedged single-source numbers — this is a STRENGTH, not slop
The most "quotable" numbers are explicitly de-weaponized in-text, in 3+ places each:
- ~90% SQuADv2/DROP contaminated: flagged "single-source, definition-specific figure, not a universal rate" in the cross-cutting rule, CON1, AND the anti-skip table. Correct discipline.
- SWE-bench Verified 80.9% → Pro 45.9% (−35pp): CON2 explicitly refuses to attribute the whole delta to contamination ("conflates contamination, suite difficulty, and harness"), names the Scale 45.9% vs Anthropic 52% harness discrepancy, and demands "report the exact evaluator/harness/date." This is the correct treatment of a version-sensitive Opus-4.5 claim — exactly what principles YOLO-audit 2026-05-15 (research evidence auditability) asks for.
- ~1000× perplexity-alternative (QF2): flagged "setup-specific — ablate locally before relying on it." Good.
- GSM1k −13%: bounded as "up to 13% … on new uncontaminated problems," attributed to the GSM1k study.

### Minor / advisory (not bar-failing)
- F1 (P2): GEN5 names `open-mistral-7b` / `open-mixtral-8x7b` / `mistral-large-latest` as the distilabel DAG example endpoints. These are illustrative of a pipeline shape (load→generate→ultrafeedback→to_argilla) rather than load-bearing thresholds; `mistral-large-latest` is a moving alias and is mildly time-sensitive, but it is framed as "e.g." and the rule's actual judgment (an ultrafeedback judge step must precede human review) is model-agnostic. Acceptable, but the rolling alias is the one weakly-time-sensitive token in the pack.
- F2 (P2): QF1 `< 5 / > 2000 tokens` length gate and DEDUP1 `2–3 GB RAM` are corpus/setup-specific operating points presented without an explicit "tune to your corpus" hedge (unlike QF2/CON1 which DO hedge). They are sourced ([1] and [10]) so not unsourced, but readers could over-fit them as universal. Low severity — heuristic-gate thresholds are inherently illustrative.
- F3 (observation, not a defect): QF5 Complexity Gap `CG(x,y)=C(x,ỹ)−C(x,y)` uses Kolmogorov complexity (uncomputable; relies on a compressor estimate). The rule is honest that `C` is "a Kolmogorov complexity estimate," so no overclaim. Genuinely pack-unique.

### No unsourced numbers found that masquerade as research findings
Every quantitative claim traces to a `> Source:` line with a paper/tool + (for the refreshed refs) a retrieval date of 2026-06-13. No bare statistics dressed up as depth.

## fact_checks
- 16,777,216 = 2^24 is the correct float32 integer-exact upper bound (verified by arithmetic). DEDUP4's precision-loss claim is technically sound.
- specN re-counted live = 50 (initial run failed on unquoted space-in-path; re-run with null-delimited xargs). Matches QUALITY-BAR §2.3 bucket 4 (40–59→4). The ±2 drift note in QUALITY-BAR applies; bucket-stable.
- validate-curation-config.sh executed against a synthetic bad pipeline (exact-only dedup + self_instruct w/o ROUGE-L + axolotl w/o token-mapping + report_accuracy w/o decontam): returned 4 P0, exit 1. Checks 3 (BINARY_VECTOR) correctly skipped (no MinHash present). Script is deterministic, BSD-safe, no network, no Windows paths — genuinely backs the Pipeline Stage Audit table rather than punting to Claude.
- SWE-bench Pro / Opus 4.5 numbers (80.9% Verified, ~45.9% Scale Pro, ~52% Anthropic harness) are within knowledge cutoff and the pack's own hedge correctly separates "different harder suite" from "decontaminated Verified" — not a pure-contamination overclaim.
- Body = 133 lines (< 500 Anthropic threshold). References are one level deep. Fixture discriminative_pattern excludes generic ML vocab and counts only pack-unique markers (min_discriminative=4) — anti-validation-theater confirmed.
- Cited primary sources spot-checked for existence/plausibility: Self-Instruct, Evol-Instruct/WizardLM (250k), SemDeDup (arXiv 2303.09540), D4 (NeurIPS 2023, 2308.12284), Magpie (2406.08464), PersonaHub (2406.20094), Nemotron-4 340B (2406.11704), ConTAM, CoDeC — all real, correctly attributed.
