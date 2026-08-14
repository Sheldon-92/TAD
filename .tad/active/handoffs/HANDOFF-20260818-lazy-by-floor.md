# HANDOFF: 按地板表懒加载 —— 可达性记录取代计数，实测定目标

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P7 / 5，**最后一刀，最高危**）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-18
**Rev**: **rev4** —— Gate 2 三轮共 **23 个 P0**；rev3 把承重从"搬家"移到**约束语义分类**，
rev4 修完三个配套脚本（块边界 / 模块集 / AC3 分母）并按实测收紧 AC2、AC4
**配套**（均 commit，AC12 守其哈希）：`*.step0.sh` · `*.budget.sh` · `*.measure.sh` ·
`*.obligations.tsv` · `*.blocks.tsv`（块边界，Alex 逐项人工确认）

## 1. 根因：承重放错了位置（rev2 的致命缺陷）

rev2 把承重押在"**被搬走的约束行**"上。审查员实测出**一条更便宜、不搬任何约束、12 条 AC 全绿的降级路径**：
把 STEP 3 那行里的模块名**换一个**（正是 AC8 要 Blake 改的那行）→ 一次编辑 **−18,101 B**，
而 `config-quality` 承载的 4 条纪律**当场变暗**。同理 `config-agents` + `config-platform`
承载 0 项地板 → **48,277 B（18.9%）可自由摘除，无任何 AC 覆盖**。

**这就是 v2.7 的同构**：不是"删了约束"，是"**删了加载约束的那一行**"。

### 更根本的一条（三组 fresh agent 实测）

审查员把 `NOT_via_alex_auto` 搬走、只留合规的可达性记录 → agent **确实主动去读了 reference**。
**但那是最容易过的测试对象**：它属于「**禁止型**」——忘掉整个话题 = 天然满足禁令，失败方向安全。

危险的是「**义务型**」（专家审查 min 2 / 研究先行 / 致命操作人审 / KA）：**忘了 = 跳过 = v2.7**。
三组实测都出现同一签名：agent 一致地**没有**加载 `references/handoff-creation-protocol.md`，
且发现文件不存在时**降级继续、不报错、不阻塞**。

**机械佐证**：`alex/references/**` 现有 83 条强制行，**82 条（99%）在常驻层无重复副本**；
9 条 `forbidden` 中 8 条靠 `CLAUDE.md` 的重复侥幸安全，唯一没重复的那条**一外置即失效**。
→ **今天守住纪律的是"重复"，不是可达性机制。**

## 2. 总修法：按语义分类，义务型必须留祈使句

配套 `*.obligations.tsv`（30 行，Alex 分类，Step 0 冻结）：

| 类 | 判据 | 处置 | 条数 |
|---|---|---|---|
| **禁止型** | 被禁动作**不是** agent 的默认行为 → 忘了也不会做 | 本体可外置 | **1** |
| **义务型** | 忘了 = 少做一步 | **常驻层必须留 1 行祈使句原文**（不是 `load_when` 指针），reference 只放展开 | **29** |

⚠️ 判据不是"条文写禁止还是必须"，是「**被禁的动作是不是默认行为**」：不调 codex 不是默认（禁止型）；
而"写代码"对编码 agent 就是默认，故「角色分离」虽写作禁令仍按**义务型**处理。
**保守分类几乎免费：29 条祈使句合计 1,879 B。**

## 3. 阶段划分（同一风险类别一刀，阶段间可定位）

### 3.0 两个存量缺陷的处置（rev4 定案，**Blake 都不用做**）

| 缺陷 | 处置 |
|---|---|
| 地板表 `启动扫描` 锚点被 P3 改过时（全仓只存在于地板表自己） | **Alex 已于 rev4 前修完**：锚点改为 `只跑命令读其输出，禁止整读这三处`，17 项现已全部 `grep` 命中。→ `discipline-floor.md` 因此**退出写权限清单**，回到"绝对不动"侧 |
| `command_module_binding` 列 5 个模块，`STEP 3` 正文只读 4 个 → `config-cognitive.yaml` **Alex 从不加载**，其承载的 `研究先行`/`技术决策透明`/`致命操作强制人审` 三条纪律已暗 | **移出本单，另开单**。理由：修它是**加载量 +N**，与本单方向相反，混进最高危一刀会破坏"同一风险类别一刀"的可定位性；且它与"82/83 条强制行无常驻副本"是同一病（约束够不着 agent），应一起治。本单只保证**不让它变差**（AC2）并**每次 measure 都把已暗模块打印出来** |

