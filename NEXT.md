# 下一步行动

## In Progress

- [ ] **EPIC: Security Domain Pack Chain** — Phase 0+1 COMPLETE, evaluate before Phase 2
  - ✅ Phase 0: Security Tool Research (commit e2c325a)
  - ✅ Phase 1: supply-chain (639L) + code-security (873L) + 24 tools (commit 39e8017)
  - ⏸️ Phase 2-4: Paused — run real-project security audit first to validate Pack value
- [ ] Push TAD v2.8.0 to GitHub (user manual)
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.) — source: OpenHarness §Permissions
- [ ] Promote prompt hook from "spike-verified" to documented recommended hook type — source: OpenHarness §Hooks

## Recently Completed

- [x] **Commands/Skills Consolidation v2.8.1** (2026-04-04)
  - Merged 18 commands into skills (alex 3080L, blake 1149L, gate 660L)
  - Fixed all .claude/commands/ path references across 10+ files
  - Added domain_pack_awareness to *discuss mode
  - deprecation.yaml updated for downstream sync cleanup
  - Commits: 1392ce5, cf8b5fd

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
- [x] EPIC: Superpowers-Inspired Tactical Upgrades — ALL 6/6 phases (2026-03-23)
- [x] EPIC: Alex Flexibility + Learning + Project Management — ALL 5/5 PHASES COMPLETE (2026-02-16)
- [x] Earlier completed items: see [docs/HISTORY.md](docs/HISTORY.md)

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

- [ ] Test Agent Teams on next Full or Standard TAD task (verify auto-trigger + fallback) [SHE-12]
- [ ] Verify auto-trigger behavior on next /alex or /blake activation [SHE-20]
- [ ] Verify Criterion C/D detection on real stale handoffs [SHE-21]

## Blocked

(none)

---

> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
