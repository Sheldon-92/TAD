---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: Auto-Evolve Phase 3 — Dream Upgrade

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-19
**Project:** TAD
**Task ID:** TASK-20260519-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260518-auto-evolve.md (Phase 3/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-19

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Scanner (grep/jq double-parse) → candidates (timestamp-named) → STEP 3.56 display → user approve → project-knowledge. Rotation-safe (reads archive/ too). |
| Components Specified | ✅ | dream-scanner.sh (4 passes), dream-state.yaml, STEP 3.56, step0_auto, candidate format, test fixtures |
| Functions Verified | ✅ | record_trace (common.sh), trace-writer.sh helpers (Phase 1), dream-validator.sh (existing) |
| Data Flow Mapped | ✅ | JSONL (active+archive) → scanner → CAND-*.md → STEP 3.56 → project-knowledge/ |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 6 P0 + 5 P1 all resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
将 `*dream` 从"手动格式整合"升级为 Anthropic Dreaming 风格的"自动知识提取"。三个核心子功能：

1. **Auto-trigger** — `/schedule` cron 每日扫描 trace JSONL + SessionStart STEP 展示待处理 candidates
2. **Session log scanner** — grep trace 数据中的用户修正、重复失败、反思诊断（Phase 2 数据），提取模式
3. **Candidate playbook** — 结构化提案（含 provenance + confidence + scope_tag），人类审批后才写入 project-knowledge

### 1.2 Why We're Building It
**业务价值**: Phase 1 装了黑匣子（decision-level trace），Phase 2 让 Blake 学会反思。但这些数据目前只是躺在 JSONL 文件里没人看。Phase 3 让 TAD 自动从这些数据中"做梦"——提取规律、发现重复问题、生成改进建议。用户不需要记着跑 `*dream`，下次打开 Alex 就能看到"上次的 session 发现了 3 个值得记录的模式"。

**用户受益**: 打开 Alex → "你有 2 个 knowledge candidates 等待审批" → 看一眼 → 批准/拒绝 → 知识自动积累。

### 1.3 Intent Statement
**真正要解决的问题**: TAD 从"有记忆但不会反思"升级为"自动反思 + 人类审批"。

**不是要做的**:
- ❌ 不改变现有 `*dream` 的格式整合功能（dedup/merge/prune 保留为 sub-mode）
- ❌ 不自动应用 candidates 到 project-knowledge（人类审批是硬门槛）
- ❌ 不做跨项目聚合（那是 Phase 4）
- ❌ 不做 org-store 概念（Phase 4 范畴）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Mechanical Enforcement Rejected on Single-User CLI — 2026-04-15** (architecture.md)
   - 与本任务关系：cron routine 是建议性的（生成 candidates），不是强制性的。如果 cron 失败，不阻塞任何用户操作。

2. **Shell Env-Var Convention (Phase 1)** (architecture.md)
   - 与本任务关系：scanner 读取 trace JSONL 时用 jq 解析，不是自定义 parser。

3. **Drift-Check and Staleness Detection — 2026-04-24** (architecture.md)
   - 与本任务关系：候选知识需要 `Revalidated` date quieting path，避免重复提示同一条候选。

---

## 2. Background Context

### 2.1 Current *dream Protocol (line 5736-5892)
- Manual trigger only (`*dream` command)
- 6 steps: orient → gather signal → consolidate → validate → promote → rollback
- Operates on project-knowledge files (dedup, merge, prune stale refs)
- Does NOT scan session traces — only reorganizes existing knowledge entries

### 2.2 Phase 1-2 Data Now Available
- `reflexion_diagnosis` events — Blake's structured failure analyses (what_failed, hypothesis, approach, confidence)
- `gate_result` events — Gate pass/fail with context
- `expert_review_finding` events — P0/P1/P2 from reviewers
- `decision_point` events — key decisions with rationale
- `knowledge_extraction` events — when knowledge was written

### 2.3 Anthropic Dreaming Reference
- **Trigger**: 24h timer via Stop hook (we use `/schedule` cron instead — no session-end hook in Claude Code)
- **Gather Signal**: targeted `grep` on session transcripts (not LLM reads)
- **Output**: candidate playbook (separate from production knowledge — human reviews before promoting)
- **Key safety**: dreaming MUST NOT modify input knowledge store in place

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (Dream Scanner Script)**: Create `.tad/hooks/lib/dream-scanner.sh` that:
  - Reads `.tad/evidence/traces/*.jsonl` AND `.tad/archive/traces/*.jsonl` (both active + archived — prevents data loss when trace-rotate.sh moves files between scans, ARCH-P0-1 fix)
  - Reads last scan timestamp from `.tad/active/dream-state.yaml` (skip already-scanned entries)
  - ⚠️ DOUBLE-PARSE REQUIRED (CR-P0-1): v2 trace events store structured data inside the `context` field as a JSON-encoded string. To access sub-fields (e.g., `what_failed`), first extract `context` from the JSONL line, then parse that string as JSON: `jq -r '.context | fromjson | .what_failed'`. A single `jq .what_failed` on the top-level line will return `null`.
  - Extracts 4 signal types via grep/jq:
    a. **Recurring failures**: same `what_failed` pattern (via double-parse of `context`) appearing in ≥2 `reflexion_diagnosis` events. Guard: skip entries where `slug` is empty (CR-P0-2).
    b. **Unresolved escalations**: `gate_result` with `outcome=fail` that never had a subsequent `outcome=pass` for the same slug. Guard: skip entries where `slug` is empty.
    c. **Human overrides**: `decision_point` events with `actor_tag=human_overridden`. Note: this tag is Phase 2 infrastructure — no current caller emits it yet. Pass C is "future-ready" and will produce 0 results until callers adopt it (CR-P0-3).
    d. **Reflexion insights**: `reflexion_diagnosis` events where `context` contains `confidence: high` (via double-parse) AND same slug has a subsequent `gate_result` with `outcome=pass`
  - For each detected pattern, generates a candidate entry in `.tad/active/dream-candidates/`
  - Updates `last_scan_ts` in dream-state.yaml
  - Exits 0 always (advisory, never blocks)
  - Output: count of new candidates generated

- **FR2 (Candidate Format)**: Each candidate file in `.tad/active/dream-candidates/CAND-{date}-{HHMMSS}.md` (timestamp suffix prevents collision between cron and --auto, ARCH-P1-1 fix):
  ```markdown
  ---
  type: dream_candidate
  created: {ISO date}
  source_events: [{trace file}:{line}, ...]
  signal_type: recurring_failure | unresolved_escalation | human_override | reflexion_insight
  scope_tag: project | framework
  confidence: low | medium | high
  status: pending
  ---
  
  ### {Proposed Title} — {date}
  - **Context**: {derived from trace events — what was happening}
  - **Discovery**: {the pattern/insight extracted}
  - **Action**: {what should change in project-knowledge or SKILL.md}
  - **Evidence**: {trace refs with file:line}
  ```

- **FR3 (Scope Tagging)**: Scanner classifies each candidate:
  - `project`: pattern is specific to this project (references project-specific files/configs)
  - `framework`: pattern is about TAD protocol/workflow (references SKILL.md, gates, hooks)
  - Classification heuristic (3-tier, ARCH-P0-2 fix):
    1. If trace `file` field is non-empty AND references `.claude/skills/` or `.tad/hooks/` → `framework`
    2. If `file` field is empty/missing: check `slug` field — if slug contains "capability-pack" or references a SKILL name → `framework`
    3. Fallback (no file, no recognizable slug): → `project` (safe default)

- **FR4 (/schedule Routine)**: A cron routine runnable via `/schedule`:
  - Runs `bash .tad/hooks/lib/dream-scanner.sh`
  - Default interval: daily (24h)
  - On success: outputs candidate count to routine log
  - On failure: logs error, does not retry (next daily run will pick up)

- **FR5 (SessionStart Display — STEP 3.56)**: New activation step after STEP 3.55 (zombie cleanup):
  - Check `.tad/active/dream-candidates/CAND-*.md` for files with `status: pending`
  - If pending candidates found:
    ```
    🧠 Dream candidates: {N} pending review
    ```
    AskUserQuestion: "上次 session 后自动发现了 {N} 个知识模式。要现在审阅吗？"
    Options: "审阅 candidates" / "稍后处理"
  - "审阅" → show each candidate, per-candidate AskUserQuestion:
    - "接受 → 写入 project-knowledge" → write entry to appropriate .tad/project-knowledge/{category}.md, update candidate status to `accepted`
    - "修改后接受" → user edits, then write
    - "拒绝" → update candidate status to `rejected`
    - "推迟" → keep status `pending` (shown again next session)
  - After review: output summary "✅ {accepted} accepted, {rejected} rejected, {deferred} deferred"

- **FR6 (Dream State)**: Create `.tad/active/dream-state.yaml`:
  ```yaml
  last_scan_ts: null        # ISO timestamp of last scanner run
  last_scan_candidates: 0   # count from last run
  total_accepted: 0         # lifetime accepted count
  total_rejected: 0         # lifetime rejected count
  ```

- **FR7 (*dream --auto mode)**: Add a new flag to existing `*dream` command:
  - `*dream` (no flag): existing behavior (format consolidation)
  - `*dream --auto`: manually trigger the scanner (same as cron, but interactive)
  - `*dream --promote`: existing behavior (promote candidates from format consolidation)
  - `*dream --rollback`: existing behavior

### 3.2 Non-Functional Requirements
- **NFR1**: Scanner uses grep + jq on JSONL, not LLM judgment. LLM only used for candidate title/description generation.
- **NFR2**: No settings.json changes. No new hooks registered.
- **NFR3**: dream-scanner.sh must handle empty trace dirs gracefully (exit 0, 0 candidates).
- **NFR4**: macOS + Linux compatible (BSD date, no grep -P).

---

## 4. Technical Design

### 4.1 dream-scanner.sh Architecture

```
Input: .tad/evidence/traces/*.jsonl + .tad/active/dream-state.yaml
  ↓
Phase 1: Load & Filter
  - Read last_scan_ts from dream-state.yaml
  - Concatenate all JSONL files, filter entries with ts > last_scan_ts
  - If 0 new entries → exit 0 (nothing to scan)
  ↓
Phase 2: Pattern Detection (4 grep passes)
  Pass A: recurring_failure — group reflexion_diagnosis by what_failed, count ≥ 2
  Pass B: unresolved_escalation — gate_result fail without matching pass for same slug
  Pass C: human_override — decision_point with actor_tag=human_overridden
  Pass D: reflexion_insight — reflexion_diagnosis confidence=high + same slug has gate_result pass
  ↓
Phase 3: Candidate Generation
  - For each detected pattern: write CAND-{date}-{NNN}.md to dream-candidates/
  - Scope tagging: check file paths in source events for .claude/skills/ or .tad/hooks/
  ↓
Phase 4: State Update
  - Update dream-state.yaml: last_scan_ts, last_scan_candidates
  ↓
Output: "Dream scan complete: {N} new candidates"
```

### 4.2 STEP 3.56 (SessionStart — Dream Candidate Display)

Insert after STEP 3.55 (zombie cleanup), before STEP 3.8 (research landscape):

```yaml
  - STEP 3.56: Dream candidate review (conditional)
    trigger: "pending dream candidates exist in .tad/active/dream-candidates/"
    action: |
      1. Count CAND-*.md files with status: pending (grep frontmatter)
      2. If 0 → skip silently
      3. If > 0:
         Output: "🧠 {N} knowledge candidates from auto-dream (last scan: {last_scan_ts})"
         AskUserQuestion:
           question: "自动 dreaming 发现了 {N} 个知识模式。要现在审阅吗？"
           options:
             - "审阅 candidates" → per-candidate review loop
             - "稍后处理" → skip, candidates stay pending
      4. Per-candidate review:
         Display: title, signal_type, scope_tag, confidence, evidence
         AskUserQuestion per candidate:
           - "接受" → append to .tad/project-knowledge/{inferred_category}.md, status→accepted
           - "修改后接受" → user edits content, then append, status→accepted
           - "拒绝" → status→rejected (file stays for audit trail)
           - "推迟" → status stays pending
      5. After all candidates reviewed:
         Update dream-state.yaml: total_accepted, total_rejected
         Output summary
    blocking: false
    suppress_if: "No pending candidates"
    interacts_with: |
      Runs AFTER STEP 3.55 (zombie cleanup).
      Does NOT affect STEP 3.8 suppression.
      If STEP 3.7 announces Blake resume (case 3): suppress STEP 3.56.
```

### 4.3 *dream --auto Flag Addition

In `dream_protocol:` (line 5736), add to `flags:`:
```yaml
    auto: "*dream --auto — manually run dream scanner (same as cron trigger)"
```

Add a new step0 before step1_orient:
```yaml
    step0_auto:
      name: "Auto-Scan Mode (--auto flag)"
      trigger: "*dream --auto"
      action: |
        1. Run: bash .tad/hooks/lib/dream-scanner.sh
        2. Read output: candidate count
        3. If candidates > 0:
           Proceed to step4_validate_and_review (skip format consolidation steps 1-3)
           Show candidates for human review using STEP 3.56 review logic
        4. If candidates == 0:
           Output: "No new patterns detected. Try again after more sessions."
           Return to standby.
      note: "Auto mode SKIPS format consolidation (steps 1-3). Only runs scanner + review. Review logic is identical to STEP 3.56 per-candidate loop — Blake should implement it as a reusable block (e.g., YAML anchor or shared description) referenced by both STEP 3.56 and step0_auto (ARCH-P1-2 fix)."
```

### 4.4 /schedule Routine Configuration

The `/schedule` command creates a cron routine. Blake writes a description that the user can schedule:

```
Routine name: dream-scanner
Command: bash .tad/hooks/lib/dream-scanner.sh
Interval: daily (24h)
Description: "Scan trace JSONL for knowledge patterns → generate dream candidates"
```

Blake does NOT run `/schedule create` — that's a user action. Blake creates the scanner script and documents how to schedule it in the handoff's completion report.

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] Searched Alex SKILL.md for dream_protocol (line 5736), STEP 3.5/3.55/3.8 (lines 75-187)

