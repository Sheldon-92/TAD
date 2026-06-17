# Epic: Research System Consolidation

**Epic ID**: EPIC-20260616-research-system-consolidation
**Created**: 2026-06-16
**Owner**: Alex

---

## Objective

将 TAD 的 9 个研究入口统一为 `*research` 一个命令（Quick/Standard/Deep 三级，默认 NotebookLM），同时在输入端（问题生成、源精选、语义饱和）和输出端（决策简报、轻量验证、闭环反馈）实现 6 项研究质量提升。最终用户只需说"研究一下 X"就能得到一份可用于决策的研究产出。

## Success Criteria

- [ ] 用户说"研究"时，Alex 默认走 NotebookLM 路径（不再误走 WebSearch）
- [ ] 研究入口从 9 个减为 4 个（*research / *research status / *research-notebook 手动 / /academic-research）
- [ ] 研究产出格式从原始问答链变为结构化决策简报（选项→证据→推荐→未知风险）
- [ ] 用真实研究任务跑完新流程，用户判断产出可用
- [ ] pack-upgrade workflow 迁移到 NotebookLM 研究路径
- [ ] 14 个同步项目在下次 *sync 时自动替换

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Unified Entry + Routing | ✅ Done | HANDOFF-20260616-research-unified-entry.md | `*research` 命令（Quick/Standard/Deep）+ 砍掉 research-methodology + CLAUDE.md 简化 |
| 2 | Input Quality (Q1-Q3) | ✅ Done | HANDOFF-20260617-research-input-quality.md | 决策题生成 + 源精选(15上限) + 语义饱和判断 |
| 3 | Output Quality (Q4-Q6) | ✅ Done | HANDOFF-20260617-research-output-quality.md | 决策简报格式 + 轻量 WebSearch 验证 + 闭环反馈 |
| 4 | Ecosystem Cleanup | ✅ Done | HANDOFF-20260617-research-ecosystem-cleanup.md | 删 research-engine workflow + pack-upgrade 迁移 NotebookLM（*sync 延至下次 *publish） |

### Phase Dependencies
All phases are sequential. Phase 1 is MVP (可独立使用); Phase 2-3 在 Phase 1 基础上增强; Phase 4 是收尾清理。

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Unified Entry + Routing

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
创建统一的 `*research` 命令协议，实现 Quick/Standard/Deep 三级路由，默认走 NotebookLM。砍掉 `/research-methodology` capability pack（与 `*research-plan` 重复）。简化 CLAUDE.md 和 Alex SKILL.md 中的研究排除规则。将 `*research-review` 改名为 `*research status`。

NOT in scope: 研究质量改进（Phase 2-3）、pack-upgrade 迁移（Phase 4）、research-engine workflow 删除（Phase 4）、research-notebook ask 动态追问协议的修改（保持现状）。

#### Input
- 现有 Alex SKILL.md 中的 `*research-plan` 协议（保留其 effort-scaling 分级逻辑）
- 现有 `/research-notebook` SKILL.md（作为实现层，不修改）
- 现有 `*research-review` 协议
- 现有 CLAUDE.md 研究排除规则
- `.claude/skills/research-methodology/` capability pack（待删除）

#### Output
- Alex SKILL.md 中新增 `*research` 统一协议（含 Quick/Standard/Deep 路由）
- Alex SKILL.md 中 `*research-plan` 重构为 `*research` Deep 级别的内部实现
- Alex SKILL.md 中 `*research-review` 改名为 `*research status`
- CLAUDE.md 研究相关规则简化
- Alex intent router 更新：所有"研究"类关键词路由到 `*research`
- `/research-methodology` skill 目录删除
- NotebookLM 不可用时的降级路径（WebSearch + 提示安装）

#### Acceptance Criteria
- [ ] AC1: `*research` 命令存在于 Alex SKILL.md，含 Quick/Standard/Deep 三级路由逻辑
- [ ] AC2: 说"研究一下 X"时，intent router 路由到 `*research`，默认走 Standard（NotebookLM ask）
- [ ] AC3: 说"深入研究 X"或"建知识库"时，路由到 Deep（NotebookLM 全流程）
- [ ] AC4: `/research-methodology` skill 目录已删除，不影响其他 skill 加载
- [ ] AC5: CLAUDE.md 研究排除规则简化为≤3 条（现在散布 5+ 处）
- [ ] AC6: `*research status` 命令可用（原 `*research-review` 改名）
- [ ] AC7: NotebookLM CLI 不可用时，Standard 降级为 WebSearch 并提示安装
- [ ] AC8: 用一个真实研究任务（技术选型或领域探索）走完 Standard 流程，产出符合预期

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — 新增 *research 协议、重构 research-plan、改名 research-review)
- `.claude/skills/alex/references/research-plan-protocol.md` (MODIFY — 重构为 *research Deep 的内部实现)
- `.claude/skills/alex/references/research-review-protocol.md` (MODIFY — 改名为 research-status)
- `.claude/skills/alex/references/intent-router-protocol.md` (MODIFY — 研究关键词路由更新)
- `.claude/skills/alex/references/research-decision-protocol.md` (MODIFY — 简化研究入口引用)
- `.claude/skills/research-methodology/SKILL.md` (DELETE)
- `.claude/skills/research-methodology/references/` (DELETE — 整个目录)
- `CLAUDE.md` (MODIFY — 研究排除规则简化)

