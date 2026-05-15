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
| 1g | Build ai-evaluation Pack | ✅ Done | HANDOFF-20260515-capability-pack-ai-evaluation.md | 9 pack files, 43 rules, 7 capabilities, 369-source research. Gate PASS |
| 1h | Build web-testing Pack | ✅ Done | COMPLETION-20260515-capability-pack-web-testing.md | 9 files, 48 rules, 6 capabilities. Gate PASS |
| 1i | Build code-security Pack | ✅ Done | COMPLETION-20260515-capability-pack-code-security.md | 8 files, 36 rules, 5 capabilities. Gate PASS |
| 1j | Build web-deployment Pack | ✅ Done | COMPLETION-20260515-capability-pack-web-deployment.md | 11 files, 51 rules, 7 capabilities. Gate PASS |
| 1k | Build ai-tool-integration Pack | ✅ Done | COMPLETION-20260515-capability-pack-ai-tool-integration.md | 10 files, 7 capabilities, MCP SDK rules. Gate PASS |
| 2 | Real Project Validation | ✅ Done | (in-session validation) | 13/13 installed + registered + active in TAD project. Gate PASS |
| 2b | YAML Freeze + Deprecation | ✅ Done | (in-session) | 11 YAML frozen + hook skip logic added. 9 unconverted packs remain active |
| 3 | Cross-Agent Validation | ✅ Done | (in-session) | Codex tested: code-security + web-deployment packs loaded + rules extracted. AGENTS.md routing added |
| 4 | Template Extraction | ✅ Done | (in-session) | Template at .tad/templates/capability-pack-template/ + README with 13-pack patterns |

### Phase Dependencies
Phases 1g-1k are independent (can YOLO in sequence). Phase 2 validates all packs. Phase 2b depends on Phase 2 PASS. Phase 3 validates portability. Phase 4 validates generalizability.

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

### Next Phase Scope (updated 2026-05-15)
Phases 1a-1f: ALL COMPLETE — 6 capability packs built
Phases 1g-1k: Batch 1 expansion — 5 new packs via research-driven /capability-upgrade
Phase 2: Real project validation with all 13 packs
Phase 2b: YAML freeze for all converted Domain Packs

---

## Phase Detail Blocks (Phases 1g-1k, 2, 2b)

### Phase 1g: ai-evaluation Capability Pack
**Status:** ⬚ Planned
**Scope:** Build ai-evaluation capability pack using /capability-upgrade 5-stage methodology. Source: `.tad/domains/ai-evaluation.yaml` (877 lines, 7 capabilities: eval_framework_design, benchmark_testing, ab_testing, regression_testing, adversarial_testing, automated_pipeline, human_eval_protocol). NOT a YAML format conversion — full deep research → design → build cycle. Key tools: promptfoo, deepeval, langfuse.
**NOT in scope:** Runtime eval infrastructure, SaaS integration, building the eval platform itself.
**Input:** Domain Pack YAML + existing 8 pack examples for format reference
**Output:** Complete capability pack at `.tad/capability-packs/ai-evaluation/` + registered in pack-registry.yaml + installed as skill
**AC:**
- [ ] NotebookLM notebook created with ≥20 curated sources (GitHub awesome-lists + tool repos + academic papers on agent evaluation)
- [ ] ≥3 rounds of deep ask completed, findings saved to `.tad/evidence/research/ai-evaluation-capability-pack/`
- [ ] SKILL.md with YAML frontmatter (`name:` + `description:`) and token count < 5,000
- [ ] All 7 Domain Pack capabilities have corresponding judgment rules in references/
- [ ] install.sh runs successfully (exit 0) + post-install frontmatter verification passes
- [ ] pack-registry.yaml entry added with keywords, consumes, produces fields
- [ ] determinismLevel metadata preserved from Domain YAML (deterministic / semi-deterministic / non-deterministic)
**Files Likely Affected:**
- `.tad/capability-packs/ai-evaluation/SKILL.md` — CREATE
- `.tad/capability-packs/ai-evaluation/CAPABILITY.md` — CREATE
- `.tad/capability-packs/ai-evaluation/install.sh` — CREATE
- `.tad/capability-packs/ai-evaluation/references/*.md` — CREATE (3-6 reference files)
- `.tad/capability-packs/pack-registry.yaml` — MODIFY
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY (new notebook entry)
**Dependencies:** None (independent of other 1g-1k phases)
**YOLO Research Note:** Conductor runs NotebookLM research during Y2 (grounding), saves findings to evidence file. Alex sub-agent (Y3) reads findings file to create handoff. Blake sub-agent (Y5) builds pack from handoff.

