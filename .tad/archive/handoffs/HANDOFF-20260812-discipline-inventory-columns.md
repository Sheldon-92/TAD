# HANDOFF: 纪律清单补五列（成本量级·收益·论证·防线关系）

**Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 1b / 6）
**From**: Alex（full 通道）
**To**: Blake
**Created**: 2026-08-12
**Rev**: **rev4**（Gate 2 四轮并行审查，各审不同维度；**共 21 个 P0 全部修复**；清单见 §12）
**流程深度**: Light TAD（Alex 评估 small，用户 2026-08-12 裁定 Light）

---

## 0. 环境约束（违反会让验证静默失效）

| 约束 | 实测依据 | 后果 |
|---|---|---|
| **`sort` / `uniq` 前必须 `LC_ALL=C`** | `printf '高\n中\n高\n' \| sort \| uniq -c` → **`3 高`**；加 `LC_ALL=C` → `1 中` / `2 高` | 本机 `en_US.UTF-8` 下 `sort` 认为不同中文串**排序相等**，`uniq -c` 把它们并成一桶，**报第一个的标签 + 全部的计数**。这是**静默错数** |
| **禁用 `awk` 做任何 CJK 字符串比较** | `awk 'BEGIN{print ("建议"=="成本")}'` → **`1`**（one-true-awk 20200816，无 gawk） | 按中文表头定位列会**静默定错列并永真 PASS** |
| **列作用域 / 中文相等判定一律用 `/usr/bin/python3`**（3.9.6 实测可用） | — | 唯一可靠 |
| **`grep` 是 ugrep 7.5.0 的 shell function 包装**，带 `--ignore-files` | 会**静默跳过 gitignored 文件** | 用 `command grep` 或 python3 |
| **`-E` 模式下用裸 `\|`，不要用 `\\\|`** | `grep -ciE 'A\|B'` 对含 A、B 的 fixture 返回 **0**；裸竖线返回 **3** | `\|` 是字面竖线 → 模式退化为常量 → **永真 PASS** |
| **`grep -c` 无命中时 exit 1** | `set -e` 下触发 ERR | 后加 `\|\| true`；只看 stdout 数字 |
| **禁用 `git status --porcelain` 行集比对做围栏** | 对 T=0 已是 `M` 的文件，再改内容仍是同一行 ` M path` → **diff 恒为空** | 围栏一律用 `git diff <T0-commit>`（内容级） |
| **`$PIPESTATUS` 是 bash-ism，zsh 下为空** | 实测：zsh 用 `$pipestatus`（小写，1-indexed） | 管道退出码判据会**静默取到空值**，`test` 随之失败或误判 |
| **无 `timeout` / `gtimeout`** | 实测双缺 | `/usr/bin/perl -e 'alarm shift; exec @ARGV' <秒> <cmd>` |
| **路径一律绝对** | Bash 工具 cwd 在调用间重置 | 统一用 `$R` / `$D` |

⚠️ **命令一律从 §9 代码块复制，绝不要从表格复制。**

### 0.1 T=0 锚（**Alex 于 2026-08-12 已完成，Blake 不得重建、不得覆盖**）

| 锚 | 值 |
|---|---|
| **T=0 commit** | **`2859b75`** |
| `discipline-provenance.md` md5 | `f1a6914b8716cd864716a5a3b741fac6` |
| `verify.py` md5（**T=0 记录值。本单会变更它，仅供事后追溯，不参与 AC1**） | `8dca2f7d185b8d9290667a738333607d` |

> **为什么 Alex 先提交**：本单全部制品此前**未被 git 追踪**（`git ls-files` = 0，且非 gitignore，
> 是从未提交）。rev1 把「投影不能反向」全押在两个 **Blake 自己生成的基线**上——
> 被判方自证。现在 `git diff 2859b75` 是 Blake 没写过的外部锚。
> 实测：改 `handoff-design.md` 一个字节 → `git diff --name-only 2859b75` 立即命中；还原 → 归零。

### 0.2 AC14 回归基线（**Alex 于 2026-08-12 在 T=0 状态实测，逐字钉死**）

> ⚠️ rev1 的 AC14 写"与 Phase 1 完成报告记录值相同"——**实测那份报告根本没记这十条的输出**
> （`command grep -c "verify.py <sub>"` 对十个子命令返回 0/0/0/0/0/0/0/0/0/0）。
> 该 AC 当时无法执行。改为由 Alex 直接钉死基线。

```
=== cost ===
成本col=15 violations=0 []
=== class3 ===
class3_missing_trigger=0 []
=== class2 ===
class2_missing_evidence=0 []
=== carriers ===
checked=14 ok=13 bad=1
  BAD: .tad/active/handoffs/HANDOFF-20260812-discipline-inventory.md#L515 ['file-missing']
=== types ===
instances=14 typed=14 severity=14
=== single-type ===
only_absence=7 warned=7
=== floor ===
floor_missing_reason=0 []
=== blindspot ===
has_model=True / prompt_has_装不下=True / prompt_has_forbidden=False / answer_len=2476
=== rows ===
rows=15
=== empty ===
empty_missing=0 []
```

⚠️ **`carriers` 的 `bad=1` 是既存退化，不是本单造成的，不许"顺手修好"**：
Phase 1 的一个载体指向 `.tad/active/handoffs/HANDOFF-20260812-discipline-inventory.md#L515`，
而那份 handoff **已归档**到 `.tad/archive/handoffs/`——**归档动作打断了引用其自身活动路径的载体**。
Phase 1 验收时该路径存在，AC 是绿的。
**本单 AC14 的判据就是"仍然是 `ok=13 bad=1` 且 BAD 仍是同一条"**——变成 14/0 说明有人动了形态 B 的载体
（违反 §3.3），变成 12/2 说明又断了一条。修这条载体属于另一张单。

### 0.3 围栏 T=0 基线命中集（Alex 实测钉死）

```
.claude/settings.local.json.bak-20260806-082549
```

**这是 T=0 就存在的既存命中**（`git clean` 风险文件之一，提交 `2859b75` 时有意排除）。
AC11 的判据是"命中集与本节**逐行相等**"，**不是"必须为空"**——
rev2 写成"必须为空"，Blake 一行字没写就会被自己的围栏拦死。

§9 表头（每段沿用）：
```
R="/path/to/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"
T0=2859b75
TMP="<本 session 的 scratchpad 绝对路径>"   # ⚠️ 必须在仓库之外；Blake 用前先 test -d
```

⚠️ **§9 开头有一段强制 preflight**（证明全部产物存在后才允许跑任何 AC）。
实测：`grep -c X 缺失文件 || true` 与 `wc -l` 在文件不存在时**都返回 0** ——
判据"计数为 0 即通过"的 AC 在产物根本不存在时同样绿。

---

## 1. Task Overview

### 1.1 做什么

给形态 A（`discipline-inventory.md`）现有九列**追加五列**：
**成本量级 / 严重度 / 判据 / 证伪条件 / 防线关系**。

### 1.2 Intent Statement

Phase 1 的产物**能当清单看，不能当拍板依据用**：有成本无收益、有判定无论证、有行无行间关系。
本单补上，让「哪条纪律留在哪个档位」有据可依。

### 1.3 为什么是五列而不是四列（rev2 变更，用户批的是四列）

rev1 只补了**收益**侧。Gate 2 的 product-expert 指出：现有成本列是**异构自由文本**
（`~5秒` vs `3-5轮问答` vs `2次spawn`），与收益不通约——**补了收益也读不出比值**。
第五列「成本量级」把现有成本列投影到一条**有序闭值集**上，两侧才能对齐。

⚠️ 这是对用户已批范围的**扩大**，理由是 Gate 2 P0，须在完成报告中显式记录。

