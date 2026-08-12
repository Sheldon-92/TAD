# Epic: Lite 承担全部工作与职能
<!-- 原名「Full 能力提取与硬退休」。文件名保持不变以维持历史引用。 -->

**Created**: 2026-08-09
**Redesigned**: 2026-08-12（目标重述 + Phase 5–9 重构 + 判据从"判断"改为"载体"）
**Owner**: Alex-Lite
**Status**: 🛑 **STOPPED（2026-08-12，用户裁定）** —— Phase 1–4 已交付并保留；
**Phase 5–9 全部取消**。停止理由与后继方向见文末「Epic 终止记录」。
**Predecessor**: `.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md`

## Objective（2026-08-12 重述）

**目标是让 `Alex-Lite / Blake-Lite` 能承担全部工作与职能。退休 full 是可能的手段之一，
不是目的。**

用户 2026-08-12 原话："废掉 full 其实不是重点，而是让 lite 流程能承担全部工作和职能才是重点。"

⚠️ **这不是措辞调整。** 原目标以"删除 full 的运行时、安装、路由与校验面"为终点，
把手段写成了终点；一旦如此，任何"能少维护一点"的判断都天然对齐目标，
而"这项功能还有没有人在做"的问题就没有位置。Phase 1 那处确认损耗正是这么来的（见下）。

目标结构不变：`Alex-Lite / Blake-Lite` 是唯一工作流角色；skills 提供专项知识、确定流程与
工具编排，但不拥有独立任务状态，也不能覆盖 Lite 的契约授权边界或独立 reviewer。

**新增的目标维度（2026-08-12，尚未拍板 → Phase 9）**：
"承担全部职能"不只是"做得到"，还包括"代价可承受"。本 Epic 5 张单的实测代价是
契约 4–8 版、独立审查 3–7 轮，且**重量与后果不成比例**（不可撤销的对外发布 8 版 7 轮；
可回滚的本机升级 4 版 3 轮 + 准入拦 1 次）。若"lite 承担全部"意味着"全部都按这个代价"，
目标本身会变成负担。

## 判据原则：载体，不是判断（2026-08-12 新增，本次重构的核心）

**不问**"这项处置了吗"（那是判断，判断错了无人发现）；
**问**"如果今天冻结 full，什么会停止发生？什么承载它？"（可证伪，答不出载体即损耗）。

依据：2026-08-12 的损耗审计实测——**被格式强制点名载体的行（7 项 EXISTING）全部经得起检查；
唯一一处确认损耗出在被豁免于点名载体的行**（`RETIRE`，`existing_equivalents: []`）。
已蒸馏为 `patterns/handoff-design.md`「"不需要"是判断不是载体」。

## Non-Goals

- 不把 full protocol 正文搬进 Lite skill。
- ~~不为了保存历史功能而保留 full 激活、启动扫描或通道分类器。~~
  ⚠️ **2026-08-12 修订 —— 这一条是那处确认损耗的根因。**
  它把"启动扫描"作为**整体**预先判为可弃，于是 Phase 1 无需为其上承载的**任何一项功能**
  点名载体，`full-router-startup` 的 `existing_equivalents` 因此合法地为空。
  实际后果：启动扫描里的 `urgent_security` 检测停跑 28 天，期间 `gh` 的 4 个安全漏洞
  （含 `gh auth status` 明文打印部分认证 token）无人发现，直到 Phase 4 偶然撞上。
  **修订为**：不保留 full 的**激活路径与通道分类器**（那确实是固定启动费）；
  但其上承载的**每一项功能**必须单独处置——判为不需要时，同样要回答
  "它停止发生后由谁承担 / 为何可以不承担"。**打包退休一个机制，不等于退休它承载的功能。**
- 不在完成下游迁移和 Lite-only burn-in 前删除 full 文件。
  （⚠️ 若 Phase 6 裁定为"冻结而非删除"，本条随之作废——见 Phase 8 的条件性说明。）
- 不把 full 共同存在的机械权限债务伪装成本 Epic 已解决的问题。
- 历史 handoff、Epic 与 evidence 保持历史原貌，不追写为 Lite 格式。
- **不把"仪式重量"问题（Phase 9）伪装成能力问题**：能力清单已近关闭，而每单代价未降；
  两者是不同的问题，混在一起谈会让任何一个都得不到解决。

## Architecture Decisions

1. **Lite Core + Capability Skills**：低频能力只在命中任务时加载。
2. **单一状态所有者**：当前 Lite 角色持有 handoff/Progress；skill 无独立可变状态。
3. **结果授权契约**：未来有效权限模型为 Lite 角色、skill 声明与已接受 Contract Mandate
   的交集；人的意图在设计期固化，不在运行时逐命令重复批准。详见
   `.tad/decisions/DR-20260809-lite-authority-model-v2.md`。
4. **角色感知模式**：候选 skill 显式区分 `plan / execute / verify`，不得借 skill 跨越
   Alex-Lite design-only 或 Blake-Lite contract-boundary。
5. **渐进披露**：skill metadata 常驻；SKILL.md 命中才加载；references/scripts 再按需。
6. **先处置再建设**：每项 full 能力先判 `EXTRACT / EXTEND / EXISTING / LITE_NATIVE /
   RETIRE / HISTORY_ONLY / DECISION_REQUIRED`，没有载体不新建 skill。

## Success Criteria

⚠️ **2026-08-12 重构**：SC1–SC8 中，SC1/SC2 是**判断型**判据（"有处置结论"），
损耗审计证明它们不足以保证能力完整。新增 **SC0** 作为**载体型**总判据，
并把 SC4/SC6/SC7 标为**条件性**——它们只在 Phase 6 裁定为"删除"时才适用。

| # | 判据 | 类型 | 状态 |
|---|---|---|---|
| **SC0** | **19 项能力逐项有具名载体**（文件 / hook / skill），且载体经实测存在并可被 lite 触达；判为"不需要"的行同样须回答"停止发生后由谁承担/为何可以不承担" | **载体型（总判据）** | 15 有载体 / 1 确认损耗 / 1 范围待定 / 4 待裁 |
| SC1 | 所有现役 full canonical 文件、命令与路由消费者都有处置结论，无未分类项 | 判断型 | ✅ Phase 1 达成（但不足以保证 SC0）|
| SC2 | 每个 EXTRACT/EXTEND 候选都有真实触发例、资源计划、角色模式、权限与验证契约 | 判断型 | ✅ release-ops / dependencies 均达成 |
| SC3 | 普通 Lite 任务固定读取量不因本 Epic 增长；未命中能力时专项 skill 加载数为 0 | 载体型 | ✅ 保持（skills 按需加载）|
| SC4 | 14 个注册项目均有明确状态；可访问项目安装 Lite；active `HANDOFF-*` 清零 | 条件性 | ⚠️ **本仓库 active full handoff 已为 0**；下游部分**被 F1 外部阻塞** |
| SC5 | 一轮真实 publish-only、依赖变更、全局注册面、失败恢复均由 Lite-only 完成 | 载体型 | publish-only ✅(3c) / 依赖变更 ✅(P4) / **全局注册面与失败恢复未做** |
| SC6 | 弃用期内新建 `HANDOFF-*` 为 0，full fallback 为 0，P0 遗留为 0 | 条件性 | 仅在裁定"删除"时适用 |
| SC7 | full skill、安装复制、路由入口和专属 verifier 消费方全部删除；历史归档仍可读 | 条件性 | 仅在裁定"删除"时适用；裁定"冻结"则改为"标注 + 停止维护" |
| SC8 | mandate 内执行的 `avoidable_runtime_prompt_count=0`；只有目标/对象/后果越界才重新请求人域决定 | 载体型 | ✅ 3b 建立、3c/P4 实测保持 |
| **SC9** | **（Phase 9，尚未拍板）** 仪式重量与后果成比例：低后果任务的契约版次与审查轮次显著低于高后果任务 | 载体型 | 未开始；**缺证据**（现有样本全为自指的框架工作）|

