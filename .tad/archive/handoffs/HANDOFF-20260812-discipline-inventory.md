---
task_type: research
research_required: yes
production_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v2.41.0 — Evidence-Based Development

**Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 1/6）
**From**: Alex（Solution Lead）
**To**: Blake（Execution Master）
**Date**: 2026-08-12
**Revision**: 2（v1 专家审查 verdict = FAIL(8×P0) + CONDITIONAL(3×P0)，本版逐条修订）
**Process Depth**: Full TAD（人选定）
**Priority**: P1 —— 本 Epic 后续 5 个 phase 全部依赖本单产物

---

## 🔴 Gate 2: Design Completeness（Alex 必填）

- [x] 专家审查完成（min 2）—— code-reviewer(AC 可执行性) + product-expert(判断规则)，见 §9.2
- [x] P0 全部解决 —— 11 条全修；1 条经实测部分推翻（约束准入术语）按实测修正；1 条 P0 级问题作为已知取舍记入 §10.2
- [x] **修复门禁 5 条通过**（闭集，非再开一轮审查）：① token 扫描无活口径残留 ② 修订后整体空跑（Row 11 正则 4 命中 / Row 12 `-Fxq` exit 0 / 绝对化链错误 cwd 拦住）③ 新守卫判据逐字取自实现（AC11 三个载体实测 1/1/3；§📚 四个行号实测指向真标题）④ 每处 `|| true` 配独立数值断言 ⑤ 机械格式字段齐全
- [x] ⚠️ **修复门禁自身抓到 1 条**：markdown 表格的 `\|` 转义使 §9.1 命令无法逐字复制（实测 `grep: ||: No such file or directory` + 正则退化）——与 v1 的 P0-2 同 bug 换一层。**§9.1 已改为「表格给 ID，代码块给命令」**
- [x] Architecture 明确：产物是三份文档 + 一个校验脚本，无运行时组件
- [x] Components 明确：见 §7.1
- [x] Functions 明确：枚举 / 检索 / 判定 三个动作，见 §6
- [x] DataFlow 明确：见 §4.3

---

## 📋 Handoff Checklist（Blake 必读）

- [ ] 读 §0 环境约束 —— **本机 `awk` 的 CJK 比较是坏的，`grep` 是 ugrep 包装，这两条会静默毁掉验证**
- [ ] 读 §📚 Project Knowledge 并在 §Blake 确认 处签名
- [ ] 读 §9.1 —— Gate 3 的主验证源，**16 行**。⚠️ **命令从 §9.1 下方的代码块复制，绝不要从表格复制**（表格的 `\|` 转义会让命令当场坏掉，实测见该节）
- [ ] 注意 §6 Phase A 的**顺序**：先独立枚举，**后**读 Epic 草稿结论（防 Preview Anchoring）
- [ ] 注意 §10.1：两条利益冲突警告，直接影响你怎么执行 AC4 与 AC13

---

## 0. 环境约束（v2 新增，违反会让验证静默失效）

| 约束 | 实测依据 | 后果 |
|---|---|---|
| **禁用 `awk` 做任何 CJK 字符串比较** | `awk 'BEGIN{print ("建议"=="成本")}'` → **`1`**（本机 one-true-awk 20200816，无 gawk） | 用 awk 按中文表头定位列会**静默定错列并永真 PASS** |
| **列作用域 / 中文相等判定一律用 `/usr/bin/python3`**（3.9.6 已实测可用） | — | 唯一可靠 |
| **`grep` 是 ugrep 7.5.0 的 shell function 包装**，带 `--ignore-files` | 会**静默跳过 gitignored 文件** | 需扫 gitignored 路径时用 `command grep` 或 python3 |
| **`-E` 模式下用裸 `\|`，不要用 `\\\|`** | 实测：`grep -ciE 'A\|B'` 对含 A、B 的 fixture 返回 **0**；改裸竖线返回 **3** | `\|` 是转义的字面竖线 → 整个模式退化为常量 → **永真 PASS** |
| **`grep -c` 无命中时 exit 1** | 在 `set -e` 下触发 ERR | 所有 `grep -c` 后加 `\|\| true`；判据只看 stdout 数字，不看 exit |
| **无 `timeout` / `gtimeout`** | 实测双缺 | 长跑命令用 `/usr/bin/perl -e 'alarm shift; exec @ARGV' <秒> <cmd>` |
| **路径一律绝对** | Bash 工具的 cwd 在调用之间会重置 | §9.1 统一用 `$R` / `$D` |

§9.1 表头定义（每行沿用）：
```
R="/path/to/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"
```

---

## 1. Task Overview

### 1.1 What We're Building

一份**纪律清单**，两种形态：

- **形态 A —— 对比表**（`discipline-inventory.md`）：每条纪律一行，**九列固定顺序**（见 §4.2）。用途：人拿它拍板"哪些留、哪些退、哪些进旋钮"。
- **形态 B —— 逐条溯源**（`discipline-provenance.md`）：每条一段，写清它防住过什么（带**可验证载体**）、删掉会怎样、想删之前必须先找到什么反例。

覆盖范围：TAD 全部工作流纪律，**含 full 侧与 lite 侧**（lite 自己新加的机制不豁免）。

