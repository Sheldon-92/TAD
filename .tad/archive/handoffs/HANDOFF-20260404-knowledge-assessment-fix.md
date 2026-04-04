---
task_type: mixed
e2e_required: no
research_required: no
---

# Mini-Handoff: Knowledge Assessment Pipeline Fix

**From:** Alex | **To:** Blake | **Date:** 2026-04-04
**Type:** Express Bugfix (protocol fix)
**Priority:** P0
**Task ID:** TASK-20260404-016

## Bug Description

Knowledge Assessment 流程存在系统性断裂：Blake 在 Gate 3 把新发现写在 completion report 里而不是 project-knowledge，Alex 在 Gate 4 打勾通过但没验证实际写入，下次任务时历史知识无法被主动推送给执行者。

三个断点：
1. **写入断**：Blake 应该写 project-knowledge 但实际写了 completion report
2. **验证断**：Gate 表格只要求 Yes/No，不要求证明写入了哪个文件
3. **复用断**：Alex 写 handoff 时凭记忆摘录 knowledge，容易漏

## Root Cause

- Gate 3 Knowledge Assessment 表格模板只要求填 "Yes/No + Category + Summary"，不要求贴 file path 作为 evidence
- Gate 4 Knowledge Assessment 同样只确认 "有没有"，不验证 "写了没有"
- Handoff step0.5 (Context Refresh) 读 knowledge files 但没有按任务关键词匹配条目的强制步骤

## Fix: Three-Layer Repair

### Layer 1: 写入保障 — Gate 3 Knowledge Assessment (Blake 侧)

**File:** `.claude/commands/tad-gate.md`

**修改 1a: Gate 3 Knowledge Assessment 表格模板** (约 line 257-262)

当前:
```
#### Knowledge Assessment (MANDATORY - must answer)
| Question | Answer | Action |
|----------|--------|--------|
| New discoveries? | ✅ Yes / ❌ No | If Yes: recorded to .tad/project-knowledge/{category}.md |
| Category | {category} or N/A | ... |
| Brief summary | {1-line summary} | ... |
```

改为:
```
#### Knowledge Assessment (MANDATORY - must answer)
| Question | Answer | Evidence |
|----------|--------|----------|
| New discoveries? | ✅ Yes / ❌ No | — |
| If Yes: written to | .tad/project-knowledge/{category}.md | Entry title: "### {title} - {date}" |
| If No: reason | {why no new discovery} | — |

⚠️ "Yes" without a file path + entry title = Gate 3 FAIL.
Blake must write directly to project-knowledge, NOT to completion report.
Completion report references the entry, it does not contain the entry.
```

**修改 1b: Gate 3 Knowledge Assessment 执行规则** (约 line 264-310)

在 `if_new_discovery:` 节末尾追加验证步骤:

```yaml
  if_new_discovery:
    step1: "读取 .tad/project-knowledge/ 目录，列出所有可用类别"
    step2: "确定分类（或选择创建新类别）"
    step3: "写入对应的 .tad/project-knowledge/{category}.md"
    step4: "使用标准格式"
    step5_verify: "在 Gate 3 表格的 Evidence 列填写：文件路径 + 条目标题。无此信息 = Gate FAIL"

  completion_report_rule: |
    Completion report 的 Knowledge Assessment 节只写引用：
    "New discovery recorded: .tad/project-knowledge/{category}.md → '### {title}'"
    完整内容在 project-knowledge 文件中，不在 completion report 中重复。
```

**修改 1c: 同样修改 Gate 4 表格模板** (约 line 452-457)

当前:
```
#### Knowledge Assessment (MANDATORY - must answer)
| Question | Answer | Action |
|----------|--------|--------|
| New discoveries from review? | ✅ Yes / ❌ No | If Yes: recorded to .tad/project-knowledge/{category}.md |
| Category | {category} or N/A | ... |
| Brief summary | {1-line summary} | ... |
```

改为（同 Gate 3 格式）:
```
#### Knowledge Assessment (MANDATORY - must answer)
| Question | Answer | Evidence |
|----------|--------|----------|
| New discoveries? | ✅ Yes / ❌ No | — |
| If Yes: written to | .tad/project-knowledge/{category}.md | Entry title: "### {title} - {date}" |
| If No: reason | {why no new discovery} | — |

⚠️ Alex writes business/architecture discoveries. Blake writes implementation discoveries.
No overlap: Blake owns Gate 3 knowledge, Alex owns Gate 4 knowledge.
Tiebreaker: HOW code works (tool quirks, build issues, API gotchas) → Blake Gate 3.
           WHY a design should change (architecture patterns, requirement gaps) → Alex Gate 4.
```

