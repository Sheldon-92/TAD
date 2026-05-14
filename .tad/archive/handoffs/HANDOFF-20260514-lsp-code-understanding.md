# Handoff: LSP Code Understanding Integration

**From:** Alex | **To:** Blake | **Date:** 2026-05-14
**Priority:** P1
**Type:** Protocol Enhancement

---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/alex/
  - .claude/skills/blake/
  - .tad/guides/
---

## 1. Executive Summary

**Problem:** Alex 和 Blake 对代码结构的理解完全依赖文本级工具（grep + Read head 50）。这导致：
- Alex §6 scope estimation 反复 drift（architecture.md 记录了 4 次）
- Blake 实现前不知道改动的 blast radius
- Expert reviewer 只看 diff，不知道影响面

**Solution:** 集成 Claude Code 原生 LSP tool（已有 12 个语言插件），让 Alex/Blake 在关键环节自动使用 `incomingCalls` / `outgoingCalls` / `findReferences` 进行精确的代码结构分析。LSP 不可用时静默回退 grep，零破坏性。

**Evidence:** 在 menu-snap（599 文件 / 129K LOC）上实测，LSP `incomingCalls` 对 `getApiUrl` 精确返回 10 个调用方（跨 4 文件），包含函数名 + 文件路径 + 行号。同等查询用 grep 会产生 import 语句、注释等大量误报且无法追踪间接调用。

## 2. Requirements

### FR1: LSP Auto-Provision Protocol
Alex/Blake 在需要 LSP 时自动检测、安装、使用。全程无需用户干预。

### FR2: Alex step1c LSP Impact Analysis + §6 Scope Verification
step1c grounding pass 增加 LSP 查询：对 §6 中被修改的符号运行 incomingCalls，发现 scope gap 并自动补充 §6 文件列表。（原 FR3 "§6 Scope Verification" 已合并 — step1c_lsp 的 scope gap detection 完全覆盖。）

### FR3: Blake Blast Radius Check
Blake develop_command 增加 1_5d 步骤：实现前用 LSP 检查修改符号的调用方。

## 3. Technical Design

### 3.1 Language-Plugin Mapping Table

放在 `.tad/guides/lsp-language-map.yaml`：

```yaml
# LSP Language → Plugin Mapping
# Used by Alex step1c_lsp and Blake 1_5d_lsp_blast_radius
# Source: ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/

lsp_plugins:
  - extensions: [".ts", ".tsx", ".js", ".jsx", ".mts", ".cts", ".mjs", ".cjs"]
    plugin: "typescript-lsp"
    prereq: "npm i -g typescript-language-server typescript"
  - extensions: [".py", ".pyi"]
    plugin: "pyright-lsp"
    prereq: "npm i -g pyright"
  - extensions: [".rs"]
    plugin: "rust-analyzer-lsp"
    prereq: "brew install rust-analyzer"
  - extensions: [".go"]
    plugin: "gopls-lsp"
    prereq: null
  - extensions: [".swift"]
    plugin: "swift-lsp"
    prereq: null
  - extensions: [".kt", ".kts"]
    plugin: "kotlin-lsp"
    prereq: "brew install JetBrains/utils/kotlin-lsp"
  - extensions: [".java"]
    plugin: "jdtls-lsp"
    prereq: "brew install jdtls"
  - extensions: [".cs"]
    plugin: "csharp-lsp"
    prereq: "brew install csharp-ls"
  - extensions: [".php"]
    plugin: "php-lsp"
    prereq: "npm i -g intelephense"
  - extensions: [".rb", ".rake", ".gemspec"]
    plugin: "ruby-lsp"
    prereq: null
  - extensions: [".lua"]
    plugin: "lua-lsp"
    prereq: "brew install lua-language-server"
  - extensions: [".c", ".cpp", ".cc", ".h", ".hpp"]
    plugin: "clangd-lsp"
    prereq: "brew install llvm"
```

### 3.2 LSP Auto-Provision Protocol (shared by Alex + Blake)

