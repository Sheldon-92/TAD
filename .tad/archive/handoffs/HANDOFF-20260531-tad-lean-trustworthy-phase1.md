---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: code       # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no - yes 时 Blake 必须产出 E2E evidence
research_required: no # yes | no - yes 时 Blake 必须产出研究文件

git_tracked_dirs: []

skip_knowledge_assessment: no  # yes | no

gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-31
**Project:** TAD Framework
**Task ID:** TASK-20260531-tad-lean-trustworthy-phase1
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260531-tad-lean-trustworthy.md (Phase 1/5)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-31

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 单文件 awk 重写 + 6 文件删除 + 1 yaml 计数和解；无新增组件 |
| Components Specified | ✅ | `emit_decision_points()` 头部感知索引算法完整规格在 §4.2/§6 |
| Functions Verified | ✅ | `emit_decision_points`/`trace_decision_point` 均存在（见 MQ2 表）；调用点行 ~273 dedup 闸门已核实 |
| Data Flow Mapped | ✅ | §11 表格 → awk 解析 → SEP 分隔行 → trace_decision_point；4-col/5-col 双形态映射在 §4.3 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
将 `.tad/hooks/post-write-sync.sh` 的 `emit_decision_points()` 从**硬编码位置索引**（`d=a[3]; c=a[5]; r=a[6]`，line 188）改为**列名感知（header-aware）索引**：解析 §11 Decision Summary 表格的表头行，按列名 `Decision`/`Chosen`/`Rationale` 定位 awk 数组下标，再按下标读取数据行。同时删除 6 个被拒绝的、无内容的 dream-candidate 空壳文件，并和解 `dream-state.yaml` 计数。

### 1.2 Why We're Building It
**业务价值**：trace 决策语料是 TAD 自演化（*evolve / dream-scanner）的核心数据层。当前硬编码索引对 4 列表格（`| # | Decision | Chosen | Rationale |`）**静默错列**——`chosen` 字段装的是 Rationale 文本、`rationale` 字段为空，真正的 Chosen 值被丢弃。约 52% 的真实决策语料被这样污染。
**用户受益**：修复后，决策语料可信，下游 *evolve / human_override 队列不再消费错列数据。
**成功的样子**：当 4 列与 5 列 §11 表格都被正确解析（chosen/rationale 各归各位），并且历史 append-only trace 不被改动（仅加 cutoff 注释），这个修复就成功了。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：trace 生产端（producer）的列契约从隐式位置假设升级为显式按名映射，使其对任意列排布健壮。这是项目自身 ".router.log 5-Tuple load-bearing contract" + "Parser must propagate VALUE fields" 两条教训的复发——契约从 scanner（已正确）下移到了 producer（有 bug）。

**不是要做的（避免误解）**：
- ❌ 不是修复/重发历史已污染的 trace 事件（trace 是 append-only；最多加一行 cutoff 注释）
- ❌ 不是改 trace JSON schema 或 `trace_decision_point` 签名
- ❌ 不是动 `dream-scanner.sh` Pass C（它已经正确读 chosen/rationale；bug 在上游 producer）
- ❌ 不是动 `emit_expert_findings`(170) 或 `emit_reflexions`(213)
- ❌ 不是动调用点 line ~273 的 per-(slug,day) dedup 闸门

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 4-col 与 5-col 表格分别如何被错列 / 正确解析？
3. 成功的标准是什么？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed in 步骤 2 below
2. Read the handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

### 步骤 1：识别相关类别

本次任务涉及的领域（勾选所有适用项）：
- [x] code-quality - 代码模式/反模式（awk/shell 解析、grep AC 验证漂移）
- [ ] security
- [ ] ux
- [x] architecture - 消费契约/observational trace/parser self-trigger
- [ ] performance
- [x] testing - dry-run 验证、fault-injection、raw-recompute
- [ ] api-integration
- [ ] mobile-platform

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | (1) Observational trace + 稳定 marker 契约；(2) Parser Self-Trigger（evidence prose 引用 parser 字面 pattern 会自触发）；(3) Parser 必须传播 VALUE 字段，不只是 key |
| code-quality.md | 2 条 | (1) Heredoc 注入取决于 SINK（file-write ≠ interpreter-exec）——本任务 awk 内不内插用户值，无注入面；(2) AC grep-count 漂移：grep -c + sort -u\|wc -l 恒返回 1 |
| security.md | 0 条 | 无相关历史记录 |

**⚠️ Blake 必须注意的历史教训**：

1. **Parser Self-Trigger** (来自 architecture.md, 2026-05-30)
   - 问题：任何 evidence/review 文件的 PROSE 若引用 parser 匹配的字面 pattern（如写一个真实的 `| # | Decision | Chosen | Rationale |` 表格，或带 `Chosen` 表头），会被本 parser 扫到并自触发，向真实 trace 注入假 decision_point。
   - 解决方案：所有 COMPLETION / dry-run / review 文件中，**绝不**写真实的 §11 形态表格、绝不放裸露的 `Chosen` 表头行。用 paraphrase（如 "the chosen-column" 加引号、或截图式代码块包裹）。详见 §10.1。

