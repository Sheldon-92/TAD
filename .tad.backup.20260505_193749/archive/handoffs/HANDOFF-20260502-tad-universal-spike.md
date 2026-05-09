---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 0 Spike — TAD Universal Method Protocol Concept Validation

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-05-02
**Priority:** P1
**Epic:** EPIC-20260502-tad-universal-method.md (Phase 0/5)

---

## 1. Task Overview

Validate that a single protocol.md file, read by any AI CLI tool, can guide the AI through:
1. **Init mode**: detect uninitialized state → enter Socratic role design conversation → write config
2. **Role derivation**: produce meaningful, project-specific Alex/Blake role definitions (not generic)
3. **Dual-terminal workflow**: two terminals, human bridge, structured handoff + self-check

This is a concept validation spike — hand-written files, no CLI tooling, no npm packaging. The spike creates a test project directory outside the TAD repo.

## 2. Background & Motivation

TAD Universal Method extracts TAD's core methodology into a platform-agnostic execution framework for non-developers. The hypothesis: a well-written protocol.md placed in any project can produce the same "think before act" discipline for any project type (video scripts, data analysis, academic writing, etc.).

**Key risk this spike addresses**: init 推导质量 — will AI produce specific, useful role definitions, or generic "planner/executor" labels?

## 3. Requirements

### FR1: Test Project Directory
Create `~/tad-universal-spike/` with the target file structure. This is OUTSIDE the TAD repo — simulates a real user's project.

### FR2: Core Protocol File (protocol.md)
Write `protocol.md` (~150-300 lines) containing 8 sections with these canonical headers:

1. **State Detection**: Read `.tad-lite/state.yaml`. If `initialized: false` → Init Mode. If `initialized: true` → Work Mode (load roles). If state.yaml missing or malformed → treat as `initialized: false`.

2. **Init Mode — Socratic Role Design**:
   - Step 1: Understand the project (ask: what, who, output form)
   - Step 2: Derive Alex role (name, responsibilities, skills, forbidden actions)
   - Step 3: Derive Blake role (same structure)
   - Step 4: Derive risks and quality standards (common failure modes, success criteria, checkpoints)
   - Step 5: Write roles to `.tad-lite/roles/alex.md` and `blake.md`, set `state.yaml` → `initialized: true`, instruct user to exit and re-enter

3. **Role Selection**: On Work Mode entry, AI asks user: "Which role should I take — Alex (planning) or Blake (execution)?" Then loads the corresponding role file from `roles/`. This is the simplest discrimination mechanism for the spike.

4. **Work Mode — Alex (Terminal 1)**: Load role from `roles/alex.md`. Alex plans, asks clarifying questions, creates handoff as a message in the conversation. Alex NEVER executes/produces the final deliverable. Human copies the handoff message to Blake's terminal.

5. **Work Mode — Blake (Terminal 2)**: Load role from `roles/blake.md`. Blake executes per handoff instructions. Blake self-checks against acceptance criteria before declaring done.

6. **Handoff Format**: Simple template — Task, Context, Acceptance Criteria, Key Constraints. Alex writes the handoff as a conversation message (NOT a file). Human copy-pastes it to Blake's terminal.

7. **Self-Check Protocol**: Blake must list each AC, mark pass/fail with evidence, then report back to user.

8. **Terminal Isolation Rules**: Separate terminals. Human is the only bridge. Neither agent calls the other.

### FR3: Domain Reference Templates
Include 3 domain examples INSIDE protocol.md (Init Mode section) as reference for AI:
- 视频制作: Alex=编导, Blake=脚本撰稿人
- 数据分析: Alex=研究设计者, Blake=数据分析师
- 内容营销: Alex=内容策略师, Blake=文案写手

These are reference examples, not rigid templates. AI should use them as inspiration when deriving roles for new project types.

### FR4: Platform Entry Files
- `AGENTS.md` (Codex entry): ~200-400 bytes. Instructions for Codex to read `.tad-lite/protocol.md` and follow it.
- `CLAUDE.md` (Claude Code entry): ~200-400 bytes. Same logic for Claude Code format.

### FR5: State Management
- `.tad-lite/state.yaml`: initial content `initialized: false`
- After init: `initialized: true` + roles written to `.tad-lite/roles/`

