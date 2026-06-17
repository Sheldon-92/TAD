---
task_type: mixed
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
**Date:** 2026-06-17
**Project:** TAD Framework
**Task ID:** TASK-20260617-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260616-research-system-consolidation.md (Phase 4/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-17

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | research-engine 删除 + pack-upgrade 迁移方案明确 |
| Components Specified | ✅ | agent() 内联 NotebookLM 替代 workflow('research-engine') |
| Functions Verified | ✅ | workflow() nesting 替换为 agent() + Bash(notebooklm CLI) |
| Data Flow Mapped | ✅ | pack topic → notebook create/find → research fast → ask → cited report |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
删除 `research-engine` workflow，将 `pack-upgrade` workflow 的研究步骤从 `workflow('research-engine')` 嵌套调用迁移为 `agent()` 内联 NotebookLM 研究。更新 ROADMAP.md。

### 1.2 Why We're Building It
**业务价值**：research-engine workflow 与统一 `*research` 系统重叠，删除减少维护面。pack-upgrade 迁移到 NotebookLM 让升级包的研究质量与日常研究一致
**用户受益**：pack-upgrade 的研究结果存入 NotebookLM notebook（持久可查），不再是一次性 WebSearch（用完即丢）

### 1.3 Intent Statement

**真正要解决的问题**：research-engine 是 `*research` 统一前的遗留物，现在与统一系统重叠且仍被 pack-upgrade 依赖。

**不是要做的**：
- ❌ 不是同步到 14 个项目（等下次 *publish）
- ❌ 不是修改 `*research` 协议本身（Phase 1-3 已完成）
- ❌ 不是修改其他 workflow（只改 pack-upgrade）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **NotebookLM 使用 -n flag** (patterns/research-methodology.md)
   - pack-upgrade 的 agent 调 notebooklm 时必须用 `-n <id>`，不用 `use <id>`

2. **Conductor Architecture: sub-agent nesting** (project memory)
   - workflow() 内 workflow() 只允许一层。现在删掉 research-engine，pack-upgrade 不再嵌套 workflow，改为 agent() + Bash 直调 CLI

3. **Research Before Upgrade** (feedback memory)
   - pack-upgrade 先研究再升级的原则不变——只是研究手段从 research-engine(WebSearch) 变为 NotebookLM

---

## 2. Background Context

### 2.1 Current State
`pack-upgrade.workflow.js` L190:
```javascript
const research = await workflow('research-engine', {
  question: researchQ,
  max_rounds: RESEARCH_MAX_ROUNDS,
  saturation_k: RESEARCH_SATURATION_K,
  evidence_dir: packEvDir
})
```

这调用 `research-engine.workflow.js` 做 WebSearch 迭代研究。research-engine 本身是一个完整 workflow（Plan→Deepen→Verify→Synthesize）。

### 2.2 Migration Target
替换为一个 `agent()` 调用，agent 用 Bash 工具调 `notebooklm` CLI 做研究：
1. 检查/创建 notebook
2. `source add-research --mode fast`
3. `ask` 关键问题
4. 返回引用的研究发现（structured output）

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: 删除 `.claude/workflows/research-engine.workflow.js`
- FR2: `pack-upgrade.workflow.js` 的 Plan 阶段替换 `workflow('research-engine', ...)` 为 `agent()` + NotebookLM
- FR3: agent 的 prompt 指导它：preflight → find/create notebook → research fast → ask 2-3 domain questions → return structured findings
- FR4: NotebookLM 不可用时降级为 WebSearch（agent 内部 preflight 检查）
- FR5: 更新 ROADMAP.md 反映研究系统整合
- FR6: 更新所有引用 research-engine 的文件（skill descriptions, whenToUse 等）

### 3.2 Non-Functional Requirements

- NFR1: pack-upgrade pipeline 中 packs 是 pipeline 执行（非 barrier），每个 pack 的 agent() 研究独立运行
- NFR2: 每个 pack 的研究创建独立 notebook（或复用已有匹配 notebook），无并发冲突
- NFR3: 研究结果 schema 保持与原 research-engine 兼容（`findings[]` + `sources_count` + `confidence`）以最小化 Plan 阶段下游改动

---

## 4. Technical Design

### 4.1 删除 research-engine

直接删除 `.claude/workflows/research-engine.workflow.js`。

清理引用：
- `pack-upgrade.workflow.js` 头部注释（L1-22 提到 research-engine）
- Alex SKILL.md 中如有 research-engine 引用
- 系统 skill 列表中的 `research-engine` 条目（如果在 settings 中注册）

### 4.2 pack-upgrade 研究步骤迁移

替换 L190 的 `workflow('research-engine', ...)` 为：

```javascript
const research = await agent(
  'You are a research agent. Research this domain using NotebookLM CLI.\n\n' +
  'DOMAIN: ' + packName + '\n' +
  'RESEARCH QUESTION: ' + researchQ + '\n\n' +
  'STEPS (execute via Bash tool):\n' +
  '1. Preflight: test -x ~/.tad-notebooklm-venv/bin/notebooklm\n' +
  '   If FAIL: fall back to WebSearch (3+ queries + WebFetch). Skip NotebookLM steps.\n' +
  '2. Check REGISTRY: Read .tad/research-notebooks/REGISTRY.yaml\n' +
  '   Find notebook matching "' + packName + '" domain (semantic match on topic field).\n' +
  '   If found (active): use it. If not found: create new notebook:\n' +
  '   ~/.tad-notebooklm-venv/bin/notebooklm create "' + packName + ' capability research"\n' +
  '3. Research: ~/.tad-notebooklm-venv/bin/notebooklm source add-research "' + packName + '" --mode fast --import-all -n <id>\n' +
  '4. Ask 2-3 domain-specific questions:\n' +
  '   ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n <id>\n' +
  '   Questions should cover: current best practices, common tools/frameworks, version-sensitive specifics.\n' +
  '5. Return findings as structured JSON.\n\n' +
  '5. VERIFY (adversarial fact-check — P0 fix): For each finding with a version-sensitive specific\n' +
  '   (number, threshold, API name, version), WebSearch the primary documentation to verify currency.\n' +
  '   Mark any refuted claim as REFUTED with the correct value. Drop refuted claims from findings.\n' +
  '6. WRITE REPORT: Write all verified findings to a markdown report file at\n' +
  '   ' + packEvDir + '/research-' + packName + '.md with sections:\n' +
  '   # Research: {packName}\n' +
  '   ## Summary (3-5 bullet findings)\n' +
  '   ## Findings (grouped by question, each with source citation)\n' +
  '   ## Contradictions / Open Questions\n' +
  '   ## Sources (deduped list)\n' +
  '   Return the report_path so the Plan agent can READ it.\n\n' +
  'ANTI-HALLUCINATION: every finding MUST carry a source reference from NotebookLM citations [N].\n' +
  'If NotebookLM is unavailable (step 1 failed), use WebSearch source URLs instead.\n' +
  'Return report_path, findings[], sources_count, open_questions[], and confidence (high/medium/low).',
  {
    label: 'research-' + packName,
    phase: 'Plan',
    schema: RESEARCH_SCHEMA,
    model: 'sonnet'
  }
)
```

### 4.3 RESEARCH_SCHEMA 定义

保持与原 research-engine 的返回 schema 兼容，最小化下游改动：

```javascript
const RESEARCH_SCHEMA = {
  type: 'object',
  required: ['report_path', 'findings', 'sources_count', 'confidence'],
  properties: {
    report_path: { type: 'string', description: 'Path to the markdown report file written to disk' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['claim', 'source_ref'],
        properties: {
          claim: { type: 'string' },
          source_ref: { type: 'string', description: 'NotebookLM citation [N] or WebSearch URL' },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] }
        }
      }
    },
    sources_count: { type: 'number' },
    open_questions: { type: 'array', items: { type: 'string' }, description: 'Unanswered questions or gaps' },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
    notebook_id: { type: 'string', description: 'NotebookLM notebook ID if used, null if WebSearch fallback' }
  }
}

// P0 fix: report_path is now REQUIRED — the agent writes a report file to disk,
// preserving the existing plan prompt's file-reading grounding mechanism.
// The researchOk check (!!research.report_path) continues to work as before.
// open_questions is now included so the plan prompt can interpolate them.
```

### 4.4 下游影响分析（P0 fix — 完整枚举）

原 research-engine 返回：
```javascript
{ rounds_run, saturation_reason, findings_count, sources_count, report_path, open_questions, confidence, round_stats }
```

新 agent 返回：`{ report_path, findings, sources_count, open_questions, confidence, notebook_id }`

**保持兼容的字段**（无需改动）：
- `report_path` — 新 agent 写报告文件到磁盘并返回路径（与原行为一致）
- `sources_count` — 同名同义
- `confidence` — 同名同义
- `open_questions` — 现在包含在 schema 中

**需要调整的下游代码**（Blake 必须逐行处理）：
- L202 `researchOk = !!(research && research.report_path)` — **无需改动**（report_path 现在是 required 字段）
- L203 `reportPath = research.report_path` — **无需改动**
- L204 `openQs = research.open_questions || []` — **无需改动**（字段保留）
- L205-207 log 行引用 `research.findings_count` → 改为 `(research.findings || []).length`
- L227 plan prompt 中 `${reportPath}` 引用 — **无需改动**（agent 写了报告文件）
- L279 Upgrade prompt 中 "research-engine" 文字 → 改为 "NotebookLM research"

**可安全删除的字段引用**：
- `rounds_run` — 不再有多轮（未被下游引用）
- `saturation_reason` — 同上
- `round_stats` — 同上

### 4.5 ROADMAP.md 更新

在 "Dynamic Workflow Integration" theme 下添加：
```
| Research System Consolidation | Epic | Complete | [Epic](./.tad/active/epics/EPIC-20260616-research-system-consolidation.md) |
```

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 → 修改现有 `pack-upgrade.workflow.js`
- 搜索证据：已读取 pack-upgrade.workflow.js 全文，确认 L190 `workflow('research-engine', ...)` 调用点 + 下游引用

### MQ2: 函数存在性验证
- `workflow()` → 现有 Workflow runtime API ✅
- `agent()` → 现有 Workflow runtime API ✅
- `notebooklm` CLI → `~/.tad-notebooklm-venv/bin/notebooklm` ✅ (preflight 检查)

---

## 6. Implementation Steps

### Step 1: 删除 research-engine workflow
- `rm .claude/workflows/research-engine.workflow.js`
- 清理所有引用（grep 确认）

### Step 2: 修改 pack-upgrade.workflow.js
- 在文件顶部添加 `RESEARCH_SCHEMA` 定义（§4.3，含 report_path + open_questions）
- 替换 L190 `workflow('research-engine', ...)` 为 `agent()` 调用（§4.2，含 VERIFY step + WRITE REPORT step）
- 调整下游引用（§4.4 完整枚举）：`research.findings_count` → `(research.findings || []).length`；L279 "research-engine" → "NotebookLM research"
- 更新 `meta.description`（L25）和 `meta.whenToUse`（L26）：移除 "compose research-engine inline"，改为 NotebookLM 描述
- 更新 `phases[0].detail`（L28）：同上
- 更新头部注释（L1-22）：移除 research-engine 引用
- 删除 `RESEARCH_MAX_ROUNDS`、`RESEARCH_SATURATION_K` 常量及其相关的 `researchMaxRounds`、`researchSaturationK` 解析变量
- 保留 `research-failure detection` 逻辑（`researchOk` 检查无需改动——report_path 保持兼容）

### Step 3: 更新 ROADMAP.md
- 添加 Research System Consolidation Epic 条目

### Step 4: 清理其他引用
- grep 全范围确认无残留 `research-engine` 引用（除归档/history/evidence 文件外）
- 特别检查：`.tad/active/SURPLUS-PLAN-*.json` 中引用 research-engine 的条目 → 标记为 obsolete
- CHANGELOG.md / NEXT.md 中的历史性引用可保留（记录性质）
- agent prompt 中 `packName` 插值说明：packName 来自硬编码 DEFAULT_PACKS 数组或 args，非用户输入，shell 注入风险极低。但 agent 实现时应对 packName 做 alphanumeric+hyphen 校验

---

## 7. File Structure

### 7.1 Files to Create
无

### 7.2 Files to Modify
```
.claude/workflows/research-engine.workflow.js    # DELETE
.claude/workflows/pack-upgrade.workflow.js       # MODIFY — 研究步骤迁移
ROADMAP.md                                       # MODIFY — Epic 条目
```

### 7.3 Grounded Against
- `.claude/workflows/pack-upgrade.workflow.js` (read 2026-06-17 — L1-80, L174-221)
- `.claude/workflows/research-engine.workflow.js` (read 2026-06-16 — full 406 lines)
- `ROADMAP.md` (read 2026-06-16 — full file)

---

## 8. Testing Requirements

### 8.1 Edge Cases
- NotebookLM CLI 不可用 → agent 降级为 WebSearch 研究（返回 notebook_id: null）
- REGISTRY.yaml 不存在 → agent 创建新 notebook
- pack-upgrade 并行跑多个 pack → 每个 pack 独立 notebook，无冲突
- agent() 返回 null（agent 失败）→ 现有 research-failure detection 应处理

## 8.4 Friction Preflight
无特殊摩擦点。

---

## 9. Acceptance Criteria

- [ ] research-engine.workflow.js 已删除
- [ ] pack-upgrade 研究步骤使用 agent() + NotebookLM
- [ ] NotebookLM 降级路径存在
- [ ] ROADMAP.md 已更新
- [ ] 无残留 research-engine 引用

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | research-engine 已删 | post-impl-verifiable | `test ! -f .claude/workflows/research-engine.workflow.js && echo DELETED` | DELETED | (post-impl) |
| AC2 | pack-upgrade 不再调 workflow('research-engine') | post-impl-verifiable | `grep -c "workflow('research-engine'" .claude/workflows/pack-upgrade.workflow.js` | 0 | (post-impl) |
| AC3 | pack-upgrade 改用 agent() | post-impl-verifiable | `grep -c 'agent(' .claude/workflows/pack-upgrade.workflow.js` | ≥ 原有数量 +1（新研究 agent） | (post-impl) |
| AC4 | NotebookLM 在 agent prompt 中 | post-impl-verifiable | `grep -c 'notebooklm\|NotebookLM' .claude/workflows/pack-upgrade.workflow.js` | ≥2 | (post-impl) |
| AC5 | 降级路径存在 | post-impl-verifiable | `grep -c 'WebSearch\|fallback\|FAIL' .claude/workflows/pack-upgrade.workflow.js` | ≥1 (在研究 agent prompt 中) | (post-impl) |
| AC6 | RESEARCH_SCHEMA 定义 | post-impl-verifiable | `grep 'RESEARCH_SCHEMA' .claude/workflows/pack-upgrade.workflow.js` | ≥1 | (post-impl) |
| AC7 | ROADMAP 已更新 | post-impl-verifiable | `grep -i 'research.*consolidation\|研究.*整合' ROADMAP.md` | ≥1 | (post-impl) |
| AC8 | 无残留 research-engine 引用 | post-impl-verifiable | `grep -r 'research-engine' .claude/workflows/ .claude/skills/alex/ CLAUDE.md \| grep -v 'archive\|history\|evidence\|deleted\|已删'` | 0 matches | (post-impl) |
| AC9 | 旧常量已清理 | post-impl-verifiable | `grep -c 'RESEARCH_MAX_ROUNDS\|RESEARCH_SATURATION_K' .claude/workflows/pack-upgrade.workflow.js` | 0 | (post-impl) |

---

## 9.2 Expert Review Status

### Experts Selected

1. **code-reviewer** — workflow JS 修改质量 + schema 兼容性
2. **backend-architect** — NotebookLM 并发安全 + 降级路径

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0-1: 对抗验证丢失——假 claim 直通 Upgrade | §4.2 agent prompt — 添加 step 5 VERIFY (WebSearch fact-check) | Resolved |
| backend-architect | P0-2: report_path 移除破坏 plan prompt 文件读取 | §4.2 step 6 + §4.3 schema — agent 写报告到磁盘并返回 report_path | Resolved |
| code-reviewer | P0-1: researchOk 门控永远失败 | §4.3 schema — report_path 改为 required 字段 | Resolved |
| code-reviewer | P0-2: plan prompt 引用不存在的报告文件 | §4.2 step 6 — agent 写报告文件，path 保持兼容 | Resolved |
| backend-architect | P1-1: 并发 notebook 创建不写 REGISTRY 导致重复 | §4.2 step 2 note + §10.1 — agent 直接用 create 返回的 ID，不依赖 REGISTRY 发现 | Resolved |
| backend-architect | P1-2: CLI 在 subagent sandbox 可用性未验证 | §10.2 — 已知约束，降级路径覆盖 | Deferred |
| backend-architect | P1-3: researchMaxRounds 变量 + 成本注释未清理 | §6 Step 2 — 补充说明 | Resolved |
| code-reviewer | P1-1: SURPLUS-PLAN 等引用未覆盖 | §6 Step 4 — 扩大清理范围 | Resolved |
| code-reviewer | P1-2: agent prompt shell 注入风险 | §10.2 — packName 来自硬编码 DEFAULT_PACKS，低风险 | Deferred |
| code-reviewer | P2-1/P2-2: meta.description + phases 仍提 research-engine | §6 Step 2 — 补充 meta 更新指令 | Resolved |

### Overall Assessment (post-integration)

- **backend-architect**: CONDITIONAL PASS → PASS (2 P0 resolved, 2 P1 resolved, 1 deferred)
- **code-reviewer**: PASS (2 P0 resolved, 2 P1 resolved, 1 deferred)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 删 research-engine 后，skill 列表中的 `research-engine` 条目自动消失（workflow 自动发现）
- ⚠️ pack-upgrade agent 的 NotebookLM 调用是 fire-and-forget（不更新 REGISTRY.yaml），因为 workflow subagent 可能无权写 REGISTRY。notebook 创建后用户需手动 `*research-notebook sync` 补 REGISTRY
- ⚠️ *sync 到 14 个项目延迟到下次 *publish

### 10.2 Known Constraints
- workflow subagent 能调 Bash 但可能受 sandbox 限制——如果 notebooklm CLI 在 subagent 中不可用，降级路径会自动触发
- 迁移后 pack-upgrade 的研究结果没有 `report_path`（不再生成独立报告文件）——findings 直接传给 plan agent

---

## 11. Decision Rationale

### 11.1 为什么用 agent() 内联而不是保留 research-engine

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| agent() 内联 NotebookLM（选中）| 与 *research 统一、研究结果持久化、减少 workflow 文件 | 需要改 pack-upgrade 代码 | ✅ 用户选择 |
| 保留 research-engine 改名 | 改动最小 | 维护两套研究系统 | 违背整合目标 |
| agent() 内联 WebSearch | 简单、无 NotebookLM 依赖 | 放弃迁移目标 | 用户否决 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-17
**Version**: 3.1.0
