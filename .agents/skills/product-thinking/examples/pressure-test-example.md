# Pressure Test Example: AI Meeting Summarizer for Developers

**Product type**: Software
**Date**: 2026-Q2
**Verdict**: KILL (2 fatal flaws → KILL regardless of confidence)

This is a complete walkthrough of a /pressure-test session. The founder proposes an AI tool that automatically summarizes Slack threads and meeting transcripts for developers who want to catch up on long threads.

---

## Step 0: Type Detection

> What type of product is this?

Founder selects: **Software**

Adapter loaded: `adapters/software.md`
- Primary search tools: last30days (Reddit/HN), WebSearch, Product Hunt
- Q4 variant: "What's the smallest payable feature?"

---

## Round 1: Demand Reality

**AI asks:**
> "What's your strongest evidence that someone actually wants this — not 'would be interested' but has actively tried to solve this problem already? Show me behavior, not opinion."

**Founder answers:**
> "I've had a lot of developers tell me they spend too much time catching up on Slack. And I personally hate it. I've gotten a lot of positive feedback when I describe the idea."

**AI searches:**
```
last30days --reddit "slack thread summarizer" --days 90 → 2 threads found
last30days --hn "slack summarize" --days 180 → 0 threads
WebSearch: "site:reddit.com/r/devops slack summarizer" → 8 threads from past year
WebSearch: "slack summary tool AI alternatives" → Otter.ai, Read.ai, Notta, 12+ competitors
```

**AI responds:**
> I searched Reddit and HN for demand signals. Here's what I found:
>
> - 2 Reddit threads in 90 days asking about Slack summarization (r/devops, r/productivity). Both got 3-7 responses — low engagement.
> - 0 HN discussions in 6 months.
> - Competitors already exist: Read.ai ($19.75/user/mo), Otter.ai ($17/mo), Notta ($8/mo), and at least 8 others.
>
> "Developers telling you they spend too much time on Slack" is the same as saying "people don't like doing dishes." It's a real pain. It does not validate demand for YOUR solution. 12+ products exist. Why aren't developers using them?
>
> Apply the commitment-currency test (The Mom Test): "they told me" costs them nothing → ASSUMPTION. A scheduled call, an intro, or a deposit would be a FACT. None present yet.
>
> And the named PMF gate: have you run the Sean Ellis survey — "how would you feel if you could no longer use this?" ≥40% "very disappointed" = product-market fit. You have 0%; you don't have a product yet. "Positive feedback" is not the 40% threshold.
>
> The question is not "does this problem exist" — it does. The question is "why has no one solved it well enough that you'd know about it?" That's the real research you haven't done yet.
>
> **ASSUMPTION** — not FACT. Show me why existing solutions fail before assuming the market wants another one.

