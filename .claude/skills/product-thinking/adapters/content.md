# Adapter: Content

Applies to: newsletters, YouTube channels, podcasts, courses, communities, media businesses, writing, social media accounts.

---

## Data Sources (ordered by priority)

| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| YouTube topic demand | last30days `--youtube "{topic}"` | ZERO_CONFIG | `WebSearch "youtube {topic} views subscribers"` |
| TikTok trend signals | last30days `--tiktok "{topic}"` | ZERO_CONFIG | `WebSearch "tiktok {topic} trending"` |
| Reddit niche communities | last30days `--reddit "{topic}"` | ZERO_CONFIG | `WebSearch "site:reddit.com {topic} community"` |
| Newsletter market | WebSearch `"substack {topic} subscribers"` | ZERO_CONFIG | — |
| Competitor content performance | WebSearch `"{creator} subscribers revenue"` | ZERO_CONFIG | — |
| Podcast market | WebSearch `"chartable {podcast category} top"` | ZERO_CONFIG | — |

---

## Question Variants

| Q# | Standard Wording | Content-Specific Wording |
|----|-----------------|--------------------------|
| Q1 | Evidence of real demand? | "Who already covers this topic? How many YouTube/newsletter subscribers do they have? If nobody covers it, that's a warning sign — not an opportunity. If people already succeed in this space, that's demand validation." |
| Q2 | Current workaround? | "Where does your target audience currently get information on this topic? Which subreddits, which YouTubers, which newsletters? Why aren't those enough?" |
| Q3 | Real person? | "Name one person who would subscribe on day 1. What content do they consume today? What do they still want that no one gives them? Have you talked to them?" |
| Q4 | Narrowest wedge? | "**One tweet thread to test the core thesis.** Not a newsletter. Not a YouTube channel. One piece of content that, if it gets traction, proves people want more. What is it? Write the headline now." |
| Q5 | Observation? | "Have you spent time in the communities where your audience lives — reading threads, not posting? What questions come up repeatedly that no one answers well?" |
| Q6 | Future-fit? | "Will AI-generated content flood this niche in 2 years and commoditize it? If yes — what human element (point of view, lived experience, network) makes your content irreplaceable?" |

---

## Search Queries per Round

**Round 1 (Demand)**:
```
last30days --youtube "{topic}" --days 90
WebSearch: "{topic} newsletter substack top"
WebSearch: "best {topic} YouTube channel subscribers"
```

**Round 2 (Status Quo)**:
```
WebSearch: "site:reddit.com {topic} subreddit"
WebSearch: "{topic} podcast top ranked"
WebSearch: "{similar creator} revenue business model"
```

**Round 4 (Narrowest Wedge)**:
```
WebSearch: "{thesis as question} site:twitter.com"
WebSearch: "{controversial claim in niche} viral"
```

**Round 6 (Future-Fit)**:
```
WebSearch: "AI content {niche} flooding"
last30days --reddit "AI replacing {content type}"
```

---

## MVP Definition

**10 posts to measure engagement**: Publish 10 pieces of content over 2-4 weeks across your primary channel. No monetization yet. Measure: open rates (newsletter), comments/shares (YouTube/social), follower growth rate.

**Success signal**: At least 1 piece gets organic sharing from non-followers. Engagement rate exceeds platform average. People ask when the next one comes.

**What this proves**: The thesis resonates. The format works. There's an audience.

---

## /define Output Format

For content businesses, `/define` produces a **Content Calendar + Distribution + Monetization Path** (see `skills/define.md` Content section):
- Topic (specific niche, not broad category)
- Core thesis (the one non-obvious idea that makes this different)
- First 10 posts content calendar
- Distribution (primary channel + first 1000 audience strategy)
- Monetization path (months 1-12)
- Competitive position (why this POV is unclaimed)
