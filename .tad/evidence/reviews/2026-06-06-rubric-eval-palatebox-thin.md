# Pressure-Test Rigor Evaluation

## Per-Dimension Bands

| # | Dimension | Band | Evidence from artifact |
|---|-----------|------|------------------------|
| D1 | Adversarial Rigor | superficial | No forcing rounds run at all (no Demand Reality / Status Quo / Desperate Specificity / Narrowest Wedge / Observation / Future-Fit). The whole piece is a single encouraging pass: "really promising idea," "a lot going for it," "I'd be surprised if it didn't take off." Zero pushback; every implicit claim is accepted at face value. These are the exact sycophantic phrasings the anti-sycophancy rules forbid. ≤2 rounds and no genuine adversarial confrontation → superficial. |
| D2 | Evidence Grounding | superficial | 0 real searches. All claims rest on opinion and trend hand-waving: "subscription boxes are super popular," "hot sauce is having a huge moment," "margins ... are usually pretty good." No named Reddit/HN threads, no competitor names or pricing, no Product Hunt counts, no real persona evidence. No FACT vs ASSUMPTION labeling anywhere. Stated/imagined interest ("foodies would absolutely love it," "I'd be surprised") is treated as demand — the precise failure the skill forbids. |
| D3 | Fatal-Flaw Analysis | superficial | No fatal-flaw scan whatsoever. The 15 universal killers are never invoked. Obvious candidate flaws for a hot-sauce subscription box (CAC vs subscription LTV / churn, unit economics on physical goods + shipping, "vitamin not painkiller," no real differentiation behind an "AI quiz") are not even mentioned, let alone analyzed. The "2+ flaws = KILL" rule is absent. Flaws are not waved away explicitly — they are simply never looked for. |
| D4 | Verdict Justification | superficial | No named BUILD/PIVOT/KILL verdict. The conclusion is the vague "It could definitely work — you should give it a try," exactly the hand-wavy phrasing the skill replaces. No confidence score, no FACT/ASSUMPTION tally, no named core unvalidated assumption, and no 2-week validation plan with a success signal. |
| D5 | Product-Type Adapter Use | superficial | No product-type detection. This is an ecommerce / physical-subscription product, but none of the ecommerce adapter specifics appear: no Amazon reviews/BSR/Keepa, no Helium10/Jungle Scout keyword volume, no FBA/shipping fee math, no Alibaba supplier cost, no "minimum viable SKU / minimum order test-sold" wedge. The analysis is fully generic boilerplate with no adapter influence. |

## Band Decision-Tree Application

Inputs: D1 = superficial, D2 = superficial, D3 = superficial, D4 = superficial, D5 = superficial.

Rule 1 fires (first matching rule wins): `IF D1 == superficial OR (count of superficial dimensions) >= 2`. D1 is superficial AND all 5 dimensions are superficial — rule 1 fires on both clauses. Band = superficial → verdict FAIL.

## Swap Test

Flipping the artifact's implicit conclusion from a soft BUILD ("it could work, give it a try") to a KILL, and changing nothing else, would not move any per-dimension band or the aggregate. The bands reflect the absence of rounds, searches, fatal-flaw scan, named verdict, and adapter — all conclusion-neutral. The band reflects rigor only.

Band justification: every one of the five rigor dimensions is superficial — no adversarial rounds, no real data searches, no fatal-flaw scan, no named/justified verdict, and no product-type adapter — so the load-bearing D1 alone, and the 5-of-5 superficial count, both force the lowest band.

band: superficial
content_verdict: BUILD

verdict: FAIL

## Strengths and Weaknesses

Top-3 strengths: The prose is clear and readable. It does surface a couple of plausible go-to-market angles (social/unboxing shareability, premium pricing perception). It correctly identifies that subscriptions are a familiar payment model for consumers. (Note: these are content observations, not rigor — none lift any dimension off superficial.)

Top-3 weaknesses: There is no adversarial interrogation at all — it is a single sycophantic pass that takes a hard position only in favor of the idea. There is zero evidence grounding: no searches, no named sources, no FACT/ASSUMPTION discipline, and stated interest is mistaken for demand. There is no fatal-flaw scan and no named verdict with a confidence score or a concrete 2-week validation plan, so the conclusion ("give it a try") is asserted rather than justified.

Judge: independent sub-agent; producer identity not provided.
