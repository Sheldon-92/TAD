---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/codex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Codex Phase 2 — Validate + Document

**From:** Alex | **To:** Blake | **Date:** 2026-05-02
**Project:** TAD Framework
**Task ID:** TASK-20260502-001
**Epic:** EPIC-20260427-codex-cli-adaptation.md (Phase 2/3 — FINAL)

---

## 🔴 Gate 2: ✅ PASS (CR CONDITIONAL PASS 2 P0 resolved + BA PASS 0 P0)

---

## 1. Task Overview

### 1.1 What We're Building
Epic 收尾：用 Codex adapter 跑一次真实 TAD 闭环（dogfood），然后写文档 + release prep。完成后触发 v2.9.0 发布。

### 1.2 Why
**业务价值**：完成后你说 "Claude Code 撞限额了" → 跑一行命令切换 Codex 继续干活，且有文档告诉你怎么操作。
**成功的样子**：INSTALLATION_GUIDE 有 Codex 章节，release-runbook 有 smoke test，README 有 banner，CHANGELOG 有 v2.9.0 entry。

---

## 📚 Project Knowledge

**⚠️ Blake 必须注意**:
1. **`codex exec --full-auto` Combination Unverified** (architecture.md:583) — Phase 2 第一件事验证此组合。如果失败，fallback 到 `codex exec "prompt"` 无 --full-auto。
2. **Codex-Edition SKILL Strip-Only Rule** (architecture.md:576) — dogfood 中如发现 SKILL 缺失内容，添加到 SOURCE 先，再重新派生 Codex-edition。

---

## 2. Implementation Steps

### Pre-flight: Validate `codex exec --full-auto` (5 min)

```bash
cd "/Users/sheldonzhao/01-on progress programs/TAD"
# Test 1: stdin pipe + --full-auto flag accepted
echo "Say hello" | codex exec --full-auto "respond with exactly: HELLO_CONFIRMED"
# Test 2: write permission (critical for Blake mode)
codex exec --full-auto "Create file /tmp/tad-preflight-write.txt with content WRITE_OK"
test -f /tmp/tad-preflight-write.txt && echo "WRITE_VALIDATED" || echo "WRITE_BLOCKED"
rm -f /tmp/tad-preflight-write.txt
```

- Test 1 PASS + Test 2 PASS → full-auto works with writes, proceed normally
- Test 1 PASS + Test 2 FAIL → stdin works but writes blocked (sandbox). Blake-Codex sessions use interactive mode (`codex` without `exec --full-auto`) for file operations
- Test 1 FAIL → remove `--full-auto`, use plain `codex exec`
- Record all results in DOGFOOD-REPORT.md §Pre-flight

---

### P2.1: Dogfood — Full Codex TAD Loop

**Task**: Implement hook timeout configuration (from IDEA-20260403-hook-timeout-config)
**Scope**: Add `timeout_seconds` field to TAD hook invocation patterns

**Dogfood steps** (Blake operates Codex through the full TAD loop):

**Step A — Alex-Codex session**:
```bash
bash .tad/codex/codex-tad-alex.sh
```
Inside Codex-Alex:
1. Present the hook-timeout-config requirement
2. Observe if Codex-Alex does Socratic inquiry (per socratic-fallback.md)
3. Observe if Codex-Alex drafts a handoff (per codex-alex-skill.md)
4. Save Codex-Alex output as evidence

**Step B — Blake-Codex session**:

First, save Step A's handoff output to a file:
```bash
# Save Alex-Codex's handoff draft output to evidence
# (copy from terminal or redirect during Step A)
cp <alex-session-output> .tad/evidence/dogfood/alex-handoff-draft.md
```

Then start Blake-Codex and point it to the handoff:
```bash
bash .tad/codex/codex-tad-blake.sh
# Once inside Codex-Blake, give it the task:
# "Read .tad/evidence/dogfood/alex-handoff-draft.md as your handoff. Execute it per Blake protocol."
```

Inside Codex-Blake:
1. Observe if Codex-Blake reads and paraphrases the handoff correctly
2. Observe if Codex-Blake follows Ralph Loop (per codex-blake-skill.md)
3. Observe if Codex-Blake produces completion report structure
4. Save Codex-Blake output as evidence to `.tad/evidence/dogfood/blake-session-output.md`

**Step C — Record friction points**:
- What worked smoothly?
- What required manual intervention?
- What documentation was missing/unclear?
- Did `codex exec --full-auto` work throughout?

**PASS criteria for dogfood**: Both sessions produce recognizable TAD-style output (Socratic questions, handoff structure, completion structure). Does NOT need to be a real implemented feature — we're testing the WORKFLOW, not the output quality.

**Evidence**: Save all session outputs to `.tad/evidence/dogfood/`

---

### P2.2: DOGFOOD-REPORT.md

Create `.tad/evidence/dogfood/DOGFOOD-20260502-codex-loop.md`:

```markdown
# Codex Dogfood Report
Date: 2026-05-02
Task: Hook Timeout Configuration (IDEA-20260403)

## Pre-flight
- `codex exec --full-auto` validated: {YES/NO}
- Model used: {gpt-5.5 or other}
- Fallback needed: {YES/NO}

## Alex-Codex Session
- Socratic inquiry: {worked / partial / failed}
- Handoff draft: {template-correct / partial / failed}
- Friction points: {list}
- Session duration: {time}

## Blake-Codex Session
- Handoff reading: {correct / partial / failed}
- Implementation attempt: {succeeded / blocked by sandbox / partial}
- Completion report: {produced / not produced}
- Friction points: {list}

## Overall Verdict
- Workflow continuity: {smooth / requires-manual-steps / broken}
- Documentation gaps found: {list — feed into P2.3/P2.4}
- P1 revisions needed: {list — if YES, stop P2.B and fix first}

## Pivot Decision
- P2.B ready: {YES / NO — needs P1 revision first}
```