### 1.4 五列里三列是投影，**两列**是新判断

| 列 | 性质 | 来源 |
|---|---|---|
| 严重度 | 投影 | 形态 B 该行实例 `严重度=` 取 max |
| 判据 | 投影 | 现有第 6 列（三类判定）→ §4.1 编号 |
| 证伪条件 | 投影 | 形态 B `地板·可缩放：` 括号内的证伪句 |
| **成本量级** | **新判断** | 现有「成本」列 **15 行有 14 种不同文本**，无机械映射（实测：只有 D10/D14 一对完全同文本） |
| **防线关系** | **新判断** | 形态 B 只有 1 条显式边，其余需推导 |

⚠️ **rev2 曾把成本量级写成"投影"——错的**（Gate 2 P0）。它是第二个新判断，
因此 **§6.3 的独立复核与 Step 4 的形状审查两列都要覆盖**，不是只覆盖防线关系。

### 1.5 行序即 ID（连接键，契约钉死）

形态 A **没有** Dxx 列。**形态 A 第 i 个数据行 ↔ 形态 B `D{i:02d}`**；
纪律**名称仅作交叉校验，不作连接键**。（`verify.py:155` 既有实现即此约定。）

---

## 2. 知识引用（逐字标题 + 行号，已核实命中）

| 条目（逐字） | 位置 | 本单怎么用 |
|---|---|---|
| `"Is This Right?" and "What Can't This Hold?" Are Different Questions — a Correctness Review Cannot See a Structure's Ceiling` | `.tad/project-knowledge/patterns/ac-verification.md#L342` | 本单存在的理由。**Step 4 要求对十四列再做一次天花板审查** |
| `Repairing a Loud Failure Must Not Replace It With a Silent Success` | `.tad/project-knowledge/patterns/ac-verification.md#L334` | §0 的 `sort` 坑正是"静默成功" |
| `Path Layering: Three Defenses Against AR-001 Drift` | `.tad/project-knowledge/principles.md#L43` | **防线关系的地基**：三条各挡一类失败的独立防线，胜过一条强机械防线 → `互补` 与 `冗余` **根本不同** |
| `A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss When Legit Stripping Also Lowers the Count` | `.tad/project-knowledge/principles.md#L67` | **逐类核对，不用全局计数** |
| `In a Capability-Retirement Inventory, "Not Needed" Is a Judgment, Not a Carrier — the Loss Concentrates in the Rows Exempted From Naming One` | `.tad/project-knowledge/patterns/handoff-design.md#L167` | **`独立` 不许当默认值**，必须举证 |

⚠️ 这五个文件**在 T=0 commit 里**。改动它们即被 `git diff 2859b75` 捕获（AC11）。

---

## 3. 范围与写权限

### 3.1 做

1. 形态 A 追加五列 + 追加一节「五列定义与取值」（自包含）
2. 扩展 `verify.py`：新增子命令（§8 逐条对应）
3. 防线关系的独立复核（§6.3）
4. 形状天花板审查（§7 Step 4）
5. 负控：目标侧三处 + **源侧两处**（§8 AC2 / AC13）

### 3.2 写权限（**allow-list —— 未列出即禁止**）

本单**只允许**写以下 4 个位置，**其余整个文件系统一律禁止写**：

1. `$D/discipline-inventory.md` —— **仅追加五列 + 追加一节**，前九列只读。
   ⚠️ **「五列定义与取值」节必须整体位于主表之后**；该节内任何表格的列数**不得等于 14**。
   （`form_a_rows()` 以文件**首个 `|` 行**为表头。实测把新节放到主表之前，
   `class3` / `class2` / `floor` / `empty` / `single-type` 五个既有子命令会在空行集上
   **静默返回 0**——绿得毫无意义。）
2. `$D/verify.py` —— **仅新增子命令**，既有 10 个子命令行为不得改动（AC14）
3. `$D/` 下本单**新建**的产物：`defense-graph-blake.md`、`defense-graph-independent.md`、
   `defense-graph-review.md`、`shape-blindspot-review-phase1b.md`、`derivation-t1.md`、
   `derivation-t1.md5`、`derivation-diff.md`、**`verify-commands.sh`**（AC9 的扫描对象）
4. 完成报告 `.tad/archive/handoffs/COMPLETION-20260812-discipline-inventory-columns.md`

**明确禁止**（这些都落在"未列出"里，此处只是点名最危险的）：
`.claude/agents/`（**被审查方重定义审查方**——`security-auditor.md` / `spec-compliance-reviewer.md` 实测在此）、
`.claude/settings*.json`（hook 注册表；关掉 hook 而 `.tad/hooks/` 一字未动，字面上不违反"不改 hook"）、
`.tad/hooks/`、`.tad/project-knowledge/`（§2 五条引用的**载体本身**）、`.tad/active/epics/`、
`.tad/archive/handoffs/HANDOFF-20260812-discipline-inventory.md`（§4.1 声明"原文不动"的那份）、
`CLAUDE.md`、`.gitignore`（围栏验证器的输入）、**本契约自身**。

> **为什么是 allow-list 而不是 deny-list**：依据 `principles.md` 2026-08-06 AMENDED 段——
> **集合有界且排除项可完整枚举 → deny-list；集合无界或边界会随职责增长 → 小而有界的 allow-list。**
> "Blake 可写的路径" = 整个文件系统，**无界**。rev1 的 §3.2 是无界集合上的 deny-list，
> 与 2026-08-06 被判 P0 的写法**同形**。

**禁止任何写入历史的 git 命令**：`commit` / `checkout` / `restore` / `clean` / `stash` / `reset` / `rm` / `add`。
`git diff` / `git show` / `git ls-files` 等只读命令允许。

⚠️ 工作树仍有 **6 个未追踪路径**（932 个 codex spike 文件 + settings 备份 + txn-lock），
**一次 `git clean -fd` 即永久销毁，无 git 对象可恢复**。

### 3.3 不做

- ❌ 不改形态 B（`discipline-provenance.md`）——它是投影的**源**，改它即循环自证。md5 锁见 §0.1
- ❌ 不改任何一行现有九列的值 ❌ 不增删纪律行（仍 15 行 D01–D15）
- ❌ 不给"哪条该删"的结论 ❌ 不定义档位触发规格（Epic 明写须等 Phase 5）

---

## 4. 五列定义（逐字执行）

### 4.1 判据编号（本契约定义，映射到 Phase 1 契约 §4.4 四类，原文不动）

| 编号 | 对应「三类判定」列 | §4.4 原判据 |
|---|---|---|
| `C1` | `1-留` | 有实例（抓到过，或缺席导致过事故） |
| `C2` | `2-退场` | 无实例，但触发条件出现过 |
| `C3` | `3-挂起` | 无实例，且触发条件从未出现 |
| `C4` | `4-威慑免死` | 无实例，且失效场景理论上会造成不可逆或高严重度后果 |

**取值域**：`{C1,C2,C3,C4}`，恰好一个。

⚠️ **本列是过滤器，不是排序器。** 它把少数例外行从主群里筛出来，对主群内部**不提供切分信息**。
不得在形态 A 中暗示本列参与"谁进地板/谁进旋钮"的排序。（Gate 2 P1）

### 4.2 成本量级（rev2 新增）

**取值域**（**有序**，低→高）：
`{零, 机械近零, 机械一次, agent一次, 人一次, 人多轮}`，恰好一个。

**每值判据（可复算）**——主轴是**谁执行**，不是机器跑多久：

