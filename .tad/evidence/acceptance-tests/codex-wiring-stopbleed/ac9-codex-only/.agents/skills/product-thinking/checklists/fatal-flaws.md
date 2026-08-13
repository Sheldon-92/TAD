# Fatal Flaw Checklist

Universal startup killer patterns. Check these during /pressure-test Step 7 verdict.

A fatal flaw is not a risk to manage — it's a structural problem that kills most products in this category. Two or more fatal flaws = KILL verdict regardless of other evidence.

**Root-cause prior (use this to anchor F1/F2, not "most products fail").** CB Insights analyzed 431 VC-backed startup post-mortems (385 with an identifiable reason). The headline number — "ran out of capital / funding" — tops the list at **70%**, but that is the *final symptom*, not the root cause: the money ran out because nobody bought. The #1 *controllable* killer is **"no market need / poor product-market fit," cited in 43% of failures** (followed by bad timing ~29%, unsustainable unit economics ~19%). Also: **~70% of startups fail between year 2 and year 5.** So when you scan F1 (solution-in-search-of-a-problem) and F2 (interest ≠ demand), you are scanning the single most common controllable cause of death, with a real prior probability behind it — not a vague "most products fail." (Source: CB Insights, *Top Reasons Startups Fail*, https://www.cbinsights.com/research/report/startup-failure-reasons-top/ — retrieved 2026-06-13.)

---

## How to Use

During /pressure-test verdict generation:
1. Scan this list against the product idea
2. Mark each that applies
3. Include ≤3 most relevant in the verdict output

---

## The 15 Universal Startup Killers

### F1: Solution in Search of a Problem
**Pattern**: The founder built something they thought was cool, then looked for a problem it solves.
**Signal**: Can't articulate the specific moment a user realizes they need this. Can't name a specific person who has tried to solve this problem before.
**Common in**: Developer tools, AI demos, hardware gadgets.
**Test**: Can you describe the exact moment your target user says "I wish I had something that could do X"? If that moment is hypothetical, this flaw applies.

---

