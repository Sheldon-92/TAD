# Epic: Codex CLI Adaptation — Full TAD Support on Codex

**Epic ID**: EPIC-20260427-codex-cli-adaptation
**Created**: 2026-04-27
**Last Updated**: 2026-04-27
**Owner**: Alex
**Target Release**: v2.9.0 (minor bump — new platform support)

---

## Objective

让 TAD 能在 Codex CLI 上跑**完整工作流**（Alex 设计 + Blake 执行 + Gate 1-4），机制可以与 Claude Code 不同（手动 hook 触发 / 顺序 sub-agent review / Codex 原生 tool 体系），但**核心理念 + 流程纪律 + 质量 gate 保留**。Hybrid 用法（Alex Claude / Blake Codex）作为 Codex 全流程支持的一个特例自动可用。

**为什么现在做（v2.3 archive 后再启动的理由）**：
- 用户实际痛点：Claude Code 周限额是 hard ceiling，重度使用必然撞顶。撞顶后 1-3 天无法做事，影响生产
- 自 v2.3 (2026-02-17) 后改进：handoff 模板成熟 / bash hook 脚本独立化 / Domain Pack 文档化 — 跨平台移植的"砖头"已经准备好，比当时容易多了
- v2.3 的核心教训仍然成立：机制差异不可消除（hook auto-trigger / AskUserQuestion / Agent tool 是 Claude Code 独占）。本 Epic 接受机制差异，不强行对等

## Success Criteria

- [ ] Phase 0 Spike 6 测试矩阵通过 ≥4/6（pivot threshold；<4/6 STOP + 归档）
- [ ] Phase 1 build：TAD-Core Portable 元数据标记完成 + portable-extract.sh helper + Codex Blake/Alex launcher + 手动 gate 文档 + 顺序 sub-agent review 文档
- [ ] Phase 2 validation：在 TAD 自己项目（dogfood）上跑完一个 Codex 闭环（Alex Codex → handoff → Blake Codex → completion → Alex Gate 4 → archive）
- [ ] Phase 2 docs：INSTALLATION_GUIDE 加 Codex setup 章节 + release-runbook 加 Codex smoke test step（minor+ release 必跑 / patch 建议跑）
- [ ] Codex CLI 用户能在 Claude Code 撞顶时无缝切换继续推进 handoff
- [ ] 维护协议落地：每次 minor+ release 必跑 Codex smoke test，避免 v2.3 类型腐烂

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | **Spike — Codex 全 TAD 可行性** | ✅ Done | HANDOFF-20260501-codex-spike-phase0.md | 5/6 PASS → CONTINUE (Blake 2/3, Alex 3/3) |
| 1 | **Build — TAD-Core Portable + Codex Adapter** | ✅ Done | HANDOFF-20260501-codex-phase1-build.md | 9 files: launchers + SKILLs (25KB/35KB) + 4 guides + portable + README |
| 2 | **Validate + Document** | ✅ Done | HANDOFF-20260502-codex-phase2-validate.md | Dogfood CONFIRMED + INSTALLATION_GUIDE + release-runbook smoke test + README + CHANGELOG v2.9.0 |

### Phase Dependencies

- **P0 → P1**：Spike 必须先做。<4/6 PASS → STOP；≥4/6 PASS → P1 启动
- **P1 → P2**：所有 adapter 文件就位才能跑闭环验证
- **P2 内部顺序**：先 dogfood 验证（如 fail 则回 P1 修复），再写文档（don't write docs for what doesn't work）
- **P2 → v2.9.0 publish**：Phase 2 完成 = Epic 完成 = v2.9.0 release 触发

### Derived Status

Status computed from Phase Map:
- All ⬚ → **Planning**
- Any 🔄 or ✅ → **In Progress**
- All ✅ → **Complete**

Current: **Planning**. Phase 0 spike handoff is the next step.

---

## Item Inventory

### Phase 0: Spike — Codex 全 TAD 可行性（4 小时硬上限）