## Phase Map

| # | Phase | Status | Deliverable |
|---|---|---|---|
| 1 | Full 能力 inventory + disposition | COMPLETE (`e05a135`) | 机械来源覆盖 + 能力处置表 |
| 2 | Lite ↔ Skill composition contract | COMPLETE (`e05a135`) | D1–D10 架构、manifest、权限/恢复/测试契约 |
| 3a | Release capability migration | COMPLETE (`cabe287`; Gate 4 PASS) | 扩展 `release-runbook`；source coverage + 无副作用 forward-test |
| 3b | Lite Authority Model v2 | COMPLETE (`80413f8`; Gate 4 PASS) | 用 Contract Mandate 取代逐命令审批；修订 Lite/skill composition 与测试 |
| 3c | Release live dogfood | COMPLETE (`9253bdd`; v2.41.0 已发布; L5 PASS) | Lite-only 真实 publish-only（v2.41.0）；mandate 内零可避免运行时询问 |
| 4 | Dependency operations | **COMPLETE**（19/19 AC PASS；L5 验收 2026-08-12）| `dependency-ops` skill（双平台镜像）+ 真实 dogfood `gh` 2.96.0→2.97.0 |
| 5 | ~~能力损耗审计 + 补齐~~ | 🛑 **CANCELLED**（2026-08-12）| 机械部分 Alex 已完成（见「Phase 5 重定义」节）。交付：① 补上确认损耗（启动扫描的 4 项功能）② 裁定"冻结 full"的范围（是否含 `/gate`）③ 裁定 4 项 `DECISION_REQUIRED` ④ CLAUDE.md §2 缺口清单改为**穷举** ⑤ 逐项载体表落盘。**原定义"次级能力处置"作废**——它假设已判定的 15 项无问题 |
| 6 | ~~通道处置裁定与执行~~ | 🛑 **CANCELLED**（2026-08-12）| 按 P5 的载体表裁定：**冻结**（停止维护 + deprecation 标注 + §2 穷举）**还是删除**。两者对 SC4/6/7 的含义不同，须显式选择。原定义"Legacy + downstream migration"移至 P7 |
| 7 | ~~下游状态与迁移~~ | 🛑 **CANCELLED**（2026-08-12；F1 仍是独立待办）| 14 个注册项目状态核实与迁移。⚠️ **被 F1 硬阻塞**：25 个存量下游跑本地旧 `tad.sh` 会被告知"已是最新"，收不到任何更新——迁移在通路修复前不可能完成。见「外部依赖」节 |
| 8 | ~~物理删除~~ | 🛑 **CANCELLED**（2026-08-12）| 删除 full 活跃面、下游 deprecation 清理、可回滚发布。⚠️ 本 phase 的存在与否由 P6 决定，不是既定路线 |
| 9 | ~~仪式重量旋钮~~ | 🛑 **移出本 Epic**（2026-08-12）—— 它是后继方向的第 2 条，见「Epic 终止记录」| 把 full/lite 从"两套 agent"改为"一个 Alex + 一个 Blake + 契约里一个轻/重字段"，权限仍由每单 mandate 单独管（**不与仪式共轴**）。⚠️ **候选独立 Epic**——它改的是 agent 架构，范围大于本 Epic。前置证据：几个**非自指**任务的实测样本 |

## Phase Dependencies

```text
P1 inventory ─► P2 composition ─► P3a migrate ─► P3b authority ─► P3c dogfood ─► P4 dependencies
     ─► P5 损耗审计+补齐 ─► P6 通道处置裁定 ─┬─► P7 下游  ─► P8 物理删除（仅当 P6 裁定"删除"）
                                              │         ▲
                                              │         └── 外部依赖：F1 / 2.41.1（不在本 Epic 内）
                                              └─► （若裁定"冻结"：P8 作废，Epic 在 P7 后收口）

P9 仪式重量旋钮 —— 与 P5–P8 无依赖关系，可并行；前置是「非自指任务的证据样本」而非某个 phase
```

⚠️ **依赖链的两处变化**（相对原设计）：
1. 原链是线性的 `P5 ─► P6 ─► P7 ─► P8`，隐含"删除是既定终点"。新链在 P6 分叉——
   **删除是一个待裁的选项，不是默认路线**。
2. P7 有一条**Epic 外部的硬依赖**（F1）。原设计没有外部依赖概念，导致"下游迁移"看起来
   随时可做，实际上在通路修复前**不可能完成**。

## Risk Register

- **Full 2.0**：把大量 references 合并进 Lite。缓解：metadata/index 常驻，正文按需加载。
- **Skill 权限旁路**：skill 文本声称自己可执行 Lite 或 mandate 禁止的动作。缓解：权限交集与角色模式。
- **状态分叉**：skill 另建任务状态。缓解：handoff/Progress 是唯一任务状态载体。
- **重复不可逆动作**：publish/sync 超时后重试。缓解：事务身份、动作前后状态核验、幂等检测与 mandate recovery policy。
- **形式主义授权**：人被要求判断 Bash/Git/exit code，形成橡皮图章。缓解：结果授权前置、agent 负责技术恢复、运行时只在 mandate 越界时问人。
- **删除早于迁移**：下游旧 handoff 无执行者。缓解：P7 是 P8 的硬前置。

### 2026-08-12 新增风险（均已实证，非推测）

- **手段被当成目的** → 为省成本而退休仍在干活的功能。**已发生**：`full-router-startup`
  被判"固定启动费无价值"，其中的 `urgent_security` 检测停跑 28 天，漏掉 `gh` 的 4 个安全漏洞
  （含明文打印 token）。缓解：判据改为**载体型**（SC0）；Non-Goals 第 2 条已修订，
  禁止打包退休一个机制来连带退休它承载的功能。
- **豁免于点名载体的行不可检**：`existing_equivalents: []` 的行没有任何后续步骤会失败。
  缓解：损耗审计对**所有**行提同一个可证伪问题，不区分处置类型。
- **证明成本与后果不成比例**：本 Epic 5 张单实测——不可撤销的对外发布 8 版 7 轮，
  可回滚的本机升级 4 版 3 轮 + 准入拦 1 次。缓解方向是 P9，但**尚无证据支撑设计**。
