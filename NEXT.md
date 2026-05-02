# 下一步行动

## In Progress

- [x] **AGENTS.md — Codex native role switching (2026-05-02)** — Gate 3 PASS, awaiting Alex Gate 4
  - Commit: `4d4fee5` — AGENTS.md (2956 bytes) + README.md Recommended Entry Point section
  - AC5/AC6 live-tested: Codex identifies both roles + loads Blake SKILL content
  - Knowledge: "Codex AGENTS.md Auto-Load Mirrors Claude Code CLAUDE.md" → architecture.md

- [x] **EPIC: Codex CLI Adaptation — ✅ ALL 3/3 PHASES COMPLETE (2026-05-02)** — Gate 4 PASS, Epic archived
  - Archived: `.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md`
  - Phase 0: 5/6 spike | Phase 1: 13/13 AC | Phase 2: 8/8 AC, dogfood CONFIRMED
  - Commits: 659c689 (P1) + 9f2ee46 (P2) + bc7d650 (completion)
  - **v2.9.0 release ready** — run `*publish` when ready to ship

- [ ] **v2.8.4 release** — ✅ pre-publish follow-up Gate 4 PASS 2026-04-27 + ✅ token efficiency Gate 3 PASS 2026-04-27 (awaiting Alex Gate 4), now nearly ready
  - 14+2 处 version bump（per release-runbook Phase 2）
  - CHANGELOG entry — needs L1 tier rule + L2 lazy knowledge + L4 *express ≤5 (commit `c3ce273`) added on top of pre-publish cleanup
  - README/INSTALLATION_GUIDE/tad-help SKILL highlights 更新
  - **release-runbook smoke test 现在能在下游 11 个项目正常 PASS**（pre-publish cleanup 已修 dangling refs）
  - Token efficiency bundle landed on top: tier rule (yaml/research/doc-only handoffs → ≥1 reviewer), knowledge lazy load (~30-50K saved per handoff), *express widen 3→5 files

- [ ] **EPIC: Security Domain Pack Chain** — Phase 0+1 COMPLETE, evaluate before Phase 2 [SHE-23]
  - ✅ Phase 0: Security Tool Research (commit e2c325a)
  - ✅ Phase 1: supply-chain (639L) + code-security (873L) + 24 tools (commit 39e8017)
  - ⏸️ Phase 2-4: Paused — run real-project security audit first to validate Pack value
  - ⚠️ 与新 Epic 的 P4.2 `agent-runtime-security` 有潜在 overlap，启动 P4.2 前需评估
- [ ] Push TAD v2.8.0 to GitHub (user manual) [SHE-24]
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.) — source: OpenHarness §Permissions [SHE-25]
- [ ] Promote prompt hook from "spike-verified" to documented recommended hook type — source: OpenHarness §Hooks [SHE-26]

## Recently Completed

- [x] **Compact Recovery Protocol — Two-Layer Session State Persistence (2026-04-28)** — Gate 4 PASS
  - Archived: `.tad/archive/handoffs/HANDOFF-20260428-compact-recovery.md` + COMPLETION
  - Commit: `028974c` — 6 files: CLAUDE.md §4.5, blake/alex SKILL, post-write-sync.sh, session-state-template.md, .gitignore
  - Layer 2: code-reviewer (Round 1 FAIL → P0 fix → Round 2 PASS) + backend-architect (PASS); DISTINCT_COUNT=2
  - Knowledge: "Two-Layer Compact Recovery Pattern — 2026-04-28" added to architecture.md

