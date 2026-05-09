# 下一步行动

## In Progress

- [x] **Pack Integration & Migration (TASK-20260508-002)** — Gate 3 PASS 2026-05-08, commit 49b0e50
  - 7 packs migrated to .tad/capability-packs/; pack-registry.yaml auto-generated; Alex step1_5b added
  - Awaiting Alex Gate 4 acceptance

- [x] **EPIC: TAD Universal Method** — 已迁移到独立开发项目 `~/tad-method-dev/` (2026-05-02)
  - Phase 0 ✅ + Phase 1 ✅ 在此完成；Phase 2+ 在 ~/tad-method-dev/ 继续
  - 产品代码: ~/tad-method/ | 开发管理: ~/tad-method-dev/

- [x] **EPIC: NotebookLM Research Director — ALL 4/4 PHASES COMPLETE (2026-05-04)** — Epic archived
  - Phase 0: spike 24-row | Phase 1: SKILL 14 cmd | Phase 2: Director+19 cmd | Phase 3: E2E 6/6 PASS
  - Archived: `.tad/archive/epics/EPIC-20260504-notebooklm-research-director.md`

- [ ] **EPIC: TAD Depth-First Capability Building** — 先深后宽，原能力打磨 + Domain Pack 重建 (NEW 2026-05-05)
  - Research notebook: `37cfefa5` (49 sources, 5 rounds deep ask)
  - Research findings: `.tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md`
  - **Phase 1: Research Capability Polish** — code changes DONE (2026-05-05, commits 69b2450 + 6b86950)
    - ✅ Fix auto-activation: CLAUDE.md §2 routing row + /deep-research exclusion
    - ✅ Fix session continuity: SKILL.md Standalone Usage + REGISTRY check in routing
    - ✅ Close the loop: step6 Research → Action Bridge (5 options)
    - ⬚ Real-project validation: 在下一个真实项目中验证研究 pipeline 是否自动触发
  - **Phase 2: Domain Pack Freeze + Rebuild** — Decision made 2026-05-07
    - ⬚ Remove 13 frozen packs from keywords.yaml (keep 8 active: web-frontend, web-backend, web-ui-design, mobile-development, mobile-release, ai-agent-architecture, ai-prompt-engineering, product-definition)
    - ⬚ Merge mobile-testing → web-testing, mobile-ui-design → web-ui-design (mobile-specific quality criteria only)
    - ⬚ Archive tools-registry.yaml → .tad/archive/domains/
    - ⬚ Rebuild strategy: on-demand when real project needs it → NotebookLM research → SKILL.md
    - Key insight: SKILL.md (菜谱/action-ready) > YAML (食材清单/informational)
    - Evidence: Knowledge Activation paper (arxiv 2603.14805)

- [ ] **EPIC: Goal-Driven Research Director** — 业务目标驱动自主研究
  - Epic: `.tad/active/epics/EPIC-20260504-goal-driven-research.md`
  - ⬚ Phase 0: Cross-Project Sync Wizard (方案 C — 解决 29 vs 1 REGISTRY 差距)
  - ✅ Phase 1: Business Objective Definition (OBJECTIVES.md OKR) — DONE 2026-05-04 (commit cc2ceff)
  - ⬚ Phase 2: Autonomous Research Strategy (目标→研究问题→自主发起)
  - ⬚ Phase 3: Research-Decision Loop (追踪 + --caller flag)

- [ ] **EPIC: Cross-Model Orchestration** — Phase 0/0b/1 ✅ DONE, Phase 2 (validation) planned
  - Epic: `.tad/active/epics/EPIC-20260503-cross-model-orchestration.md`
  - ✅ Phase 0: Spike A SKIP | Spike B DEFER | Spike C INTEGRATE
  - ✅ Phase 0b: NotebookLM INTEGRATE (15 sources, 6 video-exclusive findings)
  - ✅ Phase 1: *research-notebook SKILL (8 commands) + capabilities.yaml + Alex integration
  - ⬚ Phase 2: Validation — 真实项目使用 *research-notebook + Codex image_gen

