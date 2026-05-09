---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Product Thinking Capability Pack

**From:** Alex | **To:** Blake | **Date:** 2026-05-07
**Project:** Independent repo (not TAD)
**Epic:** EPIC-20260507-agent-capability-packs (parallel to web-ui-design, not a phase)

---

## 1. Task Overview

Build a **Product Thinking Capability Pack** — 3 deep skills that turn any AI agent into a product decision partner. Not templates. Not a PM toolkit. A thinking engine that searches real data, challenges assumptions, and forces decisions.

**Core idea**: GStack office-hours gave YC founders an AI partner that asks 6 brutal questions. We're extending that to: all product types (not just software) + variant generation + executable definition.

**Phase 1 target: Claude Code.** Same install.sh pattern as web-ui-design.

---

## 2. What It Combines

- GStack office-hours: adversarial 6-question diagnosis (Apache 2.0 inspiration, not copy)
- GStack design-shotgun: parallel variant generation with anti-convergence
- GStack CEO-review: 4-perspective scope analysis (expand/selective/hold/reduce)
- startup-pressure-test: verdict + fatal flaws + 2-week MVP
- last30days: real-time Reddit/HN/X/Polymarket/YouTube data
- aso-skills: App Store data via Appeeky API
- Amazon seller tools: BSR, Keepa, SP-API for ecommerce
- tam-sam-som-calculator: market sizing with real data
- Product type adapter pattern: same questions, different data sources per type

---

## 3. Architecture

### 3.1 Three Skills, Not Forty

```
/pressure-test → /shotgun → /define
```

Each skill is deep (500-800 lines), not thin (50 lines). Each connects to real external data. Each produces a decision, not a document.

### 3.2 Product Type Router (embedded in /pressure-test Step 0)

6 types, each with its own adapter:

| Type | Primary Data Sources | MVP Definition | Q4 "Narrowest Wedge" Variant |
|------|---------------------|---------------|------------------------------|
| software | last30days (Reddit/HN/Polymarket), aso-skills | 2-week deployable | "Smallest payable feature?" |
| hardware | Kickstarter scrape, YouTube unboxing, WebSearch | 3D print prototype + crowdfund page | "What can you validate without tooling?" |
| ecommerce | Amazon API (BSR/Keepa), Bright Data | 10-unit test sell | "Minimum order to prove demand?" |
| service | Upwork/LinkedIn scrape, WebSearch | 5 manual clients | "What can you do by hand for 5 people?" |
| content | last30days (YouTube/TikTok), WebSearch | 10 posts to measure engagement | "One tweet thread to test the core thesis?" |
| marketplace | last30days, competitor scrape | One side first (supply OR demand) | "Which side can you serve with Airtable?" |

### 3.3 Skill 1: `/pressure-test`

**Purpose**: Adversarial idea diagnosis. Default stance: "This probably won't work." User must prove otherwise with evidence.

```
Input: "I have an idea: ___"
  ↓
Step 0: Product Type Detection
  AskUserQuestion: 6 product types
  → Load adapter (data sources + question wording)
  ↓
Steps 1-6: Six Forcing Rounds (sequential, one at a time)
  Each round:
    a. Ask the forcing question (adversarial tone, not supportive)
    b. User answers
    c. AI searches real data using type-appropriate tool:
       - Software: last30days --reddit "{topic}" + WebSearch
       - Ecommerce: WebSearch "site:amazon.com {product} reviews"
       - Hardware: WebSearch "kickstarter {product}" + YouTube search
       - etc.
    d. AI challenges user's answer with search results
    e. Record: FACT (has evidence) vs ASSUMPTION (no evidence)
  ↓
Step 7: Verdict
  - BUILD / PIVOT / KILL (with confidence score 1-10)
  - Core Assumption: the single biggest unvalidated belief
  - Fatal Flaws: 0-3 potential killers
  - 2-Week Validation Plan: type-specific (code MVP / 3D print / test sell / etc.)
  - Evidence Summary: facts found vs assumptions remaining
```

**6 Forcing Questions** (adapted from GStack, rewritten to be product-type-generic):