2. **Parser 必须传播 VALUE 字段，不只是 key** (来自 architecture.md, 2026-05-31)
   - 问题：consumer/parser 容易只抓 label 丢掉 value，发出"看似有内容、实则空"的事件。
   - 解决方案：本修复的整个目的就是让 chosen/rationale 的 VALUE 正确归位。AC1.2 必须 raw-recompute 真实 cell 文本，不能只看"发出了一个事件"。

3. **AC grep-count 漂移 / dry-run on real artifact** (来自 code-quality.md, 2026-05-27)
   - 问题：AC 验证命令未在真实 artifact 上 dry-run 就发布，跑起来才暴露。
   - 解决方案：§9.1 的 post-impl 命令 Blake 必须在两个真实归档 handoff 上实跑并贴原始输出。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
`emit_decision_points()` 在 Auto-Evolve Epic 的 trace-instrumentation-fix 中作为 observational producer 引入（FR4）。当时只用 5 列表格验证，硬编码 `a[3]/a[5]/a[6]` 在 5 列下恰好正确，故 bug 潜伏。

### 2.2 Current State
现状（line 172-209）：
- line 173 注释：`Column contract: | # | Decision | Options | Chosen | Rationale | → $3 / $5 / $6.`
- line 188：`d=a[3]; c=a[5]; r=a[6]` — 硬编码位置。
- `n=split($0, a, "|")`：markdown 行首 `|` 前产生空 a[1]，行尾 `|` 后产生空尾字段。

**5-col** `| # | Decision | Options | Chosen | Rationale |` → a[2]=#, a[3]=Decision, a[4]=Options, a[5]=Chosen, a[6]=Rationale。当前 d=a[3]✓ c=a[5]✓ r=a[6]✓ **正确**。
**4-col** `| # | Decision | Chosen | Rationale |` → a[2]=#, a[3]=Decision, a[4]=Chosen, a[5]=Rationale, a[6]=""。当前 d=a[3]✓ c=a[5]=**Rationale**✗ r=a[6]=**空**✗ **错列**。

目标：表头感知映射，4-col / 5-col / 任意未来列排布皆正确。

### 2.3 Dependencies
无。可独立执行。下游 dream-scanner.sh Pass C 已正确读 chosen/rationale，不动。

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1**: `emit_decision_points()` 在 `## ... Decision Summary` 段内，检测表头行（第一条 `^\|` 行，其 trimmed cell 同时含 `Decision` 与 `Chosen`，大小写不敏感），记录 `Decision`/`Chosen`/`Rationale` 三列的 awk 数组下标。
- **FR2**: 后续数据行按 FR1 记录的动态下标读取 d/c/r，替代硬编码 a[3]/a[5]/a[6]。须正确处理 4-col 与 5-col 两种形态。
- **FR3**: 若段内未找到同时含 Decision+Chosen 的表头 → 不发出任何事件（graceful skip，无 junk）。
- **FR4**: 保留以下全部既有行为：
  - separator row 跳过（`^\|[-: |]+\|[[:space:]]*$`）
  - 每个 cell trim（`gsub(/^[[:space:]]+|[[:space:]]+$/,"")`）
  - override-marker 扫描（在 chosen+rationale 上扫 `用户选`/`user chose`/`human override`/`人类决策`）
  - `tr -d '\r\n' | cut -c1-200` 截断
  - 每条解析路径 `|| true` fail-open
  - 调用点 line ~273 的 per-(slug,day) dedup 闸门（**不动**）
- **FR5**: 删除 6 个 rejected dead-candidate 文件；和解 dream-state.yaml 计数；不动任何 pending candidate。

### 3.2 Non-Functional Requirements
- **NFR1**: hook 永不 fail-closed（SAFETY）。任何 awk/解析失败 → 静默 skip，绝不阻断 PostToolUse。
- **NFR2**: BSD-safe（macOS）。awk 用 POSIX 子集；不用 GNU 扩展、不用 `grep -P`。
- **NFR3**: 行为对历史 trace append-only：不改、不重发既有事件（最多加一行 cutoff 注释）。

### 3.3 Optimization Target
N/A（无数值优化目标，不触发 Autoresearch Mode）。

---

## 4. Technical Design

### 4.1 Architecture Overview
单文件、单函数重写 + 文件清理。无新增组件、无新依赖。数据流不变：§11 表格 → awk（now header-aware）→ SEP 分隔行 → while-read → `trace_decision_point`。

### 4.2 Component Specifications — header-aware awk 算法

在 `insec`（Decision Summary 段内）的 `/^\|/` 块中，分两类行处理：

1. **separator row**：`if ($0 ~ /^\|[-: |]+\|[[:space:]]*$/) next`（保留）。
2. **header row（尚未锁定列下标时）**：
   - `n=split($0, a, "|")`，对每个 `a[i]` trim 后求 `tolower`。
   - 找到 `tolower(cell)=="decision"` 的下标记为 `di`；`=="chosen"` 记为 `ci`；`=="rationale"` 记为 `ri`（rationale 可缺，缺则 `ri=0`）。
   - 若该行同时确定了 `di>0 && ci>0` → 设 `havehdr=1`，记录 di/ci/ri，`next`（表头本身不发事件）。
   - 若此行不满足（di 或 ci 缺）且尚未 havehdr → 视为非表头，`next`（不发）。
3. **data row（havehdr==1 之后）**：
   - `n=split($0, a, "|")`；`d=a[di]; c=a[ci]; r=(ri>0 ? a[ri] : "")`。
   - 三者 trim。
   - 若 `d==""||c==""` → `next`（空行/分隔残留）。
   - `printf "%s%s%s%s%s\n", d, SEP, c, SEP, r`。
