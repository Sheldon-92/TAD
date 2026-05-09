---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Agent Capability Pack — web-ui-design (Phase 1)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-07
**Project:** TAD (→ independent repo)
**Epic:** EPIC-20260507-agent-capability-packs (Phase 1/4)

---

## 1. Task Overview

Build the first **Agent Capability Pack** — a self-contained, portable package that gives an AI coding agent professional-grade web UI design skills.

**Phase 1 target: Claude Code.** Cross-agent (Codex, Cursor, Gemini) in Phase 3. Design with extensibility interfaces from day one.

**This is NOT a TAD SKILL.md or Domain Pack YAML.** It's a new product category: a universal capability module that works without any framework.

### Core Idea
> VoltAgent gave brands a DESIGN.md so AI agents know "what Stripe looks like."
> We're building a CAPABILITY.md so AI agents know "how to do web UI design."

### What It Combines
- Anthropic's aesthetic philosophy (anti-AI-slop, bold direction commitment)
- VoltAgent's DESIGN.md 9-section standard (token, rule, rationale in one file)
- CLI tool chains verified as FULLY_CLI (14 tools)
- Automated quality verification (6 checks + 6 anti-slop rules)
- Real company design system patterns (Polaris, Primer, Spectrum)

---

## 2. Why This Matters

Current state: AI agents produce generic, "AI-slop" UI — Inter font, purple gradient, card grid, no character. Domain Pack YAMLs list tools but don't teach workflows. Anthropic's frontend-design skill teaches taste but not tools.

After this lands: Any AI agent with this capability pack produces UI that has:
- A committed aesthetic direction (not "safe" defaults)
- Proper design token architecture (primitive → semantic → component)
- Accessible, responsive, verified code
- Specific CLI tools for every step of the workflow

---

## 3. Deliverables

### 3.1 Independent Repository Structure

```
web-ui-design-capability/
├── README.md                    ← What this is, how to install, quick start
├── LICENSE                      ← MIT or Apache 2.0
├── LICENSE-ATTRIBUTION.md       ← Source attribution (Anthropic Apache 2.0, VoltAgent, etc.)
├── CHANGELOG.md                 ← Version history
├── install.sh                   ← Phase 1: Claude Code only; Phase 3: multi-agent
├── CAPABILITY.md                ← Main file: entry protocol + 9 capabilities (Vision→Execution→Validation)
├── DESIGN-TEMPLATE.md           ← Template for generating project-specific DESIGN.md
├── checklists/
│   ├── accessibility.md         ← WCAG/APCA checks with CLI commands
│   ├── anti-slop.md             ← Anthropic 6 rules + expanded patterns
│   ├── responsive.md            ← Breakpoints, touch targets, fluid typography
│   └── post-generation.md       ← Semantic HTML, relative units, CSS purge
├── tools/
│   ├── tool-registry.md         ← 14+ FULLY_CLI tools with install/test/use commands (PARTIAL_CLI noted separately)
│   ├── component-matrix.md      ← shadcn vs Radix vs Ark vs MUI selection guide
│   └── tokens-to-css.sh         ← Level 0: pure bash+jq token→CSS compiler (no npm required)
├── references/
│   ├── brand-tokens.md          ← Stripe/Vercel/Linear token examples (reference only, not defaults)
│   ├── design-system-patterns.md ← Polaris/Primer/Spectrum architecture patterns
│   └── awesome-lists.md         ← Curated links to GitHub awesome-lists
└── examples/
    └── starter-tokens.json      ← Neutral defaults (not branded), 60-30-10 skeleton
```

### 3.2 CAPABILITY.md Core Structure

The main file follows a **Vision → Execution → Validation** pipeline for each of 9 capabilities:

