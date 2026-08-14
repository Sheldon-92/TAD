# HANDOFF: 按地板表懒加载 —— 可达性记录取代计数，实测定目标

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P7 / 5，**最后一刀，最高危**）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-18
**Rev**: **rev2** —— Gate 2 两专家，**9 个 P0**，两人独立收敛到同一条根因
**配套**（均 commit，AC12 守其哈希）：`*.step0.sh` · `*.budget.sh` · `*.measure.sh`

## 1. 根因与总修法

**本单唯一的操作是搬家，而搬家恰好是「逐类计数不变」永远抓不到的那一类改动。**
两位审查员各自构造反例：算新文件 → 任意搬家零代价全绿（含把 AR-001 的
`forbidden_implementations` 锚点搬到永不触发的 `load_when` 后面）；不算 → 任意搬家都红。

**总修法：计数降级为烟感，承重换成「逐条可达性记录」**——
每一条被搬走的约束行，落盘一条 `约束行 ⇥ 新载体 ⇥ load_when ⇥ 该触发事件在常驻层的哪一行被独立知晓`。
依据：`principles.md`「Rewiring a Gate's Prose Can Trip a `grep -c` SAFETY Count」
（count 是烟感、line-SET diff 才是地面真相）+「Circular Trigger Test」。

## 2. 阶段 0 先修两个存量缺陷（否则本单跑不动）

| 缺陷 | 实测 | 处置 |
|---|---|---|
| **`config-cognitive` 绑定了但不加载** | `config.yaml:101` 给 `tad-alex` 绑 5 模块含 cognitive；`alex/SKILL.md` STEP 3 只加载 4 个且不含它 → **研究先行 / 技术决策透明 / 致命操作强制人审 三条纪律对 Alex 今天是暗的** | STEP 3 补齐为 5 个（**只修不搬**，本阶段不降级任何模块） |
| **地板表已被 P3 改过时** | `启动扫描` 的锚点全仓只存在于 `discipline-floor.md` 自己（P3 已把该行改成命令输出） | 按 P3 后的实际载体刷新该行锚点；**其余行逐字不动** |

⚠️ rev1 §4 写「不动地板表」→ 与上表第二条**死锁**，rev2 解除该限制，但**仅限刷新过时锚点**。

## 3. 阶段划分（同一风险类别一刀，阶段间可定位）

| 阶段 | 内容 | 备注 |
|---|---|---|
| **S0** | 修上述两缺陷 + 跑 `budget.sh` 产出最小常驻集预算表 | **预算即新 SC1**，不设"超了就 STOP"的门槛 |
| **S1** | `config-workflow.yaml` 中**命令可表达触发**的段外置 | ⚠️ **不做"按意图加载 config 模块"**——binding 键是命令名，表达不了"架构决策出现"这类事件触发（Gate 2 实测）。只搬 `playground`（已废弃）/`pair_testing`/`scenarios` 这类**有命令名的**段 |
| **S2** | `principles.md` 改索引 | 索引须含**标题 + 判据句**；带 `AMENDED` 的条目其判据句逐字进索引 |
| **S3** | `alex/SKILL.md` 内联模式专属块外置 + 34 个存量存根压缩 | 存量存根压缩**也受可达性约束**（压缩 `load_when` 是把非循环压成循环的最省事路径） |

**每阶段结束**：commit + 跑 `measure.sh` + 落盘可达性记录 + 跑逐类计数（烟感）。

## 4. 不可动清单

`.tad/discipline-floor.md` 判 **Layer 0 的 11 条**，副表 6 项，**外加唯一一条
`不可降级=是` 的「版本发布管理」**（Layer 1，载体 `config-execution.yaml`）——
⚠️ rev1 漏了它，而它正是原 S1 要降级的模块之一。**`release_management:` 段不参与任何外置。**

⚠️ 17 项中 **11 项的载体在 `gate`/`blake`/`blake-lite`/`AGENTS.md`**，**本单不动这些文件**
→ 它们的护栏是"逐字未变"，不是"在常驻层可 grep"（见 AC3）。