4. **段结束 / havehdr 从未置位** → awk 自然产出空 → shell 端 `[ -n "$rows" ] || return 0` graceful skip。

> 注：旧代码靠 `d=="Decision"||c=="Chosen"` 字符串判等跳过表头行。新算法显式识别表头并锁定下标（更精确，4-col 不再错列），但 **data-row 阶段仍须保留大小写不敏感的表头守卫** `(tolower(d)=="decision" && tolower(c)=="chosen")`——多表 §11 段的第二张表表头会以 data row 身份到达（havehdr 首表锁定、不重锁），不拦会发 junk `Decision/Chosen/Rationale` 自触发事件（backend-architect Y4 P0，in-corpus: phase5-evolve-data-capture / phase6a）。保留 `d==""||c==""` 空值守卫。

### 4.3 Data Models — 双形态映射对照

| 表头形态 | split 数组 | di | ci | ri | 数据行映射 |
|---|---|---|---|---|---|
| 5-col `\| # \| Decision \| Options \| Chosen \| Rationale \|` | a[2..6] | 3 | 5 | 6 | d=a[3] c=a[5] r=a[6]（与旧码一致，无回归） |
| 4-col `\| # \| Decision \| Chosen \| Rationale \|` | a[2..5] | 3 | 4 | 5 | d=a[3] c=a[4] r=a[5]（旧码错列，新码修正） |
| 变体 `\| # \| Decision \| Options Considered \| Chosen \| Rationale \|` | a[2..6] | 3 | 5 | 6 | 同 5-col（`Options Considered` 非 Chosen/Rationale，忽略） |
| 无合法表头 | — | 0 | 0 | 0 | havehdr 未置位 → 不发任何事件 |

### 4.4 API Specifications
不变。`trace_decision_point "$d" "$c" "$r" "$slug" "$actor"` 签名与调用顺序保持。

### 4.5 User Interface Requirements
N/A（hook，无 UI）。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：
- [x] 是 → 继续填写下面（现有 `emit_decision_points` 是要改写的"原来的方案"）

#### 搜索证据
```bash
grep -n 'emit_decision_points\|d=a\[3\]\|Column contract' .tad/hooks/post-write-sync.sh
# 172: # FR4: parse §11 Decision Summary table ...
# 173: # Column contract: | # | Decision | Options | Chosen | Rationale | → $3 / $5 / $6.
# 174: emit_decision_points() {
# 188:       d=a[3]; c=a[5]; r=a[6]
# 274:       emit_decision_points "$FILE_PATH" "$_slug" || true
```

#### 决策说明
- **找到了什么**：现有 `emit_decision_points()` (174-210)，硬编码索引在 188。
- **位置**：`.tad/hooks/post-write-sync.sh:174-210`，调用点 `:273-275`。
- **决定**：✅ 复用（in-place 改写函数体），不新建函数。
- **原因**：契约 bug 在既有函数内部；调用点 dedup 闸门正确，须保留。

### MQ2: 函数存在性验证

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| `emit_decision_points` | `.tad/hooks/post-write-sync.sh` | 174 | `emit_decision_points() {` | ✅ |
| `trace_decision_point` | `.tad/hooks/lib/trace-writer.sh`（被 source） | — | `trace_decision_point "$d" "$c" "$r" "$slug" "$actor"` 在 208 被调用 | ✅（调用现存，签名不变） |
| `trace_already_emitted` | `.tad/hooks/lib/trace-writer.sh` | — | `if ! trace_already_emitted "decision_point" "$_slug"` line 273 | ✅（dedup 闸门，不动） |

**Human验证点**：每个函数都有"✅存在"和具体位置。

### MQ3: 数据流完整性

| 后端字段 | 用途说明 | 前端组件 | 是否显示 | 不显示原因 |
|---------|---------|---------|---------|-----------|
| d (Decision) | 决策标题 | trace_decision_point arg1 | ✅ | — |
| c (Chosen) | 选定方案 | trace_decision_point arg2 | ✅ | 修复后归正确列 |
| r (Rationale) | 理由 | trace_decision_point arg3 | ✅ | 修复后不再为空（4-col） |
| actor | human/agent 来源 | trace_decision_point arg5 | ✅ | override marker 扫 c+r 推导 |

#### 数据流图
```
§11 Decision Summary 表格
  → awk: 锁定表头 di/ci/ri
  → awk: 数据行 d=a[di] c=a[ci] r=a[ri]
  → SEP 分隔行 → while IFS=SEP read d c r
  → override-marker 扫描(c+r) → actor
  → trace_decision_point d c r slug actor
```

### MQ4: 视觉层级
- [x] 无不同状态 → 跳过（hook 无 UI 状态）

### MQ5: 状态同步

| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| decision_point 事件 | trace JSONL（唯一） | — | PostToolUse on HANDOFF write | 单向 append |

```
[HANDOFF §11 表格] → trace JSONL (唯一存储, append-only)
✅ 只有一个状态，无需同步
```

**Human验证点**：单一 append-only 存储，无同步问题。dream-state.yaml 计数为不可变扫描历史，本任务不改动。

---

