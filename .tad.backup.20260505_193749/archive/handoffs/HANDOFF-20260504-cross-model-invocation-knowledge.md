---
task_type: yaml
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
**Date:** 2026-05-04
**Project:** TAD Framework
**Task ID:** TASK-20260504-004
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-04

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3-file design reviewed by code-reviewer + backend-architect |
| Components Specified | ✅ | 3 files (1 new, 2 modify), insertion points anchor-text verified |
| Functions Verified | ✅ | SKILL insertion points verified via Read + corrected per expert review |
| Data Flow Mapped | ✅ | User → Alex/Blake signal → preflight → dual-path fallback |

**Gate 2 结果**: ✅ PASS (5 P0 + 6 P1 resolved, 0 open)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 需求来源
用户在 Cross-Model Orchestration Epic Phase 0 spike 验证了 Codex CLI 和 Gemini CLI 可以从 Claude Code 的 Bash tool 中调用。但 spike 的知识散落在 architecture.md 的 10+ 个条目中，Alex 和 Blake 的 SKILL 文件不知道这些工具的存在。用户希望：**当他说"用 Codex 做 review"时，Alex/Blake 立即知道怎么做，不需要重复教学。**

### 核心目标
让 Alex 和 Blake 内置 Codex/Gemini CLI 的调用知识，实现：
1. **用户明确要求时**：agent 直接知道怎么调用
2. **自身能力不足时**：agent 可以建议使用外部工具（用户确认后执行）
3. **CLI 不存在时**：静默回退到自身能力，不报错
4. **sync 后下游项目自动获得**这个能力

### 不做的事
- ❌ 不强制集成到任何现有流程（不是 mandatory workflow step）
- ❌ 不自动调用（必须用户确认）
- ❌ 不修改 hook/settings.json（纯 SKILL 文本知识）

---

## 2. Background & Context

### 已验证的技术事实（来自 Phase 0 spike，全部在 architecture.md 有条目）

**Codex CLI:**
- `codex exec --full-auto "prompt"` — 主调用模式
- `cat <file> | codex exec --full-auto "prompt"` — 通过 stdin 注入上下文
- 非 git 目录需加 `--skip-git-repo-check`
- Exit code 0 = success，非零 = failure（exit code 是真相，不是 stderr）
- stderr `failed to record rollout items` 是良性噪音，忽略
- `--commit` 与 `--full-auto [PROMPT]` 不兼容，用 stdin 替代
- sandbox = `workspace-write`：可以读 + 写 + 执行

**Gemini CLI:**
- `gemini -p "prompt"` — 主调用模式（`-p` 在非 TTY 环境 MANDATORY）
- `-m "model-name"` 选模型
- **只读模式**：仅 grep_search、read_file、glob 可用；write_file/run_shell_command 返回 "tool not found"
- 正则输出是 PCRE 风格，macOS BSD grep -E 不兼容 — 需验证后才能用于 hook
- 适合：研究/分析/结构化报告

**容错:**
- `command -v codex` / `command -v gemini` 检测可用性（POSIX 标准，比 `which` 更可靠）
- 不存在时分两种情况：
  - 用户明确要求时 → 告知用户工具不可用，说明正在用自身能力替代
  - 系统/Alex 建议时 → 静默回退到自身能力，不提及工具缺失

---

## 3. Requirements

### FR1: 参考指南文件（NEW）
创建 `.tad/guides/cross-model-invocation.md`，整合上述所有调用知识为一份简洁参考文档。

**版本标注**：文档顶部必须标注验证时的工具版本：`Validated against: Codex CLI v0.125.0, Gemini CLI v0.39.1 (spike 2026-05-03)`

结构：
- Codex CLI 区块：调用命令、场景、flag、坑、输出处理
- Gemini CLI 区块：调用命令、场景、限制、正则警告
- Preflight 区块：可用性检测 + 静默回退逻辑
- 每个工具配 2-3 个「即用命令模板」（copy-paste ready）

### FR2: Alex SKILL 增加 cross_model_awareness
在 Alex SKILL 中添加一个 `cross_model_awareness` 协议段，包含：
- **信号识别**：用户提到 "codex"/"gemini" 关键词 → 知道用户在说什么
- **建议时机**：自身能力不足时（quota、需要独立视角、需要图片生成等）可建议，但必须用 AskUserQuestion 确认
- **委派机制**：确认后告知 Blake 执行（handoff 或会话中指令），指向参考指南
- **NOT_via_alex_auto**：Alex 不自动调用外部工具，只建议或委派