1. **Demand Reality**: "What's your strongest evidence that someone actually wants this — not 'would be interested' but has tried to solve this problem already?"
2. **Status Quo**: "What is your target customer doing RIGHT NOW to solve this? How much pain/money/time does that cost them?"
3. **Desperate Specificity**: "Name one real person (with a name, job, location) who needs this most urgently. What makes their situation desperate?"
4. **Narrowest Wedge**: "{adapter.q4_variant}" — type-specific smallest version
5. **Observation**: "Have you actually watched someone struggle with this problem without helping them? What surprised you?"
6. **Future-Fit**: "If the world looks different in 3 years (AI, regulation, competition), does your product become more essential or less?"

### 3.4 Skill 2: `/shotgun`

**Purpose**: Generate 4-6 fundamentally different product variants. Not UI variants — business model variants.

```
Input: /pressure-test verdict (BUILD or PIVOT) + accumulated research data
  ↓
Step 1: Generate 4-6 Variants
  ANTI-CONVERGENCE RULE: no two variants may share the same:
    - Primary revenue model (subscription vs one-time vs marketplace cut vs freemium)
    - Target customer segment
    - Distribution channel
  Each variant = 1 paragraph: who it's for, what it does differently, how it makes money
  ↓
Step 2: 4-Perspective Review (per variant)
  For each variant, evaluate through:
    - EXPAND: "If resources were unlimited, how big could this get?"
    - SELECTIVE: "Keeping current scope, what ONE feature would make it unforgettable?"
    - HOLD: "What would make this version bulletproof?"
    - REDUCE: "Strip to absolute core — what's the essence?"
  ↓
Step 3: Side-by-side Display + User Selection
  Present all variants with 4-perspective notes
  User picks 1 (or combines elements from 2+)
```

### 3.5 Skill 3: `/define`

**Purpose**: Turn selected variant into an executable definition. 80% auto-filled from /pressure-test and /shotgun data.

```
Input: Selected variant + all accumulated research
  ↓
Step 1: Auto-Generate (NOT from blank template — from accumulated data)
  - Lean Canvas (9 blocks, pre-filled from previous steps)
  - Target Persona (from Q3 "name a real person" data)
  - MVP Scope (from Q4 "narrowest wedge" + variant REDUCE view)
  - Competitive Position (from Q2 status quo data)
  - TAM/SAM/SOM (use tam-sam-som-calculator if available)
  ↓
Step 2: User Review + Adjust
  ↓
Step 3: Type-Specific Output
  - Software → tech handoff (can feed into TAD /alex *analyze)
  - Ecommerce → product listing + pricing + supplier plan
  - Hardware → BOM estimate + prototype plan + crowdfunding brief
  - Service → service package + pricing tiers + first 10 client plan
  - Content → content calendar + distribution + monetization path
  - Marketplace → supply strategy + demand strategy + unit economics
```

---

## 4. File Structure

```
product-thinking/
├── README.md                        ← 100-150 lines
├── LICENSE                          ← MIT
├── LICENSE-ATTRIBUTION.md           ← GStack Apache 2.0, pm-skills Apache 2.0
├── CHANGELOG.md                     ← v0.1.0
├── install.sh                       ← Phase 1: Claude Code only
│
├── skills/
│   ├── pressure-test.md             ← 500-800 lines: 6 forcing rounds + verdict
│   ├── shotgun.md                   ← 300-500 lines: variant generation + 4-perspective
│   └── define.md                    ← 400-600 lines: auto-fill lean canvas + type output
│
├── adapters/                        ← Per-type data source configs
│   ├── software.md                  ← 80-120 lines
│   ├── hardware.md                  
│   ├── ecommerce.md                 
│   ├── service.md                   
│   ├── content.md                   
│   └── marketplace.md               
│
├── tools/
│   └── tool-registry.md             ← CLI/API tools + availability matrix
│
├── checklists/
│   ├── fatal-flaws.md               ← Universal startup killer checklist
│   └── per-type-validation.md       ← Type-specific validation checks
│
└── examples/
    └── pressure-test-example.md     ← Real completed pressure-test walkthrough
```

**Location**: `~/product-thinking/` (independent repo)
**Install target**: `.claude/skills/product-thinking/` (directory, not individual files)

### 3.6 Adapter Schema

Every adapter file (`adapters/{type}.md`) MUST follow this exact structure:

```markdown
# Adapter: {type}

## Data Sources (ordered by priority)
| Source | Tool | Config | Fallback |
|--------|------|--------|----------|
| {source1} | {tool or WebSearch} | ZERO_CONFIG / NEEDS_SETUP | WebSearch "{query}" |

## Question Variants
| Q# | Standard Wording | This Type's Wording |
|----|-----------------|-------------------|
| Q4 | "Smallest payable version?" | "{type-specific variant}" |

## MVP Definition
{1-2 sentences: what "2-week validation" means for this product type}

## /define Output Format
{What the final deliverable looks like for this type — section headers + key fields}
```