---

### P2.3: INSTALLATION_GUIDE — "Codex CLI Setup" Chapter

Add a new section to `INSTALLATION_GUIDE.md` (after existing Claude Code setup section):

**Content to include**:
- Prerequisites: Codex CLI installed (`codex --version`), OpenAI auth configured
- Quick start: `bash .tad/codex/codex-tad-alex.sh` / `codex-tad-blake.sh`
- When to use Codex vs Claude Code (Claude Code is primary; Codex when quota-limited)
- Known limitations: read-only sandbox on ChatGPT accounts, no AskUserQuestion, sequential review
- Troubleshooting: common issues from dogfood experience

---

### P2.4: release-runbook — Codex Smoke Test

Add to `.claude/skills/release-runbook/SKILL.md` a new phase step:

```markdown
### Phase N: Codex Adapter Smoke Test (minor+ = HARD, patch = advisory)

1. Verify files exist:
   - `test -f .tad/codex/codex-tad-blake.sh && test -f .tad/codex/codex-tad-alex.sh`
   - `test -f .tad/codex/codex-blake-skill.md && test -f .tad/codex/codex-alex-skill.md`
   - `test -f .tad/portable-rules.md && test -f .tad/portable-extract.sh`
2. Verify launcher works: `bash .tad/codex/codex-tad-blake.sh --dry-run` (exit 0)
3. Verify SKILL constraint preservation:
   `grep -c 'MUST\|MANDATORY\|VIOLATION' .tad/codex/codex-blake-skill.md` ≥ 10
4. Verify portable-extract: `bash .tad/portable-extract.sh && test -d codex-tad-bundle`

Failure on minor+ release → BLOCK release (fix adapter first).
Failure on patch release → WARN only (adapter drift is acceptable for patches).
```

---

### P2.5: README Codex Banner

Add under "## Highlights" or similar section in README.md:

```markdown
### 🔄 Codex CLI Support (v2.9.0+)
Run TAD workflows on OpenAI Codex CLI when Claude Code quota is reached:
- `bash .tad/codex/codex-tad-alex.sh` — Start Alex (design) session
- `bash .tad/codex/codex-tad-blake.sh` — Start Blake (execution) session
- See INSTALLATION_GUIDE.md "Codex CLI Setup" for details
```

---

### P2.6: v2.9.0 Release Prep

1. CHANGELOG.md entry draft:
```markdown
## v2.9.0 — Codex CLI Support (2026-05-XX)
- **NEW**: Codex CLI adapter — run TAD workflows on OpenAI Codex when Claude Code quota limited
- **NEW**: Launcher scripts (codex-tad-blake.sh, codex-tad-alex.sh) — one-command Codex TAD sessions
- **NEW**: Static Codex-edition SKILL files (25KB Blake, 35KB Alex) — stripped Claude Code mechanisms, preserved all constraints
- **NEW**: Portable extraction system (portable-rules.md + portable-extract.sh)
- **NEW**: 4 operation guides: manual-gates, sequential-review, socratic-fallback, expert-review-sequential
- **PHASE 0**: 5/6 feasibility spike PASS (Blake 2/3, Alex 3/3)
- **NOTE**: ChatGPT account sandbox is read-only; use interactive mode for Blake file writes
```

2. Version bump checklist addition: Add `.tad/codex/codex-blake-skill.md` and `codex-alex-skill.md` header version fields to the release-runbook version bump file list (if they contain version references).

---

## 3. Acceptance Criteria

| AC# | Requirement | Verification |
|-----|-------------|-------------|
| AC1 | Pre-flight validation done | DOGFOOD-REPORT §Pre-flight filled |
| AC2 | Dogfood loop attempted | DOGFOOD-REPORT §Alex-Codex + §Blake-Codex filled |
| AC3 | DOGFOOD-REPORT.md exists | `test -f .tad/evidence/dogfood/DOGFOOD-20260502-codex-loop.md` |
| AC4 | INSTALLATION_GUIDE has Codex section | `grep -c 'Codex CLI Setup' INSTALLATION_GUIDE.md` ≥ 1 |
| AC5 | release-runbook has smoke test | `grep -c 'Codex Adapter Smoke Test' .claude/skills/release-runbook/SKILL.md` ≥ 1 |
| AC6 | README has Codex banner | `grep -c 'Codex CLI Support' README.md` ≥ 1 |
| AC7 | CHANGELOG has v2.9.0 entry | `grep -c 'v2.9.0' CHANGELOG.md` ≥ 1 |
| AC8 | Completion report | COMPLETION file exists |

---

## 4. Important Notes

- If dogfood reveals P1 files need revision → FIX FIRST, then continue P2.B documentation
- Dogfood doesn't need to produce a real implemented feature — we're validating the WORKFLOW
- v2.9.0 release is triggered by this Epic completing, not by this handoff alone

---

## Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/codex-phase2-validate/code-reviewer.md
    - .tad/evidence/reviews/blake/codex-phase2-validate/backend-architect.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260502-codex-phase2-validate.md
  dogfood:
    - .tad/evidence/dogfood/DOGFOOD-20260502-codex-loop.md
  knowledge_updates:
    - .tad/project-knowledge/architecture.md (if dogfood reveals new findings)
```
