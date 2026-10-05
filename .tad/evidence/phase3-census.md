# Phase 3 普查表 — 📐 TAD（批 1 · 程序步 (a)）

- 制表：Alex（Solution Lead），step_id=`tad-phase3-census-01`，2026-10-04
- 表式：gm 仓 `.tad/evidence/designs/2026-10-04-gm-phase3-design.md` §4.1（44 行四列）
- 判定口径（§4.1＋原件三问）：落实须三段全过——①原件形态在产（近 30 天有按原件形态产出的真件）②约束环节在跑且有实证③落点合规、原件可读；差一段即未落实，差处写入「差在哪」。日期证据以文件名日期与 git log 为准（本仓 mtime 受同步收敛污染，不作产出日期证据）。

## (b) 登记确认事实（PM 已核，原文写入）

scope-privileges.json `projects.TAD.enabled_at`＝2026-10-04（GM 已登记）；seat-onboarding 键名＝「📐 TAD」；本席 stage＝quiz-pending、graduated＝false；本仓无 `docs/pm/wake-sentences.md`，常驻入口首读文件＝`docs/pm/intent.md`（席位启动序 wake-sentences → intent → now，本仓以 intent 为首读）。

## 普查表（D01–D44）

| 件 | 状态 | 盘上证据（路径与实查） | 约束实证 | 差在哪 |
|---|---|---|---|---|
| D01 项目目标 OBJECTIVES | 落实 | `OBJECTIVES.md`（仓根，5,029 B；O1–O3＋KR 表含量化目标列；git 内容提交 2026-07-12） | 仓根常驻目标件，KR 状态列在盘可查 | ——（内容版本停 2026-07-12，KR 无逐期回写实证） |
| D02 项目上下文 PROJECT_CONTEXT | 落实 | `PROJECT_CONTEXT.md`（19,161 B；占位串 `[Your Project Name]` grep 计数 0；git 2026-10-04 有内容更新） | 本次开工实读，内容为本仓真态非模板 | —— |
| D03 队列文件 NEXT | 落实 | `NEXT.md`（50,742 B；TASK 引用 16 处、HANDOFF 引用 35 处）；`.tad/archive/next/NEXT-completed-through-20261004.md`（已完成项迁移件，2026-10-04） | 完成项迁 archive/next 的规则在文件头成文且当日有迁移实绩 | —— |
| D04 需求复述确认 Restate | 未落实 | `docs/pm/restates/restate-2026-09-22-epic-phase-vs-human-habit.md`；`.tad/evidence/pm/2026-09-22-alex-epic-phase-oc-restate-refused.md` | 复述确认件在产（2026-09-22） | 无成功标准／限制条件结构化字段强制，靠复述质量 |
| D05 机会探索 IDEA | 未落实 | `.tad/active/ideas/` 25 件（最新 IDEA-20260703-*）；`.tad/archive/ideas/` 最新 2026-07-12 | 无 | 停产于 2026-07，近 30 天无新 IDEA 件 |
| D06 研究立项授权 Charter | 未落实 | `.tad/templates/research-charter.md`；真件仅 1：`.tad/evidence/research/2026-09-15-gemini-notebook-fallback/RESEARCH-CHARTER.md` | 无 | 立项授权未成研究开工固定动作，同期其他研究线（如 2026-10-02 hygiene 线）无 charter 件 |
| D07 Epic 文档 EPIC | 未落实 | `.tad/active/epics/` 2 件 EPIC＋2 文件夹（framework-health-repair、capability-builder-v1）；grep `Phase Map\|Context for Next` 两文件均 0 命中 | Epic 文件夹 session-state 在产 | 两件 active EPIC 均无 Phase Map／Context for Next Phase 节，阶段接力靠文件夹 session-state 补位，非原件形态 |
| D08 迭代文档 Sprint | 未落实 | `.tad/templates/sprint.md` 仅模板 | 无 | 无任何 Sprint 文档在产，整件未启用 |
| D09 过剩产能计划 Surplus Plan | 未落实 | `.tad/evidence/surplus-plans/`（SURPLUS-PLAN-2026-06-08/13/14、SURPLUS-REPORT-2026-07-02）；`.tad/templates/surplus-plan-template.md` | 无 | 停产于 2026-07-02，近 30 天无计划件 |
| D10 设计文档 Design Doc | 落实 | `.tad/evidence/designs/` 62 件，最新 `2026-10-04-tad-state-surface-closeout-design.md`；HANDOFF 以路径指针引用原件 | 设计先行于 HANDOFF 在当日链实证 | —— |
| D11 任务交接 HANDOFF | 落实 | `.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`（36,372 B；Quality Chain Metadata、MQ1–MQ5、§9.1、Project Knowledge 节、tad_scope 均在） | 当日链按全形态成文并驱动实施 | —— |
| D12 方案评审记录 Gate 2 Review | 落实 | `.tad/evidence/reviews/2026-10-04-gate2-tech-review-state-surface-closeout.md`、`-gate2-fit-review-`、`-gate2-merge-verdict-`、`2026-10-04-waiver-p1p3-gate2-evidence.md` | 双路独立评审＋合并裁定在 HANDOFF 定稿后、实施前落盘 | —— |
| D13 发布交接 Release Handoff | 未落实 | `.tad/templates/release-handoff.md`；`.tad/evidence/release/2026-09-15-v3.0.0-publish.md`（破坏性/平台影响提及仅 1 处） | publish 流程有记录 | publish 记录未按 Release Handoff 模板形态成文，独立 Release Handoff 件未在产 |
| D14 会话状态 Session State | 落实 | `.tad/active/session-state.md`（顶层在位，头部多链索引 2026-10-04 更新） | 本席位 2026-10-04 会话压缩后据其索引恢复接手 | 索引下正文仍为 hillclimb 存量（正文 Last Updated 2026-09-29），其自注「链收口后迁出」尚未执行 |
| D15 压缩前快照 PreCompact Snapshot | 未落实 | `.tad/active/precompact/` 5 件，最新 `snapshot-20260908-175832-codex-resume-019cb353.md`；`.tad/hooks/precompact-session-snapshot.sh` 在架 | 无 | 快照停产于 2026-09-08；其后 2026-10-03/04 多链与一次会话压缩均无新快照，原生通道无 hook 运行时承载 |
| D16 自迭代循环状态 Ralph Loop State | 未落实 | `.tad/ralph-config/loop-config.yaml`、`expert-criteria.yaml`；`.tad/evidence/ralph-loops/` 状态件 git 最后产出 2026-09-06；COMPLETION 模板含 Reflexion History 节 | 无 | loop 状态件停产于 2026-09-06，近 30 天多链无新状态件产出 |
| D17 捕获日志 Journal | 落实 | `.tad/evidence/journal/` 在产，最新 `verify-delta-2026-09-10.md`（近 30 天内） | 仓内落盘、接手者可见 | ——（近 30 天产量 1 件） |
| D18 执行轨迹 Execution Traces | 未落实 | `.tad/hooks/trace-step.sh`；`.tad/evidence/traces/2026-09-14.jsonl` 与 `per-handoff/`（仅 1 项）；traces 目录 git 最后提交 2026-08-17 | 无 | 轨迹产出稀疏，无 hook 在当前通道保证完整性，近 30 天多链无对应轨迹件 |
| D19 专家评审组 Expert Reviews | 未落实 | `.tad/evidence/reviews/`：code/security 在产（2026-10-04）；testing-review 共 9 件最新 2026-05-15；performance-review 最新 2026-08-01；ux-review 0 件 | code/safety 双路为当日链实证 | 专家粒度未恢复常态，近 30 天仅 code/safety 两路在产 |
| D20 完工报告 COMPLETION | 落实 | `.tad/active/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md`（KA／Friction／Evidence Checklist／Provenance／gate3_verdict 强制节齐） | 强制节缺一 Gate 3 BLOCKING，当日链实证 | —— |
| D21 独立验收 Gate 4 Acceptance | 落实 | `.tad/evidence/reviews/2026-10-04-gate4-acceptance-state-surface-closeout.md`（独立会话验收、含盘上重算）；`.tad/evidence/gate4/` 在架 | verdict 决定当日链收口，实证在盘 | —— |
| D22 知识评估 KA | 落实 | COMPLETION 内 Knowledge Assessment 强制节（Gate 3 BLOCKING）；2026-10-04 蒸馏落 `.tad/project-knowledge/patterns/ac-verification.md`（Gate 4 §8 处方执行） | KA 结论驱动蒸馏落盘，当日链全程实证 | —— |
| D23 结对测试 Pair-Test Brief/Report | 未落实 | `.tad/pair-testing/` 仅 `screenshots/.gitkeep`；`.tad/templates/pair-test-report-template.md` | 无 | 无 Brief/Report 在产（最近相关评审件 2026-02-09） |
| D24 结构化反馈 Structured Feedback | 未落实 | `.tad/templates/feedback-json-schema.md`；`.tad/memory/feedback_*.md` git 最后活动 2026-08-12 | 无 | 一般验收反馈无结构化记录在产，捕获停于 2026-08 |
| D25 原则集 Principles | 落实 | `.tad/project-knowledge/principles.md`（13 条原则）；AGENTS.md 激活必读指向 | 本步开工实读并作为判定依据引用 | —— |
| D26 成功模式 Patterns | 落实 | `.tad/project-knowledge/patterns/` 12 条＋`_index.md`（索引全列，git 2026-09-29 更新）；2026-10-04 KA 蒸馏向 `ac-verification.md` 追加条目 | 索引为开工必读（至多读 3 条全文），当日链有蒸馏产出 | ——（近 30 天新增产出集中于 1 件，余为存量） |
| D27 事故记录 Incidents | 未落实 | `.tad/project-knowledge/incidents/` 月目录仅 2026-05、2026-06；`_index.md` git 最后更新 2026-06-10 | 无 | 停产于 2026-06；与仓外 corrections.jsonl 无打通记录 |
| D28 领域知识类目 Domain Category Files | 未落实 | `.tad/project-knowledge/` 类目文件在盘：`architecture.md`、`code-quality.md`、`frontend-design.md`、`security.md`；AGENTS.md 选读路由指向的 testing/ux/performance/api-integration/mobile-platform 五类目无文件 | 已有四类目可按需选读 | 五类目整件缺失，选读路由命中时无件可读 |
| D29 成功剧本 Playbook | 未落实 | `.tad/templates/playbook-entry-template.md`、`playbook-entry-schema.md` | 无 | 无 Playbook 条目库落点与条目在产，成功解法沉淀实际走 patterns／skill-library 两路 |
| D30 技能化候选 Skillify Candidates | 未落实 | `.tad/templates/skillify-candidate-template.md`；候选概念仅见 `.tad/archive/ideas/IDEA-20260603-skillify-at-knowledge-assessment.md` | 无 | 无候选件与晋级评审在产 |
| D31 跨库知识路由索引 Brain Index | 未落实 | `.tad/brain-index.md`（24,904 B，git 2026-09-16 更新；含 principles/patterns/decisions/memory 路由，incidents 提及 0） | 本步开工按其路由取件 | 路由覆盖缺 incidents 一类 |
| D32 记忆捕获层 Memory Capture | 未落实 | `.tad/memory/`（MEMORY.md＋feedback 条目 37 项；git 最后活动 2026-08-12）；AGENTS.md 定记忆为捕获非权威 | 权威边界明确 | 捕获层停产于 2026-08-12，近 30 天无新条目 |
| D33 决策记录 DR | 未落实 | `.tad/decisions/` DR 件 23（最新 `DR-20260902-local-wiki-browser-ingest-bridge.md`，正文形态完备） | 无 | 最新 DR 距普查日 32 天，近 30 天无新 DR；近期取舍由 gm 仓 decisions.jsonl 单行台账承载 |
| D34 外部依赖注册表 Dependency Registry | 未落实 | `.tad/dependencies/REGISTRY.yaml`（内容 `last_updated: 2026-07-15`）、`scan-results.yaml`（`last_scan: 2026-08-12`） | 无 | v3.0.0（2026-09-15）及其后变更未见登记更新，注册表内容已过期 |
| D35 知识使用日志 Knowledge Usage Log | 未落实 | `.tad/evidence/knowledge-usage-log.jsonl` 在盘但 **0 B 空件**（git 建档 2026-08-17） | 无（读路径无留痕可查） | 空件待激活：无 genesis 行、无任何使用记录 |
| D36 归档结构 Archive Structure | 未落实 | `.tad/archive/` 17 子组（handoffs/next/knowledge-snapshots/learnings-archived/spikes/research/epics/ideas 等齐备）；`archive/handoffs/` 709 件、`archive/epics/` 76 项 | 历史迁移量实证充分 | 已收口链件仍滞留 active：platform-adapters（2026-09-15 收口）与 state-surface（2026-10-04 收口）两链 HANDOFF/COMPLETION 均未迁，迁移未成收口固定动作 |
| D37 门禁判据单文 Gate Criteria Single-Source | 未落实 | `.tad/gates/gate-canonical-checklist.md`（自称 SSOT，页眉 `Last reconciled: 2026-06-23`）；`quality-gate-checklist.md` 已标 SUPERSEDED 并指向 canonical | 仓内 Build 轨判据单文已成 | canonical 自 2026-06-23 未再对账，v3.0.0 与 §8f 分档等新规未见回写；与 gm 机制正文的双轨对账无记录 |
| D38 MQ 证据指引 MQ1–MQ5 Guide | 未落实 | `.tad/templates/handoff-a-to-b.md` 内嵌 MQ1–MQ5 字段（第 238 行起）；当日 HANDOFF 五问已实填 | 五问随 HANDOFF 模板强制成文 | 无独立字段级填写指引件（`.tad/guides/` 无、`.tad/tasks/evidence-collection.md` 对 MQ 提及 0），指引只随模板字段摸索 |
| D39 知识治理三件 Knowledge Governance | 未落实 | `.tad/templates/knowledge-bootstrap.md`、`knowledge-writing-rules.md`（治理正本在架，本仓即正本所在地）；`.tad/project-knowledge/README.md` | 无 | 无治理动作记录在产，生命周期处置靠 DR 个案承载（如 `DR-20260609-deprecation-yaml-disposition.md`），非治理例行 |
| D40 工作流定义 Workflow Definitions | 未落实 | `.tad/tasks/` 六件齐备（requirement-elicitation／handoff-creation／evidence-collection／gate-execution／parallel-execution／release-execution） | 本步激活包按规程原件装载即其引用形态 | 引用靠 PM 激活包人工带入、无机器引用点位；激活包未逐件点名 tasks 原件 |
| D41 模板库 Templates | 落实 | `.tad/templates/` 45 项（handoff-a-to-b／completion-report／epic-template／research-charter 等齐备） | 当日链 HANDOFF/COMPLETION 按模板形态成文 | —— |
| D42 平台配置组 Platform Config | 未落实 | `.tad/config.yaml` 等 `config-*.yaml` 7 件＋`discipline-floor.md`＋`task-budgets.yaml`（git 最后更新 2026-09-16） | 配置件在架随仓分发 | 最后更新早于 MODEL-LOCK v4（2026-09-28）参数变更，未见逐项对账回写记录 |
| D43 机器检查点位 Machine Checkpoints (Hooks) | 未落实 | `.tad/hooks/` 8 件（startup-health／precompact-session-snapshot／post-write-sync／trace-step／pre-gate-check／pre-accept-check 等）；`.codex/hooks.json` 接线在盘；AGENTS.md 明载 OpenCode/Cursor 无 hooks（P2 缺口） | Codex 通道有脚本与接线 | 三点覆盖的产出实证停于 2026-09-08（快照）；当前主力原生通道无 hook 运行时，写文件提醒／会话健康摘要／压缩前快照三点在该通道无覆盖实证 |
| D44 研究轨契约 Research Track Contract | 未落实 | `.tad/gates/research-gate-canonical-checklist.md`（含 SOURCES／Provenance 项）；`.tad/evidence/research/` findings 件含 provenance 字段 | 研究门判据件在架 | 近 30 天本仓无完整研究轨链（charter→Critic 独立评审→provenance 三元组→verdict）在当前通道走完的实证 |

## 分布

落实 14 件（D01、D02、D03、D10、D11、D12、D14、D17、D20、D21、D22、D25、D26、D41）；未落实 30 件。
