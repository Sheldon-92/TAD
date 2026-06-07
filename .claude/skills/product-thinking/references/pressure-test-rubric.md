# Pressure-Test Rigor Rubric (product-thinking)

> **verdict_shape: categorical** — this rubric assigns a RIGOR band, not a numeric score.
> Bands: `rigorous` (→ Gate verdict PASS) · `partial` (→ PARTIAL) · `superficial` (→ FAIL).
>
> **What this rubric scores:** the RIGOR of a `/pressure-test` analysis — how
> adversarially and evidentially the idea was interrogated.
>
> **What this rubric does NOT score:** the BUILD/PIVOT/KILL conclusion. The Gate judges
> RIGOR, never the content conclusion. **A rigorously-argued KILL is `rigorous` (PASS).**
> A hand-wavy, sycophantic BUILD is `superficial` (FAIL).
>
> **Decoupling firewall** (Phase-1 Gate-3 categorical branch, `.claude/skills/gate/SKILL.md`
> `judge_prompt_by_shape.categorical.decoupling_firewall`): band criteria are conclusion-neutral;
> the judge emits `band:` (with per-dimension justification) BEFORE `content_verdict:`; and a
> swap test guards against conclusion-anchoring (see §C).

This rubric is **self-contained**: a judge can score an artifact given ONLY this rubric path
plus the artifact path. No producer context, no session history, no interview transcript
beyond what the artifact itself records is required or permitted.

---

## How to Use (Judge Procedure)

1. Read the artifact (the `/pressure-test` output: the round-by-round diagnosis plus the
   final verdict block).
2. Score each of the 5 rigor dimensions D1–D5 against the criteria below. Assign each
   dimension exactly one of: `rigorous` | `partial` | `superficial`.
3. Apply the **Band Decision Tree** (§B) to aggregate the 5 dimension scores into one band.
4. Apply the **Swap Test** (§C) as a final self-audit before committing the band.
5. Emit per the **Judge Output Contract** (§D) — `band:` (with justification) ABOVE
   `content_verdict:`, then the derived `verdict:` line.

Scope discipline: score ONLY rigor. If you find yourself crediting the analysis because you
agree with its BUILD/PIVOT/KILL conclusion (or penalizing it because you disagree), stop and
re-score on the dimension criteria alone.

---

## §A. The 5 Rigor Dimensions

Each dimension has three mutually-exclusive criteria. Pick the lowest band any criterion
forces (i.e. if the evidence matches `partial` on one clause and `superficial` on another,
the dimension is `superficial`). When in genuine doubt between two bands, choose the LOWER —
this is a discrimination instrument, not a participation award.

---

### D1 — Adversarial Rigor  *(load-bearing — see §B)*

**Source:** `.claude/skills/product-thinking/skills/pressure-test.md`
- *"Default stance: this probably won't work. You must prove otherwise."* (L8)
- Step 0 → Step 6 = **6 forcing rounds** (Demand Reality, Status Quo, Desperate Specificity,
  Narrowest Wedge, Observation, Future-Fit).
- Anti-Sycophancy Rules (L14–28): MUST take a hard position on every answer; MUST challenge
  the **strongest** version of the claim; MUST refuse category-level answers and demand
  actual names ("product managers at mid-market SaaS" is rejected at L27/L139).

| Band | Criteria |
|------|----------|
| **rigorous** | ~6 forcing rounds actually run (Demand → Future-Fit). The analysis takes a HARD position on each round (states what would change its verdict), and pushes back on at least one weak answer. It challenges the STRONGEST version of the idea, not a strawman. It refuses category-level answers — when a demographic is offered it demands a real named person / company / thread. |
| **partial** | 3–5 rounds present, OR rounds present but pushback is soft (accepts answers without challenge on most rounds), OR it interrogates only weak/peripheral claims and never confronts the strongest claim, OR it lets a category-level answer ("SMBs", "developers") stand without demanding a real name. |
| **superficial** | ≤2 rounds, OR no genuine adversarial pushback at all (a single encouraging pass, "that could work" / "interesting approach" tone — the exact phrasings the anti-sycophancy rules forbid at L16–20), OR every founder answer is accepted at face value. A thin, agreeable single-answer analysis lands here. |

---

### D2 — Evidence Grounding

**Source:** `.claude/skills/product-thinking/skills/pressure-test.md`
- Every round has a `**Then search:**` block (Steps 1–6, e.g. L59–63, L96–101) — *"Every
  round searches real data. No round accepts 'I think' or 'people have said.'"* (L10–11).
