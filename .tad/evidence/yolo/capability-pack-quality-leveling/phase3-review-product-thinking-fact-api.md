# Phase 3 Review — product-thinking — Lens: fact-api

- **Lens**: fact-api (factual / API / version-sensitive correctness)
- **Reviewer**: Blake subagent (Opus 4.8 1M)
- **Date**: 2026-06-13
- **meets_bar**: true

---

## Verdict

**meets_bar = true.** Through the fact-api lens, the product-thinking pack genuinely clears the bar. It is unusually fact-disciplined: every load-bearing quantitative claim carries a source URL + retrieval date (2026-06-13), and on independent WebSearch verification against current primary documentation, **every headline number checks out**. No wrong tool names, no deprecated/renamed APIs, no wrong metric types, no fabricated constants. The few residual items are unverifiable-precision sub-figures, not errors.

This lens hunts for fact/API errors (the failure class that same-model loops miss — per QUALITY-BAR §6). I found none of consequence.

---

## Findings

1. **NO factual error found in any of the 9 SaaS / marketplace / failure benchmarks.** This is the rare case where adversarial fact-checking confirms rather than refutes. The pack's authors did the WebSearch-before-asserting discipline that QUALITY-BAR §6 demands, and it shows.

2. **The "API" surface of this pack is tooling references + benchmarks, not code SDKs.** Named tools (WebSearch, last30days, Keepa API, Amazon SP-API, Bright Data, Helium 10 / Jungle Scout, aso-skills/Appeeky, deanpeters/Product-Manager-Skills) are all real, correctly described, and correctly flagged ZERO_CONFIG vs NEEDS_SETUP. No invented endpoints or renamed APIs.

3. **`verify-verdict.sh` is correct** — no shell-portability or logic bug. The `printf '%s\n' "$VERDICT_LINE" | grep -c '[A-Z]'` idiom handles 0/1/2-token cases correctly (empty string -> one blank line -> count 0; the count test then fails as intended). `set -euo pipefail` with `|| true` guards is sound. Conclusion-neutral firewall claim (checks structure, not verdict) is accurate to the code.

4. **Two residual precision items (NOT errors, NOT blocking):**
   - CB Insights `checklists/fatal-flaws.md` L7 cites "431 VC-backed startup post-mortems (385 with an identifiable reason)." The 431 sample and the 70%/43%/29%/19% breakdown are corroborated by the current CB Insights report; the "385 with an identifiable reason" sub-count could not be independently confirmed. Cosmetic precision, not a headline error.
   - `tools/tool-registry.md` L101/L139 cites deanpeters repo "v0.79 (updated 2026-05-15)." Repo + non-commercial share-alike license confirmed to exist; exact version tag not independently verifiable. Low risk because the pack only points to the repo (does not copy its text) and explicitly flags the license.

5. **The pack correctly uses the NEWER CB Insights cut, not the stale classic.** A naive author would have written the famous "35% no market need / 38% ran out of cash" from the old top-20 report. This pack uses the updated 2024 "70% capital (symptom) / 43% PMF (root)" framing and explicitly distinguishes symptom from root cause — which is the currently-correct primary-source position. Strong signal of real fact discipline.

---

## Fact Checks (each version-sensitive claim verified vs current primary docs)