### 1.2 Why We're Building It

上一个 Epic 的地基是"full 能做什么"的 19 项能力表。它结构上看不见纪律，于是 `full-router-startup` 被判为"每 session 固定启动费、无价值"而退休，`existing_equivalents` 合法留空。

代价：该行打包退休的启动扫描含 `urgent_security` 检测。它停跑 28 天，期间 `gh` 的 4 个安全漏洞（含 `gh auth status` 明文打印部分认证 token）无人发现。

**根本问题**：判断纪律去留时只有"它贵不贵"一个维度，而这个维度已经删错过一次。本单建立第二个维度：**它防住过什么（可证伪）**。

### 1.3 Intent Statement

> 当要决定一条纪律是留还是删时，决定者需要一个**能证伪的判断依据**；
> 但现在只有"它贵不贵"这一个维度——按它已删错过一次。

⚠️ **本单刻意不写成"lite 缺纪律，要补回来"** —— 那是结论不是问题。
⚠️ **Epic 的 Phase 2 名为「补回'动手之前'的三条」，这个动词已经预设了结论。**
Blake 若发现证据指向相反方向（例：某条前置纪律其实可缩放、或某条的唯一实例说明问题在执行者不在流程），**如实记录，不得为对齐 Epic 叙事而调整**。

---

## 📚 Project Knowledge（Blake 必读）

⚠️ **v2 更正**：v1 用**中文意译**当条目标题引用，实测三处全部 `grep` 命中 **0 次**。以下为**逐字标题 + 行号**，可直接 `test -f` + `sed -n` 验证。

| 载体（逐字） | 对本单的含义 |
|---|---|
| `patterns/handoff-design.md#L167`<br>`In a Capability-Retirement Inventory, "Not Needed" Is a Judgment, Not a Carrier — the Loss Concentrates in the Rows Exempted From Naming One - 2026-08-12` | 三类判据由它导出。**判为"不需要"的行按定义没有后续步骤会失败** → 所以第 2 类必须和第 3 类一样举证（AC12） |
| `patterns/ac-verification.md#L310`<br>`A New Guard's Criteria Must Be (1) Read Verbatim From the Implementation, (2) Dry-Run Against Every Shape the Real Data Takes, and (3) Composed Only of Inputs the Executor Can Obtain Independently - 2026-08-11` | 第 (1) 条正是 v1 违反的：我引用的三个标题是意译不是原文。**AC2 的载体格式因此改为"路径#行号 + 逐字片段"** |
| `patterns/ac-verification.md#L326`<br>`To Test Whether a Migrated Protocol Landed as a Usable Procedure, Hand a Fresh Reviewer That Artifact and Nothing Else — With a Contract-Fixed Prompt and a Generalization Probe - 2026-08-12` | AC7 是它的变体——但问的是"装不下什么"而非"能不能用"。**题面必须由契约钉死**（见 §6 Phase D） |
| `patterns/ac-verification.md#L334`<br>`Repairing a Loud Failure Must Not Replace It With a Silent Success - 2026-08-12` | 修 v1 的 8 个 P0 时，**别把响亮的失败换成静默的成功**。§9.1 的每处 `\|\| true` 都必须配一个独立的数值断言 |
| `principles.md`「AI/Human Judgment Domain Awareness - 2026-07-03」 | **Preview Anchoring**：先看到结论会锚定判断。§6 Phase A 的顺序修改直接由它导出 |
| `patterns/shell-portability.md`「macOS `/usr/bin/awk` Compares Any Two CJK Strings as Equal - 2026-08-05」 | §0 的 awk 禁令。**这条知识早就在库里，v1 仍然踩中** |

### Blake 确认
- [ ] 我已读完上述条目，并用 `sed -n '310p;326p;334p' patterns/ac-verification.md` 验证过行号

---

## 2. Background Context

### 2.1 Previous Work

- `EPIC-20260809-...`（**已终止**）—— 其「Epic 终止记录」节说明地基为何偏了
- ⚠️ **状态澄清**：`urgent_security` 的**定义**仍在 `.claude/skills/alex/SKILL.md` 里（STEP 3.5b）。§1.2 说"停跑"指的是 **lite 通道不执行该启动扫描**，不是定义被删。Blake 检索时会读到两者，不矛盾。

### 2.2 Current State

实测语料（每个数字附产生它的命令，见 §8.4）：

| 语料 | 数量 | 路径 |
|---|---|---|
| 知识条目 | 183（167 patterns + 16 principles） | `.tad/project-knowledge/` |
| incidents | **25 个 incident + 1 个 `_index.md`** | **`.tad/project-knowledge/incidents/`** ⚠️ 不是 `.tad/incidents/`（该路径不存在） |
| violations | 2 | `.tad/logs/violations.log` |
| 归档 | 332 HANDOFF + 214 COMPLETION | `.tad/archive/handoffs/` |

⚠️ **语料有副本陷阱**：`.claude/worktrees/wf_*/` ×4 与 `.tad.backup.20260609_083936/` 各含一份完整知识语料副本（`principles.md` 实测存在 6 份）。**载体路径必须落在 `.tad/` 内且不含 `.claude/worktrees/` 或 `.tad.backup.`**（AC2 会验）。