| 值 | 判据 |
|---|---|
| `零` | 无任何运行时动作（纯禁令 / 内置约束） |
| `机械近零` | 确定性程序，单次 **<10 秒**，无 LLM 调用 |
| `机械一次` | 确定性程序，单次 **≥10 秒或需读写产物**，无 LLM 调用 |
| `agent一次` | **1–2 次** LLM / subagent 调用，无人参与 |
| `人一次` | 需人 **1 次**输入或裁定 |
| `人多轮` | 需人 **≥2 轮**往返 |

**三条消歧规则（必须逐字执行）**：
1. **复合成本取 max**：`1次评估+1次人裁定` → `人一次`（人 > agent > 机械 > 零）
2. **多次同类不升档**：`2次spawn` 仍是 `agent一次`（值集不区分 agent 次数，取舍见 §10.2）
3. **档位相关的成本按 full 填，括号内注 lite 值**：D01 的成本原文是
   `3-5轮问答(full)｜≤1问2轮(lite)` → 填 `人多轮（lite: 人一次）`
   ⚠️ **不许只填一个值。本 Epic 要决定的就是档位，单值格子会把待决问题先假定掉。**

4. **「谁执行」不在成本列里时**，按该纪律在 `CLAUDE.md` / 对应 SKILL 中的**实际执行主体**判定，
   并在完成报告**逐行写明出处**。⚠️ **不得因为"成本列没说"就直接丢进"套不上"**——
   逃生口只留给规则 1–4 全部套完仍有歧义的行。

> **为什么要第 4 条**（Gate 2 P1）：§4.2 的主轴是「谁执行」，而这个信息**根本不在成本列里**。
> 实测只有 8 行能从成本列唯一定档（D01 契约钉死 + D03/D04/D08/D10/D13/D14/D15），
> **其余 7 行全会走逃生口**——AC16 就只剩域检查（六值之一即绿），判别力≈0，
> 且近半张表退回 Alex 手上重做。第 4 条把这 7 行拉回可判定。

⚠️ 遇到四条规则也套不上的行**不要硬塞**——在完成报告中列出并说明，由 Alex 裁定。
（Alex 已知至少 D09 `1次人机配对` 存在歧义：字面"1次" vs 配对本质是持续往返。）

### 4.3 严重度

**取值域**：`{高, 中, 低, 未知}`，恰好一个。

**投影规则**：取形态 B 该 `## Dxx` 段内所有 `严重度=\`X\`` 的 **max**（`高 > 中 > 低`）；
该段**零实例**时填 `未知`。

⚠️ **不许推断。** 无实例只能是 `未知`，不得因"它看起来很重要"填 `高`。
⚠️ **严重度与「地板·可缩放」是两个独立维度**，不得互相推导。
⚠️ **严重度不驱动地板/旋钮判定。** Phase 3 的旋钮设计需要另一套依据（成本随规模的缩放曲线），
本单不提供，见 §11。（Gate 2 P0）

### 4.4 证伪条件

**取值域**：两种形态之一，**15 行均非空**（不许空单元格、不许 `-`）：
- 有证伪句的 **10 行**：**逐字**照抄形态 B `地板·可缩放：` 括号内**末个 `；` 之后那一句**
- `待判` 的 **5 行**：填 `N/A（待判·本行在 Phase 5 前不得拍板）｜前置：<下表源句，逐字>`

⚠️ **允许 ASCII 空格。** rev2 写的"无空格"是笔误（原意是"不许**空**"）。
实测 D04 / D06 / D13 / D15 的源句本就含 ASCII 空格（`min 2/1/0`、`~5 秒`、`AC 可执行性`、
`build/test/lint`）——**逐字优先于无空格**，照字面执行"无空格"会导致两边都过不去。

**5 个待判行的「前置」源句（本契约钉死，逐字）**：

| 行 | 前置源句（逐字） |
|---|---|
| D07 知识评估 | `需先找到"教训流失"实例` |
| D08 跨模型审查 | `需先制度化并测成本随任务缩放行为再判` |
| D09 配对测试 | `需非自指任务出现真机测试需求再判` |
| D11 Execution Mandate | `需非自指实例对比` |
| D12 约束准入 | `需观察约束增长速率才能判地板/可缩放` |

> ⚠️ rev2 写的是"照抄形态 B「需先…」那句"，但实测 **D09/D11/D12 三行根本没有"需先"二字**
> ——期望值不存在，AC 无法执行（Gate 2 P1）。故改为由本契约逐行钉死。
> D11 只截到 `——` 之前（整句含引号与 88 字符，塞进单元格不可读）。

⚠️ **不许改写、不许精简**——逐字是为了让 AC 做字符串包含校验。
⚠️ `待判` 行的 `不得拍板` 字样是**强制**的（Gate 2 P1）：这几行在新五列上与已判定行长得几乎一样
（有的严重度=高、判据=C1），不加锁定标记，Phase 2/3 会误当拍板对象。

### 4.5 防线关系（唯一新判断）

**取值域**：`独立`，或 `{同根|互补|冗余}→D<nn>` 一条或多条（`；` 分隔）。

| 关系 | 含义 | 判据 |
|---|---|---|
| `同根` | 两行防的是**同一个失败**的两个环节 | 删任一条，另一条**仍在但覆盖不全** |
| `互补` | 两行各挡**不同**的失败类 | 删任一条，另一条**完全挡不住**被删那条的失败类 |
| `冗余` | 两行挡的失败类**相同且覆盖相当** | 删任一条，另一条**基本挡得住** |
| `独立` | 无其他行与之有上述任一关系 | —— |

**机械约束（AC5 校验）**：
1. **对称**：三种关系必须双向
2. **目标存在**：`D<nn>` ∈ D01–D15，不得指向自己
3. **`独立` 排他**：填 `独立` 的行不得同时有任何边
4. **`独立` 必须举证**：填 `独立` 的行，**「防线关系」列本身**写成
   `独立｜理由：删除本行后无其他行覆盖其失败类「<失败类>」`
   （依据 `handoff-design.md#L167`：`独立` 是判断不是默认值）
   ⚠️ **举证不得写进「建议」列**——「建议」是现有九列的第 9 列，受 AC1 冻结。
   rev2 写的是「建议」列，与 AC1 直接互斥：只要有任何一行判 `独立`，
   AC1 与 AC5 必然一红一绿，Blake 怎么做都过不了（Gate 2 P0）。
5. **`冗余` 反证前置**（rev2 新增，Gate 2 P0）：判 `冗余` 前必须检查两行在形态 B 中的
   `防住过什么` / `删掉会怎样` / `删之前先找什么反例` 三行是否出现**反证词**
   （`漏掉` / `穿透` / `不等价` / `已证伪` / `量化…处` / `挡不住`）。
   **出现任一反证词 → 禁止判 `冗余`**，除非在**「防线关系」列本身**写成
   `冗余→D<nn>｜反证例外：<逐字反证句>｜仍成立理由：<一句>`。
   ⚠️ 同 #4，举证**一律不得进「建议」列**（AC1 冻结第 9 列）。

⚠️ **`互补` 与 `冗余` 不许混填。** `互补` = **两条都得留**；`冗余` = **可以只留一条**。
两个词在 Phase 4 导向相反处置，**填错方向 = 把该留的删掉**。

> **为什么加第 5 条约束**（Gate 2 实证）：D04 专家审查 与 D08 跨模型审查表面都写着"防视角盲区"，
> naive 读法必判 `冗余`。但 D04 自己写着「同模型同盲区的缺陷**直接穿透**」，
> D08 写着「Codex 跨模型审查全部浮出，**量化约 44 处**同模型循环漏掉的抓包」——
> **D04 明说它挡不住 D08 挡的东西，正确关系是 `互补`。**
> rev1 的四条机械约束（对称/目标存在/独立排他/独立举证）**一条都拦不住这个误判**。

