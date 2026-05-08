# Adapter: Marketplace

Applies to: two-sided platforms connecting buyers and sellers, service providers and clients, lenders and borrowers, creators and audiences.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| Existing marketplace signals | WebSearch `"{product category} marketplace alternatives"` | ZERO_CONFIG | — |
| Supply side research | WebSearch `"site:upwork.com {service}"` OR `"site:etsy.com {product}"` | ZERO_CONFIG | — |
| Demand side communities | WebSearch `"site:reddit.com looking for {supply type}"` | ZERO_CONFIG | — |
| Competitor marketplace analysis | WebSearch `"{competitor marketplace} GMV revenue"` | ZERO_CONFIG | — |
| Unit economics benchmarks | WebSearch `"{category} marketplace take rate"` | ZERO_CONFIG | — |

**Note**: Marketplace validation is primarily about proving both sides exist and want to transact. WebSearch + community research is the right tool. No specialized APIs needed for early validation.

---

## Question Variants

| Q# | Standard Wording | Marketplace-Specific Wording |
|----|-----------------|------------------------------|
| Q1 | Evidence of real demand? | "How many people on each side of this marketplace are actively looking for the other? Show me the Reddit posts, the Craigslist listings, the Slack group messages where supply and demand are already trying to find each other badly." |
| Q2 | Current workaround? | "How do supply and demand connect today? Google Docs shared in Facebook groups? Word of mouth? A broken incumbent? What's the friction in the current process — exactly?" |
| Q3 | Real person? | "Name one person on the supply side and one person on the demand side who you could get to transact through a manual version of this in the next 7 days. Do you have their contact information?" |
| Q4 | Narrowest wedge? | "**Which side can you serve with Airtable?** Before you build software, which side of the marketplace can you onboard manually — an Airtable form, a spreadsheet, a shared doc? That's your first week." |
| Q5 | Observation? | "Have you watched one complete transaction happen manually, end to end? Where did it break down? What did both sides struggle with?" |
| Q6 | Future-fit? | "At what point does the dominant supply-side participant build their own platform and cut you out? Uber driver becomes Lyft. Etsy seller starts their own Shopify store. How do you create lock-in before that happens?" |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
WebSearch: "site:reddit.com {category} looking for hire"
WebSearch: "{category} marketplace demand"
WebSearch: "{supply type} finding clients difficult"
```

**Round 2 (Status Quo)**:
```
WebSearch: "{incumbent marketplace} complaints reviews"
WebSearch: "alternatives to {competitor marketplace}"
WebSearch: "how {supply side} finds clients today"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "Airtable marketplace template"
WebSearch: "no-code marketplace {category}"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "{supply side} going direct to consumers"
WebSearch: "{marketplace category} disintermediation"
WebSearch: "{big tech} building {marketplace type}"
```

---

## MVP Definition

**One side first (supply OR demand)**: Onboard 10-20 participants on whichever side is harder to acquire. Build that side first, then bring the other side to them.

**Manual transaction**: Complete 3 transactions end-to-end without any software. Manually match supply and demand. Do everything by hand.

**Success signal**: Both sides complete transactions and are willing to pay the stated take rate. At least 1 participant on each side refers another participant.

**What this proves**: Both sides exist. They'll transact through you. The take rate is acceptable. You can operate it.

---

## /define Output Format

For marketplaces, `/define` produces a **Supply Strategy + Demand Strategy + Unit Economics** (see `skills/define.md` Marketplace section):
- What it connects (supply ↔ demand)
- Cold start problem solution (which side first + why)
- Business model (take rate + transaction economics)
- Unit economics table
- Defensibility (liquidity moat + trust mechanism + network effects)
- MVP: manual first transaction target