## 5. 不做

❌ 不做 config 模块级"按意图加载"（§3 S1 已说明前提不成立）｜
❌ 不动 `blake`/`gate`/`blake-lite`/`AGENTS.md`｜❌ 不动 `config-execution.yaml` 的 `release_management:`｜
❌ 不删任何一条纪律的内容｜❌ 不改地板表除过时锚点外的任何格｜❌ 不发布

## 6. 写权限（编号即全集；git 只允许只读子命令）

1. `.tad/discipline-floor.md`（**仅刷新过时锚点**）｜2. `.tad/discipline-floor-budget.md`（新建）｜
3. `.tad/config.yaml` · `.tad/config-workflow.yaml`｜4. `CLAUDE.md`｜
5. `.tad/project-knowledge/principles.md` + 同目录索引｜6. `.claude/skills/alex/**` · `.agents/skills/alex/**`｜
7. `.tad/evidence/acceptance-tests/lazy-by-floor/`｜8. `.tad/archive/handoffs/COMPLETION-20260818-lazy-by-floor.md`

## 7. Acceptance Criteria

**「红」= `exit ≠ 0` 且末行 `RESULT=FAIL`。**
⚠️ **AC 分两类，负控方向相反**（Gate 2 P2 发现：rev1 的负控只筛"永真"，放行了"永假"）：
**不变量类**（AC3/AC4/AC5/AC9）在未实现态**必须绿**；**完成度类**（AC1/AC2/AC6/AC7/AC8）**必须红**。
**任一 AC 方向不符 → 停下退回 Alex。**

