---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Capability Pack Auto-Awareness + Sync Install

## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-14
**Project:** TAD Framework
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-14

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 2 experts reviewed (code-reviewer + backend-architect), 4 P0 fixed |
| Components Specified | ✅ | 3 changes in 2 files, insertion points verified |
| Functions Verified | ✅ | Target insertion points verified via Read + blast-radius grep |
| Data Flow Mapped | ✅ | pack-registry → install.sh → .claude/skills/ → SKILL load |

**Gate 2 结果**: ✅ PASS (after P0 fixes)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

### 9.2 Expert Review Status

| Reviewer | Type | Verdict | P0 Found | P0 Resolved |
|----------|------|---------|----------|-------------|
| code-reviewer | code-reviewer | CONDITIONAL PASS → PASS after fixes | 3 | 3 |
| backend-architect | backend-architect | CONDITIONAL PASS → PASS after fixes | 2 | 2 |

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: install.sh error handling — fail-fast chaining | §4.1 step b2 — separate Bash calls + exit code capture | Resolved |
| code-reviewer | P0-2: .claude/ pre-check missing | §4.1 step b2 — Pre-check added | Resolved |
| code-reviewer | P0-3: PRESERVE comment contradiction | §7 Task 1 — OLD/NEW replacement specified | Resolved |
| backend-architect | P0-1: set -e propagation | §4.1 step b2 — separate Bash calls note | Resolved (same fix as CR P0-1) |
| backend-architect | P0-2: No SKILL.md frontmatter validation | §4.1 step b2 — post-install head+grep check | Resolved |
| code-reviewer | P1-1: Incomplete mode partition | §4.2 skip_if — added *idea-promote, *research-review, etc. | Resolved |
| code-reviewer | P1-3: Hardcoded React assumption | §4.3 step 2a — broadened to ["frontend", "component", "UI"] | Resolved |
| code-reviewer | P1-4: Unnecessary sleep 0.5 | §4.1 step b2 — removed | Resolved |
| backend-architect | P1-2: max_packs ranking undefined | §4.2 ranking_when_over_limit — highest keyword overlap + registry order | Resolved |
| backend-architect | P1-3: step4_5 handoff write ambiguity | §4.2 does_NOT_write_to_handoff — explicit clarification | Resolved |

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### Executive Summary
让 Capability Pack 从"被动深藏的设计步骤"变成"主动无处不在的质量保障"。三个改动：(1) *sync 自动安装 pack 到下游项目，(2) Alex 在所有模式下自动感知 pack，(3) Blake *develop 时自动检测并加载 pack。

### Problem
8 个 capability pack 已构建完成，14 个下游项目都有 pack-registry.yaml，但**没有一个项目真正安装了 pack 作为 skill**。当前 pack 加载仅在 Alex `*design step1_5b` 触发——99% 的使用场景错过了 pack。

### Scope
- **In scope**: *sync pack installation, Alex broad awareness, Blake *develop detection
- **Out of scope**: Non-TAD (普通 Claude Code) pack awareness, pack SKILL.md redesign, install.sh 修改

---

## 2. Background & Context

### 诊断
1. **安装断层**: *sync 同步 pack-registry.yaml (index) 但不安装 pack 本体 (SKILL.md + references/)
2. **激活面窄**: 只在 `*design step1_5b` 匹配 → *express, *bug, *discuss, *learn 全部跳过
3. **Blake 无感知**: 完全依赖 Alex handoff 里的 Domain Pack References section

### install.sh 机制 (已验证)
- 8 个 pack 全部有 install.sh
- 机制: `CAPABILITY.md` → `.claude/skills/{pack}/SKILL.md` + 子目录 (checklists/, references/, tools/)
- 用法: `cd {target_project} && bash {TAD_SOURCE}/.tad/capability-packs/{pack}/install.sh --force`
- `--force` 覆盖已有文件 (保持 pack 最新)

