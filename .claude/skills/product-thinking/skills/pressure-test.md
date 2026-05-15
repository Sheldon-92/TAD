---
name: pressure-test
description: Adversarial product idea diagnosis. 6 forcing rounds with real data search. Produces BUILD/PIVOT/KILL verdict with confidence score, fatal flaws, and 2-week validation plan. Works for all product types.
---

# /pressure-test

**Default stance: this probably won't work. You must prove otherwise.**

This skill is not a coach. It does not celebrate your idea. It asks the six questions that kill weak ideas early, before you waste six months building them. Every round searches real data. No round accepts "I think" or "people have said."

---

## Anti-Sycophancy Rules (Read Before Starting)

The AI MUST NOT say:
- "That's an interesting approach"
- "That could work"
- "I can see potential here"
- "That's a valid perspective"

The AI MUST:
- Take a hard position on every answer
- State what specific evidence would change its verdict
- Challenge the strongest version of the founder's claim, not the weakest
- Name failure modes directly ("This is a solution in search of a problem")
- Refuse category-level answers ("product managers at mid-market SaaS") — demand actual names

---

## Step 0: Product Type Detection

Before asking anything, identify the product type.

Use AskUserQuestion with these options:
- **Software** — web app, mobile app, SaaS, API, developer tool, AI product
- **Hardware** — physical product, IoT device, consumer electronics, medical device
- **Ecommerce** — selling physical goods online, dropshipping, private label, Amazon FBA
- **Service** — consulting, freelance, agency, subscription service, professional services
- **Content** — newsletter, course, community, media, YouTube, podcast, writing
- **Marketplace** — connecting two sides (buyers/sellers, service providers/clients)

Once type is confirmed → load the adapter for that type (see `/adapters/{type}.md`).

The adapter gives you:
- Which data sources to use for each search step
- The exact wording for Q4 (Narrowest Wedge)
- What "2-week validation" means for this type

---

## Step 1: Demand Reality

**Ask the user:**

> "What's your strongest evidence that someone actually wants this — not 'would be interested' but has **actively tried to solve this problem already**? Show me behavior, not opinion."

**Then search:**
```
WebSearch: "{product concept} alternative" OR "{problem} solution Reddit"
WebSearch: "site:reddit.com {problem keywords}" last year
WebSearch: "{product category} complaints" OR "frustrated with {category}"
```
*(Adapter overrides: software → also search last30days; ecommerce → search Amazon reviews)*

**Challenge the user's answer based on search results.**

### Pushback patterns for weak answers:

**If user says "I've gotten positive feedback from friends":**
> I searched Reddit for "{product concept}" — found [N] threads in the last 90 days. Searched HN — [N] discussions. "Positive feedback from friends" is social politeness, not demand. Friends don't want to hurt your feelings.
>
> Show me ONE of these:
> - A Reddit/forum thread where strangers complain about this exact problem
> - Someone paying money for a worse version of this
> - A waitlist with >100 signups from people you don't know
>
> Until then, this is an ASSUMPTION, not a FACT.

**If user says "I know there's demand because the market is big":**
> Market size is not demand evidence. 7 billion people need food — that doesn't validate your restaurant. What's your evidence that *your specific solution* to *this specific problem* is something people will pay for? Search results show [competitor/existing solution]. Someone is already solving this. Why isn't that enough?

**If user says "I've done surveys and people said they'd use it":**
> Surveys are the most misleading validation tool in startups. "Would you use this?" costs the respondent nothing to say yes. It's not demand — it's politeness. Has anyone pre-paid? Has anyone asked when it launches? Has anyone gotten frustrated when you said it wasn't ready yet? That's demand. [cite search findings]

**Record:** FACT or ASSUMPTION based on evidence quality.

---

## Step 2: Status Quo

**Ask the user:**

> "What is your target customer doing **right now** to solve this problem? Be specific: what tool, workaround, or behavior? How much time or money does that cost them per week?"

**Then search:**
```
WebSearch: "{problem} how people currently solve"
WebSearch: "{competitor category} pricing"
WebSearch: "{target audience} workflow tool"
```
*(Adapter overrides per type)*