- **外部依赖未登记**：P7 被 F1 硬阻塞而原设计无处记录，导致它长期显示为"可做"。
  缓解：新增「外部依赖」节，阻塞项须显式登记并注明是否在本 Epic 范围内。
- **契约的机械格式与语义质量是两道独立的闸**：Phase 4 的契约过了 3 轮语义审查，
  仍被 Blake 的 L0.5 机械准入拦下（`最终 verdict` 字段缺失 / `P0` 未带 `(fixed)` /
  AC 计数不符）。缓解：Alex 交付前须自跑一遍 L0.5 格式检查——
  **现有的交付前例行只覆盖 AC 命令空跑，不覆盖契约自身格式**。

## 外部依赖（2026-08-12 新增 —— 不在本 Epic 范围内，但阻塞本 Epic 的 phase）

| ID | 内容 | 阻塞 | 状态 |
|---|---|---|---|
| **F1** | 2.30.0–2.40.x 版 `tad.sh` 的升级判定静默失效：`detect_state` 先于下载执行，此时 `TARGET_VERSION` 仍是编译进该副本的硬编码字面量，与本地相等 → 恒判 `current` → `Nothing to do` 秒退。**用户看到绿色的"已是最新"，实际从未升级。** 影响面实测：`git tag --contains ac0699f` 仅 `v2.41.0`，`git show v2.40.0:tad.sh \| grep -c probe_remote_version` = 0 → **25 个存量下游全部在范围内** | **P7（下游迁移）** | 待开 2.41.1 单 |

⚠️ **F1 的交付物不是 patch release。** `ac0699f` 已修复代码、`v2.41.0` 已发布，
但**修复在结构上够不着需要它的机器**——存量项目跑的是自己目录里那份坏的 `tad.sh`。
唯一可用通路是 `curl -sSL …/main/tad.sh | bash -s -- --yes`（取线上版本，绕过本地坏副本，
F8 的 AC12b 实测能正常升级）。**所以交付物是"如何让这 25 个项目改用 curl"。**
已蒸馏为 `patterns/release-sync.md`「自更新安装器无法自我修复」。

## 残留登记（2026-08-12 —— 不进 phase，但不得丢失）

> 建立理由：本 Epic 此前的残留散落在各 phase 的 follow-up 段与各单的 findings 里，
> 无统一登记处，随归档逐渐不可见。以下为 2026-08-12 的全量盘点。

**A. 来自 F8（v2.41.0 安装冒烟）**
1. **Codex 单平台安装路径未验** —— `--platform codex` 走 deny-delta 裁剪，与 `both` 差异最大，是最值得补的缺口
2. `copy_pack_skill_smart` Case 4（hash-skip 保护分支）在该 fixture 上不可达、未验证
3. `merge_claude_md` 有锚点分支未验证
4. migration engine 有效链路未验证（2.30.0 恰好断链）
5. `.tad/hooks/**` 可执行位 / `.claude/settings.json` JSON 合法性 / `.codex/hooks.json` 生成正确性均无覆盖
6. **产品裁定待办**：新装项目不会获得 `.claude/skills/doc-organization.md`（skills 根级 `*.md` 契约性不装，`tad.sh:822` 的 `*/` 只遍历子目录），17/30 下游持有它属历史遗留 —— 是否为期望行为？

**B. 来自 Phase 4（dependency-ops）**
7. release 回归未测（`gh` 升级后 publish 流程行为异常与否，下次 publish 时观察）
8. limitation resolution 分支不可达、未验证（`gh` 的 `known_limitations` 为 `[]`）
9. `dependency-ops` skill 在下游未验证（属 P7 范畴）
10. ✅ **已闭**：围栏 `fence_audit` 半边无负控 —— Phase 4 的 AC15 负控 B 已补齐

**C. 更早的遗留**
11. `.tad/dependencies/REGISTRY.yaml` 的 6 项中有 3 项 `registry: null`（`notebooklm-cli` / `rsync` / `claude-code-cli`）**结构上永远扫不到** —— 若要覆盖需另想办法
12. `.tad/sync-registry.yaml` 陈旧两个月：14 条全停在 `2.30.0 / 2026-06-11`，其中 2 条路径已失效（`运动打卡小助手`、`Colin声音项目`）；存活目标已自行漂移到 1.5–2.41
13. CHANGELOG 历史乱序（重复 `[Unreleased] - 2026-02-01`；2.10.1 与 v2.23.0 排在 1.1.0 之后）
14. Layer 2 的 478 条 advisory 命中：立场是"报告并放行"，若含真实问题属后续单
15. D2（零命令通过规则）在**非 JS 项目**上的真实行为未验证
16. `audit-yolo.sh:278,288` 的 `npx` 执行点
17. 三处静态残留（详见 `.tad/archive/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md`）

**D. 流程侧（Alex 自身）**
18. **交付契约前的 L0.5 机械格式自检未固化** —— Phase 4 被 Blake 准入闸拦下一次，
    根因是 Alex 把模板固定字段改写成了叙事。应写进 alex-lite 的交付前例行或知识库
19. 未提交的已跟踪修改（本 session 的 6 条知识条目 + Epic 更新 + session-state + 此前遗留）
- **无载体能力膨胀**：为低频历史命令新建 skill。缓解：`DECISION_REQUIRED` + carrier 判定。

## Phase 1–2 Completion (2026-08-09)

- Accepted and archived: `.tad/archive/handoffs/LITE-20260809-1543-full-capability-inventory-contract.md`
- Commit: `e05a135`（未 push）
- Result: AC 9/9 PASS；独立 reviewer 最终 PASS，P0/P1/P2=0。
- Decisions: `release-ops → EXTEND release-runbook`；`dependencies → EXTRACT dependency-ops`；
  `tournament / ideas / alex-design-inquiry / knowledge-maintain → DECISION_REQUIRED`，留 Phase 5。
- Constraint-ledger overdue scan before the next phase handoff: no overdue or malformed rows.

## Phase 3 Split Decision (2026-08-09)

- Human selected option 2: use full once as a bounded migration bridge; do not loosen Lite read/write authority.
- Phase 3a handoff archived after Gate 4 PASS: `.tad/archive/handoffs/HANDOFF-20260809-release-runbook-capability-migration.md`.
- Phase 3a is build + detect-only/fixture/forward-test. It explicitly forbids push/tag/publish/sync and downstream writes.
- Phase 3a 的 capability mechanics 可完成，但其中 per-command approval 语义不得直接进入 live dogfood。
- Phase 3b 先落实 `.tad/decisions/DR-20260809-lite-authority-model-v2.md`；当前 Phase 2
  composition contract 的 per-action approval 部分被该 DR 前瞻性取代，历史 evidence 不追写。
- Phase 3c owns the real Lite-only publish-only dogfood；人的授权在设计期 Contract Mandate
  一次完成，mandate 内不得逐命令索取批准。