| 阶段 | 内容 | 备注 |
|---|---|---|
| **S0** | 跑 `step0.sh` 冻结基线 + 跑 `budget.sh` 产出最小常驻集预算表 | **预算即新 SC1**，不设"超了就 STOP"的门槛 |
| **S1** | `config-workflow.yaml` 中**命令可表达触发**的段外置 | ⚠️ **不做"按意图加载 config 模块"**——binding 键是命令名，表达不了"架构决策出现"这类事件触发（Gate 2 实测）。只搬 `playground`（已废弃）/`pair_testing`/`scenarios` 这类**有命令名的**段 |
| **S2** | `alex/SKILL.md` 内联模式专属块外置 + 34 个存量存根压缩 | 存量存根压缩**也受可达性约束**（压缩 `load_when` 是把非循环压成循环的最省事路径） |

⚠️ **原 S2（`principles.md` 索引化）已删除**：实测净省 **0**——`AGENTS.md:38` 与
`blake/SKILL.md:518` 均明写"每次角色激活必读 principles.md 全文"，而这两个文件在不许动清单里。
结局只有"照读全文（省 0 且多一份要同步的索引）"或"让纪律变成谎言"。
且其中「Deny-List Beats Allow-List」条有**正文在场时仍被误读**的实测事故（2026-08-06）。
**拿 6.76% 换这类内容的一层间接，回报率最低、风险最高。**

**每阶段结束**：commit + 跑 `measure.sh` + 落盘可达性记录 + 跑逐类计数（烟感）。

## 4. 不可动清单（改由**后果不可逆性**判定，不用自报字段）

⚠️ rev2 凭 `不可降级` 这个**自报字段**判定 → 漏了 `致命操作强制人审`（该字段填"否"，
**与它自己的 description `Risk filter for operations that could cause irreversible damage` 矛盾**）。
其本体是一张**识别表**（`rm -rf` / `DROP` / 删桶 / 打印 token·PII / 移除鉴权 / private→public / 支付逻辑），
而它的触发串**零识别内容**——表外置 = **识别能力外置**，且后果不可逆。

**不可动 = Layer 0 的 11 条 + 副表 6 项 + 以下两段（后果不可逆）**：
- `.tad/config-cognitive.yaml` 的 `fatal_operations:`
- `.tad/config-execution.yaml` 的 `release_management:`

⚠️ 17 项中 **11 项的载体在 `gate`/`blake`/`blake-lite`/`AGENTS.md`**，本单不动这些文件
→ 护栏是"逐字未变"，不是"常驻层可 grep"。

## 5. 不做

❌ 不做 config 模块级"按意图加载"（前提不成立）｜❌ **不做 `principles.md` 索引化**（净省 0，见 §3）｜
❌ 不动 `blake`/`gate`/`blake-lite`/`AGENTS.md`｜❌ 不动 `fatal_operations:` 与 `release_management:` 两段｜
❌ 不删任何一条纪律的内容｜❌ **不改地板表任何格**（过时锚点已由 Alex 修完）｜❌ 不发布

## 6. 写权限（编号即全集；git 只允许只读子命令）

1. `.tad/discipline-floor-budget.md`（新建）｜2. `.tad/config-workflow.yaml`｜
3. `.claude/skills/alex/**` · `.agents/skills/alex/**`｜
4. `.tad/evidence/acceptance-tests/lazy-by-floor/`｜5. `.tad/archive/handoffs/COMPLETION-20260818-lazy-by-floor.md`

⚠️ rev4 又移除三项：`.tad/discipline-floor.md`（过时锚点 Alex 已修完，无事可做）·
`principles.md` / `CLAUDE.md` / `config.yaml`（S2 已删、模块集只增不减，无需改它们）。
**写权限只剩 5 项，编号即全集。**