### FR3: Blake SKILL 增加 cross_model_invocation
在 Blake SKILL 中添加一个 `cross_model_invocation` 协议段，包含：
- **Preflight 检查**：`command -v codex` / `command -v gemini`（POSIX 标准）
- **双路径回退**：用户明确要求时 → 告知不可用 + 回退；系统建议时 → 静默回退
- **调用模板**：每个场景（review / research / implement）的具体 bash 命令
- **输出集成**：如何把 Codex review 结果整合到自己的 Layer 2 报告；如何把 Gemini 研究结果用于决策
- **不替代内部 review**：Codex review 是补充视角，不替代 code-reviewer sub-agent
- **Blake 也接受用户直接指令**：用户在 Blake terminal 直接说"用 Codex review"时，Blake 不需要 Alex 中转

---

## 4. Technical Design

### 4.1 Architecture

```
用户: "用 Codex review 一下这段代码"
         ↓
    ┌─── Alex ──────────────────────┐
    │ cross_model_awareness         │
    │  → 识别 "codex" + "review"    │
    │  → 委派给 Blake               │
    └───────────────────────────────┘
         ↓ (handoff 或会话指令)
    ┌─── Blake ─────────────────────┐
    │ cross_model_invocation        │
    │  → preflight: command -v codex │
    │  → 有: 调用 codex exec        │
    │  → 无(用户要求): 告知+回退    │
    │  → 无(系统建议): 静默回退     │
    │  → 输出: 整合到报告           │
    └───────────────────────────────┘
```

### 4.2 文件变更清单

| # | File | Action | Size Est. |
|---|------|--------|-----------|
| 1 | `.tad/guides/cross-model-invocation.md` | CREATE | ~120 行 |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY — 添加 `cross_model_awareness` section | +~60 行 |
| 3 | `.claude/skills/blake/SKILL.md` | MODIFY — 添加 `cross_model_invocation` section | +~80 行 |

### 4.3 Design Decisions

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 知识存放位置 | A: 全嵌入 SKILL / B: 独立参考文件 + SKILL 引用 | B | SKILL 文件已很大（Alex 4345 行），参考文件可被多方引用且独立维护 |
| 2 | 触发方式 | A: hook 检测 / B: 纯 SKILL 文本识别 | B | 符合"no hook for on-demand capability"原则，避免 Epic 1 类副作用 |
| 3 | Gemini 写文件 | A: 研究交互模式 / B: 接受只读 | B | spike 验证 -p 只读是硬限制，交互模式需 TTY 无法从 Bash tool 调 |

---

## 5. Acceptance Criteria

- [ ] **AC1**: `.tad/guides/cross-model-invocation.md` 存在，包含 Codex + Gemini 两个完整区块 + preflight 逻辑 + 即用命令模板
- [ ] **AC2**: Alex SKILL 包含 `cross_model_awareness` section，含信号识别 + 建议时机 + 委派机制
- [ ] **AC3**: Blake SKILL 包含 `cross_model_invocation` section，含 preflight + 调用模板 + 输出集成 + 回退逻辑
- [ ] **AC4**: Alex SKILL 中 cross_model_awareness 明确标注 NOT_via_alex_auto（不自动调用）
- [ ] **AC5**: Blake SKILL 中 preflight 失败时的行为是"静默回退"（不报错、不提示安装）
- [ ] **AC6**: 参考指南中 Codex 命令模板 ≥2 个 AND Gemini 命令模板 ≥2 个（copy-paste ready bash 命令）
- [ ] **AC7**: 所有 3 个文件都在 *sync scope 内（确认 .tad/guides/ 和 .claude/skills/ 均被 sync）
- [ ] **AC8**: 参考指南至少引用以下 7 个 architecture.md 条目标题（每个 `grep -F "<title>" .tad/project-knowledge/architecture.md` 返回匹配）：`codex exec --full-auto VALIDATED`、`Codex stderr failed to record rollout items`、`codex exec review --commit Incompatible`、`codex exec --skip-git-repo-check`、`Gemini CLI: -p Flag Required`、`Gemini CLI -p Mode is Read-Only`、`Gemini Regex Output Requires BSD grep-E`

### AC Verification Methods

