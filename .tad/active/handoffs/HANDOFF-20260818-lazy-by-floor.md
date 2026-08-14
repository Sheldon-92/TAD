# HANDOFF: 按地板表懒加载 —— 可达性记录取代计数，实测定目标

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P7 / 5，**最后一刀，最高危**）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-18
**Rev**: **rev5** —— Gate 2 四轮共 **28 个 P0**。rev3 把承重从"搬家"移到**约束语义分类**；
rev4 修完三个脚本（块边界 / 模块集 / AC3 分母）；**rev5 给"常驻层"下定义并把判定器从 Blake 手里收回来**
**配套**（均 commit，AC12 守其哈希）：`*.step0.sh` · `*.budget.sh` · `*.measure.sh` ·
`*.resident.sh`（**常驻层唯一定义**）· `*.verify.sh`（**AC1/3/4/10/13 的冻结判定器**）·
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
| **禁止型** | 被禁动作**不是** agent 的默认行为 → 忘了也不会做 | ~~本体可外置~~ → **rev5 改为本体也不动**（见下） | **1** |
| **义务型** | 忘了 = 少做一步 | **常驻层必须留 1 行祈使句原文**（不是 `load_when` 指针），reference 只放展开 | **29** |

⚠️ 判据不是"条文写禁止还是必须"，是「**被禁的动作是不是默认行为**」：不调 codex 不是默认（禁止型）；
而"写代码"对编码 agent 就是默认，故「角色分离」虽写作禁令仍按**义务型**处理。
**保守分类几乎免费：29 条祈使句合计 1,818 B**（rev4 写的 1,879 B 是错的，实测 1,818）。

⚠️ **rev5 收紧：唯一那条禁止型（`跨模型审查`）的本体也不动。** 它的 `NOT_via_alex_auto: true`
同时被三处要求逐字留在 body：`alex/SKILL.md:702` 的 `DO NOT remove` 注释、
`.tad/hooks/lib/skill-body-verify.sh` 的必需 marker、principles.md 的 SAFETY 条目。
外置它 = 打破仓库既有的发布门。它只占几百字节，"保守几乎免费"对它同样成立。
→ **本单一条约束本体都不外置**，义务/禁止的分类只用来决定"哪些必须在常驻层留祈使句"。

## 3. 阶段划分（同一风险类别一刀，阶段间可定位）

### 3.0 两个存量缺陷的处置（rev4 定案，**Blake 都不用做**）

| 缺陷 | 处置 |
|---|---|
| 地板表 `启动扫描` 锚点被 P3 改过时（全仓只存在于地板表自己） | **Alex 已于 rev4 前修完**：锚点改为 `只跑命令读其输出，禁止整读这三处`，17 项现已全部 `grep` 命中。→ `discipline-floor.md` 因此**退出写权限清单**，回到"绝对不动"侧 |
| `command_module_binding` 列 5 个模块，`STEP 3` 正文只读 4 个 → `config-cognitive.yaml` **Alex 从不加载**，其承载的 `研究先行`/`技术决策透明`/`致命操作强制人审` 三条纪律已暗 | **移出本单，另开单**。理由：修它是**加载量 +N**，与本单方向相反，混进最高危一刀会破坏"同一风险类别一刀"的可定位性；且它与"82/83 条强制行无常驻副本"是同一病（约束够不着 agent），应一起治。本单只保证**不让它变差**（AC2）并**每次 measure 都把已暗模块打印出来** |

| 阶段 | 内容 | 备注 |
|---|---|---|
| **S0** | 跑 `step0.sh` 冻结基线 + 跑 `budget.sh` 产出最小常驻集预算表 + **按 `obligations.tsv` 把 29 条义务型祈使句写进常驻层**（AC1） | **预算即新 SC1**，不设"超了就 STOP"的门槛。祈使句可落在受保护块内——AC4(a) 只禁删、不禁增 |
| **S1** | ~~`config-workflow.yaml` 段外置~~ **已删除** | ⚠️ rev5 砍掉。实测三段（`pair_testing` 223-268 / `playground` 269-331 / `scenarios` 710-776）合计 **5,984 B = 总量的 2.3%**，而契约又明写不做 config 按意图加载 → **外置到哪、什么格式、谁在什么触发下读回来，全部无定义**；AC6 只管 `alex/SKILL.md` 的 `reference:` 存根，管不到 config 段。结果是 Blake 删三段写三条散文记录就算"完成"，`配对测试` 当场变暗。**2.3% 不值这个风险** |
| **S2** | `alex/SKILL.md` 内联模式专属块外置 + 34 个存量存根压缩 | 存量存根压缩**也受可达性约束**（压缩 `load_when` 是把非循环压成循环的最省事路径） |

