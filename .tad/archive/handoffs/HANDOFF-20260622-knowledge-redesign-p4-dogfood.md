---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Recording Redesign — P4 Dogfood + Reference Migration

**From:** Alex (Terminal 1) · **To:** Blake (Terminal 2) · **Date:** 2026-06-22
**Epic:** EPIC-20260622-knowledge-recording-redesign.md (Phase 4/4)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三层任务:迁移现有→端到端回环→迁移报告 |
| Components Specified | ✅ | 8 个 WARN 文件逐个处理规则 + SAFETY read_only 规则 + 回环证据格式 |
| Functions Verified | ✅ | lint 脚本已验证(P3),知识文件全部存在 |
| Data Flow Mapped | ✅ | 旧 entry → 补 failure_mode → lint clean → 新知识走回环 → 迁移报告 |

**Gate 2 结果**: ✅ PASS(专家审查后回填 §9.2)

---

## 1. Task Overview

### 1.1 What We're Building
拿 TAD 自己的 project-knowledge 当参考实现:补 failure_mode、调非-SAFETY 措辞、跑 lint 到 clean;然后用**一条真实新知识**端到端走完 journal→distill→gap-handback→entry→lint→reconcile,证明整套机制在真实内容上可行。

### 1.2 Why We're Building It
P1-P3 搭了契约+流水线+维护,但全是"纸面设计"。P4 是 dogfood——如果迁移真实知识时发现 schema 有漏洞(比如某类 entry 填不进 failure_mode),就回去修 P1 文档。不 dogfood 就不知道设计有没有 gap。

### 1.3 Intent Statement
**不是要做的**:
- ❌ 不改 14 个下游项目(pull-based,post-Epic)
- ❌ 不重写 SAFETY 条目内容(read_only)——只允许**在不改约束文本的前提下**补 `failure_mode` 注解
- ❌ 不要求把所有 104 条 pattern 都转成完美的 typed entry——只要求 lint WARN=0 或每个 remaining WARN 显式 justified

---

## 📚 Project Knowledge

**⚠️ Blake 必读**:

1. **principles.md SAFETY 条目逐字不改**(多条 L1 原则警告过这件事——2026-05-31 grep-count、2026-06-01 line-set)。12 条 SAFETY entries 的约束文本(Discovery/Action)是**机械执行锚点**,byte-identical 保留。
2. **P1 产出**:`.tad/templates/playbook-entry-schema.md` + `knowledge-writing-rules.md`——这是迁移要对齐的目标格式。
3. **P3 lint**:`.tad/hooks/lib/knowledge-lint.sh`——迁移后跑 lint,目标 0 WARN(或每个 WARN justified)。

---

## 3. Technical Plan

### Task 1: 迁移 8 个 WARN 文件(补 failure_mode)

lint 报了 8 个文件缺 failure_mode。对每个文件:

**处理规则**:
1. 读文件,逐条 `### ` entry 检查
2. 对每条 entry:
   - **能补 failure_mode 吗?** 从 Context/Discovery 推断"如果不知道这条,naive 默认会怎么错"
   - **能补** → 在 entry 末尾(Action 之后)追加:`- **failure_mode**: {naive 默认会...因为...}`
   - **不能补**(entry 太抽象/太旧/无法推断 naive 默认)→ 追加:`- **failure_mode**: [UNRESOLVABLE — entry predates schema; naive default unclear from context alone]`
   - 不改 Context/Discovery/Action 原文(这些是历史记录,改了就不是当时的记录了)
3. **不做**:不重排、不合并、不删除、不改标题

**8 个文件的预期工作量**:

| 文件 | entries | 预期 |
|------|---------|------|
| architecture.md | 2 | 补 failure_mode |
| frontend-design.md | 1 | 补 |
| security.md | 3 | 补 |
| patterns/ac-verification.md | 12 | 补 |
| patterns/handoff-design.md | 21 | 补(最大文件) |
| patterns/hook-contracts.md | 4 | 补 |
| patterns/memory-and-learning.md | 4 | 补 |
| patterns/pack-evaluation.md | 6 | 补 |
| patterns/gate-design.md | 15 | 补(P0 修复:lint 漏报) |
| patterns/pack-build-rules.md | 16 | 补(P0 修复) |
| patterns/research-methodology.md | 8 | 补(P0 修复) |
| patterns/shell-portability.md | 18 | 补(P0 修复) |
| **合计** | **110** | 每条补一行 `failure_mode`,不改原文 |

**⚠️ P0 修复:lint 因 file-level 粒度漏报的 4 个文件(57 entries)也纳入迁移范围**:

