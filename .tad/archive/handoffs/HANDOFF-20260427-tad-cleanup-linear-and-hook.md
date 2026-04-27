---
task_type: mixed       # SKILL.md protocol edits + YAML config delete + shell hook redesign + deprecation entry
e2e_required: no
research_required: no
git_tracked_dirs: []   # framework files only, no production app code
skip_knowledge_assessment: no
gate4_delta:
  - field: "Handoff scope file count estimation"
    alex_said: "v1 draft: 4 files (Linear cut + accept slim + hook passive)"
    actual: "v2 post-Alex-review: 7 files (BA P0-1 +3: config.yaml / handoff template / post-write-sync.sh). Post-impl Blake Layer 2: 10 files truly needed (3 more dangling refs of removed additionalContext in run-phase2b-tests.sh + AC-P1.4-router-event-filter.sh + release-runbook SKILL.md). Estimation was 250%+ off from final reality."
    caught_by: "Alex Gate 2 review caught 4→7; Blake post-impl backend-architect Layer 2 caught 7→10 (3 dangling consumers)"
  - field: "AC4 / Linear blast radius coverage scope"
    alex_said: "5 active code/config/template files grep -i linear should be empty after delete"
    actual: "Pre-handoff backend-architect grep'd primary Linear mentions (config / SKILL / template) but NOT downstream consumers of removed mechanism (additionalContext). 3 files still consume the deleted injection: phase2b test runner / phase1 acceptance test / release-runbook smoke test. Post-impl Layer 2 backend-architect found these by fresh grep on additionalContext consumers."
    caught_by: "Blake post-impl backend-architect Layer 2 review (vs Alex pre-handoff backend-architect)"
---

# Handoff: TAD Bloat Cleanup — Linear Integration + *accept Slim + Domain Pack Hook Passive Mode

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-27 (v2 — post 2-expert review, blast radius expanded from 4 to 7 files)
**Project:** TAD Framework
**Task ID:** TASK-20260427-001
**Handoff Version:** 3.1.0
**Epic:** N/A (Standalone simplification handoff; closes Phase 6 of EPIC-20260424 by replacing 5 deferred sub-handoffs with this single one — see §11 Decision Summary)
**Supersedes:** N/A

<!-- Note: previously this handoff carried a `**Linear:** N/A` field per template line 39. Removed because this handoff itself deletes Linear integration AND deletes that template field. -->

⚠️ **v2 changes vs v1 (2026-04-27 expert review integration)**:
- File scope expanded from 4 → 7 files (BA-P0-1 blast radius — `.tad/config.yaml` + `.tad/templates/handoff-a-to-b.md` + `.tad/hooks/post-write-sync.sh`)
- Phase 2 (config-platform.yaml) prepended with YAML dedent step (CR-P0-1 + BA-P0-2 — `important_notes` structurally nested under `linear_integration`, must dedent before delete)
- Phase 3 hook regression test rewritten (BA-P0-5 — original `claude -p --system-prompt MARKER` was brittle due to "Domain Pack" string in test prompt + claude -p injecting 19k tokens of CLAUDE.md/skill catalog)
- AC4 replaced with explicit-list verifiable form (BA-P0-3 — soft "unless reasonable references" escape clause = gray-zone trap pattern documented in arch.md 2026-04-25)
- AC13 file count updated 4 → 7 + `.router.log` exclusion note (BA-P0-4)
- Line count arithmetic corrected (CR-P1-1/3/4 — actual SKILL.md removal ~84 lines, not 110)

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-04-27

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 文件级修改全部明确，无遗漏组件 |
| Components Specified | ✅ | 每个文件的删除/修改区域指明行号或函数名 |
| Functions Verified | ✅ | 涉及的所有 SKILL.md step / shell 函数都已 Read 验证存在 |
| Data Flow Mapped | ✅ | Hook 数据流：原 = 输入 → 评分 → 注入 + log；新 = 输入 → 评分 → log（去掉注入） |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 已通过 step1c grounding pass 验证所有目标文件实际状态；2 专家并行审查见 §9.2 Audit Trail；Blake 可独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解 hook 改为 passive mode 的含义（不是禁用 hook，是去掉 additionalContext 注入）
- [ ] 理解 *accept 协议中 step0b 与 acceptance_protocol.step4b 的关系（重复检查，删一个）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回 Alex 要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

三件简化（cleanup）合并到一个 handoff，跨 **7 个文件**（v2 review 扩大 blast radius）：

1. **砍除 Linear 集成**——5 个文件涉及（v1 漏了 3 个）：
   - `.claude/skills/alex/SKILL.md` 中 STEP 3.7 + *accept_command.step4b_linear_sync 删除
   - `.tad/config-platform.yaml` 中 linear_integration 段删除（含 YAML 结构修复——见 #4 §4.2 File 2）
   - `.tad/config.yaml` 中 config_modules.config-platform.yaml 描述修正 + contains 列表移除 linear_integration
   - `.tad/templates/handoff-a-to-b.md` 第 39 行 `**Linear:**` 字段从模板删除（不再传播给新 handoff）
   - `.tad/hooks/post-write-sync.sh` 第 74 行 NEXT.md 写入提示中"Linear sync may be needed"删除
   - Linear MCP 连接保留（claude.ai 自带），不再有 TAD 自动调用
2. ***accept 协议瘦身**——`.claude/skills/alex/SKILL.md` 中 *accept_command.step0b_evidence_check 删除。step0b 是 acceptance_protocol.step4b 的**严格子集**（step4b 还检查 frontmatter e2e_required / research_required path），删除是安全合并。
3. **Domain Pack Hook 改 passive mode**——`.tad/hooks/userprompt-domain-router.sh` 删除 additionalContext 注入逻辑（lines 224-234），保留 keyword 评分 + log 写入。Agent 在 *discuss / *design 时通过 SessionStart 注入的 pack 目录 + LLM 语义判断自主决定是否加载 pack（恢复 2026-04-15 教训方向：装烟雾报警器，不装自动灭火系统）。

**保留（NFR4 历史不回溯）**：
- `.tad/config.yaml` 第 321-322 行 v2.6.0 changelog 提到 Linear——历史记录，保留
- 已归档 handoff/completion 中的 `**Linear:**` 引用——保留

### 1.2 Why We're Building It

**业务价值**：

- **Linear 集成砍除**：用户从未实际使用，每次 Alex 启动都跑 ~60s 同步流程（Read NEXT.md + parse + MCP queries + writebacks），是纯成本无收益。
- ***accept 瘦身**：当前 *accept 流程超过 15 步（含 acceptance_protocol verification），其中 step0b 与 step4b 重复。删除冗余 = *accept 更顺。
- **Hook passive mode**：当前 hook 强制注入"必须 Read pack"提示，因 keyword 分类不够精准导致频繁误触（本 session 启动即被 mobile-development 1/15 命中误触发）。改 passive 后 = agent 自主判断 + hook 仍记录 trace 用于将来分析。

**用户受益**：

- Alex 启动从 60s+ 降到 < 5s（无 Linear sync）
- *accept 流程少一步重复检查
- 减少 Domain Pack 误触 / 错误加载——agent 不再被强制提示"必须 Read"，自由度恢复

**成功的样子**：

- 新 session 启动时 Alex 不再尝试 Linear sync
- *accept 流程顺畅完成，无重复 evidence 检查
- 用户提示触发 hook 时只产生 log，agent context 不再被注入"⚠️ 检测到任务匹配 Domain Pack..."

### 1.3 Intent Statement

**真正要解决的问题**：TAD 框架已经过了"加功能"阶段进入"瘦身"阶段。当前框架内有 3 处明显冗余/反向价值（Linear 死功能、*accept 重复检查、hook 过度强制），合并清理。

**不是要做的**：

- ❌ 不是要做大重构（不动 Socratic / 2 专家审查 / Gate 1-4 / Layer 2 audit / trace-digest 这些 quality 防线）
- ❌ 不是要禁用 Domain Pack 机制（pack catalog 仍由 SessionStart 注入，agent 仍可主动 Read pack；只是 hook 不再"强制提示"）
- ❌ 不是要砍 hook 本身（保留 keyword 评分 + log 写入，将来需要复活强制注入或改用 trace 分析时基础设施在）
- ❌ 不是要砍 Linear MCP 连接（claude.ai Linear MCP 仍然可用，只是 TAD 不自动调用）

