# HANDOFF: 补全纪律清单 —— 60 块逐块归宿 + 10 条候选逐条裁定

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P2a / 6）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-15
**Rev**: **rev2** —— Gate 2 两专家（AC 判别力 / 语料与块定义），**5 个 P0**，全部修在本 rev
**T0**: 本契约与 `*.step0.sh` 由 Alex 在交单前 commit；Step 0 记该 SHA（AC13 的外部载体）

## 1. 目标

现有纪律清单 15 条**不是全集**。本单产出补全后的清单：
**60 个协议块逐块归宿** + **10 条 Gate 2 候选逐条裁定**。
**不做地板判定**（那是 P2b）——只回答"有哪些纪律"，不回答"哪条必须常驻"。

## 2. 为什么按「块」

一条纪律是一个协议块不是一行。实测：语料内宽词表命中 **274 行**、命名块 **60 块**。
逐行不可行且粒度错；逐块可行。

⚠️ **词表不得从已知结果反推**（P1a 教训）。实测：窄词表 `MUST|MANDATORY|BLOCKING|VIOLATION|
forbidden|不得|必须` 全语料命中 298，宽词表 **593**；`AGENTS.md` 窄词表命中 **0**，
宽词表才捞到那条"禁止代答"。**Step 0 冻结宽词表，实现期不得收窄。**

## 3. 语料（Step 0 冻结，实现期不得增删）

**入选依据 = `.tad/config.yaml:99-110` `command_module_binding` 中 tad-alex / tad-blake / tad-gate
的模块并集**，加 `gate/SKILL.md` 与 `AGENTS.md`。
⚠️ rev1 写的依据「激活时强制加载」**是错的**：`alex/SKILL.md:209-211` 只加载 4 个且不含 cognitive，
`blake/SKILL.md:182-184` 含 execution。**SKILL STEP 3 与 config.yaml binding 两个权威互相打架**
——本单按 binding 取（更宽，fail-safe），该漂移本身移交 P2b。

| 语料 | 块数 | 块定义 |
|---|---|---|
| `.claude/skills/gate/SKILL.md` | 16 | `^[a-z_]+:` 或 `^#{2,3} ` |
| `AGENTS.md` | 11 | `^#{2,3} ` |
| `.tad/config-workflow.yaml` | 11 | `^[a-z_]+:` |
| `.tad/config-quality.yaml` | 7 | 同上 |
| `.tad/config-execution.yaml` | 5 | 同上 ⚠️ rev1 漏了它（`blake` STEP 3 强制加载，发布纪律在此） |
| `.tad/config-cognitive.yaml` | 4 | 同上 |
| `.tad/config-agents.yaml` | 4 | 同上 |
| `.tad/config-platform.yaml` | 2 | 同上 |
| **合计** | **60** | |

⚠️ **具名延期 + 更正**：`CLAUDE.md` / `alex` / `blake` / lite 的 137 块**本单不逐块归宿**。
rev1 给的理由是「实测缺口全部落在未扫语料」——**该理由已被证伪**：10 条候选里
**4 条落在 `alex`/`blake`**（平台绑定 `alex:149`、产物证据链 `blake:1606`、
熔断 `blake:995`、Global Skill Exclusion `alex:490`），即原枚举在**自己扫过的语料里也漏了**。
真实理由改为：**逐块重扫 137 块超出单张契约容量**；这 4 条由 §4.3 的候选表**独立于语料**直接裁定。
**复活条件**：P2b 或后续任一刀在已扫语料再发现未登记的强制纪律 → 本延期作废，须补做。

⚠️ **另一具名排除**：`.tad/project-knowledge/**`（`CLAUDE.md` §7 `@import` + `AGENTS.md:38`
每次激活强制读）属**知识层非协议层**，本单不枚举。复活条件同上。

## 4. 产物

### 4.1 `disposition-60.md` —— 恰好 60 行，TAB 分隔

`路径 ⇥ 起始行 ⇥ 块名 ⇥ 归宿 ⇥ 理由码 ⇥ 一句话 ⇥ 块内宽词命中数 ⇥ 强制子键`