---

## 3. Requirements

### FR1: *sync 自动安装所有 pack
每次 *sync 同步到下游项目时，在 framework files 复制之后、deprecation cleanup 之前，对目标项目运行所有 8 个 pack 的 install.sh。

### FR2: Alex 全模式 pack 感知
Alex intent router 完成路由后（进入 *analyze, *express, *bug, *discuss, *learn, *experiment 之前），自动扫描已安装的 pack，匹配当前任务关键词，加载相关 pack。

### FR3: Blake *develop pack 自动检测
Blake 在 *develop 启动时（context refresh 之后、notebook check 之前），根据 handoff 涉及的文件类型和关键词，自动检测并加载已安装的 pack。

---

## 4. Technical Design

### 4.1 *sync Pack Installation (Alex SKILL.md sync_protocol)

**插入点**: `sync_protocol.execution.step3` 中 step b (framework files) 之后，step c (deprecation cleanup) 之前。

新增 step `b2`:
```yaml
b2. Capability Pack installation:
    Pre-check: verify {target_project_path}/.claude/ exists.
      If missing: WARN "Skipping pack install for {project_name}: .claude/ not found" and skip to step c.
    
    For each pack directory in {TAD_SOURCE}/.tad/capability-packs/*/ that contains install.sh:
      1. Execute as a SEPARATE Bash tool call (NOT chained with && — one pack's failure must not prevent others):
         cd {target_project_path} && bash {TAD_SOURCE}/.tad/capability-packs/{pack_name}/install.sh --force; echo "EXIT:$?"
      2. If exit code non-zero: WARN "{pack_name} install failed on {project_name}: exit {code}" and continue to next pack
      3. Post-install validation: verify the installed SKILL.md has YAML frontmatter
         head -3 {target_project_path}/.claude/skills/{pack_name}/SKILL.md | grep -q "^name:"
         If grep fails: WARN "{pack_name} installed but SKILL.md lacks frontmatter — skill may not activate" and increment fail counter
    
    Output: "📦 {N} capability packs installed ({success} success, {fail} failed)"
    Note: install.sh uses CWD for .claude/ detection, so cd is required.
    Note: --force ensures packs are updated on each sync (idempotent).
    Note: Each install.sh runs in its own Bash call to prevent set -euo pipefail propagation.
```

### 4.2 Alex Pack Awareness Scan (Alex SKILL.md intent_router_protocol)

**插入点**: `intent_router_protocol.step4` (Route) 之后，进入具体 path protocol 之前。

新增 step `step4_5`:
```yaml
step4_5:
  name: "Pack Awareness Scan"
  trigger: "After intent router resolves (step4), before entering the specific path"
  action: |
    1. Check if .tad/capability-packs/pack-registry.yaml exists
       → If not: skip silently (no packs registered)
    
    2. Read pack-registry.yaml → extract all pack entries with keywords
    
    3. For each pack, determine availability (same 3-tier as step1_5b):
       Tier 1: .tad/capability-packs/{name}/CAPABILITY.md exists → available
       Tier 2: .claude/skills/{name}/SKILL.md exists → available
       Tier 3: neither → not installed, skip (don't offer install here — not the right moment)
    
    4. Match user input keywords against available packs' keywords lists
       (LLM semantic match, same mechanism as step1_5b)
    
    5. If ≥1 pack matches:
       → Read matched pack(s) SKILL.md (Tier 2) or CAPABILITY.md (Tier 1)
       → Output: "🎯 Pack loaded: {name} — {one-line description}"
       → Pack content is now in context for the entire path execution
    
    6. If no match: skip silently (no output)
  
  applies_to: "All user-task modes: *analyze, *express, *bug, *discuss, *learn, *experiment"
  skip_if:
    - "pack-registry.yaml not found or YAML parse error (WARN + skip)"
    - "No available packs (all Tier 3)"
    - "Framework management commands: *publish, *sync, *sync-add, *sync-list, *status, *dream, *optimize, *evolve, *idea-list, *idea-promote, *research-review, *research-plan, *test-review, *cancel"
  
  max_packs: 2  # Load at most 2 packs per session (context budget)
  ranking_when_over_limit: |
    If >2 packs match, select 2 with highest keyword overlap count.
    Break ties by pack order in pack-registry.yaml (earlier = higher priority).
  
  does_NOT_write_to_handoff: |
    step4_5 loads pack into conversation context only — it does NOT inject
    the "🔧 Domain Pack References" section into the handoff. That remains
    step1_5b's responsibility during *design. Blake's 1_5a independently
    re-detects packs, so Alex and Blake may load different packs for the
    same task. This is intentional — Blake catches what Alex missed.
  note: |
    This does NOT replace step1_5b in *design — step1_5b has the full
    confirmation flow (AskUserQuestion, CONSUMES/PRODUCES chain, install offer).
    step4_5 is lightweight and silent — no user interaction.
    If step4_5 already loaded a pack, step1_5b should detect it and skip re-loading.
```

