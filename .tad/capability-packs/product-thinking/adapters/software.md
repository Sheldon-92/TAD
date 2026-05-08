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
| Q4 | Narrowest wedge? | "**What's the smallest payable feature?** Not the product — one workflow, one integration, one script. What would someone pay $9/month for today?" |
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
