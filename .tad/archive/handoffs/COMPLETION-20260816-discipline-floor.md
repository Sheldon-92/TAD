# COMPLETION — 地板表（30 条纪律的载体该常驻还是按需）

**Handoff**: `HANDOFF-20260816-discipline-floor.md`（rev2）
**Blake**: 2026-08-16
**T0**: `bc35f8f`（Step 0 冻结，`$EV/t0.txt`）
**Evidence**: `.tad/evidence/acceptance-tests/discipline-floor/`

## 交付物（§6 写权限 1）

`.tad/discipline-floor.md`：主表 30 行（12 列）+ 副表 6 行 + `## Layer 0 实测` 汇总 + `## 清单缺口` + `## 承接单`。

## Layer 判定结果（§2 规则）

| 组 | 条数 | Layer |
|---|---|---|
| 地板（7） | 需求澄清/需求闸/门禁/启动扫描/角色分离/AC可执行性检查/Friction反跳过 | 0 |
| 可缩放（3） | 重量裁定/专家审查（多视角）/Ralph Loop自检 | 1 |
| 待判·循环（2） | 知识评估/约束准入 | 0（待判默认） |
| 待判·无法判定（2） | 跨模型审查/Execution Mandate | 0（待判默认） |
| 待判·非循环（16） | 其余 | 1（循环触发实测，各给独立知晓点） |

**Layer 0 实测**：full 9 行 756B ｜ lite 8 行 632B ｜ both 6 行 535B ｜ 副表 6 行 415B ｜ 载体整读 404,993B。
口径警告逐字在文；lite 不计入 SC1。**不设字节预算**（§1，本单只测量）。

## AC 结果（verify-final，exit=0，RESULT=PASS）

AC1-AC14 全绿。要点：
- AC4（rev1 最大缺口）：30 条锚点全部判别词命中 + 载体 verbatim + ≥12B
- AC15：三对抗表全红——(a)「27 行 0 + 3 可缩放行 1」合法表（30 个不同无关强制行锚点，rev1 攻击形状）**AC4+AC6 双拦**；(b) 全 Layer2 → AC3；(c) 全 MUST → AC5
- AC12：契约/step0.sh/keys30 三文件 vs T0 零 diff
- 承接单：Blake 当场实测 **504/6743 = 7.47%（路径口径）、4990/6743 = 74.0%（内容口径）**——与 Alex 给的 86%/4557 不同（两位审查员各测出 4557/5239 与 4754/6155，分母口径未定；本单钉死口径：分母 = `git ls-files` 全量 6743、分子 = 文件级命中，命令可复算）

## Layer 2（Gate 3）

- **spec-compliance-reviewer**: 13/13 独立复算，0 P0 / 1 P1 / 6 P2。P1-1（AC3 awk `$l`/`$b` 字段引用 bug → 错误路径崩溃致假绿）已修；P2 已修 3 项（承接单"无消费方"表述失实、锚点断词截断、CLAUDE.md:50 归属表述），其余记录。
- **code-reviewer**: 0 P0 / 3 P1 / 8 P2。P1 全部处置：
  - **AC14 只验 1/5 行 + carrier 双计口径**：已修——五行全比 + carrier 改 union 口径（与生成器一致）
  - **负控隔离未达成**：已重构——mkfix 从真实产物（全绿基准）构建并单维度变异，AC2/AC3/AC4/AC5/AC9/AC10/AC11 各分支回归均可单独检出；AC15a 锚点多样化（rev1 攻击形状：30 个不同无关强制行）
  - P2 已修：AC11 承接单名检查、AC8 token 限定副表区、死代码清理
- **AC13 围栏登记**：`.tad/active/epics/EPIC-20260813-alex-blake-lightening.md` 为 Alex 交单（bc35f8f）后并行编辑（P7 状态行修正），非本单改动——登记入 fence-baseline（P2a 同型先例），登记文 `$EV/fence-registration.md`。

## Friction Status

