# Adapter: Service

Applies to: consulting, freelance services, agencies, done-for-you services, professional services, subscription services.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| Market rate research | WebSearch `"site:upwork.com {service} hourly rate"` | ZERO_CONFIG | — |
| LinkedIn service demand | WebSearch `"site:linkedin.com/jobs {service} freelance"` | ZERO_CONFIG | — |
| Community demand signals | WebSearch `"site:reddit.com {service} hire looking for"` | ZERO_CONFIG | — |
| Competitor pricing | WebSearch `"{service category} agency pricing"` | ZERO_CONFIG | — |
| Platform rates | WebSearch `"site:fiverr.com {service} top rated"` | ZERO_CONFIG | — |

**Note**: Service validation is primarily WebSearch + direct outreach. No specialized APIs needed. The validation test is whether you can close 1-3 manual clients.

---

## Question Variants

| Q# | Standard Wording | Service-Specific Wording |
|----|-----------------|--------------------------|
| Q1 | Evidence of real demand? | "How many Upwork/Fiverr listings exist for this service? What are the top-rated providers charging? How long has the most-reviewed provider been operating? That's demand data." |
| Q2 | Current workaround? | "Who do clients hire instead today — internal staff, freelancers, agencies, no one? What does that cost them? I'll search Upwork/LinkedIn — if this service is already commoditized, you need a differentiation story." |
| Q3 | Real person? | "Name a specific person or company that would pay for this service next week if you cold-emailed them today. What's their job title, company size, and specific pain? Have you talked to them?" |
| Q4 | Narrowest wedge? | "**What can you do by hand for 5 people?** Not a product. Not a system. You, doing the work manually, for 5 clients, this month. What's that look like?" |
| Q5 | Observation? | "Have you done this work informally for free, for a friend, for yourself? What was harder than expected? What did the client actually care about vs what you thought they'd care about?" |
| Q6 | Future-fit? | "There are three commoditization threats for services: (1) Upwork/Fiverr race-to-bottom — offshore providers doing this cheaper in 18 months; (2) AI automation — LLMs replacing the delivery mechanism; (3) productization by incumbents — an agency with 500 clients packages this into a SaaS. Which of these applies most? What's your answer to it — not 'we'll be better' but a structural advantage?" |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
WebSearch: "site:upwork.com {service} jobs available"
WebSearch: "{service category} freelance demand 2024 2025"
WebSearch: "site:reddit.com {niche} looking to hire {service}"
```

**Round 2 (Status Quo)**:
```
WebSearch: "{service} agency pricing packages"
WebSearch: "how companies handle {service} internally"
WebSearch: "cost of {service} outsourced vs in-house"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "done-for-you {service} cheapest offer"
WebSearch: "{service} minimum engagement pricing"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "AI replacing {service category}"
WebSearch: "{service} automation tools 2025"
```

---

## MVP Definition

**5 manual clients**: Deliver the service manually to 5 paying clients within 30 days. No software. No systems. Just you doing the work.

**Outreach method**: Cold email, LinkedIn DMs, warm referrals, or posting in communities where your target client is active.

**Success signal**: 5 clients pay, you deliver, at least 3 ask for repeat work or refer someone else.

**What this proves**: Your service produces real value. Clients will pay the stated price. You can deliver it consistently.

---

## /define Output Format

For service businesses, `/define` produces a **Service Package + Pricing + First 10 Client Plan** (see `skills/define.md` Service section):
- Service description + guaranteed outcome
- Service package v1 (scope, deliverables, price)
- First 10 clients plan (day-by-day outreach strategy)
- Productization path (manual → systematized → delegated)
- Positioning vs competitive alternative
- Success metric (30 days)
