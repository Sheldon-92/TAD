# Phase 4 Adversarial Review — ai-evaluation pack (anti-slop lens)

> Reviewer: Blake subagent | Date: 2026-06-13
> Lens: anti-slop — are Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM
> could NOT emit from training), or generic rules dressed up? Flag vague-restatable rules and unsourced numbers.
> Files read: SKILL.md + all 7 references/ + scripts/eval-config-lint.sh + examples/llm-judge-ab-eval.md + QUALITY-BAR.md
> Default: skepticism. meets_bar=true only if it genuinely clears the anti-slop bar.

## lens
anti-slop (Layer B depth / research-grounding genuineness)

## meets_bar
**true** — but conditionally. The upgraded batch (SKILL cross-cutting rule + ab-testing-rules.md
+ adversarial-rules.md + benchmark-rules.md B4/B7/B8 + human-eval-protocol.md HE6) clears the
0/2/5 anti-slop bar: it carries multiple specifics a frontier LLM could NOT restate without the
source (G-Eval 0.514 / arXiv:2303.16634, MT-Bench >80% ceiling / arXiv:2306.05685, deepteam v1.0.4
23+5 attack split, position bias ≤0.04 reframe, promptfoo un-thresholded grader.pass no-op). These
are real, verifiable, and load-bearing. meets_bar holds DESPITE 3 unsourced-number flags below,
because none of the flagged numbers is the pack's primary anchor and the genuine anchors dominate.
If the bar were "zero unsourced numbers" it would FAIL on P1 items; on the operative 0/2/5 depth
anchor it lands in the 5 band.

## findings

### GENUINELY research-grounded (5-band — LLM cannot emit from training, properly sourced)
- **G-Eval Spearman 0.514 on summarization, drops to 0.500 without CoT, arXiv:2303.16634** (human-eval-protocol.md HE6). FACT-CHECKED EXACT against the paper. This is the single best anti-slop anchor in the pack: a precise two-significant-figure number tied to a named paper, used correctly ("be suspicious if your judge reports ≥0.80 on open NLG — that exceeds published SOTA"). Cannot be restated by an LLM without the source.
- **MT-Bench >80% judge-human agreement ceiling + three named failure modes (position, verbosity, self-enhancement), arXiv:2306.05685** (SKILL cross-cutting rule). Correct paper, correct claim, correctly framed as a CEILING not a floor ("do not claim your judge agrees with humans more than two humans agree with each other"). Non-restatable specificity.
- **deepteam v1.0.4: 23 single-turn + 5 multi-turn attack methods, 50+ vuln types, released 2025-11-12, frameworks OWASP LLM 2025 + OWASP Agents 2026 + NIST AI RMF + MITRE ATLAS + BeaverTails + Aegis** (adversarial-rules.md ADV1/ADV2). Version-pinned tool facts an LLM cannot fabricate accurately. The named individual attacks (Adversarial Poetry, Emotional Manipulation, Bad Likert Judge, Crescendo) are real deepteam methods — concrete, not generic.
- **promptfoo model-graded contract: assertion passes only when BOTH `grader.pass===true` AND `score>=threshold`; with no threshold it passes on grader.pass alone, so `{pass:true, score:0}` silently passes** (benchmark-rules.md B4). Specific tool-behavior fact that produces a real, non-obvious failure mode ("un-thresholded model-graded assertion = no-op gate"). This is the kind of API-shape knowledge that distinguishes a pack from a generic caution.
- **Position bias ≤0.04 on controlled pairs is now negligible; the operative concern is position SENSITIVITY (verdict-reversal rate on A/B swap)** (ab-testing-rules.md AB8). This actively RETIRES the obsolete generic advice ("beware position bias") and replaces it with an actionable dual-pass procedure (win-in-both-or-tie). Strong anti-slop signal — the fixture's Anti-Slop Check even lists "beware position bias" as a ❌ non-discriminative marker. Good self-awareness.
- **Krippendorff α decision bands 0.8 (reliable) / 0.667 (tentative floor)** + "prefer α over Cohen's κ when >2 raters OR missing labels" (human-eval-protocol.md HE2). These are the real conventional Krippendorff cut-points from the content-analysis methodology literature; the κ-vs-α applicability rule is a correct, non-trivial methodological distinction.
- **AB2 statistical trio: paired McNemar (continuity-corrected) for binary win/loss + bootstrap 95% CI + effect size; "raw win-count is not a result"** (ab-testing-rules.md AB2). The McNemar-for-paired-binary mapping is statistically correct and specific (not "use statistics"). The data-type→test table (McNemar / paired-t / two-proportion z / Wilson CI) is operationalized, not generic.

### MID-grade (3-4 band — partly specific, defensible but uncited in-pack)
- **ICC(2,1) > 0.92 (single evaluator) / ICC(2,K) > 0.97 (panel)** (human-eval-protocol.md HE2). Initially suspected as fabricated (the *textbook* ICC bands are 0.5/0.75/0.9). FACT-CHECK: 0.92 DOES appear in the LLM-eval literature as an "excellent reliability" benchmark (MDPI narrative-coherence "ICC > 0.92"; student-writing grading "ICC 0.92, 95% CI 0.89-0.94"). So it is research-grounded — but the pack cites NO source for it, unlike the G-Eval/MT-Bench anchors. The 0.97 panel figure is plausible (Spearman-Brown lift on K raters) but also uncited. Defensible, not fabricated; would be stronger with a citation.
- **Wilson CI half-widths n=20→±15-20pp / n=100→±7-9.5pp / n=550→±4-5pp** (ab-testing-rules.md AB1). These are computable from the Wilson formula (so legitimately derivable, not pulled from air) and n≥550 matches the internal QUALITY-BAR specN signal. Borderline-restatable by a strong LLM that knows the Wilson interval, but the specific n=550→±4-5pp anchor is a real design number. Net: acceptable depth.