---

## 5. 对照表（**封存 —— 不在本契约内**）

Alex 用两种独立解析方法从形态 B / 形态 A 抽取了一份 15 行期望值表，两次结果零不一致。
**该表不写进本契约**——rev1 把它写在 §5，而 Blake 读到那一行的瞬间"独立推导"就已经不可能了。
**这是信息顺序问题，不是自律问题**（Gate 2 P1）。

**交付顺序（强制）**：
1. Blake 独立推导四个投影列，写进 `$D/derivation-t1.md`
2. `md5 -q "$D/derivation-t1.md" > "$D/derivation-t1.md5"`，把 md5 **报给人类**
3. **人类收到 md5 后**，才把 Alex 的对照表转交给 Blake
4. 此后 `derivation-t1.md` 的 md5 **不得变化**（AC15 复验）
5. diff 结果写进 `$D/derivation-diff.md`；不一致**不许默默采信任一方**，逐条写明是 Alex 抽错还是 Blake 推错

**先给两条不含答案的提示**（无害）：
- D08 / D11 的「严重度」与「地板·可缩放」是两个独立维度，不要互相推导
- **`C2` 应为 0 行**——推出任何 `C2` 立即停下报告

### 5b 成本量级对照表（同样封存，同一交付顺序）

成本量级是**第二个新判断**（§1.4），因此同样需要对照。Alex 按 §4.2 的六档判据 +
三条消歧规则推了一份，**同样不写进契约**，走 §5 的同一条人类桥梁。

**先给一条不含答案的提示**：`D10` 与 `D14` 的「成本」原文**完全相同**（`0（内置禁令）`），
实测 15 行里只有这一对同文本——**它们的成本量级必须相同**（AC16 会机械校验这条）。

---

## 6. 防线关系怎么做

### 6.1 输入

只看形态 B 每段的三行：`防住过什么` / `删掉会怎样` / `删之前先找什么反例`。
**失败类**从「删掉会怎样」提取。

### 6.2 已知的一条边（格式样例）

`D02` 段：「与 D01 同根的事故重演」→ `D01: 同根→D02`，`D02: 同根→D01`。

### 6.3 独立复核（**本单最重要的一步；两个新判断列都要覆盖**）

Phase 1 的 Gate 4 记了一条未修取舍：**15 行的判定只有 Blake 一人做过**。防线关系是新判断，不能重蹈。

**顺序、隔离、留痕三者都要机械可证**：

1. **先封存**：Blake 边集落 `$D/defense-graph-blake.md`，
   `md5 -q "$D/defense-graph-blake.md" > "$D/graph-blake-pre-review.md5"`，md5 逐字写进完成报告。
   **此步未完成不得 spawn。**
2. **移出源文件（两份，均在仓库之外）**：
   ```bash
   cp "$D/discipline-provenance.md" "$TMP/formB.md"
   # 只抽「纪律 + 成本」两列，绝不带新五列（否则答案随输入一起递过去）
   /usr/bin/python3 - "$D/discipline-inventory.md" "$TMP/costs.md" <<'PY'
   import sys
   ls=[l for l in open(sys.argv[1],encoding='utf-8').read().splitlines() if l.startswith('|')]
   h=[c.strip() for c in ls[0].strip().strip('|').split('|')]
   i,j=h.index('纪律'),h.index('成本')
   out=["| 行号 | 纪律 | 成本 |","|---|---|---|"]
   for n,l in enumerate(ls[2:],1):
       c=[x.strip() for x in l.strip().strip('|').split('|')]
       out.append(f"| D{n:02d} | {c[i]} | {c[j]} |")
   open(sys.argv[2],'w',encoding='utf-8').write("\n".join(out)+"\n")
   print("costs.md written, cols=纪律+成本 only")
   PY
   ```
   ⚠️ 生成后 **Blake 必须 `cat "$TMP/costs.md"` 并把全文贴进完成报告**，证明只含三列、不含任何新列。

   > **为什么要抽 costs.md**（Gate 2 P0）：§1.4 要求独立复核**覆盖成本量级**，
   > 而成本量级的输入是**形态 A 的第 3 列**——正好在 §6.3 第 3 步禁止读取的
   > `.tad/evidence/designs/` 目录里，且不在 formB.md 内。
   > **rev3 自己造出了这个互斥**：复核者物理上拿不到判断成本量级所需的输入，
   > Blake 要么破隔离要么破覆盖，怎么做都错。

3. **spawn 1 个 fresh 通用 subagent**，**禁止 `subagent_type: "fork"`**
   （fork 继承调用者完整上下文 = 把答案直接递过去）。
   prompt **只给两个路径**：`$TMP/formB.md`、`$TMP/costs.md`；
   加 **§4.5 四类定义全文 + §4.2 六值域与四条消歧规则全文**；
   明写：**禁止读取 `.tad/evidence/designs/` 下任何文件**。
   要求复核者**分节输出**：`<!-- GRAPH -->` 防线关系边集、`<!-- COST-TIER -->` 15 行成本量级。

4. **强制输出**（复核者原始输出里必须有这三个锚，AC7 逐节校验）：
   `<!-- FILES-READ -->` 实际读过的文件绝对路径逐条；
   `<!-- 套不上 -->` 四类都套不上的关系（可答"无"，但必须答）；
   外加第 3 步的 `<!-- GRAPH -->` 与 `<!-- COST-TIER -->`
5. 复核者原始输出**逐字**存 `$D/defense-graph-independent.md`（不得编辑），再 diff

- 一致的边：采纳
- 不一致：两版并列写进 `$D/defense-graph-review.md`，标注最终取哪个 + 一句理由
- ⚠️ **只做一轮。** 不一致不触发重审，由 Blake 裁定并留痕。
  （用户 2026-08-12：「review 修改了以后不应该再重复的 review……对抗性的它会一直找问题」）

---

## 7. 执行步骤

> **Step -1（冻结 T=0）已由 Alex 于 2026-08-12 完成** —— commit `2859b75`，100 个文件。Blake 跳过。

**Step 0 · 记录起点**
```
git -C "$R" diff --name-only $T0     # 应为空（T=0 工作树干净，Alex 已实测）
md5 -q "$R/.tad/active/handoffs/HANDOFF-20260812-discipline-inventory-columns.md" \
  > "$D/contract-t0.md5"             # 契约内容锁（V15 复验）
: > "$D/verify-commands.sh"          # 本单跑过的每条 shell 命令都要追加进来
```
⚠️ **Blake 本单敲的每一条 shell 命令都必须追加进 `$D/verify-commands.sh`**，
否则 AC9（裸 `sort`/`uniq` 扫描）**没有扫描对象**，那条 AC 会退化成永真。
⚠️ **不再自产 md5 / porcelain 基线**——rev2 那两行已删，它们是被判方自证。

**Step 1 · 投影三列 + 推成本量级** —— 按 §4.1/4.3/4.4 投影三列，按 §4.2 推成本量级
（**那是新判断不是投影**）→ 全部写进 `$D/derivation-t1.md` → 报 md5 给人类（§5）

**Step 2 · 防线关系** —— §6.1/6.2 产出边集，按 §4.5 五条机械约束自检

**Step 3 · 独立复核** —— §6.3，**一轮**

**Step 4 · 形状天花板审查** —— spawn 1 个 fresh subagent（**同样禁止 fork**——fork 会带着刚做完的
十四列判断去回答"这个形状装不下什么"，答案被自己的实现锚定）。题面由本契约钉死：

> 这张十四列的表，**装不下**什么决策所需的信息？
> **禁止回答"填得对不对"**——正确性不是本次的问题。
> 只回答：为了决定"哪条纪律留在哪个档位"，还有什么是这个**形状**表达不了的。
> 已知本单不覆盖的缺口见契约 §11，请指出 §11 之外还有什么。

