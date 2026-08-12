# HANDOFF: 纪律清单补四列（收益·论证·防线关系）

**Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 1b / 6）
**From**: Alex（full 通道）
**To**: Blake
**Created**: 2026-08-12
**Rev**: rev1
**流程深度**: **Light TAD**（Adaptive Complexity：Alex 评估 small，用户 2026-08-12 裁定 Light）

---

## 0. 环境约束（违反会让验证静默失效）

| 约束 | 实测依据 | 后果 |
|---|---|---|
| **`sort` / `uniq` 前必须 `LC_ALL=C`**（v1b 新增，本单核心） | `printf '高\n中\n高\n' \| sort \| uniq -c` → **`3 高`**；加 `LC_ALL=C` → `1 中` / `2 高` | 本机 `en_US.UTF-8` 下 `sort` 认为不同中文串**排序相等**，`uniq -c` 把它们并成一桶，**报第一个的标签 + 全部的计数**。这是**静默错数**：统计中文枚举值时会给出一个看起来正常的错误答案 |
| **禁用 `awk` 做任何 CJK 字符串比较** | `awk 'BEGIN{print ("建议"=="成本")}'` → **`1`**（one-true-awk 20200816，无 gawk） | 按中文表头定位列会**静默定错列并永真 PASS** |
| **列作用域 / 中文相等判定一律用 `/usr/bin/python3`**（3.9.6 实测可用） | — | 唯一可靠 |
| **`grep` 是 ugrep 7.5.0 的 shell function 包装**，带 `--ignore-files` | 会**静默跳过 gitignored 文件** | 用 `command grep` 或 python3 |
| **`-E` 模式下用裸 `\|`，不要用 `\\\|`** | `grep -ciE 'A\|B'` 对含 A、B 的 fixture 返回 **0**；裸竖线返回 **3** | `\|` 是字面竖线 → 模式退化为常量 → **永真 PASS** |
| **`grep -c` 无命中时 exit 1** | `set -e` 下触发 ERR | 后加 `\|\| true`；只看 stdout 数字 |
| **无 `timeout` / `gtimeout`** | 实测双缺 | `/usr/bin/perl -e 'alarm shift; exec @ARGV' <秒> <cmd>` |
| **路径一律绝对** | Bash 工具 cwd 在调用间重置 | 统一用 `$R` / `$D` |

⚠️ **命令一律从 §9 代码块复制，绝不要从表格复制。** markdown 表格要求 `|` 转义为 `\|`，
逐字复制出来 shell 会把 `\|\|` 当成两个**文件名**。

§9 表头（每段沿用）：
```
R="/Users/sheldonzhao/01-on progress programs/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"
```

---

## 1. Task Overview

### 1.1 做什么

给形态 A（`discipline-inventory.md`）现有九列**追加四列**：
**严重度 / 判据 / 证伪条件 / 防线关系**。

### 1.2 Intent Statement（为什么要做，一句话）

Phase 1 的产物**能当清单看，不能当拍板依据用**：有成本无收益、有判定无论证、有行无行间关系。
本单补上这三样，让「哪条纪律留在哪个档位」这个决策**有据可依**。

### 1.3 为什么现在做而不是并进 Phase 2

Phase 2（补回"动手之前"的纪律）要用这张表决定**动哪些行**。表不能拍板，Phase 2 就是拍脑袋。

### 1.4 关键性质：四列里三列是投影，一列是新判断

| 列 | 性质 | 来源 |
|---|---|---|
| 严重度 | **投影** | 形态 B 该行实例的 `严重度=` 取 max |
| 判据 | **投影** | 形态 A 现有「三类判定」列 → §4.1 编号 |
| 证伪条件 | **投影** | 形态 B `地板·可缩放：` 括号内已写的证伪句 |
| **防线关系** | **新判断** | 形态 B 只有 1 条显式边（D02「与 D01 同根」），其余需推导 |

投影列**不产生新意见**，只把已验收内容搬到能比较的位置。真正的新判断只有一列，
所以本单的审查火力应集中在防线关系上。