⚠️ **原 S2（`principles.md` 索引化）已删除**：实测净省 **0**——`AGENTS.md:38` 与
`blake/SKILL.md:518` 均明写"每次角色激活必读 principles.md 全文"，而这两个文件在不许动清单里。
结局只有"照读全文（省 0 且多一份要同步的索引）"或"让纪律变成谎言"。
且其中「Deny-List Beats Allow-List」条有**正文在场时仍被误读**的实测事故（2026-08-06）。
**拿 6.76% 换这类内容的一层间接，回报率最低、风险最高。**

**每阶段结束**：commit + 跑 `measure.sh` + 跑 `verify.sh all` + 落盘可达性记录 + 跑逐类计数（烟感）。

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

### 4.1 rev5 追加的 5 个**非地板**护栏块（Gate 2 R4 逐条过完 30 条纪律后补的漏项）

地板表没覆盖，但丢了后果同样不可逆。均已写进 `blocks.tsv`（`常驻=是`），受 AC4(a) 只增不减保护：

| 块 | 载体 | 为什么必须在 |
|---|---|---|
| `STEP3模块加载` | `alex/SKILL.md` | 它就是"哪些 config 被加载"这件事本身。**改这一行 = 一次编辑让 4 条纪律变暗** |
| `跨模型禁令alex侧` | `alex/SKILL.md` | `NOT_via_alex_auto: true` + 上一行 `DO NOT remove` 注释 + 4 条 `forbidden_implementations` |
| `Friction协议本体` | `alex/SKILL.md` | 内含 `Friction反跳过`（Layer 0）的 alex 侧副本，且它自己的 `forbidden_implementations` 明写 **`MUST NOT place friction protocol only in references — it must be in body`** |
| `平台绑定交互决策` | `alex/SKILL.md` | 「禁止代答 / 禁止把选项折叠成默认值 / SAFETY 门控无论何种 harness 都必须真人作答」——**agent 替人回答 SAFETY 门控与致命操作未经人审是同一后果类** |
| `致命操作识别表` | `config-platform.yaml` | `always_confirm:`（`rm -rf` / `git push --force` / `filesystem delete` / `kubectl delete`…）。§1 亲口说 `config-platform` 承载 0 项地板可自由摘除——它此前**只因 AC2 保住模块集成员资格而偶然存活** |

⚠️ 另加 **AC13 = 仓库既有的 `.tad/hooks/lib/skill-body-verify.sh` 必须全绿**（见 §7）。
它源自 principles.md 的 SAFETY 条目《Circular Trigger Test》，对 `alex/SKILL.md` 强制 7 个 body marker
且禁止重建 3 个 reference —— **rev4 一个字都没提它，而 S2 最肥的外置目标正是其中 4 个 marker**。

## 5. 不做

❌ 不做 config 模块级"按意图加载"（前提不成立）｜❌ **不做 `principles.md` 索引化**（净省 0，见 §3）｜
❌ **不动 `config-workflow.yaml`**（S1 已砍，它已退出写权限）｜❌ 不动 `blake`/`gate`/`blake-lite`/`AGENTS.md`｜
❌ 不动 `fatal_operations:` 与 `release_management:` 两段｜❌ 不删任何一条纪律的内容｜
❌ **不外置任何约束的本体**（rev5：连唯一的禁止型也不外置，见 §2）｜
❌ **不新增常驻层成员**（见 §7.0）｜❌ **不改启动扫描命令**｜
❌ **不改地板表任何格**（过时锚点已由 Alex 修完）｜❌ 不发布

## 6. 写权限（编号即全集；git 只允许只读子命令）

1. `.tad/discipline-floor-budget.md`（新建）｜
2. `.claude/skills/alex/**` · `.agents/skills/alex/**`｜
3. `.tad/evidence/acceptance-tests/lazy-by-floor/`｜
4. `.tad/archive/handoffs/COMPLETION-20260818-lazy-by-floor.md`｜
5. `.tad/active/epics/EPIC-20260813-alex-blake-lightening.md`（**仅 phase 状态段**——P7 是本 Epic 最后一个 phase，
   rev4 漏给这一项，Blake 只能"违反 §6"或"留个不完整的 Epic"二选一）

