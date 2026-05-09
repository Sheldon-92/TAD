---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Web Frontend Capability Pack

**From:** Alex | **To:** Blake | **Date:** 2026-05-08
**Project:** Independent repo (not TAD)
**Epic:** EPIC-20260507-agent-capability-packs (Phase 1e)

---

## Gate 2: Design Completeness

**Date**: 2026-05-08

| Check | Status | Detail |
|-------|--------|--------|
| Architecture Complete | ✅ | 18 files, web-backend router pattern, DESIGN.md interface contract |
| Components Specified | ✅ | 7 references + checklist + 3 scripts + CAPABILITY.md + CONVENTIONS.md |
| Expert Review | ✅ | 2 experts (code-reviewer + backend-architect), 8 P0 + 10 P1 all Resolved |
| ACs Verifiable | ✅ | 19 ACs with verification commands (AC13 manual attestation) |
| Research Grounded | ✅ | 299 sources in NotebookLM, 4 rounds ask, findings saved |

**Gate 2 Result**: ✅ PASS

**Alex confirms**: All design elements verified. Blake can independently complete implementation using this document.

---

## 1. Task Overview

Build a **Web Frontend Capability Pack** — judgment rules that make any AI agent write frontend code like a senior React engineer. Not documentation. Not a tutorial. A decision framework with 35-45 concrete rules, executable validation scripts, and production conventions.

**Core idea**: AI agents write React code that renders correctly but fails in production — wrong component boundaries, bloated bundles, broken accessibility, state management spaghetti. This pack embeds the engineering judgment a senior frontend developer applies automatically.

**Key distinction from web-ui-design pack**: web-ui-design CREATES design artifacts (DESIGN.md, tokens, palettes). This pack CONSUMES them and turns them into production-grade code. DESIGN.md is the interface contract between the two packs.

**Phase 1 target: Claude Code.** Same install.sh pattern as web-backend.

---

## 2. Research Foundation

- **Notebook:** `430044a7-d808-4a70-9969-24e00c92da8d` — 299 sources
- **Research findings:** `.tad/evidence/research/web-frontend-capability-pack/2026-05-08-research-findings.md`
- **Key sources:**
  - Shopify Polaris (Web Components direction, atomic design)
  - Adobe React Spectrum + React Aria (headless UI, accessibility-first)
  - Radix UI Primitives (compound components, unstyled)
  - Zustand / Jotai / TanStack Query (state management 2026 stack)
  - Amazon Style Dictionary (W3C DTCG token pipeline)
  - VoltAgent awesome-design-md (68 brand DESIGN.md files)
  - axe-core (accessibility rule engine)
  - Google web-vitals (Core Web Vitals measurement)
  - React Testing Library + Storybook (testing philosophy)

---

## 3. Architecture

### 3.1 File Structure