**修改 1d: Gate 4 Knowledge_Assessment_Gate4 追加 if_new_discovery 写入流程** (约 line 516-547)

在 `Knowledge_Assessment_Gate4:` 节的 `can_skip_if:` 之后、`violation:` 之前，追加:

```yaml
  if_new_discovery:
    step1: "读取 .tad/project-knowledge/ 目录，列出所有可用类别"
    step2: "确定分类（或选择创建新类别）"
    step3: "写入对应的 .tad/project-knowledge/{category}.md"
    step4: "使用标准格式"
    step5_verify: "在 Gate 4 表格的 Evidence 列填写：文件路径 + 条目标题。无此信息 = Gate FAIL"
```

---

### Layer 2: 验证保障 — Gate 4 step7 (Alex 侧)

**File:** `.claude/commands/tad-alex.md`

**修改 2a: acceptance_protocol step7** (约 line 1732)

当前:
```
step7: "【Knowledge Assessment】记录新发现（如有）"
```

改为:
```yaml
step7:
  name: "Knowledge Assessment — Write + Verify"
  action: |
    Two responsibilities:

    A. VERIFY Blake's Gate 3 knowledge (10 seconds):
       1. Read Blake's completion report → find "New discovery recorded: {path} → '{title}'"
       2. If Blake said "Yes": Read the referenced project-knowledge file, confirm the entry exists
       3. If entry missing → BLOCK *accept, inform user "Blake reported knowledge but didn't write it"

    B. WRITE Alex's own Gate 4 knowledge (if any):
       1. Evaluate: did this acceptance reveal business/architecture insights?
       2. If Yes → write directly to .tad/project-knowledge/{category}.md
       3. Fill Gate 4 Knowledge Assessment table with file path + entry title

    Separation of concerns:
    - Blake writes implementation knowledge (Gate 3): tool behaviors, code patterns, workarounds
    - Alex writes business knowledge (Gate 4): requirement gaps, architecture decisions, process improvements
  blocking: true
```

**修改 2b: gate4_v2_checklist knowledge_assessment** (约 line 1752-1757)

当前 (注意 6 空格缩进 + 尾部 anti-rationalization 注释):
```yaml
    knowledge_assessment:
      - "是否有新发现？(Yes/No) — 必须明确回答"
      - "如果有，确认已写入 .tad/project-knowledge/{category}.md"
      - "如果没有，确认原因合理（不能只写 N/A）"
      # ⚠️ ANTI-RATIONALIZATION: "常规 CRUD，没有新发现，Knowledge Assessment 是浪费"
      # → 即使无新发现也必须显式写 "No" + 原因。跳过 = 表格不完整 = Gate 无效。
```

改为 (保留缩进 + 保留 anti-rationalization):
```yaml
    knowledge_assessment:
      - "A. 验证 Blake Gate 3 知识：读 completion report 引用 → 确认 project-knowledge 条目存在"
      - "B. Alex 自己的发现：(Yes/No) — Yes 时填写文件路径 + 条目标题"
      - "如果 A 和 B 都是 No，确认原因合理（不能只写 N/A）"
      # ⚠️ ANTI-RATIONALIZATION: "常规 CRUD，没有新发现，Knowledge Assessment 是浪费"
      # → 即使无新发现也必须显式写 "No" + 原因。跳过 = 表格不完整 = Gate 无效。
```

---

### Layer 3: 复用保障 — Handoff step0.5 知识匹配 (Alex 侧)

**File:** `.claude/commands/tad-alex.md`

**修改 3: handoff_creation_protocol step0_5** (约 line 1370-1385)

当前 step0_5 做的是 "read ALL project knowledge files"。在其末尾追加一个知识匹配步骤:

在现有 step0_5 的 `action:` 末尾（"📖 Full knowledge refreshed" 之后）追加:

