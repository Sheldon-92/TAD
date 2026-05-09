# Handoff: 质量链修复 Phase 1 — Template 元数据 + 结构更新

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-03
**Project:** TAD
**Task ID:** TASK-20260403-009
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-quality-chain-full-repair.md (Phase 1/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-04-03

### Expert Review Status

| Expert | Result | P0 Fixed | Key Feedback |
|--------|--------|----------|-------------|
| code-reviewer | CONDITIONAL PASS → PASS (after fixes) | 3/3 | grep 正则修复、NFR1 矛盾修复、格式改 YAML frontmatter |
| backend-architect | CONDITIONAL PASS → PASS (after fixes) | 2/2 | YAML frontmatter 建议采纳、Phase 4 数据契约补充 |

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | YAML frontmatter 格式，shell 可靠解析 |
| Components Specified | ✅ | 2 个模板文件，变更点明确 |
| Functions Verified | ✅ | 模板文件路径已确认存在 |
| Data Flow Mapped | ✅ | YAML frontmatter → Prompt 引用 → Hook grep 解析 流向明确 |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
更新两个核心模板文件，为后续 Phase 2-4（Prompt 强制 + Hook 验证）提供数据结构基础。

### 1.2 Why We're Building It
**业务价值**：质量链审计发现 config-quality.yaml 定义了完善规则但 60%+ 未被任何执行机制引用。模板是数据的入口 — 如果模板不捕获 task_type、e2e_required 等信息，后续 Prompt 和 Hook 就无法引用。

**成功的样子**：当 Alex 写新 handoff 时，模板要求填写 task_type/e2e_required/research_required；当 Blake 写 completion report 时，模板要求填写 Knowledge Assessment 和 Evidence 清单。

### 1.3 Intent Statement

**真正要解决的问题**：模板缺少关键字段，导致设计时的决策（是否需要 E2E、是否需要研究）没有结构化记录，后续 Hook 无法读取和验证。

**不是要做的（避免误解）**：
- ❌ 不是重写模板 — 只增加缺失的字段/节
- ❌ 不是修改 Blake/Alex SKILL.md — 那是 Phase 2 和 3
- ❌ 不是修改 Hook 脚本 — 那是 Phase 4

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 修改了哪两个文件？
3. 新增的字段如何被后续 Phase 使用？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**

### 步骤 1：识别相关类别
- [x] architecture - 架构决策（质量链三层防线架构）

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | Judgment-Only 精简教训、Hook-Native 验证、Measure Before Optimizing |

**⚠️ Blake 必须注意的历史教训**：

1. **Judgment-Only Skill Files: 76% Reduction is Safe** (来自 architecture.md)
   - 问题：v2.7 将约束性规则误归为机械性指令并删除
   - 教训：约束性规则（防 LLM 走捷径的护栏）不可精简，即使看起来像机械指令

2. **Claude Code Enforcement Priority Order** (来自 architecture.md)
   - 问题：Hook 只能检测文件存在性，不能检测过程是否执行
   - 教训：Prompt 管"必须做什么"，Hook 管"做了没有"，两者互补不替代

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解这次模板更新是三层防线的数据基础

---

## 2. Background Context

### 2.1 Previous Work
- handoff-a-to-b.md (v3.1.0) — 当前模板，已有 MQ1-MQ6、Phase 结构、Spec Compliance Checklist
- completion-report.md (v1.0) — 当前模板，结构过时（仍有 Gate 3 + Gate 4 分离结构，v2.0 已改为 Gate 3 v2）

### 2.2 Current State
- handoff 模板缺少 task_type / e2e_required / research_required 元数据
- completion report 模板缺少 Knowledge Assessment 节、Evidence 清单节、Git commit hash 字段
- completion report 的 Gate 结构与 v2.0 不匹配（仍有旧版 Gate 4 节）

### 2.3 Dependencies
- 无外部依赖
- Phase 2/3/4 将引用本 Phase 新增的字段

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1: handoff-a-to-b.md 新增 YAML frontmatter 元数据**

在模板最顶部（`# Handoff Document` 标题之前）新增 YAML frontmatter 块：

```yaml
---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: code       # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no - yes 时 Blake 必须产出 E2E evidence
research_required: no # yes | no - yes 时 Blake 必须产出研究文件
---
```

**task_type 值说明**（供 Alex 填写参考，Phase 2 Blake SKILL.md 将基于此分支执行）：

| task_type | Layer 1 检查 | 典型场景 |
|-----------|-------------|---------|
| code | build + test + lint + tsc | 常规代码开发 |
| yaml | python3 yaml.safe_load + 结构验证 | Domain Pack、config 文件 |
| research | WebSearch 执行 + 搜索日志产出 | 技术调研、竞品分析 |
| e2e | 测试脚本执行 + evidence 产出 | 端到端测试任务 |
| mixed | 根据子任务分别适用上述检查 | 多类型混合任务 |

Shell 解析方式：`grep '^e2e_required:' file | awk '{print $2}'` — 无转义、无歧义。

**FR2: completion-report.md 新增 Knowledge Assessment 节**

在"验收检查清单"之前新增：

```markdown
## 📖 Knowledge Assessment (MANDATORY — Gate 3 BLOCKING)

**是否有新发现？** ✅ Yes / ❌ No

**如果 Yes：**
- **类别**: [architecture / code-quality / security / testing / performance / ux / api-integration / other]
- **标题**: [简短描述]
- **内容摘要**: [1-2 句话]
- **已写入**: .tad/project-knowledge/{category}.md ✅/❌

**如果 No：**
- **原因**: [常规实现无特殊发现 / 已有类似记录 / etc.]

⚠️ 此节留空 = Gate 3 无效 = VIOLATION
```

**FR3: completion-report.md 新增 Evidence 清单节**

在 Knowledge Assessment 之后新增：

```markdown
## 📂 Evidence Checklist (MANDATORY)

### Ralph Loop Evidence
- [ ] State file: .tad/evidence/ralph-loops/{task_id}_state.yaml
- [ ] Summary: .tad/evidence/ralph-loops/{task_id}_summary.md

### Expert Review Evidence
- [ ] Code review: .tad/evidence/reviews/{date}-code-review-{task}-final.md
- [ ] Testing review: .tad/evidence/reviews/{date}-testing-review-{task}-final.md
- [ ] Security review: .tad/evidence/reviews/{date}-security-review-{task}-*.md (if triggered)
- [ ] Performance review: .tad/evidence/reviews/{date}-performance-review-{task}-*.md (if triggered)

### Acceptance Verification Evidence
- [ ] Report: .tad/evidence/acceptance-tests/{task_id}/acceptance-verification-report.md
- [ ] Scripts: .tad/evidence/acceptance-tests/{task_id}/AC-*.* ({count} scripts)

### Git Commit
- **Commit Hash**: [hash or NONE for doc-only]
- **Verified**: `git log --oneline -1` output matches ✅/❌

### Conditional Evidence (from Handoff metadata)
- **E2E Required (from Handoff)**: yes/no
  - If yes → E2E evidence file: [path] ✅/❌
- **Research Required (from Handoff)**: yes/no
  - If yes → Research file: [path] ✅/❌

⚠️ Required evidence 未勾选 = Gate 3 不可通过
```

**FR4: completion-report.md Gate 结构更新**

- 删除旧的"Gate 4: Integration Verification"节（v2.0 已将技术检查合并到 Gate 3 v2）
- 更新 Gate 3 节为 "Gate 3 v2: Implementation & Integration Quality"
- Gate 3 v2 检查项与 config-quality.yaml gate3_v2 对齐

### 3.2 Non-Functional Requirements
- NFR1: handoff 模板现有节标题和结构不被破坏（只增不删）。例外：completion-report.md 旧版 Gate 4 节按 FR4 intentionally 删除（v2.0 结构升级）
- NFR2: 新增字段必须有注释说明用途和合法值
- NFR3: 元数据使用 YAML frontmatter 格式，shell 解析方式：`grep '^e2e_required:' file | awk '{print $2}'`

---

## 4. Technical Design

### 4.1 handoff-a-to-b.md 变更位置

在文件最顶部（`# Handoff Document` 标题之前）插入 YAML frontmatter 块。现有内容从 `# Handoff Document` 开始不变。

### 4.2 completion-report.md 变更

1. **Gate 结构更新**（`## 🔴 Gate 3` 节区域）：
   - 将 "Gate 3" 重命名为 "Gate 3 v2: Implementation & Integration Quality"
   - 更新检查项：加入 Ralph Loop evidence、Expert evidence、Acceptance verification、Knowledge Assessment、Git commit
   - 删除 `## 🔴 Gate 4: Integration Verification` 节（v2.0 已合并入 Gate 3 v2，见 FR4）

2. **新增 Knowledge Assessment 节**（在 `## 🎯 验收检查清单` 之前）

3. **新增 Evidence Checklist 节**（在 Knowledge Assessment 之后）

4. **更新验收检查清单**：加入 Evidence Checklist 和 Knowledge Assessment 完成确认

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/templates/handoff-a-to-b.md     # 新增 3 个元数据字段
.tad/templates/completion-report.md   # Gate 结构更新 + 新增 2 个节
```

### 7.2 Files to Create
无

---

## 8. Testing Requirements

### 8.1 验证方法
- **YAML 解析测试**: 新增的元数据字段可被 grep 正确提取
- **结构完整性**: 模板的 Markdown 结构完整（无未闭合的代码块）
- **向后兼容**: 现有 handoff 和 completion report 的节标题不变

### 8.2 Edge Cases
- 元数据字段值为空时的表现（模板注释应说明"必填"）

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] **AC1**: handoff-a-to-b.md 顶部有 YAML frontmatter 块，包含 task_type / e2e_required / research_required 三个字段及注释
- [ ] **AC2**: completion-report.md 有 Knowledge Assessment 节，包含 Yes/No 判断 + 类别 + 内容 + VIOLATION 警告
- [ ] **AC3**: completion-report.md 有 Evidence Checklist 节，覆盖 config-quality.yaml 定义的所有 evidence 类型（ralph_loop + expert + acceptance + git + conditional）
- [ ] **AC4**: completion-report.md Gate 结构与 v2.0 对齐（Gate 3 v2，无旧版 Gate 4 Integration 节）
- [ ] **AC5**: YAML frontmatter 可被 shell 解析：`grep '^e2e_required:' .tad/templates/handoff-a-to-b.md | awk '{print $2}'` 输出 `no`（模板默认值）
- [ ] **AC6**: handoff 模板现有节标题不被删除（向后兼容）；completion-report 旧 Gate 4 节按 FR4 删除（预期行为）
- [ ] **AC7 (BLOCKING)**: 必须走 Ralph Loop + Gate 3

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | YAML frontmatter 存在 | `head -5 .tad/templates/handoff-a-to-b.md` | 首行为 `---`，含 task_type/e2e_required/research_required |
| 2 | Knowledge Assessment 节 | `grep 'Knowledge Assessment' .tad/templates/completion-report.md` | 1+ matches |
| 3 | Evidence Checklist 节 | `grep 'Evidence Checklist' .tad/templates/completion-report.md` | 1+ matches |
| 4 | Gate 3 v2 对齐 | `grep 'Gate 3 v2' .tad/templates/completion-report.md` | 存在 |
| 4b | 旧 Gate 4 已删除 | `grep -c 'Gate 4.*Integration' .tad/templates/completion-report.md` | 0 matches |
| 5 | Shell 可解析 | `grep '^e2e_required:' .tad/templates/handoff-a-to-b.md \| awk '{print $2}'` | 输出 `no` |
| 6 | 向后兼容 | handoff 模板现有 `## ` 节标题仍存在 | 无标题删除 |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 这是 4 Phase Epic 的第一步 — 后续 Phase 2/3/4 都依赖这里的字段定义
- ⚠️ 元数据字段的命名和格式一旦确定，Hook 脚本会基于此解析，后续改名成本高
- ⚠️ completion-report.md 删除旧 Gate 4 节是有意为之（v2.0 Gate 4 由 Alex 负责，不在 Blake 的 report 里）

### 10.2 Known Constraints
- YAML frontmatter 值必须是单个词（no/yes/code 等），不能含空格或特殊字符
- Evidence 路径中 `{date}` 格式为 YYYY-MM-DD（与 config-quality.yaml template_triggers.date_format 一致）
- Knowledge Assessment category 合法值：architecture / code-quality / security / testing / performance / ux / api-integration / mobile-platform / frontend-design / other（与 .tad/project-knowledge/ 目录对齐）

### 10.3 Phase 4 Data Contract（Hook 解析依赖）

Phase 4 Hook 将按以下流程解析本 Phase 定义的字段：

1. 从 completion report 读取 `**Handoff ID:**` 字段 → 定位对应 handoff 文件
2. 从 handoff YAML frontmatter 读取 `e2e_required` 和 `research_required`
3. 如果 `e2e_required: yes` → 检查 `.tad/evidence/` 下是否有 E2E 相关文件 → 无则 BLOCK Gate 3
4. 如果 `research_required: yes` → 检查对应研究产出文件 → 无则 BLOCK Gate 3
5. 从 completion report 检查 Knowledge Assessment 节非空 → 空则 WARN
6. 从 completion report 检查 Evidence Checklist 中 required 项已勾选 → 未勾选则 WARN

解析命令参考：
```bash
# 从 handoff 读取 frontmatter 字段
grep '^e2e_required:' "$HANDOFF_FILE" | awk '{print $2}'
grep '^research_required:' "$HANDOFF_FILE" | awk '{print $2}'

# 从 completion report 读取 handoff ID
grep -oP '(?<=\*\*Handoff ID:\*\* ).*' "$COMPLETION_FILE"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-03
**Version**: 3.1.0