**Blake 请确认理解**：

```
在开始实现前，请用你自己的话回答：
1. 这三件事为什么打包到一个 handoff？（提示：都是"删除冗余 + 软化机制"的简化型工作，文件 4 个，*express ≤3 文件超出但用 Standard TAD 单 handoff 处理更简洁）
2. Hook 改 passive 后，agent 还知道有哪些 pack 吗？（提示：SessionStart 仍注入 pack 目录，不受影响）
3. Linear 集成砍除会不会影响下游已 sync 的项目？（提示：deprecation.yaml 加 2.8.4 条目，下游 *sync 时清理）
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

涉及类别：
- [x] architecture - hook 机制 / 强制 vs 监督的设计哲学
- [x] code-quality - shell 脚本编辑 + SKILL.md 协议编辑
- [ ] security
- [ ] ux
- [ ] performance - hook 性能（keep, 已有 single-awk 优化）
- [ ] testing - hook 回归测试
- [ ] api-integration - Linear MCP（要砍）

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 5 条 | 见下方"⚠️ Blake 必须注意的历史教训" |
| code-quality.md | 0 条 | 无相关记录 |
| performance.md | 0 条 | 无相关记录 |
| testing.md | 0 条 | 无相关记录 |

**⚠️ Blake 必须注意的历史教训**（来自 architecture.md 关键词扫描）：

1. **Mechanical Enforcement Rejected on Single-User CLI — 2026-04-15** (architecture.md)
   - 教训：Epic 1 取消的核心理由——单用户 CLI 上机械强制（fail-closed PreToolUse hook）的恢复成本超过防滥用收益
   - **本 handoff 的关联**：hook 改 passive mode **直接对齐**这条教训。从"强制注入"→"被动记录" = 从"自动灭火系统"→"烟雾报警器"。
   - 必须坚持的原则：保留 log 写入（监督层），但不阻塞、不强制。

2. **Hook Performance: Single-awk vs Per-item grep Loop — 2026-04-07** (architecture.md)
   - 教训：hook 性能优化的关键是 fork/exec 减少（用 1 个 awk 取代 N 次 grep）
   - **本 handoff 的关联**：现有 single-awk 评分逻辑保留不动，只删 lines 224-234 的 additionalContext 注入段。**不要顺手"优化"评分循环**——已经是优化过的。

3. **Domain Pack Keyword Curation: Uniqueness > Count — 2026-04-07** (architecture.md)
   - 教训：threshold 1 配 strict uniqueness 在 30-case 测试 100% 准确；real-world 用了几周后误触增加，说明 keyword uniqueness 不够维持
   - **本 handoff 的关联**：本次**不动 keywords.yaml**——passive mode 让误触不再产生用户可见后果（agent 不被注入"必须 Read"），keyword 分类问题的修复推迟到 hook 监督层数据积累后再说。

4. **Claude Code Native Mechanism Validation — Hooks > Skill Frontmatter — 2026-03-31** (architecture.md)
   - 教训：hook additionalContext 是 system-level 注入，权威性高于普通 prompt 提示
   - **本 handoff 的关联**：删除注入后，agent 不再受"system-level"压力，回归普通 LLM 判断。这是有意为之。

5. **`claude -p` is a Valid UserPromptSubmit Hook Testing Channel — 2026-04-07** (architecture.md)
   - 教训：`claude -p --no-session-persistence --tools '' --system-prompt <probe>` 是验证 hook 行为的有效通道
   - **本 handoff 的关联**：Blake 的回归测试 (§8) 用此模式验证 passive mode 不再注入 additionalContext。

### Blake 确认

- [ ] 我已阅读上述 5 条历史教训
- [ ] 我理解 hook 改 passive 是承接 2026-04-15 Epic 1 取消的方向，不是新方向
- [ ] 我不会顺手优化已经优化过的 single-awk 评分逻辑
- [ ] 我不会修改 keywords.yaml（除非 hook 改 passive 后用户明确再要求）

---

## 2. Background Context

### 2.1 Previous Work

- **Linear 集成历史**：2026-03-25 加入（commit 7583fe5），目的是给人类一个跨项目看板。实际使用 1 个月后用户判断"我现在一直都没用"。
- ***accept 协议历史**：step0b 是 git status check 之后的 evidence 完整性 safety net，但 acceptance_protocol step4b 已经做了同样的事（在 Gate 4 流程中）。重复来源是历史增量演化，从未有人统一。
- **Domain Pack hook 历史**：2026-04-07 EPIC-20260407 Phase 2b 上线（commit 历史中），threshold 1 + strict uniqueness 当时 30/30 PASS。real-world 几周后误触增加，原因是用户消息超出 30-case 模式 + 部分 pack 关键词污染。

### 2.2 Current State

- Alex 启动 STEP 3.7 全量 Linear sync 仍在执行，每次 ~30-60s
- *accept 仍跑 step0b（重复检查）
- Hook 仍注入 additionalContext "⚠️ 检测到任务匹配 Domain Pack..."（本 session 启动即被 mobile-development 误触）

### 2.3 Dependencies

- 不依赖外部库变更
- 不依赖 settings.json hook 注册改动（hook 注册保留，只改脚本行为）
- deprecation.yaml 需要加 2.8.4 条目让下游 *sync 时清理 Linear 相关文件（虽然 Linear 集成是配置层不是单独文件，但下游可能从注册表删除——见 §6 Phase 4）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: 删除 Alex SKILL.md 中 STEP 3.7 整段（startup full Linear sync）
- **FR2**: 删除 Alex SKILL.md 中 *accept_command.step4b_linear_sync 整段
- **FR3**: 删除 Alex SKILL.md 中 *accept_command.step0b_evidence_check 整段（被 acceptance_protocol.step4b 严格超集覆盖，删除合并）
- **FR4**: **YAML 结构修复 + 删除** `.tad/config-platform.yaml`：
  - **Step 1（必须先做）**：将 `important_notes:` map 从 2-space indent dedent 到 0-space indent（top-level）——它当前嵌套在 `linear_integration:` 下是历史结构 bug，内容是 MCP 工具通用提醒，与 Linear 无关
  - **Step 2**：删除 linear_integration 段（约 50 行，含 enabled / mcp_server / linking_strategy / timeout_seconds / sync_points / project_mapping / auto_sync / section_mapping）
- **FR5**: 修改 `.tad/hooks/userprompt-domain-router.sh`，删除 lines 224-234 的 hookSpecificOutput.additionalContext 注入逻辑；保留 keyword 评分 + log 写入
- **FR6**: 在 `.tad/deprecation.yaml` 中新增 "2.8.4" 条目（按 §4.2 File 4 格式）
- **FR7（v2 新增 BA-P0-1）**: 修改 `.tad/config.yaml`：
  - line 77：`description: "MCP tools integration and Linear kanban"` → `description: "MCP tools integration"`
  - line 80：`contains:` 列表移除 `- linear_integration`
  - **保留** lines 321-322（v2.6.0 changelog historical text — NFR4 不回溯）
- **FR8（v2 新增 BA-P0-1）**: 修改 `.tad/templates/handoff-a-to-b.md` line 39：删除 `**Linear:** N/A <!-- Optional: TAD-42 ... -->` 整行（不再向新 handoff 传播）
- **FR9（v2 新增 BA-P0-1）**: 修改 `.tad/hooks/post-write-sync.sh` line 74：把 `output_response "PostToolUse" "NEXT.md updated. Linear sync may be needed if items changed."` 改为 `output_response "PostToolUse" "NEXT.md updated."`

### 3.2 Non-Functional Requirements

- **NFR1 (Performance)**: Alex 启动时间从当前 ~30-60s（含 Linear sync）降到 < 10s
- **NFR2 (Reversibility)**: 所有删除可通过 git revert 恢复，不删除 Linear MCP 连接配置（claude.ai 层面）
- **NFR3 (Hook Privacy)**: passive mode 不破坏 hook 现有的"不记录 prompt 内容"隐私规则（log 行只记录 pack 名 + ratio + 时间戳）
- **NFR4 (Backward Compat)**: 已归档的旧 handoff 中保留 `**Linear:**` 字段引用——不需要回溯清理（字段就是 N/A 也不影响读取）

---

## 4. Technical Design

### 4.1 Architecture Overview

四个文件，每个独立，不互相依赖。可以串行编辑（建议顺序见 §6 Implementation Steps）。

### 4.2 Per-File Change Specification

#### File 1: `.claude/skills/alex/SKILL.md`

**位置**：3 处删除（v1 估算 ~110 行；CR-P1-1/3/4 修正：实际约 84 行 = 55 + 7 + 22）

**删除区域 A**（STEP 3.7，**约 55 行**——v1 写"约 80 行"是估算偏高）：
- 起始行：`  - STEP 3.7: Linear sync (startup full sync)`（line 90）
- 结束行：activation_protocol step3.7 整段结束（含 action / timeout / status_precedence / project_matching / blocking / suppress_if / on_failure 全部子字段）
- 删除后 STEP 4 紧接 STEP 3.6 的结束

**删除区域 B**（*accept_command step0b_evidence_check，**约 7 行**）：
- 起始行：`    step0b_evidence_check:`（line 2797）
- 结束行：`      blocking: true`（line 2803）
- 删除后 step1 紧接 step0_git_check 的 purpose 注释
- **删除安全性（BA 验证）**：step0b 是 acceptance_protocol.step4b 的**严格子集**——step4b 还检查 frontmatter `e2e_required` / `research_required` paths，覆盖 step0b 全部能力。删除安全。

**删除区域 C**（*accept_command step4b_linear_sync，**约 22 行**）：
- 起始行：`    step4b_linear_sync:`（line 2872）
- 结束行：`        Principle: Linear sync NEVER blocks *accept. All errors are warnings.`（约 line 2893）
- 删除后 step5 紧接 step4 的 details

#### File 2: `.tad/config-platform.yaml`

**位置**：YAML 结构修复 + 1 处删除（CR-P0-1 + BA-P0-2）

**⚠️ Step 2.1（必须先做）：将 `important_notes:` dedent 到 top level**

当前结构（约 line 277-284）：
```yaml
linear_integration:
  enabled: true
  ...
  auto_sync:
    ...
      "Recently Completed":
        status: "Done"
        priority: null  # Keep existing

  # 重要提醒
  important_notes:                              # ← 2-space indent (child of linear_integration)
    - "MCP 工具是 ENHANCEMENTS,不是 REQUIREMENTS"
    - ...
