# Pressure-Test Rigor Evaluation — PalateBox

> Artifact: `.tad/evidence/yolo/nondev-verdict-shapes/dogfood/palatebox-rigorous.md`
> Rubric: `.claude/skills/product-thinking/references/pressure-test-rubric.md`
> Categorical rubric — scores RIGOR only, never the BUILD/PIVOT/KILL conclusion.

## Per-Dimension Bands

| # | Dimension | Band | Evidence from artifact |
|---|-----------|------|------------------------|
| D1 | Adversarial Rigor | rigorous | All 6 forcing rounds run (Demand→Future-Fit). Each round opens with an explicit "Strongest founder claim" and attacks it, not a strawman. Hard positions taken on every round, each with a verdict (ASSUMPTION / DISPROVEN). Pushes back on weak answers: R1 rejects the $5B category-size answer as forbidden demand evidence ("7 billion people need food doesn't validate your restaurant"); R2 labels the founder's "grocery-store roulette" status quo a strawman; R3 demands a named desperate persona and shows it is the best-served customer. Refuses category-level answers throughout. |
| D2 | Evidence Grounding | rigorous | Real data searched and cited in every round: named incumbents + pricing (Fuego Box, Heatonist/Hot Ones, Hot Sauce of the Month Club <$30), churn/CAC numbers (12–18%/mo, ~44–50% in 90 days, CAC $45–100, LTV:CAC 3:1), with 23 source URLs. Consistent FACT vs ASSUMPTION labeling per round and in the verdict block (9 FACTs / 5 ASSUMPTIONs). Privileges behavior over opinion: rejects "market is big" (R1), demands desperation consequence (R3), explicitly flags vendor-only quiz claims as not independent evidence (R4). |
| D3 | Fatal-Flaw Analysis | rigorous | Scans the killer list against this specific idea; names the ≤3 most relevant (F13 negative margin at scale, F3 crowded market without a wedge, F2 interest ≠ demand), each with idea-specific reasoning, plus runner-ups (F14, F5/F11). Applies the "2+ fatal flaws = KILL" rule correctly and invokes the F13 single-structural-flaw kill-on-its-own exception accurately. |
| D4 | Verdict Justification | rigorous | Named verdict (KILL) tied to the round evidence and 3-flaw count; confidence 2/10 derived from the FACT/ASSUMPTION tally with the caveat that FACTs cut against building; core unvalidated assumption named ("AI flavor-matching is a defensible wedge…"). Type-specific 2-week plan with explicit success signal (≥30 charged pre-orders at ≥$25 AND contribution ≥$12/box AND credible behavioral differentiation). Honestly notes a 2-week test can only disconfirm month-3 churn, never confirm. |
| D5 | Product-Type Adapter | rigorous | Correctly detects ecommerce/subscription, explicitly ruling out software/marketplace/content with reasons. Ecommerce data sources appear in searches (supplier/wholesale bottle cost, shipping/dimensional billing, competitor pricing, FBA-style margin math). Q4 reframed as ecommerce wedge ("minimum viable SKU you can test-sell in 30 days"). 2-week validation is ecommerce/subscription-shaped (charged pre-orders, contribution-margin sheet, matched-vs-plain cohort). Analysis is tuned to subscription unit economics, not generic. |

## Band Decision-Tree Application

Inputs: D1=rigorous, D2=rigorous, D3=rigorous, D4=rigorous, D5=rigorous.

- Rule 1 (superficial): requires D1==superficial OR ≥2 dimensions superficial. D1 is rigorous and 0 dimensions are superficial → does NOT fire.
- Rule 2 (rigorous): requires D1==rigorous AND (count rigorous ≥4) AND (count superficial ==0). D1=rigorous, rigorous count=5 (≥4), superficial count=0 → **FIRES**.

Rule 2 is the first matching rule → band = rigorous.

## Swap Test

Flipping the final verdict word (KILL → BUILD) and changing nothing else: every dimension band rests on conclusion-independent substance — six rounds actually run, named sources actually searched, the full fatal-flaw list actually scanned, confidence derived from the FACT/ASSUMPTION count, and an ecommerce-tuned validation plan. None of these scores would move if the verdict word flipped. The band reflects rigor only, not the conclusion.

Justification: All five rigor dimensions are independently rigorous — six genuine adversarial rounds against the strongest claim, real cited data with consistent FACT/ASSUMPTION discipline, an idea-specific fatal-flaw scan applying the 2+/structural rules correctly, an evidence-tied verdict with a concrete type-appropriate validation plan, and a correctly detected and applied ecommerce/subscription adapter. Rule 2 of the decision tree fires cleanly (D1 rigorous, 5/5 rigorous, 0 superficial).

band: rigorous
content_verdict: KILL
verdict: PASS

## Strengths

- The unit-economics round (R5) does the math out loud with real wholesale, shipping, churn, and CAC numbers, then derives LTV:CAC ≈ 0.4–0.9:1 — a concrete, falsifiable computation rather than a hand-wave, and it correctly identifies the reseller-margin trap (60% maker margin vs ~20% reseller contribution).
- Disciplined FACT vs ASSUMPTION labeling throughout, including the honest flag that the AI-quiz churn-reduction claims are vendor-marketing-only with no third-party outcome data — it refuses to count its own convenient evidence as proven.
- Strong adapter fit and intellectual honesty: the 2-week plan explicitly admits that the metric deciding the business (month-3 churn) cannot be confirmed in two weeks, so the test can only disconfirm — a rare, self-aware limitation statement.

## Weaknesses

- Several FACT figures (market CAGR, churn bands, CAC ranges) are asserted from single secondary sources without retrieval dates or cross-checking, so freshness/accuracy is not independently auditable from the artifact alone.
- The charitable margin math leans on assumed landed bottle cost ($4–6) and shipping ($6–8) ranges presented as near-given; these are reasonable but are themselves estimates that could swing the contribution conclusion, and they are not labeled ASSUMPTION as crisply as the demand-side claims.
- The analysis is a dogfood with no live founder, so the "strongest founder claim" framing is self-constructed; while the artifact discloses this, the adversarial pushback is against the author's own steel-man rather than a real interlocutor, which slightly limits the test's external validity (a disclosed structural limit, not a scoring fault under this rubric).

Judge: independent sub-agent; producer identity not provided.
