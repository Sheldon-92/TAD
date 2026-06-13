# Phase 4 Adversarial Review — ai-guardrails — Anti-Slop Lens

> Reviewer: subagent (Opus 4.8) | Date: 2026-06-13
> Lens: **anti-slop** — are Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM could NOT emit from training), or generic rules dressed up? Flag vague/restatable rules masquerading as depth + unsourced numbers.
> Files read: SKILL.md (149 lines) + 5 references/ + examples/ (2 fixtures) + scripts/check-guardrail-config.sh; QUALITY-BAR.md.

## Lens
anti-slop (Layer B depth / specific-threshold integrity)

## meets_bar
**true** — clears the bar on the anti-slop lens. The pack carries a high density of named, source-anchored, retrieval-dated specifics (Spotlighting ASR ~50%→<3% / ~40%→0.00%, Llama Guard 4 12B Eng recall 69%/FPR 11%/F1 61%, AgentDojo ~25%→8% with attack-detector, InjecAgent 32.2%/59.7%, F2 β=2 with 4× weight note, Presidio random-salt-since-2.2.361, OWASP 2025 LLM07/LLM08 additions). I spot-checked the four highest-fabrication-risk numbers against primary sources and all four are real. The text is honest about provenance — it explicitly tags vendor-internal vs head-to-head numbers and flags Lakera's vendor figures against the independent ~53% counter-number, which is the opposite of slop. Negative-control discipline (shallow-depth specN=0 → 1/5 FAIL) is present in QUALITY-BAR. Findings below are precision/labeling nits, not depth failures.

## Findings

1. **Spotlighting/datamarking ASR — VERIFIED genuine depth.** "datamarking ASR ~50%→<3% on GPT-3.5-Turbo, ~40%→0.00% on text-davinci-003" (prompt-injection-defense.md PI4) matches Microsoft Research arXiv 2403.14720 exactly. These are paper-table numbers an LLM cannot emit from training — textbook Layer-B specificity, correctly cited with retrieval date.

2. **Llama Guard 4 12B benchmark — VERIFIED genuine depth, one minor omission.** Eng recall 69% / FPR 11% / F1 61% and multilingual recall 43% / FPR 3% match the Meta MODEL_CARD. NIT: the pack writes multilingual F1 as "—" (omitted) when the card actually reports **51%**. Not a fabrication; an under-statement. Harmless but could be completed for full fidelity.

3. **Llama Guard 4 "replaces both" framing slightly overstated.** Pack says it "replaces both Llama Guard 3-8B and 3-11B-vision in one classifier." Meta's official wording is softer — it "combines the capabilities of" / "consolidates" the predecessors (it does not deprecate them). Defensible shorthand, but the official phrasing is "combines," not "replaces." Low-severity labeling nit.

4. **AgentDojo ASR baselines (PI8) — numbers are real benchmark figures, but the synthesis is the pack's own gloss.** "no-defense <25% → ~8% with attack-detector; ~20% baseline; Llama-4 17B ~40%" — these are genuine AgentDojo-class figures (not LLM-emittable), and PI8's core message ("a detector that doesn't move the ASR number is theater") is exactly the anti-slop posture the QUALITY-BAR rewards. I could not byte-verify the exact ~25%→8% / Llama-4-17B-40% cut against the source PDF in this session (PDF text-layer extraction failed for the OpenReview file), so the *specific pairing* is asserted-but-not-independently-confirmed here. Source URL + retrieval date are present, which satisfies auditability; flag for Gate-3 re-verification per QUALITY-BAR §5.

5. **InjecAgent 32.2% / 59.7% — VERIFIED present in source, but setting label is imprecise.** Both 32.2 and 59.7 literally appear in arXiv 2403.02691 (per-category appendix tables; pdftotext confirmed lines 1568 and 1984). So NOT fabricated. HOWEVER: the paper's *headline* GPT-4 ASR is **24% base / 47% enhanced (overall)**; 32.2/59.7 are per-category (Direct-Harm vs Data-Stealing) cuts, and the pack does not state which setting (base vs enhanced) they come from. This is a precision gap, not slop — the numbers are genuine and an LLM could not emit them, which is the anti-slop test. Recommend annotating "(no-defense, per-category)" and reconciling with the 24%/47% overall headline to pre-empt a cross-model reviewer flagging an apparent contradiction.

6. **F2 (β=2) rule carries real mathematical depth, not a restatement.** PII4 doesn't just say "prefer recall" (which would be LLM-restatable slop); it gives the F_β formula AND the non-obvious correction that β=2 gives recall **4× the weight** (β²), not 2×. That nuance is a genuine anti-slop marker — most LLM output gets this wrong.