```

修复后（dedent 到 0-space indent，top-level，与 mcp_tools 平级）：
```yaml
# 重要提醒
important_notes:                                # ← 0-space indent (top-level sibling of mcp_tools/linear_integration)
  - "MCP 工具是 ENHANCEMENTS,不是 REQUIREMENTS"
  - "所有原有 TAD 工作流在没有 MCP 的情况下仍完全可用"
  - "MCP 工具失败时不应阻止进度"
  - "始终通知用户正在使用哪些 MCP 工具"
  - "MCP 故障应记录但不影响核心功能"
  - "filesystem 和 git 是 Blake 的必需 MCP,其他都是可选"
```

理由：内容是 MCP 工具通用提醒（"filesystem 和 git 是 Blake 的必需 MCP"），与 Linear 无关。当前 2-space indent 是历史结构 bug——加 Linear 时被错误嵌入到 linear_integration 下。Dedent 是修正，不是新设计。

**Step 2.2：删除 linear_integration 段**（约 50 行）：
- 起始行：`# ==================== Linear Integration ====================`（约 line 229）
- 结束行：linear_integration map 完整结束（最后一个子字段 `auto_sync.section_mapping."Recently Completed"`）
- **不要**误删 step 2.1 dedent 后的 important_notes 段

#### File 3: `.tad/hooks/userprompt-domain-router.sh`

**位置**：1 处删除（窄）

**删除区域**（additionalContext 注入逻辑，lines 224-234）：
```bash
# ─── Emit hookSpecificOutput if a match passed threshold ──────────────────
if [ -n "$BEST_PACK" ]; then
  # Human-readable reminder (Chinese — matches TAD convention)
  REMINDER="⚠️ 检测到任务匹配 Domain Pack [${BEST_PACK}]（命中 ${BEST_MATCHED}/${BEST_TOTAL} 关键词）。请 Read ${BEST_FILE} 加载对应 capability 和 quality_criteria 后再响应。"

  # Safe JSON emission via jq (no string escaping pitfalls)
  jq -nc \
    --arg ctx "$REMINDER" \
    '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \
    2>/dev/null || true
fi
```

**保留区域**（lines 235+ 全部保留）：
- log rotation
- 结构化 log 写入（pack 名 / ratio / elapsed_ms / msg_length）
- exit 0

**注意**：保留 BEST_PACK / BEST_MATCHED / BEST_TOTAL / BEST_FILE 变量赋值（lines 217-222），因为后续 log 行需要它们。

**结果**：hook 仍读 keywords、仍评分、仍 log，但**不再向 stdout 输出 hookSpecificOutput JSON**——agent 永远不会看到"⚠️ 检测到任务匹配..."提示。

#### File 4: `.tad/deprecation.yaml`

**位置**：1 处新增

**新增条目**：
```yaml
  "2.8.4":
    description: "Linear integration removed (cleanup). User judged Linear sync as unused functionality. Domain Pack router hook switched to passive mode."
    files: []  # No standalone files removed; changes are within existing files
    note: |
      Changes within existing files (no file deletion needed for *sync):
      - .claude/skills/alex/SKILL.md: STEP 3.7 + step4b_linear_sync + step0b_evidence_check removed
      - .tad/config-platform.yaml: linear_integration section removed, important_notes dedented to top-level
      - .tad/config.yaml: config_modules.config-platform description + contains updated
      - .tad/templates/handoff-a-to-b.md: **Linear:** field removed from header template
      - .tad/hooks/post-write-sync.sh: NEXT.md hint Linear reference removed
      - .tad/hooks/userprompt-domain-router.sh: additionalContext injection removed (passive mode)
      Downstream projects: just re-sync to get the updated files. Linear MCP connection (claude.ai) remains usable manually.
    date: "2026-04-27"
```

#### File 5: `.tad/config.yaml` (v2 新增 BA-P0-1)

**位置**：2 处编辑

**编辑 1**（line 77）：
- `    description: "MCP tools integration and Linear kanban"`
- → `    description: "MCP tools integration"`

**编辑 2**（line 80）：
- `      - linear_integration` 整行删除（保留 `- mcp_tools`）

**保留**：lines 321-322（v2.6.0 changelog 提到 Linear——历史记录，NFR4 不回溯）

#### File 6: `.tad/templates/handoff-a-to-b.md` (v2 新增 BA-P0-1)

**位置**：1 处删除

**删除 line 39 整行**：
```
**Linear:** N/A <!-- Optional: TAD-42 or MENU-15 — links to Linear issue for auto-sync on *accept -->
```

删除后 `**Epic:**` 行紧接 `**Supersedes:**` 行（无空行夹层）。

#### File 7: `.tad/hooks/post-write-sync.sh` (v2 新增 BA-P0-1)

**位置**：1 处文本修改（line 74）

修改前：
```bash
  */NEXT.md|NEXT.md)
    output_response "PostToolUse" "NEXT.md updated. Linear sync may be needed if items changed."
    ;;
```

修改后：
```bash
  */NEXT.md|NEXT.md)
    output_response "PostToolUse" "NEXT.md updated."
    ;;
```

#### File 3: `.tad/hooks/userprompt-domain-router.sh`

**位置**：1 处删除（窄）