### MQ2: 函数存在性验证
- [x] dream-validator.sh — .tad/hooks/lib/dream-validator.sh (exists, verified)
- [x] trace-writer.sh — .tad/hooks/lib/trace-writer.sh (Phase 1 output)
- [x] record_trace() — .tad/hooks/lib/common.sh (Phase 1 output)

---

## 6. Implementation Steps

### Step 1: Create dream-state.yaml
Write `.tad/active/dream-state.yaml` per §3.1 FR6.

### Step 2: Create dream-scanner.sh
Write `.tad/hooks/lib/dream-scanner.sh` per §4.1. Must:
- Read dream-state.yaml for last_scan_ts
- 4 grep/jq passes on trace JSONL
- Generate CAND-*.md files to .tad/active/dream-candidates/
- Update dream-state.yaml
- Exit 0 always, macOS compatible

### Step 3: Add STEP 3.56 to Alex SKILL.md
Insert after STEP 3.55 (line ~149), before STEP 3.8 (line ~150). Per §4.2.

### Step 4: Add *dream --auto to Alex SKILL.md
In dream_protocol (line ~5736): add `auto` to flags, add `step0_auto` before step1_orient. Per §4.3.

### Step 5: Document /schedule setup
In completion report, include instructions for user to run:
`/schedule create --name dream-scanner --interval daily --command "bash .tad/hooks/lib/dream-scanner.sh"`
Blake does NOT run this command — user decides.