---

## 2. 知识引用（逐字标题 + 行号，已核实命中）

| 条目（逐字） | 位置 | 本单怎么用 |
|---|---|---|
| `"Is This Right?" and "What Can't This Hold?" Are Different Questions — a Correctness Review Cannot See a Structure's Ceiling` | `.tad/project-knowledge/patterns/ac-verification.md#L342` | 本单存在的理由。**AC8 要求本单也做一次同形状的天花板审查**，否则 Phase 1b 的十三列会重演 |
| `Repairing a Loud Failure Must Not Replace It With a Silent Success` | `.tad/project-knowledge/patterns/ac-verification.md#L334` | §0 的 `sort` 坑正是"静默成功"。**AC2 的负控就是为了不让修复本身变静默** |
| `Path Layering: Three Defenses Against AR-001 Drift` | `.tad/project-knowledge/principles.md#L43` | **防线关系那一列的地基**：三条各挡一类失败的独立防线，胜过一条强机械防线 → `互补` 与 `冗余` 是**根本不同**的关系，不许混填 |
| `A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss When Legit Stripping Also Lowers the Count` | `.tad/project-knowledge/principles.md#L67` | **逐类核对，不用全局计数**。本单所有枚举校验按值分类核，不许只核总数 |
| `In a Capability-Retirement Inventory, "Not Needed" Is a Judgment, Not a Carrier — the Loss Concentrates in the Rows Exempted From Naming One` | `.tad/project-knowledge/patterns/handoff-design.md#L167` | **`独立` 不许当默认值**：填 `独立` 必须举证（§4.4），否则损失会集中在这些被豁免举证的行里 |

---

## 3. 范围

### 3.1 做

1. 形态 A 追加四列（§4）
2. 形态 A 追加一节「四列定义与取值」（自包含，不依赖读契约）
3. 扩展 `verify.py`：新增 5 个子命令（§8 逐条对应）
4. 一次防线关系的**独立复核**（§6.3）
5. 一次形状天花板审查（§7 Step 4）

### 3.2 不做（逐条，出现即 BLOCK）

- ❌ **不改形态 B**（`discipline-provenance.md`）。它是投影的**源**，改它即循环自证。**md5 锁，AC1**
- ❌ **不改任何一行现有九列的值**。本单是增补不是重判。**AC1**
- ❌ 不新增/删除任何纪律行（仍是 15 行 D01–D15）
- ❌ 不给出"哪条该删"的结论——那是 Phase 2 以后的事
- ❌ 不定义档位（轻/重）的触发规格——Epic 明写须等 Phase 5 非自指实证
- ❌ 不改 `CLAUDE.md` / `.claude/skills/` / `.agents/skills/` / 任何 hook

---

## 4. 四列定义（逐字执行）

### 4.1 判据编号（本契约定义，映射到 Phase 1 契约 §4.4 的四类，原文不动）

| 编号 | 对应「三类判定」列的值 | §4.4 原判据 |
|---|---|---|
| `C1` | `1-留` | 有实例（抓到过，或缺席导致过事故） |
| `C2` | `2-退场` | 无实例，但触发条件出现过 |
| `C3` | `3-挂起` | 无实例，且触发条件从未出现 |
| `C4` | `4-威慑免死` | 无实例，且失效场景理论上会造成不可逆或高严重度后果 |

**取值域**：`{C1, C2, C3, C4}`，**恰好一个**，不许空、不许多值。

### 4.2 严重度

**取值域**：`{高, 中, 低, 未知}`，**恰好一个**。

**投影规则**（机械，可复算）：取形态 B 该 `## Dxx` 段内所有 `严重度=\`X\`` 的 **max**，
序 `高 > 中 > 低`；该段**零个实例**时填 `未知`。

⚠️ **不许推断。** 无实例的行只能是 `未知`，不得依据"它看起来很重要"填 `高`。

### 4.3 证伪条件