⚠️ **rev5 移除 `.tad/config-workflow.yaml`**：S1 已砍，本单不再改它。
它承载 `需求澄清` 与 `意图路由` 两个地板块，退出写权限后由 AC10 围栏整体保护，比块级检查更强。

⚠️ rev4 移除三项：`.tad/discipline-floor.md`（过时锚点 Alex 已修完，无事可做）·
`principles.md` / `CLAUDE.md` / `config.yaml`（S2 已删、模块集只增不减，无需改它们）。

⚠️ **rev5 对第 2 项加限定**：`alex/references/**` 里**已存在文件**的强制行数**只增不减**
（`step0.sh` 冻结 `references-constraint-base.tsv` 逐文件计数）。rev4 把这 307,985 B / 30 个文件
整个放开，而 AC3 分母不含它、AC4 不含它、AC7 不数它、AC9 只查 parity（两边一起删照样绿）
—— **0 覆盖的高危写面**。

## 7. Acceptance Criteria

### 7.0 「常驻层」的唯一定义 ⚠️ rev5 新增，**这是 AC1 能不能成立的前提**

rev4 全文 8 处写「常驻层」，**没有一处枚举它是哪些文件** → 解释权在 Blake 手里。
配合 `measure.sh` 的固定分母，产生一条**被制度奖励**的降级路径：
新建 `alex/OBLIGATIONS.md` 放 29 条祈使句 → AC1 绿（Blake 自定"常驻层"含它）、
AC7 **更绿**（新文件不在分母里，0 B 成本；放进 SKILL.md 反而 +1,818 B）、AC10 绿（`alex/**` 在写权限内）
→ **29 条义务全部落进一个与 reference 结构上无差别的文件**，而 §1 的实测结论正是
"agent 不去读 reference，且发现文件不存在时降级继续不报错"。**本单承重归零。**

**修法**：常驻层 = `*.resident.sh` 的输出，**AC1 / AC7 / AC8 三者读同一个集合**
（所以"AC1 grep 的文件集 == measure.sh 的分母"是构造性成立的，不靠 Blake 自觉）。
T0 实测 **12 个文件**：`CLAUDE.md` · `AGENTS.md` · `alex/SKILL.md` · `config.yaml` ·
STEP 3 正文解析出的 4 个 `config-*.yaml` · `CLAUDE.md` 的 3 个 `@import` · `tool-quick-reference-alex.md`。

⚠️ **本单不得新增常驻层成员**，且**不得减少**：`measure.sh` 对 `resident-set-base.txt` 做**双向** `comm`
——新增违反本节，减少违反 AC2。⚠️ 这两个方向都要查是实测出来的：只查新增时，把 STEP 3 从 4 个模块砍到 1 个
会让 `TOTAL_STATIC` 掉 48,325 B 而 `RESULT=PASS`，正是第三轮那条"4 条纪律变暗、AC 全绿"的攻击原样复活。
要新增须**退回 Alex 改契约**——因为 `measure.sh` 受 AC12 冻结，Blake 就算想诚实地把新文件加进分母也不被允许，
rev4 在结构上禁止了诚实路径。

### 7.1 AC 列表

**「红」= `exit ≠ 0` 且末行 `RESULT=FAIL`。**
⚠️ **AC 分两类，负控方向相反**：**不变量类**（T0 必绿）/ **完成度类**（T0 必红）。
**任一 AC 方向不符 → 停下退回 Alex。**（rev1 的负控只筛"永真"，放行了两条在 T0 即红的。）