```yaml
lsp_provision_protocol:
  description: "Detect → try → install → fallback. Zero user interaction."
  
  step1_detect:
    action: "Extract primary file extensions from §6 Files to Modify"
    output: "dominant_extension (e.g., '.ts')"
  
  step2_lookup:
    action: "Match dominant_extension against lsp-language-map.yaml"
    output: "plugin_name, prereq_command"
  
  step3_try:
    action: "LSP documentSymbol on first existing file in §6"
    on_success: "LSP available → proceed to impact analysis"
    on_no_server: "goto step4_install"
  
  step4_install:
    action: |
      a. Prereq install (split by weight):
         - npm-based prereqs (typescript-lsp, pyright-lsp, php-lsp): auto-install silently
           Bash("npm i -g {prereq_package}") — lightweight, seconds, standard dev tooling
         - brew-based prereqs (rust-analyzer, jdtls, llvm, kotlin-lsp, etc.): DO NOT auto-install
           Log: "LSP prereq needs: {prereq_command}. Run manually if you want LSP for {language}."
           Reason: brew packages can be 2GB+ (llvm); silent install violates user's env safety rule
      b. Plugin install: Bash("claude plugin install {plugin_name}")
         Validated: this exact command succeeded in session 2026-05-14 (exit 0, non-interactive)
      c. Retry LSP documentSymbol (line=1, character=1)
    on_retry_success: "LSP available → proceed to impact analysis"
    on_retry_fail: |
      LSP installed but needs new session to activate (confirmed by 2026-05-14 test).
      Log: "LSP plugin {plugin_name} installed. Available next session."
      Fallback to grep for this session.
    time_budget: "step3_try: <2s. step4_install npm prereq: 5-30s. step4_install plugin: <5s. If total >60s, abort and fallback."
  
  step5_fallback:
    action: "Use existing grep + Read approach (current behavior, zero regression)"
    note: "No error output, no user prompt. Silent degradation."
```

### 3.3 Alex step1c LSP Enhancement

在现有 step1c grounding pass **之后**追加（不替换现有 Read head 50）：

```yaml
step1c_lsp:
  name: "LSP Impact Analysis — scope gap detection"
  trigger: "After step1c grounding pass, before step1d AC Dry-Run pass"
  prerequisite: "lsp_provision_protocol completed (step3 or step4 succeeded)"
  
  action: |
    For each EXISTING file in §6 that handoff proposes to MODIFY (not create):
    
    1. Run LSP documentSymbol (line=1, character=1 — required by tool schema but not
       semantically used for this operation) → identify exported functions/classes/constants
    2. Cross-reference with handoff task description: which symbols will change?
       (LLM judgment — match task description against symbol names.
       Bias: when uncertain, CHECK the symbol. False positive = cheap extra LSP call.
       False negative = missed scope gap, defeating the entire purpose.)
    3. For each symbol identified as "will be modified":
       Run LSP incomingCalls → get all callers
    4. Collect all caller file paths into a set: lsp_callers
    5. Compare lsp_callers against §6 file list:
       - Caller in §6 → ✅ covered
       - Caller NOT in §6 → ⚠️ scope gap
    6. If scope gaps found:
       a. Output: "⚠️ LSP: {N} files call modified symbols but are not in §6: {list}"
       b. Add to §6 with annotation: "(LSP: calls modified {symbol_name})"
       c. Read head 30 of each gap file (lightweight grounding)
    7. Append to Grounded Against:
       "LSP impact: {N} symbols checked, {M} callers found, {G} scope gaps added"
  
  skip_if:
    - "LSP not available (provision failed) → existing step1c is sufficient"
    - "§6 is empty or all files are new (create, not modify)"
    - "task_type is doc-only, yaml, or research"
  
  token_budget: "~5 LSP calls per file × ~3 files = ~15 calls. Each returns ~200 tokens."
```

### 3.4 Blake 1_5d LSP Blast Radius

在 Blake develop_command 的 `1_5c_research_task_detection` 之后、`1_6_tdd_check` 之前追加：