> 目标：用 4 小时验证 "Codex 能否承担完整 TAD 流程"。6 测试覆盖 Blake 模式（3 测试）+ Alex 模式（3 测试）。Pivot threshold ≥4/6 PASS。

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P0.1 | Codex CLI 安装 + auth + 基础 functionality 测试 | Codex CLI 文档 | pending | 起点。安装失败直接 STOP |
| P0.2 | Blake-1: 把 Blake SKILL 当 system prompt 喂 Codex，让它 paraphrase 一个真实 handoff（cleanup handoff） | Codex output | pending | PASS 标准：准确说出文件 + phase 数量 |
| P0.3 | Blake-2: 让 Codex 编辑 1 个文件 + 跑 `bash .tad/hooks/lib/layer2-audit.sh <slug>` 解释 exit code | Codex tool use log | pending | PASS 标准：编辑正确 + 解释合理 |
| P0.4 | Blake-3: Codex 输出 completion report 按 `.tad/templates/completion-report.md` 模板 | Codex output | pending | PASS 标准：≥80% 模板字段对齐 |
| P0.5 | Alex-1: 把 Alex SKILL 当 system prompt + 给一个简单需求，让 Codex 做 Socratic 等价（自由对话型，无 AskUserQuestion） | Codex multi-turn dialog | pending | PASS 标准：3-5 轮澄清后产出需求总结 |
| P0.6 | Alex-2: Codex 按 handoff template 起草一个 handoff（小任务，~2-3 文件 scope）| Codex draft handoff | pending | PASS 标准：模板结构正确 + 关键字段填充 |
| P0.7 | Alex-3: Codex 调一个 sub-agent (code-reviewer 等价 in Codex) 做评审 OR 手动 prompt 模拟顺序两个 review | Codex output + manual fallback | pending | PASS 标准：sub-agent 调用成功 OR 手动顺序模拟可接受 |
| P0.8 | SPIKE-REPORT.md：6 测试结果 + pivot 决策（continue / stop / partial）+ 关键发现 | `.tad/evidence/spikes/SPIKE-20260428-codex-cli-feasibility/SPIKE-REPORT.md` | pending | 输出物 |

**Pivot threshold**：
- ≥4/6 PASS → P1 启动
- <4/6 PASS → STOP，Epic 归档为"Codex 路径今天仍不可行"，记录到 architecture.md（v2.3 类型教训）

**时间盒**：4 小时硬上限（含安装 + 测试 + report）。超时 abort。

---

### Phase 1: Build — TAD-Core Portable + Codex Adapter（4-6 工作日）

> 目标：建 Codex 能跑完整 TAD 所需的全部基础设施。

#### P1.A: TAD-Core Portable 元数据标记

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P1.1 | 用 metadata 标记每个文件 / SKILL section 是 `platform: portable` 还是 `platform: claude-code-only`（per Q1 答案 B 物理隔离不做）| 修订后的 .tad/ 文件 | pending | 标记规则文档化在 `.tad/portable-rules.md` |
| P1.2 | 写 `.tad/portable-extract.sh` helper — 让 Codex 用户能 `bash portable-extract.sh > codex-tad-bundle/` 导出可移植子集 | shell script | pending | 关键工具，让"哪些可移植"变成可执行的事实而非文档 |

#### P1.B: Codex Blake mode 适配

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P1.3 | 写 `.tad/codex/codex-tad-blake.sh` — 启动脚本，注入 Blake SKILL（自动剥除 Claude Code 专属段）作为 Codex system prompt | shell script | pending | Codex 启动入口 |
| P1.4 | 写 `.tad/codex/manual-gates.md` — Blake 在 Codex 上手动跑 Gate 3 各 step 的指令清单（含 layer2-audit.sh / drift-check.sh / stale-knowledge-check.sh 等） | markdown | pending | 替代 Claude Code 自动 hook |
| P1.5 | 写 `.tad/codex/sequential-review.md` — Codex 上 Layer 2 顺序两个 sub-agent review 的操作手册（先 code-reviewer session，输出存到 `.tad/evidence/reviews/blake/<slug>/`，再 backend-architect session）| markdown | pending | 替代 Agent 平行调用 |

#### P1.C: Codex Alex mode 适配

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P1.6 | 写 `.tad/codex/codex-tad-alex.sh` — 启动脚本，注入 Alex SKILL 作为 Codex system prompt | shell script | pending | Codex Alex 启动入口 |
| P1.7 | 写 `.tad/codex/socratic-fallback.md` — 自由对话型 Socratic 流程（替代 AskUserQuestion 结构化 4-options，变成 Alex 在 prompt 里列选项 + 用户文字选）| markdown | pending | Alex 模式核心适配 |
| P1.8 | 写 `.tad/codex/expert-review-sequential.md` — Alex 在 Codex 上跑 expert review 的顺序 invocation 流程（手动开两个 review session 的步骤）| markdown | pending | Layer 2 专家审查的 Alex 端等价 |
| P1.9 | 写 `.tad/codex/codex-completion-variant.md`（IF NEEDED — 取决于 P0.4 spike 测试结果） | markdown | conditional | 如 spike 显示 Codex 完整对齐现有 completion 模板，则不需要这个文件 |