**取值域**：两种形态之一，**不许空**：
- 有证伪句的行：**逐字**照抄形态 B `地板·可缩放：` 括号内 `若…证伪` 那一句
- `地板·可缩放` 判定为 `待判` 的行：填 `N/A（待判）｜前置：<形态B「需先…」那句，逐字>`

⚠️ **不许改写、不许精简。** 逐字照抄是为了让 AC 能做字符串包含校验。

### 4.4 防线关系（唯一新判断）

**取值域**：`独立`，或 `{同根|互补|冗余}→D<nn>` 的一条或多条（多条用 `；` 分隔）。

| 关系 | 含义 | 判据 |
|---|---|---|
| `同根` | 两行防的是**同一个失败**的两个环节 | 删掉任一条，另一条**仍在但覆盖不全** |
| `互补` | 两行各挡**不同**的失败类 | 删掉任一条，另一条**完全挡不住**被删那条的失败类 |
| `冗余` | 两行挡的失败类**相同且覆盖相当** | 删掉任一条，另一条**基本挡得住** |
| `独立` | 无其他行与之有上述任一关系 | —— |

**机械约束（AC5 校验）**：
1. **对称**：`同根` / `互补` / `冗余` 三种关系**必须双向**。A 写 `同根→D02`，D02 必须写 `同根→D01`
2. **目标存在**：每个 `D<nn>` 必须是 D01–D15 中的一个，且不得指向自己
3. **`独立` 排他**：填 `独立` 的行不得同时有任何边
4. **`独立` 必须举证**：形态 A 该行的「建议」列须追加一句
   `独立理由：删除本行后无其他行覆盖其失败类「<失败类>」`
   ——依据 `handoff-design.md#L167`，`独立` 是判断不是默认值

⚠️ **`互补` 与 `冗余` 不许混填。** 依据 `principles.md#L43`：三条各挡一类失败的独立防线，
胜过一条强机械防线——`互补` 意味着**两条都得留**，`冗余` 意味着**可以只留一条**。
这两个词在 Phase 2 会导向相反的处置。填错方向 = 把该留的删掉。

---

## 5. Alex 的对照表（Blake 必须独立推导后与之 diff，不得照抄）

Alex 用 python 从形态 B 抽取的期望值。**Blake 独立推导一遍，然后 diff。**
不一致时**不许默默采信任一方**——写进完成报告，指出是 Alex 抽错还是 Blake 推错。

| ID | 纪律 | 期望严重度 | 期望判据 | 有证伪句？ |
|---|---|---|---|---|
| D01 | 需求澄清 | 高 | C1 | 有 |
| D02 | 需求闸 | 高 | C1 | 有 |
| D03 | 重量裁定 | 中 | C1 | 有 |
| D04 | 专家审查（多视角） | 高 | C1 | 有 |
| D05 | 门禁 | 高 | C1 | 有 |
| D06 | 启动扫描 | 高 | C1 | 有 |
| D07 | 知识评估 | 未知 | C3 | 无（待判）|
| D08 | 跨模型审查 | **高** | C1 | 无（待判）|
| D09 | 配对测试 | 未知 | C3 | 无（待判）|
| D10 | 角色分离 | 高 | C1 | 有 |
| D11 | Execution Mandate | **中** | C1 | 无（待判）|
| D12 | 约束准入 | 未知 | C4 | 无（待判）|
| D13 | AC可执行性检查 | 中 | C1 | 有 |
| D14 | Friction反跳过 | 中 | C1 | 有 |
| D15 | Ralph Loop自检 | 中 | C1 | 有 |

⚠️ **注意 D08 / D11**：`地板·可缩放` 是 `待判`，但**有实例、严重度非未知**。
「严重度」（收益大小）与「地板/可缩放」（能否随档位缩放）是**两个独立维度**，不要互相推导。

⚠️ **C2 应为 0 行**——与 Phase 1 的发现「第 2 类净删除 = 0」一致。若推出任何 C2，**停下来报告**。

---

## 6. 防线关系怎么做（唯一新判断，火力集中于此）