### 4.3 Blake Pack Auto-Detection (Blake SKILL.md develop_command)

**插入点**: `develop_command.steps` 中 `1_5_context_refresh` 之后、`1_5b_notebook_check` 之前。

新增 step `1_5a_pack_detection`:
```yaml
1_5a_pack_detection:
  description: "Auto-detect and load relevant capability packs based on handoff content"
  action: |
    1. Check handoff for explicit pack references:
       a. Look for "🔧 Domain Pack References" section in handoff
       b. If found: read referenced pack files directly → announce + skip auto-detection
    
    2. If no explicit references (Alex didn't include pack section):
       a. Extract primary file extensions from handoff §6 (Files to Modify):
          - .tsx/.jsx/.css/.scss → keywords: ["frontend", "component", "UI"]
          - .ts/.js (in api/, routes/, server/, services/) → keywords: ["backend", "API"]
          - .py → keywords: ["backend", "agent"]
          - .md (DESIGN.md, design tokens) → keywords: ["UI", "design"]
       b. Read .tad/capability-packs/pack-registry.yaml (or scan .claude/skills/)
          If not found or YAML parse error → skip silently
       c. Match extracted keywords against pack keyword lists
       d. For each matched pack (max 2):
          → Check availability: .claude/skills/{name}/SKILL.md or .tad/capability-packs/{name}/CAPABILITY.md
          → If available: Read SKILL.md/CAPABILITY.md
          → Output: "🎯 Pack loaded: {name} — applying quality rules during implementation"
    
    3. If no pack matches: skip silently
  
  blocking: false
  purpose: "Catch packs Alex missed — Blake independently identifies relevant quality rules"
  note: |
    This is INDEPENDENT of Alex's handoff. Even if Alex loaded a pack,
    Blake re-checks because: (a) Alex may have used *express which skips
    step1_5b entirely, (b) Alex's keyword matching may have missed a relevant pack.
    If the same pack was already loaded via handoff's Domain Pack References (step 1),
    don't re-read it.
```

---

## 5. Research Evidence
N/A — changes are protocol additions, no external research needed.

---

## 6. Files to Modify / Create

