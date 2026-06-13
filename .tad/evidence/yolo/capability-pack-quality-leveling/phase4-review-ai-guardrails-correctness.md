# Phase 4 Adversarial Review — ai-guardrails — CORRECTNESS lens

- **Pack**: `.claude/skills/ai-guardrails` (v0.1.0)
- **Reviewer lens**: correctness (factual accuracy + internal consistency + actionability + verifiable provenance)
- **Date**: 2026-06-13
- **Posture**: default skepticism; tried to REFUTE that it meets the dual-layer bar.

## meets_bar: FALSE

The pack clears Layer A (structure) and Layer B (depth) comfortably, and MOST of its
research-grounded numbers check out against primary sources. But the **correctness lens**
is specifically about factual accuracy of load-bearing claims and verifiable provenance,
and I found one P0-class numeric error plus a P1 provenance defect — both on claims that
appear in the **always-loaded SKILL.md body**, and both of exactly the version/metric-sensitive
class QUALITY-BAR §6 mandates be verified against primary docs. A load-bearing benchmark
number that contradicts its own cited canonical source does not clear the correctness bar.

---

## Findings

### P0 — InjecAgent GPT-4 ASR figures do not match the cited benchmark and are mislabeled
The pack states (SKILL.md L133 anti-skip table AND references/prompt-injection-defense.md
PI8 L137): **"InjecAgent on GPT-4 no-defense: Direct-Harm 32.2% ASR, Data-Stealing 59.7% ASR."**
Verified against the canonical InjecAgent paper (arXiv **2403.02691**, ACL 2024 Findings, Table 3):
- GPT-4 prompted, **base/no-defense**: Direct Harm **14.7%** / Data Stealing **32.7%** (overall 23.6%).
- GPT-4 prompted, **enhanced** attack setting: Direct Harm **61.0%** / Data Stealing **59.9%** (overall 47.0%).
The pack's "32.2% / 59.7%" matches NEITHER setting cleanly: 59.7% is near enhanced Data-Stealing
(59.9%), while 32.2% is near *base* Data-Stealing (32.7%) — i.e. the figures appear scrambled
across rows/settings of the table and then labeled "no-defense." PI8 uses these as "a concrete
number to hold a pipeline to," so the error is load-bearing, not decorative. This is the precise
cross-model fact-check failure class QUALITY-BAR §6 warns about (same-model loop misses metric
type / number errors).

### P0 (provenance, same finding) — InjecAgent source URL is the wrong paper
PI8's source line (references/prompt-injection-defense.md L141) cites
`https://arxiv.org/pdf/2510.08829`. The canonical InjecAgent paper is **arXiv 2403.02691**;
2510.08829 is a different Oct-2025 paper. A reader who follows the cited URL to verify the
32.2%/59.7% figures will not find them attributed as stated. Provenance is non-reproducible.

### P1 — "Lethal Trifecta" date/URL mismatch on a rule that explicitly demands verifiable provenance
The cross-cutting rule (SKILL.md L33-36) is headlined "Datable, named provenance (pin these —
the rule must be verifiable)". It dates Willison's "Lethal Trifecta" to **June 2025** (correct —
verified: simonwillison.net/2025/Jun/16/the-lethal-trifecta/, posted 16 Jun 2025) but pins the
URL to `simonwillison.net/2025/**Nov**/2/new-prompt-injection-papers/` — a different, later post,
NOT the originating June-16 artifact. The date claim and the cited URL point to different things,
on the one rule that loudly asks to be verifiable. PI2 (references) repeats the same Nov URL with
the "June 2025" attribution. Fix: cite the Jun-16 post as the origin URL.

### P2 — minor: AgentDojo "25%→8%" reduction phrasing conflates two distinct quantities
SKILL.md L133 / PI8 mixes "<25% with no defense (best agents)", "~20% targeted ASR (most models)",
and "~8% with attack-detector", then summarizes as "a 25%→8% reduction." The 25% (best-agent
no-defense ceiling) and the 8% (detector floor) are not measured on the same model population the
"~20% most models" sentence describes, so "25%→8%" is a loose composite, not a paired before/after
on one cohort. Actionable guidance survives, but the headline delta is not a single clean datapoint.
(Not independently re-verified against the AgentDojo PDF this pass — flagged as imprecise framing.)

### Positive controls (claims that ARE correct — refutation attempts that FAILED)
- **Llama Guard 4 12B**: English recall 69% / FPR 11% / F1 61%; multilingual recall 43% / FPR 3%;
  14 categories = S1–S13 MLCommons + S14 Code Interpreter Abuse — **exact match** to the official
  PurpleLlama MODEL_CARD.md (verified live). content-moderation.md is well-grounded, including the
  correct "~31% English miss-rate" derivation and the superseded-3.x "old patterns" isolation.
