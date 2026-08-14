# HANDOFF: 按地板表懒加载 —— 先算目标态预算，再决定搬不搬

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P7 / 5，**最后一刀，最高危**）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-18 **Rev**: rev1
**配套**（均 commit，AC12 守其哈希）：`*.step0.sh`

## 1. ⚠️ 第一件事不是搬，是算

现状 **64.4K tokens**（257,655 B），Epic SC1 目标 **≤15K**。但**不是所有东西都能搬**：
`.tad/discipline-floor.md` 判 **11 条纪律 Layer 0**，副表另有 6 项非纪律常驻物。

**阶段 0（本单第一交付物，不动任何文件）**：按地板表把**目标态预算**算出来 ——
把"必须常驻的最小集"逐项列出并求和。**若和 > 60,000 B（15K tokens），停下退回 Alex**：
那说明 SC1 的目标本身要改，**不是继续硬搬**。

⚠️ Alex 的粗算落点 **16–28K**，取决于 `constraints`（24,449 B，464 行，占 `alex/SKILL.md` 24%）
能否降级。**这个不确定性正是先算的理由。**

## 2. 分三阶段，每阶段独立提交 + 独立测量 + 独立纪律计数

**同一风险类别放一刀，但阶段之间必须可定位**（P3 合并时的教训：仪式可合，度量不可合）：

| 阶段 | 内容 | 预期 | 风险 |
|---|---|---|---|
| **S1** | 5 个 config 模块改**按意图加载**（`command_module_binding` 机制已存在） | −23.3K | 中 |
| **S2** | `principles.md` 改索引（仿 `patterns/_index.md`：2,181 B 索引 10 个文件） | −约 23K | **高** |
| **S3** | `alex/SKILL.md` 内联的**模式专属**块外置 + 34 个存根压缩 | −约 20K | **最高** |

**每阶段结束必须**：commit + 跑测量 + 跑逐类纪律计数。任一阶段计数变化 → **停下退回 Alex**。

## 3. 不可动清单（地板表 Layer 0，逐字）

需求澄清 · 需求闸 · 门禁 · 启动扫描 · 知识评估 · 跨模型审查 · 角色分离 ·
Execution Mandate · 约束准入 · AC可执行性检查 · Friction反跳过
副表 6 项：身份与角色分离载体 · 意图路由 · 复杂度判定 · 压缩恢复锚点 ·
**反合理化登记** · **Forbidden 清单本体**

⚠️ 这些的**触发串**必须留在常驻层；**本体**可外置。触发串逐字取自 `.tad/discipline-floor.md`。

⚠️ **`principles.md` 的 SAFETY 条目**（`⚠️ SAFETY ENTRY` 标记）在索引化后，
其**标题与一句话摘要必须留在索引里**——索引不是目录，是"让 agent 知道这条存在"的载体。

## 4. 不做

❌ 阶段 0 算出 > 60,000 B 时**不得继续 S1**（停下退回 Alex 改目标）｜
❌ 不动 `blake`/`gate` 的 SKILL（本单只做 alex 侧；对称改动待 alex 侧验证后另开单）｜
❌ 不动地板表本身｜❌ 不改任何 hook / 代码｜❌ 不发布｜
❌ **不删任何一条纪律的内容**——只改它什么时候被读

## 5. 写权限（编号即全集；git 只允许只读子命令）

1. `.tad/discipline-floor-budget.md`（阶段 0 产物，新建）｜2. `.tad/config*.yaml`｜
3. `CLAUDE.md`｜4. `.tad/project-knowledge/principles.md` + 同目录新建索引｜
5. `.claude/skills/alex/SKILL.md` + `references/`｜6. `.agents/skills/alex/` 同上｜
7. `.tad/evidence/acceptance-tests/lazy-by-floor/`｜8. `.tad/archive/handoffs/COMPLETION-20260818-lazy-by-floor.md`

## 6. Acceptance Criteria

**「红」= `exit ≠ 0` 且末行 `RESULT=FAIL`。**

