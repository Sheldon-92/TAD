# 下一步行动

## In Progress

- [ ] **EPIC: Security Domain Pack Chain** — Phase 0 COMPLETE, Phase 1 next
  - ✅ Phase 0: Security Tool Research — 40 tools, 5 domains, 25 capabilities (commit e2c325a)
  - 🔲 Phase 1: supply-chain + code-security packs (needs Alex handoff)
  - 🔲 Phase 2: ai-security + compliance packs
  - 🔲 Phase 3: security-monitoring + TAD integration
  - 🔲 Phase 4: E2E validation
- [ ] Push TAD v2.8.0 to GitHub (user manual)
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.) — source: OpenHarness §Permissions
- [ ] Promote prompt hook from "spike-verified" to documented recommended hook type — source: OpenHarness §Hooks

## Recently Completed

- [x] **EPIC: OpenHarness Agent Architecture Upgrade** — ALL 3/3 PHASES COMPLETE (2026-04-03)
  - Phase 1: Reference doc 887 lines (commit 75d75f6)
  - Phase 2: ai-agent-architecture.yaml v1.1.0 (+4 steps, +8 criteria, commit f1af57e)
  - Phase 3: 2 NEXT.md items + 3 ideas identified

- [x] **EPIC: Quality Chain Full Repair** — ALL 4/4 PHASES COMPLETE (2026-04-03)
  - Phase 1: Template metadata + Gate 3 v2 structure (commit 679d1fa)
  - Phase 2: Blake EXECUTION CHECKLIST + frontmatter compliance (commit db54386)
  - Phase 3: Alex prompt layer hardening (commit faebb49)
  - Phase 4: Hook validation layer upgrade (pre-gate evidence checks + domain pack detection)
  - Three-layer defense: Prompt (Phase 2-3) → Template (Phase 1) → Hook (Phase 4)

- [x] **HW Domain Pack Phase 1 Research Supplement** — Gate 4 PASS, archived (2026-04-03)
  - 4 research files (21 repos × 5 dimensions), 4 YAML iterations (+156 lines)
  - 4 new steps + 2 new tools (platformio_check, admesh), commit 48a69c6

- [x] **TAD v2.8.0 Self-Evolving Framework Release** (2026-04-03)
  - Phase 1: Trace infrastructure (PostToolUse JSONL + trace-step.sh)
  - Phase 1.5: Trace schema enrichment (step-level recording)
  - Phase 2: *optimize command (trace analysis → improvement proposals)
  - Phase 3: Quality Gate Hooks (pre-accept, pre-gate enforcement)
  - Phase 4: Human Approval Workflow (PROPOSAL YAML + safety constraints)
  - Phase 5: Version bump + release
  - Domain Packs: 14 packs complete (Web 6 + Mobile 4 + AI 4), 51 tools in registry
  - self_improvement_design: 6-step process + 6-environment reference table

- [x] **EPIC: TAD v2.7.0 Hook-Native Architecture Rebuild** — ALL 6/6 PHASES COMPLETE (2026-03-31)
  - Phase 0: Mechanism Spike (5/7 pass) → Phase 1: Blueprint → Phase 2: Hooks → Phase 3: Skills 76% reduction → Phase 4: CLAUDE.md + PreToolUse → Phase 5: v2.7.0 release
  - Archived: .tad/archive/epics/EPIC-20260331-tad-v3-hook-native-rebuild.md

- [x] Linear: 4 projects created + 15 issues seeded via MCP (2026-03-25)

- [x] Linear Auto-Sync — Gate 4 PASS, archived (2026-03-25)
  - step3.7 startup sync + enhanced step4b + auto_sync config, commit 7583fe5

- [x] Autoresearch Optimization Mode — Gate 4 PASS, archived (2026-03-25)
  - Ralph Loop Layer 0.5: autonomous optimization loop for numeric targets
  - 5 files modified/created, commit 585ef88

- [x] 4D Protocol Pair Testing Upgrade — Gate 4 PASS, archived (2026-03-25)
  - Removed Mode A (Chrome MCP), added 4D Protocol as core methodology
  - Updated 7 files, commit b20ceef
  - P1 follow-up: Update stale "Claude Desktop" refs in docs/ files outside scope

- [x] Publish v2.5.0 — pushed + tagged (2026-03-23)
- [x] Project cleanup — legacy scripts/docs archived, backup files consolidated, version refs fixed (2026-03-23)