- **sync 退场决策（2026-08-11 用户裁定，publish-only 分支）**：3c 从「publish+sync」收窄为
  「publish only」，版本 2.41.0（minor）。依据 `feedback_no-sync-pull-based`（2026-06-11）：
  `*sync` 命令本身保留（用户可显式调用），但 Alex 不主动推荐；推式同步已停摆（registry 记录
  停在 2.30.0/2026-06-11），存活目标各自漂移自更新（2.30–2.38），拉取式结论成立。sync 的
  扇出写面在后续阶段不恢复为默认动作。
- Phase 1's provisional `release-verify-wrapper.sh` is rejected: it duplicates the existing public verifier interface and would create a second mechanical source of truth.

## Phase 3a Gate 4 Review (2026-08-10)

- Gate 3 commit `f8907a3` and zero-live-mutation evidence remain valid.
- Gate 4 FAIL: source guard invocation occurs too late for read-only sync/list routing (P1).
- Gate 4 FAIL: literal or symlink-resolved self-sync target is not rejected (P1).
- Performance review PASS: always-loaded entry is 69.5% smaller and no runtime executable surface changed.
- Acceptance report: `.tad/evidence/reviews/alex/release-runbook-capability-migration/gate4-acceptance.md`.
- This FAIL record is retained as history for `f8907a3`; both findings were repaired in `cabe287`.

## Phase 3a Gate 4 Rerun (2026-08-10)

- Gate 4 PASS at repair commit `cabe287` after an independent code, security, and performance rerun;
  every reviewer reported P0/P1/P2=0.
- Source identity now blocks all four operations before reference/state access; physical self-target
  identity blocks literal and symlink aliases before approval, state, or write.
- Alex mechanically reran AC1–AC11, mirror parity, and diff hygiene; all passed. The accepted evidence
  remains build/fixture-only with live mutation count 0 across 14 sealed registered targets.
- Handoff and completion were archived under `.tad/archive/handoffs/`. Phase 3b Authority Model v2 is
  ready and remains the prerequisite for any live release dogfood.
- Final report: `.tad/evidence/reviews/alex/release-runbook-capability-migration/gate4-rerun-acceptance.md`.

## Phase 3b Gate 2 (2026-08-10)

- Handoff ready: `.tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md`.
- The accepted outcome mandate replaces per-command approval; runtime prompts use a closed
  result-boundary enum and `avoidable_runtime_prompt_count` must remain zero.
- Gate 2 reviewers independently ended PASS at P0/P1/P2=0 after closing durable transaction state,
  executable CAS/crash recovery, exact consequence bindings, bounded release reference loading, and
  worktree/index/untracked/ignored/registered-target zero-touch evidence.
- Fixture contract: 30 cases, two clean controls, nine adversarial mutations; Phase 3b still prohibits
  all live push/tag/publish/sync and downstream writes.
- Gate 2 verdict: `.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md`.

## Phase 3b Gate 4 Acceptance (2026-08-10)

- Accepted at `80413f8f2c4b48d0e2e9f23d98d52e9bdc541a5e`; handoff + completion archived.
- Two repair rounds were needed. Gate 4 round 1 reproduced an **AC7 false PASS**: fixture rows carried
  their own `expected_result`, guarded only by a schema check plus a content digest — flipping an
  expected outcome and re-sealing the file still passed. Repair-2 added a 30-row literal expectation
  oracle inside the verifier, byte-compared against the normalized fixture. Alex confirmed the repair
  with four independently authored probes (outcome flip / unknown key / misplaced optional key /
  boolean inversion): 4/4 rejected.
- Gate 4 round 1 also found the revision-1 mandate encoded "one local commit" as human blast radius,
  turning a legitimate Gate-directed repair into a protocol deviation. Revision 2 redefined blast
  radius as exact target/surface/consequence/external reach; commit/retry/reviewer cardinality is
  agent-owned. `c851046` is retained honestly as a revision-1 deviation, not retroactively authorized.
- Alex recomputed every quantitative AC from raw evidence (commit range, 32 paths ⊆ §5.5, byte
  budgets, 30 fixtures, 13 inventory paths, 5 mirror pairs, 4 zero-touch planes, ledger overdue,
  evidence SHAs) — all matched. A fresh `--all` run by Alex was byte-identical to the recorded run.
- **Carry into 3c — AC8 headroom is 2 bytes.** Lite core is 52,198 against a 52,200 cap (baseline was
  47,398). The next edit to either Lite SKILL breaks AC8. Human decision 2026-08-10: defer the cap
  question until 3c actually hits it. Phase 3c must budget for this before adding Lite text.
- Open follow-up (out of scope here): `layer2-audit.sh` `KNOWN_REVIEWERS` does not recognize
  `implementation-reviewer` / `security-reviewer`, so the Layer 2 smoke alarm under-counts distinct
  reviewers. Carriers were verified directly on disk.
- No outward action performed anywhere in 3b: no push, tag, publish, sync, registry, or
  registered-target write. Phase 3c is the first phase that mutates outward.
- Gate 4 report: `.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-acceptance.md`.
- Knowledge: `patterns/gate-design.md` (authority model + blast-radius amendment, Blake) and
  `patterns/ac-verification.md` (self-certifying fixture matrix, Alex).

## Pre-3c Compatibility Cleanup — Layer 1 AC 驱动化 (2026-08-10, LITE 单，已验收归档)

Blake 的 Layer 1 自检不再硬编码 JS 四件套，改由 handoff §9.1 驱动（与 Gate 3 同源，补完
`gate/SKILL.md:159-162` 早已完成而 Layer 1 被落下的那一半）。提交 `9cfea17` + `2efe3d7`，未 push。
**在 3c 之前做，是因为 3c 的 sync 是扇出动作**——这些缺陷现在只坑本仓库，扇出后坑 14 个下游项目。

- 命令来源优先级已写进 SKILL 文本：§9.1 唯一权威 → `loop-config.yaml` 兜底 → 两者皆空则判定通过并在
  completion report 的 Gate 3 小节留一行零命令记录（禁止静默跳过）。**优先级必须写进文本而非只在本仓库
  成立**：下游 14 个项目会保留它们非空的 `loop-config.yaml`，不写清就等于把硬编码表在下一层复活。
- 同批修掉两处「作者环境 ≠ 执行环境」：pyyaml 指导改 ruby `YAML.safe_load`（`ac-verification.md:108`
  本就有本机禁用 `import yaml` 的清单，而 `shell-portability.md:72` 当时正在教它——知识层自相矛盾）；
  Blake 全文无界重读改为与 reviewer 模板同构的有界读取（§6+§9+frontmatter），顺带修好 `1_5_context_refresh`
  重复的步骤号 5/6/7。

### 带进 Phase 3c 的三项具名 follow-up（原契约 F3，不依赖记忆）

1. **D2 零命令行为的真实验证** —— 本单只做了文本断言，没有在真实非 JS 项目上跑过。安排在下一张
   非 JS 项目的单里自然验证。
2. **`.tad/hooks/lib/audit-yolo.sh:278,288`** —— 它**实际执行** `npx tsc --noEmit` / `npm test`，是同一
   缺陷最严重的实例（会真触发 npx 联网解析/挂起，见 `shell-portability.md` 2026-06-11 条目）。因
   `.tad/hooks/` 属高后果面被本单排除，**需独立单**。
