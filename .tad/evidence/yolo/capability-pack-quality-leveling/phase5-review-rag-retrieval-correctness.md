# Phase 5 Adversarial Review — rag-retrieval — Correctness Lens

**Lens**: correctness
**Reviewer**: subagent (adversarial, refute-first)
**Date**: 2026-06-13
**Target**: `.claude/skills/rag-retrieval/` (SKILL.md + 6 references + fixture + linter)
**meets_bar**: true (with one material correctness defect that does NOT sink the dual-layer bar but SHOULD be fixed)

---

## Verdict

The pack **clears the QUALITY-BAR dual-layer bar** on the correctness lens:

- **Layer A (structure)**: all 10 criteria pass — frontmatter (name+description, 3rd person, what+when), progressive disclosure (6 references), body 145 lines (≪ 550 cap), Step 0/1/2 routing table, CONSUMES/PRODUCES contract, anti-skip table (10 rows), Quick Rule Index per reference, fixture present, `discriminative_pattern`+`min_discriminative` wired, executable linter. Score 10/10 ≥ 7.
- **Layer B (depth)**: specN = **80** (≥60 → bucket 5). Rules carry research-landed thresholds an LLM cannot recite (69% vs <55%, k=60, 471 QPS / 11.4×, +7.94%, 32K, 35/49/67%, ~$1.02/M, 3072→512 Matryoshka). Tool freshness with versions/context-ceilings/cost. Anti-patterns drawn from real failure modes.
- **discriminative gate (behavior)**: verified by fresh run — CONTROL (generic no-pack RAG advice) = **0** disc markers < 4; WITH-pack output = **17** ≥ 4. Gate genuinely discriminates.

But there is **one material correctness defect** (below) that is internally inconsistent and contradicts current source-of-truth. It is a content/calibration error, not a structural failure, so it does not drop the pack below the bar — but it WOULD mislead an agent in production and should be corrected.

---

## Findings

### F1 (MATERIAL) — "Faithfulness = 1.0 production gate / any value below 1.0 = hallucination" is factually wrong and internally inconsistent

The pack's CENTRAL Cross-Cutting Rule (SKILL.md L29-34), RE2 (rag-evaluation-rules.md L33-49), the anti-skip table, and the linter (`rag-config-lint.sh` L131-135, fires **P0 BLOCKING** on any `faithfulness_gate < 1.0`) all assert as FACT:
> "Any Faithfulness score below 1.0 means the model is fabricating ... gate production deployments on Faithfulness = 1.0."

This contradicts the actual source of truth:
- **Ragas official docs** + 2026 RAG-eval consensus: Faithfulness is a 0–1 *fraction of supported claims*; recommended production thresholds are **0.8 (general) / 0.9+ (regulated finance/health/legal)**, with common pass/fail at **0.85** — NOT 1.0. (verified via WebSearch 2026-06-13, Ragas docs + premai/customgpt/confident-ai 2026 guides.)
- A 1.0 gate is operationally near-unachievable on real multi-claim answers: LLM-as-judge Faithfulness is itself **semi-deterministic** (the pack admits this in RE4 L85) — judge variance alone keeps a perfectly-grounded answer below 1.0 across runs. So a strict `== 1.0` blocking gate would reject essentially every real deployment.
- **Internal inconsistency**: RE7 (L122) and two anti-skip rows reason about a **"0.95-faithful answer"** as a realistic operating point ("can still be wrong if context is stale"). The pack simultaneously (a) treats 0.95 as a normal score worth reasoning about and (b) declares anything below 1.0 to be active fabrication that must block production. Both cannot be true. The "below 1.0 = fabricating" framing also conflates *unsupported claim* (could be benign extraction/paraphrase artifact or judge miss) with *hallucination*.

**Impact**: An agent applying this pack literally would (i) block-gate every real RAG system, and (ii) over-claim "1-in-5 claims hallucinated" framing onto a 0.8 score that the field considers shippable. The linter encodes the error deterministically as a P0, so it is not just prose drift — it produces a wrong blocking verdict.

**Fix direction**: make Faithfulness=1.0 the *aspirational* target but the *blocking* gate domain-tiered (e.g., P0 only below ~0.85 general / ~0.90 regulated, P1 in the 0.85–0.99 band), and reword "below 1.0 = hallucination" to "below the domain threshold = elevated hallucination risk." Reconcile with the RE7 0.95 example.

### F2 (MINOR) — Linter emits the RE7 "faithfulness != correctness" P2 even on a perfect/clean config

`rag-config-lint.sh` L137 fires the RE7 advisory unconditionally whenever `faithfulness_gate` is *set* — so TEST 3 (a fully clean config, gate=1.0) still returns a P2. This is benign (advisory, exit 0 preserved) but is mild noise that slightly undercuts "clean → no findings." Acceptable; flag only.

### F3 (MINOR / consistency) — SKILL prose vs script scope on semantic-chunking P0

