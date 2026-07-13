---
name: NotebookLM Research Methodology — Lessons Learned
description: GitHub-First sourcing, question format rules, source quality > quantity. From 2026-05-07 web-ui-design session.
type: feedback
originSessionId: 810b4748-17e1-42fa-b97c-c0b0625bfebb
---
## Rule: GitHub sources first, deep research last

**Why:** 2026-05-07 session — deep research ran first → 350 SEO articles (90% duplicates). User corrected 3 times before reaching useful depth. GitHub awesome-lists + company repos + tool repos are 100x higher signal-to-noise than search engine articles.

**How to apply:**
1. Search GitHub awesome-lists FIRST (`site:github.com awesome {topic}`)
2. Explore sub-pages (not just README — use `gh api repos/{org}/{repo}/git/trees/main?recursive=1` to find key .md files)
3. Add real company repos (how production systems actually work)
4. Add tool official repos
5. Deep research ONLY as gap-filler when Phase 1-3 sources leave blanks

## Rule: 10 curated repos > 350 articles

**Why:** NotebookLM has ~300 source limit. If articles fill it first, high-value GitHub repos can't be added.

## Rule: Question format must have specificity anchor

**Why:** "What are best practices?" → textbook answer. "From the Shopify Polaris repo: what naming convention do they use?" → actionable answer.

✅ "From [source]: what specific [thing]?"
✅ "What CLI tools can an agent actually run for [X]?"
❌ REJECT "What are best practices for X?"
❌ REJECT "How should we approach X?"

## Rule: Always check AI agent capability boundary before researching tools

**Why:** web-ui-design research initially recommended GUI-only tools the agent can't use. Must identify CAN DO vs CANNOT DO before sourcing.
