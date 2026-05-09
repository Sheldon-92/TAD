---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: no
gate4_delta: []
---

# Mini-Handoff: Research Pipeline Upgrade — GitHub-First Source Strategy

**From:** Alex | **To:** Blake | **Date:** 2026-05-07
**Type:** Express (2 SKILL files, protocol text changes only)
**Priority:** P1
**Epic:** EPIC-20260507-agent-capability-packs (supporting improvement, not a phase)

---

## Problem

Today's web-ui-design research session exposed a systematic flaw in `*research-plan` step4:

1. **Deep research runs first** → floods notebook with 350 SEO articles (90% duplicates)
2. **GitHub sources added last** (or not at all) → the most actionable content comes last
3. **No research plan before sourcing** → sources added randomly without question-driven strategy
4. **Questions too theoretical** → "What are best practices?" gets textbook answers, not CLI commands
5. **GitHub only at README level** → sub-pages (brand DESIGN.md files, subagent definitions) missed

Evidence: 3 rounds of corrections needed before reaching useful depth. User had to manually intervene at every stage.

## Root Cause

`research_plan_protocol.step4` Phase 1 is labeled "Deep Research" and runs `notebooklm source add-research --mode deep` as the FIRST action. This pulls from search engines → SEO content farms. The high-value sources (GitHub repos, real company code, tool documentation) are not in the pipeline at all.

## Solution

Restructure step4 into 5 phases with **inverted source priority**:

```
BEFORE (current):
  Phase 1: Deep Research (search engine articles)  ← FIRST
  Phase 2: Auto-Curate
  Phase 3: Baseline Report
  Phase 4: Question Tree + Ask
  Phase 5: Extract ACs

AFTER (proposed — all within step4 scope, step5 Extract ACs unchanged):
  Phase 0: Research Plan (define questions + source types + success criteria)  ← NEW
  Phase 1: GitHub-First Sourcing (awesome-lists → company repos → tool repos)  ← INVERTED
  Phase 2: Auto-Curate + Dedup (existing, unchanged)
  Phase 3: Baseline Report (existing, unchanged)
  Phase 4: Question Tree + Ask (existing, with question format rules added)
  Phase 4b: CRAG Gap Detection → Deep Research as LAST RESORT  ← DEMOTED from primary to fallback
  (step5 Extract ACs is a separate YAML key, NOT inside step4 — not modified)
```

## Files to Modify

### File 1: `.claude/skills/alex/SKILL.md`

**Location**: `research_plan_protocol.step4` (line ~1017-1164)

**Changes**:

1. **Insert new Phase 0** before current Phase 1 (line ~1039, after "For each confirmed research item:"):

```yaml
        a0. PHASE 0 — Research Plan (NEW — define before sourcing):
           → Step 1: Define 5-10 specific research questions from the gap analysis
             Format rule: questions MUST include a specificity anchor:
             ✅ "From GitHub repos: what specific CLI tools exist for X?"
             ✅ "What token structure does Shopify Polaris use in its polaris-tokens package?"
             ❌ "What are best practices for X?" (too vague — REJECT and rephrase)
             ❌ "How should we approach X?" (no specificity anchor — REJECT)
           → Step 2: Define source type priority for this research topic:
             | Priority | Source Type | Example |
             |----------|------------|---------|
             | 1 (first) | GitHub awesome-lists | awesome-design-systems, awesome-tailwindcss |
             | 2 | Real company repos | Shopify/polaris, primer/react, adobe/react-spectrum |
             | 3 | Tool official repos | storybookjs/storybook, amzn/style-dictionary |
             | 4 | Tool documentation sites | docs.anthropic.com, storybook.js.org |
             | 5 (last) | Deep research (articles) | ONLY if Phases 1-3 leave gaps |
           → Step 3: Define success criteria:
             "After this research, I should be able to decide: {specific decision}"
           → Display plan to user for confirmation before proceeding
```

2. **Replace current Phase 1 "Deep Research"** (line ~1045-1048) with:

```yaml
        b. PHASE 1 — GitHub-First Sourcing (replaces old "Deep Research"):
           → Step 1: Search for awesome-lists
             WebSearch: "github awesome list {topic} site:github.com"
             For each relevant awesome-list found:
               notebooklm source add "https://github.com/{org}/{repo}" -n <id>
               sleep 2
           → Step 2: Explore awesome-list sub-pages
             For TOP 3 most relevant awesome-lists:
               gh api "repos/{org}/{repo}/git/trees/main?recursive=1" --jq '[.tree[] | select(.type == "blob" and (.path | test("\\.md$"))) | .path][:20]'
               For each actionable sub-page (DESIGN.md files, specific tool docs, subagent definitions):
                 notebooklm source add "https://github.com/{org}/{repo}/blob/main/{path}" -n <id>
                 sleep 1
           → Step 3: Add real company repos (if topic involves a specific technology/pattern)
             WebSearch: "github {technology} design system stars:>5000"
             Add top 3-5 repos
           → Step 4: Add tool official repos (for each tool mentioned in Phase 0 questions)
             notebooklm source add "https://github.com/{tool-org}/{tool-repo}" -n <id>
           → Report: "📦 Phase 1 sourcing: {N} GitHub sources added ({awesome} awesome-lists + {sub} sub-pages + {company} company repos + {tool} tool repos)"
```