## Recently Completed

- [x] EPIC: Superpowers-Inspired Tactical Upgrades — ALL 6/6 phases (2026-03-23)
  - Spec Compliance Reviewer, Anti-Rationalization Tables, TDD Skill, Micro-Tasks, Pressure Testing, Git Worktree

- [x] Context Refresh Protocol: 2 critical nodes + template enhancement (2026-02-19) - Gate 3 PASS + Gate 4 PASS
  - tad-alex.md: step0_5 in handoff_creation_protocol (reads ALL project-knowledge)
  - tad-blake.md: 1_5_context_refresh in develop_command (reads handoff + knowledge)
  - handoff-a-to-b.md: MANDATORY READ block in Project Knowledge section
  - Expert review: code-reviewer + backend-architect, trimmed from 9 to 2+1 nodes

- [x] TAD Publish & Sync: *publish + *sync Alex commands, v2.3.0 → v2.4.0 (2026-02-17) - Gate 3 PASS + Gate 4 PASS
  - Created sync-registry.yaml (3 projects), deprecation.yaml (v2.3.0 entry)
  - 4 protocols in tad-alex.md, version bumped, CLAUDE.md routing updated
  - Expert review: code-reviewer + backend-architect, 6 P0 fixed

- [x] Multi-Platform Cleanup: Remove Codex/Gemini full runtime, v2.2.1 → v2.3.0 (2026-02-17)

- [x] Design Playground v2 — Independent `/playground` Command (2026-02-08) - Gate 3 PASS + Gate 4 PASS
  - Created: `.claude/commands/playground.md` (standalone Design Explorer agent, 475 lines)
  - Created: `.tad/references/design-styles.yaml` (32 styles, 7 categories)
  - Created: `.tad/templates/gallery-template.html` (Active/History/Compare views, ARIA accessible)
  - Updated: `tad-alex.md` (removed ~170 lines old protocol, added slim reference)
  - Updated: `config.yaml` + `config-workflow.yaml` (playground v2.0 section)
  - Archived: 3 legacy files → `.tad/archive/playground/legacy-v1/`
  - Ralph Loop: Layer 1 self-check PASS, Layer 2 code-reviewer (3 P0 fixed) + ux-expert + style-validation PASS
  - Acceptance: 17/17 AC verified

- [x] Agent Team Default for Full + Standard TAD (2026-02-07) - Gate 3 PASS + Gate 4 PASS
  - config-agents.yaml: standard_tad → agent_team, min_tasks_for_team 3→2
  - tad-alex.md: step3_agent_team widened to full+standard
  - tad-blake.md: agent_team_develop widened to full+standard, task_count thresholds 3→2
  - code-review: 1 P0 found and fixed (inline threshold mismatch), 7/7 AC passed

- [x] Cognitive Firewall - Human Empowerment System (2026-02-06)
  - config-cognitive.yaml: 3 pillars (decision transparency, research-first, fatal operations)
  - tad-alex.md: research_decision_protocol (4-step identify→research→present→record)
  - tad-blake.md: implementation_decision_escalation (PAUSE behavior, P0-1 fixed)
  - tad-gate.md: Risk_Translation (Gate 3) + Decision_Compliance (Gate 4)
  - config.yaml: config-cognitive module registered, 3 command bindings updated
  - Gate 3 PASS: 28/28 AC, code-review P0=0, all P0 fixes verified

- [x] Knowledge Auto-loading + Agent Teams Integration (2026-02-06) - Gate 4 PASS
  - CLAUDE.md Section 7: 9 @import statements for project-knowledge categories
  - tad-alex.md: step3_agent_team (Agent Team review mode, experimental)
  - tad-blake.md: agent_team_develop (Agent Team implementation mode, experimental)
  - config-agents.yaml: agent_teams section with terminal isolation + fallback
  - Gate 3 PASS: 8/8 AC, code-review P0=0 | Gate 4 PASS: business acceptance verified

- [x] tad-maintain P0: Criterion D references config common_words_exclude (2026-02-01)
- [x] tad-maintain P0: SYNC mode target_slug parameter for scoped processing (2026-02-01)