### FR6: Spike Validation Tests
Run 3 tests. All commands assume `cwd = ~/tad-universal-spike/`.

**Test 1 (Codex — Init + Role Derivation)**:
1. Ensure state.yaml = `initialized: false` and roles/ is empty
2. `codex`
3. Verify: AI enters init mode (detects uninitialized)
4. Tell AI: "这个项目是做一个 10 分钟的科普视频脚本，目标受众是 B 站 18-25 岁用户"
5. Verify: AI runs Socratic conversation, derives Alex and Blake roles
6. Verify: role content is project-specific (see AC11 rubric)
7. If Codex sandbox blocks file writes: record conversation quality separately, note platform limitation

**State Reset (between Test 1 and Test 2)**:
```bash
echo "initialized: false" > .tad-lite/state.yaml
rm -f .tad-lite/roles/alex.md .tad-lite/roles/blake.md
```

**Test 2 (Claude Code — Init + Role Derivation)**:
1. Ensure state.yaml = `initialized: false` and roles/ is empty (run reset above)
2. `claude`
3. Same verification steps as Test 1 (steps 3-6)
4. Exit, re-enter, verify: AI enters Work Mode and asks which role to adopt

**Test 3 (Dual-Terminal — either platform)**:
After a successful init on one platform:
1. Terminal 1: enter as Alex, give task "写第一集视频脚本的大纲"
2. Verify: Alex produces a handoff message with Task/Context/AC/Constraints
3. Human copies handoff message to Terminal 2
4. Terminal 2: enter as Blake, paste the handoff
5. Verify: Blake executes and produces a self-check report against AC
6. Qualitative note in SPIKE-RESULTS.md: was the flow natural or awkward?

Record all test results in `~/tad-universal-spike/SPIKE-RESULTS.md`.

## 4. Technical Design

### Directory Structure
```
~/tad-universal-spike/
├── AGENTS.md                    ← Codex 入口 (~300 bytes)
├── CLAUDE.md                    ← Claude Code 入口 (~300 bytes)
├── SPIKE-RESULTS.md             ← 测试结果记录 (Blake 写)
└── .tad-lite/
    ├── protocol.md              ← 核心协议 (~150-250 lines)
    ├── state.yaml               ← {initialized: false}
    └── roles/                   ← init 后写入 alex.md + blake.md
```

### protocol.md Key Design Decisions

1. **Language**: 中英混合。协议指令用英文（AI 理解更稳定），domain examples 用中文（目标用户场景）。
2. **Role template structure**: Each role file (alex.md / blake.md) should contain:
   - 角色名 + 一句话定义
   - 3-5 条核心职责
   - 2-3 条禁止行为
   - 适用的技能/知识领域
   - 该角色的质量检查标准
3. **Init conversation style**: Conversational, not form-filling. AI should ask open-ended questions and probe deeper, not just list checkboxes.
4. **Handoff format**: Keep it minimal for spike — 4 fields (Task, Context, AC, Constraints). Full TAD handoff template is too heavy for non-dev users.

## 5. Acceptance Criteria

All verification commands assume `cwd = ~/tad-universal-spike/`.

| AC | Description | Verification |
|----|-------------|-------------|
| AC1 | Directory created with correct structure (5 files + 2 dirs before testing) | `find ~/tad-universal-spike -type f \| wc -l` = 5; `find ~/tad-universal-spike -type d \| wc -l` ≥ 3 |
| AC2 | protocol.md exists, 150-300 lines, covers all 8 sections | `wc -l .tad-lite/protocol.md` + `grep -cE '^## [0-9]+\.' .tad-lite/protocol.md` ≥ 8 |
| AC3 | AGENTS.md exists, <500 bytes, references .tad-lite/protocol.md | `wc -c AGENTS.md` + `grep -q 'protocol.md' AGENTS.md` |
| AC4 | CLAUDE.md exists, <500 bytes, references .tad-lite/protocol.md | `wc -c CLAUDE.md` + `grep -q 'protocol.md' CLAUDE.md` |
| AC5 | state.yaml exists with `initialized: false` | `cat .tad-lite/state.yaml` |
| AC6 | 3 domain reference templates in protocol.md | `grep -cE '视频制作\|数据分析\|内容营销' .tad-lite/protocol.md` ≥ 3 |
| AC7 | Codex test: AI enters init conversation (concept validation) | SPIKE-RESULTS.md §Codex |
| AC8a | Codex test: AI derives meaningful role content in conversation | SPIKE-RESULTS.md §Codex (quality, even if files not written) |
| AC8b | Codex test: roles/ files written to disk (platform-conditional — may FAIL due to sandbox) | `ls .tad-lite/roles/` or "FAIL: sandbox" in SPIKE-RESULTS.md |
| AC9 | Claude Code test: AI enters init conversation | SPIKE-RESULTS.md §Claude |
| AC10 | Claude Code test: roles/ files created with project-specific content | file existence + content review |
| AC11 | Role derivation quality rubric (either platform) | SPIKE-RESULTS.md §Quality |
| AC12 | Dual-terminal test: Alex handoff → human relay → Blake executes + self-checks | SPIKE-RESULTS.md §Dual-Terminal |

