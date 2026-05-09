# Epic: Agent Capability Packs — Universal AI Design Skills

**Epic ID**: EPIC-20260507-agent-capability-packs
**Created**: 2026-05-07
**Owner**: Alex

---

## Objective
Build a cross-agent, self-contained "capability pack" standard — a portable package that any AI coding agent (Claude Code, Codex, Gemini, Cursor) can pick up and immediately gain professional-grade design skills. First instance: web-ui-design. Combines Anthropic's aesthetic philosophy + VoltAgent's DESIGN.md standard + CLI tool chains + automated quality verification.

## Success Criteria
- [ ] web-ui-design capability pack produces measurably better UI than without it in a real project
- [ ] Same pack works on at least 2 different AI agents (Claude Code + Codex)
- [ ] Format is generalizable — second domain pack (e.g., web-backend) can be created following the same template
- [ ] Independent repo, zero TAD dependency

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Design + Build web-ui-design Pack | ✅ Done | HANDOFF-20260507-capability-pack-web-ui-design.md | 18 files at ~/web-ui-design-capability/, Gate 4 PASS |
| 1b | Design + Build product-thinking Pack | ✅ Done | HANDOFF-20260507-capability-pack-product-thinking.md | 3 skills + 6 adapters at ~/product-thinking/, Gate 4 PASS |
| 1c | Design + Build web-backend Pack | ✅ Done | HANDOFF-20260507-capability-pack-web-backend.md | 43 rules + 46-item PRR at ~/web-backend/, Gate 4 PASS |
| 1d | Design + Build ai-agent-architecture Pack | ✅ Done | HANDOFF-20260507-capability-pack-ai-agent-architecture.md | 10 decisions + selection matrices at ~/ai-agent-architecture/, Gate 4 PASS |
| 1e | Design + Build web-frontend Pack | ✅ Done | HANDOFF-20260508-capability-pack-web-frontend.md | 18 files, 41 rules, 7 ref dims at ~/web-frontend/, Gate 4 PASS |
| 1f | Design + Build video-creation Pack | ✅ Done | HANDOFF-20260508-capability-pack-video-creation.md | 12 files, 2203 lines, 25 judgment rules at ~/video-creation/, Gate 4 PASS |
| 2 | Real Project Validation | ⬚ Planned | — | Use pack in menu-snap or new project, measure quality delta, fix gaps |
| 3 | Cross-Agent Validation | ⬚ Planned | — | Same pack on Codex, verify it works, document agent-specific loading |
| 4 | Template Extraction | ⬚ Planned | — | Generic capability pack template + CONSUMES/PRODUCES interface standard |

### Phase Dependencies
All phases are sequential. Phase 2 validates Phase 1's output. Phase 3 validates portability. Phase 4 validates generalizability.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Research Foundation
- NotebookLM notebook: `fd4f9117` (119 sources, 3 rounds × 16 questions)
- Research findings: `.tad/evidence/research/web-ui-design-rebuild/2026-05-07-research-findings.md`
- Key references: VoltAgent DESIGN.md (9-section standard), Anthropic frontend-design SKILL (anti-AI-slop), 16 brand DESIGN.md files, 4 subagent definitions, 12 awesome-lists, 6 company design system repos

## Key Design Decisions (from *discuss)
1. **Format**: Standard Markdown (LLM-native, no YAML/JSON dependency)
2. **Repo**: Independent GitHub repo, zero TAD/framework dependency
3. **User**: Self-first → validate → open source
4. **Risk mitigation**: Every section must have CLI commands (anti-theory), minimal file count (anti-complexity), tool references not version-pinned (anti-obsolescence)
5. **Process**: Research-driven — NotebookLM used throughout design, not just upfront

---

## Context for Next Phase
{Alex updates after each *accept}

### Completed Work Summary
- Phase 1: web-ui-design — 18 files, ~/web-ui-design-capability/ (Gate 4 PASS 2026-05-07)
- Phase 1b: product-thinking — 3 skills + 6 adapters, ~/product-thinking/ (Gate 4 PASS 2026-05-07)
- Phase 1c: web-backend — 43 rules + 46-item PRR, ~/web-backend/ (Gate 4 PASS 2026-05-07)
- Phase 1d: ai-agent-architecture — 10 decisions + selection matrices, ~/ai-agent-architecture/ (Gate 4 PASS 2026-05-07)
- Phase 1e: web-frontend — 18 files, 41 rules, 7 reference dimensions, ~/web-frontend/ (Gate 4 PASS 2026-05-08)

### Key Architecture Decision (Phase 1e Gate 4)
CONSUMES/PRODUCES interface contract: web-ui-design (PRODUCES DESIGN.md) → web-frontend (CONSUMES DESIGN.md). Future packs should declare these fields at CAPABILITY.md lines 7-8 to enable auto-detection of invocation order.

### Status Heading Into Phase 2
5 packs complete covering: UI design, product validation, web backend, AI agent architecture, frontend engineering.
Phase 2 (Real Project Validation) is the next target — use packs in menu-snap or a new project to measure quality delta.

### Completed Work Summary
- Phase 1: web-ui-design capability pack — 18 files, 3927 lines, ~/web-ui-design-capability/ (Gate 4 PASS 2026-05-07)
- Phase 1b: product-thinking capability pack — 3 skills + 6 adapters, 2532 lines, ~/product-thinking/ (Gate 4 PASS 2026-05-07)
- Phase 1c: web-backend capability pack — 43 rules + 46-item PRR at ~/web-backend/, Gate 4 PASS 2026-05-07
- Phase 1d: ai-agent-architecture capability pack — 10 decisions + selection matrices at ~/ai-agent-architecture/, Gate 4 PASS 2026-05-07

### Decisions Made So Far
- Domain Pack strategy: 20 → 8 active, rebuild as capability packs on demand
- web-ui-design: 119 sources research → 18-file capability pack (Vision→Execution→Validation)
- product-thinking: 52 sources research → 3 deep skills (pressure-test/shotgun/define) > 40 thin templates
- Product type adapter pattern: same questions, different data sources per type (6 types)
- GStack office-hours model as primary inspiration for adversarial diagnosis
- `/capability-upgrade` SKILL created to codify the upgrade methodology
- **web-backend: Pack = domain judgment, TAD = process constraint, no overlap** (key insight from *discuss)
- **web-backend: 1 SKILL.md router + 8 references/ (progressive disclosure) > multiple separate skills** (rules are facets of one judgment framework, not independent workflows)
- **web-backend: Inline language branches > adapter files** (80% rules are universal, adapter files would duplicate)
- **web-backend: Context-scoped rules > absolute rules** (expert review caught 5 "never X" rules that need "if Y context" scoping)
- **web-backend: 3-tier PRR** (automatable ~25 / human attestation ~12 / infra-dependent ~9)

### Known Issues / Carry-forward
- Cross-agent loading mechanism undefined (Claude=CLAUDE.md, Codex=AGENTS.md, Cursor=.cursorrules — need unified approach)
- Tool freshness: need update mechanism without version pinning
- File size budget: too long = agent ignores, too short = incomplete
- web-backend context router: keyword matching may have collision on multi-context prompts (P1-2 from code-reviewer) — may need decision tree in future

### Next Phase Scope
Phase 1a-1d: ALL COMPLETE — 4 capability packs built (web-ui-design, product-thinking, web-backend, ai-agent-architecture)
Phase 2: Real project validation — use all 4 packs in menu-snap or new project