### 2.3 Dependencies

无外部依赖。⚠️ `.tad/active/handoffs/` 内另有 `LITE-20260811-2254-dependency-ops-skill.md`（已验收待归档）及其 `.txn-lock`——方向互斥规则保证不冲突，但**它的 staged 文件会让 Row 10 的绝对量永不为 0**，故 Row 10 改为 T=0 delta 比对（见 §6 Step 0）。

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1：从三个来源**机械枚举**全部纪律
- FR2：为每条纪律**留痕检索**实例，标注载体、类型、严重度
- FR3：四类判定（三类 + 威慑型免死条款）
- FR4：地板 / 可缩放判定，**且须重新质询 Epic 草稿的既有标签**
- FR5：产出形态 A + 形态 B + 检索留痕 + 校验脚本
- FR6：spawn 被指派回答"这张表的形状装不下什么"的独立 reviewer

### 3.2 Non-Functional Requirements

- 成本栏只含可数量（AC4）；头部含偏差声明（AC9）
- 不含**触发规格**（定义见下），不改任何 skill / CLAUDE.md，不做最终裁定（AC8）

> **触发规格的正定义**（v1 只给了反例词表，不可判）：
> **任何把纪律绑定到可判定阈值的表述，形如「{数量/条件} → {走 X 档 / 用 Y 流程}」。**
> 仅描述"这条纪律代价是 N 轮"**不算**规格；写出"N 轮以上就该走重档"**算**规格。

---

## 4. Technical Design

### 4.1 Architecture Overview

无运行时架构。产物：三份 Markdown + 一个 `verify.py`。

### 4.2 形态 A 的列定义（**九列，顺序固定，逐字**）

```
| 纪律 | 来源 | 成本 | 频率 | 实例 | 三类判定 | 触发条件 | 地板·可缩放 | 建议 |
```

| 列 | 取值约束 |
|---|---|
| 纪律 | 名称 |
| 来源 | `full` / `lite` / `both` / `新增` |
| **成本** | **只填可数量**（如 `3-5轮问答`、`1次spawn`、`~5秒`）。出现形容词即 FAIL（AC4） |
| **频率**（v2 新增） | `每单` / `偶发` / `罕见` / `未知`。⚠️ 没有分母就算不出期望值——v1 缺这一列导致"值不值"无法判断 |
| 实例 | 见形态 B；此列填实例数与类型缩写，如 `2（缺席1/在场1）` |
| 三类判定 | `1-留` / `2-退场` / `3-挂起` / `4-威慑免死` |
| **触发条件** | 第 3 类**必填**；第 4 类必填（写明它防的不可逆后果） |
| **地板·可缩放** | `地板` / `可缩放` / `待判`。⚠️ **不得填"保留"这类处置结论**——那是别的问题的答案（v1 的两行就是这么填错的） |
| 建议 | 可空 **except**：仅有缺席致害型实例的行**不得为空**，须含"证据类型受限"字样 |

### 4.3 Data Flow

```
Step 0  记录 T=0 git 基线
   ▼
Phase A  三来源机械枚举（⚠️ 先不读 Epic 草稿的处置结论）
   ▼
Phase B  逐条留痕检索（3 关键词 × 4 语料，命中数全记）
   ▼
Phase C  四类判定 + 频率 + 严重度 + 地板/可缩放（含重新质询 Epic 旧标签）
   ▼
Phase C' 与 Epic 11 行草稿做差异比对（← 此时才读它的处置结论列）
   ▼
形态 A / 形态 B / search-log.md / verify.py
   ▼
Phase D  AC7 形状盲区 reviewer → shape-blindspot-review.md
```

### 4.4 判定规则（逐字执行）

**四类**（v2 新增第 4 类）：

| 类 | 判据 | 处置 | 举证要求 |
|---|---|---|---|
| **1-留** | 有实例（抓到过，或缺席导致过事故） | 留 | 载体（AC2） |
| **2-退场** | 无实例，**但触发条件出现过** | 退场 | ⚠️ **必须写出"曾出现的具体场景 + 检索过的语料源"**（AC12）——v1 此类零举证，而它是唯一净删除的类别 |
| **3-挂起** | 无实例，且触发条件从未出现 | 挂起 | 必须写出**具体触发条件**；写不出降为第 2 类 |
| **4-威慑免死**（v2 新增） | 无实例，且其失效场景理论上会造成**不可逆或高严重度**后果 | **不得自动降级，交人工复核** | 必须写明它防的那个不可逆后果 |

> **为什么要第 4 类**：靠"存在本身让坏事不发生"的纪律（威慑型），从没抓到过东西（坏事没发生到需拦截），也没有缺席致害记录（它一直没缺席）。按三类它必然落进第 3 类 → 写不出一次性触发条件 → 自动降第 2 类退场。
> **它工作得越好，判据越倾向把它判死。** 第 4 类是这个结构性缺陷的补丁。

**实例类型（必须标注，v2 增至三种）**：

