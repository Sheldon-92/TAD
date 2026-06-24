---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-23
**Project:** TAD Framework
**Task ID:** TASK-20260623-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260623-gate-definition-consolidation.md (Phase 1/2)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-23

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | SSOT 架构明确：一个权威文件 + 其余引用 |
| Components Specified | ✅ | 6 个源文件逐一映射，迁移目标清晰 |
| Functions Verified | ✅ | YAML/MD 协议文件，无代码函数 |
| Data Flow Mapped | ✅ | 引用方向：alex/blake/gate SKILL → canonical file |

**Gate 2 结果**: (pending expert review)

---

## 1. Task Overview

### 1.1 What We're Building
创建 Gate 1-4 checklist 的单一权威定义文件（SSOT），让所有其他文件引用它而不是各自维护独立副本。

### 1.2 Why We're Building It
同一个 Gate 在 6+ 个文件中有**不同的 checklist 项**。比如 Gate 1 在 alex/SKILL.md 是 3 项，在 gate/SKILL.md 是另外 3 项，在 quality-gate-checklist.md 是 6 项。改任何一个都不影响其他 5 个。

### 1.3 Intent Statement
**真正要解决的问题**：Gate 定义无权威源，导致修改后 drift 不可避免。
**不是要做的**：
- ❌ 不 MECE 化 checklist 项（那是下一步）
- ❌ 不改 Gate 执行协议（KA、subagent 等）
- ❌ 不改 Gate 数量/顺序/所有权

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ Blake 必须注意的历史教训**：

1. **Deny-List at Every Copy Granularity** (来自 principles.md)
   - 问题：修复一层的同步不修复其他层
   - 相关：改 Gate 定义时，确保所有引用文件都更新

---

## 2. Background Context

### 2.1 Gate 定义地图（6 个源文件）

| # | 文件 | Gate 覆盖 | 行号 | 用途 |
|---|------|----------|------|------|
| 1 | `.claude/skills/alex/SKILL.md` | G1(3项), G2(3项), G4(多处) | 1199-1238 + ~1742 quick-ref | Alex 所有权声明 |
| 2 | `.claude/skills/gate/SKILL.md` | G1(3项), G2(4项), G3(5项), G4(6项) | 55-92, 263-382, 710-810 | Gate 执行 checklist |
| 3 | `.claude/skills/blake/SKILL.md` | G3(full), G4(items) | 1080-1180 | Blake 自检清单 |
| 4 | `.tad/config-quality.yaml` | G1/G2/G3 checks | 58-100 | 配置级 checks 列表 |
| 5 | `.tad/gates/quality-gate-checklist.md` | G1-G4 全部(341行) | 全文 | 独立完整 checklist |
| 6 | `.claude/skills/alex/references/acceptance-protocol.md` | G4 相关 | 多处 | 验收流程中的 Gate 4 引用 |

### 2.2 语义区分（不能盲目合并的原因）

| 用途 | 文件 | 内容特点 |
|------|------|---------|
| **所有权声明** | alex/SKILL.md, blake/SKILL.md | "我负责检查哪些项" — 轻量级，面向 agent 自身 |
| **执行 checklist** | gate/SKILL.md | "执行 Gate 时逐项验证" — 详细，含输出格式模板 |
| **配置** | config-quality.yaml | 结构化数据，被 hooks/scripts 读取 |
| **完整参考** | quality-gate-checklist.md | 最详细的独立文档 |

---

## 4. Technical Design

### 4.1 SSOT 架构（修复 Architect P1：canonical = 维护源，非运行时源）

```
新建: .tad/gates/gate-canonical-checklist.md（维护源 — THE place to change Gate items）
  ├── Gate 1-4 完整 checklist 项 + 说明
  └── 所有修改从这里开始，然后传播到内联副本

gate/SKILL.md（执行层）:
  → 保持 checklist 项 INLINE（运行时不依赖额外 Read）
  → 但项的内容 DERIVED FROM canonical
  → 头部注释: "# Canonical source: .tad/gates/gate-canonical-checklist.md — edit there first, then sync here"

其他文件:
  alex/SKILL.md    → 精简版引用 + "canonical at .tad/gates/..."
  blake/SKILL.md   → 精简版引用 + "canonical at .tad/gates/..."
  config-quality.yaml → 保留 YAML 结构（脚本消费者依赖），checks 值对齐 canonical
  quality-gate-checklist.md → SUPERSEDED 标记

Drift 检测:
  维护时通过 diff 比对 canonical vs gate/SKILL.md 内联项，发现不一致
```