3. **三处静态残留** —— `.tad/gates/quality-gate-checklist.md:230-232`、
   `.tad/guides/anti-rationalization-tables.md:29`（孤儿文件，仅 CHANGELOG 引用）、
   `.tad/templates/acceptance-verification-guide.md:39`（已带 "or equivalent" 软化）。非 Layer 1 执行路径。

### 残留（明记，不静默丢弃）

`DISTILLATION DEFERRED: 无` —— 两条候选均已蒸馏为成品条目（`patterns/shell-portability.md` 的
`grep -F` 锚失效条目、`patterns/ac-verification.md` 的遥测使围栏 AC 不可满足条目）。
但 **raw journal 行未追加**：Blake 把内容存在 `/tmp/journal-pending.txt` 待归档后写入
`.tad/evidence/journal/lite-discoveries.md`，而 alex-lite 无该路径写权限（Forbidden 的可写集只有四项）。
成品知识已落盘，raw capture 这一层由下次 blake-lite 会话补，或视为已被成品条目取代。

## Phase 3c 完成 — 首次对外发布 (2026-08-11)

**v2.41.0 已发布**：远端 `main` 从 `2fbebe8` 快进到 `9253bdd`（16 个 commit，0 merge，`is-ancestor`
证明无 force），annotated tag `v2.41.0`（tag 对象 `34a4c9a`）peeled 指向同一 commit，消息与契约固定文本
逐字相同。**这是整个 Epic 第一个真正对外写的动作**——1/2/3a/3b 全程零外部触达。

- **零 sync 已被证伪式验证**（不是自述）：registry 摘要 `1151b1de…` 未变；`.tad-backup` 在 12 个存活目标上
  仍为 0（"跑过 sync"最有特征的指纹）；远端 ref 从 113 → **115**，恰好 +2（tag + peeled），
  `refs/heads/claude/alex-0h91ph` 停在 `8707004` 未被触碰。14 个下游项目零写入。
- 三条发布命令全部用**字面 SHA**，无 `--force` / `--tags` / 组合链。
- 审查链：pre-push 三轮（`962ee9f` → `02a94e6` → **`9253bdd` PASS P0=0/P1=0**）+ post-publish PASS。
  最后一轮 pre-push 的审查对象 tip **就是**实际推送的 commit——"推送物 == 审查物"真的兑现。

### 这一单的代价与所买到的东西

契约做了 **8 版、7 轮独立审查**（P0 累计 6 全部关闭 / P1 12 / P2 20）。三次抓到的缺陷若按初版顺序执行，
**都会在 push 之后才暴露**，而那时唯一的补救手段（改写历史）恰好是被明令禁止的。

执行期又发现契约的**结构性盲区**：mandate 写死「恰两个 commit」+ 钉死 tip SHA，导致 commit 内容需修正时
无任何合法通道。用户 2026-08-11 裁定改为「计数归 agent 自主」，对齐 Phase 3b 已确立的原则——
**该原则在被写下一张单之后就被作者本人违反了一次**。

### 蒸馏（3 条，均带 failure_mode 与载体）

- `patterns/gate-design.md` — 每个不可逆动作都需要紧邻的只读闸；"在发布阶段之前验证"不够，
  因为一次发布含多个不可回头点。
- `patterns/handoff-design.md` — 放宽过紧约束前，先清点它**免费**保证了什么（钉死 SHA 顺带保证了
  "推送物 == 审查物"）。
- `patterns/handoff-design.md` — 批量改引用时，**漏掉的那处往往是承载权限的那处**（改了 6 处，
  漏的第 7 处是 mandate 绑定，指向的正是被闸门拒绝的 commit）。

### 带进 Phase 4 的 follow-up

1. ~~**F8 未闭**~~ → **F8 已闭（2026-08-11，LITE 单已验收归档，commit `6ae6e04`）**。见下方专节。
2. **registry 已陈旧两个月**：14 条记录全停在 `2.30.0 / 2026-06-11`，其中 2 条路径已失效
   （`运动打卡小助手`、`Colin声音项目`），而存活目标已自行漂移到 2.30–2.38。清理不属本单范围。
3. CHANGELOG 历史乱序（重复 `[Unreleased] - 2026-02-01`；2.10.1 与 v2.23.0 排在 1.1.0 之后）。
4. Layer 2 的 478 条 advisory 命中：本单立场是**报告并放行**，若含真实问题属后续单。
5. 前一单遗留三项：D2 零命令行为的真实验证、`audit-yolo.sh:278,288` 的 `npx` 执行点、三处静态残留。

## F8 闭环 — v2.41.0 安装路径冒烟测试 (2026-08-11, LITE 单，已验收归档)

契约 `.tad/archive/handoffs/LITE-20260811-1951-install-smoke-v2410.md`（rev6）；证据
`.tad/evidence/acceptance-tests/install-smoke-v2410/`；交付 commit `6ae6e04`（40 文件，未触远端）。

**结论：两条全新安装路径可用；升级路径对 25 个存量下游是坏的。**

- 全新安装 `curl | bash` 与 `npx -y github:Sheldon-92/TAD` 全部 PASS；线上 `tad.sh` 与本地
  **逐字节相同**（`f7eac61b…`）；两条路径产物 `diff -rq` 差异 0。
- 内容级等价（AC10b 六组）PASS —— 含此前零覆盖的 `.tad/` 20 个顶层文件（其中
  `portable-extract.sh` 正是 2026-06-01 记载"被扩展名 allow-list 静默漏掉"的那个）与
  `.claude/settings.json` / `workflows/`。
- curl 升级变体 2.30.0 → 2.41.0 成功，**用户数据零损失**：冻结集 8607/8607 逐字节一致，
  唯一变更是 `project-knowledge/README.md` 被换成 2.41.0 版（授权写入集，正向断言成立）。
  Alex 在 L5 独立重算复核过该结论，非纸面验收。

### F1（P1，本单只诊断不修复）→ **须开 2.41.1 单**

2.30.0–2.40.x 版 `tad.sh` 的升级判定静默失效：`detect_state` 先于下载执行，此时
`TARGET_VERSION` 仍是编译进该副本的硬编码字面量，与本地 `.tad/version.txt` 恒等 →
判 `current` → `Nothing to do` 秒退，**用户看到绿色的"已是最新"，实际从未升级**。
影响面已实测：`git tag --contains ac0699f` 仅 `v2.41.0`，`v2.40.0:tad.sh` 中
`probe_remote_version` 出现 0 次 → 25 个存量下游全部在范围内。

⚠️ **2.41.1 单的重点不是改代码（`ac0699f` 已修），是通路**：存量项目跑的是自己目录里那份坏的
`tad.sh`，**修复在结构上够不着它们**。唯一可用通路是 `curl … | bash`（取线上 2.41.0 那份，
AC12b 实测能正常升级）。所以交付物是"如何让 25 个项目改用 curl"，不是一次 patch release。

### 本单未覆盖（AC19 显式声明，不假装覆盖）

