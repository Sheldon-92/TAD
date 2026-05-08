---
name: product-thinking
description: Three deep skills that turn any AI agent into a product decision partner. Not templates — a thinking engine that searches real data, challenges assumptions, and forces decisions. Covers adversarial idea validation, business model generation, and PRD definition across 6 product types (software, hardware, ecommerce, service, content, marketplace). Use for product idea evaluation, pivot decisions, business model comparison, or converting an idea into an executable spec.
keywords: ["product", "strategy", "business", "PMF", "pivot", "产品", "商业", "市场", "idea", "PRD", "business model", "压力测试", "商业模式"]
type: deep-skill
---

**CONSUMES**: Product idea or problem statement + optional existing market context
**PRODUCES**: BUILD/PIVOT/KILL verdict + validated business model variant + executable product spec (type-specific)

# Product Thinking Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: MIT — see LICENSE-ATTRIBUTION.md for source credits

---

## What This Pack Does

Most product tools coach you toward your idea. This pack assumes you might be wrong and forces you to prove otherwise.

Three skills in a serial pipeline. Each feeds the next via `~/.product-thinking/session.json`:

```
/pressure-test → /shotgun → /define
```

Each skill also works standalone. If no prior session exists, it collects context manually.

---

## Step 0: Context Detection

Detect what the user needs and route to the right skill:

| User Signal | Skill to Load |
|-------------|---------------|
| "validate idea", "pressure test", "is this viable", "kill or build", "产品验证", "想法验证" | `skills/pressure-test.md` |
| "business model", "alternatives", "variants", "how to monetize", "商业模式", "变现方式" | `skills/shotgun.md` |
| "define product", "write PRD", "spec", "turn into plan", "产品定义", "落地方案", "PRD" | `skills/define.md` |
| "all three", "full pipeline", "start from scratch", "完整流程" | Run in order: pressure-test → shotgun → define |

After detecting intent, use **AskUserQuestion** to confirm the route before loading the skill.

---

## Step 1: Load and Run Skill

After loading the relevant skill file:

1. **Read the skill completely** — interaction contract is at the top
2. **Follow the adversarial default** — pressure-test defaults to "this won't work"
3. **Execute mandatory search rounds** — do not skip; self-simulation is not research
4. **Use session.json** — skills share context; pressure-test's verdict auto-loads into shotgun

---

## Step 2: Serial Pipeline (when running all three)

If running the full pipeline:

1. Run `/pressure-test` → confirm BUILD/PIVOT/KILL verdict
2. If PIVOT or BUILD: run `/shotgun` → confirm chosen variant
3. Run `/define` → produces executable spec (80% pre-filled from steps 1-2)

At each stage, use **AskUserQuestion**: "Continue to the next skill?"

---

## Product Types Supported

| Type | Primary Output |
|------|----------------|
| Software | 2-week deployable spec + tech handoff |
| Hardware | 3D print plan + crowdfunding brief |
| Ecommerce | 10-unit test sell plan + supplier list |
| Service | 5-client playbook + service package |
| Content | 10-post calendar + engagement baseline |
| Marketplace | One-side-first strategy + Airtable MVP |

---

## Pack Architecture

**Type**: deep-skill (3 interconnected SKILL.md files with cross-skill state via session.json)

This pack does NOT follow the reference-based routing model. The three skills are:
- `skills/pressure-test.md` — adversarial validation (500+ lines, 6 forcing rounds)
- `skills/shotgun.md` — business model generation (500+ lines, anti-convergence rules)
- `skills/define.md` — PRD generation (500+ lines, 80% auto-fill from session.json)
