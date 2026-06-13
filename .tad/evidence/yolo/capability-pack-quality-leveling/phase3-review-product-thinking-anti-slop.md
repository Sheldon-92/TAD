# Phase 3 Review — product-thinking — Anti-Slop Lens

> Reviewer: adversarial subagent | Date: 2026-06-13
> Lens: anti-slop (are Layer B "specifics" genuinely research-grounded, or generic rules dressed up?)

## Lens

Anti-slop: a rule clears the bar only if it carries a number/threshold a frontier LLM could NOT reliably emit from training (operationalized 0/2/5 anchor, QUALITY-BAR §2.1). Vague rules dressed as depth, restatable platitudes, and unsourced numbers all FAIL.

## meets_bar: TRUE (with two scoped reservations)

The upgraded core (SKILL.md Quick Rule Index, fatal-flaws.md, software/hardware/marketplace/content adapters, pressure-test PMF gate) genuinely clears the anti-slop bar. Numbers are real, sourced with URL + retrieval date, and load-bearing (wired into Q4/Step7/define). Independent live fact-checks confirmed accuracy on every checkable headline figure. Reservations are about scope (2 stale adapters) and a reproducibility nit in the QUALITY-BAR specN command — neither sinks the pack on this lens.

## Findings

1. GENUINELY RESEARCH-GROUNDED (not LLM-emittable as precise rules): The SaaS unit-economics block (LTV:CAC median 3.6:1 Benchmarkit 2025; CAC payback median 6.8mo across 14,500+ SaaS, B2C 4.2 / B2B 8.6; opt-in trial 8-18% vs opt-out 31-49%; freemium 1-5% broad / 5-15% targeted; Rule-of-40 SaaS median ~12% Q1 2025) is exactly the kind of precise, source-pinned numeric set an LLM cannot reliably reproduce. These are the strongest Layer B content in the pack.

2. CB Insights prior is correctly framed AND accurate: "70% ran out of capital = final symptom; 43% poor PMF = #1 controllable cause; timing ~29%, unit economics ~19%." Live check confirmed the exact figures (CB Insights 2024 update). Crucially it does NOT slop the lazy "90% of startups fail" — it cites 431 post-mortems (385 with identifiable reason). This is depth, not dressing.

3. Sean Ellis PMF gate (≥40% "very disappointed"; 10-30% = not-yet-PMF) verified accurate and is wired as a literal decision rule in pressure-test Step 1 + fatal-flaws F2 + Quick Rule Index. It explicitly replaces a hand-picked heuristic (">100 waitlist signups") — i.e. the upgrade deliberately swapped a restatable number for a research-named one. Good anti-slop hygiene.

4. Mom Test commitment-currency (time/reputation/money) operationalizes FACT vs ASSUMPTION. This is a *named framework with an operational test*, not a generic "validate demand" platitude — clears the bar as a judgment rule even though it is not numeric.

5. Marketplace take-rate block (product 5-15%, service 15-30%, default 10-20%; Airbnb ~13-15%, Uber ~20-28%, Amazon 8-15%) verified against live sources and correctly replaces an empty `[take rate: %]` placeholder. Wired into F16 as a numeric cold-start check. Genuine depth.

6. Kickstarter block (~42% overall / 41.98% Jan 2025; Open Calls ~80%) — both numbers independently verified live (Statista + Kickstarter's own Open Call recap). The "Open Calls ~80% = curation roughly doubles odds" framing is a non-obvious, sourced insight, not a platitude.

7. RESERVATION A (scope gap, not slop): ecommerce.md and service.md were NOT upgraded (file dates May 15 vs Jun 13 for the other four). They carry ZERO research-grounded numeric benchmark block. Their "specifics" (">100 reviews", "70%+ sell-through in 30 days", "5 manual clients", "10-50 units") are operational-rule-of-thumb / restatable — they sit in the 0-2 band the QUALITY-BAR flags. Two of six adapters are still generic on the depth axis. The pack as a whole clears the bar because the cross-cutting depth (fatal-flaws + SKILL index + 4 adapters) applies to ALL product types; but ecommerce/service founders get thinner Layer B than software/marketplace founders. Flag for completion, not a blocker.

8. RESERVATION B (reproducibility, affects scoring not content): The QUALITY-BAR specN command returns 0 on this pack under macOS default locale because the alternation contains multibyte `≥`/`≤`/`×` and grep needs `LC_ALL=en_US.UTF-8` to match them. Re-run with UTF-8 locale → specN = 32 (Layer B bucket 3 per the 25-39 band). Without the locale fix a grader would wrongly score this pack specN=0 = bucket 1. This is a QUALITY-BAR §2.3 script defect surfaced by this pack, not a product-thinking defect — but it will mis-rank the pack if not caught.

9. NO unsourced load-bearing numbers found. Every numeric benchmark block carries a source URL + "retrieved 2026-06-13" (19 retrieval-date stamps, 9 distinct external source URLs). The only bare-number lines are inside example question-prompts ("how many products have >100 reviews") which are elicitation scaffolding, not asserted facts. Clean on the "unsourced numbers" sub-lens.

10. Confidence bands (6 FACT→9-10, 4-5→7-8, 2-3→4-6, 0-1→1-3) and verdict gate (BUILD conf≥7 & 0 fatal; 2+ fatal=KILL) are consistent between SKILL.md Quick Rule Index, pressure-test Step 7, and fatal-flaws Severity Guide — no drift. These thresholds are internal-design conventions (not claimed as research-grounded), correctly NOT dressed up with a fake citation.

## Fact Checks

- CB Insights 70%/43%/29%/19% — VERIFIED accurate (live, cbinsights.com 2024 update). Source cited in pack.
- Sean Ellis ≥40% "very disappointed", <25-30% struggle band — VERIFIED accurate (live). Source cited.
- Kickstarter ~42% overall (41.98% Jan 2025) — VERIFIED (Statista). Source cited.
- Kickstarter Open Calls ~80% — VERIFIED (Kickstarter Q1 2025 Open Call recap). Source cited.
- Marketplace take rates: Uber ~20-28%, Amazon ~8-15%/~10% avg, Airbnb ~13-20% — VERIFIED in range (sharetribe + corroborating sources). Pack's Airbnb 13-15% is at low end of the cited 13-20% range; acceptable, not wrong.
- SaaS LTV:CAC / CAC-payback / trial / freemium bands — NOT independently re-verified live this session (4 distinct sources cited with retrieval dates; figures are internally consistent and plausible). Recommend Phase-2 cross-model verify per QUALITY-BAR §6 before marking accepted.
- specN recompute: 0 under default locale, 32 under LC_ALL=en_US.UTF-8 (bucket 3). QUALITY-BAR §2.3 command needs a locale guard.
