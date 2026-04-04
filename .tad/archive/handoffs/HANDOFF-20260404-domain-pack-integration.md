---
task_type: mixed
e2e_required: no
research_required: no
---

# Mini-Handoff: Domain Pack Workflow Integration (2-Point Injection)

**From:** Alex | **To:** Blake | **Date:** 2026-04-04
**Type:** Express Feature (protocol enhancement)
**Priority:** P1
**Task ID:** TASK-20260404-017

## Problem

Domain Pack 是 TAD 的重要资产（20 个 pack，78 个工具），但目前只在 session start 时被动注入到 additionalContext。Alex 的 *design 和 handoff 创建流程中没有任何强制步骤去加载和使用这些 pack。结果是：Domain Pack 存在但不发挥作用。

## Fix: 2-Point Injection

### Point 1: Alex *design 阶段 — Domain Pack Loading

**File:** `.claude/commands/tad-alex.md`

**位置:** `design_protocol` → `steps:` 节，在 step1 和 step2 之间插入新 step1_5。
**⚠️ 注意:** tad-alex.md 中已有一个 `step1_5` 在 `intent_router_protocol` → `execution:` 下（Idle Detection）。这是不同的 YAML scope。Blake 插入时必须定位到 `design_protocol:` 下的 `steps:` 节，NOT intent_router。
**定位方法:** Grep `"Review Socratic Inquiry Results"` 找到 design_protocol 的 step1，在其后插入。

在 step1 之后、step2 之前插入：

```yaml
    step1_5:
      name: "Domain Pack Loading"
      action: |
        Based on Socratic Inquiry results, identify relevant Domain Packs:

        1. Extract task keywords: technologies, product type, domains involved
           (e.g., "React frontend" → web-frontend, "REST API" → web-backend,
            "AI agent" → ai-agent-architecture, "dependency audit" → supply-chain-security)

        2. Match keywords against Domain Pack capabilities from session start context.
           Session start injects all pack names + capabilities into additionalContext.
           Use this list for matching — do NOT scan .tad/domains/ directory manually.

        3. Confirm with user via AskUserQuestion:
           "Based on requirements, I identified these relevant Domain Packs:
            - {pack1}: {matched capabilities}
            - {pack2}: {matched capabilities}
            Confirm, adjust, or skip?"
           Options:
           - "Confirmed" → proceed to step 4
           - "Add/remove packs" → user specifies, then proceed
           - "Skip Domain Packs" → proceed to step2 without pack loading

        State persistence: After loading, record matched packs in conversation as:
        "🔧 Loaded Domain Packs: {pack1}, {pack2}"
        step1a will check for this marker to know which packs to inject into handoff.

        4. For each confirmed pack, Read the YAML file:
           `.tad/domains/{pack-name}.yaml`
           Extract and note:
           - capabilities (names + step sequences)
           - quality_criteria (per capability)
           - anti_patterns (per capability)
           - review persona + checklist

        5. Use loaded pack content in subsequent *design steps:
           - Reference capabilities when designing architecture (step3)
           - Reference quality_criteria when defining acceptance standards
           - Reference anti_patterns when identifying risks
           - Output: "Loaded Domain Packs: {list}" as confirmation line

      note: |
        This step is INFORMING design, not CONSTRAINING it.
        Alex uses pack content as expert reference, not as rigid template.
        If the pack's recommended approach conflicts with user's specific needs,
        user's needs take priority.

      skip_conditions:
        - "User chose 'Skip Domain Packs' in step1_5 confirmation above"
        - "No matching Domain Pack found (e.g., novel domain not covered)"
        - "Light TAD process depth (keep lightweight)"
```

Also update step2 (Frontend Detection) to be aware of pack loading — 在现有 step2 的 action 开头追加一行:

```
If any relevant Domain Pack was loaded in step1_5, reference its capabilities
in design suggestions (e.g., web-frontend pack for component patterns,
web-backend pack for API conventions, ai-agent-architecture for agent design).
```

### Point 2: Handoff step1 — Auto-inject Pack Content

**File:** `.claude/commands/tad-alex.md`

**位置:** `handoff_creation_protocol` → `step1` → `content:` 列表。

**修改 2a:** 在 step1 的 `content:` 列表末尾追加一项:

找到：
```yaml
        - "YAML frontmatter (MANDATORY — task_type, e2e_required, research_required must be filled)"
```