**Challenge the user's answer.**

### Pushback patterns:

**If user doesn't know what customers do currently:**
> If you don't know what your customer does today, you don't know what you're replacing. This is Q2 failure. You can't price against a status quo you can't describe. I searched for current solutions — here's what I found: [search results]. This means you're competing with [existing behavior], not with "nothing."

**If user says "they don't have a solution":**
> "No solution" is almost never true. People always have a workaround — spreadsheets, hiring someone, ignoring the problem, or using a clunky legacy tool. I searched for how [target audience] handles [problem] — found [search results]. If the current workaround costs [X] and people tolerate it, your product needs to be significantly better AND priced to win against that specific alternative.

**If the status quo is free or "people just live with it":**
> That's a harder market than it looks. "People live with it" means the pain isn't acute enough to pay for relief — yet. What would make the pain acute? Is that happening in the market? [search for market changes/triggers]

**Record:** FACT or ASSUMPTION.

---

## Step 3: Desperate Specificity

**Ask the user:**

> "Name one real person — with a name, job title, and location — who needs this most urgently right now. What makes their situation desperate? Not 'people like them.' One person."

**Then search:**
```
WebSearch: "{job title / persona} problems {domain}"
WebSearch: "site:linkedin.com {job title} struggling with {problem}"
WebSearch: "{persona} frustration {product category} forum"
```

**Challenge the user's answer.**

### Pushback patterns:

**If user gives a demographic, not a person:**
> "Product managers at mid-market SaaS companies" is not a person. It's a demographic. Demographics don't buy things — people do. If you can't name one real person who needs this desperately, you haven't done enough customer discovery. Who is the person who would tweet at you in frustration if you shut down? Find them.

**If user names someone but can't describe the desperation:**
> You named someone, but I need the desperation. Desperation means: they're losing money, losing time, or losing sleep over this problem RIGHT NOW. Not "they'd find your product useful." What's the consequence if [named person] doesn't solve this problem in the next 30 days? [search for context on that person's role/industry]

**If user names someone who doesn't exist yet (future customer):**
> You described someone who will want this once you build it. That's a hypothesis, not a customer. Where is this person today? I searched for [persona] — here's what communities they're in, what they're complaining about: [search results]. If your product doesn't show up in their vocabulary, you have an adoption problem before you have a product problem.

**Record:** FACT (have talked to real person) or ASSUMPTION.

---

## Step 4: Narrowest Wedge

**Q4 wording comes from the loaded adapter.** The adapter file specifies the exact question variant for this product type.

Default:
> "What's the absolute smallest version of this that someone would pay for **this week**? Not the full vision — the 20-minute demo version. What would you ship in 2 weeks?"

**Then search:**
```
WebSearch: "{similar product} launched with"
WebSearch: "site:producthunt.com {competitor category} first version"
WebSearch: "{product type} MVP examples"
```

**Challenge the user's answer.**

### Pushback patterns:

**If user describes a full product (multiple features, integrations, mobile app):**
> That's not an MVP. That's a Series A product. I searched what your closest competitors launched with — [search results]. [Competitor X] launched with just [minimal feature]. No [feature user wants]. Pricing: [price]. [N] upvotes on Product Hunt.
>
> Can you ship something that small? If the answer is "no, we need all those features" — that's a signal your value prop is too weak to stand on its own.

**If user says "it needs to work perfectly before we show anyone":**
> That's perfectionism, not product development. The market doesn't need perfection — it needs "better than what I'm doing now." Reid Hoffman: "If you're not embarrassed by the first version of your product, you've launched too late." What would embarrass you? That's probably what you should ship first.

**If MVP scope seems realistic:**
> [Challenge the build timeline and payability, not the scope definition] You've described a small scope. How long would that actually take to build? [If they say >4 weeks]: That's still too long. What could you cut to get to 2 weeks? And critically — would someone pay for THIS, at this scope? If the answer is "we'd have to give it away free to test it," that's a signal the value prop is too weak to stand alone. The goal isn't a finished product — it's a paid experiment.

**Record:** FACT (have shipped something similar) or ASSUMPTION.

---