- *"Record: FACT or ASSUMPTION based on evidence quality."* (L86, L117, L147, L180, L212, L242).
- Behavior over opinion: Step 1 demands *"has actively tried to solve this problem already?
  Show me behavior, not opinion."* (L56); *"'I'd use that' … costs nothing. It means nothing"*
  (fatal-flaws.md F2 L31).

| Band | Criteria |
|------|----------|
| **rigorous** | Real data is searched/cited across most rounds (concrete sources: named Reddit/HN threads, competitor names + pricing, Product Hunt counts, real persona evidence — not "the market is big"). Claims are explicitly labeled **FACT vs ASSUMPTION** based on evidence quality. It privileges behavior over opinion (counts "actively tried to solve / pre-paid / waitlisted" as demand; discounts "would be interested / friends liked it" as politeness). |
| **partial** | Some searching/evidence present but sparse or generic (2–3 rounds grounded; rest assert without sources), OR FACT/ASSUMPTION labeling is inconsistent / applied to only some claims, OR it treats stated interest as demand without flagging it as an assumption. |
| **superficial** | 0–1 real searches; claims rest on opinion / "I think" / market-size hand-waving — the exact failure the skill forbids (L10–11). No FACT/ASSUMPTION discipline. Social validation ("friends said they'd use it") is accepted as evidence of demand. |

---

### D3 — Fatal-Flaw Analysis

**Source:** `.claude/skills/product-thinking/checklists/fatal-flaws.md`
- 15+ universal startup killers (F1–F16).
- Usage (L9–14): *"Scan this list against the product idea; mark each that applies; include
  ≤3 most relevant in the verdict output."*
- The decision rule, quoted verbatim from fatal-flaws.md L5:
  > *"Two or more fatal flaws = KILL verdict regardless of other evidence."*
  (Severity Guide L150–155: `2 fatal flaws | KILL`; `3+ | KILL`. Note L157: a single
  high-severity flaw — F9 legal, F13 unit economics — can be a KILL on its own.)

| Band | Criteria |
|------|----------|
| **rigorous** | The 15 killers were scanned against this specific idea; the ≤3 most relevant flaws are named with the idea-specific reason each applies (or a defensible "no structural killers found" with the scan shown). The **"2+ fatal flaws = KILL"** rule (fatal-flaws.md L5) is correctly applied — and the single-flaw exceptions (F9/F13 can KILL alone; F12 alone is not auto-KILL, L157–159) are respected. |
| **partial** | Flaws are mentioned but generically (named without tying them to this idea), OR the scan is partial (only an obvious flaw or two, no evidence the full list was considered), OR the "2+ = KILL" rule is referenced but applied loosely/inconsistently. |
| **superficial** | No fatal-flaw scan at all, OR flaws are waved away ("we'll handle that later") without analysis, OR the "2+ = KILL" rule is ignored when 2+ flaws are in fact present. |

---

### D4 — Verdict Justification

**Source:** `.claude/skills/product-thinking/skills/pressure-test.md` Step 7 (L246–303)
- A named verdict **BUILD / PIVOT / KILL** (not a vague "could work").
- A **Confidence** score 1–10 derived from the FACT/ASSUMPTION count (L256–261).
- A **2-Week Validation Plan** that is type-specific and concrete, with an explicit
  **Success signal** (L291–295) — *"What result changes the verdict to BUILD"*.

> ⚠️ This dimension scores whether the verdict is RIGOROUSLY JUSTIFIED — tied to the
> evidence, with confidence and a concrete plan. It does NOT score *which* verdict was
> reached. A well-justified KILL scores `rigorous` here exactly like a well-justified BUILD.

| Band | Criteria |
|------|----------|
| **rigorous** | A named verdict — **any of BUILD/PIVOT/KILL; a rigorously-justified KILL scores `rigorous` here exactly like a rigorously-justified BUILD** — that is explicitly tied to the round evidence and fatal-flaw count, carries a confidence score consistent with the FACT/ASSUMPTION tally, names the core unvalidated assumption, AND gives a concrete, type-specific 2-week validation plan with an explicit success signal. |
| **partial** | A named verdict is present but its link to the evidence is thin (verdict asserted, reasoning sketchy), OR confidence is given but not grounded in the FACT count, OR the 2-week plan is vague / generic ("do more research", "talk to users") without a concrete success signal. |
| **superficial** | No clear verdict, OR a vague "it could work / might be worth trying" that the skill explicitly replaces (no BUILD/PIVOT/KILL), OR a verdict with no evidentiary basis, no confidence, and no validation plan. |

---

### D5 — Product-Type Adapter Use