| 项 | 状态 | 处置 |
|---|---|---|
| 锚点以 `-` 开头被 grep 当选项 | **RESOLVED** | 全部 `grep -Fq -e` / `grep -iEq -e` |
| AC3 awk 消息字段引用（`$l`） | **RESOLVED** | 改变量值（Layer 2 抓到，原为假绿路径） |
| 主表行与节标题混计 | **RESOLVED** | 统一 `MR` 提取（NF≥12 且非 #/|/表头） |
| AC14 if 逻辑倒置 | **RESOLVED** | 修复（P2a 同款陷阱复发） |
| 表头行被 python 读取当数据 | **RESOLVED** | `p[0] != "纪律"` 过滤 |
| BLOCKED 项 | 无 | — |

## 未做（按契约 §5）

- 不改 inventory 任何一列｜不实施 Layer 迁移（P3/P4/P7）｜不改 expert-criteria.yaml 或任何 skill/config/hook/代码｜不设不判字节预算｜不发布

## 遗留 Follow-ups（人域）

1. Gate 4（Alex 独立复算）→ 由人决定 commit/push（P1a/P2a 未推送 commit 同批处理）。
2. **承接单 `expert-criteria-wiring`**：security 触发判定改为可执行脚本并按内容扫描，或显式声明降级为手工检查（证据：路径 7.47% vs 内容 74.0% 差一个数量级）。
3. P2 观察项（Gate 4 可议）：AC15a 对抗强度上限（keys30 含纪律名本身的弱对抗）、锚点"最短"不可机械验证（§9.2 已知取舍）。

---

## Gate 4 验收记录（Alex，2026-08-16）—— **PASS**

**独立重算，非纸面。** Alex 自行重跑验证脚本：`exit=0`、末行 `RESULT=PASS`、AC1–AC14 全绿。
三个冻结输入（契约 / `step0.sh` / `keys30.tsv`）相对 T0 `git diff --quiet` **均未变**
——git 作外部载体连续第二单守住。

### 本单的产出：两个都不在预期内的数

**一、纪律本身几乎不占常驻成本。**

| | 行数 | 触发串合计 |
|---|---|---|
| full 激活 | 9 | 756 B |
| 共有 both | 6 | 535 B |
| 副表（非纪律常驻物） | 6 | 415 B |
| **full 路径实际常驻** | **21** | **1,706 B ≈ 0.4K tokens** |
| lite（已冻结，默认路径不付） | 8 | 632 B |
| **这些触发串所在载体文件当前整读** | | **404,993 B ≈ 101K tokens** |

**即：30 条纪律要一直在场，只需 1.7KB。而实测激活即付 107.7K 里，约 101K 是这些
载体文件被整读进来的。** 目标不是被纪律挡住的，是被"整读"挡住的——而那正是 P3/P7 要拆的。

**二、Layer 分布 11 / 19 / 0**——19 行判 Layer 1，**Layer 2 一行都没有**。

⚠️ 且只有 **4 行**落到 `待判默认`，**16 行**由 `循环触发实测` 真判（rev1 原本要让 20 条全默认 0）。
Gate 2 审查员那条"inventory 的触发条件列就是 load_when、这半个答案已付过钱"完全成立：
它把常驻行数从 27 压到 11，**且每一行都有可追的依据**（定档依据列可区分"测过的 0"与"默认的 0"）。

### ⚠️ Alex 侧的一处流程污染

围栏复查发现 `.tad/active/epics/EPIC-20260813-alex-blake-lightening.md` 落在允许集之外
——**这是 Alex 在 Blake 执行窗口内改的**（phase 合并，commit `8ba0310`），不是 Blake 越权。
教训：**Blake 的围栏基线冻结之后，Alex 不应再改被追踪文件**，否则围栏残留归属不清。

### 业务验收

产物可用作 P3/P7 的判断依据：Layer 列有值、定档依据可区分证据来源、载体可 grep、
`## 清单缺口` 与 `## 承接单` 两节齐备且未抄 Alex 给的不可复现数字。

**未提交、未推送。**