---

### Phase 2: Validate + Document（1 真实项目周期 + 0.5 工作日）

> 目标：在真实项目上跑闭环 + 文档化 + 维护协议落地。

#### P2.A: 真实项目 dogfood 闭环

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P2.1 | 在 TAD 自己项目（per Q3 答案）上跑完一个 Codex 闭环：Alex Codex 接需求 → Socratic → 写 handoff → expert review → Blake message → Blake Codex 收 handoff → 执行 → Layer 2 顺序 review → completion → Alex Gate 4 → archive | dogfood report | pending | 选一个真实但低风险的 TAD 改进任务作 dogfood |
| P2.2 | DOGFOOD-REPORT.md — 闭环执行结果 / 摩擦点 / 哪些 P1 文档要修订 / pivot 决策（继续 P2.B 文档 / 还是回 P1 修复）| `.tad/evidence/dogfood/DOGFOOD-20260XXX-codex-loop.md` | pending | 输出物 |

#### P2.B: 文档 + 维护协议

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P2.3 | INSTALLATION_GUIDE.md 加 "Codex CLI Setup" 章节 — 安装 / 启动 / 基础用法 / 何时用 Codex / 何时用 Claude Code | INSTALLATION_GUIDE.md diff | pending | 用户可见入口 |
| P2.4 | release-runbook 加 "Phase X — Codex 适配层 smoke test" — 每次 minor+ release 必跑（hard requirement），patch release 建议跑（advisory）。具体测试内容 ≥3 个核心 P1 文件 grep + 1 次 Codex Blake mode 启动测试 | release-runbook diff | pending | 防 v2.3 类型腐烂 |
| P2.5 | README.md highlights 加 Codex 支持 banner | README.md diff | pending | 用户可见 |
| P2.6 | v2.9.0 release prep notes — CHANGELOG entry 草稿 + version bump checklist 补 Codex 相关 | release notes | pending | Epic close 触发 v2.9.0 publish |

---

## Context for Next Phase

### Decisions Made So Far

1. **Hybrid 不是终点，Codex 全流程才是**（user 2026-04-27）— Codex 要支持 Alex + Blake 两种模式，机制差异接受
2. **Gemini 砍出 scope**（user 2026-04-27）— 开源配套不完善，未来真要做开新 Epic
3. **Sub-agent 平行 → 顺序**（user 2026-04-27）— 接受 Codex 上 Layer 2 review 变手动顺序两个 session
4. **元数据标记，不物理隔离** (Q1 答案)— 维护成本低，配 portable-extract.sh helper
5. **同仓库 `.tad/codex/`** (Q2 答案)— 解耦下游按需 enable
6. **dogfood 用 TAD 自己** (Q3 答案)— meta-trifecta，不影响其他活跃项目
7. **完整做完 = v2.9.0 minor** (Q4 答案)— 不在 patch 里偷塞实验性
8. **维护协议**：minor+ hard / patch advisory (Q5 答案)— 平衡负担与防腐
9. **3 phase 而非 5 phase**（user 2026-04-27）— 避免过度切分

### Out of Scope（明确不做）

- ❌ Gemini 适配（开源配套不完善 — 未来真要做开新 Epic）
- ❌ Sub-agent 平行 review（接受 Codex 上变顺序）
- ❌ Codex 端复刻 Claude Code hook 自动触发（接受变手动 invoke）
- ❌ AskUserQuestion 结构化提问 4-options 等价（接受变成自由对话型 Socratic）
- ❌ Domain Pack auto-loading hook on Codex（接受 Alex 在 handoff 里手动指定 Blake 要 Read 哪个 pack）
- ❌ Codex 端复刻 `/alex` `/blake` slash command（Codex 有自己的 command 体系，文档说明等效用法即可）
- ❌ Tool restrictions 模仿 Claude Code permissions.deny（Codex 有自己的 tool 控制机制，文档级别配齐即可）

### Known Issues / Carry-forward