```
web-frontend/
├── CAPABILITY.md              # Main skill entry — context-sensitive router
│                              # YAML frontmatter: name + description (MANDATORY for Claude Code)
│                              # Step 0: Read DESIGN.md if exists (explicit consumption)
│                              # Step 1: Context detection → load relevant reference
│                              # Pure router + anti-skip table, all rules in references/
│
├── CONVENTIONS.md             # React naming + directory structure + code examples
│                              # Next.js App Router conventions
│                              # "If Vue:" / "If Svelte:" equivalent annotations
│
├── references/
│   ├── component-architecture.md  # 5-7 rules: composition patterns, RSC decisions,
│   │                              # splitting heuristics, thin-client rule, 50-component threshold
│   ├── state-management.md        # 5-7 rules: selection matrix (Zustand/Jotai/TanStack Query/Context),
│   │                              # server vs client separation, anti-patterns
│   ├── design-tokens.md           # 4-6 rules: DESIGN.md consumption workflow,
│   │                              # W3C DTCG → Style Dictionary → CSS/Tailwind pipeline,
│   │                              # token naming conventions
│   ├── styling.md                 # 4-5 rules: Tailwind vs CSS Modules vs vanilla decision tree,
│   │                              # responsive patterns, dark mode implementation
│   ├── performance.md             # 5-7 rules: CWV thresholds (LCP<2.5s, INP<200ms, CLS<0.1),
│   │                              # bundle optimization, image handling, lazy loading
│   ├── accessibility.md           # 5-7 rules: top 7 axe-core failures + fix patterns,
│   │                              # semantic HTML first, ARIA as last resort,
│   │                              # "automation catches 20-40%" warning
│   └── testing.md                 # 4-6 rules: unit(Vitest) > integration(RTL+Storybook) > E2E(Playwright),
│                                  # behavioral testing philosophy, stable locators
│
├── checklists/
│   └── frontend-quality.md        # Comprehensive quality checklist (tiered like web-backend PRR)
│                                  # Tier 1: Automatable (~20 items — lighthouse, axe, bundle size)
│                                  # Tier 2: Human attestation (~10 items — UX review, design fidelity)
│                                  # Tier 3: Infra-dependent (~5 items — CDN, monitoring, error tracking)
│
├── scripts/
│   ├── lighthouse-check.sh        # Run Lighthouse CLI, extract CWV scores, PASS/FAIL against thresholds
│   ├── a11y-scan.sh               # axe-core scan via @axe-core/cli, report violations
│   └── bundle-check.sh            # webpack-bundle-analyzer or vite-bundle-visualizer, size budget check
│
├── install.sh                 # Installer: --agent claude-code (Phase 1) + codex/cursor/gemini stubs
├── README.md                  # Human-facing docs
├── LICENSE                    # Apache 2.0
├── LICENSE-ATTRIBUTION.md     # Source attribution
└── CHANGELOG.md
```

### 3.2 CAPABILITY.md Workflow (Context Router)

```
User says something about frontend
  ↓
Step 0: DESIGN.md Detection (EXPLICIT)
  - Check if project has DESIGN.md (root or design/ directory)
  - If found: extract structured values:
    (a) CSS custom property values (--color-primary: #xxx)
    (b) W3C DTCG JSON if referenced via a tokens.json path
    (c) Tailwind config values if present
    → Use extracted values as design constraints for all subsequent rules
  - If DESIGN.md is freeform prose without structured tokens: extract nothing,
    rules apply without design constraints (pack works standalone)
  - If not found: proceed without design constraints (pack works standalone)
  ↓
Step 1: Context Detection
  - "component / split / compose / refactor UI / RSC / server component" → Load references/component-architecture.md
  - "state / fetch / cache / store / zustand / jotai / query" → Load references/state-management.md
  - "token / design system / DESIGN.md / brand / DTCG" → Load references/design-tokens.md
  - "style / css / tailwind / theme / dark mode / module" → Load references/styling.md
  - "slow / performance / bundle / lighthouse / CWV / vitals" → Load references/performance.md
  - "accessible / a11y / screen reader / aria / wcag / axe" → Load references/accessibility.md
  - "test / coverage / storybook / playwright / vitest" → Load references/testing.md
  Disambiguation: if multiple references match, load the FIRST match and ask user to confirm.
  - "new project / scaffold / setup" → Load CONVENTIONS.md + all references
  - "review / audit / quality check" → Load checklists/frontend-quality.md
  ↓
Step 2: Apply judgment rules from loaded reference
  ↓
Step 3: Validate with scripts (if applicable)
```

### 3.3 Rule Format (per reference file)