```yaml
1_5d_lsp_blast_radius:
  name: "LSP Blast Radius Check"
  trigger: "After 1_5c_research_task_detection, before 1_6_tdd_check"
  prerequisite: "lsp_provision_protocol completed"
  
  action: |
    For each file in handoff §6 marked as MODIFY:
    
    1. Run LSP documentSymbol → exported symbols
    2. For key symbols (functions/classes with >0 callers likely):
       Run LSP incomingCalls → caller list
    3. Output blast radius summary:
       "🔍 Blast radius for {file}:
        - {symbol}: {N} callers in {M} files
        - {symbol}: {N} callers in {M} files"
    4. If ANY caller is NOT in handoff §6:
       Output: "⚠️ {caller_file}:{caller_func} calls {symbol} but is not in handoff scope.
       Verify this caller won't break after the change."
    5. This is INFORMATIONAL — does NOT block implementation.
       Blake uses judgment on whether to also update the unlisted callers.
  
  skip_if:
    - "LSP not available → skip silently"
    - "All files are new (create, not modify)"
    - "task_type is doc-only, yaml, or research"
  
  compact_recovery: "Step produces no persistent state. Safe to skip after compact."
```

### 3.5 Tool Quick Reference Updates

Add LSP section to both `tool-quick-reference-alex.md` and `tool-quick-reference-blake.md`:

```markdown
### LSP (Code Intelligence — Claude Code Native)
- **Availability:** Requires language-specific plugin. See `.tad/guides/lsp-language-map.yaml`
- **Preflight:** Try `LSP documentSymbol` on a target file. "No LSP server available" → needs plugin install.
- **Auto-install:** `claude plugin install {plugin_name}` (takes effect next session)
- **Key operations:**
  - Impact analysis: `LSP incomingCalls` — who calls this function?
  - Dependency chain: `LSP outgoingCalls` — what does this function call?
  - All references: `LSP findReferences` — every usage of this symbol
  - File structure: `LSP documentSymbol` — all symbols in a file
  - Workspace search: `LSP workspaceSymbol` — find symbol across project
  - Type info: `LSP hover` — documentation and type at a position
- **Parameters:** operation, filePath (absolute), line (1-based), character (1-based)
- **Note:** `documentSymbol` and `workspaceSymbol` require line+character by tool schema but don't use them semantically. Pass line=1, character=1.
- **Session constraint:** Newly installed plugins need NEW session to activate.
- **Mapping:** `.tad/guides/lsp-language-map.yaml`
```

## 4. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Code understanding approach | codegraph-rust MCP / LSP native / grep only | LSP native | Zero external deps, Claude Code 官方方向, 12 语言, 实测覆盖 80% 需求 |
| 2 | Integration shape | Capability Pack / Protocol embed | Protocol embed | 只改 3 个触发点, 不值得独立 pack |
| 3 | Provision strategy | tad.sh 预装 / 文档提示 / Agent 按需装 | Agent 按需装 | 零用户干预, 首次 fallback 可接受 |
| 4 | Trigger points | 3 核心 / +expert review / +Gate 3 | 3 核心 | Minimal viable, 扩展留给后续 |

## 5. Research Evidence

实测数据（2026-05-14, menu-snap 项目）：
- `documentSymbol` on api-client.ts: 返回完整结构（函数、接口、常量、嵌套属性）
- `incomingCalls` on `getApiUrl`: 精确返回 10 个调用方, 跨 4 文件, 含函数名+行号
- `outgoingCalls` on `apiCall`: 14 个调用目标, 区分项目内 vs 标准库
- `findReferences` on `getPersonaMetadata`: 正确返回 1（仅定义本身, 无外部调用）

Session 限制验证：mid-session `claude plugin install` 成功但 LSP tool 在同 session 内不可用, 新 session 可用。

## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/guides/lsp-language-map.yaml` | CREATE | 12 语言 → 插件映射表 |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | step1c 后追加 step1c_lsp; handoff_creation_protocol 追加 lsp_provision |
| 3 | `.claude/skills/blake/SKILL.md` | MODIFY | develop_command 追加 1_5d_lsp_blast_radius; 追加 lsp_provision |
| 4 | `.tad/guides/tool-quick-reference-alex.md` | MODIFY | 追加 LSP section |
| 5 | `.tad/guides/tool-quick-reference-blake.md` | MODIFY | 追加 LSP section |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` step1c section (in current context, lines referencing step1c)
- `.claude/skills/blake/SKILL.md` lines 475-534 (develop_command, read at 2026-05-14)
- `.tad/guides/tool-quick-reference-alex.md` head 50 (read at 2026-05-14)
- `.tad/guides/tool-quick-reference-blake.md` head 10 (read at 2026-05-14)
- `.tad/guides/lsp-language-map.yaml` (new — will be created)

## 7. Implementation Hints for Blake

### P1: lsp-language-map.yaml
- 直接从 §3.1 复制 YAML, 保存到 `.tad/guides/`

### P2: Alex SKILL.md — lsp_provision_protocol
- 在 `handoff_creation_protocol` 区域内, step1c 和 step2 之间插入
- 协议文本定义, 不是 hook, 不是 settings.json
- provision 结果存在 conversation context (ephemeral), 不需要持久化

### P3: Alex SKILL.md — step1c_lsp
- 紧跟现有 step1c 之后, step1d 之前
- 必须有 `skip_if` 条件: LSP 不可用 / §6 空 / doc-only
- 输出追加到 Grounded Against section

### P4: Blake SKILL.md — 1_5d_lsp_blast_radius
- 在 `1_5c_research_task_detection` 之后、`1_6_tdd_check` 之前
- 信息性, 不阻塞 — Blake 用 judgment 决定是否扩展 scope
- compact_recovery safe (无持久 state)

### P5: Tool Quick References
- 两个文件加相同的 LSP section (§3.5 内容)
- 放在 "External CLI Tools" section 之后, 用 `### LSP` heading

## 8. Micro-Tasks

| # | Task | Files | Est. | Depends |
|---|------|-------|------|---------|
| M1 | Create lsp-language-map.yaml | 1 | 5min | — |
| M2 | Add lsp_provision_protocol to Alex SKILL | 1 | 10min | M1 |
| M3 | Add step1c_lsp to Alex SKILL | 1 | 15min | M2 |
| M4 | Add 1_5d_lsp_blast_radius to Blake SKILL | 1 | 15min | M1 |
| M5 | Update tool quick references (both) | 2 | 5min | M1 |

## 9. Acceptance Criteria

- [ ] AC1: `.tad/guides/lsp-language-map.yaml` exists with 12 entries
- [ ] AC2: Alex SKILL.md contains `lsp_provision_protocol` section
- [ ] AC3: Alex SKILL.md contains `step1c_lsp` section with `skip_if` conditions
- [ ] AC4: Blake SKILL.md contains `1_5d_lsp_blast_radius` section with `skip_if` and `compact_recovery`
- [ ] AC5: Both tool-quick-reference files contain LSP section
- [ ] AC6: Provision protocol includes auto-install (`claude plugin install`) + prereq install
- [ ] AC7: All new sections have graceful degradation (LSP unavailable → silent skip, zero regression)
- [ ] AC8: No hooks registered in settings.json (protocol-level only, consistent with step1c/step1d enforcement style)

### 9.1 Spec Compliance Checklist

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `test -f .tad/guides/lsp-language-map.yaml && grep -c 'plugin:' .tad/guides/lsp-language-map.yaml` | 12 |
| AC2 | `grep -c 'lsp_provision_protocol' .claude/skills/alex/SKILL.md` | ≥1 |
| AC3 | `grep -c 'step1c_lsp' .claude/skills/alex/SKILL.md` | ≥1 |
| AC4 | `grep -c '1_5d_lsp_blast_radius' .claude/skills/blake/SKILL.md` | ≥1 |
| AC5 | `grep -c '### LSP' .tad/guides/tool-quick-reference-alex.md .tad/guides/tool-quick-reference-blake.md` | 2 (one per file) |
| AC6 | `grep -c 'claude plugin install' .claude/skills/alex/SKILL.md` | ≥1 |
| AC7 | `grep -c 'skip_if\|fallback\|skip silently' .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` | ≥4 |
| AC8 | `git diff HEAD .claude/settings.json \| wc -l` | 0 (settings.json unchanged by this handoff) |