```
# Web UI Design Capability Pack

## Meta
- Version, compatibility, loading instructions per agent

## How This Works
- 3 paragraphs: what this pack does, how to use it, what it doesn't do

## Entry Protocol (decision tree — CRITICAL)
- Decision tree: "Building from scratch? Start at C1. Have a design? Start at C5. Reviewing existing UI? Jump to C7."
- Minimum viable path: C3 (Visual Design) + C5 (Design System) + C7 (Usability Review) — the core trio
- Stop-early rule: "If user asked for a single component, skip C1/C2/C6/C9"
- Token budget awareness: "On limited-context agents, load only the capabilities you need"

## Capabilities (9 sections, each with Vision → Execution → Validation)
NOTE: Each capability's Execution section MUST lead with framework-agnostic tools FIRST,
then list framework-specific options as "If React:" / "If Vue:" branches.

### 1. Information Architecture
  **Vision**: navigation pattern decision framework, user flow mapping
  **Execution**: Mermaid CLI (`mmdc -i`), D2 (`d2 arch.d2`), next-sitemap
  **Validation**: ≤5 steps for core tasks, high-freq within 2 clicks

### 2. Wireframing
  **Vision**: structural first, no premature styling
  **Execution**: headless components (Ark UI, Headless UI), Pico.css for class-less
  **Validation**: semantic HTML check, no div soup

### 3. Visual Design
  **Vision**: bold aesthetic commitment (from Anthropic SKILL), 60-30-10 color
  **Execution**: Style Dictionary (`npx style-dictionary build`), token architecture
  **Validation**: APCA contrast, anti-slop checklist

### 4. Interaction Design
  **Vision**: purposeful motion, ≤100ms feedback, ≤300ms transitions
  **Execution**: CSS animations (universal) → If React: Framer Motion → Accessible: React Aria / Radix
  **Validation**: keyboard navigation, focus management, ARIA audit

### 5. Design System (owns Storybook SETUP)
  **Vision**: component library selection based on project needs
  **Execution**: Universal: Ark UI (multi-framework) / DaisyUI (CSS-only) → If React: shadcn-ui → Storybook init
  **Validation**: component-matrix selection justified, Storybook running

### 6. Responsive Design
  **Vision**: mobile-first, container queries for components
  **Execution**: clamp() typography, auto-fit grids, picture/srcset images
  **Validation**: 4 breakpoints tested, 44px tap targets, fluid scaling

### 7. Usability Review
  **Vision**: automated + manual checklist (know the 25-40% automation limit)
  **Execution**: axe-core CLI, Lighthouse CI, Pa11y, Chromatic
  **Validation**: all 6 automated checks pass, manual notes documented

### 8. Design System Documentation (owns Storybook CONFIGURATION — C5 owns SETUP)
  **Vision**: living documentation, not static pages
  **Execution**: Storybook autodocs + addons config, react-docgen, design.md generation
  **Validation**: every component has props table + usage example + do/don't

### 9. Design Iteration Decisions
  **Vision**: ADR format for design decisions, evidence-based iteration
  **Execution**: PostHog A/B testing, token version control via Git
  **Validation**: decision log maintained, no undocumented reversals

## Anti-AI-Slop Rules (global, applies to ALL capabilities)
- 6 rules from Anthropic + expanded from research

## Agent Loading Guide
Phase 1 (this handoff):
- Claude Code: copy to `.claude/skills/web-ui-design/SKILL.md`

Phase 3 (future — interface reserved):
- Codex: append reference to `AGENTS.md` (project root)
- Cursor: generate `.cursorrules` with embedded content or `@file` reference
- Gemini CLI: pass via `-p` with context file
- Generic: drop CAPABILITY.md in project root
```

### 3.3 install.sh

Phase 1 scope (Claude Code only):
1. Detects `.claude/` directory exists
2. Copies CAPABILITY.md → `.claude/skills/web-ui-design/SKILL.md`
3. Copies supporting files (checklists/, tools/, references/, examples/) to same skill dir
4. Supports `--dry-run` flag: prints detection results and copy plan without modifying files
5. Reports what was installed

Phase 3 interface (reserved, not implemented):
- `--agent codex`: append reference to AGENTS.md
- `--agent cursor`: generate .cursorrules with content
- Agent auto-detection via directory presence

