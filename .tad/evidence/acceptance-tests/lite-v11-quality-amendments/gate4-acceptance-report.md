# Gate 4 Acceptance Report — TAD Lite v1.1 质量修订

**Date**: 2026-07-30
**Handoff**: HANDOFF-20260730-lite-v11-quality-amendments.md (v3)
**Verdict**: **PASS** — ACCEPTED

## AC1–AC16：Alex 独立原始重算（不信 Blake 摘要）

16/16 PASS，与 Blake 报告零偏差。要点：哨兵块 4 文件 + `git show 065c19a` 基线五方 md5 = `dfce636b4b0fde62d3d3a446e384067e`；CLAUDE.md 恰 1+/1-；镜像 cmp ×2 exit 0；行数 116/140（预算 150/170）；gate-design.md AMENDED 落在目标条目区间内且 diff 仅 append。Gate 3 证据文件核实真实存在（spec-compliance 16/16 + code-review P0=0/P1=0/P2=2）。

## AC17 行为 dogfood：DEGRADED_WITH_APPROVAL，PASS

原设计为用户新开会话亲测；用户拍板委托（原话："你自己完成吧"）。改造为两个干净上下文行为探针 + 真实 spawn 链路，各核验点：

| 检查点 | 结果 | 证据 |
|---|---|---|
| ① L1 目标锚问题出现 | ✅ | 探针 A trace 逐字引用（"为什么现在做…成功长什么样"） |
| ② 落盘前方案速写 | ✅ | 4 行速写（做法/为什么/备选 A/B 及不选理由）先于 Write |
| ③ L2.5 真实 spawn（反内化核心） | ✅ | reviewer 为真实独立 agent（独立 transcript，7 次工具调用含实地只读核验）；其完成通知独立投递到主会话 = spawn 不可伪造的旁证 |
| ④ Contract Review 段完整 | ✅ | Reviewer 机制 / 首轮 CONDITIONAL 与最终 PASS 各占独立行 / P0=0, P1=0(1 fixed), P2=3 / 已审 AC 条数: 3 / 逐字摘录 |
| ⑤ 负控：blake-lite 拒绝无审查契约 | ✅ | 探针 B 真跑 L0/L0.5 机械检查，命中"缺段"分支硬停，零实现零写入，状态词 DESIGN PASS / BUILD NOT STARTED |
| 顺序性 | ✅ | L0-pre→L0→L1→L2(检查→速写→落盘)→L2.5(spawn→修 P1→增量复核)→停 L3，无跳步无颠倒 |

**超预期信号**：L2.5 在玩具契约上抓到真 P1（AC2 `grep -c .` 无法检出空行填充的多行违规，与"不做什么"冲突；reviewer 以 6 种输入管道实测证明，修复为 `grep -c ''` 后复测正确 FAIL）——证明契约审查在最小任务上也非 theater。reviewer 并正确运用人域/AI 域划分（P2-2 路径归属判为人域选择题，非验证题）。

**证伪条件未触发**：L2.5 未被内化为自审（探针 A 无法伪造独立 transcript 与跨 agent 通知投递）。

**残余风险（如实记录）**：探针环境 ≈ 真实 fresh session 但非等同（canned 人答、探针规则约束）；**真正的现场验证 = 下游项目首次真实使用 v1.1 lite**，已作为 carry-to-first-real-use 观察项。

## Gate 4 期间新发现（非阻塞，留观）

- P2：L2 模板预置 `{待填}` Contract Review 段 → 会话死在 L2/L2.5 之间时恢复逻辑误判"已有该段"跳 L3；blake L0.5 的"已审 AC 条数==机械计数"接住（占位符≠数字→停退回），fail-closed 成立，代价一次弹回。留观，若真实触发再修恢复判据（改为"最终 verdict 非待填"）。

## Knowledge Assessment（规则 5）

- 无新增 L1/L2 条目。本单实例强化既有模式：round-2 抓修复缺陷（第 3 次证实，gate-design 既有）、AC 负向 grep 与相邻修订措辞相撞（ND-1，ac-verification 自泄漏类既有）。
- 实质知识变更已由交付物本身承载：gate-design.md "Independent Perspective" 条目 AMENDED（设计期审查≠cheap-rework insurance 的证伪记录）。

## 探针产物处置

- 探针 A 契约 `LITE-20260730-1606-tmp-dogfood.md`：验收后删除（AC17⑥）
- 负控假契约（scratchpad）：删除
- `.tad/evidence/tmp-dogfood.md`：从未创建（探针 A 正确停在 L3，未越权实现——本身即角色分离的行为证据）