7. **Presidio operator depth is genuine.** "Hash uses a random salt by default since 2.2.361 → supply a consistent salt for stable join keys" (PII2) is a version-specific, gotcha-level fact an LLM would not reliably emit. Strong Layer-B signal. Same for "result_type→output_type renamed pre-v1.0, result_type removed" (OV4) — a real API-migration detail.

8. **A few rules ARE generic — but they are honestly framed as architecture, not dressed up as research depth.** PI1 (all external data untrusted), OV1 (LLM05 downstream-vuln table), DA2 (front the LLM with a gateway), DA3 (token-based 429 rate limiting) are restatable-by-an-LLM principles. They do NOT masquerade as depth: they carry `determinismLevel: deterministic` / "architectural decision" labels rather than fake thresholds. This is the correct handling — they are the connective scaffolding, and the pack's specificity load is carried by PI4/PI8/CM1/PII2/PII4/DA4. No slop violation; just noting they are the low-specificity tier.

9. **DA4 latency budgets are mostly internally-derived, partly source-thin.** "input ≤50ms, hardening <2ms, output 100–400ms, tool-gating 5–15ms" and the "GA Guard Core ~29ms / Lite ~16ms / Thinking ~650ms, 256k context" lineup are presented as specific numbers. The GA Guard figures cite findings.md [23] but no external URL/retrieval date (unlike the Spotlighting/LlamaGuard/AgentDojo rows which DO have URLs). These are the *least* independently-auditable numbers in the pack. Not flagged as fabricated, but they are the weakest-sourced specifics — recommend a primary URL or a downgrade to "illustrative budget" labeling.

10. **No unsourced bare numbers masquerading as benchmarks.** Every headline benchmark number (Spotlighting, Llama Guard 4, AgentDojo, InjecAgent, OWASP 2025) has a source URL + 2026-06-13 retrieval date inline, satisfying the YOLO-audit-2026-05-15 action item ("add source URLs + retrieval dates to research findings"). The only numbers lacking external URLs are the architecture/latency budgets (DA4) and the internal findings.md `[n]` citations — those are derived/secondary, not presented as external benchmarks.

## fact_checks
- **Spotlighting datamarking ASR (~50%→<3% GPT-3.5, ~40%→0.00% text-davinci-003)** — CONFIRMED against Microsoft Research arXiv 2403.14720 (web search of primary paper). Accurate.
- **Meta "Agents Rule of Two" (Nov 2025, A/B/C triad, Chromium-inspired, lethal-trifecta-derived)** — CONFIRMED against ai.meta.com/blog/practical-ai-agent-security + osohq writeup. Date, structure, and Willison/Chromium attribution all accurate.
- **Llama Guard 4 12B: Eng recall 69% / FPR 11% / F1 61%; multilingual recall 43% / FPR 3%; 14 categories S1-S14** — CONFIRMED against Meta PurpleLlama MODEL_CARD (WebFetch). Accurate. NIT: multilingual F1 is 51% in the card; pack writes "—". NIT: card says "combines capabilities," pack says "replaces."
- **InjecAgent GPT-4 Direct-Harm 32.2% / Data-Stealing 59.7% ASR** — values CONFIRMED present in arXiv 2403.02691 (pdftotext: 59.7 @ line 1568, 32.2 @ line 1984, per-category tables). NOT fabricated. CAVEAT: paper's headline GPT-4 overall ASR is 24% base / 47% enhanced; the pack does not label which setting/granularity 32.2/59.7 are. Precision gap, not a fabrication.
- **AgentDojo no-defense <25% → ~8% with attack-detector; Llama-4 17B ~40%** — source URL present (openreview m1YYAQjO3w) but PDF text-layer extraction failed this session; exact cut NOT independently byte-verified. Plausible/genuine benchmark figures, flagged for Gate-3 re-verification.
- **F2 β=2 gives recall 4× weight (β² term)** — mathematically CONFIRMED correct (F_β formula). Genuine non-trivial depth.
- **Validator self-test** — RAN: `check-guardrail-config.sh --self-test` → bad config trips 4 findings (RULE-OF-TWO/BLOCKLIST-ONLY/RAW-SINK/NO-PII-DEID, exit 1), clean config exit 0. PASS. Deterministic gate is real, not punted to Claude.
- **Structure sanity** — SKILL body 149 lines (< 500 ✓), 5 references one-level-deep, fixture has `discriminative_pattern` + `min_discriminative: 4` (eval-ready ✓).