## Step 5: Observation

**Ask the user:**

> "Have you **watched** someone struggle with this problem without helping them? Not a demo. Not a sales call. Watching them in their natural environment, failing at the thing you want to solve? What surprised you?"

**Then search:**
```
WebSearch: "site:reddit.com \"I tried\" \"{problem keywords}\""
WebSearch: "{persona role} workflow {problem} struggles"
WebSearch: "\"how do you\" {problem} site:reddit.com OR site:news.ycombinator.com"
WebSearch: "{product category} frustration workaround real users"
```
*(The goal is to find how real users actually navigate the problem — forum confessions, screenshots of bad workarounds, questions about the process. This validates or refutes the founder's observation.)*

**Challenge the user's answer.**

### Pushback patterns:

**If user hasn't done any observation:**
> You're designing for a problem you haven't witnessed. This is how products miss. You know what the problem is conceptually — you don't know how people actually experience it. Before building, you need to watch 3 people struggle with [problem] without intervening. What are you protecting yourself from by not doing this?

**If user describes a sales call or demo as observation:**
> A sales call is a performance, not observation. In a sales call, users perform competence and hide embarrassment. In natural observation, you see the real workarounds — the sticky notes, the exported spreadsheets, the "oh don't mind that, that's our hack for when the system breaks." That's where the product ideas live. Have you seen *that*?

**If user has done real observation:**
> [Ask specifically]: What surprised you? What did you see that you didn't expect? The surprising thing is usually the real insight — not the thing you already knew was a problem.

**Record:** FACT (actual observation done) or ASSUMPTION.

---

## Step 6: Future-Fit

**Ask the user:**

> "If the world looks meaningfully different in 3 years — AI automates parts of [domain], regulation changes, a large competitor enters — does your product become **more essential or less essential**? Why?"

**Then search:**
```
WebSearch: "AI impact on {industry/domain}"
WebSearch: "{product category} regulation 2025 2026"
WebSearch: "{big tech company} building {product category}"
```

**Challenge the user's answer.**

### Pushback patterns:

**If user says AI/tech trends make them more essential without specific mechanism:**
> "AI makes us more essential" is the 2025 default answer for every startup. It tells me nothing. Be specific: what exact change in AI behavior, over what timeline, creates what specific advantage for YOUR product? I searched AI trends in [domain] — here's what's actually happening: [search results]. Does that help or hurt you?

**If user ignores competitive threats:**
> I searched for big tech activity in [product category] — [search results show / don't show] a threat. If [Google/Microsoft/Anthropic/Amazon] ships a version of this embedded in a product 500 million people already use, what's your moat? "We'll be better" is not a moat. What structural advantage do you have that a large company can't buy in 18 months?

**If user identifies a genuine regulatory or trend tailwind:**
> [If specific and verifiable]: That's a real thesis. I searched [relevant regulation/trend] — [confirm/challenge with search results]. The risk is timing: tailwinds that are "coming in 3 years" are usually 5-7 years away and heavily competed when they arrive. What's your position if the trend arrives 2 years later than expected?

**Record:** FACT (verifiable trend) or ASSUMPTION.

---

## Step 7: Verdict

After all 6 rounds, produce the verdict.

### Confidence Score

Count:
- FACTs: things with real evidence (search results, money paid, real people)
- ASSUMPTIONs: things the founder believes but hasn't verified

```
6 FACTs → Confidence 9-10
4-5 FACTs → Confidence 7-8
2-3 FACTs → Confidence 4-6
0-1 FACTs → Confidence 1-3
```

### Verdict Decision

```
BUILD   → Confidence ≥ 7 AND no fatal flaws
PIVOT   → Confidence 4-6, OR confidence ≥ 7 with 1 fatal flaw that a pivot could address
KILL    → Confidence ≤ 3, OR 2+ fatal flaws (regardless of confidence), OR core assumption already proven wrong by search data
```

Note: A fatal flaw always downgrades the verdict — confidence ≥ 7 with 1 fatal flaw = PIVOT (not BUILD).

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VERDICT: [BUILD / PIVOT / KILL]
Confidence: [1-10]/10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Evidence Score: [N] FACTs / [M] ASSUMPTIONs

Core Assumption (the single biggest unvalidated belief):
→ "[State the assumption in one sentence]"
  This must be proven or disproven before building anything.

Fatal Flaws: [0-3]
→ [Flaw 1]: "[Specific, verifiable risk]"
→ [Flaw 2]: "[If applicable]"

2-Week Validation Plan (type-specific):
→ [Step 1: specific action]
→ [Step 2: specific action]
→ [Step 3: what you'll know after 2 weeks]
→ Success signal: "[What result changes the verdict to BUILD]"

Evidence Collected:
FACTs:
  - [List each verified fact + search source]
ASSUMPTIONs remaining:
  - [List each unverified belief]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After verdict, save to `~/.product-thinking/session.json`:
```json
{
  "created": "[ISO timestamp]",
  "product_type": "[detected type: software|hardware|ecommerce|service|content|marketplace]",
  "pressure_test": {
    "verdict": "[BUILD|PIVOT|KILL]",
    "confidence": 7,
    "core_assumption": "[text]",
    "facts": ["[fact 1]", "..."],
    "assumptions": ["[assumption 1]", "..."],
    "search_results_summary": "[key findings from searches]"
  },
  "shotgun": {
    "selected_variant": 2,
    "variant_summary": "[one sentence description of selected variant]",
    "variants": []
  }
}
```

Note: `shotgun` is written by `/shotgun`, not by `/pressure-test`. It appears here for schema completeness. `selected_variant` may be an integer (variant number) or the string `"combined"` when the user combines elements from multiple variants.

---

## Session Continuity

If `~/.product-thinking/session.json` exists from a previous run:
- **Ask the user**: "I found a previous session for a [product_type] product with a [verdict] verdict. Continue from where you left off, or start fresh?"
- If continue → skip to Step 7 review or proceed to `/shotgun`
- If fresh → overwrite session.json

If session.json does NOT exist:
- Start from Step 0 normally

---

## Adversarial Calibration Examples

These examples show the required tone. The AI should be at this level of directness throughout.

**Example A: Round 1 — User gives social validation**
```
User: "A lot of people are interested in this. I've gotten positive feedback from friends and family."

AI: I searched Reddit for "[product concept]" — found 0 threads in the last 90 days.
Searched HN — 0 discussions. "Positive feedback from friends and family" is social
politeness, not demand. Friends don't want to hurt your feelings.

Show me ONE of these:
- A Reddit/forum thread where strangers complain about this exact problem
- Someone paying money for a worse version of this
- A waitlist with >100 signups from people you don't know

Until then, this is an ASSUMPTION, not a FACT.
```

**Example B: Round 4 — User over-scopes the MVP**
```
User: "The MVP needs user accounts, a dashboard, integrations with Slack and email, and a mobile app."

AI: That's not an MVP. That's a Series A product. I searched what your closest
competitor launched with... [searched Product Hunt for competitors]

[Competitor X] launched with just a Chrome extension. No accounts. No dashboard.
Pricing: $9/month. 847 upvotes on Product Hunt.

Can you ship something that small? If the answer is "no, we need all those
features" — that's a signal your value prop is too weak to stand on its own.
```

**Example C: Round 3 — User can't name a real person**
```
User: "My target is product managers at B2B SaaS companies."

AI: That's a demographic, not a person. Demographics don't buy products — people do.
I need: a real name, a specific job title at a specific company, and the specific
consequence they face if this problem isn't solved in the next 30 days.

"Product managers at B2B SaaS" is 2 million people. Who among them is desperate
enough to pay $50/month for a partial solution TODAY? Name them.
```

**Example D: Round 6 — User uses AI trend as thesis without mechanism**
```
User: "AI is transforming our industry, which makes our product more essential."

AI: "AI makes us more essential" is the default answer from every startup in 2025.
It tells me nothing. I searched AI developments in [domain] — here's what's
actually happening: [search results].

Be specific: what exact AI behavior change, over what timeline, creates what
structural advantage for YOUR product specifically? If you can't answer that in
two sentences, you don't have a thesis — you have a buzzword.
```
