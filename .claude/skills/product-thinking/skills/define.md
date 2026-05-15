---
name: define
description: Turn a selected product variant into an executable definition. Auto-fills 80% from /pressure-test and /shotgun data. Produces type-specific output (tech handoff, product listing, crowdfunding brief, etc.)
---

# /define

**Turn your selected variant into something you can build, pitch, or sell.**

This skill doesn't give you a blank Lean Canvas to fill in. It reads everything from your /pressure-test and /shotgun sessions and pre-fills 80% of the output. Your job is to correct, not create.

---

## Input Requirements

**Ideal input:** `~/.product-thinking/session.json` with both `pressure_test` and `shotgun` sections.

**Fallback (missing shotgun):** If only `pressure_test` exists, ask: "Which idea direction do you want to define? Describe it in 2-3 sentences."

**Standalone mode (no session.json):** Collect manually:
- Product type (6 options)
- Target customer (specific, from pressure-test Q3 if done)
- Core value proposition
- Revenue model
- Primary distribution channel
- Key competitive insight (from Q2 status quo)

---

## Step 1: Auto-Generate from Session Data

Read session.json and pre-fill all sections below. Use this mapping:

| Output Field | Source |
|-------------|--------|
| Problem statement | `session.pressure_test.facts` + Q1 search results |
| Target persona | `session.pressure_test` — Q3 "desperate specificity" answer |
| Current status quo | `session.pressure_test` — Q2 search results and competitor findings |
| Unique insight | `session.pressure_test.core_assumption` — the assumption that, if validated, becomes the product insight |
| MVP scope | `session.shotgun.variants[selected_variant-1].reduce` + Q4 "narrowest wedge" answer |
| Revenue model | `session.shotgun.variants[selected_variant-1].revenue_model` |
| Distribution channel | `session.shotgun.variants[selected_variant-1].channel` |
| Market size signal | `session.pressure_test` Q1/Q2 search findings |
| Competitive position | `session.pressure_test` Q2 status quo + competitor findings |
| Unfair advantage | `session.shotgun.variants[selected_variant-1].hold` |

Note: For `"combined"` selections, `selected_variant` is the string `"combined"` — read from `session.shotgun.variant_summary` and ask the user to confirm the specific elements they're combining.

Pre-fill everything you can. Mark uncertain fields with `[NEEDS CONFIRMATION]`.

---

## Step 2: Present Pre-Filled Canvas for Review

Show the user what was auto-filled. For each section:
- Show what was inferred from the data
- Ask if it's correct or needs adjustment
- Let user override any field

Keep the review quick — this is a confirmation loop, not a blank-slate exercise.

---

## Step 3: Type-Specific Output

Once the canvas is confirmed, generate the appropriate output for the product type.

---

### SOFTWARE Output: Tech Handoff

```markdown
# [Product Name] — Product Definition

## Problem
[1-2 sentences: who has what problem, current workaround, cost/pain of workaround]

## Target User
**Persona**: [Name, job title, company type, location]
**Situation**: [What they're trying to do + why current solutions fail them]
**Desperation signal**: [Specific behavior that shows acute pain — from pressure-test Q3]

## Solution
[2-3 sentences: what the product does, how it's different from status quo]

## Unique Insight
[The one thing you know that makes this work — from pressure-test core assumption, validated]

## MVP Scope (2-week ship)
**In scope:**
- [Feature 1]
- [Feature 2]
- [Feature 3 max]

**Out of scope (v2+):**
- [Everything else]

**Success metric**: [One number that tells you if MVP worked]

## Revenue Model
**Pricing**: [Specific price point]
**Model**: [Subscription / one-time / usage-based / freemium]
**Why this pricing**: [1 sentence rationale from competitive research]

## Distribution
**Channel 1**: [Specific]
**First 100 users strategy**: [Concrete 30-day plan]

## Competitive Position
**Status quo**: [What users do now + cost]
**Why switch to this**: [Specific advantage — not "better", but what specifically]
**Closest competitor**: [Name + how you're different]

## Market Signal
[Key search findings from pressure-test that validate demand]

## TAM/SAM/SOM (rough)
TAM: [If calculable from search data]
SAM: [Serviceable segment]
SOM: [12-month realistic target]

## Next Action
[The single most important thing to do in the next 7 days]
```

---

### ECOMMERCE Output: Product Listing + Supplier Plan