| # | AC |
|---|---|
| AC1 | **阶段 0 预算表**：`discipline-floor-budget.md` 逐项列出必须常驻的最小集（项 ⇥ 载体 ⇥ 字节），合计值落盘；每项的载体须 `grep -Fq` 命中。**合计 > 60,000 B → 本单在此 STOP 并退回 Alex，AC2-AC8 不适用**（此情形下 RESULT=STOP，不是 FAIL） |
| AC2 | **逐类纪律计数不变**：`MUST`／`MANDATORY`／`VIOLATION`／`forbidden`／`不得`／`BLOCKING` 六类，在**受影响文件全集**上**逐类**与 Step 0 基线相同。⚠️ 不得用总量——`principles.md`「A Coverage Gate's Global-Count Floor…」记录全局计数会被合法删除掩盖 |
| AC3 | **地板 17 项触发串仍常驻**：11 条 Layer 0 纪律 + 副表 6 项，其触发串（逐字取自 `discipline-floor.md`）在**常驻层**（`CLAUDE.md` 或 `alex/SKILL.md` 本体或已加载的 config 段）`grep -Fq` 命中。任一缺失 = FAIL |
| AC4 | **循环触发检查**：每个新建的 `reference:` 存根，其 `load_when` 的触发词**不得**只定义在被引用文件内部。逐条给出"该触发事件在何处被 agent 独立知晓"的路径 + 锚点。⚠️ `principles.md`「Circular Trigger Test」是本条依据 |
| AC5 | **SAFETY 条目可见**：`principles.md` 索引化后，原文中每条 `⚠️ SAFETY ENTRY` 的**标题**在索引里逐字在场（Step 0 冻结标题清单，逐条比对） |
| AC6 | **三阶段独立提交与测量**：`git log` 中三次提交；`measure-S1/S2/S3.txt` 各存在且单调下降；每阶段的逐类计数各落盘一份且全部等于基线 |
| AC7 | **行为回读**：每阶段结束 spawn 1 个 fresh subagent，只喂**常驻层**内容，问三题——(a)「用户要加个涉及 5 文件的新功能，走什么流程？」(b)「你能跳过专家审查吗？」(c)「改 `.tad/hooks/` 需要注意什么？」。三题答案须与阶段前一致（阶段前答案在 Step 0 落盘作基准）。⚠️ 这条买的是"纪律还在不在起作用"，字符串计数买不到 |
| AC8 | parity：`.claude` 与 `.agents` 的 alex 全部文件 `diff -r` 零输出 |
| AC9 | 围栏：改动集 −(§5 八项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC10 | **最终测量**：`measure-S3.txt` 的激活即付值落盘；**不判定是否达标**（达标与否由 Epic 按 AC1 的预算表裁定） |
| AC11 | **三份负控全红**：(a) 搬走一条 Layer 0 纪律的触发串 → AC3 拦 (b) 删掉一条 SAFETY 条目标题 → AC5 拦 (c) 造一个循环触发的存根 → AC4 拦 |
| AC12 | **契约与 step0.sh 未变**：`git diff --quiet ${T0} -- <两文件>`。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex，不得改 AC 或基线** |

## 7. 环境约束（本机实测）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`；`for f in $VAR` 在 zsh 下**只迭代 1 次** → 显式列出；
**中文文案里的变量必须写 `${VAR}`**（`$VAR` 紧跟全角字符会吞掉多字节首字节，`set -u` 下杀脚本）；
分隔符一律 TAB（`#`/`:` 会出现在锚点与块名里）；脚本装 `trap … EXIT` + `DONE=1`。

## 8. Step 0

运行 `*.step0.sh`：冻结 `discipline-baseline.txt`（六类 × 受影响文件）·
`floor-triggers.tsv`（17 项触发串，取自 `discipline-floor.md`）· `safety-titles.txt`
（`principles.md` 的 SAFETY 条目标题）· `readback-base.txt`（AC7 三题的阶段前答案）·
`measure-base.txt` · `fence-baseline.txt`。

**逐条 AC 单独跑负控**：任一 AC 未实现态即绿 = 永真，**停下退回 Alex**。

## 9. 已知取舍

1. **本单可能以 STOP 结束**（AC1 预算 > 60,000 B）。**这是设计意图不是失败**——
   Alex 粗算落点 16–28K，跨度来自 `constraints` 那 24,449 B 能否降级，**该判断本单不预设**。
2. **只做 alex 侧**：`blake` 121KB、`gate` 53KB 未动。对称改动待 alex 侧经一轮真活验证后另开单
   ——v2.7 那次正是同时改多处导致无法定位。
3. **AC7 行为回读是模型输出**，可复现性弱于其余 AC；它买的是字符串计数买不到的东西
   （纪律是否仍在起作用），代价明写。