### Step 6: Create test fixtures (ARCH-P0-3 fix)
Write `.tad/evidence/traces/test-fixtures.jsonl` with 5 synthetic trace entries covering all 4 passes:
```jsonl
{"ts":"2026-05-19T10:00:00Z","type":"reflexion_diagnosis","project":"test","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"what_failed\":\"tsc: missing type\",\"root_cause_hypothesis\":\"interface not exported\",\"revised_approach\":\"export interface\",\"confidence\":\"high\"}","outcome":"fail","slug":"test-task","agent":"blake"}
{"ts":"2026-05-19T10:01:00Z","type":"reflexion_diagnosis","project":"test","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"what_failed\":\"tsc: missing type\",\"root_cause_hypothesis\":\"wrong import path\",\"revised_approach\":\"fix import\",\"confidence\":\"medium\"}","outcome":"fail","slug":"test-task","agent":"blake"}
{"ts":"2026-05-19T10:02:00Z","type":"gate_result","project":"test","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","context":"Gate 3: all checks pass","outcome":"pass","slug":"test-task","agent":"blake"}
{"ts":"2026-05-19T10:03:00Z","type":"gate_result","project":"test","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"Gate 3: tsc errors","outcome":"fail","slug":"orphan-task","agent":"blake"}
{"ts":"2026-05-19T10:04:00Z","type":"decision_point","project":"test","schema_version":"2.0","actor_tag":"human_overridden","detail_level":"summary","context":"{\"decision\":\"auth library\",\"chosen\":\"passport\",\"rationale\":\"user prefers\"}","outcome":"passport","slug":"auth-task","agent":"alex"}
```
These fixtures let Blake test all 4 passes: recurring_failure (2× "tsc: missing type"), unresolved_escalation (orphan-task fail with no pass), human_override (auth-task), reflexion_insight (test-task high confidence + subsequent pass).