### Phase 1h: web-testing Capability Pack
**Status:** ⬚ Planned
**Scope:** Build web-testing capability pack. Source: `.tad/domains/web-testing.yaml`. Covers E2E (Playwright/Cypress), unit testing, API testing, performance testing, accessibility testing, pair testing (4D Protocol). Key tools: Playwright, Vitest, k6, axe-core.
**NOT in scope:** Mobile testing (separate domain), test infrastructure setup.
**Input:** Domain Pack YAML + existing pack examples
**Output:** Complete capability pack at `.tad/capability-packs/web-testing/`
**AC:**
- [ ] NotebookLM notebook with ≥20 sources (testing frameworks, company testing strategies, tool repos)
- [ ] ≥3 rounds deep ask, findings saved
- [ ] SKILL.md frontmatter valid, < 5,000 tokens
- [ ] All Domain Pack capabilities covered in references/
- [ ] install.sh exit 0 + frontmatter verification
- [ ] pack-registry.yaml entry added
**Files Likely Affected:**
- `.tad/capability-packs/web-testing/` — CREATE (full directory)
- `.tad/capability-packs/pack-registry.yaml` — MODIFY
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY
**Dependencies:** None

### Phase 1i: code-security Capability Pack
**Status:** ⬚ Planned
**Scope:** Build code-security capability pack. Source: `.tad/domains/code-security.yaml`. Covers SAST, DAST, secret detection, IaC security lint, vulnerability triage. Key tools: semgrep, nuclei, gitleaks, checkov, trivy.
**NOT in scope:** Supply chain security (separate pack), compliance/SOC2, runtime monitoring.
**Input:** Domain Pack YAML + existing ai-agent-security notebook (9 sources, reusable)
**Output:** Complete capability pack at `.tad/capability-packs/code-security/`
**AC:**
- [ ] NotebookLM notebook with ≥15 sources (can cross-reference ai-agent-security-phase0b notebook)
- [ ] ≥3 rounds deep ask, findings saved
- [ ] SKILL.md frontmatter valid, < 5,000 tokens
- [ ] All 5 Domain Pack capabilities covered in references/
- [ ] install.sh exit 0 + frontmatter verification
- [ ] pack-registry.yaml entry added
**Files Likely Affected:**
- `.tad/capability-packs/code-security/` — CREATE
- `.tad/capability-packs/pack-registry.yaml` — MODIFY
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY
**Dependencies:** None

### Phase 1j: web-deployment Capability Pack
**Status:** ⬚ Planned
**Scope:** Build web-deployment capability pack. Source: `.tad/domains/web-deployment.yaml`. Covers platform selection, CI/CD pipeline, environment config, domain/DNS, monitoring, security hardening, rollback strategy. Key tools: Vercel/Netlify CLI, GitHub Actions, Docker, Terraform.
**NOT in scope:** Kubernetes orchestration, cloud-native architecture, multi-region deployment.
**Input:** Domain Pack YAML + existing pack examples
**Output:** Complete capability pack at `.tad/capability-packs/web-deployment/`
**AC:**
- [ ] NotebookLM notebook with ≥20 sources (deployment platforms, CI/CD patterns, monitoring tools)
- [ ] ≥3 rounds deep ask, findings saved
- [ ] SKILL.md frontmatter valid, < 5,000 tokens
- [ ] All Domain Pack capabilities covered in references/
- [ ] install.sh exit 0 + frontmatter verification
- [ ] pack-registry.yaml entry added
**Files Likely Affected:**
- `.tad/capability-packs/web-deployment/` — CREATE
- `.tad/capability-packs/pack-registry.yaml` — MODIFY
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY
**Dependencies:** None