- **归宿**：`已有:{纪律名}`（名须 ∈ Step 0 的 `names.txt` 15 个）｜`新增:{纪律名}`｜`非纪律`
- **强制子键**：逗号分隔；Step 0 `subkeys.tsv` 中该块的全部子键（无则填 `-`）。实测 84 条散在 13 个块，每块 2–17 个
- **理由码**：仅 `非纪律` 行填，∈ `{R1 能力非强制, R2 已由某纪律覆盖, R3 描述性非祈使, R4 平台适配, R5 元数据/索引}`
- **一句话**：须含一段该块区间内的原文片段（≥12 字节）；**块 `hits≥1` 时该片段所在行本身须命中宽词表**
  （抄块名不算——rev1 实测 55/55 可蒙混）。`hits==0` 的块见 AC4(c)

### 4.2 `discipline-inventory.md` 增补

每条 `新增:` 以同样列数并入**表体末尾**。既有 15 行逐字不动。
⚠️ 实测该表**表头 14 列、分隔行 15 个 `---`**，且 15 行中 14 行含空格或 `-` 占位
——所以 AC6 是**逐列白名单**不是"全非空"，并顺手修分隔行。

### 4.3 `gate2-candidates.md` —— 10 行，逐条裁定

Step 0 冻结 `candidates.tsv`（含 `名称 ⇥ 文件 ⇥ 行号 ⇥ 断言关键词`，Alex 已逐条复算属实）。
每行须给 `采纳:{纪律名}` 或 `驳回`（+≥20 字节理由），并**独立复算**该 `文件:行号` 标 `属实`/`不属实`。
⚠️ **不得照单全收**——候选是候选不是结论。

## 5. 不做

❌ 不做地板/Layer 判定（P2b）｜❌ 不改既有 15 行｜❌ 不改任何 skill/config/hook/代码｜
❌ 不逐块重扫 137 块（§3 具名延期）｜❌ 不枚举 `project-knowledge/`｜❌ 不发布

## 6. 写权限（编号即全集，未列出即禁止；git 只允许只读子命令）

1. `.tad/evidence/designs/discipline-inventory/disposition-60.md`｜2. 同目录 `gate2-candidates.md`｜
3. 同目录 `discipline-inventory.md`（**仅表体末尾追加行 + 修分隔行列数**）｜
4. `.tad/evidence/acceptance-tests/discipline-enumeration/`｜
5. `.tad/archive/handoffs/COMPLETION-20260815-discipline-enumeration.md`

## 7. Acceptance Criteria

**「红」= 脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。** 一律 TAB 分隔，禁用 `#`/`:` 切分（块名含两者）。

