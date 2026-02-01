# Project History

> This file contains archived completed tasks from NEXT.md
> Organized by period for easy reference

---

## Week of 2026-01-27 (v2.1.1 → v2.2.1)

### Completed Tasks

- [x] TAD v2.2.1 - Pair Testing Protocol (2026-01-31)
  - Pair E2E testing integrated into Gate 3→4 flow
  - test-brief-template.md (8-section generic template, Web defaults)
  - /tad-test-brief standalone command
  - Blake step4b: conditional TEST_BRIEF generation after Gate 3
  - Alex STEP 3.6: auto-detect PAIR_TEST_REPORT on startup
  - Alex *test-review: classify issues → generate fix Handoff
  - Alex step_test_brief: supplement Section 5 after Gate 4
  - tad-maintain: PAIR TESTING check items in both output modes
  - File lifecycle: naming, organization, archival to .tad/evidence/pair-tests/

- [x] TAD v2.2.0 improvements (2026-01-31)
  - Bidirectional message protocol (Alex→Blake letter, Blake→Alex letter, Blake auto-detect)
  - Adaptive complexity assessment (Alex assesses S/M/L, suggests depth, human decides)
  - Config.yaml modular split (6 modules, master index, per-command binding)

- [x] TAD v2.1.2 - Remove /tad-learn (2026-01-31)
  - Deprecated framework-level learning recorder
  - TAD improvements now made directly in mother repo

- [x] TAD v2.1.1 - Document Lifecycle Management (2026-01-31)
  - /tad-maintain command (3 modes: check/sync/full)
  - Criterion C/D stale detection (age + topic cross-reference)
  - handoff_lifecycle config section
  - Simplified adapter architecture (removed .tad/adapters/)

- [x] Run `/tad-maintain` full mode to clean up stale active handoffs
- [x] Archive multi-platform-init handoff (superseded by agent-agnostic-architecture)

---

## Week of 2026-01-20 (v1.6 Sync)

### Completed Tasks

- [x] TAD v1.6 - Evidence-Based Development (menu-snap sync) (2026-01-20)
  - **CLAUDE.md 增强** (113 → 315 行): Alex 验收规则, Output Template 规则, Project Knowledge 规则, 版本发布规则
  - **tad-alex.md 增强** (7055 → 15987 bytes): *accept 命令, *exit 协议, 版本发布职责, subagent 强制调用
  - **tad-blake.md 增强** (8057 → 10453 bytes): *exit 协议, 版本发布职责, NEXT.md 维护, knowledge_capture
  - **tad-gate.md 增强** (4400 → 13743 bytes): Gate 3/4 前置条件, subagent 强制, 证据文件存储
  - **config.yaml 同步** (1600 → 1910 行): next_md_maintenance, release_management, template_triggers
  - 目录结构同步: evidence/reviews/, evidence/completions/, active/designs/, project-knowledge/, reports/
  - 模板同步: 12 个 output-formats + 4 个文档模板
  - Skills 精简: 42 个归档至 _archived/，仅保留 code-review/ + doc-organization.md

- [x] 全面审核补充同步 (第二轮)
  - 补充 research.md, release-execution.md, elicitation-methods.md
  - 同步 tad-init.md, handoff-a-to-b.md, gate-execution-guide.md, quality-gate-checklist.md
  - 更新 .tad/README.md, settings.json

- [x] 记录批判性意见供未来验证 (.tad/learnings/pending/)

---

## Week of 2026-01-06 (v1.4 → v1.5)

### Completed Tasks

- [x] TAD v1.5 - 框架与用户数据分离架构重构 (2026-01-07)
  - 创建 tad-work/ 目录存放用户数据, .tad/ 只保留框架文件
  - 创建 migrate-to-v1.5.sh 自动迁移脚本
  - 提交 v1.5 到 GitHub (commits: 84e8bc1, 148f815)

- [x] 修复 6 个学习记录问题 (来自 menu-snap 项目) (2026-01-07)
- [x] 修复 /tad-alex 配置文件超限问题 (拆分 config.yaml)
- [x] 实现 /tad-learn 真正的跨项目学习积累 (GitHub API 推送)
- [x] Skills 混合策略研究与实施 (v1.4.1)
- [x] Skills 质量升级 (87/100→95+, 基于 Codex 评估报告)
- [x] 文档一致性项目 Phase 1/2/3
- [x] Agent 文件整理 (合并 v1.1 → base)
- [x] TAD v1.4 - Skills 自动匹配机制 (20+ 意图映射, 文件模式映射)
- [x] 修复 .gitignore 版本控制问题, 升级脚本 404 错误

- [x] TAD v1.4 发布 (2026-01-06)
  - MQ6 强制技术搜索, Research Phase, Skills 知识库系统
  - Learn 记忆系统, 内置 Skills (ui-design, skill-creator)
  - 安装/升级脚本

- [x] 开源 Skills 补充 - 5 批共 42 个 Skills
  - 第一批 (obra/superpowers): TDD, debugging, code-review, brainstorming, verification
  - 第二批 (综合): parallel-agents, git-worktrees, architecture, api-design, security, performance, etc.
  - 第三批 (anthropics): pdf, pptx, xlsx, canvas, algorithmic-art, theme-factory, etc.
  - 第四批 (广泛搜索): data-science, product-management, legal, marketing, i18n, media, etc.
  - 第五批 (用户指定): prompt-engineering, ux-research, competitive-analysis, ai-integration

### v1.4 File Change Summary

| Module | File | Description |
|--------|------|-------------|
| MQ6 | `.tad/config.yaml` | MQ6_technical_research config |
| Research | `.tad/config.yaml` | research_phase config |
| Skills | `.tad/config.yaml` | skills_system config |
| Learn | `.tad/config.yaml` | learn_system config |
| Auto-Match | `.tad/config.yaml` | skill_auto_match config (165 lines) |
| Agent A | `.tad/agents/agent-a-architect.md` | STEP 3.5 + auto_match |
| Agent B | `.tad/agents/agent-b-executor.md` | STEP 3.5 + auto_match |
| /tad-learn | `.claude/commands/tad-learn.md` | New command |
| 42 Skills | `.claude/skills/*.md` | All skill files |
| install.sh | `install.sh` | Updated to v1.4 |
| upgrade | `upgrade-to-v1.4.sh` | New upgrade script |

---

<!--
ARCHIVE GUIDELINES:
1. Move completed tasks from NEXT.md when they are >7 days old
2. Group by week
3. Include key decisions and lessons learned
4. Keep this file organized chronologically (newest first)
5. Link to detailed docs when needed (e.g., "See docs/feature-x.md")
-->
