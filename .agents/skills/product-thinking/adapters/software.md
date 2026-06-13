# Adapter: Software

Applies to: web apps, mobile apps, SaaS, APIs, developer tools, AI products, browser extensions.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| Reddit demand signals | last30days `--reddit "{topic}"` | ZERO_CONFIG | `WebSearch "site:reddit.com {problem}"` |
| HN discussions | last30days `--hn "{topic}"` | ZERO_CONFIG | `WebSearch "site:news.ycombinator.com {topic}"` |
| Prediction markets / trend signals | last30days `--polymarket "{domain}"` | ZERO_CONFIG | `WebSearch "{domain} trend 2025"` |
| App Store reviews | aso-skills (Appeeky API) | NEEDS_SETUP ($8/mo) | `WebSearch "site:apps.apple.com {competitor} reviews"` |
| GitHub activity (developer tools) | last30days `--github "{topic}"` | ZERO_CONFIG | `WebSearch "github.com {tool category} stars"` |
| Competitor research | WebSearch | ZERO_CONFIG | — |
| Product Hunt launches | WebSearch `"site:producthunt.com {category}"` | ZERO_CONFIG | — |

---

## Question Variants

| Q# | Standard Wording | Software-Specific Wording |
|----|-----------------|--------------------------|
| Q1 | Evidence of real demand? | "Show me a Reddit thread, HN discussion, or GitHub issue where strangers describe exactly this problem — not similar, exactly this." |
| Q2 | Current workaround? | "What tool, script, or manual process does your target user use today? Name the tool. Give me the pricing page URL." |
| Q3 | Real person? | "Name a specific developer/user (first name, company, job title) who would use this in production today. What's their current stack?" |
| Q4 | Narrowest wedge? | "**What's the smallest payable feature?** Not the product — one workflow, one integration, one script. Name a price someone would pay for it today, and prove the unit economics close (LTV:CAC ≥ 3:1 — see SaaS Unit-Economics Thresholds below). A wedge with negative unit economics is not a wedge." |
| Q5 | Observation? | "Have you watched a developer use your intended workflow without helping? What workarounds did they invent that surprised you?" |
| Q6 | Future-fit? | "If LLMs get 10x better in 2 years and can write code for free — does that make your product more essential or obsolete? Why?" |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
last30days --reddit "{product concept}" --days 90
last30days --hn "{problem keywords}" --days 180
WebSearch: "site:reddit.com/{relevant_subreddit} {problem}"
```

**Round 2 (Status Quo)**:
```
WebSearch: "{competitor} pricing site:{competitor.com}"
WebSearch: "{alternative tool} vs {another tool}"
WebSearch: "{target role} stack 2025 survey"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "site:producthunt.com {category} 2024 2025"
WebSearch: "{closest competitor} launched with"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "AI replacing {software category}"
WebSearch: "{big tech company} building {tool type} 2025"
last30days --polymarket "{domain disruption}"
```

---

## SaaS Unit-Economics Thresholds (use to challenge "will anyone pay" + pricing)

Carry these numbers into Q4 (wedge), Step 7 (verdict), and the `/define` revenue-model section. They are research-grounded benchmarks a frontier LLM cannot reliably reproduce as precise rules — use them, don't paraphrase them as "good unit economics".

| Metric | Healthy band | Red flag | Source |
|--------|-------------|----------|--------|
| **LTV:CAC ratio** | 3:1–4:1 (B2B target **4:1**, median **3.6:1**, Benchmarkit 2025) | **<1:1** = loses money per customer; **>5:1** = under-investing in growth | phoenixstrategy.group LTV:CAC SaaS benchmarks (retrieved 2026-06-13) |
| **Rule of 40** | growth % + EBITDA margin % **≥ 40** | SaaS **median only ~12%** (Q1 2025) — 40 is demanding | phoenixstrategy.group (retrieved 2026-06-13) |
| **CAC payback** | **<12 months** (76% of SaaS); median **6.8mo** across 14,500+ tracked SaaS (B2C **~4.2mo**, B2B **~8.6mo**) | **18+ mo** (8% of SaaS) = challenging unit economics | proven-saas.com CAC payback benchmarks (retrieved 2026-06-13) |
| **Free-trial conversion** | opt-in (no card) **~8-18%**; opt-out (card required) **~31-49%** | a founder assuming >20% on a no-card trial is fantasizing | proven-saas.com / userpilot.com (retrieved 2026-06-13) |
| **Freemium conversion** | broad-market tools **~1-5%**; tightly-targeted high-intent SaaS **~5-15%** | "we'll convert most free users" — challenge with the band | withdaydream.com freemium benchmark (retrieved 2026-06-13) |

**How to use in /pressure-test:** when the founder states a conversion or pricing assumption, name the band ("opt-in trials convert 8-18%, not 40% — at 12% you need 8× the traffic"), and recompute whether LTV:CAC still clears 3:1. A wedge priced such that CAC payback exceeds 18 months is a F13 unit-economics flaw.

Sources:
- LTV:CAC + Rule of 40 — https://www.phoenixstrategy.group/blog/ltvcac-ratio-saas-benchmarks-and-insights (retrieved 2026-06-13)
- CAC payback — https://proven-saas.com/benchmarks/cac-payback-benchmarks (retrieved 2026-06-13)
- Trial conversion — https://userpilot.com/blog/saas-average-conversion-rate/ (retrieved 2026-06-13)
- Freemium conversion — https://www.withdaydream.com/library/insights/freemium-conversion-rate (retrieved 2026-06-13)

---

## MVP Definition

**2-week ship**: A working API endpoint, CLI tool, Chrome extension, or single-workflow web app that does ONE thing. No accounts required. No dashboard. No mobile app.

**Target users**: 3-5 beta users who use it in real work — not demos, not friends.

**Success signal**: At least 1 user uses it without being asked, at least 3 times in 2 weeks.

---

## /define Output Format

For software products, `/define` produces a **Tech Handoff** (see `skills/define.md` Software section):
- Problem statement (1-2 sentences)
- Target persona (name, job, company type)
- Solution (2-3 sentences)
- MVP scope (in/out, ≤3 features)
- Revenue model (specific price + model)
- Distribution (channel + first 100 users plan)
- Competitive position (status quo + why switch)
- Success metric (one number)
- Next action (7 days)

---

## Tool Availability Notes

**last30days**: Zero-config for Reddit, HN, GitHub, Polymarket. Requires auth token for X (Twitter). If unavailable entirely, fall back to `WebSearch` with `site:` filters.

**aso-skills**: Needs Appeeky API key ($8/month). If unavailable, use `WebSearch "site:apps.apple.com {competitor} reviews"` for App Store data.

**tam-calculator**: Optional. If deanpeters/product-manager-skills is installed, use `tam-sam-som-calculator`. Otherwise estimate from WebSearch market size data.