- [x] **EPIC: GitHub Knowledge Integration — ALL 3/3 PHASES COMPLETE (2026-05-04)**
  - Archived: `.tad/archive/epics/EPIC-20260504-github-knowledge-integration.md`
  - ✅ Phase 1: GitHub Registry (24 domains, 50 awesome-lists, 6 commands)
  - ✅ Phase 2: Alex Workflow (step2c_github + auto-refresh + research priority rule)
  - ✅ Phase 3: Automation (weekly scan routine + scan-log + STEP 3.9 notification)
  - To activate: user runs /schedule with routine prompt from research-github SKILL

- [ ] **EPIC: Security Domain Pack Chain** — Phase 0+1 COMPLETE, evaluate before Phase 2
  - ✅ Phase 0: Security Tool Research (commit e2c325a)
  - ✅ Phase 1: supply-chain (639L) + code-security (873L) + 24 tools (commit 39e8017)
  - ⏸️ Phase 2-4: Paused — run real-project security audit first to validate Pack value

- [x] **Agent Capability Pack — product-thinking** — ✅ Gate 4 PASS 2026-05-07
  - 3 deep skills (pressure-test/shotgun/define) + 6 adapters + session.json cross-skill flow
  - ~/product-thinking/ repo, commit 389a110, 2532 lines
  - Archived: `.tad/archive/handoffs/HANDOFF-20260507-capability-pack-product-thinking.md`

- [x] **Agent Capability Pack — web-backend** — ✅ Gate 4 PASS 2026-05-07
  - 43 domain judgment rules + 46-item PRR (3 tiers) + 4 validation scripts
  - ~/web-backend/ repo, commit 5c4c6ab, 3165 lines
  - Archived: `.tad/archive/handoffs/HANDOFF-20260507-capability-pack-web-backend.md`

- [x] **Agent Capability Pack — ai-agent-architecture** — ✅ Gate 4 PASS 2026-05-07
  - 10 architectural decisions with selection matrices + 7 production disaster causal chains
  - ~/ai-agent-architecture/ repo, commits 4501f6a + 6a336c1, 2255 lines
  - Archived: `.tad/archive/handoffs/HANDOFF-20260507-capability-pack-ai-agent-architecture.md`

- [x] **Agent Capability Pack — ai-prompt-engineering** — ✅ Gate 4 PASS 2026-05-08
  - 4-phase production prompt lifecycle (Write/Test/Optimize/Ship) — 484-line CAPABILITY.md + 5 refs
  - ~/ai-prompt-engineering/ repo, 2 commits, 2940 lines
  - 11 P0 fixes: removed fabricated effort param + Mythos architecture, dspy-ai→dspy, real A-02 adversarial
  - KA: "Research Findings ≠ API Ground Truth" — research notebooks can misuse API terminology; always WebFetch official docs
  - Archived: .tad/archive/handoffs/HANDOFF-20260507-capability-pack-ai-prompt-engineering.md

- [x] **Agent Capability Pack — web-frontend** — ✅ Gate 4 PASS 2026-05-08
  - 41 React judgment rules across 7 dimensions + 3 validation scripts + 3-tier quality checklist
  - ~/web-frontend/ repo (independent dir), 2693 lines, 18 files
  - 7 P0 fixes: INP/TBT label, axe --reporter flag, bundle server scan, bc precision, context keyword, disambiguation rule, Gate → CI terminology
  - KA (Blake): Lighthouse TBT vs INP lab-mode measurement boundary (architecture.md 2026-05-08)
  - KA (Alex): CONSUMES/PRODUCES interface contract standard for capability pack ecosystem (architecture.md 2026-05-08)
  - Archived: .tad/archive/handoffs/HANDOFF-20260508-capability-pack-web-frontend.md

- [x] **Agent Capability Pack — research-methodology** — ✅ Gate 4 PASS 2026-05-08
  - 5-phase pipeline + state-tracking + saturation detection + anti-hallucination + QCE output
  - Now at .tad/capability-packs/research-methodology/ (migrated)
  - Archived: .tad/archive/handoffs/HANDOFF-20260508-capability-pack-research-methodology.md

- [x] **Capability Pack Integration & Migration** — ✅ Gate 4 PASS 2026-05-08
  - 7 packs migrated from ~/ to .tad/capability-packs/ + pack-registry.yaml + Alex step1_5b orchestration
  - scan-packs.sh auto-generates registry; .tad/capability-packs/ added to *sync PRESERVE
  - Archived: .tad/archive/handoffs/HANDOFF-20260508-pack-integration-and-migration.md