- 仅覆盖 2.30.0 fixture；下游其余 12 种版本未覆盖（现场普查 30 个项目）
- `--platform claude-code` / `--platform codex` / `--packs` 子集三条分支未覆盖
  （Codex 单平台走 deny-delta 裁剪，与 `both` 差异最大，是下一个最值得补的缺口）
- `copy_pack_skill_smart` Case 4（hash-skip）与 `merge_claude_md` 有锚点分支**不可达**
  （本 fixture 无 pack-meta、无合并锚点）—— 本单最大覆盖缺口
- **围栏 `fence_audit` 半边无负控**：AC17 的探针是未跟踪文件，构造上只对 `fence-fresh` 可见；
  建议下个触碰 `verify.sh` 时补一例已跟踪文件篡改探针
- F3 附带裁定项：新装项目不会获得 `.claude/skills/doc-organization.md`（skills 根级 `*.md`
  契约性不装，`tad.sh:822` 的 `*/` 只遍历子目录），17/30 下游持有它属历史遗留 —— 是否期望行为待裁定

### 这一单的代价与所买到的东西

契约 6 版、独立复核 3 轮（P0=6 / P1=13 / P2=12 全部处置）。买到的是判别力：rev1 那 20 条 AC
对"文件全在、内容全错"的安装**可以全绿**，因为唯一的内容比对比的是两条共用同一个 `tad.sh`
的路径。补 AC10b 之后才有真正的内容级判别力。另拆掉 4 条**必然误报**（要求安装从不安装的
`tad.sh`、把 316 个 pack 文件当必须存在、冻结一棵升级会合法写入的树、验一个在该 fixture 上
不可能发生的"定制被保留"），以及一条 Alex 写错并盖了"不必重查"章的背景事实。

### 蒸馏（3 条，均带 failure_mode 与载体）

- `patterns/ac-verification.md`：新守卫的**判据**须三重可验证 —— 逐字取自实现 / 在真实数据的
  全部形态上空跑 / 每个输入基数可被执行者独立获得。本单三次独立踩中同一条。
- `patterns/ac-verification.md`：两条各自正确的修法可**叠加**出新缺陷（预建目录 × `cp -R` 语义
  反转），且症状式守卫拦不住换路径到达的同一失败 —— 要空跑修订后的整体，不是改动的那一行。
- `patterns/release-sync.md`：从硬编码常量判定"已是最新"的自更新安装器**无法自我修复**，
  修复在需要它的机器上够不着；全新安装永远验不到这个闸，补救是通路问题不是代码问题。

## Phase 4 完成 —— dependency-ops skill + 真实 dogfood（2026-08-12，L5 验收通过）

契约 `.tad/archive/handoffs/LITE-20260811-2254-dependency-ops-skill.md`（rev4，19/19 AC PASS）；
证据 `.tad/evidence/acceptance-tests/dependency-ops-skill/`。

**交付**：`dependency-ops` capability skill（`.claude/` + `.agents/` 逐字节镜像，100 行），
承载 show/add/check/update 四子协议；真实 dogfood `gh` 2.96.0 → 2.97.0。
CLAUDE.md §2 的 `*deps` lite 缺口就此关闭。

**Alex 独立复验（非纸面验收）**：四条承重约束（N-K2/C-U1/C-U2/C-U3）实测在正文；
双平台 `cmp -s` 逐字节相同；`gh --version` = 2.97.0 且 Cellar 内 `2.96.0` 与 `2.97.0`
**两个 keg 并存**（回滚能力在）；REGISTRY diff **恰好 6 行**全在 `gh` 条目，
且日期为 **2026-08-12** —— 运行时取得，非硬编码的 08-11，证明时间炸弹的修复真实生效。

### 🔴 本单最重要的产出不是 skill，是它顺带查出的事

AC9 用完整 changelog（11294 字符，非截断的 18%）判 relevance = **HIGH**，依据是
`gh` 2.97.0 的 `## Security` 节原文："**Four security vulnerabilities have been identified,
and fixed, in this release. Users are advised to update gh to version v2.97.0 as soon as
possible.**" 其中 `GHSA-cg6r-mpgc-h9mm` 是 **`gh auth status` 会明文打印部分认证 token**
（`github_pat_*` / `ghs_*` / `ghu_*` 格式）。另三项：终端转义序列注入、URL 路径元字符改请求路径、
attestation 校验可被相似仓库名绕过。**而 `gh` 正是 publish 流程每次调用的工具。**

⚠️ **这条把 Phase 5 的损耗结论从理论变成实证**：full Alex 的启动扫描带 `urgent_security`
双路径检测，会在每次启动把安全公告顶出来；它被判为"每 session 固定启动费、无价值"而退休。
**在它停止运行的 28 天里，一个会泄漏 token 的漏洞就那么放着，直到本单偶然撞上。**
不是优先级判错，是**没有任何东西再去看这件事了**。

### AC17（单文件复演）确实起了作用

它真的抓到了东西：Q3 的答案首轮出现在**说明性文字**而非可照做的操作步骤里 → 判 FAIL →
把公式与 tier 值内联进 `deps show` 第 3 步 → 复核转正。
即：它成功区分了"信息在文件里"与"这是一份能照做的流程"——正是首轮审查发现
"skill 可以从未被打开而全绿"时补上的那条。审查者跨 harness（opencode / deepseek-v4-flash），
独立性强于同模型 spawn。

### 契约审查账

rev1 **FAIL**（4×P0）→ rev2（引入 4 个新 P0）→ rev3（引入 1 P0 / 2 P1）→ rev4 → PASS；
另被 Blake 的 L0.5 机械准入闸拦下 1 次（`最终 verdict` 字段缺失、`P0` 未带 `(fixed)`、
AC 计数不符——Alex 把模板固定字段改写成了叙事）。
**三轮的新缺陷高度同形：修复只落到成对表述的一半。**

### 蒸馏（3 条，均带 failure_mode 与载体）

- `patterns/ac-verification.md`：**单文件复演** —— 要验迁移产物是否"能照做"，
  只喂它一个文件给全新审查者，题面由契约钉死，必须含泛化探针与出处分类
- `patterns/ac-verification.md`：**修复一个响亮的失败时，别把它换成一个静默的成功**
  （`mkdir -p` / `|| true` / `2>/dev/null` 同族——它们消除的正是发现问题的信号）
- `patterns/handoff-design.md`：**"不需要"是判断不是载体** —— 退休清单里的损耗风险
  集中在被豁免于点名载体的那些行

### 带进 Phase 5 的残留（findings §4，不阻塞）

release 回归未测（下次 publish 观察）、limitation resolution 分支本轮不可达、
下游未验证（Phase 6 范畴）。

## Phase 5 重定义 —— 能力损耗审计（2026-08-12，用户提出，Alex 已跑机械部分）

### 为什么改掉原来的 Phase 5

原 Phase 5 是"次级能力处置（tournament / ideas / status 等提取或退休）"，它**假设已判定的
15 项没问题，只剩 4 项待判**。用户 2026-08-12 提出的疑问推翻了这个假设：

> "把原来的 Alex 和 Blake 冻结、全部迁到 lite 之后，能力是不是**无损耗**地迁过来了？
> 如果不是无损耗，那就是不够的。"

