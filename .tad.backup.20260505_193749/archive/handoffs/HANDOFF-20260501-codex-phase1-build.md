---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/codex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-01
**Project:** TAD Framework
**Task ID:** TASK-20260501-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260427-codex-cli-adaptation.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-01 (pending expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 8 deliverables defined, spike-informed design |
| Components Specified | ✅ | Each file has purpose + content spec |
| Functions Verified | ✅ | Existing SKILL files verified (blake 1529L, alex 4089L) |
| Data Flow Mapped | ✅ | SKILL → launcher → stdin pipe → Codex |

**Gate 2 结果**: ✅ PASS (expert review complete — 9 P0 across 2 reviewers, all resolved)

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了 Codex-edition SKILL 的剥除规则（§4.1）
- [ ] 理解了 launcher 脚本的 stdin 注入机制
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Codex CLI 的 TAD adapter 层：2 个 launcher 脚本 + 精简版 SKILL 自动生成 + 4 个操作手册 + 1 个 portable 元数据体系。让用户能在 Claude Code 限额撞顶时切换到 Codex 继续 TAD 工作流。

### 1.2 Why We're Building It
**业务价值**：Claude Code 周限额是硬顶，撞顶后 1-3 天无法做事——Codex adapter 是你的备用通道
**用户受益**：`bash .tad/codex/codex-tad-alex.sh` 一键启动 Codex Alex 模式，无需记任何 Codex CLI 语法
**成功的样子**：当用户跑 launcher 脚本时，Codex 启动并正确展现 TAD agent persona

### 1.3 Intent Statement

**真正要解决的问题**：把 Phase 0 spike 验证的"Codex 能跑 TAD"从手动操作转化为可重复使用的工具集。

**不是要做的**：
- ❌ 不是让 Codex = Claude Code（接受机制差异）
- ❌ 不是修改现有 SKILL 文件（只读取+剥除+生成新文件）
- ❌ 不是自动化 hook 触发（Codex 上手动调用 bash 脚本）

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture — Codex spike 发现 + SKILL 精简教训

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 2 条 | Codex spike 发现 + SKILL 精简教训 |

**⚠️ Blake 必须注意的历史教训**：

1. **Codex CLI TAD Feasibility: Platform Constraints and Capability Map** (来自 architecture.md, 2026-05-01)
   - 要点：ChatGPT 账户 sandbox 永久 read-only；gpt-5.5 是默认模型；`codex exec resume --last` 支持多轮；SKILL stdin 注入 76KB 可行
   - 应用：launcher 脚本必须用 gpt-5.5，不能指定 o4-mini；multi-turn 用 resume 机制

2. **Judgment-Only Skill Files: 76% Reduction Was NOT Safe — AMENDED** (来自 architecture.md, 2026-04-04)
   - 要点：v2.7 精简 SKILL 时误删了 constraint rules（MUST/MANDATORY/VIOLATION），导致质量链失效
   - 应用：Codex-edition SKILL 剥除只针对**不可用机制**（hooks/AskUserQuestion/Agent tool），**绝对不能删除 constraint rules**

---

## 2. Background Context

### 2.1 Previous Work
- Phase 0 Spike (2026-05-01): 5/6 PASS, CONTINUE. Blake-axis 2/3 PARTIAL GO, Alex-axis 3/3 GO.
- Evidence: `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/`

### 2.2 Current State
- Codex CLI v0.125.0 installed, gpt-5.5 default
- No `.tad/codex/` directory yet
- SKILL files: blake 1529 lines, alex 4089 lines
- Existing `~/.codex/prompts/tad_blake.md` (spike artifact, will be superseded)

### 2.3 Dependencies
- `.claude/skills/blake/SKILL.md` — source for Codex-edition Blake SKILL
- `.claude/skills/alex/SKILL.md` — source for Codex-edition Alex SKILL
- `.tad/hooks/lib/*.sh` — bash scripts referenced in manual-gates.md (remain as-is)

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: `bash .tad/codex/codex-tad-blake.sh` launches Codex with Blake persona and TAD SKILL
- FR2: `bash .tad/codex/codex-tad-alex.sh` launches Codex with Alex persona and TAD SKILL
- FR3: Codex-edition SKILLs strip non-applicable mechanisms, preserve all constraint rules
- FR4: Manual operation guides replace Claude Code automatic mechanisms (hooks → manual bash, AskUserQuestion → text options, Agent → sequential sessions)
- FR5: `bash .tad/portable-extract.sh` produces a self-contained codex-tad-bundle/ directory

### 3.2 Non-Functional Requirements
- NFR1: Launcher scripts must work on macOS (zsh default) and Linux (bash)
- NFR2: Codex-edition Blake SKILL ≤40KB; Codex-edition Alex SKILL ≤100KB (token cost vs protocol preservation balance; 50KB for Alex is unrealistic without deleting protocol logic per v2.7 lesson)
- NFR3: Manual guides must be self-contained (user doesn't need to read Claude Code docs)

---

## 4. Technical Design

### 4.1 Codex-Edition SKILL Extraction Rules

**Strip (Claude Code 专属机制 — Codex 上不可用)**:
- `AskUserQuestion` tool calls → replace with: "List options as numbered text. User types number or free text to respond."
- `Agent` tool / sub-agent parallel spawning → replace with: "Run separate `codex exec` sessions sequentially for each reviewer."
- `EnterPlanMode` → already forbidden in TAD
- Hook references (`PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, `settings.json`) → replace with: "Run bash script manually when needed: `bash .tad/hooks/lib/{script}.sh`"
- `Skill` tool / `/command` syntax → replace with: "Read the relevant SKILL file and follow its protocol"
- `ToolSearch`, `Monitor`, `SendMessage` tool references → remove

**Preserve (platform-independent TAD logic)**:
- All constraint rules containing MUST/MANDATORY/VIOLATION/forbidden/BLOCKING
- Ralph Loop protocol (Layer 1 self-check + Layer 2 expert review)
- Gate 3 v2 checklist structure
- Evidence directory structure and slug contract
- Knowledge Assessment protocol
- Completion report protocol
- Handoff reading and paraphrasing protocol
- `anti_rationalization_registry` (all 5 AR entries)
- `honest_partial_protocol`
- All forbidden_implementations lists (even if they reference hooks — the constraint text itself is the guardrail)

**Transform (mechanism changes)**:
- "Use AskUserQuestion" → "Present options as numbered list, ask user to type number"
- "Call Agent with subagent_type=code-reviewer" → "Start new `codex exec` session with reviewer system prompt"
- "Run in background" → "Run sequentially (Codex has no background agents)"
- Blake session_state_protocol → keep file format, strip hook auto-update (user runs manually or launcher appends)

### 4.2 Launcher Script Architecture (REVISED per BA-P0-2)

**Architecture decision: Static pre-generated SKILL files, NOT runtime sed/awk extraction.**

Rationale: Alex SKILL is 192KB (4089 lines). Runtime sed/awk extraction to strip ~75% while preserving structural integrity is the same failure mode as v2.7 "76% reduction was NOT safe" (architecture.md, 2026-04-04). A sed/awk pipeline cannot distinguish "verbose example" from "load-bearing constraint" — only human judgment can.

**Approach**:
- Blake manually authors `.tad/codex/codex-blake-skill.md` and `.tad/codex/codex-alex-skill.md` using §4.1 rules
- These are **static derived files**, reviewed at creation time, updated when source SKILLs change
- Launcher scripts simply `cat` the static file + pipe to Codex — no extraction logic

```
codex-tad-blake.sh:
  1. cd to project root (detect via .tad/ marker)
  2. Pre-flight write test: touch /tmp/.tad-write-test && rm /tmp/.tad-write-test
     If fails → warn "⚠️ Codex sandbox may be read-only. Blake file-write ops will fail.
                       Use: codex (interactive, no --full-auto) to approve writes manually."
  3. Default launch (spike-proven pattern — uses `exec` subcommand):
       cat .tad/codex/codex-blake-skill.md | codex exec --full-auto \
         "You are Blake (Execution Master). Follow the TAD protocol above. Check .tad/active/handoffs/ for pending work."
  4. Alternative launch for file-write tasks (interactive mode, user approves each write):
       cat .tad/codex/codex-blake-skill.md | codex \
         "You are Blake (Execution Master). Follow the TAD protocol above. Check .tad/active/handoffs/ for pending work."
  5. Support flags: --dry-run (print SKILL path + size, exit) | --extract-only (cat SKILL to stdout, exit)

codex-tad-alex.sh:
  Same pattern, using codex-alex-skill.md.
  Alex is read-only (no file writes needed) → always use `codex exec --full-auto`.
```

**⚠️ `codex exec` vs `codex` (interactive)**:
- Spike validated `codex exec` (non-interactive). This is the default.
- `codex` (interactive TUI) is offered as alternative for write operations only.
- Do NOT use `codex --full-auto` without `exec` — stdin pipe behavior undocumented in interactive mode.

**When source SKILL changes**: Update the Codex-edition file manually. The release-runbook smoke test (Phase 2) will catch drift.

### 4.3 File Map

```
.tad/codex/                          # NEW directory
├── codex-tad-blake.sh               # P1.3 - Blake launcher
├── codex-tad-alex.sh                # P1.6 - Alex launcher
├── codex-blake-skill.md             # P1.3b - Static Codex-edition Blake SKILL
├── codex-alex-skill.md              # P1.6b - Static Codex-edition Alex SKILL
├── manual-gates.md                  # P1.4 - Gate 3 manual steps
├── sequential-review.md             # P1.5 - Layer 2 sequential review guide
├── socratic-fallback.md             # P1.7 - Socratic without AskUserQuestion
├── expert-review-sequential.md      # P1.8 - Alex expert review guide
└── README.md                        # Quick start guide

.tad/portable-rules.md              # P1.1 - Metadata marking rules
.tad/portable-extract.sh            # P1.2 - Export helper
```

---

## 5. Not In Scope
- ❌ P1.9 (codex-completion-variant.md) — eliminated per P0.4 result (100% template alignment)
- ❌ Modifying existing SKILL files — only read + extract + generate new
- ❌ Codex MCP integration — deferred per Epic decision
- ❌ Automatic hook equivalents — Codex uses manual bash invocation

---

## 6. Implementation Steps

### Task P1.1: Portable Metadata Rules

**目标**: 定义哪些 TAD 文件/section 是 portable vs claude-code-only

**执行步骤**:
1. Create `.tad/portable-rules.md` with classification table:

| Category | Files | Classification | Rationale |
|----------|-------|---------------|-----------|
| SKILL files | .claude/skills/*/SKILL.md | Transform | Strip CC-only tools, keep protocol |
| Config | .tad/config*.yaml | Portable | Pure YAML config, platform-independent |
| Templates | .tad/templates/*.md | Portable | Markdown templates, no tool dependency |
| Hooks lib | .tad/hooks/lib/*.sh | Portable | Bash scripts, run manually on Codex |
| Hooks root | .tad/hooks/*.sh (root-level) | CC-only | Auto-triggered by Claude Code settings.json |
| Domains | .tad/domains/*.yaml | Portable | Knowledge files, no tool dependency |
| Evidence | .tad/evidence/ | Portable | File structure, no tool dependency |
| Settings | .claude/settings.json | CC-only | Claude Code hook registration |

2. Document the transform rules for SKILL files (reference §4.1 above)

---

### Task P1.2: Portable Extract Script

**目标**: 写 `bash .tad/portable-extract.sh` 导出可移植文件子集

**执行步骤**:
1. Create `.tad/portable-extract.sh`
2. Script reads `.tad/portable-rules.md` classification (or hardcoded list matching the rules)
3. Copies portable + transform files to `codex-tad-bundle/` output directory
4. For "Transform" files: runs the SKILL extraction (same logic as launcher scripts)
5. Outputs: `codex-tad-bundle/` with all files needed for Codex TAD

**验证**: `bash .tad/portable-extract.sh && ls codex-tad-bundle/`

---

### Task P1.3: Blake Launcher Script + Codex-Edition Blake SKILL

**目标**: 一键启动 Codex Blake 模式 + 预生成静态 Codex-edition SKILL

**P1.3a: 创建静态 Codex-edition Blake SKILL** (`.tad/codex/codex-blake-skill.md`)

手动从 `.claude/skills/blake/SKILL.md` (1529 lines) 创建精简版：

**剥除清单** (按 section/key 定位，不用行号):
- `develop_command` 中的 `AskUserQuestion` 调用 (2 instances: STEP 3.6 role confirmation + worktree finish prompt) → 替换为 "List options as numbered text"
- `forbidden` 列表中的 `EnterPlanMode` 条目 → 保留禁止文本，删除 Claude Code 解释
- `session_state_protocol` 中的 hook auto-update 段 → 替换为 "Run manually or launcher appends"
- 所有 `PreToolUse` / `PostToolUse` / `settings.json` 引用 → "Run bash script manually: `bash .tad/hooks/lib/{script}.sh`"
- `Agent` tool / sub-agent parallel spawning → "Run in separate `codex exec` session"
- `ToolSearch` / `Monitor` / `SendMessage` 工具引用 → 删除

**⚠️ 绝不剥除**: constraint rules (MUST/MANDATORY/VIOLATION), anti_rationalization_registry, honest_partial_protocol, forbidden_implementations lists, Ralph Loop protocol logic, Gate 3 v2 checklist, evidence slug contract

**P1.3b: 创建 Blake launcher 脚本** (`.tad/codex/codex-tad-blake.sh`)

```bash
#!/usr/bin/env bash
# 1. Detect project root
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# 2. Pre-flight write test
if ! touch /tmp/.tad-write-test 2>/dev/null; then
  echo "⚠️  Codex sandbox may be read-only. Use interactive mode (no --full-auto) for file writes."
fi
rm -f /tmp/.tad-write-test
# 3. Launch Codex with static SKILL
cat "$ROOT/.tad/codex/codex-blake-skill.md" | codex --full-auto \
  "You are Blake (Execution Master). Follow the TAD protocol above. Check .tad/active/handoffs/ for pending work."
```

支持 `--dry-run` flag: 只输出 SKILL 文件路径 + 大小，不启动 Codex。
支持 `--extract-only` flag: 输出 SKILL 内容到 stdout，不启动 Codex。
Make executable: `chmod +x`

---

### Task P1.4: Manual Gates Guide

**目标**: Blake 在 Codex 上手动跑 Gate 3 各 step 的指令清单

**内容**:
```markdown
# Codex Manual Gates Guide

## Gate 3 v2 — Manual Steps (replaces Claude Code auto-hooks)

### Layer 1: Self-Check
1. Build/test: `npm test` / `pytest` / appropriate build command
2. Lint: `npm run lint` / `eslint` / appropriate linter
3. Git tracked dirs check: `bash .tad/hooks/lib/gate3-git-tracked-check.sh <handoff-path>`

### Layer 2: Expert Review
Run TWO separate codex sessions (see sequential-review.md):
1. Session 1: code-reviewer
2. Session 2: backend-architect (or domain expert)
Save outputs to `.tad/evidence/reviews/blake/<slug>/`

### Layer 2 Audit (self-check)
After saving reviews: `bash .tad/hooks/lib/layer2-audit.sh <slug>`
Exit 0 = PASS. Exit 1 = missing reviewer artifacts.

### Evidence Collection
List all required evidence files: `ls -la .tad/evidence/reviews/blake/<slug>/`

### Drift Check (optional)
`bash .tad/hooks/lib/drift-check.sh <slug>`

### Stale Knowledge Check (optional)
`bash .tad/hooks/lib/stale-knowledge-check.sh --json`
```

---

### Task P1.5: Sequential Review Guide

**目标**: Codex 上 Layer 2 顺序 review 操作手册

**内容要点**:
- Step 1: Start code-reviewer session: `codex exec "You are a senior code reviewer. Review the following changes: [paste diff or file list]. Output P0/P1/P2 findings."`
- Step 2: Save output to `.tad/evidence/reviews/blake/<slug>/code-reviewer.md`
- Step 3: Start second reviewer session: `codex exec "You are a backend architect. Review..."`
- Step 4: Save to `.tad/evidence/reviews/blake/<slug>/backend-architect.md`
- Method B (independent sessions) for genuine review independence
- Include example prompts for each reviewer type

---

### Task P1.6: Alex Launcher Script + Codex-Edition Alex SKILL

**目标**: 一键启动 Codex Alex 模式 + 预生成静态 Codex-edition SKILL

**P1.6a: 创建静态 Codex-edition Alex SKILL** (`.tad/codex/codex-alex-skill.md`)

手动从 `.claude/skills/alex/SKILL.md` (4089 lines, ~192KB) 创建精简版。
Alex SKILL 远大于 Blake，精简难度更高。

**剥除清单** (按 section/key 定位):
- `AskUserQuestion` 调用 (~58 instances across all protocols) → 全部替换为 "Present options as numbered list, ask user to type number or free text"
- `Agent` tool / sub-agent shortcuts (*product, *architect, *ux 等) → "Start new `codex exec` session with corresponding persona prompt"
- `step3_agent_team` (Agent Team experimental review) → 整段删除（Codex 无 Agent Teams）
- `ToolSearch` / `Monitor` / `SendMessage` 引用 → 删除
- Hook references (`PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, `settings.json`) → "Run bash script manually"
- `Skill` tool / `/command` 引用 → "Read the relevant file and follow its protocol"
- 大段重复的 `example` / `format` blocks 如果与 config YAML 定义一致 → 精简为"see config-workflow.yaml"引用
- `playground_reference` → 保留（standalone command, 基于文件输出）

**⚠️ 绝不剥除** (same list as P1.3a):
- All constraint rules (MUST/MANDATORY/VIOLATION/forbidden/BLOCKING)
- anti_rationalization_registry (all 5 AR entries — byte-exact preserve)
- Socratic inquiry protocol 核心逻辑 (question dimensions, complexity detection)
- Adaptive complexity protocol
- Intent router protocol 路由逻辑
- Handoff creation protocol 核心步骤 (step0-step7)
- Acceptance protocol
- All path_transitions / forbidden rules
- Gate 4 v2 checklist

**目标大小**: ≤100KB（比原始 192KB 减半；50KB 不现实——需要删除协议逻辑才能达到，与 v2.7 教训冲突）

**P1.6b: 创建 Alex launcher 脚本** (`.tad/codex/codex-tad-alex.sh`)
Same pattern as P1.3b but using `codex-alex-skill.md`. Include `--dry-run` and `--extract-only` flags.

---

### Task P1.7: Socratic Fallback Guide

**目标**: 替代 AskUserQuestion 结构化提问的自由对话方案

**内容要点**:
- How to present options: "I have 3 approaches:\n1. ...\n2. ...\n3. ...\nWhich do you prefer? (type number or describe your preference)"
- Socratic inquiry flow: 2-3 rounds of questions → user text response → follow-up
- Multi-turn via `codex exec resume --last` (documented pattern from spike)
- Example: Full Socratic dialog script for a sample feature request

---

### Task P1.8: Expert Review Sequential Guide (Alex-side)

**目标**: Alex 在 Codex 上跑 expert review 的操作手册

**内容要点**:
- Same as P1.5 but from Alex's perspective (pre-handoff review)
- Step 1: Draft handoff
- Step 2: Start code-reviewer session with handoff draft as input
- Step 3: Start second expert session
- Step 4: Integrate feedback into handoff
- Include expert prompt templates matching Alex SKILL's `expert_prompt_template`

---

## 7. Files to Create

| File | Lines (est) | Purpose |
|------|-------------|---------|
| `.tad/portable-rules.md` | ~60 | Metadata classification table |
| `.tad/portable-extract.sh` | ~80 | Export helper script (copies static files, no extraction) |
| `.tad/codex/codex-tad-blake.sh` | ~40 | Blake launcher (cats static SKILL + launches Codex) |
| `.tad/codex/codex-tad-alex.sh` | ~40 | Alex launcher |
| `.tad/codex/codex-blake-skill.md` | ~800 | **Static** Codex-edition Blake SKILL (hand-authored from source) |
| `.tad/codex/codex-alex-skill.md` | ~2000 | **Static** Codex-edition Alex SKILL (hand-authored from source) |
| `.tad/codex/manual-gates.md` | ~80 | Gate 3 manual steps |
| `.tad/codex/sequential-review.md` | ~60 | Layer 2 review guide |
| `.tad/codex/socratic-fallback.md` | ~50 | Socratic dialog guide |
| `.tad/codex/expert-review-sequential.md` | ~50 | Alex expert review guide |
| `.tad/codex/README.md` | ~30 | Quick start + troubleshooting |

Also add to project `.gitignore`: `codex-tad-bundle/` (portable-extract.sh output)

**Grounded Against** (Alex step1c):
- `.claude/skills/blake/SKILL.md` (head 50, 1529 lines — source for P1.3)
- `.claude/skills/alex/SKILL.md` (head 50, 4089 lines — source for P1.6)
- `.tad/hooks/lib/` (exists — bash scripts referenced in P1.4)
- `.tad/codex/` (NOT EXISTS — to be created)
- `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` (spike context)

---

## 8. Testing Checklist

- [ ] `bash .tad/codex/codex-tad-blake.sh` starts Codex and Blake persona is active
- [ ] `bash .tad/codex/codex-tad-alex.sh` starts Codex and Alex persona is active
- [ ] Generated Codex-edition SKILL contains no `AskUserQuestion` references
- [ ] Generated Codex-edition SKILL preserves all MUST/MANDATORY/VIOLATION constraints
- [ ] `bash .tad/portable-extract.sh` produces codex-tad-bundle/ with expected files
- [ ] All 4 markdown guides are self-contained and actionable

---

## 9. Acceptance Criteria

| AC# | Requirement | Verification |
|-----|-------------|-------------|
| AC1 | `.tad/codex/` directory exists with 9 files | `ls .tad/codex/ \| wc -l` ≥ 9 |
| AC2 | Blake launcher --dry-run works | `bash .tad/codex/codex-tad-blake.sh --dry-run` exits 0 + prints SKILL path |
| AC3 | Alex launcher --dry-run works | `bash .tad/codex/codex-tad-alex.sh --dry-run` exits 0 + prints SKILL path |
| AC4 | No AskUserQuestion in static Blake SKILL | `grep -c AskUserQuestion .tad/codex/codex-blake-skill.md` = 0 |
| AC5 | Constraints preserved in static Blake SKILL | `grep -c 'MUST\|MANDATORY\|VIOLATION' .tad/codex/codex-blake-skill.md` ≥ 10 |
| AC5b | Constraints preserved in static Alex SKILL | `grep -c 'MUST\|MANDATORY\|VIOLATION' .tad/codex/codex-alex-skill.md` ≥ 20 |
| AC6 | portable-extract.sh produces output | `bash .tad/portable-extract.sh && test -d codex-tad-bundle` |
| AC7 | portable-rules.md has classification table | `grep -c 'Portable\|CC-only\|Transform' .tad/portable-rules.md` ≥ 5 |
| AC8 | manual-gates.md references key scripts | `grep -c 'layer2-audit\|drift-check' .tad/codex/manual-gates.md` ≥ 2 |
| AC9 | Blake SKILL size ≤ 40KB | `wc -c < .tad/codex/codex-blake-skill.md` ≤ 40960 |
| AC10 | Alex SKILL size ≤ 100KB | `wc -c < .tad/codex/codex-alex-skill.md` ≤ 102400 |
| AC11 | Completion report written | `.tad/active/handoffs/COMPLETION-20260501-codex-phase1-build.md` exists |
| AC12 | codex-tad-bundle/ in .gitignore | `grep -c codex-tad-bundle .gitignore` ≥ 1 |

### 9.1 Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|-----|--------------------|--------------------|-------------------------------|
| AC1 | `ls .tad/codex/ \| wc -l` | ≥9 | (post-impl) |
| AC4 | `grep -c AskUserQuestion .tad/codex/codex-blake-skill.md` | 0 | (post-impl — syntax-validated) |
| AC5 | `grep -c 'MUST\|MANDATORY\|VIOLATION' .tad/codex/codex-blake-skill.md` | ≥10 | (post-impl — syntax-validated) |
| AC7 | `grep -c 'Portable\|CC-only\|Transform' .tad/portable-rules.md` | ≥5 | (post-impl — syntax-validated) |
| AC9 | `wc -c < .tad/codex/codex-blake-skill.md` | ≤40960 | (post-impl) |
| AC10 | `wc -c < .tad/codex/codex-alex-skill.md` | ≤102400 | (post-impl) |

**AC Dry-Run Log** (Alex step1d at 2026-05-01):
- AC1-AC11: ✅ post-impl-verifiable, verification commands syntax-validated, deferred to Gate 3

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | BA-P0-1: Read-only sandbox not addressed | §4.2 (pre-flight write test + interactive mode alternative) | Resolved |
| backend-architect | BA-P0-2: Runtime sed/awk extraction unsound | §4.2 (switched to static pre-generated SKILL files) | Resolved |
| backend-architect | BA-P0-3: Line number references will break | §6 P1.3a (section/key references, no line numbers) | Resolved |
| backend-architect | BA-P0-4: `instructions_file` flag unverified | §4.2 (removed, only spike-proven patterns) | Resolved |
| code-reviewer | CR-P0-1: NFR2 50KB impossible | §3.2 NFR2 (revised to Blake ≤40KB, Alex ≤100KB) | Resolved |
| code-reviewer | CR-P0-2: Sandbox blocker unaddressed | §4.2 (same fix as BA-P0-1) | Resolved |
| code-reviewer | CR-P0-3: Interactive mode not spike-proven | §4.2 (default to `codex exec --full-auto`, interactive as write-only alt) | Resolved |
| code-reviewer | CR-P0-4: AskUserQuestion count wrong (3→2) | §6 P1.3a (section/key refs, correct count) | Resolved |
| code-reviewer | CR-P0-5: --extract-only undefined + temp file | §6 P1.3b + §9 ACs (static files, no temp; flags defined) | Resolved |
| backend-architect | BA-P1-1: portable-extract.sh contract ambiguous | Acknowledged — script is source of truth, rules.md is docs | Open (P1) |
| backend-architect | BA-P1-4: 4 guides have content overlap | Acknowledged — keep separate for clarity; consolidate in Phase 2 if needed | Deferred |
| code-reviewer | CR-P1-3: codex-tad-bundle/ not in .gitignore | AC12 added | Resolved |
| code-reviewer | CR-P1-5: §10.3 marks untested patterns | Acknowledged — §4.2 clarifies exec vs interactive | Resolved |

---

## 10. Important Notes

### 10.1 SKILL Extraction Safety
- **NEVER delete lines containing**: MUST, MANDATORY, VIOLATION, forbidden, BLOCKING, anti_rationalization, honest_partial
- When in doubt, keep the line — over-inclusion is safer than under-inclusion
- Test by grepping the output for constraint keywords (AC5)

### 10.2 Launcher Script Portability
- Use `#!/usr/bin/env bash` shebang
- Avoid bashisms that break on sh (no `[[ ]]`, use `[ ]`)
- Use `mktemp` for temp files if available, fallback to `/tmp/tad-*-$$`

### 10.3 Codex CLI Verified Syntax (from Phase 0 spike)
- Interactive: `codex --full-auto`
- Non-interactive: `codex exec "prompt"`
- Multi-turn resume: `codex exec resume --last "next prompt"`
- Model: gpt-5.5 (default, do NOT override)
- Working dir: must be project root (where `.tad/` exists)
- Stdin injection: `cat file.md | codex --full-auto "prompt"` works (76KB tested)

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | SKILL strategy | Full / Minimal / Strip-only-unavailable | Strip-only-unavailable | Preserves all protocol logic; v2.7 lesson: stripping constraints = quality chain failure |
| 2 | P1.9 | Include / Eliminate | Eliminate | P0.4 showed 100% template alignment — no variant needed |
| 3 | Launcher mechanism | stdin pipe / instruction file / AGENTS.md | stdin pipe | Verified in spike; most portable; no config changes needed |

---

## Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/codex-phase1-build/code-reviewer.md
    - .tad/evidence/reviews/blake/codex-phase1-build/backend-architect.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260501-codex-phase1-build.md
  blake_reviews:
    - .tad/evidence/reviews/blake/codex-phase1-build/self-review.md
  knowledge_updates:
    - .tad/project-knowledge/architecture.md (if discoveries warrant)
```