**Source:** `.claude/skills/product-thinking/skills/pressure-test.md` Step 0 (L31–50) +
`.claude/skills/product-thinking/adapters/*.md` (software, hardware, ecommerce, service,
content, marketplace).
- Step 0 detects the product type, then *"load the adapter for that type"* (L43). The adapter
  supplies: which **data sources** to use per search step, the exact **Q4 (Narrowest Wedge)**
  wording, and what **"2-week validation"** means for that type (L45–49).

**Per-type differentiator table** (so a judge can score D5 from THIS rubric alone, without
opening `adapters/*.md`). To confirm the adapter was actually applied, look in the artifact
for the distinguishing signals below for the detected type — the right data sources AND the
right-shaped narrowest-wedge / 2-week validation. Signals condensed from
`.claude/skills/product-thinking/adapters/{type}.md` (Data Sources §, Q4 row, 2-week section):

| Type | Distinguishing data sources (in the searches) | Wedge / 2-week shape (in Q4 + validation plan) |
|------|-----------------------------------------------|------------------------------------------------|
| **software** | Reddit/HN last-30-days, Product Hunt launches, App Store / GitHub activity, competitor pricing | "smallest payable feature — one workflow/integration/script someone pays ~$9/mo for today" |
| **hardware** | Kickstarter/crowdfunding funded-vs-failed, YouTube unboxings, Alibaba supplier/component cost, competitor price | "validate without tooling — 3D-printed prototype + 5 user tests, or mockup + ~50 pre-orders, ≤$500 in 2 weeks" |
| **ecommerce** | Amazon reviews + BSR/Keepa, Helium10/Jungle Scout keyword volume, FBA fee calc, Alibaba supplier | "minimum viable SKU — one color/size/variant, minimum order (10–50 units) test-sold in 30 days" |
| **service** | Upwork/Fiverr rates, LinkedIn jobs demand, Reddit "hire / looking for", agency pricing | "do it by hand for ~5 clients this month — you doing the work manually, not a product/system" |
| **content** | YouTube/TikTok/Reddit last-30-days trend, Substack subscriber counts, podcast charts, competitor revenue | "one tweet thread / one piece of content to test the core thesis — write the headline now" |
| **marketplace** | Existing-marketplace alternatives, supply-side (Upwork/Etsy) + demand-side (Reddit "looking for"), take-rate / GMV benchmarks | "serve ONE side with Airtable/spreadsheet first — onboard one side manually before building software" |