### AC11 Quality Rubric (concrete checks)
Role derivation is "specific, not generic" when ALL of:
- Role name is NOT "Planner"/"Executor"/"规划者"/"执行者" (negative check)
- At least 1 responsibility references the specific domain (e.g., "B站" or "科普" or "视频" appears)
- Forbidden actions are domain-relevant (e.g., "不要使用超过大学本科水平的术语" for 科普)

## 6. Spike Verdict Criteria

| Axis | GO | PARTIAL | NO-GO |
|------|-----|---------|-------|
| Init Detection | Both platforms enter init mode | 1 platform works, 1 doesn't | Neither works |
| Role Derivation Quality | Roles are project-specific with meaningful skills/constraints | Roles are somewhat specific but missing key aspects | Generic "planner/executor" |
| Dual-Terminal Feasibility | Handoff format clear, human can relay | Format works but awkward | Format breaks or AI can't follow |

PARTIAL verdict acceptable — document which axes pass/fail with evidence.

## 7. Files to Create

| # | File | Action | Location |
|---|------|--------|----------|
| 1 | protocol.md | CREATE | ~/tad-universal-spike/.tad-lite/ |
| 2 | state.yaml | CREATE | ~/tad-universal-spike/.tad-lite/ |
| 3 | AGENTS.md | CREATE | ~/tad-universal-spike/ |
| 4 | CLAUDE.md | CREATE | ~/tad-universal-spike/ |
| 5 | roles/ | CREATE DIR | ~/tad-universal-spike/.tad-lite/ |
| 6 | SPIKE-RESULTS.md | CREATE | ~/tad-universal-spike/ |

**Grounded Against**: N/A — all files are new (CREATE), no existing files to ground against.

## 8. Important Notes

### 8.1 This is OUTSIDE the TAD repo
All files go to `~/tad-universal-spike/`, NOT to the TAD project directory. Do not modify any TAD files during this spike.

### 8.2 protocol.md is the product's heart
The quality of protocol.md determines the entire spike's success. Spend most effort here. Read it multiple times before testing.

### 8.3 Codex sandbox limitation
Codex with ChatGPT account has write restrictions (Phase 0 spike from Codex Epic discovered this). If Codex can't write roles/ files during init, that's an expected limitation — record it in SPIKE-RESULTS.md and test the init conversation quality separately.

### 8.4 Don't over-engineer
This is a concept validation. protocol.md should be readable, not comprehensive. If it works, Phase 1 will expand it properly.

### 8.5 Time budget
This spike has a **3-hour hard cap**. If either platform test is blocked by environmental issues after 30 minutes of troubleshooting, record the limitation in SPIKE-RESULTS.md and move on to the next test.

## 9. Spec Compliance Checklist

