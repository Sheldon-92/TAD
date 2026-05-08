---
name: shotgun
description: Generate 4-6 fundamentally different business model variants from a validated idea. Anti-convergence enforced. 4-perspective review per variant. Produces a side-by-side comparison for user selection.
---

# /shotgun

**Purpose: multiply the option space before you commit.**

Most founders build the first version of their idea without asking if it's the right version. /shotgun forces you to see 4-6 genuinely different ways to build the same product before picking one. Not UI variants — business model variants.

---

## Input Requirements

**Ideal input:** Run `/pressure-test` first. If `~/.product-thinking/session.json` exists with a BUILD or PIVOT verdict, this skill reads it automatically.

**Standalone mode:** If no session.json exists, ask the user:
- "Describe your product idea in 2-3 sentences."
- "What product type is it? (Software / Hardware / Ecommerce / Service / Content / Marketplace)"
- "Who is the target customer? What problem do they have?"

---

## Anti-Convergence Rule

**Hard requirement.** No two variants may share ALL THREE of:
1. Primary revenue model (subscription vs one-time vs marketplace cut vs freemium vs usage-based vs advertising)
2. Target customer segment
3. Primary distribution channel

If any two variants share all three — regenerate the second one in a completely different direction.

**The Headline Swap Test:** If you could swap the headline/tagline between two variants without anyone noticing, they are too similar. Regenerate.

**Distinct Origins Test:** The variants should feel as though they were created by three entirely different product teams with different philosophies — not the same team with slightly different preferences.

---

## Step 1: Generate 4-6 Variants

Based on the product idea and /pressure-test data (if available), generate variants.

**For each variant, write one focused paragraph:**
- Who specifically is this for (narrow customer segment)
- What it does differently from the other variants (core differentiator)
- How it makes money (specific revenue model)
- How it reaches customers (distribution channel)
- Why someone would choose this over the others

**Variant generation prompts (use these to push in different directions):**

- **The B2B Enterprise version**: Who would pay $1000+/month for this as a team tool?
- **The prosumer version**: Who would pay $20/month but use it obsessively every day?
- **The marketplace version**: Could this connect two sides of a market instead of building the tool itself?
- **The content version**: Could the value be information/education rather than software/product?
- **The services version**: Could this be a done-for-you service before it's a product?
- **The open-source + paid version**: Could the core be free and the premium features paid?
- **The API/infrastructure version**: Could you be the platform others build on?
- **The community version**: Is the value in connecting people rather than in software?

You don't need all 8 — pick 4-6 that are most plausible AND most different from each other.

**Search step (required):**
For each variant, do a quick search to check if it already exists. Extract 2-3 keyword phrases from the variant's core concept for search (not the full description paragraph):
```
WebSearch: "{revenue model keyword} {customer segment keyword} {product category}"
WebSearch: "startup {2-3 word product concept} Y Combinator OR ProductHunt"
```
Note if a competitor exists — the variant is still valid if you can differentiate.

---

## Step 2: 4-Perspective Review

For each variant, evaluate through all 4 lenses. Keep each answer to 2-3 sentences.

### EXPAND
*"If you had unlimited resources and 5 years, how large could this get? What's the maximum total addressable market for this specific variant?"*
- What does the $100M/year version of this look like?
- What would you need to build to get there?
- What's the primary growth lever?

### SELECTIVE
*"Keeping the current scope, what ONE thing would make this version unforgettable? The single feature or quality that creates word-of-mouth."*
- What would make a user say "you have to try this" to someone else?
- What's the "iPhone moment" for this variant — the thing that makes people pick it up and not want to put it down?

### HOLD
*"What would make this version bulletproof? What would you need to be true for this to survive a recession, a large competitor entering, and an AI disruption?"*
- What's the defensibility mechanism?
- What lock-in or switching cost protects this?
- What would you need to do in the first 6 months to create that?

### REDUCE
*"Strip to absolute core. One user, one action, one outcome. What is the irreducible essence of this variant?"*
- If this could do only ONE thing, what would it be?
- What's the 5-minute version of this product?
- What would you ship in 2 weeks that still captures the core value?

---

## Step 3: Side-by-Side Display

Present all variants with their 4-perspective notes in a clear comparison table or structured format.

**Display format:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VARIANT 1: [Name/Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Core: [One paragraph — who, what, revenue model, distribution]
Revenue: [Specific model]    Customer: [Specific segment]    Channel: [Specific channel]

EXPAND →   [2-3 sentences: ceiling + path]
SELECTIVE → [2-3 sentences: the unforgettable thing]
HOLD →     [2-3 sentences: defensibility]
REDUCE →   [2-3 sentences: essence + 2-week ship]

Competitor check: [What exists, how to differentiate]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Repeat for each variant]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANTI-CONVERGENCE CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Variant | Revenue Model | Customer Segment | Channel |
|---------|--------------|-----------------|---------|
| V1      | [model]       | [segment]        | [channel]|
| V2      | [model]       | [segment]        | [channel]|
...
✅ All variants pass anti-convergence check  OR  ⚠️ V[N] and V[M] too similar — regenerate
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After displaying:

> "Which variant resonates most? You can pick one, or tell me which elements from different variants you want to combine."

---

## Step 4: Handle User Selection

**If user picks one variant:**
- Confirm the selection
- Save to `~/.product-thinking/session.json` (add `shotgun` section)
- Announce: "Ready to run `/define` to turn this into an executable plan."

**If user wants to combine variants:**
- Ask: "Which elements from which variants? Revenue model from V2, customer segment from V1, distribution from V3?"
- Create a combined variant that passes anti-convergence with the remaining options
- Save combined variant to session.json

**Session.json update:**
```json
{
  "shotgun": {
    "selected_variant": [variant number or "combined"],
    "variant_summary": "[one sentence description of selected]",
    "variants": [
      {
        "number": 1,
        "title": "[variant name]",
        "revenue_model": "[model]",
        "customer": "[segment]",
        "channel": "[channel]",
        "description": "[paragraph]",
        "expand": "[text]",
        "selective": "[text]",
        "hold": "[text]",
        "reduce": "[text]"
      }
    ]
  }
}
```

---

## Standalone Mode (No /pressure-test data)

If session.json doesn't exist or has no `pressure_test` key:

1. Ask the user for the 3 inputs listed at the top
2. Do a quick search to understand the space:
   ```
   WebSearch: "{product idea} competitors market"
   WebSearch: "{product category} business models"
   ```
3. Proceed with variant generation — but note in the output: "No /pressure-test data available. These variants are generated without demand validation. Recommend running /pressure-test first."

---

## Why This Matters

Most founders build the default version of their idea — usually a subscription SaaS with a standard signup flow, because that's the pattern they've seen. Design Shotgun forces you to ask: what if the business model was completely different? What if the customer was different? What if the distribution was different?

The selected variant after this step is almost always different from what the founder would have built without it.
