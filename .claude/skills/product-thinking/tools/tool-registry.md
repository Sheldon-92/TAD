# Tool Registry

All tools used across the Product Thinking skill pack. Skills degrade gracefully when specialized tools are unavailable — WebSearch fallback is always provided.

---

## Availability Legend

| Status | Meaning |
|--------|---------|
| `ZERO_CONFIG` | Works immediately without any API key or installation |
| `NEEDS_SETUP` | Requires API key, subscription, or CLI installation |
| `WEBSEARCH_FALLBACK` | When unavailable, use the listed WebSearch query |

---

## Tool Index

### WebSearch
| Attribute | Value |
|-----------|-------|
| **Status** | ZERO_CONFIG |
| **What it does** | General web search — the universal fallback for all research steps |
| **When to use** | Competitor research, pricing, market size, news, reviews, forum threads |
| **Used by** | All adapters, all skills |

---

### last30days
| Attribute | Value |
|-----------|-------|
| **Status** | ZERO_CONFIG (for Reddit, HN, GitHub, Polymarket) / NEEDS_SETUP (for X) |
| **What it does** | Searches recent content across Reddit, HackerNews, GitHub, Polymarket, YouTube, TikTok |
| **Sub-commands** | `--reddit "{topic}"`, `--hn "{topic}"`, `--github "{topic}"`, `--polymarket "{topic}"`, `--youtube "{topic}"`, `--tiktok "{topic}"` |
| **X (Twitter)** | Requires auth token — falls back to `WebSearch "site:twitter.com {topic}"` |
| **When to use** | Demand validation, trend signals, community complaints, competitor discussion |
| **Adapters** | software.md (Reddit/HN/GitHub/Polymarket), content.md (YouTube/TikTok/Reddit) |
| **WEBSEARCH_FALLBACK** | `WebSearch "site:reddit.com {topic}"` / `WebSearch "site:news.ycombinator.com {topic}"` |

---

### aso-skills (Appeeky API)
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP ($8/month subscription at appeeky.com) |
| **What it does** | App Store optimization — keyword rankings, review analysis, competitor ASO data |
| **When to use** | Mobile app demand validation, competitor App Store presence |
| **Adapters** | software.md |
| **WEBSEARCH_FALLBACK** | `WebSearch "site:apps.apple.com {competitor app} reviews"` |

---

### Keepa API
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP (paid API at keepa.com/api) |
| **What it does** | Amazon product history — BSR over time, price history, stock history, deal alerts |
| **When to use** | Ecommerce demand validation, competitor price/rank trends |
| **Adapters** | ecommerce.md |
| **WEBSEARCH_FALLBACK** | `WebSearch "{product} BSR history Amazon"` / `WebSearch "{product} price history Amazon"` |

---

### Amazon SP-API
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP (requires Amazon Seller account + SP-API registration) |
| **What it does** | Official Amazon Seller Partner API — listings, orders, fees, inventory |
| **When to use** | Direct Amazon seller integration, fee calculation, listing management |
| **Adapters** | ecommerce.md |
| **WEBSEARCH_FALLBACK** | `WebSearch "Amazon FBA fees {category} calculator"` / Amazon FBA Calculator (free tool on Amazon's site) |

---

### Bright Data Amazon Analyzer
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP (paid API at brightdata.com) |
| **What it does** | Multi-marketplace Amazon data — price distribution, ratings analytics, deal detection across 23 markets |
| **When to use** | Deep ecommerce competitive analysis, international market sizing |
| **Adapters** | ecommerce.md |
| **WEBSEARCH_FALLBACK** | `WebSearch "{product} price comparison Amazon international"` |

---

### Helium 10 / Jungle Scout
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP (paid SaaS — Helium 10 from $39/mo, Jungle Scout from $49/mo) |
| **What it does** | Amazon keyword research, ASIN database, revenue estimates, competitor analysis |
| **When to use** | Deep ecommerce keyword research, market size estimation on Amazon |
| **Adapters** | ecommerce.md |
| **WEBSEARCH_FALLBACK** | `WebSearch "{product} Amazon search volume 2024"` / `WebSearch "site:amazon.com {keyword} results count"` |

---

### tam-sam-som-calculator
| Attribute | Value |
|-----------|-------|
| **Status** | NEEDS_SETUP (deanpeters/product-manager-skills must be installed) |
| **What it does** | Structured TAM/SAM/SOM calculation with real data inputs |
| **When to use** | Market sizing in `/define` step (software and marketplace primarily) |
| **Adapters** | software.md (optional), marketplace.md (optional) |
| **WEBSEARCH_FALLBACK** | Manual WebSearch for market size data + rough calculation in `/define` output |

---

## Graceful Degradation Policy

Skills in this pack follow a strict degradation hierarchy:

```
1. Zero-config tool available → use it
2. Needs-setup tool available → use it
3. Neither available → use WebSearch fallback query
4. WebSearch returns nothing useful → state "no market data found; treat as assumption"
```

**Never skip a research step.** If all tools fail, the response is:
> "I searched [queries] and found insufficient public data on this. Without evidence, this remains an ASSUMPTION."

That is a valid and important output — it flags that the founder is building on unvalidated belief.

---

## Tool Installation References

| Tool | Install Guide |
|------|--------------|
| last30days | See the last30days skill repository for installation |
| aso-skills | appeeky.com/api — sign up for API key |
| Keepa API | keepa.com/api — developer registration |
| Amazon SP-API | developer.amazon.com — Seller Partner API |
| Helium 10 | helium10.com — web SaaS, no local install |
| Jungle Scout | junglescout.com — web SaaS, no local install |
| Bright Data | brightdata.com — API registration |
| tam-calculator | deanpeters/product-manager-skills — GitHub |
