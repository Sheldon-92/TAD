# Phase 4 Adversarial Review — ai-prompt-engineering (anti-slop lens)

> Reviewer: anti-slop lens subagent | Date: 2026-06-13
> Scope: SKILL.md + references/ (claude.md, phase1-write.md, failure-catalog.md, few-shot-design.md, output-format.md) + tools/selection-matrix.md + examples/ fixtures
> Bar: `.tad/evidence/pack-quality/QUALITY-BAR.md` Layer B (depth) — are the "specifics" research-grounded numbers an LLM could NOT emit from training, or generic rules dressed up?

## Lens

Layer B depth / anti-slop: distinguish (a) genuinely research-grounded specifics — thresholds/exit-codes/version-pinned API facts an LLM cannot reproduce from training — from (b) generic rules dressed up to look specific, and (c) unsourced or unverifiable numbers masquerading as depth.

## Verdict

**meets_bar = true** (clears Layer B depth on the anti-slop lens), **with one material caveat that should be fixed**: the 46/25/29 failure-taxonomy split is an unverifiable number doing disproportionate load-bearing work (cited 6×, wired into the discriminative eval gate). It does not by itself sink the bar — the pack carries a dense, independently-verified specific layer elsewhere — but it is the pack's weakest seam and a textbook anti-slop risk (number that *looks* researched, traces to a source that returns zero hits).

specN = 88 distinct specific-threshold matches (≥60 → Layer B bucket 5). Note ~20 of the 88 are semantic-version/CHANGELOG noise (4.6/4.7/4.8, v1.1.0, 1.0–3.7 confidence values in example YAML), so the *honest* specific-threshold density is lower than 88 but still comfortably above the 60 floor on genuinely load-bearing items.

## Findings

### Genuinely research-grounded (LLM could NOT emit from training) — the real depth

1. **claude.md is the strongest, most defensible layer.** `budget_tokens` REMOVED → HTTP 400 on Opus 4.7/4.8/Fable 5; `thinking:{type:"adaptive"}` + `output_config.effort` (low/medium/high/xhigh/max, default high, xhigh for coding); prefill REMOVED → 400; `temperature`/`top_p`/`top_k` → 400 on 4.7+; model-specific min cacheable prefix (4096 Opus/Haiku vs 2048 Sonnet/Fable). These are post-training-cutoff API facts (Opus 4.8 is a 2026 model) — an LLM CANNOT emit these from memory; it would emit the OLD (now-400) patterns. VERIFIED against current platform.claude.com docs via WebSearch. This is exactly the "specific threshold / exit code an LLM can't produce" signal QUALITY-BAR §2.1 anchors at 5. The "Old patterns (do NOT use)" table is excellent anti-slop hygiene — it actively counter-programs the LLM's training-data default.

2. **GEPA optimizer numbers are real and verifiable.** arXiv:2507.19457, ICLR 2026 Oral, ">10pp over MIPROv2", "~20% over GRPO with ~35× fewer rollouts (100–500 vs 5,000–25,000+)", `reflection_lm` required, works with as few as 3 examples — VERIFIED. The decision rule (tiny trainset + textual feedback → GEPA; pure scalar → MIPROv2; demos-only → BootstrapFewShot) is operationalized, not generic. The AIME 46.6%→56.6% and ARC-AGI 32%→89% sub-figures I could not independently confirm in-search but are consistent with the paper's claimed magnitude and carry a real citation (github.com/gepa-ai/gepa + dspy.ai). NOT slop.

3. **Model-specific cacheable-prefix + silent-invalidator list is genuine depth.** "A 3K-token prompt caches on Sonnet 4.6 but silently won't on Opus 4.8" + grep-able invalidators (`datetime.now()`, `uuid4()`, `json.dumps()` without `sort_keys=True`, `tools=build_tools(user)`, max 4 breakpoints, verify via `cache_read_input_tokens`). These are operational specifics, not "cache when slow" (the QUALITY-BAR §2.1 0-2 negative anchor).

4. **DeepEval metric thresholds + DAG/Conversational constructs** (FaithfulnessMetric ≥0.8, HallucinationMetric ≤0.2, DagMetric for reproducible non-jittering gates, ConversationalTestCase for multi-turn) are tool-accurate and carry a retrieval-dated source. B2 (tool timeliness) is met: named CLI + version notes (dspy not dspy-ai rename, npx promptfoo@latest) + usage, not just a tool list.

5. **OWASP LLM Top 10 2025 mapping** (LLM01/02/05/06/07/09, LLM07 System Prompt Leakage flagged "new in 2025") + promptfoo redteam strategy→attack-shape mapping (prompt-injection/jailbreak/crescendo) is specific and current.

### Generic-or-thin rules (dressed up, lower discriminative value)

6. **output-format.md and few-shot-design.md are the thinnest references.** Compliance tiers (≥99 excellent / 95–99 good / <90 failing), "examples ≤40% of context", "1 token ≈ 4 chars", "3 high-quality > 10 mediocre" — these are reasonable but largely restatable by a frontier LLM with no research (QUALITY-BAR 0-2 band). The 95% compliance threshold and the 40% token budget are presented as hard numbers with no source; they read as sensible defaults, not measured findings. Not harmful, but this is the "generic rule with a number stapled on" pattern. These references lean on the pack's structure (B3 checklists) more than on B1 specific-threshold depth.

