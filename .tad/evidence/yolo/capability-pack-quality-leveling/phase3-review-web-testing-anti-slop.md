# Phase 3 Review — web-testing pack (anti-slop lens)

**Reviewer**: adversarial subagent | **Date**: 2026-06-13 | **Model**: Opus 4.8 (1M)
**Lens**: anti-slop — are Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM could NOT emit from training), or generic rules dressed up? Flag vague/restatable rules masquerading as depth + unsourced numbers.

## Verdict

**meets_bar = true** (clears the anti-slop lens, but with material fact-check corrections required before "accepted").

specN (counted sub-dimension, re-run on this tree) = **54** → Layer B bucket **4/5** (40-59). This matches the rubric's depth expectation; the pack is genuinely above the 0-2 "restatable" band. The depth is real but a handful of headline numbers are misattributed/fabricated and must be fixed.

## Findings

### Genuinely research-grounded (clears the bar — LLM could NOT emit these cold)
- **Stryker covered-code score split** (U7): `mutationScore(covered) = detected/(detected+survived)` vs all-mutants, used to triage NoCoverage vs weak-assertion. This is a real, specific Stryker metric distinction + an actionable decision rule. Not restatable.
- **WCAG 2.2 operational specifics** (X9): target-size SC 2.5.8 = 24x24 CSS px + 24px-circle non-intersection rule is AUTOMATABLE via axe `target-size`; focus-appearance SC 2.4.13 = >=2px perimeter + >=3:1 state contrast is MANUAL; SC 4.1.1 Parsing REMOVED in 2.2. Verified against W3C — correct, and exactly the "which-one-can-my-tool-enforce" judgment a base LLM blurs.
- **axe `wcag22aa` tag gotcha** (X2/X9): without the tag axe silently skips target-size. Concrete failure mode + fix; pin axe-core >=4.5/4.12.x. Verified (Deque blog).
- **k6 exit code 99 on threshold breach + abortOnFail 60s Grafana-Cloud lag** (P3): verified against k6 exitcodes pkg + docs. The 60s-cloud-lag caveat is a real, non-obvious detail.
- **Playwright Test Agents Planner/Generator/Healer (v1.56) + browser.bind() (v1.59)** (G1/G2): verified — v1.56 Oct 2025, three-agent loop, init-agents with Claude Code support. Correct and current.
- **CWV thresholds + 75th-pct CrUX framing + INP-replaced-FID-March-2024** (P1): verified against web.dev (LCP 2.5s/INP 200ms/CLS 0.1 unchanged) and INP transition (Mar 12 2024). The "reject LCP-tightened-to-2.0s" defensive note is a genuine anti-misinformation guard.

### Borderline (named but thinner than the depth claim)
- **pair-testing 4D Protocol** (T1-T8) is mostly process scaffolding (internal TAD convention), not external-research-grounded depth. "5-15 E2E tests / 3-5 critical flows" is a reasonable heuristic but is restatable. This reference is the weakest on the anti-slop axis — it survives because the rest of the pack carries the depth.
- **api-testing-rules.md** has NO Sources section and no retrieval dates (every other reference does). Its content (Pact CDC, Schemathesis, P95<500/err<1%, auth matrix, 400/401/403/404/429/500) is sound but largely restatable senior-engineer common knowledge — Layer-B-thin and unsourced. It dilutes the pack's "research-grounded" claim.

### UNSOURCED / MISATTRIBUTED NUMBERS (must fix before "accepted")
1. **"break: 50" framed as Stryker's "documented default" is FALSE.** (U5 L107, SKILL Tool Quick Ref, mutation-gate.sh). Stryker's actual defaults are `high: 80, low: 60, break: null` (build never fails by default). 80/60 are real defaults; **50 is NOT a documented default** — it's a reasonable project floor but the text explicitly says "These are the *documented* defaults — they are not arbitrary," which is wrong for break:50. Fix: present 50 as a recommended break floor, not a Stryker default.
2. **"n=550 audits" (Deque) is fabricated/misattributed.** Appears 3x (SKILL L111, accessibility X1/X3, fixture). The 57%-by-volume figure IS real and correctly from Deque, but the cited Deque coverage study used **~2,000 audits / ~13,000 pages / ~300,000 issues**, NOT n=550. The "30-50%" range is a generic industry figure. The precise "n=550" has no matching source in the cited Deque material — classic dressed-up-precision. Fix: drop n=550 or cite the real WebAIM Million / Deque sample.
3. **"~1.28% of working time" (flaky tests) does not appear on the cited source.** (S5 L134, fixture, example frontmatter). The cited testdino page gives Google "2%", "$120k/yr per 50-dev", "8% of QA time" — but NOT 1.28%. The 1.28% is a suspiciously precise headline with no carrier in the source. Fix: replace with the 2% figure that the source actually supports, or find the real origin.
4. **"8% of dev time" mislabels the source's "8% of QA time."** (S5). Minor but real category swap.
5. **"trust-erosion mechanism (Microsoft) — developers significantly LESS likely to investigate the next real failure"** is attributed to Microsoft but the cited source does not contain that as a Microsoft finding (it has Microsoft's $1.14M cost + 18% reduction via fix/remove policy, not the causal trust-erosion claim). Fix: attribute the trust-erosion causal claim to its real source or downgrade to pack assertion.

Note: 58% monthly / 79% moderate-serious / 25%-fewer-reruns / $120k-per-50-dev ARE confirmed on the cited page — so the reference is ~half-verified, half-embellished.

## Why meets_bar = true despite the fixes
The pack is NOT generic rules dressed up. The core depth (Stryker covered-score triage, WCAG 2.2 automatable-vs-manual split, axe tag gotcha, k6 exit codes + cloud-lag, Playwright agent API versions, CWV anti-misinformation guards) carries genuine non-restatable, source-cited, version-pinned content with retrieval dates. specN=54 (bucket 4) is earned, not inflated. The failures are localized to ~5 embellished/misattributed stat numbers (Stryker break-default, Deque n=550, flaky 1.28%/8%/Microsoft-trust) — these are anti-slop violations of the *unsourced-number* kind and MUST be corrected, but they do not pull the pack below the bar. The api-testing + pair-testing references are the weak Layer-B tail.

## fact_checks
- Stryker defaults: high 80 / low 60 / break **null** (NOT 50) — stryker-mutator.io configuration docs. PACK CLAIM "break:50 is documented default" = FALSE.
- Deque automated a11y = 57% by volume — TRUE; but sample = ~2,000 audits/13,000 pages, NOT "n=550" — PACK n=550 = UNSOURCED.
- Flaky test: 58% monthly, 79% mod-serious, $120k/50-dev, 25% fewer reruns — CONFIRMED on testdino. "1.28% working time" = NOT on source. "8% dev time" = source says "8% QA time". Microsoft trust-erosion causal claim = NOT in cited source.
- k6 exit code 99 on threshold breach + abortOnFail (60s cloud lag) — CONFIRMED.
- Playwright Test Agents v1.56 (Planner/Generator/Healer), browser.bind v1.59 — CONFIRMED.
- CWV LCP 2.5s/INP 200ms/CLS 0.1 @ 75th pct, INP replaced FID Mar 12 2024 — CONFIRMED.
- WCAG 2.2 target-size 24px (automatable), focus-appearance manual, 4.1.1 Parsing removed — CONFIRMED (W3C).