产出 `$D/shape-blindspot-review-phase1b.md`。

**Step 5 · 负控（目标侧 + 源侧）** —— §8 AC2 / AC13。
还原后 **preflight + V1–V15 全量重跑并全绿**（尤其 V13：注入⑦触碰前九列，最需要它复验）。
⚠️ 注入⑥ `touch .claude/skills/_nc_probe.md` 验完**必须删掉**，否则 AC11 围栏恒红。
⚠️ **注入⑦触碰前九列，是本单唯一授权的临时越界**（与 §3.3「不改任何一行现有九列的值」字面冲突）：
必须在**同一次 Bash 调用内**完成「改 → 跑 V1b → 还原 → 复跑 V1b」，并当场贴出三个 exit。

**Step 6 · 完成报告** —— 含：derivation diff 结果、防线关系分歧裁定、Step 4 结论、
成本量级套不上的行、以及 **§1.3 范围扩大（四列→五列）的记录**。

---

## 8. Acceptance Criteria

### 8.0 verify.py 退出码契约（⚠️ 本单**新增**的全部子命令逐条适用）

> **为什么必须先立这条**（Gate 2 P0）：`verify.py` 既有的 9 个子命令**全部 print 完就 return**，
> 全文唯一一处 `raise SystemExit(2)` 只在**整列缺失**时触发。实测九条全部 `exit=0`，
> 包括 `carriers` 报 `bad=1` 时也是 0。若新子命令照抄这个房规，
> **AC3/4/5/6/10/17 的判据「跑 verify.py」不是永真，而是根本没有"红"这个状态。**

**每个新子命令**：
- 最后一行必须是 `RESULT=PASS` 或 `RESULT=FAIL`
- `RESULT=FAIL` 时必须 `raise SystemExit(1)`
- **Phase 1 的 9 个既有子命令不得改动**（AC14 回归）；新旧风格差异写进完成报告

**"变红"的定义（本契约唯一定义，AC2 依此判定）**：`exit ≠ 0` **且**末行为 `RESULT=FAIL`。

### 8.1 AC 表

| # | AC | 判据 |
|---|---|---|
| **AC1** | 形态 B 字节不变；形态 A **前 9 格**逐行不变 | V1 `git diff --quiet $T0` exit=0；V1b 前 9 格投影 diff exit=0。⚠️ **不得直接 `git diff` 形态 A**——追加列会改写每一行整行文本，照字面读会恒红 |
| **AC2** | **负控九处**：注入后对应命令**变红**（§8.0 定义）；还原后回到 exit=0 + `RESULT=PASS` | ① D01 严重度 `高`→`中` →V2 红 ② 删一条边的反向边 →V4 红 ③ `独立` 行加一条边 →V4 红 ④ 任一行证伪条件删末 3 字 →V5 红 ⑤ `verify-commands.sh` 插一条裸 `sort` →V7 红 ⑥ `touch .claude/skills/_nc_probe.md` →V8 红（验完即删）**⑦ 前九列改一字符**（D06 成本 `~5秒`→`~6秒`）→**V1b 红且逐行打印该行** **⑧ 任一行判据 `C1`→`C2`** →**V3 红且 C2 计数=1** **⑨ 任一行成本量级改成域外值 `中等`** →**V3b 红**。**逐处贴出注入前 / 注入后 / 还原后三个 exit**，缺任一数字该处不算做过 |
| **AC2b** | **`冗余` 反证前置的负控**（§4.5 #5 唯一没有负控的一条）：把 D04↔D08 强改成 `冗余→D08` / `冗余→D04` → `graph` **必须 FAIL 并打印命中的反证词** | 注入前/后/还原三个 exit |
| **AC13** | **源侧负控**：形态 B 复制到 `$TMP` 后改掉 D01 一处 `严重度=` 与一处 `若…证伪`，对副本跑 `severity --form-b` / `falsifier --form-b` **必须变红**；复验原件 `git diff --quiet` exit=0 | 证明判据真在读形态 B，而非内联期望值表 |
| **AC3** | 严重度列取值全在 `{高,中,低,未知}`，与形态 B max 逐行相等；**分布须为 高=7 中=5 未知=3** | V2 exit=0 + `RESULT=PASS` |
| **AC16a** | **机械半**：成本量级 15 行取值全在六值域内；**D10/D14（成本原文同为 `0（内置禁令）`）必须为 `零`，其余行必须不是 `零`**；**D01 必须逐字为 `人多轮（lite: 人一次）`** | V3b exit=0。⚠️ D10/D14 那条是 15 行里**唯一**可机械验的一致性约束（实测只有这一对完全同文本） |
| **AC16b** | **判断半**：每一行在完成报告写明「**执行者 = 机械 / agent / 人**，依据 = <`CLAUDE.md` 或该纪律 SKILL 的逐字出处>」；与 §6.3 复核者 `<!-- COST-TIER -->` 节逐行 diff，不一致逐条裁定留痕 | ⚠️ 单靠域检查是永真的（六值之一即绿）——判别力全在这一半 |
| **AC4** | 判据列取值全在 `{C1..C4}`，与「三类判定」列逐行一致；**`C2` 计数 = 0** | V3 exit=0 |
| **AC5** | 防线关系**五条**机械约束（对称 / 目标存在 / `独立`排他 / `独立`已举证**在防线关系列内** / `冗余`反证前置）全过 | V4 exit=0 |
| **AC6** | 证伪条件列 15 行**均非空**；**逐字命中=10**（形态 B 末个 `；` 之后那句的子串）；**待判=5**（形如 `N/A（待判…）｜前置：<§4.4 钉死源句>`） | V5 exit=0。⚠️ **允许 ASCII 空格** |
| **AC7** | 独立复核**无泄题**（可机械检测，取代自我声明） | `defense-graph-review.md` 须含四个锚：`<!-- REVIEWER-PROMPT -->`（给 subagent 的 prompt 全文）、`<!-- REVIEWER-RAW-EDGES -->`、`<!-- BLAKE-EDGES -->`、`<!-- 分歧裁定 -->`。**REVIEWER-PROMPT 段内 `grep -cE 'D[0-9]{2}\s*(→\|->)\s*D[0-9]{2}'` 必须 = 0**（prompt 里出现任何一条边 = 泄题 = FAIL）；另需 `<!-- FILES-READ -->` 非空且不含 `discipline-inventory` / `defense-graph-blake`；明写 `subagent_type` 非 fork |
| **AC8** | 形状审查**题面钉死且未跑偏成正确性审查** | V10 `verify.py blindspot-1b` exit=0：PROMPT 段内 `装不下` ≥1、`对不对`/`是否正确` = 0、RAW-ANSWER ≥500 字符 |
| **AC15** | `derivation-t1.md5` 记录时点**早于**对照表出现；该文件当前 md5 与记录值一致 | 完成报告时间线 + md5 复验 |
| **AC14** | `verify.py` **Phase-1 十子命令回归**：逐条输出与 **§0.2 钉死基线逐字相同**；`form_a_rows()` **必须按表头名取列**，不得按位置索引 | V13 十条输出全文贴进完成报告 |
| **AC9** | 本单**新增/修改的每一条 shell 命令**中 `sort`/`uniq` 均带 `LC_ALL=C` 前缀 | V7 `bare=0`。⚠️ Python 的 `sorted()`/`.sort()` **不在此列**（码点排序，与 locale 无关）；扫描器须按 shell token 位置判定、剥注释后再判 |
| **AC10** | **collation 自证**（取代 rev2 那条被 AC3 完全蕴含的直方图检查） | 完成报告须贴两份输出：`printf '高\n中\n高\n' \| sort \| uniq -c`（错：`3 高`）与 `printf '高\n中\n高\n' \| LC_ALL=C sort \| LC_ALL=C uniq -c`（对：`1 中`/`2 高`） |
| **AC11** | **零改动围栏 = 已跟踪内容变化 ∪ 未跟踪新增**，命中集须与 §0.3 的 T=0 基线**逐行相等**；**且本契约自身 md5 与 Step 0 记录值一致**（围栏正则不覆盖 `.tad/active/handoffs/`，改契约即改 AC —— 必须单独锁） | V8。⚠️ 两者**各漏一半**：`git diff` 看不见未跟踪新增；porcelain 行集对 T=0 同状态行全盲——**必须取并集**。⚠️ 判据**不是"必须为空"**：Alex 实测 T=0 已有一条既存命中 |
| **AC12** | 形态 A 自包含：`## 五列定义与取值` 节存在且唯一，含 **18 个取值域词全命中** + `待判` 5 行清单 + 「判据列是过滤器不是排序器」一句 | V11 exit=0 |

