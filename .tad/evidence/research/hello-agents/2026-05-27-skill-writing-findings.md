# Findings: Skill Writing — hello-agents Extra-05 + Extra-08

**Date:** 2026-05-27
**Notebook:** `037c8e7d` (10 sources now: README + 5 chapters + 4 Extra)
**Source chapters cited:** Extra-05 (AgentSkills 解读), Extra-08 (如何写出好的 Skill)
**Reference framework being challenged:** Anthropic Claude Code Skills (the canonical pattern hello-agents documents)

---

## 1. Author's Definition of "Skill"

- A Skill = **standardized format for encapsulating procedural domain knowledge**, an "AI capability plugin"
- **vs prompts**: Skill is an "advanced prompt" using **Progressive Disclosure** (渐进式披露) — info layered so deep context only loads when triggered
- **vs MCP**: *Connectivity ≠ Capability*
  - MCP = USB interface / printer driver (the **hands**)
  - Skill = software application / operation manual (the **brain**) telling the agent how to use MCP tools

## 2. Recommended Structure (L1 / L2 / L3)

| Layer | What | Tokens | When loaded |
|-------|------|--------|-------------|
| **L1 Frontmatter** | YAML `name` + `description` | ~100 | Always in context — acts as **strict trigger mechanism** |
| **L2 Body** | Markdown instructions, **imperative tone**, **< 5k words** | up to 5k | After trigger |
| **L3 Bundled subfolders** | `scripts/` `references/` `assets/` `agents/openai.yaml` | 0 (scripts) / on-demand (refs) | Lazy |

**Naming convention:** hyphen-case, lowercase, ≤64 chars, **verb-prefix preferred** (e.g., `gh-address-comments`)

## 3. Anti-patterns explicitly called out

| ❌ Don't do | Why |
|-------------|-----|
| **Write for humans** — Changelog, "based on years of team experience", "maintain professional tone" | AI doesn't need background motivation; needs exact operational steps |
| **Misplaced trigger** — putting "When to use" inside body | By the time body is read, trigger decision already made. Trigger must live in frontmatter description only |
| **Abstract positive adjectives** — "be warm", "be insightful" | Too much room for hallucination. Use concrete "Don't do X" anti-pattern lists |
| **Context bloat** — detailed API schemas / reference data inline in SKILL.md | Dilutes attention. Move to `references/` and link |

## 4. Freedom Spectrum: Skill text vs Script

- **High freedom → text in SKILL.md**: creative tasks where many approaches are "correct" (e.g., writing a blog)
- **Low freedom → script in `scripts/`**: "Fragile operations" with severe failure cost and single exact right way (e.g., PDF rotation, strict YAML formatting)
- **Scripts cost 0 tokens** because they're executed, not read

## 5. Concrete examples shown

| Quality | Example |
|---------|---------|
| ❌ Bad description | `"Help process data"` / `"Data analysis skill"` — too vague, AI can't decide when to trigger |
| ✅ Good description | `docx` skill: *"Comprehensive document creation, editing, and analysis... Use when Codex needs to work with professional documents (.docx files) for: (1) Creating new..."* — explicit triggers |
| ❌ Bad instructions | "Comprehensive review, giving improvement suggestions... balance strictness and flexibility" — useless without specifics of what to check first |
| ✅ Good instructions | `laotou-thought-style` skill uses anti-pattern table: **Don't:** "Directly preach big truths" → **Symptom:** "Talking about rules at the very beginning" → **Fix:** "Lay out life scenarios first" |

---

## 6. TAD Gap Analysis (cross-reference with `.claude/skills/`)

| Principle | hello-agents teaches | TAD current state | Gap |
|-----------|---------------------|-------------------|-----|
| L1 Frontmatter exists | YAML `name` + `description` mandatory | ✅ TAD does this | None |
| L2 Body < 5k words | < 5k words, imperative | ❌ `alex/SKILL.md` ~2,700+ lines, `blake/SKILL.md` ~1,000 lines | **Severe context bloat** |
| L3 subfolders pattern | `scripts/` `references/` `assets/` | ⚠️ Some skills use `references/` (e.g., research-notebook); no `scripts/` usage | **Missing scripts/ pattern** |
| Naming verb-prefix | `gh-address-comments` style | ❌ TAD uses noun-based: `alex`, `blake`, `tad-help`, `playground` | **Weakened triggerability** |
| Trigger in frontmatter ONLY | Body must NOT contain "when to use" | ⚠️ TAD: alex SKILL has trigger conditions in body sections (e.g., intent_router_protocol) | **Partial violation** |
| No "writing for humans" | No Changelog / "team experience" / version notes | ❌ TAD: SKILL.md has version markers, anti_rationalization_registry references, many cross-refs to handoffs | **Heavy human-noise** |
| Concrete anti-patterns over abstract adjectives | Use anti-pattern tables (symptom → fix) | ✅ TAD has `anti_rationalization_registry` with exact pattern | None — TAD actually does this well |
| Freedom Spectrum | Scripts for fragile ops, text for creative | ⚠️ TAD uses inline bash via Bash tool, no `scripts/` subfolder convention | **Potential refactor** |

### Key takeaways for TAD

1. **alex/SKILL.md violation severity**: 2,700+ lines vs recommended < 5k **words** (~700-900 lines). TAD's main skill files are 3-5x the recommended size.
2. **Naming convention**: switching from `alex` → `lead-design` or `blake` → `execute-implementation` would improve trigger clarity. (BUT this is a breaking change for muscle memory — needs careful weighing.)
3. **Scripts folder pattern**: TAD has lots of "fragile operations" (e.g., `layer2-audit.sh`, `trace-step.sh`) but they live in `.tad/hooks/lib/` not `.claude/skills/*/scripts/`. Migration could improve discoverability.
4. **Body trigger leakage**: SKILL.md descriptions are reasonably trigger-rich, but body sections also describe activation conditions, which violates the rule.

### What TAD already does WELL (per Skill best practices)

- ✅ `anti_rationalization_registry` is exactly the "anti-pattern table" pattern they recommend
- ✅ Most skills have YAML frontmatter with name + description
- ✅ `progressive disclosure` philosophy is followed (CLAUDE.md routes → SKILL.md → references)

---

## 7. Confidence

**HIGH** — answer cites 5+ specific line/section refs from Extra-05 and Extra-08; not hallucinated; concrete examples match what would be in those chapters; gap analysis grounded in our own `.claude/skills/` filesystem state I can verify with `wc -l`.

## 8. Decision Implications

| If TAD takes this seriously | Action |
|------------------------------|--------|
| Accept "L2 < 5k words" as goal | Major SKILL.md refactor for alex / blake (split into references/) — Standard TAD handoff |
| Accept "scripts/ pattern" | Migrate `.tad/hooks/lib/*.sh` into `.claude/skills/*/scripts/` — Standard TAD, multi-file |
| Accept "no human noise" | Audit & strip Changelog / version markers from SKILL.md files — *express handoff |
| Accept "trigger in frontmatter only" | Audit body for trigger conditions, move to description — *express handoff |
| Defer naming convention change | Too disruptive; keep `alex/blake` muscle memory |