### 3.4 Cross-Agent Loading (Phase 1 = Claude Code; others = Phase 3)

Research finding: all major agents converge on Markdown format, diverge on directory path. Phase 1 ships Claude Code only; design reserves interface for others.

| Agent | Auto-load Path | Format | Phase |
|-------|---------------|--------|-------|
| Claude Code | `.claude/skills/{name}/SKILL.md` | Markdown | **Phase 1** |
| Codex | `AGENTS.md` (project root) with file reference | Markdown | Phase 3 |
| Cursor | `.cursorrules` or `.cursor/rules/` | Markdown | Phase 3 |
| Gemini CLI | context via `-p` flag | Markdown | Phase 3 |

### 3.5 Token Pipeline (3-level, framework-agnostic)

| Level | Requirement | Tool | Command |
|-------|-----------|------|---------|
| Level 0 (universal) | bash + jq only | `tokens-to-css.sh` | `bash tools/tokens-to-css.sh examples/starter-tokens.json > tokens.css` |
| Level 1 (Node available) | npm | Style Dictionary | `npx style-dictionary build` |
| Level 2 (design system scale) | Figma | Tokens Studio | GUI plugin → JSON → Git |

Level 0 is the baseline — the pack works even without Node installed.

---

## 4. Research Foundation

All content draws from 3 rounds of NotebookLM research (notebook `fd4f9117`, 119 sources):

- **Round 1** (9 questions): CLI tools, component libraries, design patterns per capability
- **Round 2** (4 questions): real company design systems, Claude Code capabilities, tool verification matrix, competitive SKILL analysis
- **Round 3** (3 questions): DESIGN.md 9-section standard, subagent role division, ecosystem tools top 10

Full findings: `.tad/evidence/research/web-ui-design-rebuild/2026-05-07-research-findings.md`

### Key Research to Reference During Implementation
- Tool Verification Matrix (14 FULLY_CLI, 3 PARTIAL_CLI, 1 GUI_ONLY)
- DESIGN.md 9-section standard from VoltAgent (16 brand examples)
- Anthropic frontend-design SKILL (anti-AI-slop rules)
- Component Library Selection Matrix (8 libraries compared)
- Subagent role division pattern (Design Bridge → UI Designer → Frontend Dev → Tester)

---

## 5. Implementation Notes

### 5.1 Writing Style for CAPABILITY.md
- **Imperative, not descriptive**: "Run `npx style-dictionary build`" not "Consider using Style Dictionary"
- **Every section must have at least 1 CLI command**: if there's no command, the section is theory (delete it)
- **Token examples in references/ must be real**: use Stripe/Vercel values from research
- **Token examples in examples/ must be neutral**: no branded colors as defaults
- **Anti-slop rules must be concrete**: "NEVER use Inter, Roboto, Arial" not "avoid generic fonts"
- **Tool registry format**: entries use exact labels `Install:`, `Test:`, `Use:` (capitalized, colon) for grep-ability
- **Framework-agnostic first**: each capability leads with universal tools, then "If React:" / "If Vue:" branches

### 5.2 File Size Budget
- CAPABILITY.md: target 2000-3000 lines (Phase 1 = Claude Code, 1M context is fine; Phase 3 will split for smaller-context agents)
- Each checklist: 50-100 lines
- Tool registry: 200-300 lines
- Total pack: under 5000 lines across all files
- Phase 3 interface: CAPABILITY.md has clear `## Capability N` markers so it can be split into per-capability files later

### 5.3 What NOT to Include
- No TAD-specific concepts (no "Gate [1-4]", "Ralph Loop", "Agent A", "Agent B")
- No React-only code without framework-agnostic alternative listed first
- No version-pinned packages (use `@latest` or unversioned) — Exception to global version-pinning rule: this is a reference document for external users, not a lock file. Users choose their own versions at install time.
- No GUI-only tools (every recommended tool must have CLI path; PARTIAL_CLI tools noted with "manual step required")