**删除区域**（additionalContext 注入逻辑，lines 224-234）：
```bash
# ─── Emit hookSpecificOutput if a match passed threshold ──────────────────
if [ -n "$BEST_PACK" ]; then
  # Human-readable reminder (Chinese — matches TAD convention)
  REMINDER="⚠️ 检测到任务匹配 Domain Pack [${BEST_PACK}]（命中 ${BEST_MATCHED}/${BEST_TOTAL} 关键词）。请 Read ${BEST_FILE} 加载对应 capability 和 quality_criteria 后再响应。"

  # Safe JSON emission via jq (no string escaping pitfalls)
  jq -nc \
    --arg ctx "$REMINDER" \
    '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \
    2>/dev/null || true
fi
```

**保留区域**（lines 235+ 全部保留）：
- log rotation
- 结构化 log 写入（pack 名 / ratio / elapsed_ms / msg_length）
- exit 0

**注意**：保留 BEST_PACK / BEST_MATCHED / BEST_TOTAL / BEST_FILE 变量赋值（lines 217-222），因为后续 log 行需要它们。

**结果**：hook 仍读 keywords、仍评分、仍 log，但**不再向 stdout 输出 hookSpecificOutput JSON**——agent 永远不会看到"⚠️ 检测到任务匹配..."提示。

#### File 4: `.tad/deprecation.yaml`

**位置**：1 处新增

**新增条目**：
```yaml
  "2.8.4":
    description: "Linear integration removed (cleanup). User judged Linear sync as unused functionality. Domain Pack router hook switched to passive mode."
    files: []  # No standalone files removed; changes are within existing files
    note: |
      Changes within existing files (no file deletion needed for *sync):
      - .claude/skills/alex/SKILL.md: STEP 3.7 + step4b_linear_sync + step0b_evidence_check removed
      - .tad/config-platform.yaml: linear_integration section removed
      - .tad/hooks/userprompt-domain-router.sh: additionalContext injection removed (passive mode)
      Downstream projects: just re-sync to get the updated files. Linear MCP connection (claude.ai) remains usable manually.
    date: "2026-04-27"
```

### 4.3 Data Flow (Hook before vs after)

**Before**:
```
User prompt → SessionStart pack catalog injected (preserved)
            → UserPromptSubmit hook fires
              → Read keywords.yaml → score → BEST_PACK
              → IF threshold met:
                 → Emit hookSpecificOutput.additionalContext "⚠️ 必须 Read pack..."
                 → ★ Agent context gets system-level prompt
              → Log to .router.log
              → Exit 0
            → Agent processes prompt + injected hint
```

**After (passive mode)**:
```
User prompt → SessionStart pack catalog injected (preserved)
            → UserPromptSubmit hook fires
              → Read keywords.yaml → score → BEST_PACK
              → IF threshold met:
                 → ★ NO injection
              → Log to .router.log (preserved — for future trace analysis)
              → Exit 0
            → Agent processes prompt without hint
              → If task matches a pack, agent decides via *discuss step1.5/domain_pack_awareness or *design step1_5 自主 Read
```

### 4.4 Component Specifications

无新组件。全部是现有组件的删除/瘦身。

### 4.5 API/UI Specifications

不涉及 API 或 UI 改动。

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：✅ 是

**证据**：用户提到 "之前我们设置的比较强" + "之前因为他不会主动去加载 Domain Pack，所以我们就相当于是给他强制让他要加载"——指 EPIC-20260407 Phase 2b（Domain Pack 可靠加载机制）。

**搜索证据**：
```bash
grep -n "additionalContext" .tad/hooks/userprompt-domain-router.sh
# 232:    '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \

grep -n "STEP 3.7\|step4b_linear_sync\|step0b_evidence_check" .claude/skills/alex/SKILL.md | head
# 90:  - STEP 3.7: Linear sync (startup full sync)
# 2797:    step0b_evidence_check:
# 2872:    step4b_linear_sync:
```

**决策说明**：复用现有 hook + SKILL 结构，删除而非重构。Hook 评分逻辑（single-awk）已经过 Phase 2b 性能优化，不动。

### MQ2: 函数存在性验证

**问题**：设计中调用了哪些函数 / 引用了哪些 step？它们都存在吗？

**回答**：

| 引用 | 文件位置 | 行号 | 验证状态 |
|------|---------|------|---------|
| STEP 3.7 (Alex activation step) | .claude/skills/alex/SKILL.md | 90+ | ✅ 存在（grep 已确认）|
| step0b_evidence_check | .claude/skills/alex/SKILL.md | 2797-2803 | ✅ 存在 |
| step4b_linear_sync | .claude/skills/alex/SKILL.md | 2872-2893 | ✅ 存在 |
| linear_integration section | .tad/config-platform.yaml | ~229+ | ✅ 存在 |
| hookSpecificOutput emission block | .tad/hooks/userprompt-domain-router.sh | 224-234 | ✅ 存在 |
| BEST_PACK 变量赋值（要保留）| .tad/hooks/userprompt-domain-router.sh | 217-222 | ✅ 存在 |
| acceptance_protocol.step4b（重复检查的"原版"，要保留）| .claude/skills/alex/SKILL.md | (acceptance_protocol section) | ✅ 存在（已在 *accept 流程使用）|

### MQ3: 数据流完整性

✅ 见 §4.3 Data Flow (before vs after)

### MQ4: 视觉层级

N/A — 不涉及 UI 状态变化。

### MQ5: 状态同步

**问题**：数据存在几个地方？同步时机？

**回答**：

| 数据 | 存储位置 | 同步时机 | 备注 |
|------|---------|---------|------|
| Pack catalog (要保留) | SessionStart hook → agent context | 每次 session 启动 | passive mode 不影响 |
| Pack 评分结果（要保留）| .tad/hooks/.router.log | 每次 user prompt | passive mode 仍写入 |
| Pack injection（要删除）| stdout JSON → agent context | 每次 user prompt | **删除——这就是本次改动核心** |
| Linear issue 状态（要删除全部）| Linear server / NEXT.md tags / handoff frontmatter | 多处 | **删除全部 TAD 自动同步逻辑；Linear server 数据保留** |

✅ 删除后：Pack 信息有 catalog（agent 知道有哪些 pack）+ log（trace 用），不再有 injection。Linear 信息保留在 Linear server，TAD 不再触碰。

---

## 6. Implementation Steps

### Phase 1: SKILL.md 三处删除（预计 30 分钟）

#### 交付物
- [ ] STEP 3.7 Linear sync 整段删除
- [ ] *accept_command.step0b_evidence_check 删除
- [ ] *accept_command.step4b_linear_sync 删除

#### 实施步骤

1. 备份当前 SKILL.md（`.tad/active/handoffs/.skill-md-backup-20260427.bak`，commit 时不入库，仅本地保险）
2. 用 Edit tool 删除区域 A (STEP 3.7) — ~55 行
3. 用 Edit tool 删除区域 B (step0b_evidence_check) — ~7 行
4. 用 Edit tool 删除区域 C (step4b_linear_sync) — ~22 行
5. `wc -l .claude/skills/alex/SKILL.md` 应减少 ~80-90 行（actual 84 行 per CR-P1-1 verified arithmetic）
6. `grep -c "STEP 3.7\|step0b_evidence_check\|step4b_linear_sync" .claude/skills/alex/SKILL.md` → 应返回 0

#### 验证
- 不能破坏文件 YAML 缩进结构（SKILL.md 含大段嵌入式 YAML）
- Phase 1 后还不能继续，需先运行一次 hook 确保 SKILL 仍可加载（虽然 hook 不直接读 SKILL，但下个 /alex session 加载时会过 grep 等检查）

### Phase 2: config-platform.yaml YAML 修复 + linear_integration 删除（预计 15 分钟）

#### 交付物
- [ ] `important_notes:` map dedent 到 top-level（YAML 结构修复）
- [ ] linear_integration 段完整删除
- [ ] dedent 后的 important_notes 段保留并 YAML 验证 PASS

#### 实施步骤

⚠️ **关键顺序：先 dedent，再 delete。颠倒顺序会破坏 YAML 结构。**