| 类型 | 含义 | 证据强度 |
|---|---|---|
| **缺席致害型** | 没有它，出了 X 事 | 证明**它该在**，不证明它有效 |
| **在场生效型** | 有它，抓到了 X | 证明**它有效** |
| **合成型**（v2 新增） | 对抗测试 / 演习产生，非自然发生 | **弱**。⚠️ 不得单独作为第 1 类"留"的唯一依据，须配一个自然发生实例 |

**每个实例还须标严重度**：`高`（不可逆/安全/数据）/ `中` / `低`。
> 理由：一次"文档格式不对"和一次"token 泄露"在 v1 的 schema 里长得一模一样。

**证据冲突处理**（v2 新增）：一条纪律同时有"至少一个正面实例"与"多次有机会未抓住"时，**不适用一票通过**——形态 B 必须**并列陈述两类证据**，形态 A 的建议栏须注明"证据冲突"。

### 4.5 地板 vs 可缩放（假设，须被质询）

**假设**：「动手之前」的纪律多半是**地板**；「做完之后」的验证多半**可缩放**。

⚠️ **这是待证伪的假设，不是判定规则。** 已知它至少有一个反例：Epic 草稿把「门禁」（含 Gate 3/4，都是"做完之后"）标成了**地板**，与假设方向相反。

**AC13 强制要求**：Blake 对每条纪律的地板/可缩放判定必须附**一句可证伪理由**，且对 Epic 草稿已有的标签（尤其「门禁=地板」「Execution Mandate=保留」「约束准入=保留」）**逐条重新质询**，不得默认沿用。

---

## 5. Mandatory Questions

- **MQ1 需求完整性**：§1.3 + §9（13 条 AC）
- **MQ2 函数存在性**：N/A（无代码调用）；`verify.py` 由本单创建，其正确性由 §9.1 各行的期望输出反验
- **MQ3 数据流完整性**：§4.3
- **MQ4 视觉层级**：N/A（无 UI 产物）
- **MQ5 状态同步**：N/A（无运行时状态）
- **MQ6 研究充分性**：语料已实测（§2.2/§8.4），检索方法已给逐字模板（§6 Phase B）

---

## 6. Implementation Steps

### Step 0 —— T=0 基线（必做，30 秒）

```bash
R="/path/to/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"
mkdir -p "$D"
git -C "$R" status --porcelain > "$D/git-baseline-t0.txt"
git -C "$R" rev-parse HEAD >> "$D/git-baseline-t0.txt"
test -s "$D/git-baseline-t0.txt" && echo "T0-OK"
```
⚠️ `test -s` 不可省（重定向早于命令查找，失败会留空文件）。

### Phase A —— 独立机械枚举（45 分钟）

⚠️ **顺序是本 Phase 的核心，不可颠倒**（Preview Anchoring，见 §📚）：

1. **先**从三个来源独立枚举，**此时不读 Epic 草稿的处置结论列**：
   - 来源1：`CLAUDE.md §3` 规则 0–5
   - 来源2：`.claude/skills/alex/SKILL.md` + `blake/SKILL.md` 的 gates / protocols / forbidden
   - 来源3：`.claude/skills/alex-lite/SKILL.md` + `blake-lite/SKILL.md` 的脊柱 + 内置约束
2. **什么构成"纪律"**（v2 新增判准，防止这一步变成未被承认的主观筛选）——**同时满足**：
   - (a) 语气含 `MUST` / `MANDATORY` / `BLOCKING` / `必须` / `禁止` / `不得` 之一，**或**是一个具名的 Gate / 检查点
   - (b) 被违反时有**可观测后果**（有人会发现、有东西会红、有记录会留下）
   - 不满足即不是纪律，但**须列进 `enumeration-diff.md` 并写明为何排除**
3. 去重合并 → 写 `enumeration-diff.md`，**骨架逐字如下**：
```
- **来源1** CLAUDE.md §3 规则0–5：N=__
- **来源2** full SKILL（alex+blake）gates/protocols/forbidden：N=__
- **来源3** lite SKILL（alex-lite+blake-lite）脊柱+内置约束：N=__
- 去重合并 合计=__

| 项 | 在初稿11行中? | 在本次枚举中? | 说明 |
```
4. **此时才**读 Epic 的 11 行草稿表，逐条填上表的后三列（差异比对）。

### Phase B —— 留痕检索（180 分钟；v1 的 90 分钟不可信）

5. 对**每一条**纪律，先定 3 个检索关键词，再跑**逐字模板**：
```bash
R="/path/to/TAD"
for kw in "<kw1>" "<kw2>" "<kw3>"; do
  for corpus in "$R/.tad/project-knowledge/principles.md" \
                "$R/.tad/project-knowledge/patterns" \
                "$R/.tad/project-knowledge/incidents" \
                "$R/.tad/logs/violations.log"; do
    printf '%s | %s -> ' "$kw" "$corpus"
    command grep -rn "$kw" "$corpus" 2>/dev/null | wc -l
  done
done
```
⚠️ 用 `command grep`（绕过 ugrep 的 `--ignore-files`）。
6. 归档语料**有界**：`command grep -rl "<kw>" "$R/.tad/archive/handoffs/COMPLETION-"*.md | head -5`，上限 5 个，写进留痕。
7. 全部命中数写入 `search-log.md`，**每条纪律一个 `## ` 块**（AC10 会数块数）。
8. 载体格式**逐字钉死**：`` `<相对仓库根的路径>#L<行号>` + 该行的逐字片段（≥12 字符，原样复制，不得意译） ``
   ⚠️ 路径不得含 `.claude/worktrees/` 或 `.tad.backup.`