- [x] **Agent Capability Pack — video-creation** — ✅ Gate 4 PASS 2026-05-08
  - 25 video production judgment rules across 6 dimensions + HyperFrames-first tool selection + 3 video type pacing patterns
  - ~/video-creation/ repo, commit 200d216, 12 files, 2203 lines
  - 2 P0 fixes: sidechaincompress ms units, CRF range labeling
  - Research: NotebookLM notebook a62f253b (35 sources, 8 ask rounds) — HyperFrames, Remotion, motion design, video pacing
  - KA (Blake): FFmpeg sidechaincompress ms + Quick Rule Index exact heading match (architecture.md 2026-05-08)
  - Archived: .tad/archive/handoffs/HANDOFF-20260508-capability-pack-video-creation.md

- [ ] **Capability Upgrade SKILL created** — `/capability-upgrade` at `.claude/skills/capability-upgrade/SKILL.md`
  - 5-stage methodology: Assess → Research (GitHub-First) → Design → Build → Validate
  - Based on web-ui-design upgrade experience (踩坑 + 纠正全记录)
  - CLAUDE.md routing table updated

- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.) — source: OpenHarness §Permissions
- [ ] Promote prompt hook from "spike-verified" to documented recommended hook type — source: OpenHarness §Hooks

## Recently Completed

- [x] **Agent Capability Pack — web-ui-design Phase 1 (2026-05-07)** — Gate 4 PASS ✅
  - 18 files at ~/web-ui-design-capability/ | 3927 lines | 114 CSS tokens | 17 CLI tools | 144 checklist items
  - Commits: b4e3558 + f82a3d3 + d18636e | KA: YAML frontmatter + Phase N stub install pattern

- [x] **Research Pipeline — GitHub-First Source Strategy (2026-05-07)** — Gate 4 PASS ✅
  - Inverted research order: GitHub awesome-list first, deep research last (fallback only)
  - Added Phase 0 (Research Plan) + question format rules (❌ REJECT vague questions)
  - Commit: 0a6c16b

- [x] **Research Capability Polish — Auto-activation + Session Continuity (2026-05-05)** — Gate 3 PASS
  - CLAUDE.md: routing row for deep research + /deep-research exclusion note
  - research-notebook SKILL: "Standalone Usage" section + removed "Alex-domain only" restriction
  - alex SKILL: step6 "Research → Action Bridge" with 5 next-step options
  - Commits: 69b2450 + 6b86950 | KA: CLAUDE.md routing label must not share keyword with AC grep

- [x] **Research Pipeline Iterative Enrichment + Curate Acceleration (2026-05-05)** — Gate 4 PASS ✅
  - Added PHASE 4b CRAG Judge Loop: auto gap detection + targeted re-research per question (max 1 re-ask)
  - Replaced 4x sequential delete+sleep with xargs -P5 parallel batch delete (~17 deletes/sec vs sequential)
  - Live-tested on real NotebookLM notebook: 10/10 deletes OK, gap signal detected, 0 rate limit errors
  - Files: alex/SKILL.md + research-notebook/SKILL.md | Commits: 0bd1a93 + 63e4669

- [x] **Research Methodology Upgrade — 5-Phase Pipeline (2026-05-05)** — Gate 4 PASS
  - Upgraded *research-plan from report-only to: curate → report → Question Tree → ask loops → AC extraction
  - Added curate auto-clean (error sources) + auto-dedup (title+domain) + source quality tiering
  - Cross-notebook serial query with `-n` flag (no state leak)
  - Commit: `2d306a3` | KA: NotebookLM CLI state management pattern

- [x] **Global Skill Exclusion + Tool Quick Reference (2026-05-05)** — Gate 4 PASS
  - Fixed: global skills (/deep-research, /code-review etc.) shadowing TAD methods
  - Added: tool-quick-reference-alex.md + blake.md (CLI cheat sheets loaded at activation)
  - Archived: 5 conflicting project-level skills
  - Commit: `2b83513`