### 5.4 Research-During-Implementation
Blake should use NotebookLM notebook `fd4f9117` when encountering uncertainties. Key pattern:
1. Formulate question
2. `~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n fd4f9117-a869-4d4e-ade9-6eea34d031b2`
3. Integrate answer into the capability pack
4. Log the question + answer in evidence

---

## 6. Files to Create

| # | File | Purpose | Lines (est.) |
|---|------|---------|-------------|
| 1 | `README.md` | Repo overview + install + quick start | 100-150 |
| 2 | `LICENSE` | MIT or Apache 2.0 | 20 |
| 3 | `LICENSE-ATTRIBUTION.md` | Source attributions (Anthropic Apache 2.0, VoltAgent, etc.) | 30-50 |
| 4 | `CHANGELOG.md` | Version history (start with v0.1.0) | 20-30 |
| 5 | `CAPABILITY.md` | Main: entry protocol + 9 caps × Vision/Execution/Validation | 2000-3000 |
| 6 | `DESIGN-TEMPLATE.md` | Template for project-specific DESIGN.md | 200-300 |
| 7 | `install.sh` | Phase 1: Claude Code install + --dry-run | 50-80 |
| 8 | `checklists/accessibility.md` | WCAG/APCA checks with commands | 80-100 |
| 9 | `checklists/anti-slop.md` | Anti-AI-slop rules (Anthropic 6 + expanded) | 50-80 |
| 10 | `checklists/responsive.md` | Responsive design checks | 50-80 |
| 11 | `checklists/post-generation.md` | Post-gen cleanup checklist | 50-80 |
| 12 | `tools/tool-registry.md` | 14+ FULLY_CLI tools (Install:/Test:/Use: format); PARTIAL_CLI noted separately | 200-300 |
| 13 | `tools/component-matrix.md` | Library selection guide (universal first, framework branches) | 100-150 |
| 14 | `tools/tokens-to-css.sh` | Level 0 token compiler: bash+jq only, no npm | 40-60 |
| 15 | `references/brand-tokens.md` | Real token examples (reference, not defaults) | 150-200 |
| 16 | `references/design-system-patterns.md` | Architecture patterns | 100-150 |
| 17 | `references/awesome-lists.md` | Curated GitHub links | 50-80 |
| 18 | `examples/starter-tokens.json` | Neutral defaults, 3-level structure | 80-120 |

**Location**: `~/web-ui-design-capability/` (independent of TAD)

---

## 7. Acceptance Criteria