| # | AC | 类 |
|---|---|---|
| AC1 | **预算表**：`discipline-floor-budget.md` 与 `budget.sh` 产出的 `budget-computed.tsv` **逐行 `diff` 零输出**。⚠️ 字节由脚本算，Blake 只填载体路径——rev1 让实现方自报，两种合理读法差 **300 倍**（1,171 B vs 360,369 B） | 完成度 |
| AC2 | **可达性记录（承重）**：每条被搬走的约束行一条记录，四列齐全；每条的"独立知晓点"须在**常驻层**（验证时现算，见 AC3）`grep -Fq` 命中且落盘行号。**任一条缺失或知晓点不可命中 = FAIL** | 完成度 |
| AC3 | **地板护栏，按载体分两半**：(a) 载体在 alex 常驻层的 6 项 → 用**锚点串**（地板表列 7 / 副表列 3，**不是合成的"触发串"列**）`grep -Fq` 命中；(b) 载体在 `gate`/`blake`/`blake-lite`/`AGENTS.md` 的 11 项 → `git diff --quiet ${T0} -- <载体>`。**常驻层 = 验证时现算**：`CLAUDE.md` + `AGENTS.md` + `alex/SKILL.md` 本体 + **改动后** `command_module_binding.tad-alex.modules` 实际被 STEP 3 加载的模块 + `CLAUDE.md` 的 `@import` 现值。⚠️ rev1 用"触发串"→ T0 即 **MISS 15/17**（永假）；且只查磁盘文件 → 把模块从 binding 摘掉后**串还在、纪律已不加载、AC 照绿** | 不变量 |
| AC4 | **循环触发逐条现判**：每个**新建或被修改**的 `reference:` 存根，其 `load_when` 触发词须在常驻层有独立定义点（路径+锚点+行号落盘）。⚠️ 不得引用地板表的 `循环?` 列——实测该列对 3 条 Layer 1 行是**从"既有判定"继承**而非判出（`重量裁定`/`专家审查`/`Ralph Loop自检` 触发条件为空却写"否"，而同表 Layer 0 的空值行诚实写"无法判定"）。⚠️ 存量 34 个存根压缩前后 `load_when` 逐条 diff 落盘 | 不变量 |
| AC5 | **SAFETY 双验**：12 条 `⚠️ SAFETY ENTRY` 条目，索引中须含 (a) **标题逐字**、(b) **判据句逐字**（取自条目的 `Action` 或 `AMENDED` 段，**不得从标题改写**）。且 `CLAUDE.md` 的 `@import` 须指向索引路径、**不再指向全文**（正+负双断言）。⚠️ rev1 只验标题 → 把 `safety-titles.txt` 原样复制成索引即 12/12 绿而 `principles.md` 一字未动；且「Deny-List Beats Allow-List」条已有**实测误读事故**（2026-08-06，正文在场时仍被误读，判据句只在正文） | 不变量 |
| AC6 | **测量**：`measure.sh`（冻结）跑 S0-S3 各一次，常驻集**脚本内现算**（binding 实际加载值 + `@import` 现值 + `alex/SKILL.md`），**禁止硬编码文件列表**；四次值严格下降。**任一阶段不降 → 停下退回 Alex** | 完成度 |
| AC7 | **行为回读**：每阶段 spawn fresh subagent 只喂常驻层，答 `readback-rubric.tsv` 三题；判定为**逐键 `grep -Fq` 在场**（rubric 由 step0 冻结、AC12 守哈希），不是"人看着一致"。⚠️ rev1 的基线由 Blake 读完契约后自产、且"一致"无判定规则 | 完成度 |
| AC8 | **两个存量缺陷已修**：STEP 3 加载 5 个模块含 `config-cognitive`（`grep -Fq`）；地板表 `启动扫描` 行的锚点在 `alex/SKILL.md` `grep -Fq` 命中 | 完成度 |
| AC9 | parity：`.claude/skills/alex/**` 与 `.agents/skills/alex/**` `diff -r` 零输出 | 不变量 |
| AC10 | 围栏：改动集 −(§6 八项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 | 完成度 |
| AC11 | **四份负控全红**：(a) 搬走一条约束但不写可达性记录 → AC2 拦 (b) 把某存根的 `load_when` 压成循环触发 → AC4 拦 (c) 索引只放标题不放判据句 → AC5 拦 (d) 把 `config-execution.yaml` 的 `release_management:` 外置 → AC3(b) 拦 | 完成度 |
| AC12 | **契约与三个脚本均未变**：`git diff --quiet ${T0} -- <四文件>`。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex** | 不变量 |

## 8. 环境约束（本机实测）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`；`for f in $VAR` 在 zsh 下**只迭代 1 次** → 显式列出；
**中文文案里的变量必须写 `${VAR}`**；分隔符一律 TAB；脚本装 `trap … EXIT` + `DONE=1`；
⚠️ **`cat dir/*.md` 不递归**（子目录内容看不见）→ 一律 `find <dir> -name '*.md'`。

## 9. Step 0

运行 `*.step0.sh`：冻结 `discipline-baseline.txt`（六类，烟感用）·`floor-anchors.tsv`（17 项**锚点串**）·
`safety-entries.tsv`（12 条：标题 ⇥ 判据句）·`readback-rubric.tsv`（三题的必含键）·
`stub-loadwhen-base.tsv`（34 个存量存根的 `load_when` 原文）·`fence-baseline.txt`。
`budget.sh` / `measure.sh` 另行提供，均受 AC12 哈希保护。

**逐条 AC 按 §7 的类别跑方向负控**：不变量类 T0 必绿、完成度类 T0 必红，任一不符 → 停下退回 Alex。

## 10. 已知取舍

1. **不做 config 模块级按意图加载**（前提不成立），故本单省下的远少于原估。
   **新 SC1 由 AC1 的预算表实测决定，本单不预设数字**。
2. **只做 alex 侧**；`blake` 121KB / `gate` 53KB 未动，对称改动待真活验证后另开单
   ——v2.7 正是同时改多处导致无法定位。
3. **可达性记录的"独立知晓点"由 Blake 判定**，AC2 只验它可 grep 命中，
   **验不了它是否真的会让 agent 想起去读**——那要到真活里才被证伪。明写。