### Phase 1k: ai-tool-integration Capability Pack
**Status:** ⬚ Planned
**Scope:** Build ai-tool-integration capability pack. Source: `.tad/domains/ai-tool-integration.yaml`. Covers MCP server development, CLI tool wrapping, API integration, tool schema design, tool permission model, tool testing, tool documentation. Key tools: MCP SDK, Claude Code plugin system, OpenAPI.
**NOT in scope:** MCP server hosting, production API gateway.
**Input:** Domain Pack YAML + existing pack examples + MCP 2026 Roadmap (from tad-evolution notebook)
**Output:** Complete capability pack at `.tad/capability-packs/ai-tool-integration/`
**AC:**
- [ ] NotebookLM notebook with ≥20 sources (MCP repos, Claude Code plugin docs, tool design patterns)
- [ ] ≥3 rounds deep ask, findings saved
- [ ] SKILL.md frontmatter valid, < 5,000 tokens
- [ ] All 7 Domain Pack capabilities covered in references/
- [ ] install.sh exit 0 + frontmatter verification
- [ ] pack-registry.yaml entry added
**Files Likely Affected:**
- `.tad/capability-packs/ai-tool-integration/` — CREATE
- `.tad/capability-packs/pack-registry.yaml` — MODIFY
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY
**Dependencies:** None

### Phase 2: Real Project Validation
**Status:** ⬚ Planned
**Scope:** Use all 13 capability packs (8 existing + 5 new) in a real project. Measure: pack activation rate, token savings, quality improvement (before/after comparison). Fix gaps discovered during real use.
**NOT in scope:** Building the project itself — only measuring pack effectiveness.
**Input:** All 13 installed capability packs + a real project (menu-snap or new)
**Output:** Validation report with metrics + gap fix PRs
**AC:**
- [ ] ≥3 distinct tasks tested across ≥3 different packs
- [ ] Activation rate measured: % of tasks where pack was detected and loaded
- [ ] Token savings measured: with-pack vs without-pack comparison
- [ ] Quality delta documented (subjective + any measurable metrics)
- [ ] Any gaps found → bug fixes or pack updates applied
**Files Likely Affected:**
- `.tad/evidence/validation/` — CREATE (validation report)
- Various pack files — MODIFY (bug fixes)
**Dependencies:** Phases 1g-1k complete

### Phase 2b: YAML Freeze + Deprecation
**Status:** ⬚ Planned
**Scope:** Freeze Domain Pack YAML files for all 13 converted domains. Add deprecation header to each frozen YAML. Update CLAUDE.md routing to prefer Capability Pack loading. Run *sync to push changes.
**NOT in scope:** Deleting YAML files (freeze only), converting remaining 7 Domain Packs (mobile + supply-chain — Batch 2).
**Input:** Phase 2 validation PASS
**Output:** 13 frozen YAML files + updated routing + synced to projects
**AC:**
- [ ] All 13 converted Domain Pack YAML files have deprecation header: `# DEPRECATED: Use capability pack instead. Frozen as of 2026-05-XX.`
- [ ] CLAUDE.md SessionStart hook stops loading frozen packs into additionalContext
- [ ] *sync pushes frozen state + new capability packs to all registered projects
- [ ] Regression test: frozen packs no longer appear in step1_5 Domain Pack matching
**Files Likely Affected:**
- `.tad/domains/*.yaml` — MODIFY (add deprecation header, 13 files)
- `.tad/hooks/session-start-hook.sh` — MODIFY (skip frozen packs)
- CLAUDE.md — MODIFY (routing update)
**Dependencies:** Phase 2 complete