### 4.2 Canonical 文件格式

```markdown
# Gate Canonical Checklist (SSOT)
> THE authoritative definition of Gate 1-4 checklist items.
> All other files MUST reference this file, not duplicate items.
> Last reconciled: 2026-06-23

## Gate 1: Requirements Clarity
**Owner:** Alex | **When:** After Socratic Inquiry, before *design

Checklist items:
- [ ] Problem defined — 问题定义清晰（Socratic Q2 输出）
- [ ] User identified — ICP 或目标用户已定义（Socratic Q1）
- [ ] Scope bounded — 范围和排除项明确（Socratic Q3a/Q3b）
- [ ] Acceptance criteria defined — AC 可验证

## Gate 2: Design Completeness  
**Owner:** Alex | **When:** Before handoff to Blake

Checklist items:
- [ ] Expert review complete — min 2 experts
- [ ] All P0 resolved — blocking issues fixed
- [ ] Architecture complete — 组件、数据流、API 都有
- [ ] Functions verified — 引用的函数/文件存在

## Gate 3: Implementation Quality
**Owner:** Blake | **When:** After implementation

Checklist items:
- [ ] Code/deliverable complete — all handoff tasks done
- [ ] §9.1 Spec Compliance — every row verified
- [ ] Evidence files exist — per handoff manifest
- [ ] Git commit done — hash recorded
- [ ] Knowledge Assessment complete — journal or "no discovery"

## Gate 4: Business Acceptance
**Owner:** Alex | **When:** After Gate 3 passes

Checklist items:
- [ ] Business acceptance — §9 AC met
- [ ] Ready for user — no known blockers
- [ ] Quality evidence — security/performance/code review done
- [ ] All subagent feedback addressed
- [ ] Knowledge Assessment complete — distillation or "no discovery"
```

### 4.3 传播模式（修复 Architect P1：不依赖运行时 Read）

```
修改流程:
1. 编辑 canonical 文件（唯一的"改定义"入口）
2. 手动传播到 gate/SKILL.md 内联副本（高频执行层）
3. 更新 alex/blake SKILL.md 精简版（低频所有权层）
4. 验证: diff canonical 项 vs gate/SKILL.md 内联项

gate/SKILL.md 头部注释:
  # ═══ Gate Checklist Items (inline — derived from canonical) ═══
  # Canonical source: .tad/gates/gate-canonical-checklist.md
  # Edit canonical FIRST, then sync here. Drift check: diff canonical vs this section.

alex/blake SKILL.md:
  # Gate items: see .tad/gates/gate-canonical-checklist.md for full definitions
  (保留 owner + when + 精简项名，不内联完整说明)

config-quality.yaml:
  # 保留完整 YAML 结构（AC-04-config-evidence.sh 依赖）
  # checks: 值对齐 canonical，用 YAML key 不用注释
  gate_checklist_source: ".tad/gates/gate-canonical-checklist.md"
  # v1 gates (gate1_requirement 等): 保留结构，值对齐 canonical
  # v2 gates (gate3_v2 等): 保留结构，值对齐 canonical
```

### 4.4 Reconciliation 决策（修复 CR P1：逐项 KEPT/DROPPED）

**Gate 1 — 来源: alex(3项) + gate(3项) + quality-checklist(6项)**