### Phase C —— 判定与产出（60 分钟）

9. 四类判定 + 频率 + 严重度 + 地板/可缩放（含 AC13 的重新质询）
10. 写形态 A（九列）+ 形态 B + 头部偏差声明
11. 写 `verify.py`（§9.1 各行调用它，子命令见下）

### Phase D —— 形状盲区审查（20 分钟）⚠️ 不可省

12. spawn 独立 reviewer。`shape-blindspot-review.md` **必须严格三段，分隔行逐字**：
```
<!-- REVIEWER-IDENTITY -->
<!-- PROMPT -->
<!-- RAW-ANSWER -->
```
题面写在 PROMPT 段，**必须含"装不下"，不得含"对不对"或"是否正确"**；原始回答整段落在 RAW-ANSWER 之后，不得改写、不得摘要。

---

## 7. File Structure

### 7.1 Files to Create

| 文件（均在 `$D/`） | 内容 |
|---|---|
| `git-baseline-t0.txt` | Step 0 基线 |
| `enumeration-diff.md` | Phase A 骨架 + 差异表 |
| `search-log.md` | 每条纪律一个 `## ` 块，含 3×4 命中数 |
| `discipline-inventory.md` | 形态 A（九列） |
| `discipline-provenance.md` | 形态 B |
| `shape-blindspot-review.md` | AC7 三段式 |
| `verify.py` | 校验脚本，子命令：`cost` / `class3` / `class2` / `carriers` / `types` / `single-type` / `floor` / `blindspot` |

### 7.2 Files to Modify

无。

### 7.3 Grounded Against

- **Base commit**: `6ae6e04db79e7dc1e0f1c89705eddd07c69396c7`
- 开工时 dirty tracked：49（`git status --porcelain | grep -vc '^??'`）
- ⚠️ 若开工时 HEAD 已变，先报告再决定

---

## 8. Testing Requirements

### 8.1 / 8.2 Unit & Integration Tests

N/A —— 无代码产出。`verify.py` 的正确性由 §9.1 的期望输出反验（每个子命令有确定的期望字符串）。

### 8.3 Edge Cases

| 情况 | 处理 |
|---|---|
| 一条纪律 full/lite 都有但形态不同 | 同一行，差异写进"来源"栏（填 `both`） |
| 实例 >3 个 | 取最强 2 个（缺席+在场各一为佳），其余只计数 |
| 实例仅来自本 session 对话 | 允许，但须标注 `仅此一例·本session` |
| 枚举出 >20 条 | 不截断；判定栏可写 `不构成纪律：<理由>` ⚠️ 用**尖括号**不用花括号（花括号会撞 Row 2 的占位符检测） |

### 8.4 Friction Preflight

| 前置项 | 状态 | 产生该判定的命令 |
|---|---|---|
| 独立 reviewer 可用 | READY | Agent tool 可用（v1 已实际 spawn 2 个） |
| 知识条目 183 | READY | `grep -c '^### ' patterns/*.md principles.md \| awk -F: '{s+=$2}END{print s}'` |
| incidents **25+_index** | READY | `ls .tad/project-knowledge/incidents/**/*.md \| wc -l` ⚠️ **v1 写 `.tad/incidents/`，该路径不存在** |
| violations 2 | READY | `wc -l < .tad/logs/violations.log` |
| 归档 332+214 | READY | `ls .tad/archive/handoffs/HANDOFF-*.md \| wc -l` |
| `python3` 可用 | READY | `/usr/bin/python3 --version` → 3.9.6 |
| **非自指样本** | **BLOCKED（已知且接受）** | 全部证据来自 TAD 自身框架工作。Phase 5 才能解决，**本单只声明不解决**（AC9）。⚠️ 是 `BLOCKED` 不是 `NOT_APPLICABLE` |

### 8.6 Test Evidence Required

`enumeration-diff.md` / `search-log.md` / 全部实例载体（可独立 grep）/ AC7 原始回答全文 / `verify.py` 各子命令输出

---

## 9. Acceptance Criteria