### F2: Assuming Interest Equals Demand
**Pattern**: Friends said they'd use it. Survey respondents said they'd pay. Followers liked the tweet.
**Signal**: No pre-payment. No waitlist. No one has asked "when is this available?"
**Brutal truth**: "I'd use that" is the polite thing to say when someone shows you their idea. It costs nothing. It means nothing.
**The commitment-currency test (operational FACT vs ASSUMPTION rule).** From Rob Fitzpatrick's *The Mom Test*: a signal is real ONLY if the prospect spent a **currency they actually value** — one of **time** (they booked a scheduled follow-up), **reputation** (they made an intro to a decision-maker / put their name on it), or **money** (a pre-order, deposit, or signed letter of intent). "Would you use this?" / "that's a great idea" costs nothing → record as **ASSUMPTION**. A booked next meeting, an intro, or a deposit → record as **FACT**. Use this as the literal decision rule whenever you label a round's evidence in `/pressure-test`. (Source: Sachin Rekhi's summary of *The Mom Test*, https://www.sachinrekhi.com/p/the-mom-test-rob-fitzpatrick — retrieved 2026-06-13.)
**PMF demand gate.** When the founder claims demand, the named benchmark is the **Sean Ellis PMF survey**: ask users "How would you feel if you could no longer use [product]?" — **≥40% answering "very disappointed"** is the must-have threshold. **10-30% means the majority can take-it-or-leave-it** (not yet PMF; iterate before scaling). This replaces hand-picked heuristics like ">100 waitlist signups". (Source: https://learningloop.io/glossary/sean-ellis-score — retrieved 2026-06-13.)
**Test**: Has anyone spent a real currency — a scheduled follow-up (time), an intro (reputation), or a deposit (money) — to signal demand? If not, this flaw applies.

---

### F3: Crowded Market Without a Wedge
**Pattern**: The space is competitive. The founder's plan is "we'll be better."
**Signal**: Can't identify a specific customer segment that existing solutions actively fail. "Better" is not a wedge.
**Brutal truth**: The three biggest players have 20x your budget, brand, and distribution. "Better" gets you nowhere. What makes you irreplaceable to a specific niche that the incumbents ignore?
**Test**: Who would switch to your product even if it was 20% worse across most dimensions, because you solve ONE thing they care about deeply that incumbents don't?

---

### F4: Pricing Without Competitive Awareness
**Pattern**: The founder chose a price without knowing what alternatives cost or what the buyer is used to paying.
**Signal**: "We haven't decided pricing yet" or "We'll figure that out later."
**Brutal truth**: Price is positioned against alternatives, not against cost. If the alternative is free (Excel, Google Sheets, a free tier), you need a very clear story for why someone pays you anything.
**Grounded unit-economics test (don't accept a price without these).** A price is only defensible if the resulting unit economics survive: target **LTV:CAC of 3:1 to 4:1** (B2B SaaS target 4:1; **median 3.6:1**, Benchmarkit 2025). **Below 1:1 = losing money on every customer**; above ~5:1 signals *under-investment* in growth (you're leaving the market to a competitor). Sanity-check growth+profit with the **Rule of 40** (revenue-growth % + EBITDA-margin % ≥ 40) — note the SaaS **median is only ~12% as of Q1 2025**, so 40 is genuinely demanding, not a floor. (Source: https://www.phoenixstrategy.group/blog/ltvcac-ratio-saas-benchmarks-and-insights — retrieved 2026-06-13.)
**Test**: What does your target customer currently spend to solve this problem? At the proposed price, is LTV:CAC ≥ 3:1? If unit economics are unknown or <1:1, this flaw applies.

---

### F5: Building for an Audience That Doesn't Pay
**Pattern**: Large potential user base, zero willingness to pay.
**Signal**: Target audience is students, consumers in developing markets, free-tier professionals, or people who have historically expected free software.
**Common in**: Consumer social apps, education apps, entertainment.
**Test**: What's the reference class of products your target user has paid for in the last year? If the answer is "nothing," this flaw applies.

---

### F6: Distribution Afterthought
**Pattern**: "We'll figure out how to reach customers after we build the product."
**Signal**: No existing audience, no distribution partnerships, no organic acquisition hypothesis, no owned channel.
**Brutal truth**: The best product without distribution is invisible. Distribution is harder than building. Founders who figure out distribution before (or while) building have a structural advantage.
**Test**: If you had a working product tomorrow, how would you get your first 100 users? Be specific. If the answer is "social media" or "word of mouth" without specifics, this flaw applies.

---

### F7: Single Point of Failure Dependency
**Pattern**: The business depends on a platform, API, or partner that could change terms, shut down access, or compete directly.
**Signal**: Revenue depends on Apple App Store, Google Play, Amazon marketplace, a single social media algorithm, or one enterprise customer.
**Common in**: Apps, browser extensions, Amazon FBA, B2B with single enterprise customer.
**Test**: If [key platform] changes its terms or fees tomorrow, what happens to your revenue? If the answer is "it collapses," this flaw applies.

---

### F8: Premature Complexity
**Pattern**: The MVP requires 6 months to build before anyone can use it.
**Signal**: "We need X first before we can test Y." Every feature seems essential. Can't describe a 2-week version.
**Brutal truth**: If you can't describe something valuable that ships in 2 weeks, your thinking about the product is still confused. Complexity is often a proxy for lack of clarity about the core value proposition.
**Test**: What's the 5-minute version of your product — the thing that takes 5 minutes to experience and delivers some core value? If you can't describe that, this flaw applies.

---

### F9: Regulatory or Legal Landmine
**Pattern**: The business model depends on behavior that is currently in a legal grey zone, or is actively being regulated.
**Signal**: Involves financial services, healthcare data, prescription products, gig workers, data privacy across jurisdictions, or content that platforms are restricting.
**Common in**: Fintech, healthtech, marketplaces, scrapers.
**Test**: Has a lawyer reviewed whether the core business model is legal in your target markets? If not, treat all compliance assumptions as unvalidated.

---

### F10: Dependency on Behavior Change
**Pattern**: The product requires users to significantly change how they work before they get value.
**Signal**: Onboarding requires importing data, connecting multiple accounts, training colleagues, or changing existing workflows before seeing results.
**Brutal truth**: Behavior change is the hardest thing to achieve in product. Every step between "user discovers product" and "user gets value" is a drop-off point.
**Test**: How many steps before your new user experiences value for the first time? If it's more than 3, this flaw applies.

---

### F11: TAM Ceiling Too Low
**Pattern**: The total addressable market is too small for a venture-scale business, or too large to be believable.
**Signal**: "Our market is X million people" without specificity, OR the realistic paying segment is under $10M/year even at 100% market share.
**Brutal truth**: If your realistic serviceable market can only support $2M ARR at scale, it's a lifestyle business — which is fine, but be honest about it. If you need venture funding, you need a credible path to $50M+ ARR.
**Test**: How many people will actually pay your price? What's the math for $10M ARR? If it requires unrealistic market share, this flaw applies.

---

### F12: Founder-Market Mismatch
**Pattern**: The founders have no relevant domain expertise, no network in the space, and no clear reason why they will out-compete domain experts.
**Signal**: Founder learned about this problem 3 months ago. No relationships with potential customers. No specific insight from domain experience.
**Test**: Why is THIS team the right team to build THIS product? If the answer is "we're technical" or "we're passionate," this flaw applies.

---

### F13: Negative Gross Margin at Scale
**Pattern**: Unit economics don't improve with scale — or get worse.
**Signal**: CAC increases as you exhaust easy acquisition channels. COGS include human labor that doesn't automate. Infrastructure costs scale linearly.
**Common in**: Services masquerading as products, marketplaces with high trust/safety costs, hardware with supply chain complexity.
**Test**: At 10x current revenue, does gross margin improve, stay flat, or worsen? If worsen, this flaw applies.

---

### F14: The "This Time It's Different" Fallacy
**Pattern**: A very similar product has failed before. The founder believes their version succeeds because of timing, technology, or execution differences.
**Signal**: Can point to 2+ failed predecessors. Justification is vague ("the market wasn't ready," "AI makes it different now").
**Not always fatal**: Markets do change. Timing matters. But the burden of proof is high — you need to articulate exactly what is structurally different, not just that technology has improved.
**Test**: Find the closest failed predecessor. What specifically killed it? Is that thing actually different now, or are you assuming it is?

---

### F15: No Path to Profitability Visible at Current Scale
**Pattern**: The business model requires significant scale before unit economics work. At current or near-term scale, money is lost on every transaction.
**Signal**: "We'll make it up in volume" or "We need to get to X users before we can charge" with no concrete path to X.
**Common in**: Consumer apps, marketplaces, platforms with two-sided subsidy requirements.
**Test**: At what specific revenue or user number do unit economics turn positive? Is there a credible plan to reach that number before running out of money?

---

### F16: Two-Sided Cold Start Without a Seeding Strategy
**Pattern**: A marketplace that cannot function below a minimum level of supply and demand — but has no plan to reach that threshold without both sides being present simultaneously.
**Signal**: When asked "why would supply join before there's demand?" the founder says "we'll recruit them" without specifying the incentive. When asked "why would demand join before there's supply?" same non-answer.
**Common in**: Service marketplaces, B2B platforms, gig economy apps, peer-to-peer lending, niche product exchanges.
**Brutal truth**: Every marketplace that succeeded solved the cold-start problem asymmetrically — they seeded one side with a specific non-monetary value proposition before charging the other side. Airbnb scraped Craigslist. OpenTable gave restaurants free scheduling software. Uber paid drivers by the hour. "We'll grow both sides simultaneously" is not a strategy.
**Take-rate reality (turn the cold-start check into a numeric one).** A marketplace only works if the take rate clears CAC on BOTH sides. Real benchmarks: **product marketplaces ~5-15%**, **service marketplaces ~15-30%**; top-100-marketplace average ~10-30%. Reference points: **Airbnb ~13-15%, Uber ~20-28%, Amazon category commissions 8-15%.** Default a starting take rate of **10-20%** and pressure-test whether supply tolerates it. If the founder's `[take rate: %]` is blank, or is set above the service-marketplace ceiling (>30%) without a reason supply would accept it, the cold-start economics don't close. (Source: https://www.sharetribe.com/marketplace-glossary/commission-take-rate/ — retrieved 2026-06-13.)
**Test**: Can you answer all of these: (1) Why would a supply-side participant join before you have significant demand — what do they get TODAY that justifies their effort? (2) At what specific supply-side density does the demand side get enough value to pay? (3) At a 10-20% take rate, do both sides' CAC pay back? If any answer is vague, this flaw applies. Also check: if you subsidize supply early, what happens when the subsidy stops? (Subsidized-side defection is the most common late-stage marketplace killer.)

---

## Severity Guide

| Flaws | Verdict Signal |
|-------|---------------|
| 0 fatal flaws | No structural killers found |
| 1 fatal flaw | PIVOT — only if the flaw can be addressed by a model/scope change. KILL if the flaw is structural (F9 legal, F13 unit economics) |
| 2 fatal flaws | KILL — two structural problems rarely have one solution |
| 3+ fatal flaws | KILL — stop immediately |

**Note**: A single F-level flaw with high severity (F9 legal, F13 negative unit economics) can be a KILL on its own.

**F12 note**: Founder-market mismatch (F12) is not fatal in isolation — domain knowledge can be acquired. It amplifies other flaws. If F12 is the only flaw, the verdict is not automatically KILL; recommend the founder build domain expertise aggressively before building the product.