- **F2 (β=2) "4× mathematical weight"** (PII4): correct, non-restateable nuance of the Fβ formula
  (β²=4 in the denominator). Exactly the kind of research-landed detail an LLM won't emit unprompted.
- **Presidio** two-engine + operator table (random-salt-by-default since 2.2.361, Encrypt+Deanonymize
  round-trip): internally consistent and matches Presidio's documented behavior.
- **OWASP 2025** LLM07 System Prompt Leakage / LLM08 Vector & Embedding Weaknesses (new in 2025):
  correctly attributed; canary→LLM07 mapping is sound.
- **Spotlighting/datamarking** ASR ~50%→<3% (GPT-3.5) / ~40%→0.00% (text-davinci-003): cited to the
  MSRC blog with retrieval date; plausible and internally consistent (not independently re-fetched).

### Internal consistency / actionability (no defect found)
- Fixture discriminative gate is honest: config has `injection_defense: none` (not a blocklist),
  so the validator fires 3 findings (RULE-OF-TWO + RAW-SINK + NO-PII-DEID), and the fixture
  documents exactly "exit=1 (RULE-OF-TWO + RAW-SINK + NO-PII-DEID)" — matches the live run. No
  over-claim of a 4th BLOCKLIST-ONLY finding.
- `discriminative_pattern` markers are genuinely pack-specific (Rule of Two / sqlglot / Presidio /
  DeanonymizeEngine / F2(β=2) / LLM05-07 / Spotlighting / Llama Guard 4 / AgentDojo) — an LLM cannot
  emit these unprompted. Anti-slop ❌ list correctly excludes generic nouns.
- Rule IDs in the Rule Index match the reference files (PI1-7 in index vs PI1-8 in the ref file —
  index lists "PI1..PI7" but the ref defines PI8 too; minor index-vs-body undercount, cosmetic).
- Output-format examples, three-layer gating, and tool-quick-reference are concrete and executable.

## fact_checks
- InjecAgent GPT-4 base ASR: Direct Harm 14.7% / Data Stealing 32.7% (arXiv 2403.02691 Table 3) — pack's "32.2%/59.7% no-defense" is WRONG/mislabeled. [REFUTED pack]
- InjecAgent enhanced GPT-4 ASR: 61.0% / 59.9% — pack's 32.2% matches neither; 59.7%≈59.9% enhanced. [pack scrambled settings]
- InjecAgent canonical paper = arXiv 2403.02691, NOT the cited 2510.08829. [REFUTED pack citation]
- Willison "lethal trifecta" coined 16 Jun 2025 (simonwillison.net/2025/Jun/16/the-lethal-trifecta/) — pack's "June 2025" date CORRECT but cited URL (.../Nov/2/...) is the wrong post. [provenance defect]
- Llama Guard 4 12B: Eng 69%/11%/61%, multilingual 43%/3%, 14 cats = S1-S13 + S14 — EXACT match to official MODEL_CARD.md. [pack CORRECT]
- F2 β=2 → recall 4× weight in Fβ denominator — mathematically CORRECT. [pack CORRECT]
- OWASP 2025 LLM07/LLM08 are the new-in-2025 entries — CORRECT. [pack CORRECT]

## Structural/depth measurements (for context; not the lens, but bar-relevant)
- Layer A: A1✓(name 13ch, desc 563ch, 3rd person) A2✓(5 refs+scripts) A3✓(149 lines) A4✓(3 Steps)
  A5✓(CONSUMES/PRODUCES) A6✓(anti-skip table) A7✓(Rule Index) A8✓(fixture) A9✓(discriminative_pattern)
  A10✓(check-guardrail-config.sh) → ~10/10, clears 7/10.
- Layer B: specN=41 (UTF-8) → bucket 4; reading confirms research-landed thresholds. Clears.
- Validator `--self-test`: PASS (bad→4 findings exit1, good→exit0). Validator on fixture config: exit1, 3 findings. Eval-harness wired.

**Verdict rationale**: Structure and depth pass, but the correctness lens turns on factual
accuracy of load-bearing numeric claims and verifiable provenance. The InjecAgent ASR figures
(in the always-loaded body + PI8) contradict the canonical benchmark and are mis-cited to the
wrong paper — a P0 of the exact class QUALITY-BAR §6 mandates be caught. meets_bar=FALSE on this
lens until the InjecAgent numbers are corrected to the base-setting values (14.7%/32.7%) with the
2403.02691 citation, and the Willison URL is repinned to the Jun-16 origin post.

---

## FIX applied (validated) — 2026-06-13

Cross-model fact-checked against primary sources (arXiv 2403.02691 HTML Table 3, arXiv 2510.08829 abstract, simonwillison.net/2025/Jun/16). Edits confined to `.claude/skills/ai-guardrails/`. Validator `--self-test` re-run: PASS (bad→4 findings/exit1, clean→exit0).