#### Dependencies
None (first phase)

#### Notes
- research-notebook SKILL.md 和 ask 动态追问协议本阶段不修改
- research-engine workflow 本阶段保留（Phase 4 删除）
- Quick 级别不建 notebook，直接 WebSearch 回答——对应现有 research_decision_protocol 的 step2_research
- Standard 级别 = 找到匹配 notebook → ask（含动态追问）；没有匹配 → 新建 notebook + research fast + ask
- Deep 级别 = 现有 research-plan 的 Phase 0-5 全流程（GitHub-First sourcing + 多轮 seed + 报告）
- effort-scaling 分级（simple/comparison/complex）合并进路由：simple→Quick, comparison→Standard, complex→Deep

### Phase 2: Input Quality (Q1-Q3)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
在 `*research` Standard 和 Deep 级别中实现三项输入端质量提升：(Q1) 决策导向的问题生成——从 OBJECTIVES 或用户意图推导"基于 Y，X 哪个方案在 Z 方面证据最强？"而非泛搜清单题；(Q2) 源精选——Standard 上限 15 源，加源后 ask 验证相关性，不相关删掉再补；(Q3) 语义饱和判断——每轮反问"能回答研究目标吗？"替代机械的"0 新引用×2 轮"。

NOT in scope: 输出端改进（Phase 3）、ask 动态追问的 6 策略机制（保持现状）。

#### Input
Phase 1 产出的统一 `*research` 协议

#### Output
- `*research` 协议中 Standard/Deep 的问题生成规则更新
- `*research` 协议中源管理逻辑（加源后验证、上限控制）
- `*research` 协议中饱和判断从机械计数改为语义反问
- 对应的 references/ 文件更新

#### Acceptance Criteria
- [ ] AC1: Standard 研究生成的种子问题含决策锚点（"基于 Y，哪个 X 在 Z 方面..."），不出现"best practices for X"类泛问
- [ ] AC2: Standard 研究加源后自动验证相关性（ask "这个源和研究问题相关吗"），不相关的被删除
- [ ] AC3: Standard 研究源总量不超过 15（超出时删最低相关性的再补新的）
- [ ] AC4: 饱和判断使用语义反问（"基于现有信息，能回答 {研究目标} 吗？"），输出明确指出哪个子问题缺信息
- [ ] AC5: 用真实研究任务对比：新问题生成 vs 旧问题生成，新版更具体

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — *research 协议中的问题生成和源管理)
- `.claude/skills/alex/references/research-plan-protocol.md` (MODIFY — Deep 级别的问题生成和饱和规则)
- `.claude/skills/research-notebook/SKILL.md` (MODIFY — ask 中的饱和判断逻辑，如果 Q3 需要修改 ask 的 saturation 检测)

#### Dependencies
Phase 1

#### Notes
- Q3（语义饱和）可能需要修改 research-notebook ask 的 step3_5 饱和检测——但用户决定 ask 协议保持现状。解决方案：在 *research 协议层面包装，在调 ask 之前/之后做语义反问，不改 ask 内部逻辑
- Q2 的源上限 15 是 Standard 级别；Deep 级别可以更多但也应该有 curate 门控

### Phase 3: Output Quality (Q4-Q6)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
实现三项输出端质量提升：(Q4) 决策简报模板——固定格式：选项→每个选项的证据→推荐→未知风险；(Q5) 轻量验证——提取前 3 个具体 claim（数字/版本/名称）用 WebSearch 验证；(Q6) 闭环反馈——交付后问"回答了你的问题吗？哪部分没到位？"→ 针对性补充。

NOT in scope: research-notebook report 命令本身的修改；Deep 级别的 Codex/Gemini 对抗验证（保持现状）。

#### Input
Phase 2 产出的改进型研究流程

#### Output
- 决策简报模板文件 `.tad/templates/research-decision-brief.md`
- `*research` 协议中 Standard/Deep 的输出格式规则
- `*research` 协议中的轻量验证步骤
- `*research` 协议中的闭环反馈步骤

#### Acceptance Criteria
- [ ] AC1: Standard 研究产出遵循决策简报格式（含选项列表、每个选项的证据引用、推荐、未知风险四个必有段落）
- [ ] AC2: Standard 研究结束前提取 ≥3 个具体 claim 并用 WebSearch 验证，验证结果标注在简报中
- [ ] AC3: 研究交付后有闭环反馈步骤（AskUserQuestion），用户说"没到位"时能针对性补充而非从头开始
- [ ] AC4: 用真实研究任务测试完整 Standard 流程（Phase 1 路由 + Phase 2 质量 + Phase 3 产出），用户判断决策简报可用