## 7. Acceptance Criteria

**「红」= `exit ≠ 0` 且末行 `RESULT=FAIL`。**
⚠️ **AC 分两类，负控方向相反**：**不变量类**（T0 必绿）/ **完成度类**（T0 必红）。
**任一 AC 方向不符 → 停下退回 Alex。**（rev1 的负控只筛"永真"，放行了两条在 T0 即红的。）

| # | AC | 类 |
|---|---|---|
| **AC1** | **义务型祈使句常驻（本单承重）**：`obligations.tsv` 中 29 条 `义务` 行的第 3 列祈使句，**逐条在常驻层 `grep -Fq` 命中**并落盘行号。任一缺失 = FAIL。⚠️ 这是 rev3 的核心：忘记义务 = 跳过 = v2.7；祈使句必须是**原文**，不是 `load_when` 指针 | 完成度 |
| **AC2** | **两个模块集各自只增不减**：`STEP 3` 正文实际加载的模块集、`command_module_binding.tad-alex.modules`，**分别**与 T0 比对，`LC_ALL=C comm -23 T0集 现集` 均须为空。任何减项须为该模块承载的**每条纪律**逐条落盘可达性记录。⚠️ **rev4 更正：不得取并集**——实测 binding(5) ⊇ 正文(4)，取并集会让"改正文里的模块名"这类攻击**完全隐形**；而正是这条攻击一次编辑 −18,101 B、4 条纪律变暗、12 条 AC 全绿 | 不变量 |
| **AC3** | **约束行集有分母**：`comm -23 constraint-lines-base.txt 现集` 的**每一行**必须在可达性记录里出现恰好 1 次，多一条少一条 = FAIL。⚠️ rev2 的"任一条缺失=FAIL"没有分母，由 Blake 自划范围 | 完成度 |
| **AC4** | **地板护栏（块级，不是单行 grep）**：(a) `blocks.tsv` 里 `常驻=是` 的 **9 项**，块边界由该文件的起/止锚串给出，逐块 **块内行集只增不减**（`LC_ALL=C comm -13` 零输出）——⚠️ 实测其锚点仅是注释行/标记行，条目全删也不影响 `grep -Fq`；(b) 载体在 `gate`/`blake`/`blake-lite` 的 8 项 → `git diff --quiet ${T0} -- <载体>`；`AGENTS.md`（另 3 项）同样 `git diff --quiet`——它既在(a)的块级保护里，也在不许动清单里，两道都要过。⚠️ 起/止锚串须 **`grep -Fx` 恰好命中 1 次**，且地板锚点必须落在块内，否则 `budget.sh` 直接 FAIL（rev2 靠 `^#{1,3} ` 猜边界 → 17 项跨度 >100×，`启动扫描` 记成 0 B） | 不变量 |
| **AC5** | **不可逆两段逐字未变**：`git diff --quiet ${T0} -- .tad/config-cognitive.yaml .tad/config-execution.yaml`。⚠️ `fatal_operations:` 的本体是**识别表**，外置 = 识别能力外置 | 不变量 |
| **AC6** | **循环触发逐条现判**：每个**新建或被修改**的 `reference:` 存根，其 `load_when` 触发词须在常驻层有独立定义点（路径+锚点+行号落盘）。存量 34 个存根压缩前后 `load_when` 逐条 diff 落盘，**键为存根名不是行号**（行号会整体位移） | 不变量 |
| **AC7** | **测量**：`measure.sh`（冻结）跑 S0/S1/S2 各一次，值严格下降。⚠️ 脚本内正文模块集为空或少于 T0 项数即 `RESULT=FAIL`；`CMD_OUTPUT` 从 SKILL **现抽命令 + 实跑取 `wc -c`**（T0 实测 5 条命令 5,859 B），抽到 0 条即 FAIL；`session-state.md` **不进分母**（会话中会变，进了则测量不可复现）。T0 实测 **262,172 B ≈ 65K tokens** | 完成度 |
| **AC8** | **行为回读（义务型专项）**：每阶段 spawn fresh subagent 只喂常驻层，三题**全部取自义务型**（Gate 2 前最少几人审 / 架构决策前必须先做什么 / 删库·打印 token 前必须做什么），判定为**未经提示自发说出** rubric 必含键。⚠️ 禁止型题目会稳定假绿 | 完成度 |
| **AC9** | parity：`.claude/skills/alex/**` 与 `.agents/skills/alex/**` `diff -r` 零输出 | 不变量 |
| **AC10** | 围栏：改动集 −(§6 **五项** ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 | 不变量 |
| **AC11** | **四份负控全红**：(a) 摘掉一个模块名 → AC2 拦 (b) 搬走一条约束不写记录 → AC3 拦 (c) 删空 `Forbidden` 块内条目但留注释锚点 → AC4(a) 拦 (d) 外置 `fatal_operations:` → AC5 拦 | 完成度 |
| **AC12** | **契约与五个配套文件均未变**：`git diff --quiet ${T0} -- <六文件>`（含 `blocks.tsv`：块边界是 Alex 的人工判断，Blake 改它等于自划护栏范围）。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex** | 不变量 |

## 8. 环境约束（本机实测）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`；`for f in $VAR` 在 zsh 下**只迭代 1 次** → 显式列出；
**中文文案里的变量必须写 `${VAR}`**；分隔符一律 TAB；脚本装 `trap … EXIT` + `DONE=1`；
⚠️ **`cat dir/*.md` 不递归** → 一律 `find <dir> -name '*.md'`。

## 9. Step 0

运行 `*.step0.sh`，冻结：`obligations.tsv` 校验（30 行 / 29 义务 / 1 禁止，名称与地板表逐字相等）·
`blocks.tsv` 覆盖校验（17 项齐全，常驻 9 项必有起锚串）·
`constraint-lines-base.txt`（**AC3 的分母**：`alex/SKILL.md` + `config-workflow.yaml` 的约束行文本集，
`LC_ALL=C sort -u`，T0 实测 **57 行**）·`module-set-base.txt`（AC2 的 T0 模块集，**正文 4 / binding 5 分开记**）·
`floor-anchors.tsv`（17）·`stub-loadwhen-base.tsv`（**键 = `reference:` 路径，不是行号**，T0 实测 34）·
`obligations-t0.tsv`（29 条祈使句在常驻层的 T0 命中数——AC1 是完成度类，T0 应大量为 0）·
`readback-rubric.tsv`（三题**义务型**必含键）·`discipline-baseline.txt`（六类，烟感）·`fence-baseline.txt`。

**T0 实测**（Alex 已跑通，Blake 复跑应得同值）：`step0.sh` PASS ·
`budget.sh` = **常驻 9 项 15,935 B ≈ 4K tokens**（非常驻 8 项已排除）· `measure.sh base` = **262,172 B ≈ 65K tokens**。

**逐条 AC 按 §7 类别跑方向负控**：不变量类 T0 必绿、完成度类 T0 必红，任一不符 → 停下退回 Alex。

## 10. 已知取舍

1. **保守分类的代价**：29/30 判义务型，各留一行祈使句 = 1,879 B 常驻。**这是刻意的**
   ——判据是"被禁动作是否为默认行为"，存疑一律按义务型。
2. **只做 alex 侧**；`blake` 121KB / `gate` 53KB 未动（v2.7 正是同时改多处导致无法定位）。
3. **AC8 是模型输出**，可复现性弱于其余 AC；它买的是"义务是否仍会被自发说出"，字符串计数买不到。
4. ⚠️ **存量发现（不在本单范围）**：`alex/references/**` 现有 83 条强制行中 **82 条在常驻层无重复副本**
   ——**今天守住纪律的是重复不是可达性**。本单只保证不让这个数变差，**修它另开单**。
   §3.0 的 `config-cognitive` 从不加载（3 条纪律已暗）与此同病，**同一张单一起治**。
5. ⚠️ **SC1 ≤15K tokens 本单达不到，且这不是本单的锅**：地板本体只占 15,935 B（≈4K tokens），
   剩下 246K B 全在"可搬但要搬得安全"的区间。S1+S2 的可搬量远小于 200K B。
   **本单交付的是"能不能安全地搬"这个能力，不是 15K 这个数**；SC1 的收口留给后续单。