1. Read .tad/config-platform.yaml 全文，定位 `important_notes:` map（约 line 277-284，2-space indent under linear_integration）
2. **Step 2.1：dedent important_notes 到 top-level（0-space indent）**：
   - 找到 `# 重要提醒` 注释 + `important_notes:` 行
   - 把 `# 重要提醒` 注释和 `important_notes:` map 整体（含所有 list items）从当前位置剪切，放到 linear_integration 段**之前**（紧接 mcp_tools 段结束之后）
   - 修改缩进：所有行从 2-space dedent 到 0-space（即 `  important_notes:` → `important_notes:`，map items 从 4-space → 2-space）
3. **Step 2.2：定位 `# ==================== Linear Integration ====================` 注释**
4. 删除该注释块到 linear_integration 段最后一个子字段（auto_sync.section_mapping."Recently Completed"）的所有内容
5. **YAML 语法验证**：`python3 -c "import yaml, sys; d = yaml.safe_load(open('.tad/config-platform.yaml')); assert 'important_notes' in d and isinstance(d['important_notes'], list) and len(d['important_notes']) >= 6, 'important_notes structure broken'; print('YAML OK, important_notes has', len(d['important_notes']), 'items')"`
   - **预期 stdout**: `YAML OK, important_notes has 6 items`
6. `grep -c "linear_integration" .tad/config-platform.yaml` → 应返回 0
7. `wc -l .tad/config-platform.yaml` 应减少 ~50 行（净删除）

### Phase 3: Hook passive mode（预计 20 分钟）

#### 交付物
- [ ] userprompt-domain-router.sh lines 224-234 的 additionalContext 注入块删除
- [ ] BEST_PACK 等变量赋值保留（lines 217-222）
- [ ] log 写入逻辑保留（lines 235+）
- [ ] 回归测试通过：hook 仍 log 但不注入

#### 实施步骤
1. Read .tad/hooks/userprompt-domain-router.sh 完整内容
2. Edit 删除 lines 224-234（11 行）
3. 保留所有变量赋值 + log 逻辑
4. `bash -n .tad/hooks/userprompt-domain-router.sh` → 语法检查 PASS
5. **回归测试（直接 hook 测试，BA-P0-5 修订）**：

   ⚠️ **不要用** `claude -p --system-prompt MARKER` 探针（v1 设计已废弃）。原因：(a) 测试 prompt 含 "Domain Pack" 字面，(b) `claude -p` 注入 ~19k tokens 的 CLAUDE.md/skill catalog 也提到 Domain Pack——两个干扰源都会让 MARKER 探针 false-FAIL。

   **改用直接 hook stdin/stdout 测试**：
   ```bash
   # Test 1: hook with no match → empty stdout, log written
   echo '{"prompt":"hello world unrelated text", "session_id":"test", "transcript_path":"/tmp/x", "cwd":"'$(pwd)'", "permission_mode":"default", "hook_event_name":"UserPromptSubmit"}' \
     | bash .tad/hooks/userprompt-domain-router.sh > /tmp/hook-out-1.txt 2> /tmp/hook-err-1.txt
   echo "Test 1 stdout bytes: $(wc -c < /tmp/hook-out-1.txt)"  # 预期: 0
   tail -1 .tad/hooks/.router.log  # 预期: 包含 "none" 和 "0/0"

   # Test 2: hook with match → STILL empty stdout (passive mode), log written with pack name
   echo '{"prompt":"react native expo mobile platform_features", "session_id":"test", "transcript_path":"/tmp/x", "cwd":"'$(pwd)'", "permission_mode":"default", "hook_event_name":"UserPromptSubmit"}' \
     | bash .tad/hooks/userprompt-domain-router.sh > /tmp/hook-out-2.txt 2> /tmp/hook-err-2.txt
   echo "Test 2 stdout bytes: $(wc -c < /tmp/hook-out-2.txt)"  # 预期: 0 (passive — 关键证据)
   tail -1 .tad/hooks/.router.log  # 预期: 包含 mobile-development 或 web-frontend pack 名 + N/M ratio (>0/N)
   ```
   - **关键判定 (AC10)**：Test 2 stdout 字节数 = 0 + log 行有 pack 名 → passive mode 工作正确
6. `git diff .tad/hooks/userprompt-domain-router.sh` 应只显示 lines 224-234 的删除，不动其他代码

### Phase 4: deprecation.yaml 新增 2.8.4 条目（预计 5 分钟）

#### 交付物
- [ ] 2.8.4 条目按 §4.2 File 4 格式追加

#### 实施步骤
1. Read .tad/deprecation.yaml
2. 在 2.8.2 条目下方追加 2.8.4 条目（按 §4.2 File 4 内容）
3. YAML 语法检查：`python3 -c "import yaml; yaml.safe_load(open('.tad/deprecation.yaml'))"` → 不报错

### Phase 5: config.yaml + handoff template + post-write-sync.sh（v2 新增，预计 10 分钟）

#### 交付物
- [ ] `.tad/config.yaml` line 77 description 修改（去掉 "and Linear kanban"）
- [ ] `.tad/config.yaml` line 80 区域删除 `- linear_integration`
- [ ] `.tad/templates/handoff-a-to-b.md` line 39 删除整行
- [ ] `.tad/hooks/post-write-sync.sh` line 74 修改文案

#### 实施步骤
1. `.tad/config.yaml`:
   - Edit line 77: `"MCP tools integration and Linear kanban"` → `"MCP tools integration"`
   - Edit line 80 area: 删除 `      - linear_integration` 整行
   - YAML 验证：`python3 -c "import yaml; yaml.safe_load(open('.tad/config.yaml'))"` 不报错
2. `.tad/templates/handoff-a-to-b.md`:
   - Edit line 39: 删除 `**Linear:** N/A <!-- Optional: TAD-42 ... -->` 整行
   - 验证：`grep -c "Linear" .tad/templates/handoff-a-to-b.md` 应返回 0（v2.6.0 changelog 不在此文件，不影响）
3. `.tad/hooks/post-write-sync.sh`:
   - Edit line 74: `"NEXT.md updated. Linear sync may be needed if items changed."` → `"NEXT.md updated."`
   - 验证：`bash -n .tad/hooks/post-write-sync.sh` exit 0
   - 验证：`grep -c "Linear" .tad/hooks/post-write-sync.sh` 应返回 0

### Phase 6: 集成回归 + commit（预计 15 分钟）

#### 交付物
- [ ] 7 个文件改动 stage
- [ ] commit message 体现"cleanup: linear cut + accept slim + hook passive"
- [ ] git log 验证 commit 干净

#### 实施步骤
1. `git status` 应显示 7 个 modified files（无 untracked / 无误删）：
   - `.claude/skills/alex/SKILL.md`
   - `.tad/config-platform.yaml`
   - `.tad/config.yaml`
   - `.tad/templates/handoff-a-to-b.md`
   - `.tad/hooks/userprompt-domain-router.sh`
   - `.tad/hooks/post-write-sync.sh`
   - `.tad/deprecation.yaml`
2. `git diff --stat` 复核行数变化（参考 §9 AC13）
3. **Run Layer 1 self-check** (Blake Gate 3 v2 standard)
4. **Run Layer 2 expert review** (≥2 distinct sub-agents per P6-A hard rule)：
   - **必选**: code-reviewer（shell + SKILL.md + YAML 编辑正确性）
   - **第二个必选**: backend-architect（hook 契约变化 + 7 文件 blast radius 完整性）
5. Commit message（**用 heredoc 格式 per CLAUDE.md** — CR-P2-1 提醒）:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat(TAD): bloat cleanup — Linear cut + *accept slim + hook passive mode

   - Remove Linear integration across 5 files (Alex STEP 3.7 + *accept step4b_linear_sync + config-platform linear_integration + config.yaml description/contains + handoff template Linear field + post-write-sync hint)
   - Fix YAML structural bug: dedent important_notes to top-level in config-platform.yaml (was incorrectly nested under linear_integration)
   - Remove duplicate evidence check (*accept step0b_evidence_check — strict subset of acceptance_protocol step4b)
   - Domain Pack router hook switched to passive mode (no additionalContext injection; keyword scoring + log preserved)
   - deprecation.yaml 2.8.4 entry for downstream sync awareness

   Closes Phase 6 of EPIC-20260424 by replacing 5 deferred sub-handoffs with this single simplification.
   Aligns with 2026-04-15 mechanical enforcement rejection (smoke alarm > auto-extinguisher).

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