```yaml
    # Knowledge Matching — ensure relevant history reaches Blake
    5. After reading all knowledge files, scan each entry (### title - date) for relevance:
       a. Extract task keywords from current Socratic Inquiry results (topics, technologies, file paths, domain)
       b. For each knowledge entry: does its Context/Discovery mention any of these keywords?
       c. Collect all matching entries into a "relevant_knowledge" list
    6. When writing handoff §📚 Project Knowledge → "⚠️ Blake 必须注意的历史教训":
       a. ALL entries from relevant_knowledge list MUST be included (not optional, not "Alex picks")
       b. Format: entry title + source file + 1-line summary of why it's relevant to this task
       c. If relevant_knowledge is empty: write "✅ 已检查所有 knowledge 文件，无与本任务直接相关的历史教训"
    7. This replaces the current manual "Alex reads and picks relevant entries" approach.
       The scan is keyword-based and exhaustive — Alex cannot silently skip a matching entry.
    8. Matching is LLM semantic scan, not regex. Match related concepts
       (e.g., "hook" matches entries about hook scripts, shell portability).
       When in doubt, include — false positives acceptable, false negatives are not.
```

---

### Layer 3b: config-quality.yaml 同步

**File:** `.tad/config-quality.yaml`

**修改 4a: gate3 knowledge_assessment** (约 line 175-183)

当前:
```yaml
knowledge_assessment:
  required: true
  blocking: true
  questions:
    - "New discoveries during implementation? (Yes/No)"
    - "Category (if yes)"
    - "Brief summary"
  output_location: ".tad/project-knowledge/{category}.md"
```

改为:
```yaml
knowledge_assessment:
  required: true
  blocking: true
  questions:
    - "New discoveries during implementation? (Yes/No)"
    - "If Yes: file path written to (.tad/project-knowledge/{category}.md)"
    - "If Yes: entry title (### {title} - {date})"
    - "If No: reason"
  output_location: ".tad/project-knowledge/{category}.md"
  evidence_required: "Yes answer without file path + entry title = Gate FAIL"
  write_rule: "Write to project-knowledge directly. Completion report only references the entry, does not contain it."
```

**修改 4b: gate4 knowledge_assessment** (约 line 235-243)

同样格式改为:
```yaml
knowledge_assessment:
  required: true
  blocking: true
  questions:
    - "A. Blake Gate 3 knowledge verified? (check project-knowledge file exists)"
    - "B. New discoveries during acceptance? (Yes/No)"
    - "If B=Yes: file path + entry title"
    - "If A and B both No: reason"
  output_location: ".tad/project-knowledge/{category}.md"
  evidence_required: "Yes answer without file path + entry title = Gate FAIL"
  responsibility: "Blake writes implementation knowledge (Gate 3). Alex writes business knowledge (Gate 4). No overlap."
```

---

## Affected Files

| File | Changes |
|------|---------|
| `.claude/commands/tad-gate.md` | Gate 3 + Gate 4 Knowledge Assessment 表格模板 + 验证规则 |
| `.claude/commands/tad-alex.md` | acceptance_protocol step7 + gate4_v2_checklist + handoff step0_5 |
| `.tad/config-quality.yaml` | gate3 + gate4 knowledge_assessment 节 |

## Acceptance Criteria

- [ ] AC1: Gate 3 表格模板有 Evidence 列（file path + entry title）
- [ ] AC2: Gate 4 表格模板同样有 Evidence 列
- [ ] AC3: Gate 3 `if_new_discovery` 有 step5_verify + completion_report_rule
- [ ] AC4: Alex step7 拆为 A(验证Blake) + B(写自己的)，有 blocking 标记
- [ ] AC5: Alex gate4_v2_checklist 更新为 3 条（验证+写入+兜底）
- [ ] AC6: Alex handoff step0_5 追加关键词匹配 + 强制列出相关条目的步骤
- [ ] AC7: config-quality.yaml gate3 + gate4 同步更新 evidence_required 和 write_rule
- [ ] AC8: Gate 4 Knowledge_Assessment_Gate4 有 if_new_discovery 写入流程（与 Gate 3 对称）
- [ ] AC9: gate4_v2_checklist 修改保留了 anti-rationalization 注释
- [ ] AC10: 无其他功能回归（Gate 流程其他部分不变）
- [ ] AC11: tad-blake.md 不需修改（确认未改动）

## Blake Instructions

- 这是协议修复，不是功能开发。修改的都是 .md 和 .yaml 配置文件
- 每个修改点都给了精确的位置（line number）和 before/after 对比
- 用 Edit tool 做精确替换，不要重写整个文件
- 如果某个 line number 偏移了（因为之前的编辑），用 Grep 找到对应的文本再改

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-04
**Version**: 3.1.0