| AC | Type | Verification |
|----|------|-------------|
| AC1 | post-impl | `test -f .tad/guides/cross-model-invocation.md && grep -c "Codex CLI" .tad/guides/cross-model-invocation.md` ≥1 AND `grep -c "Gemini CLI" .tad/guides/cross-model-invocation.md` ≥1 |
| AC2 | post-impl | `grep -c "cross_model_awareness" .claude/skills/alex/SKILL.md` ≥1 |
| AC3 | post-impl | `grep -c "cross_model_invocation" .claude/skills/blake/SKILL.md` ≥1 |
| AC4 | post-impl | `grep -c "NOT_via_alex_auto" .claude/skills/alex/SKILL.md` ≥1 |
| AC5 | post-impl | `grep -A5 "on_not_found" .claude/skills/blake/SKILL.md \| grep -c "静默"` ≥1 AND `grep -A5 "if_user_explicitly_requested" .claude/skills/blake/SKILL.md \| grep -c "告知"` ≥1 |
| AC6 | post-impl | `grep -cE '^\s*codex exec' .tad/guides/cross-model-invocation.md` ≥2 AND `grep -cE '^\s*gemini -p' .tad/guides/cross-model-invocation.md` ≥2 |
| AC7 | pre-impl | Confirmed: .tad/guides/ in sync step3b framework subdirectories list; .claude/skills/ in sync scope |
| AC8 | post-impl | For each referenced title: `grep -F "<title>" .tad/project-knowledge/architecture.md` returns match |

---

## 6. Implementation Steps

### Task 1: 创建参考指南 `.tad/guides/cross-model-invocation.md`

**目标**: 从 architecture.md 散落的 10+ 个 spike 条目中提取调用知识，整合为一份简洁的参考文档。

**结构**:
```markdown
# Cross-Model Invocation Guide
## Codex CLI
### 基本调用 / 场景模板 / Flag 参考 / 已知坑
## Gemini CLI
### 基本调用 / 场景模板 / 限制 / 已知坑
## Preflight & Fallback
### 可用性检测 / 静默回退模式
```

**内容来源**（architecture.md 条目，Blake 必须读取这些条目）:
- `codex exec --full-auto VALIDATED in Phase 2 Dogfood`
- `Codex stderr failed to record rollout items is Benign`
- `codex exec review --commit Incompatible with --full-auto [PROMPT]`
- `codex exec --skip-git-repo-check Required for Non-Git Project Directories`
- `Gemini CLI: -p Flag Required for Non-TTY / Sub-Agent Invocation`
- `Gemini CLI -p Mode is Read-Only`
- `Gemini Regex Output Requires BSD grep-E Validation`

**实现提示**:
1. 不要复制 architecture.md 全文 — 提炼为"怎么用"而不是"怎么发现的"
2. 每个场景一个 copy-paste ready 的代码块
3. 保持 <150 行

### Task 2: Alex SKILL 添加 `cross_model_awareness`

**插入位置**: 在 `my_tasks` section 之后、`intent_router_protocol` section 之前。用锚文本定位：搜索 `my_tasks:` 找到该 section 结尾，在其后插入。不要依赖行号。

**内容要点**:
```yaml
cross_model_awareness:
  description: "Alex 知道如何委派任务给 Codex/Gemini CLI"
  reference: ".tad/guides/cross-model-invocation.md"
  
  recognition:
    user_signals: ["codex", "gemini", "用 codex", "让 gemini", "codex review", "gemini 研究"]
    alex_suggestion_triggers:
      - "需要独立第二视角（自己 review 自己有盲点）"
      - "Claude sub-agent quota 耗尽"
      - "需要图片/diagram 生成"
  
  behavior:
    on_user_request: "确认 → 委派给 Blake，指向参考指南"
    on_alex_suggestion: "AskUserQuestion 建议 → 用户确认 → 委派"
    NOT_via_alex_auto: "Alex 永远不自动调用外部 CLI。只建议或委派。"
    in_handoff: "在 task 实现提示中标注 ⚠️ Cross-model + 引用参考指南"
  
  tool_capabilities:
    codex: "读 + 写 + 执行（code review / implementation / generation）"
    gemini: "只读（research / analysis / structured report）— 不能写文件"
```

**注意**:
- 保持 YAML 缩进与周围 section 一致
- 不改动其他任何 section

### Task 3: Blake SKILL 添加 `cross_model_invocation`

**插入位置**: 在 `subagent_shortcuts` section 之后、`ralph_loop_execution` section 之前。用锚文本定位：搜索 `ralph_loop_execution:` 找到该行，在其前一行插入。不要依赖行号。