| # | File | Action | What Changes |
|---|------|--------|-------------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `b2` pack install step to `sync_protocol.execution.step3` |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `step4_5` pack awareness scan to `intent_router_protocol` |
| 3 | `.claude/skills/blake/SKILL.md` | MODIFY | Add `1_5a_pack_detection` step to `develop_command.steps` |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` (read at activation + sync/intent router sections grep'd)
- `.claude/skills/blake/SKILL.md` (head 200 + develop_command section read at offset 474)
- `.tad/capability-packs/web-ui-design/install.sh` (full read — verified mechanism)
- `.tad/capability-packs/pack-registry.yaml` (full read — 8 packs, all with install.sh)

---

## 7. Implementation Steps

### Task 1: *sync Pack Installation (Alex SKILL.md)

**Location**: Find `sync_protocol.execution.step3` section. Locate step `b` (Framework files) and step `c` (Deprecation cleanup).

**Action**: Insert new step `b2` between them. Content is the YAML block from §4.1 above.

**Insertion hint**: Search for the line containing `c. Deprecation cleanup:` in the sync_protocol section. Insert the new step `b2` block immediately BEFORE that line.

Also update the existing `PRESERVE` list entry for `.tad/capability-packs/` to replace:
```
OLD: - .tad/capability-packs/ (installed via install.sh, NOT synced — downstream projects install packs independently)
NEW: - .tad/capability-packs/ (source dirs NOT synced — packs installed via step b2's install.sh during *sync)
```

### Task 2: Alex Pack Awareness (Alex SKILL.md)

**Location**: Find `intent_router_protocol` section. Locate `step4` (Route).

**Action**: Add `step4_5` (Pack Awareness Scan) as a new section AFTER step4 and BEFORE the `standby` section. Content is the YAML block from §4.2 above.

**Also update** `standby.on_new_input_in_standby` to mention that step4_5 re-runs on each new input (since packs may be relevant to the new task).

### Task 3: Blake Pack Detection (Blake SKILL.md)

**Location**: Find `develop_command.steps` section. Locate `1_5_context_refresh` and `1_5b_notebook_check`.

**Action**: Insert `1_5a_pack_detection` between them. Content is the YAML block from §4.3 above.

**Insertion hint**: Search for `1_5b_notebook_check:` in Blake's SKILL.md. Insert the new step immediately BEFORE that line.

### 10.3 Sub-Agent 使用建议
No sub-agents needed for implementation — all changes are YAML protocol additions to SKILL.md files.

---

## 8. Testing Checklist

- [ ] After Task 1: Run `*sync` on one test project → verify 8 pack SKILL.md files appear in `.claude/skills/`
- [ ] After Task 2: Start `/alex` in a downstream project, describe a frontend task → verify pack awareness scan fires and loads web-frontend or web-ui-design
- [ ] After Task 3: Start `/blake` with a handoff involving .tsx files → verify pack auto-detection loads web-frontend
- [ ] Edge case: Run `/alex` with a task that doesn't match any pack → verify no output (silent skip)
- [ ] Edge case: Run `*sync` on a project where packs are already installed → verify --force overwrites cleanly

---

## 9. Acceptance Criteria

- [ ] AC1: *sync installs all 8 capability packs to every synced project (`ls .claude/skills/{pack}/SKILL.md` exists for all 8 after sync)
- [ ] AC2: *sync pack install failure on one pack does not block other packs or framework sync
- [ ] AC3: Alex pack awareness scan fires for *analyze, *express, *bug, *discuss, *learn, *experiment (6 modes)
- [ ] AC4: Alex pack awareness scan does NOT fire for *publish, *sync, *status, *dream (framework management)
- [ ] AC5: Blake 1_5a_pack_detection loads pack based on handoff file types even when Alex didn't include Domain Pack References
- [ ] AC6: Max 2 packs loaded per session in both Alex and Blake (context budget guard)
- [ ] AC7: Already-loaded pack is not re-read (dedup between Alex handoff reference and Blake auto-detection)

### 9.1 Spec Compliance Checklist

| # | Check | Verification Method | Expected Evidence |
|---|-------|--------------------|--------------------|
| AC1 | Pack SKILL.md installed | `ls .claude/skills/web-ui-design/SKILL.md` after *sync | File exists for all 8 packs |
| AC2 | Graceful failure | Intentionally break one install.sh, run *sync | Other packs still install, WARN logged |
| AC3 | Alex 6-mode coverage | `grep -c 'analyze.*express.*bug.*discuss.*learn.*experiment' .claude/skills/alex/SKILL.md` in step4_5 section | Count ≥1 |
| AC4 | Skip framework commands | `grep 'publish.*sync.*status.*dream' .claude/skills/alex/SKILL.md` in step4_5 skip_if | Listed in skip_if |
| AC5 | Blake independent detection | Handoff without Domain Pack section → Blake loads pack | Pack loaded announcement in output |
| AC6 | Max 2 packs | `grep 'max_packs: 2' .claude/skills/alex/SKILL.md` + `grep 'max 2' .claude/skills/blake/SKILL.md` | Both present |
| AC7 | Dedup | Blake step 1_5a action step 1 checks Domain Pack References before auto-detection | "skip auto-detection" path exists in 1_5a |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md) — SKILL.md 必须有 `name:` + `description:` YAML frontmatter 才能被 Claude Code 注册。install.sh 已处理此问题（CAPABILITY.md → SKILL.md 重命名保留 frontmatter），但 Blake 应验证。
- **Step Insertion Requires Predecessor Transition Arrow Audit** (architecture.md) — 在 Blake SKILL.md 插入 `1_5a` 时，需要确认 `1_5_context_refresh` 的结尾 transition arrow 指向新步骤，以及 `1_5a` 的结尾指向 `1_5b`。
- **Capability Pack: Design and Build Rules** (architecture.md) — CONSUMES/PRODUCES interface 是 pack 间协调的关键。step4_5 加载多个 pack 时要尊重 CONSUMES/PRODUCES 顺序。

---

## 10. Important Notes

### 10.1 ⚠️ CRITICAL
- install.sh 使用 CWD 检测 `.claude/`，sync step `b2` 必须 `cd` 到目标项目再运行
- `--force` flag 是必须的，否则已有 pack 会被跳过不更新
- Alex step4_5 是轻量级的（无 AskUserQuestion），不替代 step1_5b 的完整确认流程
- **Pack awareness 依赖 *sync 先跑过一次**。新注册的下游项目在首次 *sync (step b2) 之前，awareness scans 会静默找不到任何 pack。这是预期行为，不是 bug。
- install.sh 内部 `set -euo pipefail`，因此每个 pack 必须用独立 Bash 调用执行（详见 §4.1 step b2）
- *sync 中断后部分项目可能有不完整的 pack 安装。`--force` 保证重跑 *sync 可修复（幂等）

### 10.2 NOT in scope
- 不修改任何 pack 的 install.sh（它们已经工作正常）
- 不修改 CLAUDE.md（用户指定仅 TAD 流程内感知）
- 不修改 tad.sh（初始安装器的 pack 安装是未来增强）

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Pack installation strategy | Smart match / All install / User confirm | All install | 用户选择。8 个 pack 全装，简单可靠 |
| 2 | Awareness scope | All scenarios / TAD only / TAD + manual | TAD only | 用户选择。限制在 /alex + /blake 流程内 |
| 3 | Risk acceptance | Control limit / Try first | Try first | 先全装看效果，后续优化 |
| 4 | Alex insertion point | Per-path / Post-router | Post-router (step4_5) | 一处改动覆盖所有模式，DRY |
| 5 | Blake insertion point | Before context refresh / After | After (1_5a) | 需要 handoff 内容在 context 中才能匹配 |

---

## Required Evidence Manifest
```yaml
evidence_manifest:
  expert_reviews:
    - ".tad/evidence/reviews/blake/capability-pack-auto-awareness/code-reviewer.md"
  gate_verdicts:
    - ".tad/evidence/reviews/blake/capability-pack-auto-awareness/gate3-report.md"
  completion:
    - ".tad/active/handoffs/COMPLETION-20260514-capability-pack-auto-awareness.md"
  blake_reviews:
    - "Layer 2 code-reviewer"
  knowledge_updates:
    - "TBD (Gate 3 Knowledge Assessment)"
```