这个疑问成立。**在做这个审计之前谈冻结 full 是不安全的。**

### 审计方法（可证伪，不是复查判断）

不问"这项处置了吗"（那是 Phase 1 已做过的判断），改问：

> **如果今天冻结 full，什么会停止发生？**

每一项必须点名一个**载体**——具体的文件 / hook / skill——而不是一句"lite 也能做"。
**答不出载体的，就是损耗。** 这是本 Epic 三轮契约审查反复验证有效的同一条纪律
（`ac-verification.md` 2026-08-11：判据须逐字取自实现，不取自"听起来覆盖了"）。

⚠️ **风险的分布与直觉相反**：损耗风险**不在** 7 项 `EXISTING`（它们被格式强制点名了
`existing_equivalents`，有载体可查），**而在** `RETIRE` / `HISTORY_ONLY` 那 3 项 ——
因为它们的 `existing_equivalents: []` 是**按定义空的**。
"不需要"是一个判断，不是载体；判断错了不会有任何检查发现。

### 机械部分结果（2026-08-12 实测，只读）

| 类别 | 数 | 审计结论 |
|---|---|---|
| `EXISTING` | 7 | ✅ **10 个具名载体 skill 全部存在**（release-runbook 148 行 / tad-status 104 / research-notebook 1186 / research-github 583 / tad-parallel 75 / surplus 100 / product-thinking 78 / gate 995 / capability-upgrade 416 / playground 495），且均为**可独立调用**的 skill——不依赖 full 激活 |
| `LITE_NATIVE` | 3 | ✅ 本就是 lite 自身 |
| `EXTEND` / `EXTRACT` | 2 | ✅ release 已迁（Phase 3a）；dependencies 迁移中（Phase 4） |
| `HISTORY_ONLY` | 1 | ✅ 本仓库 active full handoff **已为 0**（332 张全归档）。下游 37 张属 Phase 6 范畴，与冻结无关 |
| `RETIRE` | 2 | ⚠️ `playground-legacy` 有 `playground` skill 存在 ✅；**`full-router-startup` 是确认损耗，见下** |
| `DECISION_REQUIRED` | 4 | 待裁（tournament / ideas / alex-design-inquiry / knowledge-maintain）|

### 🔴 确认损耗 1 项：`full-router-startup`

Phase 1 判 `RETIRE`，`existing_equivalents: []`，理由原文：
*"每 session 固定启动费在 lite-first 下无价值"*。

它打包退休的是三项扫描：**依赖演进提示 / 研究图景 / 僵尸 handoff 提示**。
**问题在于这个判断把它们当成「成本」，没当成「功能」。**

**实证**：full Alex 的 STEP 3.5b 每次启动检查依赖注册表，超 30 天提示"扫描数据已 N 天未更新"。
lite 没有等价物。结果 `.tad/dependencies/` 的 `last_checked` 停在 2026-07-14，
**28 天无人查看** —— 是 Alex 在设计 Phase 4 时偶然发现的，不是任何机制报出来的。
2026-08-12 实测：`grep -rl 'scan-results\|last_scan' .tad/hooks/*.sh` **无结果**
→ hook 层没有承载它；僵尸 handoff 提示同样无 SessionStart 载体。

**补法（便宜，因为都是只读检查）**：
(a) 依赖陈旧提示 → 直接进正在建的 `dependency-ops` skill，或做成 SessionStart hook；
(b) 僵尸 handoff / 研究图景 → SessionStart hook（hook 层是**平台级**的，不随 full 退役）。
**补完再谈冻结。**

### ⚠️ 新发现的范围歧义：「冻结 full」未定义清楚

`gate-protocol` 的处置是 `EXISTING`，载体是 **`gate`** skill —— 而 `/gate` **本身就列在
CLAUDE.md §2 的 full 通道命令表里**（`| /gate | Gate 1-4 |`）。

于是"冻结 full"有两种读法，后果不同：
- **只冻 `/alex` + `/blake`** → `/gate` 存活，`gate-protocol` 的载体成立，但"full"没被完全冻结
- **连 `/gate` 一起冻** → `gate-protocol` 失去载体，成为第二项损耗

**这是一个需要人裁定的范围问题，不是技术问题。** 在裁定前，"冻结 full"这句话不可执行。

### Phase 5 的交付物（待 Phase 4 落地后转成 LITE 契约）

1. 对 4 项 `DECISION_REQUIRED` 逐项裁定（判断题，非工程题）
2. 补上 `full-router-startup` 的确认损耗（至少依赖陈旧提示）
3. 裁定"冻结 full"的确切范围（是否含 `/gate`）
4. 把 CLAUDE.md §2 的缺口清单从"非穷举"改为**穷举**（依据就是这张 19 项处置表）——
   这会删掉"遇到未列出的先停下来问人"那条日常摩擦
5. 给 full 加 deprecation 提示

### 对 Phase 6/7/8 的影响

若采用**冻结**而非**删除**：双份维护的成本来自"维护"不来自"存在"，停止维护即可消除；
路由税由上列第 4 项消除。则 **Phase 6（下游迁移）与 Phase 7（burn-in）大部分作废**
（且 Phase 6 目前本就卡在 F1 上——下游收不到更新）。Phase 8 由"物理删除"降级为"冻结 + 标注"。
⚠️ 该重排**尚未经人裁定**，此处仅记录，不作为既定方向。

## Current Baseline (2026-08-09, Phase 1 measured)

- Source full surface：`.claude` 35 文件 + `.agents` 35 镜像文件。
- Full main skill body：约 322KB；Alex references 30 个。
- Registered downstream：14；可访问 12、路径失效 2。
- 可访问项目安装 full：12/12；安装 Lite：1/12。
- 下游 active `HANDOFF-*.md`：37。
- Phase 1–2 grounded base：`4116517`；交付 commit：`e05a135`；尚未 push/publish/sync。

以上是 Phase 1 的输入基线，不是永久常量；每次迁移前必须重新测量。

---

# 🛑 Epic 终止记录（2026-08-12，用户裁定）

## 一、为什么停：地基答不了要回答的问题

Epic 的地基是 Phase 1 的 inventory —— 它靠扫描命令与路由消费者生成，回答的是
**"full 能做什么"**。于是处置表里全是**动作**：`release-ops` / `dependencies` /
`tournament` / `research` / `gate-protocol` …

而 2026-08-12 逐条比对 full 与 lite 后发现，full 真正值钱的东西是：

- **规则 0 苏格拉底提问**（BLOCKING，3–5 轮）
- **Adaptive Complexity**（Alex 评估，**人裁定**流程重量）
- **Gate 1 需求清晰**
- **启动扫描**（依赖演进 / 安全公告 / 僵尸 handoff / 研究图景）

**这四样，一样都不在那 19 项里。** 因为它们不是"full 能做什么"，是**"full 逼你做什么"**。
一张清点能力的表，**结构上看不见纪律**。启动扫描唯一露头的那次，
还是以 `full-router-startup` 的身份被打包定价成"固定启动费"而退休——本 Epic 唯一的确认损耗。