- [x] **EPIC: GitHub Knowledge Integration — Phase 1 COMPLETE (2026-05-04)** — Gate 3 PASS
  - REGISTRY.yaml: 24 domains, 50 awesome-lists | *research-github SKILL: 6 commands
  - Commit: `047266c` | Knowledge: 2 new architecture.md entries (gh api snake_case, git/trees recursive)
  - Gate 4 (AC7 live test): Alex runs explore → notebook → ask → verify code-level answer

- [x] **Cross-Model CLI Invocation Knowledge (2026-05-04)** — Gate 4 PASS
  - Alex/Blake now natively know how to invoke Codex CLI + Gemini CLI on user request
  - 3 files: guide (170L) + Alex SKILL section + Blake SKILL section
  - Commit: `584aa39` | *sync to distribute to all projects

- [x] **Spike: Cross-Model Orchestration Feasibility (2026-05-03)** — Gate 4 PASS, Verdict: GO (3/3)
  - Gemini CLI + Codex CLI both callable from Claude Code sub-agents
  - Commit: fcd0ea6 | Knowledge: 2 new architecture.md entries (Gemini -p flag, Codex exit-code rule)
  - IDEA-20260503-cross-model-orchestration updated — ready for architecture design when user chooses

- [x] **v2.9.0 released + synced to 12 projects (2026-05-02)** — Codex CLI Support + Cross-Platform TAD
  - Published: commit `c0ecc9c`, tag v2.9.0
  - Synced: commit `0d5a1a3`

- [x] **AGENTS.md — Codex native role switching (2026-05-02)** — Gate 4 PASS
  - Commit: `4d4fee5` — AGENTS.md (2956 bytes) + README.md Recommended Entry Point
  - Knowledge: "Codex AGENTS.md Auto-Load Mirrors Claude Code CLAUDE.md" → architecture.md

- [x] **EPIC: Codex CLI Adaptation — ALL 3/3 PHASES COMPLETE (2026-05-02)** — Epic archived
  - Phase 0: 5/6 spike | Phase 1: 13/13 AC | Phase 2: 8/8 AC, dogfood CONFIRMED
  - Archived: `.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md`

- [x] **Compact Recovery Protocol (2026-04-28)** — Gate 4 PASS
  - Two-layer session state persistence for compact recovery
  - Commit: `028974c`

- [x] **v2.8.4 bundle (2026-04-27)** — superseded by v2.9.0
  - Token efficiency + pre-publish cleanup + dangling refs migration + BUSINESS-VALUE-FIRST rule

- [x] **EPIC: TAD Self-Upgrade from Cross-Project Learning — ALL 6/6 PHASES (2026-04-27)** — Epic archived

- [x] Earlier completed items: see [docs/HISTORY.md](docs/HISTORY.md)

## Ideas

- [x] IDEA-20260504-goal-driven-research-director: Goal-Driven Research Director — (promoted to Epic)
- [ ] IDEA-20260503-cross-model-orchestration: Cross-Model Orchestration (sub-agent Codex/Gemini for review + research)
- [ ] IDEA-20260502-tad-universal-method: TAD Universal Method (extract methodology for non-devs)
- [ ] IDEA-20260427-domain-pack-taxonomy-reorg: Domain Pack Taxonomy Reorg
- [ ] IDEA-20260407-local-skill-capture: Local Skill Capture (future Epic 2)
- [ ] IDEA-20260407-cross-project-skill-harvest: Cross-Project Skill Harvest (future Epic 3)
- [ ] IDEA-20260403-config-env-override: Config Environment Override
- [ ] IDEA-20260403-hook-timeout-config: Hook Timeout Config
- [ ] IDEA-20260403-session-health-check: Session Health Check
- [ ] IDEA-20260402-deerflow-patterns: DeerFlow Patterns
- [ ] IDEA-20260402-domain-pack-monthly-refresh: Domain Pack Monthly Refresh
- [ ] IDEA-20260402-self-evolving-domain-pack: Self-Evolving Domain Pack
- [ ] IDEA-20260401-tad-self-test-agent: TAD Self-Test Agent
- [ ] Domain Pack Phase 1: web-deployment + content-creation still pending (5/7 done)

## Pending

- [ ] Test Agent Teams on next Full or Standard TAD task
- [ ] Verify auto-trigger behavior on next /alex or /blake activation
- [ ] Verify Criterion C/D detection on real stale handoffs

## Blocked

(none)

---

> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
