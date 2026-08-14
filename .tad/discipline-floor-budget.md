# discipline-floor 预算表（P7 S0 产出）

**Handoff**: `HANDOFF-20260818-lazy-by-floor.md`（rev5）｜**T0**: `08043c4`
**计算器**: `budget.sh`（冻结，AC12 守哈希）｜机械输出：`.tad/evidence/acceptance-tests/lazy-by-floor/budget-computed.tsv`

## 结果：最小常驻集 ≈ 20,081 B ≈ 5K tokens（下限）

| 项 | 载体 | 行区间 | 字节 |
|---|---|---|---|
| 需求澄清 | `.tad/config-workflow.yaml` | 457-604 | 4,238 |
| 启动扫描 | `.claude/skills/alex/SKILL.md` | 229-326 | 8,465 |
| 角色分离 | `AGENTS.md` | 62-66 | 145 |
| 身份与角色分离载体 | `AGENTS.md` | 16-35 | 1,358 |
| 意图路由 | `.tad/config-workflow.yaml` | 653-667 | 590 |
| 复杂度判定 | `.claude/skills/alex/SKILL.md` | 1149-1153 | 363 |
| 压缩恢复锚点 | `AGENTS.md` | 67-73 | 346 |
| 反合理化登记 | `.claude/skills/alex/SKILL.md` | 1869-1933 | 3,896 |
| Forbidden 清单本体 | `.claude/skills/alex/SKILL.md` | 1719-1732 | 680 |
| **TOTAL_RESIDENT** | | | **20,081** |

非常驻 8 项（载体在 gate/blake/blake-lite，不计入）已排除：需求闸 / 门禁 / 知识评估 / 跨模型审查 / Execution Mandate / 约束准入 / AC可执行性检查 / Friction反跳过。

## 说明

- **这是下限，不是全部**：§4.1 的 5 个非地板护栏块 + `启动扫描-研究`（约 4KB）受 AC4(a) 保护但不计入预算；29 条义务祈使句 +1,818 B 是刻意常驻成本（契约 §10.1）。
- 地板本体只占 15,935 B（≈4K tokens）；SC1 ≤15K 本单达不到——本单交付的是「能不能安全地搬」这个能力。
- 预算对 T0 复跑 REPRODUCIBLE：`budget.sh` RESULT=PASS，与 Alex 的 T0 实测（20,081 B）逐字节一致。