## 6. Implementation Steps（分Phase）

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | `.tad/hooks/post-write-sync.sh` | 改写 `emit_decision_points()` awk 为 header-aware（di/ci/ri 动态下标） | `bash -n .tad/hooks/post-write-sync.sh` 通过 | 15 min |
| 2 | `.tad/hooks/post-write-sync.sh` | 更新 line 173 注释为 cutoff 注释（header-aware since 2026-05-31） | `grep -n 'header-aware' .tad/hooks/post-write-sync.sh` | 2 min |
| 3 | extract awk → /tmp 临时脚本，对两个归档 handoff dry-run | 见 §9.1 AC1.2 命令 | 两份原始输出 | 10 min |
| 4 | fault-injected malformed table dry-run | 见 §9.1 AC1.4 | 空输出 + exit 0 | 5 min |
| 5 | `rm` 6 个 CAND-2026-05-30-16115{201,202,203,304,305,306}.md | 删除 | `ls .tad/active/dream-candidates/CAND-2026-05-30-16115*.md` → no match | 2 min |
| 6 | `.tad/active/dream-state.yaml` | **不改动**（计数=不可变扫描历史，code-reviewer Y4 P1-1） | `git status --porcelain .tad/active/dream-state.yaml` 空 | 1 min |

---

### Phase 1: header-aware 改写 + 清理（预计 ~1 小时）

#### 交付物
- [ ] header-aware `emit_decision_points()`（动态 di/ci/ri）
- [ ] line 173 注释更新为 cutoff 注释
- [ ] 6 个 dead candidate 删除
- [ ] (dream-state.yaml 不改动 — 计数=不可变扫描历史)
- [ ] 两个归档 handoff 的 dry-run 原始输出（4-col 修正 + 5-col 无回归）
- [ ] malformed-table fault-injection 的 graceful-skip 证据

#### 实施步骤（精确、有序）

**Step 1 — 改写 awk 为 header-aware。** 替换 line 185-194 当前 `/^\|/ { ... }` 块。核心逻辑（保持 SEP/insec/comment-strip 外壳不变）：
1. separator row：`if ($0 ~ /^\|[-: |]+\|[[:space:]]*$/) next`（保留原样）。
2. 若 `havehdr==0`：`split($0,a,"|")`；遍历 i，对 `t=a[i]` 做 `gsub(/^[[:space:]]+|[[:space:]]+$/,"",t); lt=tolower(t)`；记 `if(lt=="decision")di=i; if(lt=="chosen")ci=i; if(lt=="rationale")ri=i`。若 `di>0 && ci>0` → `havehdr=1`。无论是否成 header，本行都 `next`（表头/前导行不发事件）。
3. 若 `havehdr==1`（data row）：`split($0,a,"|")`；`d=a[di]; c=a[ci]; r=(ri>0?a[ri]:"")`；三者 trim；**保留大小写不敏感表头守卫**：`if(d==""||c==""||(tolower(d)=="decision"&&tolower(c)=="chosen"))next`（多表 §11 第二张表表头以 data row 到达——havehdr 首表锁定不重锁——须靠此守卫拦掉，否则发 junk 自触发事件）；`printf "%s%s%s%s%s\n",d,SEP,c,SEP,r`。
4. **关键**：`havehdr`/di/ci/ri 必须在进入新的 Decision Summary 段时重置。当前 `/^##[[:space:]]/ { insec=... }` 行：在该行同时 `havehdr=0; di=0; ci=0; ri=0`（防止跨段串扰 —— 实际只有一个 §11 段，但显式重置更稳）。
5. ⚠️ **保留（不要移除）** data-row 的大小写不敏感表头守卫 `(tolower(d)=="decision"&&tolower(c)=="chosen")`（见 Step 1 点 3）+ `d==""||c==""` 空值守卫。backend-architect Y4 P0：语料里有多表 §11（phase5-evolve-data-capture / phase6a），删此守卫会对第二张表表头发 junk decision_point + parser self-trigger。

**Step 2 — 更新 cutoff 注释。** 将 line 173 改为说明 header-aware 契约 + cutoff：例如
`# Column-NAME-aware since 2026-05-31 (was hardcoded a[3]/a[5]/a[6] — 4-col tables before this date are column-shifted in historical trace; not repaired, append-only).`
（⚠️ 注释里**不要**写出真实的 `| # | Decision | Chosen | Rationale |` 字面表格 —— 见 §10.1 anti-self-trigger；用 "a[3]/a[5]/a[6]" 描述即可。）

**Step 3 — 保留项核对（不动）：** override-marker `case "$c $r"` 扫描（205-207）、`tr -d '\r\n'|cut -c1-200`（199-201）、每条 `|| true`（208 及 awk `2>/dev/null`）、调用点 line ~273 dedup 闸门（273-275）。

**Step 4 — dry-run（见 §9.1 AC1.2 命令形态）。** 把改写后的 awk 主体抽到 `/tmp/eda.awk`，分别喂两个归档 handoff，贴原始输出。

**Step 5 — fault-injection（见 §9.1 AC1.4）。** 构造一个 Decision Summary 段但表头缺 `Chosen` 列的 malformed 输入，确认 awk 产出为空、退出码 0。