**整条链因此从地基就偏了**：inventory 清点"能做什么" → 处置表按能力分类 →
Success Criteria 问"能力有没有载体" → 2026-08-12 的重构（含新增 SC0 与重定义的 Phase 5）
**仍然在问"能力"**，只是把"判断"换成了"载体"。同一个类别错误，做得更严谨而已。

## 二、被误读的前提（根因）

用户的原话是：**"你假设你现在要改一个 Alex Lite 和 Blake Lite，让他能够替换掉 Alex 和 Blake。
我只是做了一个假设，就希望你把这件事情能够想得方方面面，能够往前推。"**

**那是一个用于逼出周全思考的假设，不是一个批准。** Alex 将其当作既定目标，
据此推进了 6 个 phase、一次对外发布（v2.41.0）与一次系统级工具升级。

用户 2026-08-12 的判断：**"我现在还不着急替换，因为现在完全还没有到能够替换的地步，
因为我还是觉得很多东西被你遗漏了。"** —— 该判断已被本 Epic 自己的损耗审计证实
（第一遍只跑机械部分即查出一处确认损耗）。

⚠️ **这正是规则 0（苏格拉底提问，BLOCKING）本该拦住的失败**，而 lite 的 L1 明写
"上下文已清楚 → 不问，直接进下一步——**不问是常态不是偷懒**"，于是一次都没问。
**没有任何一条 AC 能抓到它，因为 AC 只验"做对了没有"，不验"该不该做"。**

## 三、保留什么

Phase 1–4 的交付全部保留，它们本身没有问题：
`release-runbook` 扩展（3a）、**Lite Authority Model v2**（3b，实测优于 full 的逐命令审批）、
v2.41.0 发布（3c）、`dependency-ops` skill（4）、以及 F8 查出的 F1 缺陷与 6 条已蒸馏知识。

作废的是**继续按"清点能力 → 退休 full"这个方向堆下去**。

## 四、后继方向：六条对 lite 自身的修改（不动 full 一根手指）

> 判据的转向：从"lite 有没有这个**能力**"转为"lite 有没有这个**纪律**"。
> 被削掉的三样纪律有一个共同点——**它们都在"动手之前"，都在问"该不该做"**；
> 而 lite 保留的 AC / 审查 / 门禁 / 验收，**全在问"做对了没有"**。
> **一个只问"做对了没有"的流程，可以完美地把错的东西做对。**

### A. 接回来的三样（纪律，源自 full 已验证有效的机制）

**A1. 需求澄清闸（对应 full 规则 0）**
lite 现状：L1 目标锚，≤1 问 ≤2 轮，且"不问是常态"。
改法：按**任务来源**分流，且**不得由 agent 自评跳过**——
任务来自用户的一句话 / 一个假设 / 一个模糊方向 → **必须问**；
来自已接受的契约或明确指令 → 可跳过，但须落盘跳过理由。
判据：本 session 的失败（把假设当批准）在改法下会被拦住。

**A2. 重量裁定（对应 full 的 Adaptive Complexity —— 即用户要的"旋钮"）**
lite 现状：CLAUDE.md §2.5 明写"文件数、协议密度、是否触及协议契约均不构成升级理由"——
**为了不再动不动升级到 full，把"任何东西都不能改变重量"写死了，顺手删掉了旋钮。**
改法：接回 Adaptive Complexity 的形状——**Alex 评估建议，人裁定**。
裁定对象改为"本单的验证强度（轻/重）"，不再是"走哪个通道"。
轻档：AC 即"跑一下看输出"，1 个 reviewer；重档：AC 需正负控，多视角审查。
⚠️ **权限不随档位走**——仍由每单一次的 mandate 单独管，**不与仪式共轴**
（否则 agent 可靠调档给自己放权；依据 `principles.md` 2026-08-06 AMENDED）。

**A3. 需求闸（对应 Gate 1）**
lite 现状：L0/L1 全是 Alex 自评，**无人复核**。
改法：需求理解须落盘并由人确认通过，明确其为**闸**而非征求意见。
可复用现有的"方案速写"，但要改变其性质。

### B. 减重的三样（流程，源自 2026-08-12 对审查循环的实测）

**B1. 一轮多视角审查（取代单 reviewer 串行多轮）**
实测：Phase 4 三轮共 9 个 P0，其中 **5 个是修复过程自己造的**；F8 同形。
原因（reviewer 自诊）：排查清单**靠回忆列**而非从关键词出发。
更深的结构原因：**用轮数换了视角数** —— full 是 min 2 个专家并行看同一版。
改法：L2.5 改为并行 2–3 个 reviewer，各带一个维度：
① **AC 判别力**（会不会在正确工作上误报？会不会全绿却什么也没证明？）
② **授权与边界**（mandate 六字段闭合？AC 要做的事有载体？爆炸半径与恢复诚实？）
③ **可执行性**（命令能逐字跑？前置状态那一刻存在？zsh / 跨日 / cwd 陷阱？）

**B2. 修复门禁取代复核循环**
用户观察：**"一直 review 一直 review，它相当对抗性的，会一直倾向于找问题"** ——
实测支持：Phase 4 三轮的 P0/P1/P2 分别为 4/11/6、4/8/7、1/2/5，**从无一轮返回"没问题"**。
**这个仪器没有自然终点。**
改法：修完**不再审**，改过一道**闭集门禁**（判据全部来自本 Epic 的实际失败）：
1. 成对表述都改了吗（**从关键词扫全文**，不从记忆列清单）
2. 空跑的是**修订后的整体**，不是改动的那一行
3. 新加守卫的判据**逐字取自实现**，不是取自字段名
4. 有没有把一次**响亮的失败**换成**静默的成功**
5. 机械格式字段齐全（即 L0.5 那几项）

**B3. 门禁显性化**
用户观察：**"门禁系统还是非常有效，而现在基本上门禁系统融入了流程当中，反而觉得不太好"**。
铁证：Phase 4 的契约**过了三轮对抗性审查**，仍被 Blake 的 **L0.5 机械准入闸**当场拦下
（`最终 verdict` 缺失 / `P0` 未带 `(fixed)` / AC 计数不符）——**三轮审查一个都没提**。
根因：**审查与门禁是两种不同的仪器**——
审查找**未知**问题，判据开放，**不会自己停**；门禁查**已知**失败类，判据闭合，**查完就完**。
门禁被溶进脊柱当成"又一个步骤"后，它"闭集对表"的性质就丢了。
改法：把 L0.5 / L2.25 / L3.5 / L5 从"脊柱步骤"改回**具名关卡 + 闭集判据表**。

## 五、承接的独立待办（不属于任何 Epic）

| 项 | 内容 |
|---|---|
| **F1 / 2.41.1** | 25 个存量下游跑本地旧 `tad.sh` 会被告知"已是最新"，收不到修复。交付物是**"如何让他们改用 curl"**，不是 patch release |
| 残留登记 19 项 | 见上方「残留登记」节，随本 Epic 终止一并移交，不得丢失 |
| 能力处置表 | `capability-disposition.yaml` 的 19 项判断保留为参考资料；**但不再作为任何目标的判据** |