| 源 | 项 | 处置 | 理由 |
|----|-----|------|------|
| alex | All key questions answered | MERGED → "Problem defined" + "Scope bounded" | 太宽泛，拆为具体维度 |
| alex | Edge cases identified | MERGED → "Scope bounded" | 边界条件属于范围定义 |
| alex | Acceptance criteria defined | KEPT | 独立维度 |
| gate | User confirmed understanding | MERGED → "Problem defined" | 用户理解 = 问题定义清晰 |
| gate | Success criteria defined | MERGED → "AC defined" | 同义 |
| gate | Requirements documented | DROPPED | 文档化是手段不是检查项 |
| checklist | Business Value Clear | DROPPED | 属于 Socratic Q2 职责，非 Gate 检查 |
| checklist | User Story Complete | DROPPED | TAD 不用 user story 格式 |
| checklist | Historical Code Searched | DROPPED | 属于 MQ1 (handoff §5)，非 Gate 1 |
| (new) | User identified | ADDED | P1 ICP 新增维度 |

**Gate 2 — 来源: alex(3项) + gate(4项)**

| 源 | 项 | 处置 | 理由 |
|----|-----|------|------|
| alex | Expert review complete | KEPT | 核心流程项 |
| alex | P0 issues resolved | KEPT | 核心质量项 |
| alex | Implementation details sufficient | DROPPED | 被 expert review + gate 4 项覆盖 |
| gate | Architecture Complete | KEPT (inline in gate/SKILL.md) | 执行层需要 |
| gate | Components Specified | KEPT (inline) | 执行层需要 |
| gate | Functions Verified | KEPT (inline) | 执行层需要 |
| gate | Data Flow Mapped | KEPT (inline) | 执行层需要 |

**结论**: Gate 2 canonical 保留 alex 2 项 + gate 4 项 = 6 项。gate/SKILL.md 内联全部 6 项。alex/SKILL.md 精简为 "Expert review + P0 resolved + 详见 canonical"。

**Gate 3 — 所有源一致**。以 gate/SKILL.md 5 项为准。

**Gate 4 — 来源: gate(6项) + alex(多处) + blake + acceptance-protocol**
以 gate/SKILL.md 6 项为基准（最权威执行层）。不做合并/删减（MECE 优化留给后续 Epic）。

---

## 6. Implementation Steps

### Phase 1: 创建 canonical 文件（15 分钟）
1. Read 所有 6 个源文件的 Gate 段
2. 按 §4.4 reconciliation 表决定每个 Gate 的最终项
3. 创建 .tad/gates/gate-canonical-checklist.md（按 §4.2 格式）

### Phase 2: 更新引用文件（30 分钟）
1. alex/SKILL.md: my_gates 段改为精简引用
2. gate/SKILL.md: Gate 1/2 段改为引用 canonical（Gate 3/4 执行协议保留，checklist 引用 canonical）
3. blake/SKILL.md: my_gates 段改为精简引用
4. config-quality.yaml: checks 段引用 canonical
5. quality-gate-checklist.md: 加 SUPERSEDED 标记，指向 canonical
6. acceptance-protocol.md: Gate 4 引用指向 canonical

### Phase 3: 同步 .agents/（5 分钟）
1. 复制修改后的 .claude/ 文件到 .agents/
2. diff 验证字节一致

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/gates/gate-canonical-checklist.md    # THE SSOT
```

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md              # my_gates → reference
.claude/skills/gate/SKILL.md              # Gate 1/2 → reference, Gate 3/4 checklist → reference
.claude/skills/blake/SKILL.md             # my_gates → reference
.tad/config-quality.yaml                  # checks → reference
.tad/gates/quality-gate-checklist.md      # SUPERSEDED marker
.claude/skills/alex/references/acceptance-protocol.md  # Gate 4 → reference
.agents/skills/alex/SKILL.md              # Mirror
.agents/skills/gate/SKILL.md              # Mirror
.agents/skills/blake/SKILL.md             # Mirror
```

---

## 9. Acceptance Criteria

