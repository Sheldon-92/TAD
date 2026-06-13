# Adapter: Hardware

Applies to: physical products, IoT devices, consumer electronics, wearables, medical devices, tools, accessories.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| Crowdfunding validation | WebSearch `"kickstarter {product} funded"` | ZERO_CONFIG | — |
| Consumer interest signals | WebSearch `"site:reddit.com {product type}"` | ZERO_CONFIG | — |
| YouTube unboxing/reviews | WebSearch `"youtube {product} unboxing review"` | ZERO_CONFIG | — |
| Competitor pricing | WebSearch `"{product} price buy"` | ZERO_CONFIG | — |
| Supplier + manufacturing cost | WebSearch `"site:alibaba.com {component}"` | ZERO_CONFIG | — |
| Similar crowdfunding performance | WebSearch `"kickstarter {category} failed funded"` | ZERO_CONFIG | — |

**Note**: Hardware has fewer specialized CLI/API tools than software or ecommerce. Most research is WebSearch + YouTube + crowdfunding sites. This is expected and acceptable — see §5.6 adapter thickness guidelines.

## Crowdfunding Reality (set a realistic pre-order/campaign bar, not "just launch")

Hardware's 2-week validation usually leans on a crowdfunding or pre-order signal — so anchor it to real Kickstarter data, not optimism. **Overall Kickstarter project success rate is ~42% (41.98% as of Jan 2025)** — a coin-flip, not a default win. **Technology/hardware is among the highest cumulative-pledge categories (~$1.65B) but NOT the highest success rate** (high pledges ≠ high odds; tech campaigns are large and frequently fail). Creators who use structured **Open Calls** hit **~80%** — i.e. validation/curation before launch roughly doubles the odds. So set the bar accordingly: a hardware pre-order/crowdfunding wedge should target funded-vs-asked evidence and a curated audience, not "we'll launch a campaign and see." (Source: https://www.statista.com/statistics/235405/kickstarter-project-funding-success-rate/ — retrieved 2026-06-13.)

---

## Question Variants

| Q# | Standard Wording | Hardware-Specific Wording |
|----|-----------------|--------------------------|
| Q1 | Evidence of real demand? | "Show me a Kickstarter campaign in this category that funded — with the backer count and average pledge. That's real demand evidence. 'I asked people and they like it' is not." |
| Q2 | Current workaround? | "What does your target customer use today? Show me the Amazon listing or product page. What do the reviews complain about? What do they praise? That's your design brief." |
| Q3 | Real person? | "Name a specific person who would back this on Kickstarter in the first 48 hours. What communities are they in? What YouTube channels do they watch? Have you talked to them?" |
| Q4 | Narrowest wedge? | "**What can you validate without tooling?** A 3D-printed prototype + 5 user tests. Or a mockup + 50 pre-orders. What's the most important assumption you can test in 2 weeks with $500 or less?" |
| Q5 | Observation? | "Have you watched someone use the existing product (or workaround) and noted the specific moments of frustration? Video it. That's your product design." |
| Q6 | Future-fit? | "How long before a Chinese manufacturer makes a cheaper version? What's your moat — patent, brand, community, or something else? Be specific." |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
WebSearch: "kickstarter {product category} most funded"
WebSearch: "{product} crowdfunding backed funded"
WebSearch: "site:reddit.com {product category} wish existed"
```

**Round 2 (Status Quo)**:
```
WebSearch: "best {product category} 2024 review"
WebSearch: "site:amazon.com {closest product} reviews problems"
WebSearch: "{product} YouTube review complaints"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "3D print {product component} design"
WebSearch: "{product} prototype services cost"
WebSearch: "site:alibaba.com {main component} price"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "China manufacturer {product category} USA direct"
WebSearch: "{product} patent filed"
WebSearch: "{similar product} knockoff clone AliExpress"
```

---

## MVP Definition

**2-week validation**: Build a 3D-printed or hand-assembled prototype. Test with 5 real users in natural context. OR launch a pre-order page with mockup images and goal of 50 pledges before spending on tooling.

**Success signal**: 5 users complete a real task with the prototype without significant confusion. OR 50+ pre-orders at a price that covers tooling costs.

**What this proves**: The physical form factor works. People value it enough to commit money before it exists.

---

## /define Output Format

For hardware products, `/define` produces a **BOM Estimate + Prototype Plan + Crowdfunding Brief** (see `skills/define.md` Hardware section):
- Product description + form factor
- Problem validated (from pressure-test)
- Prototype plan (week 1: build, week 2: test)
- Bill of Materials (cost estimate)
- Crowdfunding brief (campaign title + tiers + visual)
- Manufacturing path (MOQ + lead time + unit cost at scale)
- Risk assessment