- **AC1**：三来源机械枚举，**九列齐全**（列顺序与 §4.2 逐字一致），核心列（成本/频率/实例/三类判定/地板·可缩放）不得为空，无 TBD
- **AC2**：每条实例引用 `路径#L行号 + ≥12 字符逐字片段`，路径落在 `.tad/` 内且不含 `.claude/worktrees/` / `.tad.backup.`。**不得用中文意译当标题引用**
- **AC3**：第 3 类必须写出具体触发条件；写不出降为第 2 类
- **AC4**：成本栏**只填可数项**，出现 `贵/便宜/值得/划算/繁琐/沉重/轻松` 即 FAIL
- **AC5**：每个实例标注**类型（缺席致害/在场生效/合成）+ 严重度（高/中/低）**。仅有缺席致害型实例的纪律，其**建议栏不得为空**，须含"证据类型受限"
- **AC6**：lite 侧机制（Execution Mandate、**约束准入**）与 full 侧同表呈现，过同一套判据。⚠️ 术语按 lite SKILL 原文为 **`约束准入`**（实测 alex-lite 2 处 / blake-lite 1 处，载体 `lite-constraint-ledger`），**不是「约束准入台账」**
- **AC7**：独立 reviewer 被指派回答"**这张表的形状装不下什么**"，三段式落盘，题面含"装不下"且不含"对不对/是否正确"
- **AC8**：产出形态 A + B。**不含触发规格**（正定义见 §3.2），不改任何 skill / CLAUDE.md，不做最终裁定
- **AC9**：头部**逐字包含**这一行：
  `> 已知偏差：本清单证据几乎全部来自 TAD 自身的框架工作（自指）。非自指样本为 0。`
- **AC10（v2 新增·检索留痕）**：**每一条**纪律附检索留痕（≥3 关键词 × ≥4 语料 + 每次命中数）。判为第 2/3/4 类的行，其留痕必须显示这些检索**全部为空**。无留痕的"无实例"判定视为未执行 → FAIL
- **AC11（v2 新增·阳性对照）**：下列 3 条已知实例必须出现在产物中，缺任一即判检索不足 → FAIL：
  (a) `principles.md` "Express Handoff is NOT Review-Exemption - 2026-04-14"（专家审查的**在场生效型**实例）
  (b) `.tad/logs/violations.log` 第 2 行 2026-08-02（「Alex 不写代码」的**缺席致害型**实例）
  (c) `EPIC-20260809-...` 的 `urgent_security` 28 天（启动扫描的**缺席致害型**实例）
  ⚠️ **只做下限校准，不做上限**——3/3 命中不代表检索充分，只代表没有全空转
- **AC12（v2 新增·第2类举证）**：每个第 2 类行必须写出"曾出现的具体触发场景 + 检索过的语料源列表"。⚠️ 第 2 类是唯一净删除的类别，v1 对它零举证
- **AC13（v2 新增·地板判定可证伪）**：每个地板/可缩放判定附**一句可证伪理由**（不能只是标签）；且对 Epic 草稿的既有标签（「门禁=地板」「Execution Mandate=保留」「约束准入=保留」）**逐条重新质询**，结论写进 `enumeration-diff.md`

### 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

⚠️ **命令一律从下方代码块复制，绝不要从表格复制。**
markdown 表格要求 `|` 转义为 `\|`，逐字复制出来 shell 会把 `\|\|` 当成两个**文件名**，
且 `-E` 里的 `\|` 是**字面竖线**导致正则退化为常量。实测：
```
$ command grep -ciE 'TBD\|待填' f \|\| true
grep: ||: No such file or directory
grep: true: No such file or directory
```
**这与 v1 的 P0-2 是同一个 bug，只是换了一层——本表因此改为「表格给 ID，代码块给命令」。**

| # | 要求 | 命令 ID | Expected Evidence |
|---|---|---|---|
| 1 | AC1 三来源枚举 | `V1` | 第一条 `3`；第二条 `1` |
| 2 | AC1 无 TBD | `V2` | `0`（`-c` 数的是行数） |
| 3 | AC2 载体全验（不抽样） | `V3` | `checked=<N> ok=<N> bad=0` |
| 4 | AC3 第3类有触发条件 | `V4` | `class3_missing_trigger=0 []` |
| 5 | AC4 成本无形容词 | `V5` | `成本col=<n> violations=0 []`；列名缺失 → ValueError → FAIL |
| 6 | AC5 实例类型+严重度 | `V6` | `instances=<N> typed=<N> severity=<N>`，三数相等 |
| 7 | AC5 单类型警示 | `V7` | `only_absence=<N> warned=<N>`，两数相等 |
| 8 | AC6 对称审查 | `V8` | 前两条均 `≥1`；第三条 `floor_missing_reason=0 []` |
| 9 | AC7 盲区审查 | `V9` | `has_model=True` / `prompt_has_装不下=True` / `prompt_has_forbidden=False` / `answer_len>=200` |
| 10 | AC8 零改动（T=0 delta） | `V10` | `diff_exit=0` 且无 diff 输出行；基线文件不存在 → FAIL |
| 11 | AC8 无触发规格 | `V11` | **两行**，形如 `<abs-path>:0`（顺序不定，按路径判读）。任一 >0 须在 `enumeration-diff.md` 说明 |
| 12 | AC9 偏差声明 | `V12` | `exit=0`（整行逐字匹配） |
| 13 | AC10 检索留痕 | `V13` | `blocks=<N>` == 形态 A 数据行数 |
| 14 | AC11 阳性对照 | `V14` | 三行均 `≥1` |
| 15 | AC12 第2类举证 | `V15` | `class2_missing_evidence=0 []` |
| 16 | AC13 地板理由 + 旧标签质询 | `V16` | 前者 `floor_missing_reason=0 []`；后者 `≥3` |

#### 验证命令（⚠️ 复制这里，不要复制上表）

