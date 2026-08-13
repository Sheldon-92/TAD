# Adapter: Ecommerce

Applies to: physical goods sold online, Amazon FBA, private label, dropshipping, DTC brands.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| Amazon product/BSR data | WebSearch `"site:amazon.com {product} reviews"` | ZERO_CONFIG | — |
| Amazon BSR history + price trends | Keepa API | NEEDS_SETUP (paid API) | `WebSearch "{product} BSR history Amazon"` |
| Amazon keyword research | Helium 10 / Jungle Scout | NEEDS_SETUP (paid SaaS) | `WebSearch "{product} Amazon search volume 2024"` |
| Multi-marketplace data | Bright Data Amazon Analyzer | NEEDS_SETUP (paid API) | `WebSearch "{product} price comparison"` |
| Profit/fee calculator | Sellerboard / Amazon FBA Calculator | ZERO_CONFIG (Amazon native) | `WebSearch "Amazon FBA fees {category} calculator"` |
| Supplier research | WebSearch `"site:alibaba.com {product}"` | ZERO_CONFIG | — |
| Competitor reviews | WebSearch `"{product} Amazon negative reviews"` | ZERO_CONFIG | — |

---

## Question Variants

| Q# | Standard Wording | Ecommerce-Specific Wording |
|----|-----------------|---------------------------|
| Q1 | Evidence of real demand? | "How many products in this category have >100 reviews on Amazon? What's the average BSR for page 1? Show me the data — not your estimate." |
| Q2 | Current workaround? | "What product do people buy instead today? Link me to the Amazon listing. What do the 1-star reviews complain about? That's your opportunity." |
| Q3 | Real person? | "Name a specific person (age range, income, life situation) who buys this category regularly on Amazon. Why do they buy? What makes them choose one product over another?" |
| Q4 | Narrowest wedge? | "**What's the minimum order to prove demand?** 10 units? 50 units? What's the minimum viable SKU — one color, one size, one variant — that you can test-sell in the next 30 days?" |
| Q5 | Observation? | "Have you read 50+ reviews (positive AND negative) for the top 3 competitors? What do buyers say they wish was different?" |
| Q6 | Future-fit? | "Is Amazon going to compete with you directly? (Check if Amazon Basics has this category.) What happens to your margins when a Chinese manufacturer sells direct?" |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
WebSearch: "site:amazon.com {product category} bestsellers"
WebSearch: "{product} Amazon BSR range top sellers"
WebSearch: "{product category} market size 2024 2025"
```

**Round 2 (Status Quo)**:
```
WebSearch: "site:amazon.com {main competitor product} reviews 1 star 2 star"
WebSearch: "{product} reddit complaints"
WebSearch: "{product category} problems customers"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "site:alibaba.com {product} MOQ price"
WebSearch: "{product} Alibaba minimum order"
WebSearch: "Amazon FBA fees {product category}"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "Amazon basics {product category}"
WebSearch: "{Chinese brand} selling {product} directly USA"
WebSearch: "{product category} tariff 2025"
```

---

## MVP Definition

**10-unit test sell**: Source 10-50 units (Alibaba, domestic, or existing inventory), list on Amazon/Etsy/eBay, sell through within 30 days without paid advertising.

**Success signal**: Sell 70%+ of units at target price within 30 days. At least 3 organic reviews. No returns beyond 10%.

**What this proves**: Price point is right. Product-market fit is real. Listing converts.

---

## /define Output Format

For ecommerce products, `/define` produces a **Product Listing + Supplier Plan** (see `skills/define.md` Ecommerce section):
- Product + category
- Target customer (segment + search intent)
- Market position (BSR target + price position + differentiator)
- Pricing (COGS estimate + retail price + margin + FBA fees)
- MVP: 10-unit test sell plan
- Listing strategy (keywords + photo requirements)
- Validation plan (30 days, step by step)
- Risk + mitigation
