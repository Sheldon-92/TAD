# DR-20260712: Native Capability Overlap — 裁决(退役/改造/保留)

**Date**: 2026-07-12
**Mode**: *discuss(裁决讨论,研究与裁决刻意分离——先事实后判断,防结论污染证据)
**Decided by**: Human(Alex 提供选项 + 取舍分析;方向判断属人域)
**Evidence base**: `.tad/evidence/research/claude-native-capabilities/2026-07-12-overlap-matrix.md`(23 源 notebook b07a6598 + 5 seed ask 链 + 第一方 harness 内省 + TAD 112 机制清单)
**Caveat**: 矩阵未经第二模型对抗挑战(Codex auth 过期 + Gemini 无 key,Phase 4c 双缺 auto-PASS)——实施各裁决时如遇与矩阵矛盾的事实,以实测为准并回写本 DR。

---

## 裁决 1:Memory vs Knowledge → 重定向进 TAD,native memory 降为 Capture 层

- **裁决**: 不关闭、不划车道。`autoMemoryDirectory` 重定向到 `.tad/memory/`;native auto-memory 自由写入(即时笔记 = Capture);Alex 蒸馏循环把 `.tad/memory/` 列为与 Blake journal 并列的第二原料源,陌生人锻造后进 project-knowledge(Distill);knowledge-maintain 管 Maintain。
- **Why**: 消除 system 层 vs skill 层的指令抢跑(双腿打架的机械成因),同时保留 MEMORY.md 每会话自动召回(TAD 自身没有的能力)。把对手变进水管,精确对齐 2026-06-22 知识重设计的 Capture≠Distill 原则。副产品:memory 进 repo,可 git/审计/sync。
- **实施路径**: Blake handoff(settings.json 加 autoMemoryDirectory + workspace trust 确认 + 蒸馏循环协议扩展第二源 + CLAUDE.md 说明)。**Alex 不直接改 settings(constraints deny)。**
- **风险**: autoMemoryDirectory 行为以实测为准(重定向后 MEMORY.md 索引是否仍每会话加载——矩阵证据为文档级,未实测);.gitignore 策略需定(全进 git 还是 user 型条目隔离)。

## 裁决 2:/code-review → 试点作为 Layer 2 的一票(deep-research / plan mode 禁令不变)

- **裁决**: 三禁令不再一刀切。/deep-research、EnterPlanMode 禁令**保留**(TAD 版在持久积累/结构化上占优)。/code-review **试点薄壳委托**:在下 2-3 个合适的 code handoff 中充当 distinct reviewer 之一(不是替代整条链),输出落 `.tad/evidence/reviews/` 照常,gate 契约(distinct-reviewer 规则、P0 阻断、evidence 文件)不变。试点后按质量对比定去留。
- **Why**: TAD 审查链的价值在 gate 契约而非审查引擎自建;原生引擎免费且持续调优。契约不动,引擎可换票。
- **风险**: 输出格式适配;原生 review 表面半年内已有一次合并改名(churn),薄壳厚度要够薄。

## 裁决 3:Agent Teams / 官方同构模式 → 不迁移 + 立场文档化

- **裁决**: 不把两 agent 模型迁到 native agent teams。把"官方 best-practices 已收编 TAD 工作流之形(spec-first interview / Writer-Reviewer / 对抗辩论 team / 独立 diff review),TAD 的增量是结构化契约 + gates + 蒸馏 + 人域边界(人桥是刻意设计)"写进 docs/value-proposition.md,喂 O1 定位。
- **Why**: 人桥承载人域判断和用户学习回路,是设计不是缺口;teams 表面刚经历破坏性变更(v2.1.178 移除 TeamCreate),流沙期不迁移。有界实验(低风险 Epic 用 teams 跑 vs yolo-epic 对比)保留为可选后手,不排期。

## 裁决 4:小件打包(全部按建议)

- **Pack ≤2 护栏保留**(质量护栏 vs 原生 stacking ≤5 的能力上限,不冲突不让步)。
- **采用 `disable-model-invocation: true`**:低频/手动型 pack 加此 frontmatter 减上下文税(逐 pack 甄别,归入常规维护)。
- **Agent-verifier hooks 不单独重开机械 enforcement 决定**:作为新载体证据并入 gate-ROI 测量任务(surplus 队列 item 3)的考量项,等 ROI 数据一起判(Measure Before Optimizing)。

---

## 明确不做的

- 不关闭 auto-memory;不整体迁移 Layer 2 到 /code-review;不迁移 agent teams;不现在重开 2026-04-15 机械 enforcement 决定。

## 第二轮裁决(2026-07-12 晚,矩阵剩余重叠面)

- **A1 session-state / §4.5 双层恢复**: 保留。原生压缩恢复只覆盖同会话;session-state 的跨会话/跨终端价值无替代。先跑 PreCompact hook 试点(IDEA-20260712-precompact-hook-session-state),hook 稳定后再议 §4.5 瘦身。
- **A2 /advisor 纳入对抗审查降级档**: 采纳。优先级 Codex/Gemini(跨厂商)> /advisor(同族)> auto-PASS。需修改 research 协议 UNAVAILABLE 路径(research-plan-protocol.md Phase 0c/4c/5b 的双缺分支)——今天 Phase 4c 裸奔的场景以后先降 /advisor。实施:小 handoff。
- **A3 /verify 试点**: 采纳。下个有可运行 artifact 的 handoff,Blake 验证环节加 /verify 作为补充途径之一,evidence 照落。与 /code-review 试点同批观察。
- **A4 原生任务系统 vs NEXT.md**: 零动作。分工已自然形成(会话内=原生 tasks,跨会话=NEXT.md),不写规则不加协议。
- **B 组 6 个机会**已捕获为 ideas(.tad/active/ideas/IDEA-20260712-*.md):审查员持久记忆、PreCompact hook、skills 预载、.claude/rules 试点、cron 复活周扫描、AskUserQuestion preview。执行未开始,按 *idea-promote 流程逐个来。

## 后续动作登记(见 NEXT.md)

1. Handoff:memory-redirect-capture-layer(裁决 1 实施)— 需过完整 TAD 流程
2. 试点标记:下 2-3 个 code handoff 的 Layer 2 加 native /code-review 票(裁决 2)
3. value-proposition 增补(裁决 3)— 可并入 O1 相关工作
4. Pack disable-model-invocation 甄别(裁决 4)— 常规维护
5. gate-ROI 任务考量项追加 agent-verifier hooks(裁决 4)