| # | AC |
|---|---|
| AC1 | `disposition-60.md` 前三列与 `blocks.txt` **逐字相等且恰好 60 行**（`LC_ALL=C comm -3` 双向空） |
| AC2 | 归宿匹配 `^(已有:.+\|新增:.+\|非纪律)$`；**且每个 `已有:{X}` 的 X 必须逐字 ∈ `names.txt`**（15 个）。⚠️ rev1 只验 `.+`，实测全填胡编的纪律名也全绿 |
| AC3 | 理由码闭集 `{R1..R5}`，且**仅** `非纪律` 行非空 |
| AC4 | 「一句话」的原文片段按 `hits.tsv` **分档**：(a) 恒须在该块 `ranges.txt` 区间内 `grep -Fq` 命中且 ≥12 字节；(b) **块 `hits≥1` 时，片段所在行本身须命中宽词表**（防抄块名蒙混——rev1 实测 55/55 可蒙混）；(c) 块 `hits==0` 时免 (b)，但**若该块归宿≠`非纪律`，「一句话」须含 `零标记但仍属纪律·理由：` + ≥20 字节**。⚠️ 实测 60 块中 **26 块 hits=0**（43%），无此分档则 AC4 对它们不可满足 |
| AC4b | 「块内宽词命中数」列须**逐行等于** Step 0 `hits.tsv`（Blake 不得自报该数——AC7 的触发靠它） |
| AC5 | 既有 15 行逐字未变（`git show ${T0}:` 对照）；**且新表体行数 == 15 + `新增:` 去重条数** |
| AC6 | 每条 `新增:` 在 inventory 恰好 1 次；**逐列白名单**：`纪律/来源/成本/频率/三类判定/地板·可缩放` 六列须实质填写（非空且非 `-`），其余列允许 `-`；新行列数 == T0 表头列数 |
| AC7 | **子块点名**（取代 rev1 的孤儿检查）：「强制子键」列须**逐字等于** Step 0 `subkeys.tsv` 中该块的子键集合（`LC_ALL=C sort` 后比对）；且对 `subkeys.tsv` 中每个子键，该块的「一句话」或「归宿」须能解释它未被独立成条的理由。⚠️ rev1 的孤儿检查被两位审查员**独立证明恒真**（块区间铺到 EOF，orphans 恒 0、零工作量已绿），且只读 Step 0 产物、与 Blake 写什么无关 |
| AC8 | `gate2-candidates.md` 恰好 10 行，各含 `采纳:{名}` 或 `驳回`；`驳回` 理由 ≥20 字节；`属实`/`不属实` 判定与 `candidates.tsv` 的断言关键词机械比对（`sed -n "${N}p" file \| grep -Fq 关键词`） |
| AC9 | **三份负控全红**，落盘 `negative-controls/`：(a) 全 `非纪律`（AC11 拦）(b) 全 `已有:需求澄清`（AC10 拦）(c) 全 `新增`（AC4 拦）。任一为绿 = 该端无防守，**停下退回 Alex** |
| AC10 | **分布约束**：单一 `已有:{X}` 值覆盖行数 **≤ 24**（60×40%）。⚠️ 60 块不可能全归一条纪律 |
| AC11 | **采纳↔新增双向绑定**：每条 `采纳:{名}` 必须在 disposition 有 ≥1 行 `新增:{同名}`；每个 `新增:{名}` 必须在候选表有 `采纳:{同名}` 或该行标 `非候选新增`。⚠️ rev1 的 AC9(a) 声称拦「全非纪律」，实测**无实现体**——没有任何 AC 把两个产物连起来 |
| AC12 | 围栏：改动集 − (§6 五项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC13 | **契约与 step0.sh 均未变**：`git diff --quiet ${T0} -- <本契约> <step0.sh>`。⚠️ 外部载体 = git 对象库，Blake 只读。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex，不得改 AC 或 Step 0 冻结物** |

## 8. Step 0

**运行 `HANDOFF-20260815-discipline-enumeration.step0.sh`**（与本契约同目录，AC13 一并守其哈希）。
它冻结：`blocks.txt`(60 三段) · `ranges.txt`(起止行) · `hits.tsv`(每块宽词命中数) ·
`names.txt`(15 纪律名) · `subkeys.tsv`(AC7 期望子键，84 条/13 块) · `candidates.tsv`(10 候选带行号) ·
`wide-markers.txt` · `expected-blocks.tsv`(逐文件块数) · `fence-baseline.txt`。
任一逐文件块数对不上即中止并**指认是哪个文件漂移**。**脚本与冻结物实现期均不得修改。**

**开工前逐 AC 单独跑负控**（不是整脚本跑一次）：任一 AC 在未实现态即绿 = 该 AC 永真，
**停下退回 Alex**。⚠️ rev1 正是因为整脚本负控被 AC1 的红掩盖，才让 AC7 的恒真性溜过去。

## 9. 已知取舍

1. **137 块未逐块归宿**（§3 具名延期，理由已更正为"超出单张契约容量"，有复活条件）。
2. **块粒度损失是实测的、且不均匀**：`gate/SKILL.md` 4 个块吃掉 810/995 行与 124/146 处标记；
   `config-quality.yaml` 的 `quality_gates:` 一块 250 行内含两条各自 `blocking: true` 的
   Knowledge Assessment。AC7 的子块点名是针对这一条的**唯一**防守。
3. **AC7 的子键抽取经三轮收窄才可用**（Alex 自查）：不过滤 1144 条（每块 48 个，不可满足）→
   宽标记过滤 151 → 窄标记过滤 62，但**区间按"下一个匹配行"算会把父子当兄弟**，
   丢掉 `knowledge_assessment` 而留下 `blocking: true`；改缩进感知得 98，再要求标记出现在
   键行**之后**（否则键名自己满足自己）得 **84**。审查员点名的具体牺牲品
   （`config-quality.yaml` 的两条 `knowledge_assessment`，各带 `blocking: true`）**已守住**。
4. **"是不是纪律"是判断不是测量**。AC2/AC10/AC11 买到的是"与独立物料一致"，
   AC4(b) 买到的是"看过原文"，**都不等于判定正确**——那要到 P2b/P3 引用这张表时才被证伪。