### AC Dry-Run Log (Alex step1d, 2026-05-14)
- AC1: ✅ post-impl-verifiable, syntax-validated (`test -f` + `grep -c` valid shell)
- AC2: ✅ post-impl-verifiable, syntax-validated
- AC3: ✅ post-impl-verifiable, syntax-validated
- AC4: ✅ post-impl-verifiable, syntax-validated
- AC5: ✅ post-impl-verifiable, syntax-validated (`grep -c '### LSP'` — simplified per CR-P1-5)
- AC6: ✅ post-impl-verifiable, syntax-validated
- AC7: ✅ post-impl-verifiable, syntax-validated
- AC8: ✅ pre-impl-verifiable, raw cmd: `git diff HEAD .claude/settings.json | wc -l`, output: `0` — matches expected

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: 1_5d insertion point contradiction | §3.4 trigger + §7 P4 unified to "After 1_5c, before 1_6" | Resolved |
| code-reviewer | P0-2: AC8 grep -c piped to grep -v is no-op | §9.1 AC8 rewritten to `git diff HEAD \| wc -l` | Resolved |
| code-reviewer | P0-3: Missing AC Dry-Run Log | §9.1 AC Dry-Run Log added above | Resolved |
| code-reviewer | P1-1: step1c_lsp trigger says "before step2" | §3.3 trigger fixed to "before step1d" | Resolved |
| code-reviewer | P1-3: FR3 has no design section | §2 FR3 merged into FR2 | Resolved |
| code-reviewer | P1-4: Missing skip_if for task_type: research | §3.3 skip_if updated | Resolved |
| code-reviewer | P1-5: AC5 fragile heading pattern | §9.1 AC5 simplified to `grep -c '### LSP'` | Resolved |
| code-reviewer | P1-6: tool-quick-reference insertion point ambiguous | §7 P5 — deferred to Blake judgment (add `## Claude Code Native Tools` section) | Open |
| backend-architect | P0-1: Auto-install heavy prereqs silently | §3.2 step4_install split: npm=silent, brew=recommend only | Resolved |
| backend-architect | P0-2: 1_5d insertion point (same as CR P0-1) | §3.4 + §7 P4 fixed | Resolved |
| backend-architect | P0-3: AC8 broken (same as CR P0-2) | §9.1 AC8 rewritten | Resolved |
| backend-architect | P1-2: documentSymbol needs line=1, character=1 note | §3.5 tool reference + §3.3 action step 1 updated | Resolved |
| backend-architect | P1-3: lsp-language-map.yaml macOS-specific | §3.1 — Blake add comment at YAML top | Open |
| backend-architect | P1-4: Symbol matching bias instruction | §3.3 step 2 bias added | Resolved |
| backend-architect | P1-5: No time budget for provision | §3.2 step4_install time_budget added | Resolved |

## 10. Important Notes

### 10.1 Session Constraint
LSP plugins installed mid-session via `claude plugin install` do NOT take effect until the next session. The provision protocol handles this: install for future + fallback for now.

### 10.2 Enforcement Style
All new sections use `enforcement: prompt-level-only`. Consistent with step1c, step1d, and all Phase 3 P3.1/P3.2/P3.3 forbidden_implementations patterns. NO hooks, NO settings.json entries, NO tool blocks.

### 10.3 Regression Safety
Every LSP enhancement has a `skip_if` guard. If LSP is completely absent (no plugins ever installed), Alex and Blake behave exactly as they do today. Zero regression by design.

## 11. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/lsp-code-understanding/code-reviewer.md
  - .tad/evidence/reviews/blake/lsp-code-understanding/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/lsp-code-understanding/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260514-lsp-code-understanding.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new discovery)
```

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Cleanup Handoff Scope-Estimation Drift** (architecture.md, 2026-04-27): Alex §6 scope estimation 反复 drift 的根因是 "primary mention bias" — Alex 只 grep DEFINE 位置,漏掉 CONSUMER。LSP incomingCalls 正是为了修这个问题。
- **Minimal Viable Cross-Cutting Enhancement** (architecture.md, 2026-02-19): 跨多个 workflow 节点添加增强时，从 2 个最关键点开始。我们选了 3 个（step1c + §6 + develop_command），已经是最小可行集。
- **Claude Code Native Mechanism Validation** (architecture.md, 2026-03-31): Skill frontmatter 的 allowed-tools 字段不生效。所有新增内容必须是 protocol text，不是 hook 或 settings.json。

## 🔧 Domain Pack References (Blake 必读)

本 handoff 不涉及 Domain Pack。修改的是 TAD 框架协议本身。