**内容要点**:
```yaml
cross_model_invocation:
  description: "Blake 知道如何调用 Codex/Gemini CLI 完成委派任务"
  reference: ".tad/guides/cross-model-invocation.md"
  
  preflight:
    codex: "command -v codex >/dev/null 2>&1"
    gemini: "command -v gemini >/dev/null 2>&1"
    on_not_found:
      if_user_explicitly_requested: |
        告知用户工具不可用："{tool} CLI 未安装，我用自身能力完成。"
        然后用自身能力完成任务。
      if_system_suggested_or_handoff: |
        静默回退 — 用自身能力完成任务。
        不向用户报错，不建议安装，不提及工具缺失。
  
  scenarios:
    codex_review:
      when: "用户或 handoff 要求用 Codex 做 code review"
      command_template: |
        git diff HEAD~1 > /tmp/tad-review-diff.txt
        { echo "Review this diff:"; cat /tmp/tad-review-diff.txt; } \
          | codex exec --full-auto "Provide structured code review with P0/P1/P2 findings"
      output_integration: "整合到 Layer 2 报告作为 'External Review (Codex)' 补充视角"
      not_a_substitute: "不替代内部 code-reviewer sub-agent — 是额外独立视角"
    
    codex_implement:
      when: "用户要求用 Codex 实现某个功能或生成代码"
      command_template: |
        codex exec --full-auto "specific implementation prompt"
      note: "Codex 可写文件（workspace-write sandbox）"
      non_git_caveat: "非 git 目录加 --skip-git-repo-check flag"
    
    gemini_research:
      when: "用户要求用 Gemini 做研究或分析"
      command_template: |
        gemini -p "structured research prompt with output format instructions"
      output_note: "只读输出 — 用于决策参考，不能直接写文件"
      regex_warning: "Gemini 输出的正则是 PCRE 风格，用于 hook 前必须用 grep -E 验证"
  
  error_handling:
    exit_nonzero: "报告调用失败 + 回退到自身能力"
    stderr_noise: "忽略 Codex 的 'failed to record rollout items' stderr"
    timeout:
      mechanism: "Bash tool timeout 参数设为 120000 (2 分钟 wall clock)"
      rationale: "Codex exec 复杂 review 可能 30-60s，2min 更安全"
      shell_alternative: "或在命令前加 timeout 120 codex exec ..."
```

**注意**:
- 保持 YAML 缩进与周围 section 一致
- 不改动其他任何 section

---

## 7. Files to Modify / Create

| # | File | Action | Lines Changed |
|---|------|--------|---------------|
| 1 | `.tad/guides/cross-model-invocation.md` | CREATE | ~120 行 |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY — insert after `subagent_shortcuts` | +~50 行 |
| 3 | `.claude/skills/blake/SKILL.md` | MODIFY — insert after `subagent_shortcuts` | +~60 行 |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- `.claude/skills/alex/SKILL.md` (head 50, read at 2026-05-04)
- `.claude/skills/blake/SKILL.md` (lines 1-300, read at 2026-05-04)
- `.tad/guides/` directory listing (read at 2026-05-04 — 7 existing files)
- `.tad/project-knowledge/architecture.md` (full context via @import)

---

## 8. Testing Strategy

### Blake Self-Check (Layer 1)
- `test -f .tad/guides/cross-model-invocation.md` — 文件存在
- `grep -c "cross_model_awareness" .claude/skills/alex/SKILL.md` — Alex section 存在
- `grep -c "cross_model_invocation" .claude/skills/blake/SKILL.md` — Blake section 存在
- YAML 缩进检查：确保插入内容与周围缩进一致

### Smoke Test
- `grep -cF "codex exec" .tad/guides/cross-model-invocation.md` ≥ 2
- `grep -cF "gemini -p" .tad/guides/cross-model-invocation.md` ≥ 2
- `grep -F "NOT_via_alex_auto" .claude/skills/alex/SKILL.md` — 安全约束存在

---

## 9. Acceptance Criteria Spec Compliance

### 9.1 Spec Compliance Checklist