- [x] CLAUDE.md Router Architecture (先补后砍) (2026-02-01)
  - Phase 1: 13 rules backfilled to agent files (tad-alex, tad-gate, tad-blake)
  - Phase 2: CLAUDE.md 657→109 lines (router pattern, enforcement markers preserved)
  - Phase 3: Alex config 5→4 modules (dropped config-execution, kept config-platform)
  - 3 expert reviews (code-reviewer, backend-architect, security-auditor), 9 P0 all resolved
  - 24/24 verification criteria passed, Gate 3 + Gate 4 passed
  - Backup: .tad/backups/CLAUDE.md.pre-slim-backup

- [x] Epic/Roadmap multi-phase task tracking (2026-02-01)

- [x] Pair Testing Redesign - human-initiated, Alex-owned (2026-02-01)

- [x] Multi-Session Pair Testing upgrade (2026-02-09) - Gate 3 PASS + Gate 4 PASS
  - 6 files modified: test-brief-template, pair-test-report-template, tad-alex, config-workflow, tad-test-brief, tad-help
  - Singleton → session directories (S01/, S02/) + SESSIONS.yaml manifest
  - Context inheritance, atomic mv archive, corruption recovery, active session guard
  - 18/18 AC verified, 4 P1 fixed during code review

## In Progress

- [x] Git Commit Verification: two-layer protection (Blake step3c + Alex step0_git_check) — Gate 3 PASS (2026-03-03)
  - 4 files: tad-blake.md, tad-alex.md, tad-gate.md, config-quality.yaml
  - Code-reviewer: 1 P0 found (missing Gate 3 output section) + fixed, then PASS
  - Commit: 80c52fb
- [ ] P1-4 deferred: Consider renaming config-platform.yaml → config-mcp.yaml (future cleanup) [SHE-11]

## Recently Completed Epic

- [x] **EPIC: Alex Flexibility + Learning + Project Management** — ALL 5/5 PHASES COMPLETE (2026-02-16)
  - Phase 1: Intent Router ✅ | Phase 2: *learn ✅ | Phase 3: Idea Pool ✅ | Phase 4: Roadmap ✅ | Phase 5: Layer Integration ✅
  - Archived: .tad/archive/epics/EPIC-20260216-alex-flexibility-and-project-mgmt.md
- [x] Test Epic flow end-to-end on next multi-phase task — ✅ THIS EPIC was the test, 5 phases completed successfully

## Ideas

- [x] IDEA-20260401-domain-pack-framework: Domain Pack Framework — Extensible Domain Support (promoted)
- [x] Domain Pack: Tool Research Spike — ✅ 10 tools in 3 tiers, 5 tested
- [x] **EPIC: Domain Pack Framework** — ALL 3/3 PHASES COMPLETE (2026-04-01)
  - Archived: .tad/archive/epics/EPIC-20260401-domain-pack-framework.md

- [ ] **Domain Pack Phase 1: 软件开发全链路** (5/7 完成)
  - ✅ product-definition (含深度迭代)
  - ✅ web-ui-design (压力测试 7/7)
  - ✅ web-frontend (744 行, 压力测试 7/7)
  - ✅ web-backend (756 行, 压力测试 7/7)
  - ✅ web-frontend (Gate 3 PASS, commit fe2b027, 压力测试 7/7)
  - ✅ web-testing (Gate 3 PASS, commit d562e08, 7 caps, 4D Protocol)
  - 🔲 web-deployment
  - 🔲 content-creation
- [x] IDEA-20260325-linear-kanban-for-human: Linear Kanban for Human Time/Energy Management (promoted)
- [x] IDEA-20260325-linear-auto-sync: Linear Auto-Sync — TAD as Single Source of Truth (promoted)

## Pending

- [x] tad-maintain P1: CLAUDE.md §1 add exemption for maintain-mode handoff reads (2026-02-06)
- [x] tad-maintain P1: NEXT.md classification table add `## Recently Completed` header (2026-02-06)
- [x] tad-maintain P1: Add 2 explicit prohibition statements (file-mtime, Criterion C/D auto-archive) (2026-02-06)
- [x] tad-maintain P2: config.yaml clean up legacy `tad_version: 1.3.0` field (2026-02-06)
- [ ] Test Agent Teams on next Full or Standard TAD task (verify auto-trigger + fallback) [SHE-12]
- [ ] Verify auto-trigger behavior on next /alex or /blake activation [SHE-20]
- [ ] Verify Criterion C/D detection on real stale handoffs [SHE-21]

## Blocked

(none)

---

> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