lint 对整个文件做 `grep -ci`——只要文件里**任意一行**含 `failure.mode` 等关键词就不报 WARN,即使只有 1/15 条 entry 有。以下 4 个文件因此静默通过,但实际绝大多数 entry 缺 failure_mode:

| 文件 | entries | lint 假通过原因 | 处理 |
|------|---------|----------------|------|
| patterns/gate-design.md | 15 | 2 处 prose 提到 "failure mode" | 纳入迁移,逐条补 failure_mode |
| patterns/pack-build-rules.md | 16 | 3 处 prose 提到 | 纳入迁移 |
| patterns/research-methodology.md | 8 | 1 处 prose 提到 | 纳入迁移 |
| patterns/shell-portability.md | 18 | 1 处 prose 提到 | 纳入迁移 |

**更新后合计:8+4=12 个文件,53+57=110 entries**。

不在迁移范围内:
- `principles.md`:SAFETY read_only;3 条非-SAFETY 见 Task 2
- `code-quality.md`:0 entries(空)
- `_index.md`:不是 entry 文件(见 Task 3)

### Task 2: principles.md 非-SAFETY 条目调整(3 条)

15 条中 12 条是 SAFETY(**不动**)。剩 3 条非-SAFETY:

**识别方法**:`grep -v 'SAFETY ENTRY' principles.md | grep '^### '` → 找出没有 SAFETY 标记的。

对这 3 条:
1. 如果有全大写 MUST/NEVER/ALWAYS → 检查是否可以改成解释推理(writing-rules 规则 4)
2. 补 `failure_mode` 如缺
3. **不改语义**——只调措辞格式,不改内容含义

⚠️ **即使是非-SAFETY 条目,principles.md 是 L1,措辞变更也需要审慎**。如果某条非-SAFETY 的 MUST 实际上是 load-bearing(被其他地方 grep 依赖),**不改**,在迁移报告里注明。

### Task 3: _index.md 补 selector 描述

当前 `patterns/_index.md` 每条是 `[title](file.md) — one-line hook`。新 schema 要求 `selector` 枚举触发词 + near-miss。

**做法**:不改 _index.md 的格式结构(它是 Blake 1_5_context_refresh 的检索面),但**在每条的 one-line hook 里追加关键触发词**(如果当前 hook 太短)。不新建文件,不改结构。

这是轻量调整,不是重写——_index.md 的 hook 已经在做 selector 的事,只需要让它更"pushy"(更多触发词)。

### Task 4: 端到端回环验证(⚠️ 最重要)

用**一条真实的、在本 Epic 中新产生的知识**走完整回环:

**知识来源**:本 Epic 自身产出的知识——例如"P2 的 AC9 重犯 grep-c 教训"或"P3 lint 的 \b word-boundary macOS 不兼容"。这些是**真实的、刚发生的**、且之前没有被正确提炼过的。

**回环步骤(全部记录在 evidence)**:

1. **Capture**: Blake 写 journal entry 到 `evidence/journal/knowledge-redesign-p4-{date}.md`
   - 原始记录:本 Epic 过程中发现了什么(用日记体,不要求 schema)
   - **⚠️ 写 journal 前不要重读 schema 模板**——用时间叙事("先发生 X,然后 Y"),不用概念结构("context, discovery, action")
   **⚠️ BLAKE 在此 STOP。** Steps 2-7 由 Alex 在 Gate 4 验收时执行。Blake 做完 Task 1-3 + Task 4 step 1 后提交 completion report。
2. **Distill**: Alex(以陌生人身份)读 journal,尝试填 typed entry
   - 使用 `playbook-entry-template.md`
   - **必须有至少 1 个字段填不出**(failure_mode 或 validator 最可能)→ 产出缺口问题
3. **Gap hand-back**: 把缺口问题展示给用户,用户传给 Blake
4. **Blake answers**: Blake 答(因为 Blake 有执行上下文)
5. **Alex finalizes**: 填入答案,做变量化测试,leak 检测
6. **Lint**: 跑 lint 确认新 entry clean
7. **Reconcile**: 跑 *knowledge-maintain 的和解步骤(新 entry vs 现有 top-5)

**证据格式**(写到 `.tad/evidence/knowledge-redesign-p4-e2e-validation.md`):
```
## End-to-End Validation

### 1. Journal (Blake raw)
[贴 journal 原文]

### 2. Distill attempt (Alex as stranger)
[贴 typed entry 草稿 — 标出哪些字段填不出]

### 3. Gap questions
[贴给用户的问题列表]

### 4. Blake answers
[贴答案]

### 5. Finalized entry
[贴最终 typed entry]

### 6. Lint result
[贴 lint 输出 — 0 WARN for this entry]

### 7. Reconcile result
[贴 ADD/UPDATE/DELETE/NOOP 判断 + 理由]

### Schema gaps found
[如果回环中发现 schema 有 gap → 列出;无 gap 则写 "None found"]
```