3. **Demote Deep Research to Phase 4 gap-filler** — rename PHASE 4b (currently CRAG Judge Loop) to include deep research as a last-resort source enrichment:

In the existing PHASE 4b gap detection block (line ~1133), add after "3. Fast research:" step:

```yaml
             3b. If fast research finds 0 usable sources AND this is the first gap for this topic:
                → Escalate to deep research as fallback:
                  notebooklm source add-research "{broader_topic}" --mode deep -n <target_notebook_id>
                  Report: "🔍 Gap persists after fast research. Running deep research as fallback..."
                → Auto-curate (error + dedup) after deep research completes
                → Then retry the ask
                → This is the ONLY path where deep research runs. It is a fallback, not a primary.
```

4. **Add question format rules** to Phase 4 Step 1 "Generate Question Tree" (line ~1097):

After the existing "Format:" line, add:

```yaml
             Question format rules (MANDATORY):
             ✅ Include specificity anchor: "From [source type]: what [specific thing]?"
             ✅ Ask for CLI commands, not concepts: "What CLI tool does X?"
             ✅ Reference specific sources: "From the Shopify Polaris repo: how do they structure tokens?"
             ❌ REJECT "What are best practices for X?" — rephrase to "What do [companies] actually use for X?"
             ❌ REJECT "How should we approach X?" — rephrase to "What specific tools/patterns exist for X?"
             If a generated question matches a ❌ pattern, Alex MUST rephrase before adding to tree.
```

### File 2: `.claude/skills/research-notebook/SKILL.md`

**Location**: Near the `research` sub-command section (add a note about GitHub-first strategy)

**Change**: After the existing `research` sub-command description, add a usage note:

```yaml
### Source Strategy Note (GitHub-First)

When building a notebook for a new topic, source quality matters more than quantity.
Preferred order:
1. GitHub awesome-lists (`source add "https://github.com/org/awesome-topic"`)
2. GitHub sub-pages from awesome-lists (explore with `gh api` tree, add key .md files)
3. Real company repos (how production systems actually do it)
4. Tool repos (official source, not blog posts about the tool)
5. `source add-research --mode deep` (LAST RESORT for gaps only)

10 curated GitHub repos > 350 deep research articles.
```

---

## Acceptance Criteria

- [ ] AC1: `research_plan_protocol.step4` has Phase 0 (Research Plan) before any source addition
- [ ] AC2: Phase 1 is labeled "GitHub-First Sourcing" with awesome-list → sub-pages → company repos → tool repos order
- [ ] AC3: Deep research (`source add-research --mode deep`) appears ONLY in gap-filler context (Phase 4 fallback), NOT as primary Phase 1
- [ ] AC4: Question format rules include ≥2 ✅ patterns and ≥2 ❌ patterns with rephrase instructions
- [ ] AC5: research-notebook SKILL.md has "Source Strategy Note" section with the 5-level priority list
- [ ] AC6: No behavioral changes to existing commands (curate, ask, report, etc.) — only step4 pipeline restructuring

## Spec Compliance

| AC | Verification | Expected |
|----|-------------|----------|
| AC1 | `grep -c "Phase 0\|Research Plan" .claude/skills/alex/SKILL.md` | ≥2 |
| AC2 | `sed -n '/research_plan_protocol/,/^[a-z_]*_protocol:/p' .claude/skills/alex/SKILL.md \| grep -c "GitHub-First Sourcing"` | ≥1 |
| AC3 | `grep -A5 "add-research.*--mode deep" .claude/skills/alex/SKILL.md \| grep -c "fallback\|gap\|last resort"` | ≥1 |
| AC4 | `grep -c "❌ REJECT" .claude/skills/alex/SKILL.md` | ≥2 |
| AC5 | `grep -c "GitHub-First\|Source Strategy" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC6 | `git diff --stat \| grep -v "alex/SKILL.md\|research-notebook/SKILL.md"` | 0 other files changed |

## Expert Review

| Expert | Verdict | P0 | P1 | P2 |
|--------|---------|----|----|-----|
| code-reviewer | CONDITIONAL PASS | 2 | 1 | 2 |

### P0 Resolved
| # | Issue | Resolution |
|---|-------|-----------|
| P0-1 | AC2 grep matches pre-existing "awesome-list" references (AC self-leak) | Fixed: scoped grep to `research_plan_protocol` block only, search for exact "GitHub-First Sourcing" label |
| P0-2 | Phase numbering collision — BEFORE/AFTER diagram conflates step4 phases with step5 | Fixed: clarified all phases are within step4 scope; step5 Extract ACs noted as separate + not modified |

### P1 Noted (advisory)
- P1-1: Question format rules are LLM self-discipline, not mechanical enforcement — acceptable since GitHub-first sourcing is the primary fix, question rules are secondary quality bar

### P2 Noted (future)
- P2-1: Pure academic/regulatory topics have no GitHub presence → Phase 0 user confirmation implicitly allows reordering (no change needed now)
- P2-2: `github.com` URLs vs `raw.githubusercontent.com` — Blake should test which NotebookLM handles better

## Blake Instructions
- Read the full handoff
- Changes are TEXT-ONLY in 2 SKILL.md files — no code, no hooks, no config
- The Phase 0/1/4 restructuring must fit cleanly into the existing YAML indentation structure
- Do NOT change any other step4 sub-phases (Phase 2 curate, Phase 3 report, Phase 5 extract ACs)
- Expert review: ≥1 (code-reviewer required per express path)