### Step 7: Smoke test
- `bash -n .tad/hooks/lib/dream-scanner.sh` exits 0
- Run scanner against test fixtures → verify it produces ≥3 candidates
- `bash .tad/hooks/lib/dream-scanner.sh` on empty trace dir → exits 0, 0 candidates
- dream-state.yaml is valid YAML
- Delete test-fixtures.jsonl after testing (or move to .tad/evidence/traces/test/)

### Grounded Against (Alex step1c):
- .claude/skills/alex/SKILL.md lines 75-187 (STEP 3.5-3.9, read at 2026-05-19)
- .claude/skills/alex/SKILL.md lines 5736-5892 (dream_protocol, read at 2026-05-19)
- .tad/hooks/lib/trace-writer.sh (Phase 1 output, read at 2026-05-19)
- .tad/evidence/traces/2026-05-17.jsonl (sample trace data format, read at 2026-05-18)

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/SKILL.md    # STEP 3.56 + dream_protocol --auto flag
```

### 7.2 Files to Create
```
.tad/hooks/lib/dream-scanner.sh    # Core scanner (4 pattern passes + candidate generation)
.tad/active/dream-state.yaml       # Scanner state persistence
.tad/templates/dream-candidate.md  # Candidate template (for reference — scanner generates directly)
```

---

## 8. Testing Requirements

### 8.1 Scanner Tests
- `bash -n .tad/hooks/lib/dream-scanner.sh` exits 0
- Empty trace dir → exits 0, outputs "0 new candidates"
- dream-state.yaml exists and is valid YAML after first run

### 8.2 Protocol Text
- `grep -c 'STEP 3.56' .claude/skills/alex/SKILL.md` ≥ 1
- `grep -c 'step0_auto' .claude/skills/alex/SKILL.md` = 1
- `grep -c 'dream-scanner' .claude/skills/alex/SKILL.md` ≥ 1

---

## 9. Acceptance Criteria

- [ ] AC1: `dream-scanner.sh` exists with 4 pattern detection passes (recurring_failure, unresolved_escalation, human_override, reflexion_insight)
- [ ] AC2: Scanner reads `last_scan_ts` from dream-state.yaml and only processes new trace entries
- [ ] AC3: Generated candidates follow CAND-{date}-{NNN}.md format with frontmatter (type, signal_type, scope_tag, confidence, status)
- [ ] AC4: `scope_tag` classification: file paths with `.claude/skills/` or `.tad/hooks/` → framework; else → project
- [ ] AC5: STEP 3.56 exists in Alex SKILL.md with AskUserQuestion review loop (accept/modify/reject/defer)
- [ ] AC6: `*dream --auto` flag added to dream_protocol with step0_auto that runs scanner then shows candidates
- [ ] AC7: dream-state.yaml created with last_scan_ts, last_scan_candidates, total_accepted, total_rejected
- [ ] AC8: Scanner exits 0 always (empty trace dir = 0 candidates, not error)
- [ ] AC9: `bash -n .tad/hooks/lib/dream-scanner.sh` exits 0
- [ ] AC10: No settings.json changes
- [ ] AC11: Existing *dream flow (format consolidation steps 1-6) unchanged — --auto is additive
- [ ] AC12: Completion report includes /schedule setup instructions for user
- [ ] AC13: Scanner reads BOTH `.tad/evidence/traces/` AND `.tad/archive/traces/` (rotation-safe)
- [ ] AC14: Scanner uses double-parse for `context` field: `jq '.context | fromjson | .field'`
- [ ] AC15: Scanner guards against empty `slug` in Pass A and Pass B
- [ ] AC16: Test fixtures file exists with ≥5 synthetic events covering all 4 passes
- [ ] AC17: Candidates with status=pending older than 30 days auto-transition to status=expired (staleness guard)
- [ ] AC18: Candidate filenames use timestamp suffix (not sequential NNN) to prevent collision between cron and --auto

## 9.1 Spec Compliance Checklist

| # | Verification Type | Verification Method | Expected | Verified |
|---|-------------------|--------------------|---------:|----------|
| 1 | post-impl | `grep -c 'recurring_failure' .tad/hooks/lib/dream-scanner.sh` | ≥1 | (post-impl) |
| 2 | post-impl | `grep -c 'STEP 3.56' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| 3 | post-impl | `grep -c 'step0_auto' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| 4 | post-impl | `bash -n .tad/hooks/lib/dream-scanner.sh` | exit 0 | (post-impl) |
| 5 | post-impl | `test -f .tad/active/dream-state.yaml` | exit 0 | (post-impl) |
| 6 | pre-impl | `git diff --name-only .claude/settings.json` | empty | ✅ empty |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ dream-scanner.sh is a SHELL SCRIPT (not protocol text). It must handle edge cases: empty files, malformed JSON lines, missing jq. Use the same `HAS_JQ` pattern from common.sh.
- ⚠️ STEP 3.56 numbering: goes after 3.55 (zombie), before 3.8 (research). The `interacts_with` field must suppress when Blake is active (same as 3.55).
- ⚠️ Candidate status updates (accepted/rejected) modify CAND-*.md frontmatter. Use sed to update the `status:` field, not rewrite the whole file.
- ⚠️ The scanner must NOT use LLM judgment for pattern detection — only grep/jq. LLM is only used by Alex (STEP 3.56) to display candidates in human-readable form.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: context is string-encoded JSON — scanner needs double-parse | §3.1 FR1 rewritten with double-parse requirement + jq example | Resolved |
| code-reviewer | P0-2: Pass B slug empty guard missing | §3.1 FR1 Pass A+B: explicit guard added | Resolved |
| code-reviewer | P0-3: Pass C human_overridden — no caller emits yet | §3.1 FR1 Pass C: marked "future-ready", will produce 0 until adopted | Resolved |
| backend-architect | P0-1: trace rotation moves files out of scanner glob path → data loss | §3.1 FR1: scanner reads BOTH evidence/traces/ AND archive/traces/, AC13 added | Resolved |
| backend-architect | P0-2: scope classification fails for events without file field | §3.1 FR3: 3-tier heuristic (file → slug → fallback project) | Resolved |
| backend-architect | P0-3: no test fixtures for scanner testing | §6 Step 6: 5 synthetic JSONL entries covering all 4 passes, AC16 added | Resolved |
| code-reviewer | P1-4: STEP 3.56 transitive suppression from 3.7 | §4.2 interacts_with already covers (same pattern as 3.55) | Resolved |
| code-reviewer | P1-5: no candidate expiry/garbage collection | AC17 added: pending >30 days → status=expired | Resolved |
| code-reviewer | P1-6: AC gap for scope_tag verification | AC4 already covers heuristic rule; scope_tag in frontmatter verified by AC3 | Resolved |
| backend-architect | P1-1: candidate naming collision | §3.1 FR2: CAND-{date}-{HHMMSS} timestamp suffix, AC18 added | Resolved |
| backend-architect | P1-2: step0_auto and STEP 3.56 share review logic but undefined how | §4.3 step0_auto note: reusable block or shared description, explicitly referenced | Resolved |
| code-reviewer | P2-7: zero-event edge case | AC8 covers exit 0; scanner updates last_scan_ts even with 0 candidates | Resolved |
| code-reviewer | P2-8: /schedule working directory | §10.1 warning added about BASH_SOURCE path resolution | Deferred |
| backend-architect | P2-1: /schedule setup likely never run | Noted — consider STEP 3.56 one-time prompt in future iteration | Deferred |

### Experts Selected

1. **code-reviewer** — jq query validity, JSONL schema alignment, edge cases, AC coverage
2. **backend-architect** — data flow integrity, cross-phase contracts, state management, rotation safety

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → PASS (3 P0, 3 P1 resolved, 2 P2 resolved/deferred)
- backend-architect: CONDITIONAL PASS → PASS (3 P0, 2 P1 resolved, 1 P2 deferred)

---

### 10.2 Sub-Agent 使用建议
- [ ] **code-reviewer** — shell script quality, jq queries, edge case handling
- [ ] **backend-architect** — data flow integrity, state management, cross-phase contract

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Scanner trigger | Hook-based vs /schedule cron vs Manual only | /schedule cron + manual --auto | No session-end hook available; cron covers gaps between sessions |
| 2 | Pattern detection | LLM analysis vs grep/jq | grep/jq | Per Anthropic Dreaming: grep is deterministic, reproducible, auditable |
| 3 | Candidate storage | In-memory vs File-based | File-based (CAND-*.md) | Persists across sessions; auditable; reviewable by user at any time |
| 4 | Scope classification | LLM judgment vs Path heuristic | Path heuristic | Simple, deterministic: .claude/skills/ or .tad/hooks/ = framework |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/auto-evolve-phase3-dream/code-reviewer.md
    - .tad/evidence/reviews/alex/auto-evolve-phase3-dream/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260519-auto-evolve-phase3-dream.md
  blake_reviews:
    - .tad/evidence/reviews/blake/auto-evolve-phase3-dream/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-19
**Version**: 3.1.0