All commands assume `cwd = ~/tad-universal-spike/`.

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `find . -type f \| wc -l` | 5 |
| AC2 | `wc -l .tad-lite/protocol.md` + `grep -cE '^## [0-9]+\.' .tad-lite/protocol.md` | 150-300 lines; ≥8 sections |
| AC3 | `wc -c AGENTS.md` + `grep -q protocol.md AGENTS.md` | <500 bytes; exit 0 |
| AC4 | `wc -c CLAUDE.md` + `grep -q protocol.md CLAUDE.md` | <500 bytes; exit 0 |
| AC5 | `cat .tad-lite/state.yaml` | contains `initialized: false` |
| AC6 | `grep -cE '视频制作\|数据分析\|内容营销' .tad-lite/protocol.md` | ≥3 |
| AC7 | Codex live test | SPIKE-RESULTS.md §Codex — init conversation started |
| AC8a | Codex live test | SPIKE-RESULTS.md §Codex — role content quality (even if not written to disk) |
| AC8b | Codex live test | `ls .tad-lite/roles/` OR "sandbox limitation" in SPIKE-RESULTS.md |
| AC9 | Claude Code live test | SPIKE-RESULTS.md §Claude — init conversation started |
| AC10 | Claude Code live test | `ls .tad-lite/roles/` shows alex.md + blake.md |
| AC11 | Quality rubric check (§5) | SPIKE-RESULTS.md §Quality — all 3 rubric checks pass |
| AC12 | Dual-terminal live test | SPIKE-RESULTS.md §Dual-Terminal — handoff relayed, Blake self-checks |

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| backend-architect | P0-1: Work Mode can't distinguish Alex/Blake terminal | FR2 §3 Role Selection added — AI asks user which role | Resolved |
| backend-architect + code-reviewer | P0-2: AC6 grep pattern mismatch + BSD grep portability | Changed to `grep -cE '视频制作\|数据分析\|内容营销'` | Resolved |
| backend-architect | P0-3: No state reset between Test 1 and Test 2 | FR6 State Reset step added between tests | Resolved |
| code-reviewer | P0-2: AC2 missing verification command + canonical section names | FR2 changed to 8 numbered sections + `grep -cE '^## [0-9]+\.'` | Resolved |
| code-reviewer | P0-3: AC1 count arithmetic wrong | Replaced `ls -R` with `find -type f \| wc -l` = 5 | Resolved |
| code-reviewer | P0-4: Codex AC8 should split concept vs platform | AC8 split into AC8a (conversation quality) + AC8b (file write, platform-conditional) | Resolved |
| backend-architect + code-reviewer | P1: No AC for dual-terminal workflow | AC12 added + Test 3 added to FR6 | Resolved |
| code-reviewer | P1: No time cap | §8.5 time budget (3h hard cap) added | Resolved |
| backend-architect | P1: Handoff storage location ambiguous | FR2 §4 + §6 clarified: Alex writes handoff as conversation message, NOT file | Resolved |
| code-reviewer | P1: Section 9 paths relative without cwd note | Added "All commands assume cwd = ~/tad-universal-spike/" | Resolved |
| backend-architect | P1: Role template too prescriptive | Kept as-is — spike will test if AI naturally produces all 5 fields or skips optional ones | Deferred |

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

1. **Codex AGENTS.md Auto-Load Mirrors Claude Code CLAUDE.md (2026-05-02)** — architecture.md. Codex auto-loads AGENTS.md from project root. "Read file then follow protocol" reference pattern works. Verified via live test.

2. **Codex CLI TAD Feasibility (2026-05-01)** — architecture.md. ChatGPT-account Codex = permanent read-only sandbox. `codex exec resume --last` enables multi-turn. SKILL injection via stdin (76KB) works with gpt-5.5.

3. **`codex exec --full-auto` VALIDATED (2026-05-02)** — architecture.md. Sandbox allows writes to workdir. Pre-flight write test confirmed.

## 10. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Spike location | Inside TAD repo / Outside in new dir | Outside (`~/tad-universal-spike/`) | Simulates real user experience; no TAD contamination |
| 2 | protocol.md language | English only / Chinese only / Mixed | Mixed (instructions=EN, examples=ZH) | AI understands EN instructions better; ZH examples match target user scenarios |
| 3 | Domain templates count | 1 / 3 / 5-8 | 3 for spike | Enough to validate reference-aided derivation; more in Phase 2 |
| 4 | Handoff format complexity | Full TAD template / Minimal 4-field | Minimal 4-field | Non-dev users need simple format; expand in Phase 1 if needed |
| 5 | Role selection in Work Mode | Auto-detect / User tells AI / Separate entry files per role | AI asks user on entry | Simplest for spike; no extra files needed; user just says "Alex" or "Blake" |