---

## 9. 验证命令（一律从此代码块复制）

```bash
R="/path/to/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"
T0=2859b75
TMP="<本 session 的 scratchpad 绝对路径>"   # ⚠️ 必须在仓库之外
```

**⚠️ preflight（§9 全部命令之前必须先跑，任一失败 = GATE FAIL）**
```bash
test -d "$TMP" || { echo "GATE FAIL: TMP 未定义或不存在"; false; }
for f in discipline-inventory.md discipline-provenance.md verify.py verify-commands.sh \
         defense-graph-blake.md defense-graph-independent.md defense-graph-review.md \
         shape-blindspot-review-phase1b.md derivation-t1.md derivation-t1.md5 \
         derivation-diff.md graph-blake-pre-review.md5; do
  test -s "$D/$f" || { echo "GATE FAIL: 缺 $f"; false; }
done
test -s "$R/.tad/archive/handoffs/COMPLETION-20260812-discipline-inventory-columns.md" \
  || { echo "GATE FAIL: 缺完成报告"; false; }
echo "preflight OK"
```
> **为什么要 preflight**：`grep -c X 缺失文件 || true` 返回 **0**，`wc -l` 也返回 **0**——
> 判据"计数为 0 即通过"的 AC **在产物根本不存在时同样绿**。
> Gate 2 实测：V9a / V9b / V11 三条在产物不存在时全部 `exit=0` 且 stdout 为空。

```bash
# ---- AC1 ----
# V1  形态B 字节不变（用 git，不用 Blake 自产 md5）
git -C "$R" diff --quiet "$T0" -- .tad/evidence/designs/discipline-inventory/discipline-provenance.md
echo "V1_exit=$?"        # 要求 0
[ "$(md5 -q "$D/discipline-provenance.md")" = "f1a6914b8716cd864716a5a3b741fac6" ] \
  && echo "formB_md5=OK" || echo "GATE FAIL: 形态B 被改"

# V1b 形态A 前 9 格逐行不变
cut9() { /usr/bin/python3 -c '
import sys
for line in sys.stdin:
    if line.startswith("|"):
        print("\t".join(c.strip() for c in line.strip().strip("|").split("|")[:9]))'; }
diff <(git -C "$R" show "$T0:.tad/evidence/designs/discipline-inventory/discipline-inventory.md" | cut9) \
     <(cut9 < "$D/discipline-inventory.md")
echo "V1b_exit=$?"       # 要求 0

# ---- 投影四列（全部要求 exit=0 且末行 RESULT=PASS）----
/usr/bin/python3 "$D/verify.py" severity;   echo "V2_exit=$?"    # AC3
/usr/bin/python3 "$D/verify.py" criterion;  echo "V3_exit=$?"    # AC4
/usr/bin/python3 "$D/verify.py" cost-tier;  echo "V3b_exit=$?"   # AC16
/usr/bin/python3 "$D/verify.py" graph;      echo "V4_exit=$?"    # AC5
/usr/bin/python3 "$D/verify.py" falsifier;  echo "V5_exit=$?"    # AC6

# ---- AC9 裸 sort/uniq 扫描（扫 shell，不扫 python）----
# V7
/usr/bin/python3 - "$D/verify-commands.sh" <<'PY'
import re,sys
bad=[]
for n,l in enumerate(open(sys.argv[1],encoding="utf-8"),1):
    code=l.split("#",1)[0]                       # 剥注释，防"注释提一嘴就洗白"
    for m in re.finditer(r'(?:^|[|;&(]|\bxargs\s+)\s*((?:[A-Za-z_]+=\S+\s+)*)(sort|uniq)\b', code):
        if "LC_ALL=C" not in m.group(1):         # 只看该 token 自己的前缀赋值
            bad.append((n, m.group(2), l.rstrip()))
print("bare=%d" % len(bad))
for b in bad: print("  L%d %s :: %s" % b)
print("RESULT=" + ("PASS" if not bad else "FAIL"))
sys.exit(0 if not bad else 1)
PY
echo "V7_exit=$?"        # 要求 0

# ---- AC11 零改动围栏（已跟踪内容变化 ∪ 未跟踪新增）----
# V8
F='(^|/)CLAUDE\.md$|^\.claude/skills/|^\.agents/skills/|^\.tad/hooks/|^\.claude/settings'
{ git -C "$R" diff --name-only "$T0" -- .; git -C "$R" ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u | command grep -E "$F" > "$TMP/fence-now.txt"
# ⚠️ 与 T=0 基线命中集比对，不是"必须为空"——T=0 本身就有一条既存命中（见 §0.3）
printf '%s\n' '.claude/settings.local.json.bak-20260806-082549' > "$TMP/fence-t0.txt"
diff "$TMP/fence-t0.txt" "$TMP/fence-now.txt"
echo "V8_exit=$?"    # 要求 0；任何新增/消失的行都是违规

# ---- AC7 独立复核无泄题 ----
# V9 —— ⚠️ 对象是 defense-graph-independent.md（复核者**原始输出**），不是 -review.md。
#      -review.md 是分歧裁定文件，按 §6.3 天然会出现 "defense-graph-blake" 字样，
#      在它上面查"须 0"是**写对了反而红**。
/usr/bin/python3 - "$D/defense-graph-independent.md" <<'PY'
import sys,re
t=open(sys.argv[1],encoding='utf-8').read()
def sec(mark):
    m=re.search(re.escape(mark)+r'\n(.*?)(?=\n<!-- |\Z)', t, re.S)
    return m.group(1).strip() if m else None
fr, na, gr, ct = sec('<!-- FILES-READ -->'), sec('<!-- 套不上 -->'), sec('<!-- GRAPH -->'), sec('<!-- COST-TIER -->')
bad=[]
if not fr: bad.append('FILES-READ 节缺失')
elif len(fr)<10: bad.append(f'FILES-READ 节空(len={len(fr)})')
else:
    for leak in ('discipline-inventory','defense-graph-blake'):
        if leak in fr: bad.append(f'FILES-READ 泄漏 {leak}')
if not na or len(na)<2: bad.append('「套不上」节缺失或空')
if not gr or len(gr)<10: bad.append('GRAPH 节缺失或空')
if not ct or len(ct)<10: bad.append('COST-TIER 节缺失或空')
print(f"RESULT={'PASS' if not bad else 'FAIL'} {bad}")
sys.exit(0 if not bad else 1)
PY
echo "V9_exit=$?"     # 要求 0
# 顺序证据：spawn 前封存的 md5 与当前一致
a=$(md5 -q "$D/defense-graph-blake.md"); b=$(cat "$D/graph-blake-pre-review.md5")
[ "$a" = "$b" ] && echo "graph_seal=OK $a" || echo "GATE FAIL: 封存 md5 不符 now=$a sealed=$b"

# ---- AC8 形状审查 ----
# V10
test -s "$D/shape-blindspot-review-phase1b.md" || echo "MISSING"
/usr/bin/python3 "$D/verify.py" blindspot-1b; echo "V10_exit=$?"    # 要求 0

# ---- AC12 形态A 自包含 ----
# V11 —— ⚠️ token 必须落在该节**内部**。全文 grep 是永真的：
#      C1 / 独立 / 高 这些词主表里本来就有，Blake 只写个标题也会绿。
/usr/bin/python3 - "$D/discipline-inventory.md" <<'PY'
import sys,re
t=open(sys.argv[1],encoding='utf-8').read()
m=re.search(r'^##+ *五列定义与取值\s*$(.*?)(?=^##+ |\Z)', t, re.M|re.S)
if not m:
    print("RESULT=FAIL 无「五列定义与取值」节"); sys.exit(1)
s=m.group(1)
need=["零","机械近零","机械一次","agent一次","人一次","人多轮",
      "高","中","低","未知", "C1","C2","C3","C4",
      "同根","互补","冗余","独立", "过滤器","不是排序器"]
miss=[k for k in need if k not in s]
dpan=set(re.findall(r'D(?:07|08|09|11|12)\b', s))
if len(dpan)!=5: miss.append(f"待判5行清单(只找到{sorted(dpan)})")
print(f"RESULT={'PASS' if not miss else 'FAIL'} missing={miss} section_len={len(s)}")
sys.exit(0 if not miss else 1)
PY
echo "V11_exit=$?"    # 要求 0

# ---- AC13 源侧负控 ----
# V12
/usr/bin/python3 "$D/verify.py" severity  --form-b "$TMP/formB-corrupted.md"; echo "V12a_exit=$?"  # 要求 ≠0
/usr/bin/python3 "$D/verify.py" falsifier --form-b "$TMP/formB-corrupted.md"; echo "V12b_exit=$?"  # 要求 ≠0
git -C "$R" diff --quiet "$T0" -- .tad/evidence/designs/discipline-inventory/discipline-provenance.md
echo "V12c_exit=$?"      # 要求 0（原件未被污染）

# ---- AC14 Phase-1 十子命令回归（与 §0.2 逐字比对）----
# V13
for s in cost class3 class2 carriers types single-type floor blindspot rows empty; do
  printf '=== %s ===\n' "$s"; /usr/bin/python3 "$D/verify.py" "$s"
done

# ---- AC15 derivation 时序 ----
# V14
[ "$(md5 -q "$D/derivation-t1.md")" = "$(cat "$D/derivation-t1.md5")" ] \
  && echo "derivation_seal=OK" || echo "GATE FAIL: derivation-t1.md 在报 md5 之后被改过"
# V15 契约自身未被 Blake 改动（围栏正则不覆盖 .tad/active/handoffs/）
[ "$(md5 -q "$R/.tad/active/handoffs/HANDOFF-20260812-discipline-inventory-columns.md")" \
  = "$(cat "$D/contract-t0.md5")" ] && echo "contract=OK" || echo "GATE FAIL: 契约被改"
```