**Recorded**: ASSUMPTION (social validation only, competitors exist and aren't winning)

---

## Round 2: Status Quo

**AI asks:**
> "What tool, script, or manual process does your target developer use today? Name the tool. Give me the pricing page URL."

**Founder answers:**
> "Most developers I know just scroll through Slack manually or ask a colleague to summarize. They don't use any tool."

**AI searches:**
```
WebSearch: "Read.ai pricing" → $19.75/user/month, 10,000+ customers
WebSearch: "developer Slack workflow 2025 survey" → StackOverflow survey: 82% of devs use Slack
WebSearch: "Slack AI summarize feature" → Slack launched native AI summaries in 2024 for paid plans
```

**AI responds:**
> Wait — Slack itself launched AI summaries in 2024. It's built into paid Slack plans (Pro $8.75/user/mo, Business+ $15/user/mo).
>
> Before going further: does your product solve a problem that Slack's native AI feature doesn't already solve?
>
> I also found: Read.ai has 10,000+ customers at $19.75/user/month. That means someone has already captured this market. That's not a tailwind for you — that's a closed door. And the unit economics have to clear LTV:CAC ≥ 3:1 against an incumbent that already amortized its CAC — paying to pull a user off a working tool pushes your payback past the 18-month challenged-economics line. Read.ai spent 3+ years and significant capital to get those customers. You're starting at zero, competing with:
> (a) Slack's native feature (zero extra cost for existing paid subscribers)
> (b) 12+ entrenched competitors with established user bases and integrations
>
> "Developers just scroll manually" is not accurate — 10,000+ Read.ai customers clearly don't. You have not found an underserved market. You've found a market that's already been fought over and is being commoditized by the platform itself.
>
> **ASSUMPTION** on your differentiation. FACT that the market is occupied and moving against you.

**Recorded**: FACT (demand exists, but competitive landscape changes everything)

---

## Round 3: Desperate Specificity

**AI asks:**
> "Name a specific developer — first name, job title, company type, location — who would use this in production today. What's their current stack? What makes their situation desperate?"

**Founder answers:**
> "Like, a senior backend engineer at a Series B startup. Maybe in San Francisco. They're on Slack all day and have too many threads."

**AI responds:**
> That's a demographic. I need a person.
>
> "Senior backend engineer at a Series B startup in San Francisco" is approximately 15,000 people. Which one of them is desperate? Desperate means: they're losing 2+ hours/day to this problem. They've already tried at least 2 solutions that didn't work. They would pay $50/month tomorrow if you told them it was available.
>
> You described someone who "is on Slack all day." That's everyone with a knowledge job. "Too many threads" — same. That's not desperation, that's mild annoyance.
>
> Here's my concern: if your target user is a developer at a company with Slack Pro, Slack's own AI summaries already exist. The developers who are *most* desperate are probably at companies that haven't paid for Slack Pro — which means they're also less likely to pay for your tool.
>
> Name a real person, or this remains an assumption.

**Recorded**: ASSUMPTION (no specific desperate persona identified)

---

## Round 4: Narrowest Wedge

**AI asks:**
> "What's the smallest payable feature? Not the product — one workflow, one integration, one script. What would someone pay $9/month for today?"

**Founder answers:**
> "I'm thinking a Chrome extension that summarizes the current Slack thread you're looking at. One button, instant summary. That's it."

**AI searches:**
```
WebSearch: "site:producthunt.com Slack summarizer Chrome extension"
→ Found: 3 Chrome extensions for Slack summarization. Top one: 4.2 stars, 500+ installs.
WebSearch: "Slack summarize thread extension free"
→ Multiple free options found, including open-source projects on GitHub
```

**AI responds:**
> That's a real MVP. I'll give you that — it's small, specific, and buildable in 2 weeks.
>
> But: I found 3 Chrome extensions for this already, including at least 1 with 500+ installs. And there are free open-source options.
>
> The question is not "can you build this" — you can. The question is: why would someone pay $9/month for yours when there are free alternatives?
>
> If your answer is "mine will be better," that's not a wedge. You need a specific reason why the existing solutions fail a specific type of user.
>
> **FACT** — this is buildable. But "smallest payable feature" is unclear without differentiation.

**Recorded**: PARTIAL FACT (MVP is achievable; differentiation is the real gap)

---

## Round 5: Observation

**AI asks:**
> "Have you watched a developer use their current Slack workflow without helping them? What workarounds did they invent that you didn't expect?"

**Founder answers:**
> "I've talked to about 6 developers and they all say the same thing — too many threads, hard to keep up."

**AI responds:**
> Talking to 6 developers is customer discovery, not observation. In a conversation, developers describe the problem conceptually. In observation, you'd see the actual behavior.
>
> For example: Do they mute channels and check them once a day? Do they rely on colleagues to surface key messages? Do they use Slack's own search? Do they screenshot threads into Notion? Do they have bots that ping them on keywords?
>
> I'd bet at least 3 of those 6 developers have a workaround they didn't mention in the conversation — because they don't think of it as a workaround, they think of it as "just how I use Slack."
>
> Those workarounds are where the real product insight is. Without observing them, you're designing for the problem people describe, not the problem they actually have.
>
> **ASSUMPTION** — customer discovery done, not observation.

**Recorded**: ASSUMPTION (talked to users, didn't observe them)

---

## Round 6: Future-Fit

**AI asks:**
> "If LLMs get 10x better in 2 years and can write code for free — does your product become more essential or obsolete? Why?"

**Founder answers:**
> "AI getting better is good for us — our summaries will get better too."

**AI searches:**
```
WebSearch: "Slack AI features 2025 roadmap" → Slack's native AI is being expanded; Salesforce integrating deeply
WebSearch: "OpenAI Slack integration" → OpenAI partners with Slack, ChatGPT integration announced
```

**AI responds:**
> Here's the structural risk: Slack + Salesforce (which owns Slack) + OpenAI are all investing in this exact feature. In 2 years, every Slack paid plan will likely include better AI summarization as a default feature.
>
> "Our summaries get better with better AI" is true but irrelevant — Slack's built-in summaries also improve with better AI, and they have zero additional cost to users.
>
> Your product being "better" requires users to pay more for better summarization when they already have adequate summarization for free.
>
> This is the structural threat: you're building a feature, not a product. When Slack ships it better, you're gone.
>
> **ASSUMPTION** → upgraded to **FACT (negative)**. The future direction of the market is known, and it disfavors your current positioning.

**Recorded**: FACT (negative) — market is moving toward making this a free commodity

---

## Step 7: Verdict

**Evidence Score**: 2 FACTs / 4 ASSUMPTIONs (one FACT is negative)

**Confidence**: 5/10

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VERDICT: KILL
Confidence: 5/10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Evidence Score: 2 FACTs / 4 ASSUMPTIONs
(Note: 1 FACT is negative — market is moving against this positioning)

Why KILL (not PIVOT): 2 fatal flaws → KILL regardless of confidence.
Two structural problems rarely have one solution. Confidence 5/10 does
NOT rescue this — the decision rule is "2+ fatal flaws = KILL (regardless
of confidence)." A single pivot cannot simultaneously create a wedge in a
12+ competitor market AND remove the platform-dependency on Slack.

Core Assumption (biggest unvalidated belief):
→ "Developers will pay for AI Slack summarization when Slack's own AI and
   free alternatives already exist."
This is already contradicted by the negative-FACT search data.

Fatal Flaws: 2 → KILL
→ F3: Crowded market without a wedge — 12+ competitors including Slack's
  own native feature. "Better" is not a wedge.
→ F7: Single point of failure dependency — the product's value is
  contingent on Slack not improving its built-in AI, which they are
  actively doing.

What KILL means here: stop building THIS product (general Slack/meeting
summarization for developers). KILL is not "give up" — it's "this exact
framing is dead; the next move is fresh problem discovery, not a patch."
→ Do NOT spend 2 weeks validating a tweak to summarization. The two fatal
  flaws are structural, not addressable by a scope change.
→ Instead, run problem-discovery interviews unanchored to summarization:
  talk to 5 developers about where they actually lose hours, with NO
  product in hand. Recruit from r/devops / r/sre threads complaining about
  tooling and SREs posting incident postmortems on LinkedIn.
→ If a sharp, un-served, willing-to-pay problem emerges, that becomes a
  NEW /pressure-test run on a NEW idea — not a pivot of this one.

Evidence Collected:
FACTs:
  - 10,000+ customers paying for Slack summarization tools (Read.ai) — demand exists
  - Slack, Salesforce, OpenAI actively building this feature into the platform

ASSUMPTIONs remaining:
  - That developers would pay for your summarization over free/built-in options
  - That a specific sub-niche has unmet needs the incumbents don't serve
  - That you have a specific person who is desperate for this (no persona)
  - That you can differentiate from 12+ established competitors
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## What Happened After This Session

The founder accepted the KILL and shelved the summarization product entirely — no two-week patch, no attempt to bolt a wedge onto a dead framing. Instead they ran problem-discovery interviews with NO product in hand, asking developers where they actually lose hours. A specific pattern surfaced: **incident postmortem workflows**. After production incidents, on-call engineers needed to reconstruct what happened across Slack, PagerDuty, Datadog, and GitHub — and Slack's native summary only covered Slack.

That discovery became a **brand-new idea** — a tool specifically for incident reconstruction that aggregates across 4-5 dev tools, not general Slack summarization — and the founder ran a fresh `/pressure-test` on it. That new idea had real desperation (on-call engineers losing 3-4 hours per incident on reconstruction), clear willingness to pay (companies budget for incident tooling), and no direct competitor, so it scored very differently.

The pressure test killed the right thing. KILL didn't mean "give up" — it meant "this exact product is dead; go find a real problem." The new product was not a pivot of the old one; it was a different product that survived its own pressure test.