| AC | Requirement | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|----|-------------|--------------------|--------------------|-------------------------------|
| AC1 | 参考指南存在 + 双工具区块 | `test -f ... && grep -c` | ≥1 per tool | (post-impl) |
| AC2 | Alex 含 cross_model_awareness | `grep -c` | ≥1 | (post-impl) |
| AC3 | Blake 含 cross_model_invocation | `grep -c` | ≥1 | (post-impl) |
| AC4 | NOT_via_alex_auto 存在 | `grep -c` | ≥1 | (post-impl) |
| AC5 | 静默回退 | `grep -A5 "on_not_found"` | 含 "静默" | (post-impl) |
| AC6 | ≥4 即用命令 | `grep -cE '^\s*(codex exec\|gemini -p)'` | ≥4 | (post-impl) |
| AC7 | sync scope 覆盖 | Read sync_protocol.step3 | .tad/guides/ + .claude/skills/ in list | ✅ pre-impl verified: both in sync scope |
| AC8 | 引用标题准确 | `grep -F "<title>"` per ref | all match | (post-impl) |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC6 grep regex `\|` in `-E` mode = literal pipe, never matches | §9.1 AC6 rewritten as two separate greps | Resolved |
| code-reviewer | P0-2: Alex SKILL insertion point ~260 wrong (actual ~282) | §6 Task 2 — changed to anchor-text-only, no line numbers | Resolved |
| code-reviewer | P0-3: Blake SKILL insertion point ~272 slightly off | §6 Task 3 — changed to anchor-text-only | Resolved |
| code-reviewer | P1-1: AC5 greps "silent"/"自己做" but content has "静默" | §9.1 AC5 — changed to grep "静默" + grep "告知" | Resolved |
| code-reviewer | P1-4: AC8 doesn't enumerate required titles | §5 AC8 — enumerated all 7 required titles | Resolved |
| backend-architect | P0-1: `which` non-POSIX, use `command -v` | §2, §3 FR3, §6 Task 3 YAML — all changed to `command -v` | Resolved |
| backend-architect | P0-2: Silent fallback wrong for explicit user requests | §2, §3 FR3, §4.1, §6 Task 3 YAML — split into dual-path fallback | Resolved |
| backend-architect | P0-3: Alex insertion point structurally awkward | §6 Task 2 — moved to after `my_tasks`, before `intent_router_protocol` | Resolved |
| backend-architect | P1-1: Timeout specification incomplete | §6 Task 3 YAML — concrete mechanism: Bash tool 120000ms | Resolved |
| backend-architect | P1-2: Missing `--skip-git-repo-check` in codex_implement | §6 Task 3 YAML — added `non_git_caveat` | Resolved |
| backend-architect | P1-4: Reference guide should pin validated versions | §3 FR1 — added version pin requirement | Resolved |

---

## 10. Important Notes

### 10.1 ⚠️ 不改 hook 和 settings.json
这是纯 SKILL 文本知识注入。不注册任何 hook，不修改 settings.json，不添加 PreToolUse/PostToolUse 检查。参照 "Mechanical Enforcement Rejected on Single-User CLI" 教训。

### 10.2 Codex-edition SKILL 文件不在本次范围
`.tad/codex/codex-alex-skill.md` 和 `codex-blake-skill.md` 是用于 Codex-native TAD session 的静态文件。本次改的是 Claude Code 端的 SKILL 文件（让 Claude Code 知道怎么调 Codex），两者是不同方向。Codex-edition 如需同步，留待下次 *sync 时 strip-only 重新生成。

### 10.3 Sub-Agent 使用建议
本 handoff 不需要特殊 sub-agent。标准 Layer 2 (code-reviewer + 1 domain expert) 即可。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

1. **Gemini CLI: `-p` Flag Required for Non-TTY / Sub-Agent Invocation** (architecture.md)
   → Gemini 不加 -p 在非 TTY 环境会永远 hang，这是本次参考指南的核心坑之一

2. **Gemini CLI `-p` Mode is Read-Only** (architecture.md)
   → Gemini 只读是硬限制，参考指南必须明确标注，Blake SKILL 不能给出 Gemini 写文件的命令

3. **Codex stderr `failed to record rollout items` is Benign** (architecture.md)
   → 参考指南和 Blake SKILL 的 error_handling 必须包含此项

4. **`codex exec --full-auto` VALIDATED in Phase 2 Dogfood** (architecture.md)
   → 这是主调用模式的权威验证来源

5. **`codex exec review --commit` Incompatible with `--full-auto [PROMPT]`** (architecture.md)
   → 参考指南必须包含 stdin 替代方案

6. **Gemini Regex Output Requires BSD grep-E Validation** (architecture.md)
   → Gemini 研究输出中的正则不能直接用于 macOS hook

7. **Codex-Edition SKILL: Strip-Only Rule Prevents Drift** (architecture.md)
   → 本次不改 Codex-edition SKILL 的原因

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 知识存放 | A: 全嵌入 SKILL / B: 独立文件 + SKILL 引用 | B | SKILL 已大（Alex 4345L），独立文件可复用 |
| 2 | 触发方式 | A: hook / B: 纯 SKILL 文本 | B | 避免 Epic 1 副作用，on-demand 能力不需 hook |
| 3 | Gemini 写文件 | A: 研究交互模式 / B: 接受只读 | B | -p 只读是硬限制 |
| 4 | 建议时机 | A: 总是建议 / B: 能力不足时 / C: 不建议 | B | 避免噪音，只在真需要时出声 |
| 5 | CLI 缺失处理 | A: 报错 / B: 静默回退 / C: 提示安装 | B | 用户要求 |
