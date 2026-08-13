---
name: product-thinking
description: "Three deep skills that turn any AI agent into a product decision partner. Covers adversarial idea validation, business model generation, and executable product definition across 6 product types. Use for any product strategy, idea validation, business model design, or product definition task."
---

# Product Thinking Capability Pack

Three deep skills for product decisions. Not templates — a thinking engine that searches real data, challenges assumptions, and forces decisions.

**CONSUMES / PRODUCES** (the 3-skill pipeline, wired through `~/.product-thinking/session.json`):

| Skill | CONSUMES | PRODUCES |
|-------|----------|----------|
| `/pressure-test` | User idea + detected product type (Step 0) | `session.json{pressure_test}` — verdict, confidence, facts/assumptions, core_assumption, 2-week plan |
| `/shotgun` | `session.json{pressure_test}` | `session.json{shotgun}` — ranked variants + `selected_variant` |
| `/define` | `session.json{pressure_test}` + `{shotgun}` (degrades to standalone if absent) | A type-specific PRD document (tech handoff / listing / crowdfunding brief / …) — NOT written back to session.json |

**Scope boundary**: This pack NEVER writes code and NEVER builds the product. It produces *decisions and definitions* only. When `/define` is done, hand off to a build pack (`web-backend` / `web-frontend` / `web-deployment`) — this pack stops at the spec.

## Skills

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/pressure-test` | Adversarial idea diagnosis — 6 rounds with real data search → BUILD/PIVOT/KILL verdict | New idea, pivot decision, pre-investment |
| `/shotgun` | Business model variant generation — 4-perspective review → ranked variants | Business model exploration, monetization strategy |
| `/define` | Executable product spec — auto-filled from prior steps → type-specific PRD | After pressure-test + shotgun, ready to build |

## Product Type Adapters

Adapters customize each skill for the product type:
- `adapters/software.md` — SaaS, apps, developer tools
- `adapters/hardware.md` — Physical products, IoT
- `adapters/ecommerce.md` — Online retail, marketplace sellers
- `adapters/service.md` — Consulting, agencies, professional services
- `adapters/content.md` — Media, courses, newsletters
- `adapters/marketplace.md` — Two-sided platforms

## Anti-Rationalization Registry

The whole value of this pack is adversarial rigor. These are the excuses an agent (or the founder, channeled through the agent) will use to soften the diagnosis. Each has a binding counter-rule.

| Shortcut / Excuse | Counter-Rule |
|-------------------|--------------|
| "The idea sounds exciting — skip to BUILD." | Excitement is not evidence. Run all 6 forcing rounds. Default stance stays "this probably won't work" until FACTs prove otherwise. The verdict is computed from the FACT/ASSUMPTION tally, never from enthusiasm. |
| "The founder seems confident — soften the pushback." | Confidence is the thing being tested, not respected. The anti-sycophancy rules (`skills/pressure-test.md` L14–28) FORBID "that could work" / "interesting approach". Challenge the *strongest* version of the claim. |
| "No search tool is wired — guess instead of searching." | Never guess. Fall back to `WebSearch` with `site:` filters (`tools/tool-registry.md` degradation hierarchy). If all searches return nothing, the output is "insufficient public data → ASSUMPTION", not a fabricated finding. |
| "Only ran 3 rounds — call it done." | A pressure-test with ≤2 rounds scores `superficial` on D1 and FAILs the rubric (`references/pressure-test-rubric.md` §B). Run Demand → Future-Fit. |
| "A demographic was given ('PMs at mid-market SaaS') — accept it." | Demographics don't buy; people do. Refuse category answers; demand a named person, company, or thread (Step 3, L138–139). |
| "Interest = demand — count 'I'd use that' as validation." | Apply The Mom Test commitment-currency test (`checklists/fatal-flaws.md` F2): a real signal costs the prospect time, reputation, or money. "Would you use this?" costs nothing → record ASSUMPTION. |
| "Pricing later — don't challenge the number." | Price is positioned against alternatives, not invented later (F4). Demand the LTV:CAC / take-rate / freemium band from the adapter before accepting any price. |

## Quick Rule Index

The load-bearing thresholds an agent must apply, and where each lives:

| Rule / Threshold | Value | Where it lives |
|------------------|-------|----------------|
| Verdict decision | BUILD (conf ≥7, 0 fatal) · PIVOT · KILL | `skills/pressure-test.md` Step 7 |
| Confidence bands | 6 FACTs→9-10 · 4-5→7-8 · 2-3→4-6 · 0-1→1-3 | `skills/pressure-test.md` Step 7 |
| 2+ fatal flaws = KILL | regardless of confidence | `checklists/fatal-flaws.md` L5 / Severity Guide |
| #1 controllable killer | poor PMF cited in 43% of failures (capital 70% = symptom) | `checklists/fatal-flaws.md` F1/F2 |
| PMF must-have threshold | ≥40% "very disappointed" (Sean Ellis); 10-30% = not yet PMF | `skills/pressure-test.md` Step 1 |
| FACT vs ASSUMPTION test | Mom Test commitment currency (time/reputation/money) | `checklists/fatal-flaws.md` F2 |
| LTV:CAC healthy | 3:1–4:1 (B2B target 4:1, median 3.6:1); <1:1 loses money; >5:1 under-invested | `adapters/software.md`, `skills/define.md` |
| Rule of 40 | growth% + margin% ≥ 40 (SaaS median only ~12%) | `adapters/software.md` |
| CAC payback | median 6.8mo (B2C 4.2 / B2B 8.6); <12mo healthy; 18+mo challenging | `adapters/software.md` |
| Free-trial conversion | opt-in (no card) 8-18% · opt-out (card) 31-49% | `adapters/software.md` |
| Freemium conversion | broad 1-5% · tightly-targeted 5-15% | `adapters/software.md`, `adapters/content.md` |
| Marketplace take rate | product 5-15% · service 15-30%; default 10-20% | `adapters/marketplace.md`, F16 |
| Kickstarter success | ~42% overall; structured Open Calls ~80% | `adapters/hardware.md` |

## Validation Script

`scripts/verify-verdict.sh <pressure-test-output.md>` — structural rigor verifier. Asserts the output is *well-formed* (exactly one BUILD/PIVOT/KILL token, a Confidence N/10, a Fatal Flaws count, a FACT/ASSUMPTION tally, a 2-week plan with an explicit Success signal). It checks rigor STRUCTURE, never the conclusion — consistent with the rubric's conclusion-neutral firewall (`references/pressure-test-rubric.md` §C).

## Usage

Start with `/pressure-test` for any new product idea. The pack will detect or ask for product type and load the right adapter automatically.