| # | AC | 类 | 判定器 |
|---|---|---|---|
| **AC1** | **义务型祈使句常驻（本单承重）**：`obligations.tsv` 中 29 条 `义务` 行的第 3 列祈使句，**逐条在 §7.0 的常驻层 `grep -F` 命中**并落盘 `文件:行号`。任一缺失 = FAIL。⚠️ 忘记义务 = 跳过 = v2.7；祈使句必须是**原文**，不是 `load_when` 指针 | 完成度 | `verify.sh AC1` |
| **AC2** | **两个模块集各自只增不减**：`STEP 3` 正文实际加载的模块集、`command_module_binding.tad-alex.modules`，**分别**与 T0 比对，`LC_ALL=C comm -23 T0集 现集` 均须为空。⚠️ **不得取并集**——binding(5) ⊇ 正文(4)，取并集会让"改正文里的模块名"这类攻击**完全隐形**（该攻击一次编辑 −18,101 B、4 条纪律变暗、12 条 AC 全绿）。⚠️ **rev5**：正文集抽取必须锚定 `^ +[0-9]+\. Load required modules: ` 且**命中恰好 1 次**，否则报错退出——rev4 用 `grep -m1` 子串匹配，**在文件任意更早处插一行含该子串的注释即可劫持抽取**（已实跑复现：诱饵行 + 改真行 → 旧法仍报 4 个模块全绿，新法 0 命中 FAIL） | 不变量 | `resident.sh` + `measure.sh` |
| **AC3** | **约束行集有分母**：`comm -23 constraint-lines-base.txt <(bash step0.sh --constraint-set)` 的**每一行**必须在 `reachability.tsv` 里出现恰好 1 次。⚠️ **rev5 两处修正**：(1) 现集口径**必须调 `step0.sh --constraint-set`**，rev4 只写"现集"不说怎么算 → Blake 把范围放宽到整个 skills 树就 `comm` 恒空、AC3 永远绿零条记录；(2) 分母正则改**大小写不敏感**并补 `NEVER\|REQUIRED\|min [0-9]` —— rev4 只匹配大写，把 `Missing dependency… is NEVER a skip reason`（Layer 0 `Friction反跳过` 的 alex 侧副本）、`Self-review is NEVER equivalent`、`Expert review (min 2)`（AC8 Q1 的本体）全漏在分母外。**分母 57 → 137 行** | **不变量** | `verify.sh AC3` |
| **AC4** | **地板护栏（块级，不是单行 grep）**：(a) `blocks.tsv` 里 `常驻=是` 的 **14 项**（9 地板 + §4.1 的 5 个护栏块），块边界由起/止锚串给出，逐块 `LC_ALL=C comm -23 <T0块行集> <现块行集>` **零输出**——⚠️ **rev5 写死操作数顺序**：rev4 只写 `comm -13` 不给操作数，按 AC2 的自然读法方向是**反的**（变成禁止新增、允许任意删除），已实跑验证该读法会放行"`Forbidden` 块条目全删只留注释锚点"这个负控。**允许新增行**（AC1 的祈使句可以落在块内）；(b) 载体在 `gate`/`blake`/`blake-lite` 的 8 项 + `AGENTS.md` → `git diff --quiet ${T0} -- <载体>`。⚠️ 起/止锚串须 `grep -Fx` **恰好命中 1 次**且地板锚点必须落在块内，否则 `budget.sh` FAIL | 不变量 | `verify.sh AC4` |
| **AC5** | **不可逆两段逐字未变**：`git diff --quiet ${T0} -- .tad/config-cognitive.yaml .tad/config-execution.yaml`。⚠️ `fatal_operations:` 的本体是**识别表**，外置 = 识别能力外置 | 不变量 | git |
| **AC6** | **循环触发逐条现判**：每个**新建或被修改**的 `reference:` 存根，其 `load_when` 触发词须在 §7.0 常驻层有独立定义点（路径+锚点+行号落盘）。存量 34 个存根压缩前后 `load_when` 逐条 diff 落盘，**键为 `reference:` 路径不是行号**（行号会整体位移） | 不变量 | 人工 + `stub-loadwhen-base.tsv` |
| **AC7** | **测量**：`measure.sh`（冻结）跑 S0/S2 各一次，**`TOTAL_STATIC` 严格下降**。⚠️ 分母 = §7.0 常驻层（与 AC1 同一集合），常驻层**新增成员即 FAIL**；`CMD_OUTPUT` 现抽命令实跑 `wc -c`，且**只跑 T0 冻结集里逐字相同的命令**（本单不改扫描命令）；因其随工作树漂移，**不计入 `TOTAL_STATIC`**。T0 实测 `TOTAL_STATIC` **256,313 B ≈ 64K tokens**、`TOTAL` 262,172 B | 完成度 | `measure.sh` |
| **AC8** | **行为回读（义务型专项）**：每阶段 spawn fresh subagent，**只喂 `resident-set-base.txt` 列出的文件**（逐个落盘 md5），问 `readback-rubric.tsv` 四题，**每题必含键全中（AND）** 才算过。⚠️ **rev5 加第 4 题**：前三题（专家审查 min 2 / 研究先行 / 致命操作人审）在 AC1 通过后必然能答——AC1 一绿 AC8 必绿，是同义反复，测不出"本体是否还够得着"。第 4 题「列出至少 4 类致命操作的识别特征」**只能靠识别表本体答出**，一行祈使句答不出来。⚠️ 必含键均已改为可从**冻结的祈使句/识别表**推出（rev4 的 Q2 要求答出 `*research`，而该词在常驻层根本不出现 → 在 Blake 权限内不可满足） | 完成度 | 人工 + rubric |
| **AC9** | parity：`.claude/skills/alex/**` 与 `.agents/skills/alex/**` `diff -r` 零输出 | 不变量 | `diff -r` |
| **AC10** | 围栏：`git diff --name-only ${T0}` ∪ 未跟踪 −(§6 **五项** ∪ `fence-baseline.txt` ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空。⚠️ **rev5**：基线改成"相对 T0 commit"而非"跑 Step 0 那一刻的脏文件快照"——快照式围栏对并发写入天生脆弱（rev4 实测：Alex 在冻结后 3 分钟改了 Epic 文件，AC10 在 Blake 动工前就已经红） | 不变量 | `verify.sh AC10` |
| **AC11** | **五份负控全红**：(a) 摘掉一个模块名 → AC2 拦 (b) 搬走一条约束不写记录 → AC3 拦 (c) 删空 `Forbidden` 块内条目但留注释锚点 → AC4(a) 拦 (d) 外置 `fatal_operations:` → AC5 拦 (e) **rev5 新增**：把 29 条祈使句写进一个新建的 `alex/OBLIGATIONS.md` → **AC1 保持红**拦（实测：新文件不在 `resident.sh` 的输出里，`grep` 根本不会去看它，29/29 仍缺失）。⚠️ 负控只测**单一 AC 的孤立行为**，测不出组合绕过——(a) 单独跑确实会红，但"诱饵行 + 改真行"的组合就绕过去了 | 完成度 | 人工 |
| **AC12** | **契约与七个配套文件均未变**：`git diff --quiet ${T0} -- <八文件>`（`step0.sh` · `budget.sh` · `measure.sh` · `resident.sh` · `verify.sh` · `obligations.tsv` · `blocks.tsv`）。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex** | 不变量 | git |
| **AC13** | **仓库既有的 body/reference 边界门必须全绿**：`bash .tad/hooks/lib/skill-body-verify.sh` 输出含 `ALL CHECKS PASSED`。⚠️ **rev5 新增**：该脚本源自 principles.md 的 SAFETY 条目《Circular Trigger Test》，对 `alex/SKILL.md` 强制 7 个 body marker（`research_unified_protocol:` / `distillation_loop:` / `note_blocking_taxonomy` / `read_feedback_protocol:` / `MANDATORY: Socratic Inquiry Protocol` / `anti_rationalization_registry:` / `NOT_via_alex_auto: true`）并禁止重建 3 个 reference。**rev4 一个字都没提它，而 S2 最肥的外置目标正是其中 4 个 marker** —— 删了 12 条 AC 全绿、这个门事后才红。T0 实测已绿，加它零成本 | 不变量 | `verify.sh AC13` |

## 8. 环境约束（本机实测）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`；`for f in $VAR` 在 zsh 下**只迭代 1 次** → 显式列出；
**中文文案里的变量必须写 `${VAR}`**；分隔符一律 TAB；脚本装 `trap … EXIT` + `DONE=1`；
⚠️ **`cat dir/*.md` 不递归** → 一律 `find <dir> -name '*.md'`。

## 9. Step 0

运行 `*.step0.sh`，冻结：
`resident-set-base.txt`（**§7.0 常驻层闭集**，T0 实测 12 文件 —— AC1/AC7/AC8 共用）·
`scan-cmds-base.txt`（启动扫描命令 T0 冻结集，5 条；`measure.sh` 只跑集内逐字相同的命令）·
`obligations.tsv` 校验（30 行 / 29 义务 / 1 禁止，名称与地板表逐字相等）·
`blocks.tsv` 覆盖校验（地板 17 项齐全 + 常驻 14 项必有起锚串）·
`constraint-lines-base.txt`（**AC3 的分母**，口径 = `step0.sh --constraint-set`，T0 实测 **137 行**）·
`floor-anchors.tsv`（17）·`stub-loadwhen-base.tsv`（**键 = `reference:` 路径**，T0 实测 34）·
`references-constraint-base.tsv`（`alex/references/**` 逐文件强制行数，§6 第 3 项的只增不减基线）·
`readback-rubric.tsv`（**四题**，前三义务型 + 第四题只能靠本体答出）·
`discipline-baseline.txt`（六类，烟感）·`fence-baseline.txt`（相对 T0 commit 的既有脏文件 ∪ 未跟踪）。

⚠️ `step0.sh --constraint-set` 是 **AC3 现集的公开接口**，AC3 必须调它、不得自写 grep
（对齐 principles.md 2026-06-01：跨文件漂移检查挂在**公开 flag 接口**上，不是抄内部实现）。

**T0 实测**（Alex 已跑通，Blake 复跑应得同值）：
`step0.sh` PASS · `budget.sh` = 常驻 9 项 **15,935 B ≈ 4K tokens** ·
`measure.sh base` = `TOTAL_STATIC` **256,313 B** / `TOTAL` 262,172 B ·
`verify.sh all` = **AC1 红（29/29 缺失，完成度类方向正确）· AC3/AC4/AC13 绿 · AC10 绿**。

**逐条 AC 按 §7.1 类别跑方向负控**：不变量类 T0 必绿、完成度类 T0 必红，任一不符 → 停下退回 Alex。

## 10. 已知取舍

1. **保守分类的代价**：29/30 判义务型各留一行祈使句 = **1,818 B** 常驻，且唯一的禁止型本体也不动
   → **本单一条约束本体都不外置**。这是刻意的：判据是"被禁动作是否为默认行为"，存疑一律按义务型。
2. **只做 alex 侧**；`blake` 121KB / `gate` 53KB 未动（v2.7 正是同时改多处导致无法定位）。
3. **AC8 是模型输出**，可复现性弱于其余 AC。前三题在 AC1 通过后是同义反复，**真正买东西的是第 4 题**
   ——它问识别表的内容，一行祈使句答不出来，只有本体还够得着才答得出。
4. ⚠️ **存量发现（不在本单范围）**：`alex/references/**` 现有 83 条强制行中 **82 条在常驻层无重复副本**
   ——**今天守住纪律的是重复不是可达性**。本单只保证不让这个数变差，**修它另开单**。
   §3.0 的 `config-cognitive` 从不加载（3 条纪律已暗）与此同病，**同一张单一起治**。
   ⚠️ 但 **rev5 更正**：其中有一条**不能推给另开单**——`Friction反跳过` 是 Layer 0 纪律，
   它在 `alex/SKILL.md:712-754` 的副本原本 0 覆盖（blocks.tsv 因载体指向 `blake` 而标 `常驻=否`，
   AC4(b) 只 `git diff` 保护 blake 那份），而该段自己的 `forbidden_implementations` 明写
   **"must be in body"**。这是**本单写权限范围内**的缺口，已加进 §4.1 的护栏块。
5. ⚠️ **SC1 ≤15K tokens 本单达不到，且这不是本单的锅**：地板本体只占 15,935 B（≈4K tokens），
   剩下 240K B 全在"可搬但要搬得安全"的区间。S1 已砍、S2 的可搬量远小于 200K B。
   **本单交付的是"能不能安全地搬"这个能力，不是 15K 这个数**；SC1 的收口留给后续单。
6. ⚠️ **判定器的作者问题只解决了一半**：AC1/AC3/AC4/AC10/AC13 有 Alex 写的冻结判定器
   （`verify.sh`，受 AC12 保护），AC2/AC7/AC9/AC12 有冻结脚本或 git 原语；
   但 **AC6/AC8/AC11 仍由 Blake 自己执行**。前三轮 23 个 P0 的共同签名是"AC 全绿纪律已死"，
   而判定器作者就是被判定方时这个签名会重现 —— 这三条的产物格式已冻结（rubric / 负控 diff），
   但**执行仍靠自觉**，这是本单剩余的最大敞口。