#### Files Likely Affected
- `.tad/templates/research-decision-brief.md` (CREATE)
- `.claude/skills/alex/SKILL.md` (MODIFY — *research 协议中的输出和反馈)
- `.claude/skills/alex/references/research-plan-protocol.md` (MODIFY — Deep 级别输出格式)

#### Dependencies
Phase 2

#### Notes
- Q5 验证只用 WebSearch，不依赖 Codex/Gemini。Deep 级别的对抗验证保持现状（Codex+Gemini Phase 4c/5b）
- Q6 闭环反馈的"针对性补充"：不是重新走完整流程，而是用 ask 追问用户指出的不足子问题

### Phase 4: Ecosystem Cleanup

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
清理研究生态：删除 `research-engine` workflow；将 `pack-upgrade` workflow 的研究步骤从 research-engine 迁移到 NotebookLM；通过 *sync 将变更同步到 14 个项目。

NOT in scope: 修改 /academic-research capability pack；修改 /research-github skill；修改 research-notebook ask 动态追问。

#### Input
Phase 1-3 产出的完整统一研究系统

#### Output
- `research-engine.workflow.js` 删除
- `pack-upgrade.workflow.js` 研究步骤迁移
- 14 个同步项目更新（旧 skill 删除、新 skill 写入）
- ROADMAP.md 更新

#### Acceptance Criteria
- [ ] AC1: `.claude/workflows/research-engine.workflow.js` 已删除
- [ ] AC2: `pack-upgrade.workflow.js` 的 Plan 阶段使用 NotebookLM 研究（不再依赖 research-engine）
- [ ] AC3: *sync 执行后，14 个项目中 `/research-methodology` 目录被删除、`*research` 相关文件已写入
- [ ] AC4: *sync 后随机抽查 2 个项目，验证 Alex 激活后 `*research` 命令可用
- [ ] AC5: ROADMAP.md 反映研究系统整合完成

#### Files Likely Affected
- `.claude/workflows/research-engine.workflow.js` (DELETE)
- `.claude/workflows/pack-upgrade.workflow.js` (MODIFY — 研究步骤迁移)
- `ROADMAP.md` (MODIFY)
- 14 个同步项目的 `.claude/skills/` 和 `.tad/` 目录 (MODIFY via *sync)

#### Dependencies
Phase 3

#### Notes
- pack-upgrade 的 Plan 阶段当前用 research-engine workflow 做 WebSearch 深度研究。迁移到 NotebookLM 意味着需要在 workflow 中调用 notebooklm CLI——需确认 workflow subagent 是否能直接调 Bash
- 同步时旧 skill 文件的删除由 deny-list 机制处理（derive-sync-set.sh 不排除 research-methodology → 它会被同步为空/删除）
- 风险：如果某个同步项目正在用 research-methodology 做研究（状态文件 .research/research-state.yaml），直接删除可能中断。建议 *sync 时检查

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: 统一 *research 命令（Quick/Standard/Deep 路由）+ 删除 research-methodology pack（10 files, -1492 lines）+ 更新 13 文件 + CLAUDE.md 简化。Commit 4dbb5a3。
- Phase 2: 三项输入端质量提升——Q1 决策点确认 + Q2 源相关性验证(--source scoped) + Q3 语义饱和检查。+141 行。Commit 05efd2e。
- Phase 3: 三项输出端质量提升——Q4 决策简报(四段式) + Q5 WebSearch claim 验证 + Q6 闭环反馈(4路径+sufficiency check)。模板+协议 +157 行。Commit b1c13a0。

### Decisions Made So Far
- pack-upgrade 研究步骤迁移到 NotebookLM（不保留 research-engine）
- 同步策略：下次 *sync 自动替换（不做新旧共存过渡期）
- MVP = Phase 1（入口统一 + 路由修正），质量提升后续逐项加
- NotebookLM 不可用时降级为 WebSearch + 提示安装
- research-notebook ask 动态追问协议保持现状
- 验收方式：用真实研究任务跑完新流程

### Known Issues / Carry-forward
- research-notebook ask 的机械饱和检测（0 新引用×2 轮）在 Phase 2 需要在 *research 层面包装语义反问，但不修改 ask 内部逻辑
- pack-upgrade workflow 的 subagent 能否直接调 notebooklm CLI 需在 Phase 4 确认

### Next Phase Scope
Phase 1: 创建统一 *research 命令，实现三级路由，砍 research-methodology，简化 CLAUDE.md

---

## Notes
- 源于 2026-06-16 *discuss 深度分析：9 个研究入口完整摸底
- 用户核心痛点："想要 NotebookLM 研究但 Alex 经常做别的"
- 方法论：入口整合是前提，质量改进是目的