```markdown
# [Product Name] — Ecommerce Definition

## Product
**Name**: [Product name]
**Category**: [Amazon category / product type]
**Core benefit**: [One sentence — what problem it solves, for whom]

## Target Customer
**Who**: [Specific segment with demographics]
**When they buy**: [Trigger or occasion]
**Search intent**: [What they search for on Amazon]

## Market Position
**BSR target**: [Rank range to aim for]
**Price position**: [$ vs competitors: premium / mid / value]
**Key differentiator**: [What makes this product different from page 1 competitors]

## Pricing
**COGS estimate**: $[X] (based on [source])
**Target retail price**: $[X]
**Target margin**: [X]%
**Amazon FBA fees estimate**: $[X]

## MVP: 10-Unit Test Sell
**Units to order**: 10-50
**Supplier**: [Platform: Alibaba / domestic / etc]
**Timeline**: [Days to first sale]
**Success signal**: [Sell-through in X days at Y price = demand validated]

## Listing Strategy
**Primary keyword**: [Most searched relevant term]
**Secondary keywords**: [3-5 terms from Amazon/Keepa research]
**Photo requirements**: [Main image + 4 key angles]

## Validation Plan
1. [Step 1 with timeline]
2. [Step 2 with timeline]
3. [What you'll know after 30 days]

## Risk
**Biggest risk**: [One sentence]
**Mitigation**: [One sentence]
```

---

### HARDWARE Output: BOM + Prototype Plan + Crowdfunding Brief

```markdown
# [Product Name] — Hardware Definition

## Product
**What it does**: [One sentence: physical function + user benefit]
**Form factor**: [Dimensions, materials, key physical features]
**Target user**: [From pressure-test Q3]

## Problem Validated
[From pressure-test evidence — what makes this person desperate]

## Prototype Plan (2-week)
**Week 1**: [What to build / 3D print / mock up]
**Week 2**: [What to test with 3 real users]
**Success signal**: [What user behavior proves the concept works]

## Bill of Materials (Estimate)
| Component | Est. Cost | Source |
|-----------|----------|--------|
| [Part 1]  | $[X]     | [Supplier / Amazon] |
| [Part 2]  | $[X]     | [Supplier / Amazon] |
| Assembly  | $[X]     | — |
| **Total COGS (unit)** | **$[X]** | |

## Crowdfunding Brief
**Campaign title**: [Compelling hook — who + problem + solution]
**Target**: $[X] (covers tooling + minimum order)
**Reward tiers**: [3 tiers: early bird / standard / premium]
**Key visual**: [What the hero image shows]
**Launch timeline**: [Prototype → campaign → delivery]

## Manufacturing Path (post-validation)
**MOQ estimate**: [Minimum order quantity]
**Lead time**: [Weeks]
**Target per-unit cost at scale**: $[X]

## Risk Assessment
**Biggest risk**: [Technical / supply chain / timing]
**Mitigation**: [Specific action]
```

---

### SERVICE Output: Package + Pricing + First 10 Clients Plan

```markdown
# [Service Name] — Service Definition

## Service
**What you do**: [One sentence: who you help + what you deliver]
**Outcome you guarantee**: [Specific, measurable result for the client]
**Who it's for**: [From pressure-test Q3 — specific persona]

## Service Package (v1: do it by hand)
**Package name**: [Something specific — not "Basic/Pro/Enterprise"]
**What's included**: [3-5 specific deliverables or actions]
**What's NOT included**: [Critical for scope clarity]
**Timeline**: [X days / sessions / weeks]
**Price**: $[X] per [engagement / month / project]

**Why this price**: [1 sentence — competitive research from Q2]

## First 10 Clients Plan
1. **Days 1-7**: [Specific outreach method — LinkedIn DMs, referrals, cold email to specific list]
2. **Days 8-14**: [Follow-up + close first 3 clients]
3. **Days 15-30**: [Deliver + get case study + expand to next 7]

**Lead source**: [Where specifically these first 10 come from]
**Conversion rate assumption**: [Reach X people → close Y → revenue $Z]

## Productization Path
**Current**: Manual, founder-delivered
**Month 3**: [What can be systematized with a checklist or template]
**Month 6**: [What can be delegated to a hire or software]

## Positioning
**Competitive alternative**: [What clients do today instead — from Q2]
**Why switch**: [Specific ROI or outcome advantage]

## Success Metric (30 days)
[One number: revenue, clients, or specific outcome]
```