- [x] **TAD Token Efficiency — L1 Tiered Layer 2 + L2 Lazy Knowledge + L4 *express ≤5 + L6 Narrow-Scope Expert Prompts (2026-04-27)** — Gate 4 PASS
  - Archived: `.tad/archive/handoffs/HANDOFF-20260427-tad-token-efficiency.md` + COMPLETION
  - **All 19 ACs PASS** (16 v2 + 3 v3 L6) — Blake implemented FULL v2+v3 scope (L1+L2+L4+L6) but committed in 2 stages: c3ce273 (v2 L1+L2+L4) + working-tree v3 L6 → bundled into Alex Gate 4 acceptance commit
  - Edits: Alex SKILL line 949+996+1655+2167+2295 (5 edits) + Blake SKILL line 906+918 (2 edits) = 7 edits across 2 files
  - Layer 2: 4 review files saved (Alex pre-handoff + Blake post-impl × code-reviewer + backend-architect; Blake added `-v3.md` for v3 L6 follow-on review)；layer2-audit.sh DISTINCT_COUNT=2 exit 0
  - Constraint preservation NFR2: alex=64 (= baseline) + blake=34 (≥ 32 baseline, +2 from L6 forbidden_implementations); AR-001 anchor count=2 (= baseline)
  - Estimated token savings: L4 ~250-280K per newly-fitting *express handoff; L2 ~30-50K per future handoff; L1 ~60K per yaml/research/doc-only handoff; **L6 ~50% per sub-agent review × 4 reviews = ~240K per Standard architecture handoff**
  - 3 gate4_delta entries captured (v3 L6 commit-timing drift / AC16 5th consecutive INTENT-PASS-LITERAL-FAIL / 11-space vs 10-space indent spec drift)
  - layer2-audit.sh untouched (Anti-Epic-1 preserved); no settings.json / hook script changes
  - Commits: `c3ce273` (Blake v2 L1+L2+L4) + Alex Gate 4 batch commit (Blake's uncommitted v3 L6 + Alex Gate 4 metadata + archive moves)

- [x] **Pre-publish Cleanup — Dangling Refs Migration + 人话版 BUSINESS-VALUE-FIRST Rule (2026-04-27)** — Gate 4 PASS
  - Archived: `.tad/archive/handoffs/HANDOFF-20260427-pre-publish-cleanup.md` + COMPLETION
  - Gate 4 v2 verification: all 13 ACs PASS（AC8/9/10 documented as INTENT-PASS-LITERAL-FAIL — 4th 连续 Phase 出现 spec-vs-actual drift, gate4_delta 3 entries 录入推动 Phase-7+ Epic）；Layer 2 audit DISTINCT_COUNT=2 exit 0；trace-digest N/A (per-handoff dir missing — advisory only)
  - 5 files modified: 3 dangling consumers (run-phase2b-tests / AC-P1.4 / release-runbook) migrated to `.router.log` reading + Alex/Blake SKILL human-readable explanation prose got new BUSINESS-VALUE-FIRST hard rule
  - Regression: run-phase2b-tests 5/30 → 30/30 PASS; AC-P1.4 0/7 → 6/7 PASS (1 perf bench dev-host variance, not regression)
  - Layer 2: code-reviewer PASS (0 P0/P1, 4 P2); backend-architect PASS-WITH-P1 (0 P0; 4 P1 forward-looking — CONTRACT block recommendation, AC-dry-run Epic, allowlist extension)
  - AC8/9/10 INTENT-PASS-LITERAL-FAIL — 4th consecutive Phase, recurring meta-pattern. KA entry "AC Verification Drift Pattern Recurring 4 Phases in a Row — Process-Level Defect" added recommending Phase-7+ Epic
  - Bonus: caught hook `whitelist_early_exit` log emission writing 4-field log lines (vs normal 5-tuple), now classified
  - Commit (Blake): `95b154b feat(TAD): pre-publish cleanup — dangling refs migration + 人话版 BUSINESS-VALUE-FIRST rule`
  - **v2.8.4 release now unblocked** — release-runbook smoke test will work for downstream projects

- [x] **EPIC: TAD Self-Upgrade from Cross-Project Learning — ✅ ALL 6/6 PHASES COMPLETE (2026-04-27)**
  - Archived: `.tad/archive/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md`
  - Phase 1-5: see commits 08e9e74 / 0b2e25d / ff96bd5 / d2a73a1 + 93fcb50 / d578707
  - Phase 6: P6-A PARTIAL (process quality foundation) + cleanup (Linear cut + *accept slim + hook passive) replaced 5 deferred sub-handoffs (P6-B/C/E/F + P6-A v2 follow-up all killed by user 2026-04-27 over-engineering reflection)
  - 18,433 net insertions / 86 deletions over 10 commits

- [x] **TAD Bloat Cleanup — Linear cut + *accept slim + Hook passive mode (2026-04-27)** — Gate 4 PASS
  - Archived: `.tad/archive/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md` + COMPLETION
  - 7 files modified (-129 net lines): Linear integration完全砍除 + step0b重复检查删除 + Hook从active注入改为passive logging only + deprecation 2.8.4
  - Layer 2: code-reviewer PASS 0 P0; backend-architect CONDITIONAL PASS — flagged 3 OUT-OF-SCOPE P0 cross-references (see Pre-publish follow-up above)
  - Commit (Blake): `2209648 feat(TAD): bloat cleanup — Linear cut + *accept slim + hook passive mode`
  - Gate 4 v2 verification: 17 ACs all PASS (raw-TSV recompute matches Blake report); Layer 2 audit DISTINCT_COUNT=2 exit 0
  - 3 architecture.md KA entries (2 from Blake + 1 from Alex on scope-estimation drift pattern)
  - 2 gate4_delta entries captured (scope estimation 4→7→10 drift; AC4 blast radius coverage gap)

- [x] **Express: Layer 2 Audit — Alex *accept 红字警告 (2026-04-15)**
  - Handoff: `.tad/archive/handoffs/HANDOFF-20260415-layer2-audit.md`
  - 监督层替代 Epic 1 机械强制——Alex *accept step4c 跑 `layer2-audit.sh <slug>` 检查 Blake reviewer artifacts 存在性
  - 产出：88 行 shell 工具 + Alex SKILL step4c + Blake SKILL Slug Contract + 11 fixture (5 FAIL + 4 slug-negative + 2 dogfood)
  - Gate 3 PASS (Blake 自检 + code-reviewer 0 P0 5 P1) / Gate 4 PASS (Alex 独立 raw-data 复现 8/8 AC + meta-dogfood)
  - 零 `.claude/settings.json` 改动——无 dogfood paradox 风险
  - 元趣味：该工具第一次运行时审计了自己 (slug=`layer2-audit` → exit 0，找到自己的 code-reviewer.md)
  - Commit (Blake): `ff1e32a feat(TAD): implement layer2-audit [Gate 3 PASS]`

- [x] **🚫 EPIC: Symmetric Quality Enforcement — Cancelled (product decision 2026-04-15)**
  - Archived Epic: `.tad/archive/epics/EPIC-20260413-symmetric-quality-enforcement.md`
  - ✅ Phase 1a/1b/1c/2 技术验证全部 PASS；v3-LEAN 设计 Gate 2 PASS
  - 🚫 Phase 3 实装首次激活 → `dep-guard.sh` Apple Silicon PATH bug → Claude 全工具锁死 → 用户判断"恢复成本 > 防滥用收益"
  - **保留**：Phase 3.A SKILL 硬化 commit `4e4d581`（`anti_rationalization_registry` + `honest_partial_protocol`，纯文字软提醒）
  - **归档**：Phase 3 handoff / 3 份 expert review / v2 extract / gate2-verdict → `.tad/archive/spikes/phase3-attempt-20260415/`
  - **撤销**：settings.json 已 git checkout；Phase 4-5 N/A
  - Knowledge entry: architecture.md "Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15"
  - 教训：LLM 对齐 ≠ 必须拦截工具；deployment threat model 决定手段；"最严格"不等于"最好"

- [x] **Express: Plain-Language Explanation as TAD Capability** (2026-04-14)
  - User feedback: agents should write 人话版 section after every handoff/completion message so user learns instead of just relaying
  - Folded into Alex `step7.generate_message` + Blake `step8_generate_message` (NO new step8/step9 — preserves STOP semantic)
  - Includes: ORDER REQUIREMENT (人话版 FIRST), length scaling, anti-theater rule, negative/positive examples, purpose anchor, violation_plain_language clause
  - Commit 514849f. Archived: `.tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md` + COMPLETION
  - Self-caught anti-pattern logged: architecture.md "Express Handoff is NOT Review-Exemption - 2026-04-14"

- [x] **EPIC: Domain Pack 可靠加载机制** — ✅ ALL 4/4 PHASES COMPLETE (2026-04-08)
  - Archived: `.tad/archive/epics/EPIC-20260407-domain-pack-reliable-loading.md`
  - Phase 1: Spike — UserPromptSubmit hook verified (4th validated hook event)
  - Phase 2a: Contract spike — Architecture A dead, pivoted to C
  - Phase 2b: Production hook — **30/30 accuracy, 81ms latency, 7-9x perf improvement via single-awk pattern**
  - Phase 3: absorbed by 2b's 30-case × 5-family integration test
  - Phase 4: skipped (no tuning needed — 100% accuracy)
  - **Production hook LIVE**: `.tad/hooks/userprompt-domain-router.sh` + 20 curated packs in `keywords.yaml`
  - 4 new architecture.md entries (hook perf, claude -p testing, keyword uniqueness, epic pivot pattern)

- [x] **Phase 2a Contract Micro-Spike (Epic 1 Phase 2a)** — ✅ Gate 4 PASS, NO-GO verdict (2026-04-07)
  - Decisive finding: `type:prompt` on UserPromptSubmit is permission gate only, NOT context injection
  - Architecture A pivoted to Architecture C (keyword matching) — user explicit decision
  - Bonus: stdin payload schema documented (6 fields, user msg in `prompt` field)
  - architecture.md updated with sub-finding (existing entry extended, not duplicated)
  - Spike: `.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/`

- [x] **Domain Pack Hook Spike (Epic 1 Phase 1)** — ✅ Gate 4 PASS PARTIAL (2026-04-07)
  - UserPromptSubmit hook verified in Claude Code 2.1.92 (4th validated event)
  - Haiku-4.5 accuracy 93.75% high-conf / 94.44% all (18 cases)
  - Latency 4567ms proxy artifact — Phase 2 must remeasure with direct API
  - Architecture.md gained 2 entries: UserPromptSubmit verification + Spike-driven Epic de-risking pattern
  - Spike: `.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/`

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

- [ ] IDEA-20260407-local-skill-capture: 本地 Skill 捕获机制（未来 Epic 2，依赖 Epic 1 完成）
- [ ] IDEA-20260407-cross-project-skill-harvest: 跨项目 Skill Harvest 与晋升（未来 Epic 3，依赖 Epic 2 + 1-2 个月数据积累）
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