SKILL.md L64 describes the P0 trigger as "semantic-by-default on academic docs," but the script (L108-114) also fires P0 when `doc_type` is **unspecified** (empty). This is arguably *correct* (semantic-by-default with unknown corpus IS the dangerous default the pack warns about) and the script's message says so honestly ("doc_type='unspecified'"), but the SKILL one-liner under-describes the actual trigger. Cosmetic — the behavior is defensible; the prose summary is just narrower than the code.

### F4 (NOT A DEFECT — verified clean) — Benchmark hedging is correct

Probed for over-claimed portable constants. The pack **correctly hedges** benchmark-specific numbers: the 120ms P95 and top-50≈90%-of-top-200 are explicitly flagged "benchmark-specific, not a portable constant; plot quality vs latency on your own stack" (SKILL anti-skip L121, HR6 L114). The pgvector 11.4× and Voyage +7.94% are stated with their benchmark conditions. No false universalization found here.

---

## Fact checks (external verification, WebSearch 2026-06-13)

- **RRF k=60**: CONFIRMED. Industry default (OpenSearch/Elasticsearch/Azure AI Search/Weaviate/MongoDB Atlas); original pilot-study constant; optimum flat over k∈[20,100]. Pack's k=60 + "rank-based, bypasses normalization" rationale is correct.
- **BM25 unbounded vs cosine bounded → raw-sum invalid**: CONFIRMED. Matches RRF-motivation literature ("eliminates BM25-vs-cosine incompatibility without normalization").
- **pgvector + pgvectorscale 471 QPS @ 99% recall = 11.4× Qdrant's 41 QPS**: CONFIRMED EXACTLY (471.57 vs 41.47, 50M × 768-dim, TigerData benchmark). Pack correctly notes it is scale/condition-specific.
- **Voyage rerank-2.5 +7.94% over Cohere v3.5, +12.70% MAIR, 32K context (8× Cohere)**: CONFIRMED EXACTLY (Voyage AI blog, 93 datasets; MongoDB/Vercel corroborate; released 2025-08-11).
- **Faithfulness = 1.0 production gate / below 1.0 = hallucination**: REFUTED. Ragas docs + 2026 RAG-eval guides put production thresholds at 0.8–0.9+ (common 0.85), not 1.0. This is F1.
- **Matryoshka 3072→512 no significant Wilcoxon loss**: not independently re-verified this run; consistent with known OpenAI text-embedding-3-large Matryoshka behavior; no red flag.

## Mechanical checks (re-run this session)

- `wc -l SKILL.md` = 145 (A3 pass, ≪ 550)
- `discriminative_pattern` + `min_discriminative` present in fixture (A9 pass)
- specN (UTF-8 locale) = 80 → Layer B bucket 5
- discriminative gate: CONTROL 0 < 4 (FAIL as required), WITH 17 ≥ 4 (PASS) — gate discriminates
- linter exit codes match SKILL prose: P0 config → exit 1; P1-only → exit 2; clean → exit 0; JSON parse works

---

## FIX applied (validated) — 2026-06-13

Each finding from the correctness, fact-api, and anti-slop lenses was VALIDATED (WebSearch against current primary docs for factual/API claims; internal-consistency check for correctness claims) before action. Edits confined to `.claude/skills/rag-retrieval/`.

### Correctness lens

- **F1 (MATERIAL — Faithfulness 1.0 gate)** — **FIXED**. Validated as a genuine defect: WebSearch (Ragas official faithfulness docs + premai/confident-ai 2026 RAG-eval guides, retrieved 2026-06-13) confirms production thresholds are **0.8 general / 0.85 customer-facing / 0.9+ regulated — NOT 1.0**, and the pack was internally inconsistent (RE7 + two anti-skip rows treat 0.95 as a normal operating point while RE2/Cross-Cutting/linter declared anything <1.0 to be blocking fabrication). Changes:
  - `SKILL.md` Cross-Cutting Rule retitled and rewritten: 1.0 = aspirational; gate domain-tiered (block P0 < ~0.85 general / < ~0.90 regulated; 0.85–0.99 = P1 review band), averaged over the eval suite; semi-determinism of the LLM judge made explicit.
  - `SKILL.md` "What This Pack Does" intro: removed the false "ship at 0.8 = 1-in-5 hallucinated" framing; replaced with the blended-score / no-domain-gate failure.
  - `SKILL.md` anti-skip "ship it" row, Step 2 output template, and Validation-Script paragraph all reworded to the tiered gate.
  - `references/rag-evaluation-rules.md` RE2 fully rewritten (graded risk signal, tiered block/review/aspirational ladder, sourced to Ragas + 2026 guidance); RE2 index row, RE4 Faithfulness target row, RE6, and the "Shipping below 1.0" anti-pattern all updated.
  - `scripts/rag-config-lint.sh` faithfulness gate: now domain-tiered — P0 below the floor (0.90 for `doc_type=legal|medical`, else 0.85), P1 in the 0.85–0.99 band, clean at 1.0. Header comment + Validation-Script prose updated. Verified by re-run: clean(1.0)→exit0/0-findings, review(0.95)→P1 exit2, general(0.80)→P0 exit1, regulated medical(0.88)→P0 exit1, raw-sum→P0 exit1.
  - `examples/rag-retrieval-fixture.md` marker/anti-slop prose updated to the tiered gate (financial reports → regulated 0.90 floor still rejects 0.8); discriminative_pattern unchanged (`[Ff]aithfulness ?= ?1` still a valid aspirational-target marker). Discriminative gate re-verified: WITH-pack 19 ≥ 4, CONTROL 0 < 4.