**Step 6 — 删 6 文件（dream-state.yaml 不改动）。**
```bash
rm .tad/active/dream-candidates/CAND-2026-05-30-16115201.md \
   .tad/active/dream-candidates/CAND-2026-05-30-16115202.md \
   .tad/active/dream-candidates/CAND-2026-05-30-16115203.md \
   .tad/active/dream-candidates/CAND-2026-05-30-16115304.md \
   .tad/active/dream-candidates/CAND-2026-05-30-16115305.md \
   .tad/active/dream-candidates/CAND-2026-05-30-16115306.md
```
**dream-state.yaml 不改动**（code-reviewer Y4 P1-1）：`total_rejected` / `last_scan_candidates` 是**不可变扫描历史**（记录"2026-05-30 那次扫描产出 6 个候选、全部 rejected"这一事实），删除物理文件不改写历史——正如本 handoff Decision 2 对 trace 的处理：append-only，不重写历史。删文件 ≠ 改计数。**绝不触碰任何 pending candidate 文件，也不编辑 dream-state.yaml。**

#### 验证方法
- `bash -n .tad/hooks/post-write-sync.sh` 退出 0。
- §9.1 AC1.2 两条 dry-run 命令产出符合期望 cell 文本。
- §9.1 AC1.4 malformed dry-run 产出空、exit 0。
- `ls .tad/active/dream-candidates/CAND-2026-05-30-16115*.md` 无匹配。

#### 🆕 Phase 1 完成证据（Blake必须提供）
- [ ] 改写后 `emit_decision_points()` 函数体（代码块）
- [ ] AC1.2 两份 dry-run 原始 stdout（4-col + 5-col）
- [ ] AC1.4 malformed fault-injection 原始 stdout + exit code
- [ ] `rm` 后的 `ls` 输出（no match）
- [ ] dream-state.yaml 未改动证据（`git status --porcelain .tad/active/dream-state.yaml` 空）

**Human决策**：✅ 完成（Phase 1 为单 Phase，无 Phase 2）

---

## 7. File Structure

### 7.1 Files to Create
```
(无 — 本任务不创建生产文件；证据文件见 Required Evidence Manifest)
```

### 7.2 Files to Modify
```
.tad/hooks/post-write-sync.sh   # MODIFY — emit_decision_points() 改为 header-aware；line 173 注释→cutoff
# (dream-state.yaml 不改动 — code-reviewer Y4 P1-1：计数=不可变扫描历史，删文件不改写历史)
```

### 7.2b Files to Delete
```
.tad/active/dream-candidates/CAND-2026-05-30-16115201.md   # DELETE — rejected 空壳
.tad/active/dream-candidates/CAND-2026-05-30-16115202.md   # DELETE — rejected 空壳
.tad/active/dream-candidates/CAND-2026-05-30-16115203.md   # DELETE — rejected 空壳
.tad/active/dream-candidates/CAND-2026-05-30-16115304.md   # DELETE — rejected 空壳
.tad/active/dream-candidates/CAND-2026-05-30-16115305.md   # DELETE — rejected 空壳
.tad/active/dream-candidates/CAND-2026-05-30-16115306.md   # DELETE — rejected 空壳
```

### 7.3 Grounded Against (Alex step1c)

**Grounded Against** (Alex step1c 实际 Read 过的源文件):

- `.tad/hooks/post-write-sync.sh` lines 170-289 (read 2026-05-31 — emit_decision_points 现状 + 调用点 dedup 闸门)
- `.tad/archive/handoffs/HANDOFF-20260531-research-engine-wire-phase4.md` (read 2026-05-31 — 4-col 测试语料；§11 表头 line 145，row 5 line 151: Chosen="Right-moment trigger, not usage-count" / Rationale="Some projects legitimately don't need research")
- `.tad/archive/handoffs/HANDOFF-20260530-trace-instrumentation-fix.md` (read 2026-05-31 — 5-col 测试语料；§11 表头 line 295: `| # | Decision | Options Considered | Chosen | Rationale |`)
- `.tad/archive/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md` (multi-table §11 测试语料 — backend Y4 P0/P1，验证守卫拦截 junk)
- `.tad/active/dream-candidates/CAND-2026-05-30-16115{201,202,203,304,305,306}.md` (read 2026-05-31 — DELETE 目标，全部 status: rejected)
- `.tad/active/dream-state.yaml` (read 2026-05-31 — last_scan_candidates:6 total_rejected:6 total_accepted:0)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- 4-col §11 dry-run：row 5 emit chosen="Right-moment trigger, not usage-count"，rationale="Some projects legitimately don't need research"（swap 修正）。
- 5-col §11 dry-run：解析不变（无回归）。

### 8.2 Integration Tests
- N/A（hook 在真实 PostToolUse 路径上由调用点 dedup 包裹；本任务 dry-run 抽取 awk 即可，不需触发真实 hook 以免污染真实 trace）。

### 8.3 Edge Cases
- 表头缺 Chosen 列 → graceful skip（空输出，exit 0）。
- 完全无 §11 段 → 无输出。
- 表头存在但无数据行 → 无输出。
- 多表 §11 段（第二张表带 Decision/Chosen 表头）→ 大小写不敏感守卫拦掉，不发 junk（语料 phase5-evolve-data-capture / phase6a）。