在其后追加：
```yaml
        - "Domain Pack References (if packs loaded in *design step1_5)"
```

**修改 2b:** 在 step1 之后、step1b (Frontmatter Validation) 之前，插入新的 step1a:

```yaml
    step1a:
      name: "Domain Pack Injection"
      action: |
        If Domain Packs were loaded during *design step1_5:

        1. Add a new section to the handoff draft after "📚 Project Knowledge":

           ## 🔧 Domain Pack References (Blake 必读)

           **Loaded Packs:**
           | Pack | File | Matched Capabilities |
           |------|------|---------------------|
           | {pack1} | .tad/domains/{pack1}.yaml | {cap1, cap2} |
           | {pack2} | .tad/domains/{pack2}.yaml | {cap3, cap4} |

           **⚠️ Blake 必须在开始实现前 Read 上述 YAML 文件。**
           Pack 内容包含：工作流步骤、工具推荐、质量标准、反模式。

        2. Merge pack quality_criteria into "## 9. Acceptance Criteria":
           For each matched capability's quality_criteria:
           - Append as supplementary AC items
           - Tag each with source: `[from: {pack-name} → {capability}]`
           - These are ADVISORY, not mandatory — Blake uses judgment on applicability

           Example:
           ```
           - [ ] AC11: [from: web-frontend → component_development] Component has error boundary
           - [ ] AC12: [from: web-backend → api_design] API follows RESTful naming conventions
           ```

        3. Merge pack anti_patterns into "## 10. Important Notes":
           Append under a sub-heading:
           ```
           ### 10.4 Domain Pack Anti-Patterns
           - ⚠️ [web-frontend] Don't use inline styles for layout — use design tokens
           - ⚠️ [web-backend] Don't expose internal IDs in API responses
           ```

        4. Merge pack tool recommendations into "## 10.3 Sub-Agent 使用建议":
           If pack has tool_ref that maps to CLI tools, suggest Blake use them.

        If no Domain Packs were loaded: skip this step entirely.
      skip_conditions:
        - "No Domain Packs loaded during *design"
        - "Light TAD (skip for lightweight process)"
```

---

## Affected Files

| File | Section | Change |
|------|---------|--------|
| `.claude/commands/tad-alex.md` | design_protocol | Insert step1_5 (Domain Pack Loading) |
| `.claude/commands/tad-alex.md` | design_protocol step2 | Add pack-awareness line |
| `.claude/commands/tad-alex.md` | handoff_creation_protocol step1 content | Add "Domain Pack References" item |
| `.claude/commands/tad-alex.md` | handoff_creation_protocol | Insert step1a (Domain Pack Injection) |

**1 个文件，4 处修改。**

**Deferred scope (not in this handoff):**
- Handoff template (`.tad/templates/handoff-a-to-b.md`): Add "Domain Pack References" placeholder section — deferred to next template update
- Blake protocol (`tad-blake.md`): No change needed — Blake reads handoff sections as-is, "Blake 必读" in section title is sufficient
- Gate 3: Advisory AC items tagged `[from: pack]` are not blocking — spec-compliance reviewer already handles advisory vs mandatory by checking `[ ]` checkbox state

## Acceptance Criteria

- [ ] AC1: design_protocol 有 step1_5 (Domain Pack Loading)，含 AskUserQuestion 确认
- [ ] AC2: step1_5 有 skip_conditions（Light TAD / 无匹配 / 用户跳过）
- [ ] AC3: handoff_creation_protocol 有 step1a (Domain Pack Injection)
- [ ] AC4: step1a 注入 quality_criteria 标注来源 `[from: pack → capability]`
- [ ] AC5: step1a 注入 anti_patterns 到 Important Notes
- [ ] AC6: step1a 有 skip_conditions（无 pack 时跳过）
- [ ] AC7: step2 有 pack-awareness 行
- [ ] AC8: 现有 design_protocol 和 handoff_creation_protocol 的其他步骤不受影响

## Blake Instructions

- 只改 `tad-alex.md` 一个文件
- 4 处修改都是**插入**，不是替换现有内容
- step1_5 插入在 step1 和 step2 之间
- step1a 插入在 step1 和 step1b 之间
- 注意 YAML 缩进一致性（step1_5 与 step1/step2 同级）
- 用 Grep 定位准确位置，不要依赖 line numbers

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-04
**Version**: 3.1.0