Each reference/*.md follows this structure:

```markdown
# {Dimension} Judgment Rules

> React-first. Vue/Svelte equivalents noted in [brackets].

## Rule 1: {Title}

**When**: {specific trigger condition}
**Decision**: {what to do — concrete, not "consider"}
**Threshold**: {specific number, metric, or CLI command}
**Anti-pattern**: {what NOT to do}
**Source**: [{repo/article name}]({url})

[If Vue: {equivalent}]
[If Svelte: {equivalent}]
```

### 3.4 DESIGN.md Interface Contract

```
web-ui-design pack                 web-frontend pack
─────────────────                  ─────────────────
PRODUCES:                          CONSUMES:
  DESIGN.md                  →      Step 0: Parse DESIGN.md
  tokens.json (DTCG format) →      design-tokens.md: Transform via Style Dictionary
  color palette              →      styling.md: Apply as CSS custom properties
  spacing scale              →      component-architecture.md: Use as layout constraints
  typography                 →      CONVENTIONS.md: Font loading strategy

NEVER TOUCHES:                     NEVER TOUCHES:
  component code                     color selection
  state management                   typography pairing
  build config                       wireframe layout
```

---

## 4. Key Design Decisions

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Framework scope | React-only / Framework-agnostic / React+Vue dual | React-first + annotations | Specific enough for actionable rules, Vue/Svelte in brackets prevents lock-in |
| 2 | Pack structure | web-ui-design pattern / web-backend pattern / new | web-backend pattern | Proven: router + progressive disclosure. Agent loads only what's needed |
| 3 | DESIGN.md relationship | Explicit / Optional / Independent | Explicit consumption | DESIGN.md is THE interface contract. Step 0 reads it before any routing |
| 4 | Rule format | Prose / Table / Structured (When/Decision/Threshold) | Structured | Each rule must have a threshold or CLI command — prevents "best practice" vagueness |
| 5 | Scope | Core 4 dimensions / All 7 / Adaptive | All 7 | Research showed each dimension has 4-7 unique rules not covered by others |
| 6 | Checklist tiers | Flat list / 3-tier (web-backend pattern) | 3-tier | Automatable/Attestation/Infra — proven in web-backend, matches frontend reality |
| 7 | Dimension count | 8 from research / 7 merged | 7 | Build & Deploy folded into component-architecture.md (RSC/SSR) + performance.md (code splitting, lazy loading). Avoids thin file with <3 unique rules |

---

## 5. Acceptance Criteria

### Structure
- [ ] AC1: ~/web-frontend/ exists as independent directory, zero TAD file dependencies
- [ ] AC2: CAPABILITY.md has YAML frontmatter with `name` + `description` fields
- [ ] AC3: 7 files in references/ (component-architecture, state-management, design-tokens, styling, performance, accessibility, testing)
- [ ] AC4: CONVENTIONS.md exists with React naming + directory conventions + Vue/Svelte annotations
- [ ] AC5: checklists/frontend-quality.md with 3 tiers (Tier 1 automatable ≥15 items, Tier 2 attestation ≥8 items, Tier 3 infra ≥4 items)
- [ ] AC6: install.sh with --agent flag + --dry-run flag + Phase 3 stubs (codex/cursor/gemini exit 2)

### Rules Quality
- [ ] AC7: Total judgment rules across all references/ ≥35 and ≤50
- [ ] AC8: Every rule has When + Decision + Threshold (or CLI command) — no rule without a concrete trigger
- [ ] AC9: Every rule has Source attribution linking to a specific repo, spec, or article
- [ ] AC10: Zero TAD terminology in any file (no "Gate", "Ralph Loop", "Blake", "handoff")

### DESIGN.md Integration
- [ ] AC11: CAPABILITY.md Step 0 explicitly reads DESIGN.md and extracts tokens/colors/spacing
- [ ] AC12: design-tokens.md contains complete W3C DTCG → Style Dictionary → CSS/Tailwind pipeline with CLI commands

### Risk Mitigations
- [ ] AC13: No rule says "consider" or "best practice" without a specific threshold — grep verification: `grep -ciE '(consider |best practice)' references/*.md` returns 0
- [ ] AC14: CAPABILITY.md declares "This pack CONSUMES design artifacts. It does NOT create them." in first 10 lines
- [ ] AC15: Rules that depend on React version explicitly note "React 19+" applicability
- [ ] AC16: Each reference/*.md ≤800 lines (progressive disclosure — prevents context overflow)

### Scripts
- [ ] AC17: 3 scripts in scripts/ (lighthouse-check.sh, a11y-scan.sh, bundle-check.sh), each with `--help` flag and exit code conventions. Scripts take a URL as first argument (`bash scripts/lighthouse-check.sh http://localhost:3000`). They do NOT start a server — user must have a running app. Default to `http://localhost:3000` if no URL provided.

### Structural Integrity
- [ ] AC18: CAPABILITY.md contains ZERO inline rules — `grep -cE '^\*\*Rule' ~/web-frontend/CAPABILITY.md` returns 0 (pure router, all rules in references/)
- [ ] AC19: Total line count across all .md + .sh files ≤5000

---

## 6. Implementation Guide

### Phase 1: Scaffold (start here)
1. `mkdir -p ~/web-frontend/{references,checklists,scripts}`
2. Create CAPABILITY.md with YAML frontmatter + context router skeleton
3. Create install.sh from web-backend template (change paths + --agent stubs)

### Phase 2: References (core work)
For each of the 7 reference files:
1. Read the corresponding section from `.tad/evidence/research/web-frontend-capability-pack/2026-05-08-research-findings.md`
2. For each rule with a `[Source: X]` tag, **WebFetch or `gh api` the actual source and read the relevant section** before writing the rule text (per architecture.md "Capability Pack Rule Sourcing" — do NOT write from training data alone)
3. Write 4-7 rules per file using the structured format (When/Decision/Threshold/Anti-pattern/Source)
4. Add `[If Vue: ...]` / `[If Svelte: ...]` annotations where React-specific

### Phase 3: Quality artifacts
1. Write checklists/frontend-quality.md (3 tiers, 27+ items total)
2. Write scripts/ (3 shell scripts with `--help` and proper exit codes)
3. Write CONVENTIONS.md (Next.js App Router structure + naming)

### Phase 4: Polish
1. Write README.md, LICENSE (Apache 2.0), LICENSE-ATTRIBUTION.md, CHANGELOG.md
2. Run self-audit: every rule has Source? Every reference ≤800 lines? Zero TAD terms?
3. Verify AC1-AC17

### ⚠️ Critical reminders
- **Rule Sourcing**: Read the cited source BEFORE writing each rule. Do not write from memory. (architecture.md: "Capability Pack Rule Sourcing: Read the Cited Source, Not Just the Citation")
- **YAML frontmatter**: CAPABILITY.md MUST start with `---\nname: ...\ndescription: ...\n---` or Claude Code won't load it (architecture.md: "Capability Pack: YAML Frontmatter is Load-Bearing")
- **Install stubs**: Use Phase N stub pattern — `--agent codex` returns exit 2 with informative message (architecture.md: "Capability Pack: Multi-Agent Install Pattern")

---

## 7. Files to Create

| # | File | Purpose | Lines (est.) |
|---|------|---------|-------------|
| 1 | CAPABILITY.md | Context router + DESIGN.md consumption | 400-600 |
| 2 | CONVENTIONS.md | React naming + structure + Vue/Svelte notes | 200-300 |
| 3 | references/component-architecture.md | 5-7 rules: composition, RSC, splitting | 400-600 |
| 4 | references/state-management.md | 5-7 rules: selection matrix, anti-patterns | 400-600 |
| 5 | references/design-tokens.md | 4-6 rules: DTCG pipeline, DESIGN.md workflow | 300-500 |
| 6 | references/styling.md | 4-5 rules: Tailwind/Modules/vanilla decision tree | 300-400 |
| 7 | references/performance.md | 5-7 rules: CWV thresholds, bundle, lazy loading | 400-600 |
| 8 | references/accessibility.md | 5-7 rules: top failures, semantic HTML, ARIA | 400-600 |
| 9 | references/testing.md | 4-6 rules: pyramid, behavioral testing, tools | 300-500 |
| 10 | checklists/frontend-quality.md | 3-tier quality checklist (27+ items) | 200-300 |
| 11 | scripts/lighthouse-check.sh | CWV measurement + PASS/FAIL | 50-80 |
| 12 | scripts/a11y-scan.sh | axe-core accessibility scan | 50-80 |
| 13 | scripts/bundle-check.sh | Bundle size budget check | 50-80 |
| 14 | install.sh | Installer with --agent flag | 80-120 |
| 15 | README.md | Human-facing docs | 100-150 |
| 16 | LICENSE | Apache 2.0 | standard |
| 17 | LICENSE-ATTRIBUTION.md | Source credits | 50-80 |
| 18 | CHANGELOG.md | Version history | 20-30 |

**Total estimated: 18 files, 3300-5000 lines**

---

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/capability-pack-web-frontend/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-pack-web-frontend/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/capability-pack-web-frontend/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260508-capability-pack-web-frontend.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new patterns discovered)
research_evidence:
  - .tad/evidence/research/web-frontend-capability-pack/2026-05-08-research-findings.md (already exists)
```

---

## 9. Spec Compliance Checklist

### 9.1 Verification Table

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `test -d ~/web-frontend/references && test -d ~/web-frontend/scripts && test -d ~/web-frontend/checklists && [ -z "$(find ~/web-frontend -path '*/.tad/*' -print -quit)" ]` | All dirs exist, no .tad files |
| AC2 | `head -5 ~/web-frontend/CAPABILITY.md \| grep -c 'name:\|description:'` | Returns 2 |
| AC3 | `ls ~/web-frontend/references/*.md \| wc -l` | Returns 7 |
| AC4 | `test -f ~/web-frontend/CONVENTIONS.md && grep -c 'Vue\|Svelte' ~/web-frontend/CONVENTIONS.md` | File exists, ≥2 annotations |
| AC5 | `grep -cE '^##+ Tier' ~/web-frontend/checklists/frontend-quality.md` | Returns ≥3 (heading-level tier declarations) |
| AC6 | `bash ~/web-frontend/install.sh --agent=codex 2>&1; echo $?` | Exit code 2 + informative message |
| AC7 | `grep -cE '^## Rule [0-9]+' ~/web-frontend/references/*.md` | Returns 35-50 (H2 heading format) |
| AC8 | `grep -cE '^\*\*(When\|Decision\|Threshold)\*\*' ~/web-frontend/references/*.md \| awk -F: '{s+=$NF} END{print s}'` | Returns ≥105 (35 rules × 3 fields) |
| AC9 | `grep -cE '^\*\*Source\*\*:' ~/web-frontend/references/*.md` | Returns ≥35 (one per rule) |
| AC10 | `grep -rnE '\bTAD\b\|handoff\|Gate [1-4]\|Ralph Loop\|\bBlake\b\|\bAlex\b' ~/web-frontend/ --include='*.md' --include='*.sh' --exclude='LICENSE-ATTRIBUTION.md'` | Returns 0 (recursive, word-boundary) |
| AC11 | `grep -c 'DESIGN.md' ~/web-frontend/CAPABILITY.md` | Returns ≥3 (Step 0 + interface notes) |
| AC12 | `grep -cE 'style-dictionary\|Style Dictionary\|DTCG' ~/web-frontend/references/design-tokens.md` | Returns ≥2 |
| AC13 | Manual attestation: no rule uses "consider" or "best practice" as SOLE guidance without a Threshold field on the same rule | Blake self-review + Layer 2 reviewer verification |
| AC14 | `head -10 ~/web-frontend/CAPABILITY.md \| grep -c 'CONSUMES'` | Returns ≥1 |
| AC15 | `grep -cE 'React 19\|React 19\+' ~/web-frontend/references/*.md` | Returns ≥1 |
| AC16 | `wc -l ~/web-frontend/references/*.md \| awk '{if($1>800 && $2!="total")print "FAIL:"$2}'` | Empty output |
| AC17 | `ls ~/web-frontend/scripts/*.sh \| wc -l` | Returns 3 |
| AC18 | `grep -cE '^\*\*Rule' ~/web-frontend/CAPABILITY.md` | Returns 0 (CAPABILITY.md is pure router, zero inline rules) |
| AC19 | `find ~/web-frontend/ -name '*.md' -o -name '*.sh' \| xargs wc -l \| tail -1 \| awk '{print $1}'` | Returns ≤5000 (total line cap) |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: AC10 "Gate" substring matches navigate/investigate | §9.1 AC10 — changed to word-boundary recursive grep | Resolved |
| code-reviewer | P0-2: AC7 format mismatch (H2 vs bold) | §9.1 AC7 — standardized on `## Rule N` H2 format, documented in §3.3 | Resolved |
| code-reviewer | P0-3: AC1 shell precedence bug | §9.1 AC1 — rewritten with `test -d` + `find -quit` | Resolved |
| code-reviewer | P0-4: AC13 "consider" grep false positives | §9.1 AC13 — changed to manual attestation | Resolved |
| code-reviewer | P1-1: Dimension 8 (Build & Deploy) silently dropped | §4 Decision #7 added | Resolved |
| code-reviewer | P1-2: Scripts need URL input clarification | §5 AC17 — added URL input requirement + default localhost:3000 | Resolved |
| code-reviewer | P1-3: AC5 "Tier" grep false positives | §9.1 AC5 — changed to heading-level grep `^##+ Tier` | Resolved |
| code-reviewer | P1-5: DESIGN.md extraction mechanism underspecified | §3.2 Step 0 — added 3 extraction modes (CSS props/DTCG JSON/Tailwind) | Resolved |
| code-reviewer | P1-6: Missing verification for AC6,8,9,11,12,15 | §9.1 — added all 6 verification commands | Resolved |
| backend-architect | P0-1: 6 missing AC verifications (same as CR P1-6) | §9.1 — added all 6 | Resolved |
| backend-architect | P0-2: Anti-skip table mentioned but no AC | §5 AC18 added — CAPABILITY.md zero inline rules | Resolved |
| backend-architect | P0-3: AC7 format mismatch (same as CR P0-2) | §9.1 AC7 — H2 format | Resolved |
| backend-architect | P0-4: AC1 shell bug (same as CR P0-3) | §9.1 AC1 — rewritten | Resolved |
| backend-architect | P1-1: AC10 grep scope too narrow | §9.1 AC10 — changed to recursive with --exclude | Resolved |
| backend-architect | P1-2: Missing "zero inline rules" AC | §5 AC18 added | Resolved |
| backend-architect | P1-3: Missing total line count cap | §5 AC19 added (≤5000) | Resolved |
| backend-architect | P1-4: Router keyword "data" ambiguous | §3.2 — removed "data", added disambiguation rule | Resolved |
| backend-architect | P1-5: No --dry-run for install.sh | §5 AC6 — added --dry-run flag | Resolved |
| backend-architect | P1-7: Dimension 8 fold not documented | §4 Decision #7 added | Resolved |

---

## 10. Important Notes

### 10.1 Risk Mitigations (from Socratic Inquiry)

1. **"Rules too vague"** → AC8 + AC13 enforce every rule has a threshold/CLI command. No "consider" or "best practice" without concrete numbers.
2. **"web-ui-design boundary blur"** → AC14 forces CAPABILITY.md to declare consumption-only. §3.4 interface contract defines what each pack touches.
3. **"React version churn"** → AC15 requires version annotations. Rules reference React 19+ stable APIs, not experimental.
4. **"File too long"** → AC16 caps each reference at 800 lines. Router pattern means agent only loads 1 reference per task.

### 10.2 Sub-Agent Usage

- **code-reviewer**: Review all reference files for rule quality + actionability
- **backend-architect**: Review CAPABILITY.md router design + install.sh architecture (cross-skill concern — same reviewer who reviewed web-backend)

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Framework | React-only / Agnostic / Dual | React-first + annotations | Actionable rules need specific APIs |
| 2 | Structure | web-ui-design / web-backend / new | web-backend (router + refs) | Proven progressive disclosure |
| 3 | DESIGN.md | Explicit / Optional / None | Explicit Step 0 | Interface contract with web-ui-design |
| 4 | Rule format | Prose / Table / Structured | When/Decision/Threshold/Source | Prevents vagueness |
| 5 | Dimensions | 4 core / all 7 | All 7 | Each has unique non-overlapping rules |
| 6 | Checklist | Flat / 3-tier | 3-tier | Proven in web-backend |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md) — CAPABILITY.md 没有 YAML frontmatter 会安装成功但 Claude Code 不加载。必须有 `name:` + `description:` 两个字段。
- **Capability Pack: Multi-Agent Install Pattern — Phase N Stubs** (architecture.md) — install.sh 的 `--agent codex/cursor/gemini` 必须返回 exit 2 + 提示信息，不是 exit 0 空操作。
- **Capability Pack Rule Sourcing: Read the Cited Source, Not Just the Citation** (architecture.md) — 每条规则写之前必须 WebFetch 实际源文件。不要从训练数据写然后贴 attribution。web-backend 的 11 个 P1 就是这个原因。
- **DESIGN.md Spec Integration as a Type A Capability** (architecture.md) — 外部规范导入时要标注 license + 版本 + 检索日期。DESIGN.md 是 Google Labs 概念（Apache 2.0, alpha）。