### 8.4 🆕 Test Evidence Required
- [ ] 两份 dry-run 原始 stdout（4-col / 5-col）
- [ ] malformed fault-injection 原始 stdout + exit code
- [ ] `bash -n` 通过证据

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] **AC1.1**: `emit_decision_points()` 读表头行，按名（case-insensitive trim）找 `Decision`/`Chosen`/`Rationale` 列下标并动态映射；缺必需列名时 graceful fallback（skip，无 junk emit）。
- [ ] **AC1.2**: 4-col handoff (`research-engine-wire-phase4`) dry-run 发出 decision_point，其 `chosen` 与 `rationale` NON-empty 且匹配真实表格 cell（修复前：rationale 空 + chosen=错列）。5-col handoff (`trace-instrumentation-fix`) dry-run 仍正确（无回归）。两份原始输出贴入 COMPLETION。
- [ ] **AC1.3**: 6 个 rejected `CAND-2026-05-30-16115*.md` 删除；dream-state.yaml **不改动**（计数=不可变扫描历史）；零 pending candidate 被触碰。
- [ ] **AC1.4 (SAFETY)**: hook 永不 fail-closed —— 每条解析路径保留 `|| true`；malformed/缺失表头 → graceful skip，无 junk decision_point 事件（用 fault-injected malformed 表格验证）。
- [ ] Human验证"这是我期望的"。

---

## 9.1 Spec Compliance Checklist (for automated verification)

> **Pipe-escape note**: Markdown 表格内 `|` 写作 `\|` 渲染；提取到 bash 运行时 **un-escape** 回 `|`。
> dual-column: pre-impl 由 Alex 在 step1d dry-run；post-impl 由 Blake 在 Gate 3 Layer 1 实跑。

| # | Acceptance Criterion | Verification Type | Verification Method (un-escaped for bash) | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1.1 | header-aware 动态映射 + graceful skip | post-impl-verifiable | 见下方『AC1.1 命令块』（unescaped pipe，移出表格避免 ERE `\|` 转义歧义 — code-reviewer Y4 P0-1） | di/ci/ri 扫描存在；旧硬编码消失 | (post-impl) |
| AC1.2a | 4-col 修正 | post-impl-verifiable | 抽 awk → `/tmp/eda.awk`，喂 4-col handoff（见下方"AC1.2 dry-run 命令形态"），输出 row5 行 | 一行含 `Right-moment trigger, not usage-count` 在 chosen 位、`Some projects legitimately don't need research` 在 rationale 位（SEP 分隔） | (post-impl) |
| AC1.2b | 5-col 无回归 | post-impl-verifiable | 同一 `/tmp/eda.awk` 喂 5-col handoff | chosen/rationale 各归正确列，与修复前一致 | (post-impl) |
| AC1.2c | before/after 对照 | post-impl-verifiable | 旧 awk `/tmp/eda-old.awk` 喂同一 4-col handoff，与 AC1.2a 对照 | OLD: chosen=rationale 文本、rationale 空；NEW: 归正确列。diff 即 swap-back 证据（code-reviewer Y4 P1-2） | (post-impl) |
| AC1.2d | 多表 §11 不发 junk | post-impl-verifiable | `/tmp/eda.awk` 喂 `HANDOFF-20260425-phase5-evolve-data-capture.md`（多表 §11） | 输出无 junk 行；尤其无把第二张表表头当数据行的 `Decision/Chosen` 行（backend-architect Y4 P0） | (post-impl) |
| AC1.3a | 6 文件删除 | post-impl-verifiable | `ls .tad/active/dream-candidates/CAND-2026-05-30-16115*.md 2>&1` | `No such file` / no match | (post-impl) |
| AC1.3b | pending 未触碰 | post-impl-verifiable | `git status --porcelain .tad/active/dream-candidates/` 仅显示 6 个 D（删除），无其他改动 | 仅 6 行 `D ...16115*.md` | (post-impl) |
| AC1.3c | dream-state 未改动 | post-impl-verifiable | `git status --porcelain .tad/active/dream-state.yaml` | 空输出（文件未改动 — 计数=不可变扫描历史） | (post-impl) |
| AC1.4a | fail-open 全保留（函数内+文件级） | post-impl-verifiable | 见下方『AC1.4a 命令块』：函数体内 `\|\| true` ≥1 AND 文件级 ≥14（code-reviewer Y4 P0-2） | 函数内不减、文件级不减 | (pre-impl 基线如下) |
| AC1.4b | malformed graceful skip | post-impl-verifiable | fault-inject 缺-Chosen 表格喂 `/tmp/eda.awk`，捕获 stdout + `$?` | stdout 空，exit 0 | (post-impl) |
| AC1.4c | bash 语法 | post-impl-verifiable | `bash -n .tad/hooks/post-write-sync.sh; echo $?` | 0 | (post-impl) |

**AC1.1 命令块（unescaped pipe — 移出表格，code-reviewer Y4 P0-1）：**
```bash
# 正向：header-aware 标志存在（应有命中）
grep -nE 'di=i|ci=i|ri=i|havehdr' .tad/hooks/post-write-sync.sh
# 反向：旧硬编码消失（应无命中；bracket \[ \] 保留，仅 alternation 用裸 |）
grep -nE 'd=a\[3\]|c=a\[5\]|r=a\[6\]' .tad/hooks/post-write-sync.sh
```