- **F2 (MINOR — RE7 P2 fires on clean config)** — **FIXED**. Linter now emits the faithfulness≠correctness P2 only when `faithfulness_gate < 1.0`, so a clean deliberately-aspirational 1.0 gate returns **zero findings** (verified: clean.conf → 0 P0 / 0 P1 / 0 P2, exit 0). Restores "clean → no findings."
- **F3 (MINOR/cosmetic — SKILL under-describes semantic P0 trigger)** — **FIXED**. `SKILL.md` Validation-Script paragraph now states the trigger as "semantic chunking on academic *or* unspecified-doc-type corpora," matching the script (L108–114 fires on `doc_type` academic OR empty).
- **F4 (benchmark hedging)** — **SKIPPED-FALSE-POSITIVE**. Reviewer already verified clean; 120ms P95 and top-50≈90%-of-top-200 are explicitly flagged non-portable (SKILL anti-skip, HR6). No change.

### Fact-api lens

- **[P0] Qwen3-Embedding mislabeled SYMMETRIC** — **FIXED**. WebSearch (Qwen3-Embedding model card / GitHub / arXiv:2506.05176, retrieved 2026-06-13) confirms Qwen3-Embedding is **instruction-aware / asymmetric**: vendor format prepends an instruction to the QUERY only (`{Instruction} {Query}<|endoftext|>`), document unchanged, for a documented **+1–5%** (omitting it drops recall ~1–5%). `references/embedding-rules.md` EM4 index row, EM4 body, and Anti-Patterns: Qwen3 moved out of the symmetric column into asymmetric/instruction-aware with the query-only-instruction mechanism; OpenAI 3-series kept as the symmetric example.
- **[P1] Cohere embed-v4 default dims 1,024 → 1,536** — **FIXED**. WebSearch (Cohere docs changelog + Vercel/Azure model cards, retrieved 2026-06-13) confirms default **1536**, Matryoshka 256/512/1024/1536. EM1 matrix updated to "1,536 default (256/512/1,024/1,536, Matryoshka)". (128,000 context left as-is — confirmed correct.)
- **[P1] "Nimble" misattributed to Cohere Rerank v4.0** — **FIXED**. WebSearch (Cohere Rerank v4.0 changelog + AWS/Azure listings, retrieved 2026-06-13) confirms v4.0 ships as **rerank-v4.0-pro** and **rerank-v4.0-fast** (Nimble was a Rerank 3 name). `references/hybrid-rerank-rules.md` HR5 row rewritten to name both v4.0 variants (+ 32K context); "Nimble" removed (grep-verified zero residual).
- **[P2] text-embedding-3 context 8,000 → 8,191** — **FIXED**. WebSearch confirms OpenAI max input **8,191** tokens. EM1 matrix updated for both 3-large and 3-small.
- **MTEB v2 numbers + the verified-exact load-bearing numbers** — **SKIPPED-FALSE-POSITIVE** (no defect). Reviewer confirmed they match primary docs and are correctly caveated; no change.

### Anti-slop lens

- **P1 (Faithfulness 1.0 rhetorical absolute)** — **FIXED** (same edits as F1; the Cross-Cutting rule + linter P0 that inherited the overstatement are now domain-tiered and averaged over the suite).
- **P1 (RE3/RE4 targets presented as universal)** — **FIXED** (light reframe). Validated as a soft framing issue (reviewer noted it "still passes the lens"). RE3 and RE4 now explicitly label their target tables as **calibratable General-Purpose-Blueprint defaults, not universal constants**, consistent with HR6's existing hedging.
- **HR2 BM25 k1/b + CH2 separator hierarchy** — **SKIPPED-FALSE-POSITIVE**. Reviewer classified "NOT SLOP (justified)" — correct, load-bearing reference constants. No change.

### Mechanical re-verification post-fix

- `wc -l SKILL.md` = **145** (≪ 550 cap held).
- specN (naive UTF-8 numeric-token dedup) = 163 raw tokens; net edits added numbers (0.85, 0.90, 1536, 8191, +1–5%) and removed none of substance → Layer B bucket 5 (≥60) preserved.
- linter `bash -n` syntax OK; all five exit-code scenarios pass (see F1/F2 above).
- discriminative gate: WITH-pack 19 ≥ 4, CONTROL 0 < 4 — still discriminates.

**Net**: all genuine findings fixed (F1, F2, F3, fact-api P0/2×P1/P2, anti-slop 2×P1); F4 and the verified-clean number/constant items skipped as false positives. Pack remains above the dual-layer bar with the central correctness defect corrected.