---

### CONTENT Output: Content Calendar + Distribution + Monetization Path

```markdown
# [Content Brand Name] — Content Definition

## Content
**Topic**: [Specific niche — not "productivity" but "async workflows for 5-person remote dev teams"]
**Format**: [Primary: newsletter / YouTube / podcast / Twitter / TikTok]
**Audience**: [From pressure-test Q3 — specific person + their content consumption]

## Core Thesis
[The ONE controversial or non-obvious idea that makes this different]
[This is what will create loyal fans — people who've found someone who "gets it"]

## First 10 Posts (Content Calendar)
| Post | Format | Hook | Core Insight |
|------|--------|------|-------------|
| 1    | [format] | [hook line] | [key insight] |
| 2    | [format] | [hook line] | [key insight] |
...10 posts total

**Volume target**: [X posts/week for first 30 days]
**Success signal**: [Engagement metric that proves the thesis resonates]

## Distribution
**Primary channel**: [Specific platform — and why this audience is there]
**Cross-posting**: [Secondary channels if applicable]
**First 1000 audience members**: [Specific acquisition strategy]

## Monetization Path
**Month 1-3**: [Audience building only — no monetization]
**Month 4-6**: [First monetization: sponsorship / digital product / community / consulting]
**Month 7-12**: [Primary revenue model: subscription / course / affiliate / product]

**Comparable creator**: [Who does something similar — revenue model + size benchmark]

## Competitive Position
[Why this POV / niche is not already owned by someone else — or why you can do it better]
```

---

### MARKETPLACE Output: Supply Strategy + Demand Strategy + Unit Economics

```markdown
# [Marketplace Name] — Marketplace Definition

## Marketplace
**What it connects**: [Supply side: who] ↔ [Demand side: who]
**Transaction**: [What changes hands — money, time, goods, services]
**Core value**: [Why this connection doesn't happen efficiently today]

## The Cold Start Problem
**Which side to start with**: [Supply OR Demand — and why]
**First 10 supply-side participants**: [Specific acquisition plan]
**First 10 demand-side participants**: [Specific acquisition plan]
**What makes supply side want to join before demand exists?**: [Answer this explicitly]

## Business Model
**Take rate**: [% or flat fee per transaction]
**Average transaction value**: $[X]
**Revenue per transaction**: $[X × take rate]
**Transactions needed for $10K MRR**: [Math]

## Unit Economics
| Metric | Target |
|--------|--------|
| Customer Acquisition Cost (supply) | $[X] |
| Customer Acquisition Cost (demand) | $[X] |
| Avg transaction value | $[X] |
| Take rate | [X]% |
| Gross margin | [X]% |
| Payback period | [X months] |

## Defensibility
**Liquidity moat**: [At what GMV does the marketplace become hard to replicate?]
**Trust mechanism**: [Reviews / escrow / verification / identity]
**Network effects**: [How does each additional participant make it more valuable?]

## MVP (Airtable-first)
**What you can run manually**: [Specific process — matching, coordination, payments]
**When to build software**: [Trigger: X transactions/day exceeds manual capacity]
**First transaction target**: [Date + specific supply+demand pair]
```

---

## Step 4: Next Actions

After generating the type-specific output:

1. **Review**: Go through each section with the user. Mark unresolved questions.

2. **Prioritize**: Ask — "What's the single most important thing to validate in the next 7 days?"

3. **Hand off (optional)**:
   - Software → "This output can feed directly into a technical specification or product development workflow."
   - Ecommerce → "Take the supplier plan to Alibaba/Amazon today."
   - Hardware → "Start the 3D print or mockup this week."
   - Service → "Send the first 10 outreach messages today."
   - Content → "Write post #1 today."
   - Marketplace → "Find your first supply-side participant today."

---

## Session.json: Not Updated

`/define` reads from session.json but does not write back to it. The output is a document, not a pipeline step. Save the output separately if you want to reference it later.

---

## Standalone Use

You can use `/define` without having run `/pressure-test` or `/shotgun`. In that case:
- Collect the 6 fields listed under Input Requirements manually
- Pre-fill what you can from user input
- Mark more fields `[NEEDS CONFIRMATION]`
- The output will be less pre-filled but still structured

The output format is the same regardless of whether prior steps were run.