**AC1.4a 命令块（函数体内 + 文件级双重 — code-reviewer Y4 P0-2）：**
```bash
# 函数体内 fail-open（关键：改写后 emit_decision_points 体内 || true 须 ≥1）
awk '/^emit_decision_points\(\)/{f=1} f&&/^}/{print;exit} f' .tad/hooks/post-write-sync.sh | grep -c '|| true'   # 基线 1 → 改写后 ≥1
# 文件级 fail-open 不减
grep -c '|| true' .tad/hooks/post-write-sync.sh   # 基线 14 → 改写后 ≥14
```
Blake 改写前先记录两个基线（函数内=1、文件级=14），改写后均须 ≥ 基线。另确认 awk 子壳保留 `2>/dev/null` + `[ -n "$rows" ] || return 0`。

**AC1.2 dry-run 命令形态（Blake 在 Gate 3 Layer 1 实跑 — post-impl）：**

把改写后的 awk 主体（`awk -v SEP=$'\x1e' '...'` 内的 program）原样写入 `/tmp/eda.awk`（不含 shell `awk -v` 包裹，program 本体；SEP 用可见替身便于读取），然后：
```bash
# 用可见分隔符 '<<SEP>>' 替代 \x1e 便于肉眼核对（仅 dry-run 用途）
cat > /tmp/eda.awk <<'AWK'
# <<< 粘贴改写后 emit_decision_points 内的 awk program 本体；
#     把 SEP=$'\x1e' 改为 program 开头 BEGIN{SEP="<<SEP>>"} 以便可读
AWK

echo "=== 4-col (research-engine-wire-phase4) — NEW fixed awk ==="
awk -f /tmp/eda.awk .tad/archive/handoffs/HANDOFF-20260531-research-engine-wire-phase4.md

echo "=== 4-col — OLD buggy awk (a[3]/a[5]/a[6]) before/after 对照 (code-reviewer Y4 P1-2) ==="
# /tmp/eda-old.awk = 改写前 program 本体（从 git HEAD:.tad/hooks/post-write-sync.sh 抽取 d=a[3];c=a[5];r=a[6] 版本）
awk -f /tmp/eda-old.awk .tad/archive/handoffs/HANDOFF-20260531-research-engine-wire-phase4.md

echo "=== 5-col (trace-instrumentation-fix) — no regression ==="
awk -f /tmp/eda.awk .tad/archive/handoffs/HANDOFF-20260530-trace-instrumentation-fix.md

echo "=== multi-table §11 (phase5-evolve-data-capture) — NEW awk 必须不发 junk (backend-architect Y4 P0/P1) ==="
awk -f /tmp/eda.awk .tad/archive/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md
```
期望：
- **4-col NEW**：含一行 chosen=`Right-moment trigger, not usage-count`、rationale=`Some projects legitimately don't need research`（归正确列）。
- **4-col OLD**（同文件、旧 awk）：同一行 chosen 为 rationale 文本、rationale 空 —— before/after diff 即 swap-back 证据。
- **5-col**：无回归。
- **multi-table phase5**：输出**不得**含把第二张表表头（字面 `Decision`/`Chosen`）当数据行发出的 junk 行（守卫已拦）。

> ⚠️ Blake：dry-run 抽取的是 awk **program 本体**到独立 .awk 文件并用 `-f` 跑，**不要**在 dry-run 中真实触发 PostToolUse hook（会向真实 trace JSONL append 事件）。raw CLI `awk -f` 仅读取、不写 trace。

---

## 9.2 Expert Review Status (Alex 必填)

> Conductor 负责本 Epic 的专家审查（YOLO Y4/Y6）。本 handoff 由 Alex 起草，专家审查由 Conductor 在派发前/实现后执行，结果回填此表。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: §6 Step5 让删 data-row 表头守卫 → 多表 §11 发 junk + 自触发 | §4.2 + §6 Step1.3/Step5 改为"保留大小写不敏感守卫" | Resolved |
| backend-architect | P1: 多表 §11 (phase5/phase6a) 未进 dry-run 语料 | §9.1 AC1.2d + §8.3 + Grounded 加 phase5 | Resolved |
| backend-architect | P2: expert_findings/reflexions positional-safe，窄 scope 正确 | (确认，无需改) | Resolved (affirm) |
| code-reviewer | P0-1: AC1.1 grep 用 `\|`（ERE 字面管道）→ 失效/假通过 | §9.1 AC1.1 命令块移出表格 + 裸 `|` alternation | Resolved |
| code-reviewer | P0-2: fail-open 基线按全文件，未锁函数内唯一 `\|\| true` | §9.1 AC1.4a 命令块加函数体内计数 ≥1 | Resolved |
| code-reviewer | P1-1: dream-state 和解矛盾且违 append-only | 全文改为 dream-state 不改动（计数=不可变扫描历史） | Resolved |
| code-reviewer | P1-2: AC1.2 只验后态无 before/after | §9.1 AC1.2c 加旧 awk 对照 | Resolved |
| code-reviewer (re-review v2) | 验证 6 项全 resolved + 实证（守卫 awk 多表零 junk；4-col swap-back） | — | PASS |

### Experts Selected
1. **code-reviewer** — shell/awk 解析正确性 + fail-open 保全（Conductor 选定）。
2. **(domain — 视 Conductor 判断)** — observational trace 契约 / parser self-trigger。