---

## 10. 已知取舍与利益冲突

### 10.1 利益冲突（rev2 已机械化两条，剩一条）

1. ~~Alex 的对照表在契约里，Blake 会照抄~~ → **已修**：对照表移出契约，经人类桥梁在 Blake 提交 md5 后转交（§5）
2. ~~独立复核只有自述~~ → **已修**：顺序（md5 封存）/ 隔离（禁 fork + 源文件移出仓库 + FILES-READ 清单）/ 留痕（原始输出逐字存）三证（AC7）
3. **⚠️ 未修**：`防线关系` 的四类定义是 **Alex 写的**，独立复核者用的也是这套定义——
   复核的是**填得对不对**，不是**这四类分得对不对**。Step 4 的形状审查部分覆盖，但不完全。
   §6.3 第 4 步的"套不上的关系"是廉价补丁，不是解决。

### 10.2 已知取舍

- **严重度只有一个维度**。用户初选的 `{高,中,低} × {不可逆,可回滚}` 被否：Phase 1 契约 §4.4 里
  「严重度=高」的定义**就是**「不可逆/安全/数据」，叉乘会同数两遍，且 `高·可回滚` 是空格子。
- **「低」档预期 0 行** —— 四值域实际退化成三值。
- **判据列对主群区分度为 0**（§4.1 已声明）。
- **5 行 `待判` 的证伪条件为 N/A**，须等 Phase 5。

---

## 11. 本单**不**覆盖的形状缺陷（Gate 2 要求显式登记，避免 Phase 3/4 执行时才发现）

Phase 1 的 AC7 盲区审查共列出约 10 条形状缺陷，本单覆盖约 3 条。**明确留给后续 phase 的**：

| 缺口 | 谁会用到 | 为什么本单不做 |
|---|---|---|
| **成本随规模的缩放曲线** | **Phase 3（旋钮）** | 本单的「成本量级」是**单点**成本，不是"轻档 vs 重档下各是多少"。旋钮设计需要曲线，本单给不了 |
| **"进旋钮"的目标状态** | **Phase 3 / 4** | 现有列只说"能不能缩"，不说"怎么缩、缩到什么" |
| 证据置信度分级（缺席致害 vs 在场生效 vs 反事实推断） | Phase 5 | 现有「实例」列只标类型不标置信度 |
| 混合实例（同一行既有正面又有负面证据） | Phase 5 | Phase 1 契约 §4.4「证据冲突处理」已有规则，但形态 A 无对应列 |
| 时间动态 / 重审触发条件 | Phase 6 | 无 |
| 缺席致害的因果机制 | Phase 5 | 无 |
| 归属责任方（Alex / Blake / 人） | Phase 2 | 无 |

⚠️ **Phase 3 开工前必须先解决前两条**，否则那张表接不住旋钮设计。

---

## 12. Gate 2 记录（四份并行审查，各审不同维度，**各一轮，无重审**）

| 专家 | 维度 | 结果 |
|---|---|---|
| `security-auditor` | 授权边界 / 围栏 / 自证循环 | **6 个 P0** |
| `product-expert` | 拍板可用性 | 2 个 P0 + 2 个 P1 |
| `code-reviewer` #1 | AC 判别力 / 命令可执行性 | **7 个 P0 + 5 个 P1**（首轮延迟送达，非重审） |
| `code-reviewer` #2 | 同上（#1 疑似失联时补派，实际审的是 rev2） | **5 个 P0 + 6 个 P1**，其中 **3 个是 rev3 新出现的** |
| Alex 自查（空跑 + 闭集门禁） | — | **5 个**（AC9 扫错对象 / `$TMP` 未定义 / V7 静默通过 / `nine-col` 对照物未定 / 编造行数「27」实为 26） |

### rev1 → rev2 修的 9 个 P0

1. AC9/V7 扫 python 文件恒为 0 → 改扫完成报告（Alex 自查）
2. 只补收益侧、成本不通约 → 新增第 5 列 成本量级（product-expert）
3. `冗余` 无机械前置，D04↔D08 会被误判成可删 → §4.5 第 5 条反证前置（product-expert）
4. 形态 A 无 T=0 基线，AC4 参照物可被改 → git commit `2859b75`（security-auditor）
5. `verify.py` 可硬编码期望值、从不读形态 B → AC13 源侧负控 + `--form-b`（security-auditor）
6. md5 基线由被锁方自己生成 → git 锚取代（security-auditor）
7. 独立复核零机械载体、fork 会带答案 → AC7 + 禁 fork（security-auditor）
8. §3.2 是无界集合上的 deny-list → 改 allow-list（security-auditor）
9. `verify.py` 十子命令无回归保护 → AC14 + §0.2 钉死基线（security-auditor）

