# 下一步行动

## In Progress

- [x] **EPIC: TAD Universal Method** — 已迁移到独立开发项目 `~/tad-method-dev/` (2026-05-02)
  - Phase 0 ✅ + Phase 1 ✅ 在此完成；Phase 2+ 在 ~/tad-method-dev/ 继续
  - 产品代码: ~/tad-method/ | 开发管理: ~/tad-method-dev/

- [x] **EPIC: NotebookLM Research Director — ALL 4/4 PHASES COMPLETE (2026-05-04)** — Epic archived
  - Phase 0: spike 24-row | Phase 1: SKILL 14 cmd | Phase 2: Director+19 cmd | Phase 3: E2E 6/6 PASS
  - Archived: `.tad/archive/epics/EPIC-20260504-notebooklm-research-director.md`

- [ ] **EPIC: Goal-Driven Research Director** — 业务目标驱动自主研究 (NEW)
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

- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.) — source: OpenHarness §Permissions
- [ ] Promote prompt hook from "spike-verified" to documented recommended hook type — source: OpenHarness §Hooks

## Recently Completed

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