### UNSOURCED NUMBERS (flag — masquerade risk)
- **"Self-enhancement bias is 10-15% documented" / "LLMs rate their own outputs 10-15% more favorably"** appears THREE times (SKILL anti-skip table, ab-testing AB3, fixture). MT-Bench documents self-enhancement bias *qualitatively*; the specific **10-15% magnitude carries NO citation** anywhere in the pack or QUALITY-BAR sources. This is the highest masquerade risk: a precise-looking percentage presented as "documented" with no carrier. Either cite the source or soften to "documented (magnitude varies by task)."
- **"State-of-the-art pipelines achieve 0.86" Spearman** (human-eval-protocol.md HE3). Unsourced, AND in surface tension with the same file's HE6 ("~0.5 is the realistic SOTA ceiling for open NLG"). HE6 partly reconciles this ("0.80 bridge is achievable for constrained/anchored dimensions"), but the bare 0.86 number has no carrier and reads as a confidence-inflating figure. Flag.
- **"Deterministic checks catch 40-60% of failures at zero cost"** (pipeline-rules.md PL1) — NOTE: pipeline-rules.md is a NON-upgraded May-15 file, so outside this batch's scope, but the 40-60% is an uncited round-number range typical of LLM-emittable filler. Mentioned for completeness; not counted against the upgraded batch.

### Generic-restatable content still present (not "dressed up", but thin)
- The 3 NON-upgraded references (eval-framework-workflow.md, pipeline-rules.md, regression-rules.md — all dated May 15, untouched) are noticeably shallower than the 4 upgraded ones. Examples an LLM CAN restate without research: regression-rules R6 "cost increase >20% = regression / latency >50% = regression" (round-number thresholds, no source), pipeline PL3 cost-budget arithmetic (generic), EF1 "use specific metric names not vague labels" (good advice but restatable). These drag the pack's *average* depth down even though the upgraded subset is strong. The upgrade was a partial pass, not a full-pack pass — worth flagging for whoever scores Layer B aggregate.
- benchmark-rules.md B1/B3/B6 are mostly tool-selection tables and "outcomes over steps" — useful but largely restatable; the depth in benchmark-rules concentrates in B4 (promptfoo grader contract), B7 (mocks hide SDK shape drift), B8 (Pass@k vs Pass^k). The pack's depth is unevenly distributed.

### Validation infrastructure (supports anti-slop, not theater)
- examples/llm-judge-ab-eval.md has a genuinely DISCRIMINATIVE pattern: `discriminative_pattern` excludes severity tags and generic stats, includes only pack-specific markers (self-enhancement bias, McNemar, dual-pass, Spearman 0.514). The fixture's own Anti-Slop Check explicitly lists ❌ non-discriminative markers ("use more test cases", "beware position bias", "make sure it's accurate") — this is exactly the right self-discipline and is evidence the authors understood the anti-slop bar.
- scripts/eval-config-lint.sh is deterministic (grep/sed/awk, no npm/pip), and its 4 checks map to load-bearing rules (judge==generator family, un-thresholded grader, <5 tests, no --repeat). It is a real smoke alarm, not decoration. Minor: the family-collision check (USES_LLM_JUDGE && FAMILY_COUNT<=1) will false-positive on a config that names one family but routes judging to a non-LLM grader, and grep `provider:` is broad — acceptable for a P0 smoke alarm but not precise.

## fact_checks
- G-Eval Spearman 0.514 on summarization (arXiv:2303.16634): CONFIRMED EXACT — paper abstract states GPT-4 G-Eval achieves Spearman 0.514 with humans on summarization, SOTA at publication. Source: https://arxiv.org/abs/2303.16634
- MT-Bench three judge failure modes + >80% / ~human-level agreement (arXiv:2306.05685): CONSISTENT with the MT-Bench paper (position/verbosity/self-enhancement bias named; GPT-4 judge reaches ~80%+ agreement matching inter-human). Source as cited in pack.
- ICC(2,1) > 0.92 as an "excellent reliability" benchmark in LLM-eval: CONFIRMED present in literature (MDPI narrative-coherence "ICC > 0.92"; arXiv student-writing grading "ICC 0.92, CI 0.89-0.94") — real, but pack cites no source. Source: https://www.mdpi.com/2079-9292/14/13/2735
- Self-enhancement bias "10-15%": NOT VERIFIED — no source in pack; MT-Bench documents the bias qualitatively, not at this magnitude. FLAG as unsourced.
- HE3 "SOTA pipelines achieve 0.86" Spearman: NOT VERIFIED — no source; in tension with HE6's ~0.5 ceiling for open NLG (partly reconciled by the constrained-dimension carve-out). FLAG.
- deepteam v1.0.4 (23 single + 5 multi-turn, released 2025-11-12): version-specific tool fact; consistent with the pack's internal note in QUALITY-BAR and not restatable from training — accepted as research-grounded (not independently re-fetched this session).

## Recommendation
Accept the upgraded batch for the anti-slop lens. Two cheap fixes before sign-off:
1. Cite or soften the "10-15% self-enhancement bias" figure (appears 3x — highest masquerade risk).
2. Cite the HE3 "0.86 SOTA" Spearman or remove it (tension with HE6).
Optional: cite the ICC>0.92 source; complete the upgrade on the 3 stale May-15 references so the
pack's AVERAGE depth matches the upgraded subset (current upgrade is partial, depth is uneven).