---

## 7. File Structure

### 7.1 Files to Create
```
(none — handoff is pure deletion + 1 deprecation entry append)
```

### 7.2 Files to Modify (v2 — 7 files total, +3 from v1)
```
.claude/skills/alex/SKILL.md                 # 3 删除区域（~84 行 net per CR-P1-1）
.tad/config-platform.yaml                    # YAML 结构修复 + linear_integration 删除（~50 行 net）
.tad/config.yaml                             # 2 处编辑（line 77 description + line 80 contains）
.tad/templates/handoff-a-to-b.md             # line 39 删除（1 行）
.tad/hooks/userprompt-domain-router.sh       # 1 删除区域（11 行）
.tad/hooks/post-write-sync.sh                # line 74 文案修改（1 行）
.tad/deprecation.yaml                        # 1 追加（~14 行）
```

### 7.3 Grounded Against (Phase 2 P2.2 — Alex step1c, 2026-04-27)

**Grounded Against** (Alex step1c 实际 Read 过的源文件):

- `.claude/skills/alex/SKILL.md` (head 50 + lines 85-130 + lines 2790-2900, read at 2026-04-27 by Alex)
- `.tad/config-platform.yaml` (full file, read at 2026-04-27 by Alex via earlier context dump; v2 re-verified important_notes structural nesting at lines 277-284)
- `.tad/config.yaml` (lines 75-85 + 320-323 verified by grep, read at 2026-04-27 v2 by Alex)
- `.tad/templates/handoff-a-to-b.md` (lines 37-42 verified, read at 2026-04-27 v2 by Alex)
- `.tad/hooks/userprompt-domain-router.sh` (head 50 + lines 210-260, read at 2026-04-27 by Alex)
- `.tad/hooks/post-write-sync.sh` (lines 70-80 verified, read at 2026-04-27 v2 by Alex)
- `.tad/hooks/keywords.yaml` (head 50, read at 2026-04-27 — for understanding context, not modifying)
- `.tad/deprecation.yaml` (full file, read at 2026-04-27 by Alex)
- `.claude/settings.json` hook registration (grep'd — confirmed `userprompt-domain-router.sh` registered as `type: command`)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- Hook syntax check: `bash -n .tad/hooks/userprompt-domain-router.sh`
- YAML syntax check: `python3 -c "import yaml; yaml.safe_load(open('.tad/config-platform.yaml'))" && python3 -c "import yaml; yaml.safe_load(open('.tad/deprecation.yaml'))"`

### 8.2 Integration Tests
- **Hook regression（直接 stdin/stdout 测试，BA-P0-5 修订）**：
  - 跑 §6 Phase 3 step 5 Test 1 + Test 2
  - **预期 A**: Test 2 stdout 字节数 = 0（passive — 关键证据，证明 additionalContext 注入已删）
  - **预期 B**: `.tad/hooks/.router.log` 两条新行（一条 "none 0/0"，一条含 pack 名 + N/M ratio）
  - **不要使用** `claude -p --system-prompt MARKER` 探针——见 §6 Phase 3 step 5 BA-P0-5 注释
- ***accept 流程**：跑一次本 handoff 自身的 *accept（meta-dogfood），观察：
  - **预期 C**：流程不再跑 step0b_evidence_check
  - **预期 D**：流程不再跑 step4b_linear_sync（"Linear: ..." 行不应出现在 acceptance log）
  - **预期 E**：其他步骤（git check / archive move / NEXT.md / Layer 2 audit / trace-digest）不变
- **Alex 启动**：在新 terminal `/alex` 启动，观察 STEP 3.6 Pair test 之后直接到 STEP 4 greeting，无 STEP 3.7 Linear sync 输出
- **SessionStart pack catalog 仍注入回归（BA P1）**：新 session 启动时仍能看到 "Domain Pack [pack-name]" 注入（来自 SessionStart hook，不是本次改的 UserPromptSubmit hook）。这是关键回归 — 确认本次改动只动 UserPromptSubmit，不影响 SessionStart 的 pack 目录注入。
- **handoff template Linear 字段不再传播（FR8 验证）**：用 `cat .tad/templates/handoff-a-to-b.md | grep -c "Linear"` → 0
- **post-write-sync.sh NEXT.md hook 文案（FR9 验证）**：编辑 NEXT.md 触发 hook，stdout 应显示 "NEXT.md updated."（无 "Linear sync may be needed" 尾巴）

### 8.3 Edge Cases
- **Hook 无匹配**：prompt 中无 keyword 时 hook 应继续 log "none" + ratio 0（passive mode 行为不变）
- **Hook log 文件不存在**：hook 创建文件，正常写入（passive mode 不影响）
- **deprecation.yaml 损坏**：本次只是追加，不应破坏现有 2.3.0 / 2.8.1 / 2.8.2 条目

### 8.4 Test Evidence Required
Blake 必须提供：
- [ ] Hook regression 的 `claude -p` 输出（粘贴到 completion report）
- [ ] `.router.log` 测试前后对比（log 行数 +1，证明 log 仍写）
- [ ] `wc -l` SKILL.md / config-platform.yaml / userprompt-domain-router.sh 测试前后对比
- [ ] `git diff --stat` 输出

---

## 9. Acceptance Criteria (v2 — post-review revisions)

Blake 的实现被认为完成，当且仅当：

- [ ] **AC1**: `grep -c "STEP 3.7" .claude/skills/alex/SKILL.md` 返回 0
- [ ] **AC2**: `grep -c "step0b_evidence_check" .claude/skills/alex/SKILL.md` 返回 0
- [ ] **AC3**: `grep -c "step4b_linear_sync" .claude/skills/alex/SKILL.md` 返回 0
- [ ] **AC4 (v2 — BA-P0-3 重写)**: 删除后**仅以下"已知合法残留"** 仍可包含 "linear" 字样（精确白名单，非软逃逸）：
  - `.tad/config.yaml` 第 321-322 行（v2.6.0 changelog 历史，NFR4 不回溯）
  - `.tad/archive/handoffs/COMPLETION-*.md`（已归档历史完成报告）
  - `.tad/archive/handoffs/HANDOFF-*.md`（已归档历史 handoff）
  - `.tad/active/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md`（本 handoff 自己）
  - `.tad/active/handoffs/COMPLETION-20260427-*.md`（本 handoff 的 completion 报告）

  验证命令（精确）：
  ```bash
  grep -rln -i "linear" .tad/config-platform.yaml .tad/hooks/userprompt-domain-router.sh \
    .tad/hooks/post-write-sync.sh .tad/templates/handoff-a-to-b.md \
    .claude/skills/alex/SKILL.md
  ```
  → 应返回**空列表**（5 个 active code/config/template 文件中无任何 linear 字样）
- [ ] **AC5**: `grep -c "linear_integration" .tad/config-platform.yaml` 返回 0
- [ ] **AC5b (v2 新增 — YAML 结构修复证据)**: `python3 -c "import yaml; d = yaml.safe_load(open('.tad/config-platform.yaml')); assert 'important_notes' in d and isinstance(d['important_notes'], list) and len(d['important_notes']) >= 6, 'fail'; print('OK')"` 输出 `OK`
- [ ] **AC6**: `grep -c "additionalContext" .tad/hooks/userprompt-domain-router.sh` 返回 0
- [ ] **AC7**: `grep -c "hookSpecificOutput" .tad/hooks/userprompt-domain-router.sh` 返回 0
- [ ] **AC8**: `bash -n .tad/hooks/userprompt-domain-router.sh` exit code 0
- [ ] **AC8b (v2 新增 FR9)**: `grep -c "Linear" .tad/hooks/post-write-sync.sh` 返回 0 + `bash -n .tad/hooks/post-write-sync.sh` exit code 0
- [ ] **AC9**: `grep '"2.8.4"' .tad/deprecation.yaml | wc -l` ≥ 1
- [ ] **AC10 (v2 — BA-P0-5 重写)**: §6 Phase 3 step 5 Test 2 stdout 字节数 = 0（passive — additionalContext 已彻底删除）；evidence 粘贴到 completion report
- [ ] **AC11**: `.router.log` 测试前后行数增加 ≥2（Test 1 + Test 2 都写 log）
- [ ] **AC12 (v2 — CR-P1-1 修正)**: `wc -l .claude/skills/alex/SKILL.md` 减少 ≥80 行（实际 84 行 = 55 + 7 + 22 = STEP 3.7 + step0b + step4b）
- [ ] **AC13 (v2 — BA-P0-4 修正)**: `git diff --stat` 显示恰好 7 个文件 modified, 0 created, 0 deleted。`.tad/hooks/.router.log` **从 git 跟踪中排除**（已在 .gitignore 或 untracked）— 不计入 diff stat。
- [ ] **AC14 v2 新增 FR7**: `grep -c "Linear" .tad/config.yaml` 返回 ≤ 2（仅 lines 321-322 v2.6.0 changelog 残留）+ `grep -c "linear_integration" .tad/config.yaml` 返回 0
- [ ] **AC15 v2 新增 FR8**: `grep -c "Linear" .tad/templates/handoff-a-to-b.md` 返回 0
- [ ] **AC16 (was AC14, v2 重编号)**: Layer 2 expert review (≥2 distinct sub-agents per P6-A hard rule) PASS — code-reviewer + backend-architect (or equivalent)
- [ ] **AC17 (v2 新增 — SessionStart 回归)**: 新 session `/alex` 启动时仍注入 pack catalog（来自 SessionStart hook，不是本次改的 UserPromptSubmit hook）— 截图或 stdout 摘录证明

---

## 9.1 Spec Compliance Checklist (v2 — 7 files, 17 ACs)

| # | AC | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|----|--------------------|--------------------|--------------------|-------------------------------|
| AC1 | STEP 3.7 removed | post-impl-verifiable | `grep -c "STEP 3.7" .claude/skills/alex/SKILL.md` | 0 | (post-impl) |
| AC2 | step0b removed | post-impl-verifiable | `grep -c "step0b_evidence_check" .claude/skills/alex/SKILL.md` | 0 | (post-impl) |
| AC3 | step4b_linear removed | post-impl-verifiable | `grep -c "step4b_linear_sync" .claude/skills/alex/SKILL.md` | 0 | (post-impl) |
| AC4 | linear residual restricted to whitelist | post-impl-verifiable | `grep -rln -i "linear" .tad/config-platform.yaml .tad/hooks/userprompt-domain-router.sh .tad/hooks/post-write-sync.sh .tad/templates/handoff-a-to-b.md .claude/skills/alex/SKILL.md` | empty list (no matches) | (post-impl) |
| AC5 | linear_integration removed | post-impl-verifiable | `grep -c "linear_integration" .tad/config-platform.yaml` | 0 | (post-impl) |
| AC5b | YAML structure fixed | post-impl-verifiable | `python3 -c "import yaml; d = yaml.safe_load(open('.tad/config-platform.yaml')); assert 'important_notes' in d and isinstance(d['important_notes'], list) and len(d['important_notes']) >= 6; print('OK')"` | `OK` | (post-impl) |
| AC6 | additionalContext removed | post-impl-verifiable | `grep -c "additionalContext" .tad/hooks/userprompt-domain-router.sh` | 0 | (post-impl) |
| AC7 | hookSpecificOutput removed | post-impl-verifiable | `grep -c "hookSpecificOutput" .tad/hooks/userprompt-domain-router.sh` | 0 | (post-impl) |
| AC8 | hook shell syntax OK | post-impl-verifiable | `bash -n .tad/hooks/userprompt-domain-router.sh; echo $?` | 0 | (post-impl) |
| AC8b | post-write-sync syntax + linear-free | post-impl-verifiable | `grep -c "Linear" .tad/hooks/post-write-sync.sh; bash -n .tad/hooks/post-write-sync.sh; echo $?` | `0` then `0` | (post-impl) |
| AC9 | deprecation 2.8.4 added | post-impl-verifiable | `grep '"2.8.4"' .tad/deprecation.yaml \| wc -l` | ≥1 | (post-impl) |
| AC10 | passive mode — Test 2 stdout empty | post-impl-verifiable | run §6 Phase 3 step 5 Test 2; check `wc -c < /tmp/hook-out-2.txt` | `0` | (post-impl) |
| AC11 | passive log still writes | post-impl-verifiable | check `.tad/hooks/.router.log` line count delta ≥2 between pre-test and post-test | ≥2 | (post-impl) |
| AC12 | SKILL.md line drop ≥80 | post-impl-verifiable | pre/post `wc -l .claude/skills/alex/SKILL.md` diff | ≥80 | (post-impl) |
| AC13 | 7 files modified | post-impl-verifiable | `git diff --name-only \| wc -l` (excluding .router.log) | 7 | (post-impl) |
| AC14 | config.yaml linear cleanup | post-impl-verifiable | `grep -c "linear_integration" .tad/config.yaml` | 0 | (post-impl) |
| AC15 | template Linear field removed | post-impl-verifiable | `grep -c "Linear" .tad/templates/handoff-a-to-b.md` | 0 | (post-impl) |
| AC16 | Layer 2 ≥2 distinct sub-agents | post-impl-verifiable | `bash .tad/hooks/lib/layer2-audit.sh tad-cleanup-linear-and-hook` | DISTINCT_COUNT ≥ 2 + exit 0 | (post-impl) |
| AC17 | SessionStart pack catalog regression | post-impl-verifiable | new `/alex` session start; check stdout/transcript for "Domain Pack [...]" mentions | ≥1 pack catalog injection | (post-impl) |

> 所有 AC 均为 post-impl-verifiable。Step1d Sub-rule 2 syntax-validate 已对所有 grep / bash -n / python -c / wc 命令做目视检查 — 无 `grep -P` / `sed -i without backup` / GNU-only flag 等已知坑。
> AC4 用精确白名单（5 个 active 文件 grep -rln 应空）替代 v1 的软逃逸 "unless reasonable references" 模式（BA-P0-3 防 gray zone 复发）。
> AC10 替代 v1 的 `claude -p MARKER` 探针（BA-P0-5 — 探针 false-FAIL 风险）。
> AC13 计数 7 而非 4，并明确排除 `.router.log` from diff（BA-P0-4）。

---

## 9.2 Expert Review Status (Alex 必填)

> Alex MUST integrate every expert finding into Audit Trail table row.

### Audit Trail

Both reviewers spawned in parallel via Agent tool, 2026-04-27. Findings stored at:
- `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/code-reviewer.md`
- `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/backend-architect.md`

| # | Reviewer | Issue | Resolution Section | Status |
|---|----------|-------|-------------------|--------|
| CR-P0-1 | code-reviewer | YAML structural error: `important_notes` at 2-space indent is structurally a CHILD of `linear_integration`, NOT sibling. Following deletion literally produces invalid YAML. | §4.2 File 2 Step 2.1 dedent + §6 Phase 2 step 2.1+2.2 ordering + AC5b YAML validation | **Resolved** |
| CR-P1-1 | code-reviewer | AC12 "≥100 lines" wrong arithmetic — actual SKILL.md removal = 55+7+22 = 84 lines | AC12 revised to ≥80 + §4.2 File 1 region sizes corrected | **Resolved** |
| CR-P1-3 | code-reviewer | Phase 1 step 5 says "应减少 ~110 行" — should be ~84 | §6 Phase 1 step 5 revised to ~80-90 | **Resolved** |
| CR-P1-4 | code-reviewer | §4.2 File 1 区域 A "约 80 行" — actual is 55 | §4.2 File 1 区域 A revised to "~55 行" | **Resolved** |
| CR-P1-2 | code-reviewer | Phase 1 step 7 (`grep -c "Linear"` → 0) depended on P0-1 resolution | Replaced with AC4 explicit-whitelist approach | **Resolved** |
| CR-P2-1 | code-reviewer | Phase 5 commit message shown as fenced code block, not heredoc per CLAUDE.md | §6 Phase 6 step 5 commit shown in `cat <<'EOF' ... EOF` heredoc form | **Resolved** |
| CR-P2-2 | code-reviewer | Hook regression test should also check `.router.log` for pack scoring path | §6 Phase 3 step 5 Test 2 already checks log line for pack name | **Resolved** |
| BA-P0-1 | backend-architect | Blast radius undercounted — 4 additional active files reference Linear: `.tad/config.yaml` (4 lines, 2 actionable) + `.tad/templates/handoff-a-to-b.md` line 39 (live template propagating Linear field) + `.tad/hooks/post-write-sync.sh` line 74 (live hook injecting "Linear sync may be needed") | §1.1 expanded scope to 7 files + §3.1 FR7/FR8/FR9 added + §4.2 Files 5/6/7 added + §6 Phase 5 added + §7.2 list expanded + AC14/AC15 added + AC13 count 4→7 | **Resolved** |
| BA-P0-2 | backend-architect | YAML structural ambiguity (same as CR-P0-1) — `important_notes` parent vs sibling confusion | Same resolution as CR-P0-1 | **Resolved (dup)** |
| BA-P0-3 | backend-architect | AC4 unsatisfiable + soft escape clause — `grep -ci "linear"` returns 33 currently; "unless reasonable references" recreates gray-zone pattern (3 phases recurring per arch.md 2026-04-25) | AC4 rewritten as precise whitelist: `grep -rln -i linear` over 5 active files should return EMPTY | **Resolved** |
| BA-P0-4 | backend-architect | AC13 file count will fail — count goes to 7 with FR7/8/9; `.router.log` writes during regression test inflate diff | AC13 revised to 7 + explicit `.router.log` exclusion note | **Resolved** |
| BA-P0-5 | backend-architect | Phase 3 regression test brittle — `claude -p --system-prompt MARKER` probe will false-FAIL because (a) test prompt contains "Domain Pack" substring, (b) `claude -p` injects ~19k tokens of CLAUDE.md/skill catalog mentioning Domain Packs by name | §6 Phase 3 step 5 + §8.2 + AC10 fully rewritten as direct hook stdin/stdout test (Test 1 + Test 2) — no `claude -p` involved | **Resolved** |
| BA-P1 (positive) | backend-architect | step0b vs step4b is "strict superset" not "完全重复" wording inaccuracy | §1.1 + §4.2 File 1 Region B + §11 Decision Summary row 6 wording corrected to "严格子集 / strict subset" | **Resolved** |
| BA-P1 (positive) | backend-architect | AC for "SessionStart pack catalog still injected" missing — must verify still works after UserPromptSubmit hook change | AC17 added; §8.2 added explicit regression note | **Resolved** |
| BA verified positive | backend-architect | Slug `tad-cleanup-linear-and-hook` PASSES `layer2-audit.sh` regex; "smoke alarm > auto-extinguisher" pattern correctly applied; "claude -p" invocation OK | (no change needed — verified) | (no action) |

### Expert Prompts Used

Stored in evidence files for reproducibility:
- code-reviewer prompt at `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/code-reviewer.md` (header section)
- backend-architect prompt at `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/backend-architect.md` (header section)

### Experts Selected

1. **code-reviewer** — shell script + SKILL.md + YAML edit correctness, regex/grep BSD portability, deletion safety, line-number accuracy
2. **backend-architect** — hook contract change risk (UserPromptSubmit injection removal), Linear/accept removal blast radius across all framework files, overall design coherence with 2026-04-15 mechanical-enforcement-rejected lesson

### Overall Assessment (post-integration)

- **code-reviewer**: CONDITIONAL PASS — 1 P0 + 4 P1 + 2 P2 → **all 7 Resolved in v2**
- **backend-architect**: CONDITIONAL PASS — 5 P0 + 2 P1 + verified positives → **all 7 Resolved in v2** (1 dup with CR)
- **Net P0 unique**: 5 (CR-P0-1 = BA-P0-2 deduplicated). All 5 Resolved.
- **Final verdict**: PASS for handoff to send to Blake.

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **不要顺手"优化"** hook 的 single-awk 评分逻辑——已经过 Phase 2b 性能优化（architecture.md 2026-04-07）
- ⚠️ **不要修改 keywords.yaml**——passive mode 让误触不再有用户可见后果，关键词重审推迟到将来 trace 数据足够时
- ⚠️ **不要砍 hook 注册** in settings.json——hook 仍要运行（log 写入需要），只改脚本行为
- ⚠️ **不要砍 acceptance_protocol.step4b**——这是 step0b 的"原版"，必须保留
- ⚠️ **deprecation.yaml 2.8.4 条目 files: []**——本次清理是文件内修改而非文件删除，下游 *sync 通过更新文件即可，无需独立删除

### 10.2 Known Constraints

- 已归档的旧 handoff 中可能还有 `**Linear:**` 字段引用——不需要回溯清理（NFR4）
- 已归档的旧 completion report 中可能记录了 "Linear: TAD-XX → Done" 行——历史记录，保留
- claude.ai Linear MCP 连接保留，用户仍可手动调用 Linear MCP tools（只是 TAD 不再自动调用）

### 10.3 Sub-Agent 使用建议

Blake 应该考虑使用：
- [x] **code-reviewer** - shell 脚本 + SKILL.md 编辑（必选 per P6-A hard rule）
- [x] **backend-architect** - hook 契约变更 + Linear 砍除影响评估（第二个必选 per P6-A）
- [ ] parallel-coordinator - 4 个文件可串行编辑，不需要 parallel
- [ ] bug-hunter - 不预期遇到 bug
- [ ] test-runner - 回归测试简单（claude -p + grep），手动验证即可

### 10.4 Domain Pack Anti-Patterns (来自 keywords.yaml editing guidelines)

本次不动 keywords.yaml，但读到 keywords.yaml header 确认了未来如果要重新做 keyword 审计，原则是：
- 每个 pack ≥3 unique anchors（zero cross-pack）
- 没有 keyword 出现在 >2 packs（integrity audit）
- 禁用高碰撞词：build, code, test, project, system, api, design, tool, file, data

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Process depth | Standard TAD / *express / Light | Standard TAD | 4 文件超出 *express ≤3 上限；Linear 砍 + hook 改 passive 是 contract change，值得 2 专家审查 |
| 2 | Socratic 是否重新跑 | 跑 / 引用 *discuss | 引用 *discuss | 已经做了 6+ 维度战略反思（价值/边界/风险/AC/场景/技术约束），重跑是仪式性浪费 |
| 3 | Hook 路线 | A 渐进改良（≥3 threshold）/ B passive mode | **B passive** | 对齐 2026-04-15 教训（机械强制 → 监督）；保留 log 用于将来分析；agent 自主性恢复 |
| 4 | 是否合并 4 文件到一个 handoff | 拆 2 个 *express / 1 个 Standard | 1 个 Standard | 用户明确说"直接开一个 Handoff" + 三件事都是简化型工作语义一致 |
| 5 | keywords.yaml 是否同时审计 | 一起改 / 只改 hook | 只改 hook | passive mode 让误触不再有用户可见后果，keyword 审计推迟到 trace 数据积累足够时 |
| 6 | acceptance_protocol.step4b 是否一起删 | 删 / 保留 | 保留 | step4b 是 *accept 流程中 evidence 完整性检查的**严格超集**（step4b 还检查 frontmatter `e2e_required` / `research_required` paths）；step0b 是 step4b 的**严格子集**，删除 step0b 是合并不是丢失（BA-P1 wording correction）|

---

## 12. Forward Compatibility Notes

本次改动对未来 *evolve 跨项目分析的影响：

- **Hook log 仍写入** `.router.log`——未来 trace 分析仍可用
- **Linear 集成痕迹保留在 git history**——未来如果要复活 Linear 集成（不太可能），git revert 即可
- **deprecation.yaml 2.8.4 记录决策**——下游项目 *sync 时可以追溯"为什么 Linear 突然没了"

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-27
**Version**: 3.1.0