- [ ] AC1: CAPABILITY.md has Entry Protocol + 9 capability sections, each with Vision + Execution + Validation
- [ ] AC2: Every Execution sub-section contains ≥1 actual CLI command (no theory-only sections)
- [ ] AC3: Anti-slop rules section contains the 6 Anthropic rules (Inter/Roboto ban, purple gradient ban, scattered animation ban, bold aesthetic enforce, unexpected spatial enforce, solid background ban) + ≥4 expanded rules
- [ ] AC4: Tool registry lists ≥14 FULLY_CLI tools with `Install:`, `Test:`, `Use:` labels each; PARTIAL_CLI tools noted separately
- [ ] AC5: Component matrix includes ≥8 libraries with Type, A11y, Bundle, Framework columns
- [ ] AC6: Brand token examples in references/brand-tokens.md use real values (Stripe #533afd, Vercel #171717 etc.); starter-tokens.json uses NEUTRAL non-branded defaults
- [ ] AC7: install.sh Phase 1: detects .claude/ → copies to .claude/skills/web-ui-design/; supports --dry-run flag
- [ ] AC8: DESIGN-TEMPLATE.md follows VoltAgent 9-section standard
- [ ] AC9: All 4 checklists are actionable (each item is a `- [ ]` yes/no check, not advice)
- [ ] AC10: starter-tokens.json is valid JSON with top-level keys "primitive", "semantic", "component"
- [ ] AC11: Zero TAD-specific terminology (grep for "Ralph Loop", "Gate [1-4]", "Agent A", "Agent B" returns 0)
- [ ] AC12: Total line count across all files ≤ 5000
- [ ] AC13: LICENSE-ATTRIBUTION.md exists with Anthropic Apache 2.0 citation
- [ ] AC14: tokens-to-css.sh converts starter-tokens.json to valid CSS custom properties using only bash+jq
- [ ] AC15: Entry Protocol section contains decision tree + minimum viable path (C3+C5+C7) + stop-early rule
- [ ] AC16: Each capability's Execution leads with framework-agnostic tools; framework-specific as "If React:" branches

---

## 8. Expert Review Status

### Round 1 (2026-05-07)

| Expert | Verdict | P0 | P1 | P2 |
|--------|---------|----|----|-----|
| code-reviewer | CONDITIONAL PASS | 4 | 6 | 5 |
| backend-architect | CONDITIONAL PASS | 5 | 5 | 4 |

### P0 Issues Resolved

| # | Source | Issue | Resolution |
|---|--------|-------|-----------|
| 1 | CR-P0-1 | AC11 grep "Gate\|Alex" false positives | Fixed: grep for TAD-specific compound terms only (§9 AC11) |
| 2 | CR-P0-2 | AC3 grep "NEVER" misses "Enforce"/"Ban" rules | Fixed: grep for specific anti-slop rule subjects (§9 AC3) |
| 3 | CR-P0-3 + BA-P0-3 | Codex path `.agents/` is wrong | Fixed: Phase 1 = Claude Code only; Codex/Cursor deferred to Phase 3 with interface reserved (§3.3, §3.4) |
| 4 | CR-P0-4 + BA-P1-5 | Tool count "18" inconsistent | Fixed: "14+ FULLY_CLI" throughout; PARTIAL_CLI noted separately (§3.1, §6) |
| 5 | BA-P0-1 | React-centric despite framework-agnostic claim | Fixed: each capability leads with universal tools, React as "If React:" branch (§3.2 NOTE, §5.1, AC16) |
| 6 | BA-P0-2 | Token pipeline assumes npm | Fixed: added Level 0 bash+jq fallback via tokens-to-css.sh (§3.5, AC14) |
| 7 | BA-P0-4 | Missing entry protocol | Fixed: added Entry Protocol with decision tree + minimum viable path + stop-early rule (§3.2, AC15) |
| 8 | BA-P0-5 | 2000-3000 lines too large for cross-agent | Deferred to Phase 3: Phase 1 = Claude Code (1M context OK); design has clear markers for future splitting (§5.2) |

### P1 Issues Integrated

| # | Source | Issue | Resolution |
|---|--------|-------|-----------|
| 1 | CR-P1-2 | AC7 --dry-run not in spec | Added to §3.3 |
| 2 | CR-P1-3 | AC4 format-coupling | Added Install:/Test:/Use: format spec to §5.1 |
| 3 | CR-P1-4 + BA-P1-2 | Missing license attribution | Added LICENSE-ATTRIBUTION.md to deliverables + AC13 |
| 4 | CR-P1-5 | @latest conflicts with global security policy | Added exception note to §5.3 |
| 5 | CR-P1-6 | C5 vs C8 Storybook overlap | Added ownership split: C5=SETUP, C8=CONFIGURATION (§3.2) |
| 6 | BA-P1-1 | AC verification commands brittle | Fixed throughout §9 |
| 7 | BA-P1-3 | starter-tokens.json uses branded defaults | Fixed: neutral defaults in starter, brand values only in references/ (AC6) |
| 8 | BA-P1-4 | No versioning | Added CHANGELOG.md + version field (§3.1, §6) |

---

## 9. Spec Compliance Checklist

Note: `\|` in verification commands represents shell pipe `|` (escaped for markdown table rendering).

| AC | Verification Method | Expected Evidence |
|----|-------------------|------------------|
| AC1 | `grep -c "^### [0-9]" CAPABILITY.md` | 9 |
| AC2 | `grep -c '```' CAPABILITY.md` | ≥18 (≥2 code blocks per capability) |
| AC3 | `grep -ic "Inter.*Roboto\|purple gradient\|scattered.*animation\|bold aesthetic\|spatial composition\|solid background" CAPABILITY.md` | ≥6 |
| AC4 | `grep -c "^Install:" tools/tool-registry.md` | ≥14 |
| AC5 | `grep -c "^|" tools/component-matrix.md` | ≥10 (header + 8 libs + separator) |
| AC6 | `grep -c "#533afd\|#171717\|#5e6ad2" references/brand-tokens.md` | ≥2 |
| AC7 | `bash install.sh --dry-run 2>&1` | Shows ".claude/ detected" + copy plan |
| AC8 | `grep -c "^## " DESIGN-TEMPLATE.md` | ≥9 |
| AC9 | `grep -rc "^- \[ \]" checklists/` | ≥20 total |
| AC10 | `python3 -c "import json; d=json.load(open('examples/starter-tokens.json')); assert all(k in d for k in ['primitive','semantic','component'])"` | exit 0 |
| AC11 | `grep -rli "Ralph Loop\|Gate [1-4]\|Agent A\|Agent B" *.md */*.md */*.sh` | 0 files |
| AC12 | `find . \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) \| xargs wc -l \| tail -1` | ≤5000 |
| AC13 | `grep -c "Apache 2.0" LICENSE-ATTRIBUTION.md` | ≥1 |
| AC14 | `bash tools/tokens-to-css.sh examples/starter-tokens.json > /tmp/test.css && grep -c "^--" /tmp/test.css` | ≥5 CSS custom properties |
| AC15 | `grep -c "minimum viable\|stop early\|decision tree" CAPABILITY.md` | ≥3 |
| AC16 | `grep -c "If React:" CAPABILITY.md` | ≥3 (at least C4, C5, C8 have React branches) |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **DESIGN.md Spec Integration as a Type A Capability** (architecture.md) — When importing external spec into Domain Pack, verify license + pin version + declare read-only consumption of upstream outputs
- **Anti-AI-Slop Philosophy as a Cross-Pack Quality Bar** (architecture.md) — Anti-slop criteria need positive framing alongside negative; pair "don't do X" with "do Y instead"
- **Judgment-Only Skill Files AMENDED** (architecture.md) — Constraint rules (MUST/MANDATORY/VIOLATION) are NOT mechanical — they cannot be removed during slimming

---

## 🔧 Domain Pack References (Blake 必读)

N/A — This handoff creates a NEW product category, not a Domain Pack modification.

---

## 10. Important Notes

### 10.1 This is NOT a TAD artifact
The output repo must stand alone. Someone with zero knowledge of TAD should be able to clone it, run install.sh, and have their AI agent immediately produce better UI.

### 10.2 Research notebook is available
Blake can query NotebookLM at any point:
```bash
~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n fd4f9117-a869-4d4e-ade9-6eea34d031b2
```

### 10.3 Anti-slop rules must cite source
When writing the anti-slop section, cite: "Based on Anthropic frontend-design SKILL (Apache 2.0)" for the 6 core rules. Expanded rules cite our research notebook.

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Format | YAML / JSON / Markdown | Markdown | LLM-native, all agents read it, no parser needed |
| 2 | Repo | Inside TAD / Independent | Independent | Zero-dependency portability |
| 3 | Structure | Single file / Multi-file pack | Multi-file pack | CAPABILITY.md is core; checklists/tools/references are supporting |
| 4 | Cross-agent | One file per agent / Universal + install script | Universal + install.sh | Same content, different paths; Phase 1 = Claude Code only |
| 5 | Token format | CSS variables / JSON / Both | JSON + Level 0 bash+jq fallback | W3C DTCG spec + works without Node |
| 6 | Phase 1 scope | All agents / Claude Code only | Claude Code only | Validate concept first, adapt in Phase 3; design with interfaces |
| 7 | Framework stance | React-only / Universal-first | Universal-first with React branches | Framework-agnostic tools lead; "If React:" as enhancement |
| 8 | File size | Split now / Split later | Split later (Phase 3) | Claude Code 1M context handles 3K lines; markers for future split |