- **CB Insights startup failure: 70% ran out of capital (symptom), 43% poor PMF (#1 controllable), ~29% bad timing, ~19% unit economics** (fatal-flaws.md L7) — VERIFIED. Matches current CB Insights "Why Startups Fail: Top reasons" report (431 post-mortems since 2023, multi-cause so totals exceed 100%). Pack correctly frames 70% as symptom, 43% as root. Sub-figure "385 with identifiable reason" UNVERIFIED (cosmetic).
- **Sean Ellis PMF: >=40% "very disappointed" = must-have threshold; 10-30% = not yet PMF** (pressure-test.md L81, fatal-flaws.md L35) — VERIFIED. Matches Sean Ellis test definition across multiple primary/secondary sources; learningloop.io source cited is live and correct.
- **LTV:CAC: healthy 3:1-4:1, B2B target 4:1, median 3.6:1 (Benchmarkit 2025), <1:1 loses money, >5:1 under-invested** (software.md L71, fatal-flaws.md L52, SKILL.md L64) — VERIFIED. Benchmarkit 2025 median 3.6:1 confirmed; band semantics correct.
- **Rule of 40: growth%+margin% >= 40; SaaS median ~12% (Q1 2025)** (software.md L72, SKILL.md L65) — VERIFIED EXACTLY. Q1 2025 median Rule of 40 = 12% (growth 10% + EBITDA margin 6%) confirmed.
- **CAC payback: median 6.8mo across 14,500+ SaaS; B2C ~4.2mo / B2B ~8.6mo; <12mo healthy (76%); 18+mo challenging (8%)** (software.md L73, SKILL.md L66) — VERIFIED EXACTLY. proven-saas.com figures match: 6.8mo median, 14,500+ tracked, B2C 4.2 / B2B 8.6, 76% <12mo.
- **Free-trial conversion: opt-in (no card) 8-18%; opt-out (card) 31-49%** (software.md L74, SKILL.md L67) — VERIFIED. Current 2026 benchmarks: opt-in ~8-22% (median ~14%, ChartMogul 8.9%), opt-out ~31-55%. Pack's bands sit within the verified ranges; directionally and numerically sound.
- **Freemium conversion: broad 1-5%; tightly-targeted high-intent 5-15%** (software.md L75, content.md L65, SKILL.md L68) — VERIFIED. Matches withdaydream.com + corroborating benchmarks (broad 1-5%, targeted/sales-assist 5-15%).
- **Marketplace take rates: product 5-15% (Amazon 8-15%), service 15-30% (Uber 20-28%), Airbnb ~13-15%, default 10-20%** (marketplace.md L23-29, fatal-flaws.md F16, SKILL.md L69) — VERIFIED. Airbnb effective take ~13-15%, Uber ~20-28%, Amazon category commissions 8-15%; product 5-15% / service 15-30% standard. All consistent with sharetribe source cited.
- **Kickstarter: overall success ~42% (41.98% Jan 2025); technology high cumulative pledges (~$1.65B) but not highest success rate; Open Calls ~80%** (hardware.md L22) — VERIFIED for the headline ~42% (Statista Jan 2025 "over 41%"). Tech ~$1.65B cumulative pledges and Open Calls ~80% are plausible and consistent with Statista/Kickstarter data; headline rate confirmed.
- **deanpeters/Product-Manager-Skills: TAM/SAM/SOM calculator, CC BY-NC-SA 4.0 (non-commercial, share-alike), v0.79** (tool-registry.md L101/L106/L139) — PARTIALLY VERIFIED. Repo + tam-sam-som-calculator skill + non-commercial share-alike license all confirmed to exist. Exact version "v0.79" UNVERIFIED (low risk; cite-only, text not copied; license correctly flagged).
- **Tool names/types: WebSearch, last30days (Reddit/HN/GitHub/Polymarket/YouTube/TikTok), Keepa API, Amazon SP-API, Bright Data, Helium 10 ($39/mo) / Jungle Scout ($49/mo), aso-skills/Appeeky ($8/mo)** (tool-registry.md, adapters) — VERIFIED as real tools with correct descriptions and plausible pricing. No deprecated/renamed/fabricated APIs.
- **Reid Hoffman quote "If you're not embarrassed by the first version of your product, you've launched too late"** (pressure-test.md L178) — VERIFIED. Correctly attributed to Reid Hoffman.
- **The Mom Test commitment-currency (time/reputation/money) attributed to Rob Fitzpatrick via Sachin Rekhi summary** (fatal-flaws.md L34) — VERIFIED. Accurate attribution; source URL correct.