1. **[correctness] P0 — InjecAgent ASR figures wrong/mislabeled** — FIXED. Verified canonical GPT-4 (gpt-4-0613) numbers from InjecAgent Table 3: base/no-defense Direct-Harm 14.7% / Data-Stealing 32.7% (aggregate 23.6%); enhanced (hacking prompt) Direct-Harm 33.3% / Data-Stealing 61.0% (aggregate 47.0%). The pack's "32.2%/59.7% no-defense" matched neither setting. Corrected both call sites: SKILL.md anti-skip table (L133) and PI8 (references/prompt-injection-defense.md L137), each now states both settings explicitly and labels them. NOTE: refuting reviewer proposed enhanced "61.0%/59.9%" — primary source confirms enhanced is DH 33.3% / DS 61.0% (not 59.9%); used the verified values.

2. **[correctness] P0 / [fact-api] P1 — InjecAgent source URL points to wrong paper** — FIXED. Confirmed arXiv 2510.08829 = "CommandSans" (a Nov-2025 defense paper that merely uses InjecAgent as a benchmark), NOT the InjecAgent benchmark. Repinned PI8 source line to https://arxiv.org/abs/2403.02691 (Zhan et al., ACL 2024 Findings; also aclanthology.org/2024.findings-acl.624), with Table 3 attribution.

3. **[correctness] P1 — Lethal Trifecta date/URL mismatch** — FIXED. Verified simonwillison.net/2025/Jun/16/the-lethal-trifecta/ is the originating post (title "The lethal trifecta for AI agents: private data, untrusted content, and external communication", dated 16 Jun 2025). Repinned both citations (SKILL.md L36 and PI2 references L45) from the .../2025/Nov/2/new-prompt-injection-papers/ later post to the Jun-16 origin post. Date claim and URL now agree.

4. **[correctness] P2 — AgentDojo "25%→8%" loose composite** — FIXED. Reworded SKILL.md anti-skip table (L133) and PI8 to stop presenting "25%→8%" as a paired before/after on one model cohort. Now states the <25% no-defense ceiling, ~20% typical, and ~8% with-detector figures are reported across different model populations; "~8% with a detector" framed as the with-detector ballpark/order-of-magnitude target, not a fixed delta. Also updated the matching anti-pattern bullet (L154).

### Cosmetic (non-blocking, fixed opportunistically)
- **Rule Index undercount** — FIXED. SKILL.md Rule Index prompt-injection row listed PI1..PI7 but the reference defines PI8; updated to PI1..PI8.

### SKIPPED — FALSE POSITIVES (refutation attempts that failed; no change)
- **Llama Guard 4 12B benchmark numbers** (Eng recall 69%/FPR 11%/F1 61%, multilingual 43%/3%, 14 cats S1–S13 + S14) — CONFIRMED correct by reviewer against official PurpleLlama MODEL_CARD; left as-is.
- **F2 (β=2) → recall 4× weight** — mathematically correct; left as-is.
- **OWASP 2025 LLM07 System-Prompt-Leakage / LLM08 Vector-Embedding-Weaknesses** — correctly attributed as new-in-2025; left as-is.
- **Presidio two-engine + random-salt-since-2.2.361 + Encrypt/Deanonymize round-trip** — internally consistent; left as-is.
- **Fixture honesty** (injection_defense:none → 3 findings RULE-OF-TWO+RAW-SINK+NO-PII-DEID, documented exit=1 set, no over-claimed 4th finding) — verified honest; left as-is.
- **discriminative_pattern markers + anti-slop ❌ list** — genuinely pack-specific; left as-is.
- **Spotlighting/datamarking ASR (PI4, ~50%→<3% GPT-3.5, ~40%→0.00% davinci-003)** — verified by reviewer against MSR arXiv 2403.14720; genuine depth; left as-is.
- **Rebuff openai_model='gpt-4o-mini'** — shown as explicit OPTIONAL override (commented `# optional`), pack does not claim it is the upstream default (which is gpt-3.5-turbo); technically accurate; left as-is.
- **Llama Guard 4 multilingual F1 written as "—"** and **"replaces both 3-8B and 3-11B-vision"** — both flagged only as low-severity labeling nits by the anti-slop reviewer, not correctness defects; out of scope for the correctness-lens refutation; left as-is.
- **DA4 latency budgets weakest-sourced** — anti-slop advisory (recommend primary URL / "illustrative" label), not a correctness defect; out of scope this pass; left as-is.
- **AgentDojo exact cut not byte-verified** — the numbers themselves were NOT contradicted (only the composite framing, fixed in #4); no figure change warranted.

### Net effect
The FALSE verdict was driven solely by the correctness-lens P0 (InjecAgent numbers + mis-citation). Both P0s + the P1 + the P2 are now fixed against primary sources; both auxiliary bars (Layer A structure, Layer B depth) already passed. Pack is ready for Gate-3 re-review.
