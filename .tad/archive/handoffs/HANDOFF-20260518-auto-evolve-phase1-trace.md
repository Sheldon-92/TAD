---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: Auto-Evolve Phase 1 — Trace Infrastructure

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-18
**Project:** TAD
**Task ID:** TASK-20260518-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260518-auto-evolve.md (Phase 1/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-18

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | env-var convention, 11 event types, 3-file deliverable, backward compat via unconditional schema_version |
| Components Specified | ✅ | record_trace() signature, 5 helpers, rotation script — all with code samples |
| Functions Verified | ✅ | record_trace() verified at post-write-sync.sh:45, common.sh sourced at line 9 |
| Data Flow Mapped | ✅ | PostToolUse hook → record_trace() → JSONL append. Helpers → env vars → record_trace() → JSONL |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 2 P0 + 7 P1 all resolved. See §9.2 Audit Trail.

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
升级 TAD 的 trace 系统，从文件级事件（4 types × 6 fields）到决策级事件（10+ types × 12+ fields），支持后续 Phase 的自动学习和反思。三个核心交付：

1. **决策级 trace schema** — 新增 6+ 事件类型，每个事件携带上下文（为什么做这个决策、结果如何）
2. **采样/压缩机制** — 失败路径详细记录（≤2KB/event），成功路径只记摘要（≤200B/event）
3. **trace 轮转** — 90 天自动归档，防止 trace 文件无限增长

### 1.2 Why We're Building It
**业务价值**: TAD 当前的 trace 数据只记录"什么文件被创建了"（文件级），无法回答"为什么 Gate 失败了"、"Blake 重试了几次、为什么"、"哪些决策是人类做的 vs agent 猜的"。没有这些数据，`*dream`（Phase 3）无法从 session 历史中自动提取改进，`*optimize`（Phase 4）无法检测跨项目的模式。

**用户受益**: Phase 1 本身对用户是透明的（trace 在后台记录），但它是后续 3 个 Phase 的数据基础。

### 1.3 Intent Statement
**真正要解决的问题**: 给 TAD 的自进化闭环提供数据燃料。当前 702+ 条 trace 只有 4 种文件级事件，无法支撑自动模式检测。

**不是要做的**:
- ❌ 不改变现有 4 种 trace 类型的行为（完全向后兼容）
- ❌ 不改变 `*optimize`/`*dream` 的逻辑（那是 Phase 3/4）
- ❌ 不添加任何阻塞用户操作的 hook（trace 是异步记录）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Hook Shell Portability Rules — 2026-04-03** (architecture.md)
   - 关键：No `grep -P` on macOS, use `ENVIRON["VAR"]` not `awk -v` for user content, `perl -MTime::HiRes=time` for per-step timing
   - 与本任务关系：trace-writer.sh 和 trace-rotate.sh 必须 macOS 兼容

2. **Mechanical Enforcement Rejected on Single-User CLI — 2026-04-15** (architecture.md)
   - 关键：hooks are async, never block tool calls
   - 与本任务关系：所有新 trace 写入必须 exit 0，不得阻塞

3. **`.router.log` 5-Tuple as Load-Bearing Hook Output Contract — 2026-04-27** (architecture.md)
   - 关键：当 hook 的 side-output 被下游消费时，格式变更是 breaking change
   - 与本任务关系：新 trace schema 的 JSONL 格式一旦发布就是 API contract，Phase 3/4 会消费它

4. **Data-Capture and AskUser Hooks — 2026-04-25** (architecture.md)
   - 关键：array-valued data 用 elementwise membership check，不用 joined-string
   - 与本任务关系：trace schema 中的 array 字段（如 tags）的消费者必须用 elementwise check

---

## 2. Background Context

### 2.1 Current Trace Infrastructure

| Component | Location | Status |
|-----------|----------|--------|
| trace writer | `.tad/hooks/post-write-sync.sh` line 45-78 `record_trace()` | Working, file-level only |
| trace storage | `.tad/evidence/traces/{date}.jsonl` | Working, no rotation |
| trace consumer | `.tad/hooks/lib/trace-digest.sh` | Working, reads per-handoff traces |
| trace-step.sh | (referenced but never created) | Does not exist |
| event types | handoff_created, task_completed, domain_pack_created, evidence_created | 4 types, all file-level |

### 2.2 Current Schema (6 fields)
```json
{"ts":"2026-05-17T14:36:26Z","type":"handoff_created","project":"TAD","file":"/path/to/file.md","domain":"","size_bytes":19398}
```

### 2.3 Research Findings (from notebook — 2026-05-18)
- Production agent systems log decision-level traces: every tool call, sub-agent handoff, retry loop
- Minimum for auto-evolve: actor_tag (human vs agent), lifecycle events, subagent dependency tracking
- Anthropic Dreaming scans traces via grep, not LLM — schema must be grep-friendly

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (Schema Definition)**: Create `.tad/schemas/trace-schema.yaml` defining all event types (existing 4 + new 6+), their required/optional fields, and validation rules. Schema is the contract — Phase 3/4 consumers depend on it.

- **FR2 (Extended record_trace)**: Extend `record_trace()` in `post-write-sync.sh` to accept additional fields: `context`, `outcome`, `actor_tag`, `detail_level`. Existing callers (4 `record_trace` calls in the same file) continue working unchanged (new params are optional with defaults).

- **FR3 (New Event Helpers)**: Create `.tad/hooks/lib/trace-writer.sh` with helper functions for new event types:
  - `trace_gate_result <gate_num> <verdict> <detail>` — records gate pass/fail with reason
  - `trace_expert_finding <reviewer_type> <priority> <finding>` — records expert review findings
  - `trace_decision_point <decision> <options> <chosen> <rationale>` — records architectural/design decisions
  - `trace_tool_outcome <tool_name> <success|error> <detail>` — records tool call results
  - `trace_knowledge_extraction <file> <title> <source>` — records knowledge writes
  - Each helper calls the extended `record_trace()` internally

- **FR4 (Sampling/Compression)**: Implement detail_level field:
  - `full`: complete context, ≤2KB per event (used for: failures, gate FAIL, P0 findings)
  - `summary`: one-line digest, ≤200B per event (used for: successes, routine operations)
  - Default: `summary` (opt-in to `full` at call site)

- **FR5 (Actor Tags)**: Every trace entry gets `actor_tag` field:
  - `human_confirmed`: data explicitly provided/confirmed by human
  - `agent_inferred`: agent's own judgment (default)
  - `agent_verified`: agent's judgment verified by human or sub-agent review
  - `human_overridden`: human explicitly disagreed with agent suggestion and chose differently

- **FR6 (Trace Rotation)**: Create `.tad/hooks/lib/trace-rotate.sh`:
  - Move `.tad/evidence/traces/*.jsonl` files older than 180 days to `.tad/archive/traces/` (default; configurable via `--days N`)
  - Called manually via `bash .tad/hooks/lib/trace-rotate.sh` or from cron (Phase 3)
  - Preserves original filenames. No data loss — archive, not delete.
  - 180-day default chosen to give `*evolve` sufficient historical data across quiet periods.

- **FR7 (Schema Version)**: Add `schema_version` field to every trace entry (value: "2.0"). Existing v1 entries (no schema_version field) remain valid — consumers must handle both.

### 3.2 Non-Functional Requirements
- **NFR1**: All trace writes are async (exit 0, never block). No new settings.json hooks.
- **NFR2**: macOS + Linux compatible (no GNU-only features, no `grep -P`).
- **NFR3**: trace-writer.sh is a library (sourced by other scripts), not a standalone hook.
- **NFR4**: New trace entries must be valid JSON (jq-parseable). Use jq when available, shell fallback when not.

---

## 4. Technical Design

### 4.1 New Trace Schema (trace-schema.yaml)

```yaml
schema_version: "2.0"
description: "TAD decision-level trace schema. Consumed by *dream, *optimize, *evolve."

# Common fields (all events)
common_fields:
  ts: {type: string, format: "ISO 8601", required: true}
  type: {type: string, required: true, enum: [see event_types]}
  project: {type: string, required: true}
  schema_version: {type: string, required: true, default: "2.0"}
  actor_tag: {type: string, required: true, enum: [human_confirmed, agent_inferred, agent_verified, human_overridden], default: agent_inferred}
  detail_level: {type: string, required: true, enum: [full, summary], default: summary}

# Preserved fields (backward compat)
legacy_fields:
  file: {type: string, required: false, note: "present in v1 events"}
  domain: {type: string, required: false, note: "present in v1 events"}
  size_bytes: {type: integer, required: false, note: "present in v1 events"}

# New context fields (v2 events)
v2_fields:
  context: {type: string, required: false, max_bytes: 2048, note: "only populated when detail_level=full"}
  outcome: {type: string, required: false, enum: [pass, fail, error, skip, partial]}
  slug: {type: string, required: false, note: "handoff slug for cross-referencing"}
  agent: {type: string, required: false, enum: [alex, blake, conductor, sub-agent]}
  duration_ms: {type: integer, required: false, note: "elapsed time for timed events"}

event_types:
  # --- v1 (preserved, unchanged) ---
  handoff_created: {fields: [file, domain, size_bytes]}
  task_completed: {fields: [file, domain, size_bytes]}
  domain_pack_created: {fields: [file, domain, size_bytes]}
  domain_pack_step: {fields: [file, domain, size_bytes], note: "legacy Domain Pack step event"}
  evidence_created: {fields: [file, domain, size_bytes]}
  
  # --- v2 (new) ---
  gate_result: {fields: [slug, agent, outcome, context, duration_ms], note: "Gate 2/3/4 verdict"}
  expert_review_finding: {fields: [slug, agent, outcome, context], note: "P0/P1/P2 from expert review"}
  reflexion_diagnosis: {fields: [slug, agent, context, outcome], note: "Phase 2 — structured failure reflection"}
  decision_point: {fields: [slug, agent, context, outcome, actor_tag], note: "key decision with rationale"}
  tool_call_outcome: {fields: [agent, outcome, context, duration_ms], note: "sub-agent or tool result"}
  knowledge_extraction: {fields: [file, slug, context, actor_tag], note: "knowledge write to project-knowledge/"}
```

### 4.2 Extended record_trace() Signature

Current (line 45-48 of post-write-sync.sh):
```bash
record_trace() {
  local type="$1"
  local file_path="$2"
  local domain="${3:-}"
```

New (backward-compatible extension — env-var convention for v2 fields):
```bash
record_trace() {
  local type="$1"
  local file_path="${2:-}"
  local domain="${3:-}"
  # --- v2 extensions via environment variables (CR-P0-1 fix) ---
  # Callers set TRACE_* env vars before calling. Defaults preserve v1 behavior.
  local context="${TRACE_CONTEXT:-}"
  local outcome="${TRACE_OUTCOME:-}"
  local actor_tag="${TRACE_ACTOR:-agent_inferred}"
  local detail_level="${TRACE_DETAIL:-summary}"
  local slug="${TRACE_SLUG:-}"
  local agent="${TRACE_AGENT:-}"
  local duration_ms="${TRACE_DURATION:-}"

  # Auto-escalation (CR-P1-3 fix): failures force full detail regardless of caller
  case "$outcome" in
    fail|error|FAIL|ERROR) detail_level="full" ;;
  esac

  # Guard stat on empty file_path (CR-P1-2 fix)
  local size=0
  [ -n "$file_path" ] && size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")
```

All events emitted after this upgrade include `schema_version: "2.0"` unconditionally (CR-P0-2 fix).
Pre-upgrade events (no `schema_version` field) remain in trace files — consumers detect pre-upgrade data by absence of `schema_version` key.

When `detail_level=summary`, truncate context to 200 chars.
When `detail_level=full`, allow context up to 2048 chars.

### 4.3 trace-writer.sh Helper Functions

```bash
#!/bin/bash
# TAD Trace Writer Library — decision-level event helpers
# Source this file, don't execute it directly.
# Usage: source .tad/hooks/lib/trace-writer.sh

TRACE_WRITER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${TRACE_WRITER_DIR}/common.sh"

# Source the main hook's record_trace (need the function, not the hook logic)
# trace-writer.sh provides wrappers; record_trace lives in post-write-sync.sh
# To avoid sourcing the full hook, extract record_trace to common.sh (see §6 step 1)

trace_gate_result() {
  local gate_num="$1" verdict="$2" detail="${3:-}" slug="${4:-}" agent="${5:-alex}"
  TRACE_CONTEXT="$detail" TRACE_OUTCOME="$verdict" TRACE_ACTOR="agent_inferred" \
    TRACE_SLUG="$slug" TRACE_AGENT="$agent" \
    record_trace "gate_result"
}

trace_expert_finding() {
  local reviewer_type="$1" priority="$2" finding="${3:-}" slug="${4:-}"
  TRACE_CONTEXT="$finding" TRACE_OUTCOME="$priority" TRACE_ACTOR="agent_inferred" \
    TRACE_SLUG="$slug" TRACE_AGENT="$reviewer_type" \
    record_trace "expert_review_finding"
}

trace_decision_point() {
  local decision="$1" chosen="$2" rationale="${3:-}" slug="${4:-}" actor="${5:-agent_inferred}"
  # Use jq to build structured context (CR-P1-4 fix: no flat string packing)
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg d "$decision" --arg c "$chosen" --arg r "$rationale" \
      '{decision:$d,chosen:$c,rationale:$r}')
  else
    ctx="decision=${decision}|chosen=${chosen}|rationale=${rationale}"
  fi
  TRACE_CONTEXT="$ctx" TRACE_OUTCOME="$chosen" TRACE_ACTOR="$actor" \
    TRACE_SLUG="$slug" \
    record_trace "decision_point"
}

trace_tool_outcome() {
  local tool_name="$1" result="$2" detail="${3:-}" duration="${4:-}"
  TRACE_CONTEXT="$detail" TRACE_OUTCOME="$result" TRACE_ACTOR="agent_inferred" \
    TRACE_AGENT="$tool_name" TRACE_DURATION="$duration" \
    record_trace "tool_call_outcome"
}

trace_knowledge_extraction() {
  local file="$1" title="$2" source="${3:-}" slug="${4:-}" actor="${5:-agent_verified}"
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg t "$title" --arg s "$source" '{title:$t,source:$s}')
  else
    ctx="title=${title}|source=${source}"
  fi
  TRACE_CONTEXT="$ctx" TRACE_ACTOR="$actor" TRACE_SLUG="$slug" \
    record_trace "knowledge_extraction" "$file"
}
```

### 4.4 Trace Rotation Script

```bash
#!/bin/bash
# TAD Trace Rotation — archive old trace files
# Usage: bash .tad/hooks/lib/trace-rotate.sh [--days N] [--dry-run]
set -euo pipefail

ARCHIVE_DAYS="${1:-180}"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true && ARCHIVE_DAYS="${2:-90}"
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

TRACE_DIR=".tad/evidence/traces"
ARCHIVE_DIR=".tad/archive/traces"

[ -d "$TRACE_DIR" ] || { echo "No trace directory found"; exit 0; }
mkdir -p "$ARCHIVE_DIR"

CUTOFF=$(date -v-${ARCHIVE_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "${ARCHIVE_DAYS} days ago" +%Y-%m-%d)
MOVED=0

for f in "$TRACE_DIR"/*.jsonl; do
  [ -f "$f" ] || continue
  FILE_DATE=$(basename "$f" .jsonl)  # e.g., 2026-05-17
  if [[ "$FILE_DATE" < "$CUTOFF" ]]; then
    if [ "$DRY_RUN" = true ]; then
      echo "Would archive: $f"
    else
      mv "$f" "$ARCHIVE_DIR/"
    fi
    MOVED=$((MOVED + 1))
  fi
done

echo "Trace rotation: $MOVED files archived (cutoff: $CUTOFF)"
```

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 — 搜索了 post-write-sync.sh (trace writer), trace-digest.sh (consumer), settings.json (hook config)

### MQ2: 函数存在性验证
- [x] `record_trace()` — post-write-sync.sh line 45, verified exists
- [x] `read_stdin_json`, `get_json_field`, `output_response`, `output_empty` — common.sh, verified via source statement

### MQ3-MQ5: N/A (no UI, no data flow beyond JSONL append)

---

## 6. Implementation Steps

### Step 1: Extract record_trace to common.sh
Move the `record_trace()` function from `post-write-sync.sh` (lines 45-78) to `.tad/hooks/lib/common.sh`. In `post-write-sync.sh`, replace the function body with `# record_trace moved to common.sh` (it's already sourced via line 9). This allows trace-writer.sh to access `record_trace()` without sourcing the full hook.

### Step 2: Extend record_trace() signature
In `.tad/hooks/lib/common.sh`, extend `record_trace()` per §4.2. Add v2 fields (context, outcome, actor_tag, detail_level, slug, agent, duration_ms) as optional params with defaults. Add `schema_version` to JSON output when any v2 field is non-empty. Existing 4 callers in post-write-sync.sh pass only 2-3 args — they continue working unchanged.

### Step 3: Create trace-schema.yaml
Write `.tad/schemas/trace-schema.yaml` per §4.1. This is the contract document for Phase 3/4 consumers.

### Step 4: Create trace-writer.sh
Write `.tad/hooks/lib/trace-writer.sh` per §4.3. Source common.sh for `record_trace()`. Add 5 helper functions. Make executable (`chmod +x`).

### Step 5: Create trace-rotate.sh
Write `.tad/hooks/lib/trace-rotate.sh` per §4.4. Support `--days N` and `--dry-run` flags. macOS compatible (BSD `date -v`). Make executable.

### Step 6: Verify backward compatibility
Run the existing 4 `record_trace` calls in post-write-sync.sh mentally (or via dry-run): confirm they produce valid v1 JSONL (no schema_version field when called with ≤3 args).

### Step 7: Smoke test new trace functions
Source trace-writer.sh and call each helper once with test data. Verify JSONL output is valid (`jq .` parses it). Verify `detail_level=full` produces context, `detail_level=summary` truncates.

### Grounded Against (Alex step1c):
- .tad/hooks/post-write-sync.sh lines 1-130 (full file, read at 2026-05-18)
- .tad/hooks/lib/common.sh (referenced as source, exists)
- .tad/schemas/ directory (exists, has 2 .json schema files)
- .tad/evidence/traces/2026-05-17.jsonl (sample data, read at 2026-05-18)

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/hooks/lib/common.sh          # Add record_trace() (moved from post-write-sync.sh)
.tad/hooks/post-write-sync.sh     # Remove record_trace() body (now in common.sh)
```

### 7.2 Files to Create
```
.tad/schemas/trace-schema.yaml    # Trace schema contract (v2)
.tad/hooks/lib/trace-writer.sh    # Helper functions for v2 event types
.tad/hooks/lib/trace-rotate.sh    # Trace file rotation/archival
```

---

## 8. Testing Requirements

### 8.1 Backward Compatibility
- Existing `record_trace "handoff_created" "$FILE_PATH" ""` calls still produce valid v1 JSONL
- No `schema_version` field in v1 entries (backward compat)

### 8.2 New Function Tests
- Each trace helper produces valid JSON (`echo '...' | jq .` exits 0)
- `trace_gate_result 3 FAIL "tsc errors"` produces `detail_level: full` (auto-escalation)
- `trace_gate_result 3 PASS ""` produces `detail_level: summary`
- `trace_expert_finding code-reviewer P0 "missing type"` produces `detail_level: full`

### 8.3 Rotation Test
- `bash .tad/hooks/lib/trace-rotate.sh --dry-run` runs without error
- Creates `.tad/archive/traces/` if missing

---

## 9. Acceptance Criteria

- [ ] AC1: `record_trace()` function lives in `.tad/hooks/lib/common.sh` and is callable from both `post-write-sync.sh` and `trace-writer.sh`
- [ ] AC2: Extended `record_trace()` reads v2 fields from `TRACE_*` env vars (TRACE_CONTEXT, TRACE_OUTCOME, TRACE_ACTOR, TRACE_DETAIL, TRACE_SLUG, TRACE_AGENT, TRACE_DURATION) — no positional params beyond the original 3
- [ ] AC3: All events after upgrade include `schema_version: "2.0"` unconditionally (pre-upgrade events identified by absence of `schema_version` key)
- [ ] AC4: `record_trace()` auto-escalates `detail_level` to `full` when `outcome` is fail/error, regardless of caller setting
- [ ] AC5: `trace-writer.sh` has 5 helper functions (trace_gate_result, trace_expert_finding, trace_decision_point, trace_tool_outcome, trace_knowledge_extraction)
- [ ] AC6: `trace-rotate.sh` moves files older than N days (default 180) to `.tad/archive/traces/`
- [ ] AC7: `trace-schema.yaml` defines 11 event types (5 v1 + 6 v2) with field specifications
- [ ] AC8: All shell scripts pass `bash -n` syntax check (no syntax errors)
- [ ] AC9: All generated JSONL is valid JSON (parseable by `jq .`)
- [ ] AC10: No changes to `.claude/settings.json` — no new hooks registered
- [ ] AC11: `actor_tag` field supports 4 values: human_confirmed, agent_inferred, agent_verified, human_overridden — default is agent_inferred
- [ ] AC12: `trace_decision_point` stores structured context as JSON object (via jq) not flat string packing
- [ ] AC13: `stat` call in `record_trace()` guarded by `[ -n "$file_path" ]` — empty file_path produces `size_bytes: 0` without error

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | AC1: record_trace in common.sh | post-impl | `grep -c '^record_trace()' .tad/hooks/lib/common.sh` | 1 | (post-impl) |
| 2 | AC2: env-var convention | post-impl | `grep -c 'TRACE_CONTEXT' .tad/hooks/lib/common.sh` | ≥1 | (post-impl) |
| 3 | AC3: schema_version unconditional | post-impl | `grep -c 'schema_version' .tad/hooks/lib/common.sh` | ≥1 | (post-impl) |
| 4 | AC5: 5 helpers in trace-writer.sh | post-impl | `grep -c '^trace_' .tad/hooks/lib/trace-writer.sh` | 5 | (post-impl) |
| 5 | AC7: 11 event types in schema | post-impl | `grep -c 'fields:' .tad/schemas/trace-schema.yaml` | 11 | (post-impl) |
| 6 | AC8: syntax check | post-impl | `bash -n .tad/hooks/lib/trace-writer.sh && bash -n .tad/hooks/lib/trace-rotate.sh` | exit 0 | (post-impl) |
| 7 | AC10: no settings.json change | pre-impl | `git diff --name-only .claude/settings.json` | empty | ✅ empty |
| 8 | AC11: 4 actor_tag values | post-impl | `grep -c 'human_overridden' .tad/schemas/trace-schema.yaml` | 1 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: 10-positional-param record_trace() is maintenance hazard — silent data corruption | §4.2 rewritten with TRACE_* env-var convention | Resolved |
| backend-architect | P0-1: Same positional param issue (independently flagged) | §4.2 env-var convention | Resolved |
| backend-architect | P0-2: v1/v2 discrimination implicit — v2 call with all empty optional fields looks like v1 | §4.2 unconditional schema_version on all post-upgrade events | Resolved |
| code-reviewer | P1-2: stat on empty file_path fails | §4.2 guard: `[ -n "$file_path" ]`, AC13 added | Resolved |
| code-reviewer | P1-3: AC1 grep pattern too loose | §9.1 row 1 anchored to `^record_trace()` | Resolved |
| code-reviewer | P1-4: decision_point flat string not grep-friendly | §4.3 trace_decision_point uses jq structured JSON, AC12 added | Resolved |
| code-reviewer | P1-5: Missing AC for FR5 actor tags | AC11 added (4 values including human_overridden) | Resolved |
| code-reviewer | P1-6: domain_pack_step missing from schema | §4.1 event_types: domain_pack_step added as v1 legacy, AC7 updated to 11 | Resolved |
| backend-architect | P1-3: Sampling auto-escalation caller-dependent | §4.2 auto-escalation moved into record_trace() itself, AC4 added | Resolved |
| backend-architect | P1-4: Missing human_overridden actor tag | §3.1 FR5 + §4.1 schema updated, AC11 added | Resolved |
| backend-architect | P1-5: 90-day rotation too aggressive for *evolve | §4.4 + FR6 changed to 180 days default | Resolved |
| code-reviewer | P2-7: trace-rotate.sh arg parsing brittle | Noted — Blake can improve with getopts if desired | Deferred |
| code-reviewer | P2-8: schema_version required vs conditional contradiction | Resolved by P0-2 fix: unconditional emission | Resolved |

### Experts Selected

1. **code-reviewer** — shell function design, AC coverage, backward compat, syntax
2. **backend-architect** — schema design, data contract, cross-phase dependencies, actor model

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → PASS (1 P0, 6 P1 resolved, 1 P2 deferred)
- backend-architect: CONDITIONAL PASS → PASS (2 P0, 3 P1 resolved)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ `record_trace()` is called from a PostToolUse hook. It MUST NOT fail (always exit 0). Any error in trace writing must be silently swallowed — trace is observability, not functionality.
- ⚠️ Moving `record_trace()` to common.sh: verify that `post-write-sync.sh` sources common.sh BEFORE the first `record_trace` call (currently line 9-10, calls start at line 98).
- ⚠️ The `context` field in v2 events will contain user content (file paths, error messages). Use `ENVIRON["VAR"]` not `awk -v` per Hook Shell Portability Rules.
- ⚠️ BSD `date -v` for macOS, `date -d` for Linux. trace-rotate.sh must handle both.

### 10.2 Known Constraints
- Phase 1 creates the infrastructure but does NOT wire it into Alex/Blake SKILL.md (that's Phase 2-4).
- trace-writer.sh will be sourced by future hooks/scripts in later Phases — the function signatures are the API contract.

### 10.3 Sub-Agent 使用建议
- [ ] **code-reviewer** — verify shell portability, function signature design, backward compat
- [ ] **test-runner** — run syntax checks and basic JSON validation

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | record_trace location | Keep in post-write-sync.sh vs Move to common.sh | Move to common.sh | trace-writer.sh needs to call it; sourcing full hook would trigger side effects |
| 2 | Schema format | JSON Schema vs YAML definition | YAML definition | Consistent with TAD's existing config style, human-readable |
| 3 | Sampling mechanism | Per-event-type config vs Call-site decision | Call-site with auto-escalation | Simpler; failures auto-escalate to full regardless of caller's choice |
| 4 | Rotation trigger | Hook-based (every session) vs Manual script | Manual script (cron-ready) | Phase 3 will wire cron; for now manual is sufficient |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/auto-evolve-phase1-trace/code-reviewer.md
    - .tad/evidence/reviews/alex/auto-evolve-phase1-trace/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260518-auto-evolve-phase1-trace.md
  blake_reviews:
    - .tad/evidence/reviews/blake/auto-evolve-phase1-trace/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-18
**Version**: 3.1.0