### rev2 → rev3 修的 7 个 P0（全部来自 code-reviewer 维度）

| # | 问题 | 修法 |
|---|---|---|
| 1 | **`verify.py` 既有约定是永远 exit 0**——AC3/4/5/6/10/17 的判据「跑 verify.py」**根本没有"红"这个状态**（实测九条子命令全 exit=0，含 `carriers` 报 `bad=1` 时） | **§8.0 退出码契约**：新子命令末行 `RESULT=PASS/FAIL`，FAIL 必须 `SystemExit(1)`；「变红」= `exit≠0` 且末行 FAIL |
| 2 | AC2「变红」无判据；三处注入只覆盖 12 条 AC 中的 2 条 | 扩到**六处注入**，逐处贴注入前/后/还原三个 exit |
| 3 | V9/V11 在产物**根本不存在**时 exit=0、stdout 空 | §9 preflight + 改写为带断言的判据 |
| 4 | **成本量级是第二个新判断，不是投影**；值集混了执行者轴与次数轴；复合成本无处安放；**D01 的成本本身随档位变化，单值格子把待决问题先假定掉了** | §1.4 改正性质表；§4.2 补每值判据 + 三条消歧规则（复合取 max / 多次同类不升档 / 档位相关按 full 填并注 lite）；补 §5b 对照表；§6.3 独立复核扩到两列；新增 AC16 |
| 5 | AC1 后半无可用比对器（形态 A 追加列会改写每一行，`git diff` 恒红） | V1b 前 9 格投影 diff |
| 6 | AC9/V7 永真且过滤器双向都错（`data.sort()` 假阳；`LC_ALL=C sort \| uniq` 里裸 `uniq` 假阴；注释提一嘴就洗白） | 新增 `verify-commands.sh` 落盘 + 剥注释的 token 级扫描器 |
| 7 | AC11 围栏：`git diff` 与 porcelain **各漏一半**（前者看不见未跟踪新增，后者对 T=0 同状态行全盲） | V8 **取并集**，围栏集补 `.tad/hooks/` 与 `.claude/settings` |

**P1 修复**：AC6「无空格」是笔误且与「逐字」互斥（4 句源句本就含 ASCII 空格）→ 改「均非空」+ 钉死 5 行前置源句（**D09/D11/D12 根本没有"需先"二字，期望值原本不存在**）；`独立` 举证从被冻结的「建议」列移进「防线关系」列（原写法使 AC1 与 AC5 必然一红一绿）；AC10 改 collation 自证（原判据被 AC3 完全蕴含）；AC7 改泄题检查（原为自我声明）；AC8 接上 `blindspot-1b`；§1.5 钉死「行序即 ID」连接键。

### Alex 的自评

**rev1 是我写的，两轮共 16 个 P0。** 值得记下的是分布：
- **授权维度 6 个**——我完全没有"谁给谁做基线"这层意识，把锁和钥匙一起交给了被判方
- **AC 判别力 7 个**——我写了 12 条验证命令，其中 **11 条最终没有红态**，而我自己空跑时只发现了 1 条
- **我自查抓到的 5 个里，有 1 个是我修别的 P0 时新造的**（V7 挪到完成报告后变成"文件不存在也绿"）

⚠️ **按用户 2026-08-12 指示：修复后不再送回复审。** 本节即 Gate 2 终局记录，
剩余风险由 §10.1 第 3 条（四类定义由 Alex 单方设定）和 §11（不覆盖的形状缺陷）显式承担。

### rev3 → rev4 修的 5 个 P0

补派的第二份 AC 审查（审的是 rev2）报了 5 个 P0，逐条对 rev3 分诊后：
**2 条 rev3 已修**（围栏 T=0 已红 / 「变红」无定义），**3 条是真·新缺陷**：

| # | 问题 | 修法 |
|---|---|---|
| 1 | **`nine-col` / `criterion` / `cost-tier` 三个子命令零负控** —— `nine-col` 是本单最承重的不变量（前九列冻结），Blake 写个恒打 `RESULT=PASS` 的实现即永绿，而 §3.2 正好允许他写 `verify.py` | AC2 从六处注入**扩到九处**（⑦前九列改一字符 ⑧`C1`→`C2` ⑨成本量级填域外值）；另加 **AC2b** 专打 §4.5 #5「冗余反证前置」——五条约束里唯一没有负控的一条 |
| 2 | **AC12 的 V11 在全文 grep 那 18 个取值域词** —— 一旦 Blake 加完五列，`高`/`C1`/`独立` 全在主表里，列名也在表头里，**新节只写一个标题也是 18/18 全绿**（实测：主表填完后旧写法给 15/18，差的正是三个列名，而真实表头必然含它们） | V11 改为**只在「五列定义与取值」节内部**核 20 个 token + 待判 5 行清单。实测三态：无该节→红 / 只有标题→红 / 写全→绿 |
| 3 | **§1.4 与 §6.3 互斥，且是 rev3 自己造的** —— §1.4 要求独立复核覆盖成本量级，而成本量级的输入是**形态 A 第 3 列**，正落在 §6.3 禁止读取的 `.tad/evidence/designs/` 里。复核者物理上拿不到输入，Blake 破隔离或破覆盖，**怎么做都错** | §6.3 第 2 步抽出 `$TMP/costs.md`（**只含 行号+纪律+成本 三列**，绝不带新五列），复核者分节输出 `<!-- GRAPH -->` 与 `<!-- COST-TIER -->` |

**P1 修复**：AC16 拆成 **16a 机械半 / 16b 判断半**（域检查是永真的，判别力全在判断半）；
§4.2 补**第 4 条消歧规则**——「谁执行」不在成本列里时按 `CLAUDE.md`/SKILL 的实际执行主体判定
（实测只有 8/15 行能从成本列唯一定档，不补这条会有 7 行走逃生口、近半张表退回 Alex）；
§4.5 #5 的逃生口从被冻结的「建议」列移出（#4 修了 #5 漏了）；
V9 的对象从 `-review.md` 改成 `-independent.md`（前者按 §6.3 天然含 `defense-graph-blake` 字样，
在它上面查"须 0"是**写对了反而红**），泄漏检查限定在 `FILES-READ` 节内；
§0.2 换成**原始未美化输出**（我美化过的排版按 AC14 的"逐字"会十条全红）；
§3.2 补「新节必须在主表之后」（`form_a_rows()` 取首个 `|` 行当表头，放前面会让五个既有子命令
在空行集上**静默返回 0**）；V1/V14 加断言；新增 V15 契约内容锁。

### Alex 的自评（rev4）

**四轮审查共 21 个 P0，rev1 全是我写的。** 两个值得记住的分布：

1. **21 个里我自查只抓到 5 个**，且其中 **1 个是我修别的 P0 时新造的**。
   rev3→rev4 的 3 个新 P0 里，**又有 1 个（§1.4/§6.3 互斥）是 rev3 的修复造出来的**。
   → **修复本身是缺陷源**。本 session 第二次观察到（Phase 4 是 9 个 P0 里 5 个）。
2. **判别力维度的缺陷最难自查**：两份 AC 审查合计 12 个 P0，
   而我自己空跑只发现 1 条。原因是**我写 AC 时验的是"我以为它会怎么跑"，
   不是"它在这台机器上实际怎么跑"**——`verify.py` 永远 exit 0 这件事，
   读代码一分钟就能确认，我没读。