```bash
R="/path/to/TAD"
D="$R/.tad/evidence/designs/discipline-inventory"

# V1  AC1 三来源枚举
command grep -cE '^- \*\*来源[123]\*\*' "$D/enumeration-diff.md" || true
command grep -c  '^- 去重合并 合计='        "$D/enumeration-diff.md" || true

# V2  AC1 无 TBD
command grep -ciE 'TBD|待填|待补|＿＿' "$D/discipline-inventory.md" || true

# V3  AC2 载体全验
/usr/bin/python3 "$D/verify.py" carriers

# V4  AC3 第3类触发条件
/usr/bin/python3 "$D/verify.py" class3

# V5  AC4 成本无形容词
/usr/bin/python3 "$D/verify.py" cost

# V6  AC5 实例类型+严重度
/usr/bin/python3 "$D/verify.py" types

# V7  AC5 单类型警示
/usr/bin/python3 "$D/verify.py" single-type

# V8  AC6 对称审查
command grep -c 'Execution Mandate' "$D/discipline-inventory.md" || true
command grep -c '约束准入'           "$D/discipline-inventory.md" || true
/usr/bin/python3 "$D/verify.py" floor

# V9  AC7 盲区审查
/usr/bin/python3 "$D/verify.py" blindspot

# V10 AC8 零改动（相对 T=0 基线的 delta）
F='(^|[ /])CLAUDE\.md$|\.claude/skills/|\.agents/skills/'
diff <(command grep -E "$F" "$D/git-baseline-t0.txt" | sort; true) \
     <(git -C "$R" status --porcelain | command grep -E "$F" | sort; true)
echo "diff_exit=$?"

# V11 AC8 无触发规格
command grep -cinE '触发规格|轻档.*重档|怎么算过|[0-9]+ *(条|个|文件|轮|次).*(→|则|就|即).*(走|用|升|降)|≥ *[0-9]+.*(则|→)' \
  "$D/discipline-inventory.md" "$D/discipline-provenance.md" || true

# V12 AC9 偏差声明（整行逐字）
command grep -Fxq '> 已知偏差：本清单证据几乎全部来自 TAD 自身的框架工作（自指）。非自指样本为 0。' \
  "$D/discipline-inventory.md"; echo "exit=$?"

# V13 AC10 检索留痕块数
/usr/bin/python3 -c "import re,pathlib,sys;t=pathlib.Path(sys.argv[1]).read_text(encoding='utf-8');print('blocks=',len(re.findall(r'^## ',t,re.M)))" "$D/search-log.md"
/usr/bin/python3 "$D/verify.py" rows

# V14 AC11 阳性对照
for s in 'Express Handoff is NOT Review-Exemption' 'violations.log' 'urgent_security'; do
  printf '%s -> ' "$s"
  command grep -c "$s" "$D/discipline-provenance.md" || true
done

# V15 AC12 第2类举证
/usr/bin/python3 "$D/verify.py" class2

# V16 AC13 地板理由 + 旧标签质询
/usr/bin/python3 "$D/verify.py" floor
command grep -c '重新质询' "$D/enumeration-diff.md" || true
```

### 9.2 Expert Review Status

#### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| code-reviewer | P0-1 Row 10 在 T=0 已 FAIL（实测返回 2） | §6 Step 0 + §9.1 #10 | ✅ fixed |
| code-reviewer | P0-2 Row 11 `\|` 在 `-E` 下失效 → 永真 PASS（实测 fixture 3 命中报 0） | §0 + §9.1 #11 + §3.2 正定义 | ✅ fixed |
| code-reviewer | P0-3 Row 5「成本栏区域」不可运行 | §9.1 #5（`verify.py cost`） | ✅ fixed |
| code-reviewer | P0-4 9 条 AC 对敷衍产物 9/9 全绿（实跑证明） | AC10 + AC11 + §9.1 #13/#14 | ✅ fixed |
| code-reviewer | P0-5 `.tad/incidents/` 不存在，§8.4 假 READY | §2.2 + §8.4（附命令） | ✅ fixed |
| code-reviewer | P0-6 Row 4 查不存在的列；AC1「四栏」vs §4.2「七栏」互斥 | §4.2 九列固定 + AC1 改写 | ✅ fixed |
| code-reviewer | P0-7 第 1/3/6/7/9 行无可运行命令 | §9.1 全表重写 + `verify.py` | ✅ fixed |
| code-reviewer | P0-8 禁用 awk 做 CJK 比较 | §0 环境约束 | ✅ fixed |
| code-reviewer | P1-5「约束准入台账」不在 lite SKILL | AC6 —— ⚠️ **部分不成立**：实测 `约束准入` 在 alex-lite 2 处 / blake-lite 1 处；仅"台账"二字是 Alex 加的。已按实测改术语 | ⚠️ corrected |
| product-expert | P0-A 第 2 类零验证（唯一净删除类别） | AC12 + §9.1 #15 | ✅ fixed |
| product-expert | P0-B 地板/可缩放栏无验证，且 Epic 旧标签会被沿用 | AC13 + §9.1 #16 + §4.5 | ✅ fixed |
| product-expert | P0-C Preview Anchoring（先读 Epic 结论再"独立"枚举） | §6 Phase A 顺序 + Phase C' | ✅ fixed |
| product-expert | P1 威慑型纪律被结构性判死 | §4.4 第 4 类 | ✅ fixed |
| product-expert | P1 实例缺合成型；缺严重度；缺频率分母 | §4.4 三类型+严重度；§4.2 频率列 | ✅ fixed |
| product-expert | P1 建议栏可空 → 单类型警示不传导 | §4.2 建议栏约束 + AC5 | ✅ fixed |
| product-expert | P1 第 1 类证据冲突无优先级 | §4.4 证据冲突处理 | ✅ fixed |
| product-expert | P1「什么构成纪律」是未承认的主观筛选 | §6 Phase A 第 2 步判准 | ✅ fixed |
| product-expert | P0-Q5 行级判定零交叉验证 | ⚠️ **未修，已知取舍** —— 见 §10.2 | ⚠️ accepted |