### 3.7 Session Persistence (Skill-to-Skill Data Flow)

Skills write intermediate data to `~/.product-thinking/session.json`:

```json
{
  "created": "2026-05-07T10:00:00Z",
  "product_type": "ecommerce",
  "pressure_test": {
    "verdict": "BUILD",
    "confidence": 7,
    "core_assumption": "...",
    "facts": [...],
    "assumptions": [...],
    "search_results_summary": "..."
  },
  "shotgun": {
    "selected_variant": 2,
    "variants": [...]
  }
}
```

Rules:
- `/pressure-test` CREATES session.json (overwrites any previous)
- `/shotgun` READS pressure_test data, WRITES shotgun data
- `/define` READS both sections
- Each skill checks: session.json exists? If not → standalone mode (ask user for context manually)
- Session.json is gitignored, ephemeral, local only

---

## 5. Implementation Notes

### 5.1 Writing Style
- **Adversarial, not supportive**: default tone is skeptical. AI must be convinced, not convince the user
- **Every question must trigger a real search**: no self-simulation. If WebSearch/last30days/API is available, USE IT
- **Verdict must have evidence basis**: BUILD/PIVOT/KILL + confidence score + evidence count
- **Adapters are lightweight**: each adapter is just data source config + question wording variants, not a separate skill

### 5.2 Tool Integration
- Zero-config tools (use immediately): WebSearch, WebFetch, last30days (Reddit/HN/Polymarket/GitHub)
- Needs-setup tools (note as optional): aso-skills (Appeeky $8/mo), Amazon SP-API, last30days advanced (X auth token)
- Skills must WORK without any setup — degrade gracefully to WebSearch-only when specialized tools unavailable

### 5.3 What NOT to Include
- No TAD terminology (Gate, Ralph Loop, Agent A/B)
- No pm-skills-style templates ("fill in this Lean Canvas")
- No passive artifacts — every output is a DECISION, not a document
- No "best practices" advice — only forcing questions + real data

### 5.5 Adversarial Tone Examples

Blake MUST embed 2-3 examples like these in pressure-test.md to calibrate the AI's tone:

**Example: Round 1 (Demand Reality) — User gives vague answer**
```
User: "A lot of people are interested in this. I've gotten positive feedback from friends."

AI: I searched Reddit (r/startups, r/SaaS) for "{product concept}" — found 0 threads
in the last 90 days. Searched HN — 0 discussions. "Positive feedback from friends"
is social politeness, not demand. Friends don't want to hurt your feelings.

Show me ONE of these:
- A Reddit/forum thread where strangers complain about this exact problem
- Someone paying money for a worse version of this
- A waitlist with >100 signups from people you don't know

Until then, this is a ASSUMPTION, not a FACT.
```

**Example: Round 4 (Narrowest Wedge) — User over-scopes**
```
User: "The MVP needs user accounts, a dashboard, integrations with Slack and email, and a mobile app."

AI: That's not an MVP. That's a Series A product. Let me search what your
closest competitor launched with... [searches Product Hunt for competitors]

{Competitor X} launched with just a Chrome extension. No accounts. No dashboard.
Pricing: $9/month. 847 upvotes on Product Hunt.

Can you ship something that small? If the answer is "no, we need all those
features" — that's a signal your value prop is too weak to stand on its own.
```

### 5.6 Adapter Thickness Expectations

| Type | Expected Lines | Reason |
|------|---------------|--------|
| software | 80-120 | Rich CLI/API tool ecosystem |
| ecommerce | 80-120 | Amazon APIs, Keepa, BSR data |
| hardware | 40-60 | Mostly WebSearch fallback, limited CLI tools |
| service | 40-60 | Mostly WebSearch + scrape |
| content | 40-60 | last30days covers YouTube/TikTok; rest is WebSearch |
| marketplace | 40-60 | Mostly WebSearch + competitor scrape |

4 of 6 adapters will be thin. This is acknowledged and acceptable for v0.1.

### 5.7 Research Notebook Available
```bash
~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n a8f77481-802c-42f5-bf29-5f66fac7c888
```
52 sources: GStack (12 files), pm-skills (12 skills), last30days, aso-skills, Amazon tools, ecommerce resources.