### Task 5: 迁移报告

写一份简短报告(`.tad/evidence/knowledge-redesign-p4-migration-report.md`):
- 迁移了多少条、多少个文件
- 补了多少个 failure_mode(实际可推断 vs UNRESOLVABLE)
- lint 最终状态(0 WARN 或 justified 列表)
- 端到端回环是否成功 + 哪个字段触发了 gap hand-back
- Schema gaps(有则列出 + 建议的 P1 文档修正;无则 "None")
- principles.md SAFETY byte-preservation 证明(line-set diff)

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/journal/knowledge-redesign-p4-{date}.md           # 端到端回环的 journal
.tad/evidence/knowledge-redesign-p4-e2e-validation.md           # 回环 7 步证据
.tad/evidence/knowledge-redesign-p4-migration-report.md         # 迁移报告
```
### 7.2 Files to Modify
```
.tad/project-knowledge/architecture.md                          # 补 failure_mode
.tad/project-knowledge/frontend-design.md                       # 补 failure_mode
.tad/project-knowledge/security.md                              # 补 failure_mode
.tad/project-knowledge/patterns/ac-verification.md              # 补 failure_mode
.tad/project-knowledge/patterns/handoff-design.md               # 补 failure_mode (最大)
.tad/project-knowledge/patterns/hook-contracts.md               # 补 failure_mode
.tad/project-knowledge/patterns/memory-and-learning.md          # 补 failure_mode
.tad/project-knowledge/patterns/pack-evaluation.md              # 补 failure_mode
.tad/project-knowledge/patterns/gate-design.md                  # 补 failure_mode (P0 修复)
.tad/project-knowledge/patterns/pack-build-rules.md             # 补 failure_mode (P0 修复)
.tad/project-knowledge/patterns/research-methodology.md         # 补 failure_mode (P0 修复)
.tad/project-knowledge/patterns/shell-portability.md            # 补 failure_mode (P0 修复)
.tad/project-knowledge/principles.md                            # 3 条非-SAFETY 调整(如适用)
.tad/project-knowledge/patterns/_index.md                       # 补触发词(轻量)
```

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist

| # | AC | Verification Type | Verification Method | Expected | Verified Output |
|---|-----|-------------------|---------------------|----------|-----------------|
| 1 | lint 0 WARN 或全 justified(含 P0 修复的 4 文件) | post-impl | `bash .tad/hooks/lib/knowledge-lint.sh 2>/dev/null \| grep -c WARN` | 0(或迁移报告列出每个 justified WARN) | (post-impl) |
| 2 | principles.md SAFETY entry **全 body** byte-preserved | post-impl | `git diff .tad/project-knowledge/principles.md \| grep '^[+-]' \| grep -v '^[+-][+-][+-]' \| grep -viE 'failure_mode\|UNRESOLVABLE' \| head -20`(仅显示非 failure_mode 的改动行;SAFETY entry 内应无任何改动行) | 输出中无 SAFETY entry 内容的行(人工确认) | (post-impl) |
| 3 | 端到端验证证据存在 | post-impl | `test -f .tad/evidence/knowledge-redesign-p4-e2e-validation.md && echo OK` | OK | (post-impl) |
| 4 | 验证含 7 步 | post-impl | `grep -cE '^### [0-9]+\.' .tad/evidence/knowledge-redesign-p4-e2e-validation.md` | 7 | (post-impl) |
| 5 | gap hand-back 实际发生 | post-impl | `grep -cE 'Gap questions\|填不出\|缺口' .tad/evidence/knowledge-redesign-p4-e2e-validation.md` | >= 1 | (post-impl) |
| 6 | 迁移报告存在 | post-impl | `test -f .tad/evidence/knowledge-redesign-p4-migration-report.md && echo OK` | OK | (post-impl) |
| 7 | 无下游项目文件改动 | post-impl | `git diff --name-only \| grep -vE '^\.(tad\|claude)/' \| grep -c .` | 0 | (post-impl) |
| 8 | journal 文件存在 | post-impl | `ls .tad/evidence/journal/knowledge-redesign-p4*.md 2>/dev/null \| wc -l` | >= 1 | (post-impl) |
| 9 | **Diff-filter: 改动只含 failure_mode 追加**(P0 修复) | post-impl | `git diff .tad/project-knowledge/ \| grep '^+' \| grep -v '^+++' \| grep -viE 'failure_mode\|UNRESOLVABLE\|naive.default' \| wc -l` | 0(或极少——仅 Task 2 的 3 条非-SAFETY 措辞调整 + Task 3 _index 补触发词) | (post-impl) |
| 10 | failure_mode 总数达标(~110 新增) | post-impl | `grep -rc 'failure_mode' .tad/project-knowledge/ \| awk -F: '{s+=$2}END{print s}'` | >= 100(允许部分 UNRESOLVABLE 计入) | (post-impl) |

## 9.2 Expert Review Status

### Experts Selected
1. **code-reviewer** — AC 可执行性、迁移范围完整性、SAFETY preservation
2. **migration-safety reviewer**(general-purpose) — batch-edit blast radius、UNRESOLVABLE theater risk、cross-bridge choreography

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: 4 文件(57 entries)因 lint file-level 粒度静默跳过 | Task 1 扩范围到 12 文件 110 entries;§7.2 更新 | Resolved |
| code-reviewer | P0-2: AC2 只查 SAFETY 标记行不查 entry body | §9.1 AC2 改 diff-filter 展示非-failure_mode 改动行+人工确认;AC9 补 diff-filter 验证只追加 failure_mode | Resolved |
| migration-safety | P0-3: 47 entries batch-edit 无 diff-scope 验证 | §9.1 AC9 diff-filter:所有新增行必须是 failure_mode 相关 | Resolved |
| code-reviewer | P1-1: AC5 grep 缺 `-E`(literal `\|` 不做 alternation) | §9.1 AC5 加 `-E` | Resolved |
| code-reviewer | P1-2: Task 4 body 无 STOP 标记,Blake 可能越界做 step 2-7 | Task 4 step 1 加 ⚠️ BLAKE STOP 标记 | Resolved |
| code-reviewer | P1-3: 3 条非-SAFETY principles 极短无 MUST 可剥,Task 2 实质只补 failure_mode | Noted — Task 2 范围合理,迁移报告会记录 | Noted |
| migration-safety | P1: UNRESOLVABLE 无上限 → lint-suppression theater 风险 | 迁移报告 Task 5 须含 UNRESOLVABLE 计数+占比;若 >20% 标红 escalate | Noted |
| migration-safety | P2: Blake journal 可能无意识 schema-aligned → 假通过 | Task 4 step 1 加"写 journal 前不重读 schema,用时间叙事" | Resolved |

### Overall Assessment
- **code-reviewer**: CONDITIONAL PASS → 2 P0 + 2 P1 Resolved
- **migration-safety**: CONDITIONAL PASS → 1 P0 Resolved + 1 P1 Noted + 1 P2 Resolved

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **SAFETY 条目是 read_only 的生死线**。12 条 SAFETY entries 的 Discovery/Action 文本不能有任何字节变化。补 failure_mode 注解可以(是追加),但不改原文。AC2 用 line-set diff on SAFETY 行验证。
- ⚠️ **53 条 entry 补 failure_mode 是批量工作**——handoff-design.md 有 21 条,是最大的。Blake 应该按文件 batch 处理,每补完一个文件跑一次 lint 确认 WARN 消除。
- ⚠️ **端到端回环的 gap hand-back 必须真实发生**。如果 Blake 写的 journal 太完整导致 Alex 能填出所有字段(没有 gap)→ 这不是成功,是 journal 不够"raw"。Blake 写 journal 时**刻意不提炼**,只记发生了什么,让 Alex 去发现 gap。
- ⚠️ **Schema gap 反馈是 P4 的隐性产出**。如果迁移过程中发现某类 entry 根本填不进 failure_mode(不是"信息不够"而是"这类知识没有 naive 默认"的概念),在迁移报告里标出——这是判断型知识的边界,Phase 2 follow-up Epic 的输入。

### 10.2 回环中 Blake 和 Alex 的角色

这个 handoff 的特殊之处:Blake 做 Task 1-3(迁移)+ Task 4 的 step 1(写 journal)+ step 4(答缺口问题);**Alex 做 Task 4 的 step 2-3, 5-7(提炼+缺口+定稿+lint+reconcile)**。

也就是说 Task 4 需要**两次跨桥**:
1. Blake 写 journal → 传给 Alex
2. Alex 发现 gap → 传回 Blake
3. Blake 答 → 传回 Alex

Blake 的 completion report 应该在 Task 1-3 + Task 4 step 1 完成后提交;Task 4 的 step 2-7 由 Alex 在 Gate 4 验收时执行(这就是 distillation_loop 的真实首次运行)。Task 5 迁移报告由 Blake 写初稿、Alex 在 Gate 4 补充回环结果后定稿。

---

**Handoff Created By**: Alex · **Date**: 2026-06-22 · **Version**: 3.1.0