- [ ] AC1: .tad/gates/gate-canonical-checklist.md 存在，包含 Gate 1-4 所有 checklist 项
- [ ] AC2: alex/SKILL.md my_gates 段不再内联 checklist 项（改为引用）
- [ ] AC3: gate/SKILL.md Gate 1/2 定义段引用 canonical
- [ ] AC4: blake/SKILL.md my_gates 段引用 canonical
- [ ] AC5: config-quality.yaml checks 段引用 canonical
- [ ] AC6: quality-gate-checklist.md 标记为 SUPERSEDED
- [ ] AC7: Gate 执行 dry-run：gate/SKILL.md 的 Gate 3 执行流程能找到 canonical checklist 项
- [ ] AC8: .agents/ 镜像字节一致
- [ ] AC9: config-quality.yaml 保留完整 YAML 结构（AC-04-config-evidence.sh 仍能通过）
- [ ] AC10: config-quality.yaml v1/v2 gate 条目都对齐 canonical（不删除，保留结构）

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | Canonical 文件存在 | post-impl-verifiable | `test -f .tad/gates/gate-canonical-checklist.md && echo EXISTS` | EXISTS | (post-impl) |
| 2 | Canonical 含 4 个 Gate | post-impl-verifiable | `grep -c '^## Gate [1234]' .tad/gates/gate-canonical-checklist.md` | 4 | (post-impl) |
| 3 | alex 引用 canonical | post-impl-verifiable | `grep -c 'gate-canonical-checklist' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| 4 | gate 引用 canonical | post-impl-verifiable | `grep -c 'gate-canonical-checklist' .claude/skills/gate/SKILL.md` | ≥1 | (post-impl) |
| 5 | blake 引用 canonical | post-impl-verifiable | `grep -c 'gate-canonical-checklist' .claude/skills/blake/SKILL.md` | ≥1 | (post-impl) |
| 6 | SUPERSEDED 标记 | post-impl-verifiable | `grep -c 'SUPERSEDED' .tad/gates/quality-gate-checklist.md` | ≥1 | (post-impl) |
| 7 | .agents/ mirror | post-impl-verifiable | `diff .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` | exit 0 | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Experts Selected
1. **code-reviewer** — File structure accuracy, script consumer survival, reconciliation completeness
2. **backend-architect** — SSOT architecture pattern reliability, LLM reference semantics, SPOF risk

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| architect | P1: Comment-based reference unreliable for LLM — gate/SKILL.md must keep inline | §4.1 rewritten: canonical=maintenance source, gate/SKILL.md=inline derived | Resolved |
| architect | P1: config-quality.yaml should use YAML key not comment | §4.3 updated: `gate_checklist_source:` YAML key | Resolved |
| architect | P2: SPOF if canonical missing | §10.1 warning added; AC7 dry-run covers | Noted |
| architect | P2: Reconciliation needs per-item KEPT/DROPPED | §4.4 rewritten: full per-item table with rationale | Resolved |
| code-reviewer | P1: AC-04-config-evidence.sh parses config-quality.yaml | §4.3 preserves YAML structure; AC9 added for script survival | Resolved |
| code-reviewer | P1: Gate 1 canonical drops items without noting | §4.4 full reconciliation table added with DROPPED rationale | Resolved |
| code-reviewer | P1: config-quality.yaml dual v1/v2 naming unaddressed | §4.3 + AC10: both v1/v2 preserved, values aligned to canonical | Resolved |
| code-reviewer | P2: CLAUDE.md is 7th source not in file map | Noted — CLAUDE.md has routing rules not checklist items; cross-ref sufficient |
| code-reviewer | P2: Expert review section empty | §9.2 filled (this table) | Resolved |

### Overall Assessment (post-integration)
- **code-reviewer**: PASS (0 P0, 3 P1 resolved, 2 P2 noted)
- **backend-architect**: PASS (0 P0, 2 P1 resolved, 2 P2 noted)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ alex/SKILL.md 和 blake/SKILL.md 是核心文件——改动时保持其余 section 完全不变
- ⚠️ gate/SKILL.md 的 Gate 3/4 执行协议（KA、subagent 流程、verdict marker）不改——只改 checklist 引用
- ⚠️ config-quality.yaml 可能被 hooks/scripts 读取——确保引用格式不 break 现有消费者
- ⚠️ 用户最担心的风险：引用断裂。每改一个文件后立即验证引用可解析

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-23
**Version**: 3.1.0