---

## 6. Acceptance Criteria

- [ ] AC1: pressure-test.md has 6 forcing rounds, each with question + search step + challenge step
- [ ] AC2: pressure-test.md Step 0 has product type router with 6 types
- [ ] AC3: Each adapter file maps 6 questions to type-specific data sources and search queries
- [ ] AC4: shotgun.md has anti-convergence rule (no shared revenue model + customer + channel)
- [ ] AC5: shotgun.md has 4-perspective review (EXPAND/SELECTIVE/HOLD/REDUCE) per variant
- [ ] AC6: define.md auto-fills from previous steps' data (not blank template)
- [ ] AC7: define.md has type-specific output format for all 6 product types
- [ ] AC8: tool-registry.md marks each tool as ZERO_CONFIG / NEEDS_SETUP / WEBSEARCH_FALLBACK
- [ ] AC9: fatal-flaws.md has ≥15 universal startup killer patterns
- [ ] AC10: pressure-test-example.md shows a complete walkthrough with real search results
- [ ] AC11: Zero TAD terminology (grep "Ralph Loop\|Gate [1-4]\|Agent A\|Agent B" returns 0)
- [ ] AC12: install.sh works for Claude Code (.claude/skills/)
- [ ] AC13: Total ≤ 6000 lines across all files
- [ ] AC14: Skills degrade gracefully without specialized tools (WebSearch fallback documented)
- [ ] AC15: LICENSE-ATTRIBUTION.md cites GStack (MIT), pm-skills (Apache 2.0), startup-pressure-test (verify license)
- [ ] AC16: session.json schema matches §3.7 (product_type + pressure_test + shotgun fields)
- [ ] AC17: Each adapter follows §3.6 schema (Data Sources table + Question Variants + MVP Definition + Output Format)

---

## 7. Expert Review

| Expert | Verdict | P0 | P1 | P2 |
|--------|---------|----|----|-----|
| code-reviewer | CONDITIONAL PASS | 5 | 4 | 4 |

### P0 Resolved
| # | Issue | Resolution |
|---|-------|-----------|
| P0-1 | Expert review section empty | Filled (this table) |
| P0-2 | Adapter files have no schema | Added §3.6 Adapter Schema |
| P0-3 | Skill-to-skill data flow undefined | Added §3.7 Session Persistence (session.json) |
| P0-4 | GStack license contradiction | Fixed: GStack is MIT (verified from repo README) |
| P0-5 | No adversarial tone examples | Added §5.5 Adversarial Tone Examples |

### P1 Integrated
| # | Issue | Resolution |
|---|-------|-----------|
| P1-1 | AC verification commands missing | Deferred — Blake uses intent verification (per AC Verification Drift pattern); adding spec compliance table is Phase 2 |
| P1-2 | 4/6 adapters thin (WebSearch only) | Noted in §5.6: thin adapters are 40-60 lines, acknowledged as WebSearch fallback |
| P1-3 | tam-calculator dangling ref | Clarified in §5.2: it's a deanpeters SKILL, optional, WebSearch fallback if unavailable |
| P1-4 | 5000-line budget tight | Raised to 6000 (AC13 updated)

---

## 8. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Scope | 3 deep skills, not 40 templates | pm-skills proved quantity≠quality; GStack office-hours alone beats 40 templates |
| 2 | Interaction model | Adversarial diagnosis | startup-pressure-test + GStack office-hours: skepticism > encouragement |
| 3 | Product types | 6 types with adapter pattern | Same questions, different data — universal structure, type-specific data layer |
| 4 | Data policy | Real search mandatory | Self-simulation = worthless. Every question must trigger WebSearch/API call |
| 5 | Structure | 3 separate skill files, not 1 monolith | Each skill is independently usable; /define without /pressure-test = still useful |
| 6 | Naming | "product-thinking" not "product-management" | PM is a role; thinking is what the tool does |

---

## 📚 Research Foundation

- NotebookLM notebook: `a8f77481` (52 sources)
- Research findings: `.tad/evidence/research/product-capability-pack/2026-05-07-research-findings.md`
- Key references: GStack (office-hours, design-shotgun, CEO-review), pm-skills (Triple Diamond, 40 skills as anti-pattern), startup-pressure-test, last30days-skill, aso-skills, Amazon seller tools