| Band | Criteria |
|------|----------|
| **rigorous** | The product type is correctly detected AND the matching adapter's specifics are actually applied — the type's distinguishing data sources from the table above appear in the searches, the wedge wording in Q4 matches that type's shape, and the 2-week validation definition is type-appropriate. The analysis reads as tuned to this product type, not generic. |
| **partial** | The product type is identified but the adapter is applied only superficially (named but the table-above data sources / wedge shape / validation specifics don't actually shape the analysis), OR the type detection is plausible but unconfirmed. |
| **superficial** | No product-type detection, OR a wrong/contradictory type, OR a fully generic analysis with no adapter influence (same boilerplate regardless of product type). |

---

## §B. Band Decision Tree (Aggregation)

Score D1–D5 first, then apply IN ORDER (first matching rule wins):

```
INPUT: D1..D5 each ∈ {rigorous, partial, superficial}

1. superficial  (→ verdict FAIL)
     IF  D1 == superficial
     OR  (count of dimensions == superficial) >= 2

2. rigorous     (→ verdict PASS)
     IF  D1 == rigorous
     AND (count of dimensions == rigorous) >= 4   # ≥4 of 5 rigorous
     AND (count of dimensions == superficial) == 0

3. partial      (→ verdict PARTIAL)
     EVERYTHING ELSE
```

**D1 (Adversarial Rigor) is load-bearing.** A sycophantic, non-adversarial analysis can
NEVER be `rigorous`: if D1 is superficial the band is `superficial` (rule 1); if D1 is
merely `partial` the band can be at best `partial` (rule 2 requires D1 == rigorous). This is
deliberate — the pack's entire value is adversarial diagnosis, so an agreeable pass fails by
construction.

Worked discrimination check (a thin/sycophantic pressure-test — single encouraging answer,
0–1 real searches, no fatal-flaw scan): D1 superficial (no adversarial pushback) AND D2
superficial (0–1 searches, no FACT/ASSUMPTION) AND D3 superficial (no scan) → rule 1 fires
twice over → **`superficial` → FAIL.** This is the intended outcome.

---

## §C. Anti-Theater / Decoupling Rule + Swap Test

> **Score rigor ONLY. If flipping the final BUILD/PIVOT/KILL word would change your band,
> you are scoring the conclusion — re-score. A rigorously-argued KILL is rigorous.
> content_verdict is recorded separately, never gates.**

**Swap Test (mandatory self-audit before committing the band):** Take the artifact, flip its
final BUILD/PIVOT/KILL word (BUILD↔KILL), change NOTHING else, and re-read your per-dimension
scores. If any dimension band — or the aggregate band — would move, you scored the
conclusion, not the rigor. Re-score on the §A criteria alone.

Anti-theater corollary: rigor is about whether the interrogation was real (rounds actually
run, real data actually searched, flaws actually scanned), not about volume of prose or
confident tone. A long, eloquent, but search-free and unchallenged analysis is `superficial`,
not `rigorous` — eloquence is not evidence.

---

## §D. Judge Output Contract

Emit EXACTLY in this order. `band:` (with its per-dimension justification) MUST appear ABOVE
`content_verdict:` — this is the **order firewall** (`.claude/skills/gate/SKILL.md`
`judge_prompt_by_shape.categorical.extra_output` L479: *"`band:` (with justification) MUST
appear ABOVE `content_verdict:` in the file"*). The conclusion is committed AFTER the band so
it cannot anchor it.

```
# Pressure-Test Rigor Evaluation

## Per-Dimension Bands
| Dim | Name                    | Band        | Justification (rigor evidence in the artifact)              |
|-----|-------------------------|-------------|-------------------------------------------------------------|
| D1  | Adversarial Rigor       | <band>      | <e.g. "6 rounds run; pushed back on weak demand answer…">   |
| D2  | Evidence Grounding      | <band>      | <e.g. "Reddit+PH searched 5/6 rounds; FACT/ASSUMPTION used">|
| D3  | Fatal-Flaw Analysis     | <band>      | <e.g. "scanned 15; named F2,F4,F6; applied 2+=KILL rule">   |
| D4  | Verdict Justification   | <band>      | <e.g. "KILL tied to 2 flaws + conf 3/10 + 2-wk plan">       |
| D5  | Product-Type Adapter    | <band>      | <e.g. "software adapter: HN/PH sources, MVP wedge wording"> |

## Swap Test
<state the result: "Flipping the final verdict word changes nothing in the scores above — band reflects rigor only.">

band: rigorous|partial|superficial
content_verdict: BUILD|PIVOT|KILL   # the artifact's own conclusion; RECORDED only, never maps to the gate verdict

verdict: PASS|PARTIAL|FAIL          # derived from band (rigorous→PASS · partial→PARTIAL · superficial→FAIL); the shape-agnostic Gate 4 token
```

Mapping (must match `.claude/skills/gate/SKILL.md` categorical branch L457):
`rigorous → PASS` · `partial → PARTIAL` · `superficial → FAIL`.

---

## Source Citations (on-disk, verbatim anchors)

| Claim used in this rubric | Source file | Anchor |
|---------------------------|-------------|--------|
| 6 forcing rounds (Demand→Future-Fit); "this probably won't work, prove otherwise"; anti-sycophancy / refuse category answers / challenge strongest claim | `.claude/skills/product-thinking/skills/pressure-test.md` | L8, Steps 0–6, L14–28, L139 |
| Every round searches real data; "No round accepts 'I think'"; behavior over opinion | `.claude/skills/product-thinking/skills/pressure-test.md` | L10–11, L56, per-round `**Then search:**` blocks |
| "Record: FACT or ASSUMPTION based on evidence quality" | `.claude/skills/product-thinking/skills/pressure-test.md` | L86, L117, L147, L180, L212, L242 |
| 15 universal killers; scan + name ≤3 most relevant | `.claude/skills/product-thinking/checklists/fatal-flaws.md` | L9–14, F1–F16 |
| **"Two or more fatal flaws = KILL verdict regardless of other evidence."** | `.claude/skills/product-thinking/checklists/fatal-flaws.md` | L5 (Severity Guide L150–157; F12 exception L159) |
| BUILD/PIVOT/KILL + Confidence 1–10 + 2-week validation plan with success signal | `.claude/skills/product-thinking/skills/pressure-test.md` | Step 7, L246–303 |
| Step-0 product-type detection → load adapter (data sources, Q4 wedge wording, 2-week meaning) | `.claude/skills/product-thinking/skills/pressure-test.md` + `.claude/skills/product-thinking/adapters/*.md` | L31–50 |
| Categorical band→verdict mapping; rigor independence; order firewall (band above content_verdict); swap test | `.claude/skills/gate/SKILL.md` | `judge_prompt_by_shape.categorical` L453–479 |