### Overall Assessment (post-integration)
- (待 Conductor 审查后回填)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Anti-self-trigger（来自 architecture.md "Parser Self-Trigger" 2026-05-30）**：本任务改的 parser 匹配 `Decision`/`Chosen`/`Rationale` 列名与 `^\|` 行。**绝不**在 COMPLETION、dry-run 输出说明、review 文件、注释里写一个真实的 §11 形态 markdown 表格（带 `Chosen` 表头的 `| ... |` 行），否则下次任何 HANDOFF write 触发的 hook 会扫到它并向真实 trace 注入假 decision_point。规避手段：(a) dry-run 期望值用行内反引号或缩进代码块包裹、用 paraphrase（"chosen 列"/"the chosen-column"）描述；(b) 代码块内若必须示意表格，确保它**不在** `## ... Decision Summary` 标题段之下、且行首不是裸 `|`（用前导文字或反引号）。
- ⚠️ **Hook 永不 fail-closed（SAFETY，NFR1/AC1.4）**：任何 awk 解析失败、表头缺失、malformed 输入，都必须 graceful skip（空输出、exit 0），绝不返回非 0 阻断 PostToolUse。保留 awk 的 `2>/dev/null`、shell 的 `|| true`、`[ -n "$rows" ] || return 0`。这是单用户 CLI 的硬约束（参 "Mechanical Enforcement Rejected on Single-User CLI"）。

### 10.2 Known Constraints
- BSD/macOS awk：用 POSIX 子集，不用 GNU 扩展，不用 `grep -P`。
- 历史 trace append-only：不重发、不修历史事件；仅加 cutoff 注释。
- 调用点 line ~273 per-(slug,day) dedup 闸门：不动。
- dream-scanner.sh Pass C：不动（下游已正确）。
- dream-state.yaml（total_rejected/last_scan_candidates）= 不可变扫描历史：删文件不改计数，本任务**不编辑**该文件。

### 10.3 🆕 Sub-Agent使用建议
Blake应该考虑使用：
- [ ] **code-reviewer**（若 Conductor 未已派发）— awk 正确性
- [ ] **test-runner** — 跑 dry-run + fault-injection 后

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | 列映射策略：header-aware 按名索引 vs positional + 启发式列数推断 | header-aware 按名索引 | 按名映射对任意列排布健壮（4/5/未来列）；启发式列数推断在边界（如 4 列含空 Options）易再错列。匹配 ".router.log 5-Tuple 契约"教训：消费契约要显式。 |
| 2 | 历史已污染 trace 事件处理：repair/re-emit vs leave-as-is + cutoff 注释 | leave-as-is + 一行 cutoff 注释 | trace 是 append-only 数据层；重写历史会破坏可信度与可重放性。cutoff 注释标注修复日期即足够，符合 grounding NOT-in-scope。 |

> （此 §11 表格本身位于 HANDOFF，写入时会被 hook 扫描——这是**预期且正确**的：它会为本 handoff 自身正确发出 2 个 decision_point。Blake/评审在 evidence 文件中**不得**复制此表的 §11 形态——见 §10.1。）

---

## 12. 🆕 Sub-Agent使用记录

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| code-reviewer | ✅ (Conductor Y4 ×2: 设计审查 + v2 re-review) | 设计阶段 | P0-1/P0-2/P1-1/P1-2 → v2 全修复，re-review PASS | .tad/evidence/yolo/tad-lean-trustworthy/phase1-design-review-cr.md |
| backend-architect | ✅ (Conductor Y4) | 设计阶段 | P0(守卫)+P1(多表语料) → v2 修复 | .tad/evidence/yolo/tad-lean-trustworthy/phase1-design-review-backend.md |
| test-runner | ⬚ (Blake Gate 3 Layer 2) | — | — | — |

---

## Required Evidence Manifest

```yaml
# Blake 在 Gate 3 / *complete 必须产出以下证据文件：
required_evidence:
  completion_report:
    path: ".tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase1.md"
    must_contain:
      - "改写后 emit_decision_points() 函数体（代码块）"
      - "AC1.2a 4-col dry-run 原始 stdout（含 row5 chosen/rationale 修正值）"
      - "AC1.2b 5-col dry-run 原始 stdout（无回归）"
      - "AC1.4b malformed fault-injection 原始 stdout + exit code"
      - "AC1.3a 删除后的 ls 输出（no match）"
      - "AC1.3b git status --porcelain（仅 6 个 D）"
      - "AC1.3c dream-state.yaml 未改动证据（git status --porcelain 空）"
      - "AC1.4c bash -n 退出 0"
    anti_self_trigger: "COMPLETION 中绝不写 §11 形态真实表格 / 裸 Chosen 表头行"
  gate3_verdict_marker:
    path: ".tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase1.md"
    field: "gate3_verdict"           # frontmatter marker, allowlist: pass | fail | partial
    written: "as Gate 3 POST-STEP Edit (verdict 存在后再写)"
  dry_run_outputs:
    - path: ".tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/dryrun-4col.txt"
      proves: "AC1.2a — research-engine-wire-phase4 修正"
    - path: ".tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/dryrun-5col.txt"
      proves: "AC1.2b — trace-instrumentation-fix 无回归"
    - path: ".tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/malformed-skip.txt"
      proves: "AC1.4b — graceful skip, exit 0"
  expert_review:
    path: ".tad/evidence/reviews/blake/tad-lean-trustworthy-phase1/"
    note: "Conductor 派发；≥1 distinct reviewer (canonical 文件名: code-reviewer.md)"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-31
**Version**: 3.1.0