### 6.1 输入

只看形态 B 每段的这三行：`防住过什么` / `删掉会怎样` / `删之前先找什么反例`。
**失败类**从「删掉会怎样」提取。

### 6.2 已知的一条边（形态 B 唯一显式边，作为格式样例）

`D02` 段：「与 D01 同根的事故重演」→ `D01 同根→D02`，`D02 同根→D01`。

### 6.3 独立复核（**本单最重要的一步**，闭 Gate 4 的已知取舍）

Phase 1 的 Gate 4 记了一条未修取舍：**行级判定零交叉验证——15 行的判定只有 Blake 一人做过**。
防线关系是新判断，不能重蹈。

**做法**：Blake 完成边集后，spawn **1 个 fresh subagent**，给它形态 B **和四类关系定义**，
**不给它 Blake 的边集**，要求它独立产出完整边集。然后 diff。

- 一致的边：采纳
- 不一致的边：**两个版本并列写进** `defense-graph-review.md`，标注最终取哪个 + 一句理由
- ⚠️ **只做一轮**。不一致不触发重审——由 Blake 裁定并留痕。
  （依据：用户 2026-08-12「review 修改了以后不应该再重复的 review……对抗性的它会一直找问题」）

### 6.4 产物

`$D/defense-graph-review.md`：边集全文 + 独立复核结果 + 分歧逐条裁定。

---

## 7. 执行步骤

**Step 0 · 基线**
```
git -C "$R" status --porcelain > "$D/git-baseline-t0-phase1b.txt"
md5 -q "$D/discipline-provenance.md" > "$D/formB-t0.md5"
```

**Step 1 · 投影三列** —— 按 §4.1/4.2/4.3 独立推导，与 §5 对照表 diff，写进形态 A。

**Step 2 · 防线关系** —— 按 §6.1/6.2 产出边集，按 §4.4 的四条机械约束自检。

**Step 3 · 独立复核** —— §6.3，一轮，产出 `defense-graph-review.md`。

**Step 4 · 形状天花板审查** —— spawn 1 个 fresh subagent，题面**由本契约钉死**：

> 这张十三列的表，**装不下**什么决策所需的信息？
> **禁止回答"填得对不对"**——正确性不是本次的问题。
> 只回答：为了决定"哪条纪律留在哪个档位"，还有什么是这个**形状**表达不了的。

产出 `$D/shape-blindspot-review-phase1b.md`。
⚠️ 依据 `ac-verification.md#L342`：不钉死题面，力气会全流到"对不对"那个更容易的问题上。

**Step 5 · 负控** —— §8 AC2，验证 AC 会红。

**Step 6 · 完成报告** —— 含：§5 对照表的 diff 结果、防线关系分歧裁定、Step 4 的结论。

---

## 8. Acceptance Criteria

| # | AC | 判据 |
|---|---|---|
| **AC1** | 形态 B **字节不变**；形态 A 现有九列的值**逐行不变** | md5 相等 + 九列逐行 diff 为空 |
| **AC2** | **负控**：注入一处已知错误后，对应 AC **变红**；还原后变绿 | 三处注入（严重度改一格、删一条边的反向边、`独立` 行加一条边），逐处记录红/绿 |
| **AC3** | 严重度列 15 行取值全在 `{高,中,低,未知}`，且与形态 B 的 max **逐行相等** | verify.py `severity` |
| **AC4** | 判据列 15 行取值全在 `{C1..C4}`，与「三类判定」列**逐行一致**；`C2` 计数 = 0 | verify.py `criterion` |
| **AC5** | 防线关系四条机械约束（对称 / 目标存在 / `独立`排他 / `独立`已举证）**全过** | verify.py `graph` |
| **AC6** | 证伪条件列**无空格**；10 行含形态 B 的 `若…证伪` 逐字子串；5 行为 `N/A（待判）｜前置：…` | verify.py `falsifier` |
| **AC7** | 独立复核已跑且**未看过 Blake 的边集**；分歧逐条裁定留痕 | `defense-graph-review.md` 含"独立产出"声明 + 分歧节 |
| **AC8** | 形状天花板审查已跑，且**未回答"对不对"** | `shape-blindspot-review-phase1b.md` 存在且不含正确性判断 |
| **AC9** | 所有 `sort` / `uniq` 调用**均带 `LC_ALL=C`** | 全仓 grep 本单新增脚本，裸 `sort`/`uniq` 计数 = 0 |
| **AC10** | 严重度分类计数**判别力自证**：分类结果 ≥2 个不同取值 | 只出 1 桶即 §0 collation 坑复发 |
| **AC11** | 零改动围栏：`CLAUDE.md` / `.claude/skills/` / `.agents/skills/` 相对 T=0 无 delta | diff 基线 |
| **AC12** | 形态 A 自包含：新增「四列定义与取值」一节，不读契约也能懂 | 该节含四列取值域全文 |