7. **Phase 3 escalation gate 6-dimension 1–10 scoring + "≥2 dims ≤2 → redesign"** is a reasonable heuristic but the cutoffs are arbitrary/unsourced — judgment scaffolding, not research. Acceptable as process, but not "depth."

### Unsourced / unverifiable numbers masquerading as depth (the anti-slop flags)

8. **⚠️ PRIMARY FLAG — the 46% env / 25% config / 29% wording failure taxonomy.** This is the single most load-bearing number in the pack: cited in SKILL.md Phase 3.1, the Anti-Skip table (2×), the Anti-Slop Rules list, failure-catalog FM-6, AND wired directly into the `hallucination-diagnosis.md` fixture `discriminative_pattern: "...|46%|25%|29%"` as a PASS marker. Its only attribution is a paper titled "Fix the Prompt is a Root Cause Fallacy" — "Industry research — cited for data points." WebSearch for that title + those statistics returns **ZERO hits**; real LLM-failure taxonomies in the literature (arXiv 2511.19933, 2506.09713) use entirely different category schemes (In/Output, Algorithm, Resource…), none producing a 46/25/29 split. This is the textbook anti-slop hazard: a precise-looking number whose specificity IS its credibility, sourced to a title that cannot be found. Because it's keyed into the eval gate, a WITH-pack agent gets rewarded for reproducing a possibly-fabricated statistic — exactly the "validation theater" QUALITY-BAR §4 warns against. RECOMMENDATION: either produce the actual source (URL + retrieval date, per principles 2026-05-15 action D) or demote the exact percentages to a qualitative claim ("most failures are env/config, not wording") and drop them from the discriminative_pattern.

9. **~23% hallucination reduction (capability declaration)** — no inline source anywhere; not even in LICENSE-ATTRIBUTION. Appears in phase1-write.md, SKILL.md, and BOTH fixture discriminative patterns. Same class as #8 (number wired into the eval gate with no traceable origin), lower blast radius. Plausible direction, unverifiable magnitude.

10. **84% → ~12% injection success rate** — attributed loosely to "industry study." Unlike #8, this one is directionally CORROBORATED by real literature (AgentDojo undefended ~84%; spotlighting/explicit-boundary defenses drop crossing rate to ~12% on gpt-5.2-class evals). So the pairing is a defensible synthesis rather than a fabrication, but the pack should cite AgentDojo / the spotlighting paper rather than "industry study."

11. **"18 test cases per research findings" / "20+ per research findings"** — the 10/5/3 split is sensible engineering but "per research findings" implies a citation that doesn't exist. Minor dpress-up.

12. **FM-1..FM-6 "measured impacts"** (-10% downstream accuracy, -13.3% RAGAS, $47K, 60% fact destruction, 14,000 complaints) — narrated as concrete incident metrics; only -10%/-13.3% are loosely attributed ("When Better Prompts Hurt", also unfindable). The dollar/complaint/percentage figures read as illustrative storytelling presented as measurement. They make the catalog vivid but should be framed as representative, not cited data.

## Fact-checks

- **VERIFIED (current docs):** budget_tokens→400 on Opus 4.7/4.8/Fable5; `thinking:{type:"adaptive"}`; effort low/medium/high/xhigh/max, Opus 4.8 default high, xhigh for coding; prefill→400; temperature/top_p/top_k→400 on 4.7+. claude.md is accurate and current as of 2026-06-13.
- **VERIFIED:** GEPA arXiv:2507.19457, ICLR 2026 Oral, ~10% avg / up to 20% over GRPO, up to 35× fewer rollouts, outperforms MIPROv2. Decision rule operationalized.
- **PARTIALLY VERIFIED:** GEPA AIME 46.6→56.6 / ARC-AGI 32→89 not independently confirmed in-search but carry a real source and consistent magnitude.
- **DIRECTIONALLY CORROBORATED:** 84%→12% injection — real literature supports the shape (AgentDojo ~84% undefended; explicit-boundary/spotlighting ~12%). Cite the actual papers.
- **UNVERIFIABLE / LIKELY UNSOURCED:** 46/25/29 failure taxonomy ("Fix the Prompt is a Root Cause Fallacy" — 0 search hits, no matching taxonomy in literature). ~23% hallucination reduction. "When Better Prompts Hurt" -10%/-13.3% (title unfindable). FM dollar/complaint figures.
- **specN = 88** (LC_ALL=en_US.UTF-8, pack-anchored) → Layer B bucket 5; ~20 are version/CHANGELOG noise but genuinely-specific load-bearing items still clear the 60 floor.

## Net

The pack's depth is real and the strongest layer (claude.md current-API rules, GEPA, cache prefix mechanics) is precisely the kind an LLM CANNOT fabricate from training — it clears the anti-slop bar. But the discriminative eval gate is partly anchored on UNSOURCED numbers (46/25/29, ~23%), which is a self-reinforcing slop risk: the gate rewards reproducing statistics that may not be real. Fix before marking accepted: source-or-soften items #8 and #9 and remove them from the fixtures' discriminative_pattern, replacing with the verified API/GEPA/cache specifics that already carry citations.