1. **Codex CLI 版本依赖**：Phase 0 spike 时锁定的 Codex 版本，未来 Codex 更新可能 break adapter。Phase 2 release-runbook smoke test 是防御机制
2. **Codex MCP 支持深度未验证**：spike P0.1-P0.7 没专门测 MCP，如果 Phase 1 用到 MCP 工具会有意外。**风险接受**：先不依赖 MCP，未来需要再补 spike
3. **Maintenance burden 三倍化**：每次 Alex/Blake SKILL 改动都要同步 Codex 适配层。release-runbook smoke test 是缓解但不是消除
4. **TAD-Core Portable 边界可能不清晰**：哪些 SKILL section 真的"平台无关"是判断题，可能 spike 后才能定。Phase 1 P1.1 是关键
5. **AR-001 mechanical SKILL grep anchor 在 Codex 上不可执行**：Phase 3 P3.1 装的 *express path 防退化机制依赖 Claude Code grep 工具。Codex 等价方式：每次 release 时手动 grep 一次（纳入 release-runbook）

### Next Phase Scope — Phase 0 Spike

**触发条件**：用户 explicit start（Epic 进入 In Progress 状态）

**Phase 0 handoff 应覆盖**：
- 6 个测试的具体执行步骤 + pass/fail 判定
- Codex CLI 安装指南
- 把 cleanup handoff（HANDOFF-20260427-tad-cleanup-linear-and-hook）作为 Blake-1/2 测试用例
- 自定义一个 ~2-3 文件 scope 的小需求作为 Alex-2 测试用例
- SPIKE-REPORT.md 模板（含 pivot 决策框架）
- 时间盒严格执行（4 小时硬上限）

**预期 Phase 0 结果分布**：
- 5-6/6 PASS：Codex 适配信心高，Phase 1 直接做完整版
- 4/6 PASS：基本可行但有局部 broken，Phase 1 需要补漏
- 3/6 PASS：边界 — 用户判断是 STOP 还是 partial（如只做 Blake 模式，放弃 Alex 模式）
- <3/6 PASS：STOP，归档为 v2.3 类型教训

---

## Notes

### v2.3 历史背景（必读）

2026-02-17 删除了 Codex/Gemini 完整 runtime（commit message: "Multi-Platform Runtime Cleanup"）。当时判断：
- Codex/Gemini CLI 机制与 Claude Code 差异太大
- 维护负担三倍化收益小
- 用户没强烈痛点

**今天为什么再启动**：
- 用户开始撞 Claude Code 周限额（实际痛点）
- 自 v2.3 后 TAD 模板 / hook 脚本 / Domain Pack 都已经成熟+独立化，移植成本下降
- 接受"机制不对等"作为前提（v2.3 当时是想机制对等，所以放弃；本 Epic 不强求对等）

### v2.3 教训保留与超越

**保留**：
- 不强行机制对等（hook auto-trigger / AskUserQuestion / Agent tool 等 Claude Code 独占的，Codex 上变手动等效，不复刻）
- 维护负担是真问题，必须用 release-runbook smoke test 缓解

**超越**：
- 接受降级方式（顺序 review / 自由对话 Socratic）
- 用 metadata 标记而非物理代码分支
- Phase 0 spike 时间盒严格防失控

### Anti-Epic-1 Reminders

按 architecture.md "Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15"：
- ❌ 不要在 Codex 适配层装 fail-closed 机制（dep-guard 类）
- ❌ 不要让 Codex smoke test 阻塞用户日常使用
- ✅ 所有 Codex 适配层故障应 fail-soft + 警告，不阻断
- ✅ 维护协议是 release 时检查，不是运行时阻塞

### Active Epic count after Phase 0 launch

- EPIC-20260403-security-domain-pack-chain (paused at Phase 0+1)
- EPIC-20260424-tad-self-upgrade-from-consumers (Phase 6 pruned, will close after Blake commits cleanup)
- EPIC-20260427-codex-cli-adaptation (this — Planning)

3 active = at limit。EPIC-20260424 close 后剩 2 active，安全启动新工作。

### Pivots Table

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-04-27 | Hybrid → Codex 完整 TAD 支持 | User 期望 Codex 大部分能承担 Claude Code 能做的事，机制不同没关系 |
| 2026-04-27 | Gemini 砍出 scope | 开源配套不完善 |
| 2026-04-27 | 5 phase → 3 phase | User 反馈过度切分 |
| 2026-04-27 | 3 phase 切法 | Spike / Build / Validate-Document — 各有清晰 deliverable |

---

**Epic Created By**: Alex (Agent A)
**Date**: 2026-04-27