#### Experts Selected
- `code-reviewer`（维度：AC 可执行性）—— verdict **FAIL**，P0=8 / P1=8 / P2=4
- `product-expert`（维度：判断规则成立性）—— verdict **CONDITIONAL**，P0=3 / P1=4 / P2=2

#### Overall Assessment (post-integration)
- 11 个 P0 全部修订；1 个 P1 经实测**部分推翻**（约束准入术语）并按实测修正
- **1 个 P0 级问题未修，作为已知取舍记入 §10.2**（行级交叉验证）

---

## 10. Important Notes

### 10.1 Critical Warnings

⚠️ **利益冲突之一（v1 已声明）**：Alex 对"对自己便宜的"有偏好。缓解 = AC4（成本栏只填可数项）。

⚠️ **利益冲突之二（v2 新发现，AC4 管不到）**：product-expert 指出——Epic 草稿表里，**Alex 自己设计的 lite 机制已预判"保留"，而 full 侧机制大多标"待判"**。这不是"对便宜的偏好"，是**对"自己设计的机制"的偏好**，它不在成本栏，AC4 完全管不到。
**缓解 = §6 Phase A 的顺序（先独立枚举后读草稿）+ AC13（逐条重新质询旧标签）。**
**Blake 若发现 Alex 在草稿里已写倾向性结论，必须按 AC13 重新过判据，不得沿用。**

⚠️ **v1 的三处知识引用是中文意译，语料中逐字不存在**（实测命中 0）。这与 §📚 引用的 `ac-verification.md#L310` 第 (1) 条是同一个错误。**Blake 引用任何条目必须用逐字标题 + 行号。**

⚠️ **风险分析是单方的**：Socratic Q4 第一步用户答"想不到"，四条风险全部出自 Alex——而 Alex 是被审对象。已入 AC9 偏差声明。

### 10.2 Known Constraints / 已知取舍

- **行级判定零交叉验证（未修的 P0 级问题）**：两位 Gate 2 专家审的是**规则**；AC7 的 reviewer 被明确禁止回答"对不对"。**结果是每一行的实际判定只有 Blake 一人做过。**
  **不修的理由**：加一层行级复核会让本单体量再翻倍，而本单的产物本来就是"给人拍板的输入"而非"结论"——**人在拍板时就是那一层交叉验证**。
  ⚠️ **但这个取舍必须让拍板者知道**：形态 A 头部除 AC9 的偏差声明外，须另加一行：
  `> 本表每一行的判定由单一执行者产出，未经行级独立复核。拍板前请抽查。`
- `violations.log` 仅 2 条，**不足以支撑任何频率/趋势结论**
- 全部证据自指，非自指样本为 0
- Epic 的 11 行草稿由 Alex 所写，**已知至少漏过 3 类东西**——当起点，不当基准

### 10.3 Sub-Agent 使用建议

Gate 2 已完成（2 位，见 §9.2）。**执行期另需 1 位**（AC7，与上述两位不同 spawn）：

| Reviewer | 指派问题 |
|---|---|
| `general-purpose` | **"这张表的形状装不下什么？"** —— 明确不是"这张表对不对" |

---

## 11. Learning Content

### 11.1 Decision Rationale：为什么判据是"实例"而不是"重要性"

**候选**：① 按重要性打分 ② 按成本-收益比 ③ **按"有没有防住过东西"分类** ← 选定

**为什么选 ③**：①② 都依赖**评分者的判断**，而评分者（Alex）是被审对象，且上一次正是按"成本高不高"删错。③ 的判据是**外部事实**（某个文件某一行有没有记录），可被独立 grep 验证。

**代价**：会有一批纪律落进"无实例"。这是诚实的代价——**"没证据"和"没价值"是两回事**，第 3/4 类就是为了不把这两者混为一谈。

**v2 补充**：product-expert 指出 ③ 仍有漏洞——**举证责任不对称**（第 1/3 类要举证，第 2 类不用），而不对称的方向正好朝着删除。AC12 是这个漏洞的补丁。

---

## 12. Sub-Agent 使用记录

- Gate 2：`code-reviewer`（AC 可执行性，FAIL/8×P0）、`product-expert`（判断规则，CONDITIONAL/3×P0）
- 执行期：**待填**