---

## 9. 验证命令（一律从此代码块复制）

```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"

# V1  AC1 形态B 字节不变
md5 -q "$D/discipline-provenance.md"; cat "$D/formB-t0.md5"

# V2  AC3 严重度投影
/usr/bin/python3 "$D/verify.py" severity

# V3  AC4 判据投影 + C2 计数
/usr/bin/python3 "$D/verify.py" criterion

# V4  AC5 防线图四约束
/usr/bin/python3 "$D/verify.py" graph

# V5  AC6 证伪条件
/usr/bin/python3 "$D/verify.py" falsifier

# V6  AC10 严重度判别力（必须 ≥2 桶；出 1 桶 = collation 坑）
/usr/bin/python3 "$D/verify.py" severity-hist

# V7  AC9 裸 sort/uniq 计数（应为 0）
command grep -nE '(^|[^C=])\b(sort|uniq)\b' "$D/verify.py" | command grep -v 'LC_ALL=C' | wc -l

# V8  AC11 零改动围栏
F='(^|[ /])CLAUDE\.md$|\.claude/skills/|\.agents/skills/'
diff <(command grep -E "$F" "$D/git-baseline-t0-phase1b.txt" | LC_ALL=C sort; true) \
     <(git -C "$R" status --porcelain | command grep -E "$F" | LC_ALL=C sort; true)
echo "diff_exit=$?"

# V9  AC7 独立复核留痕
command grep -c '独立产出' "$D/defense-graph-review.md" || true
command grep -c '分歧'     "$D/defense-graph-review.md" || true

# V10 AC8 形状审查存在
test -s "$D/shape-blindspot-review-phase1b.md"; echo "exit=$?"

# V11 AC12 形态A 自包含
command grep -c '四列定义与取值' "$D/discipline-inventory.md" || true

# V12 AC2 负控（三处注入，逐处记录）——见完成报告
```

---

## 10. 已知取舍与利益冲突

### 10.1 利益冲突

1. **Alex 写了对照表（§5），又要 Blake 独立推导后 diff。** 若 Blake 直接照抄，AC3/AC4 会
   自动全绿而毫无信息。缓解：只能靠 Blake 自律 + 完成报告须写"我是怎么独立推的"。
   ⚠️ **这是本单最弱的一环，Alex 明说，不装作没有。**
2. **防线关系的四类定义是 Alex 写的**，独立复核者用的也是这套定义 —— 复核的是**填得对不对**，
   不是**这四类分得对不对**。Step 4 的形状审查部分覆盖，但不完全。

### 10.2 已知取舍

- **严重度只有一个维度**。用户初选的 `{高,中,低} × {不可逆,可回滚}` 被否掉了：§4.4 里
  「严重度=高」的定义**就是**「不可逆/安全/数据」，做成叉乘会同数两遍，且 `高·可回滚` 是空格子。
- **收益的"发生频度"没有单独成列**——形态 A 第 5 列（实例）已含次数与类型。
- **五行 `待判` 的证伪条件为 N/A**。它们要等 Phase 5 非自指实证才判得了，本单不强行填。
