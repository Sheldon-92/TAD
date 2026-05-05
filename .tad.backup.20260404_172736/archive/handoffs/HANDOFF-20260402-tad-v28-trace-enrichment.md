# Handoff: TAD v2.8 Phase 1.5 — Trace Schema Enrichment

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-017
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 1.5)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Problem

Phase 1 的 trace 只记录文件元数据（type、path、size）。Phase 2 的分析 agent 需要更丰富的数据（step 状态、耗时、失败原因）。当前 trace 不够做有价值的优化分析。

**当前 trace 样例**:
```json
{"ts":"2026-04-03T01:03:07Z","type":"task_completed","project":"TAD","file":"...COMPLETION-*.md","domain":"","size_bytes":1711}
```

**需要的 trace**:
```json
{"ts":"...","type":"domain_pack_step","step":"deep_analyze","capability":"competitive_analysis","domain":"product-definition","status":"completed","duration_ms":1500,"tool":"WebSearch","quality_passed":true}
```

## 2. 问题：Hook 层面无法记录 step 级别数据

PostToolUse hook 只在文件写入时触发 — 它不知道当前在执行哪个 Domain Pack 的哪个 step。它只知道"一个文件被写了"。

**Step 级别的 trace 必须在 agent 执行时记录（不是 hook）。** 这意味着：

1. Domain Pack 的 workflow 描述中要包含"每个 step 完成后记录 trace"的指令
2. 或者在 Blake 的 SKILL.md 中加入"执行 Domain Pack step 时记录 trace"的行为规则

## 3. Design: 两层 Trace

```
Layer 1: Hook 自动记录（已有，Phase 1）
  → 文件事件：什么文件被创建/修改，什么时候，多大
  → 无需 agent 配合，自动发生

Layer 2: Agent 手动记录（本 Phase 新增）
  → Step 事件：哪个 capability 的哪个 step，状态、耗时、工具、质量
  → 需要 agent 在执行 Domain Pack 时主动记录
```

### 3.1 Agent Trace 记录方式

**在 Domain Pack 的每个 capability 开始和结束时**，Blake 写一行 trace：

```bash
# Step 开始
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"step_start","domain":"product-definition","capability":"competitive_analysis","step":"deep_analyze"}' >> .tad/evidence/traces/$(date +%Y-%m-%d).jsonl

# Step 完成
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"step_end","domain":"product-definition","capability":"competitive_analysis","step":"deep_analyze","status":"completed","tool":"WebSearch"}' >> .tad/evidence/traces/$(date +%Y-%m-%d).jsonl
```

但让 Blake 每个 step 手动跑两行 shell 太麻烦。

### 3.2 更好的方案：trace helper 脚本

创建 `.tad/hooks/trace-step.sh` — 一个简单的命令行工具：

```bash
# 记录 step 开始
bash .tad/hooks/trace-step.sh start product-definition competitive_analysis deep_analyze

# 记录 step 结束
bash .tad/hooks/trace-step.sh end product-definition competitive_analysis deep_analyze completed WebSearch
```

**脚本实现**:
```bash
#!/bin/bash
# trace-step.sh — Record Domain Pack step trace
# Usage:
#   trace-step.sh start <domain> <capability> <step>
#   trace-step.sh end <domain> <capability> <step> <status> [tool]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ACTION="$1"
DOMAIN="$2"
CAPABILITY="$3"
STEP="$4"
STATUS="${5:-}"
TOOL="${6:-}"

TRACE_DIR=".tad/evidence/traces"
mkdir -p "$TRACE_DIR"

TODAY=$(date +%Y-%m-%d)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROJECT=$(basename "$(pwd)")

if [ "$ACTION" = "start" ]; then
  TYPE="step_start"
elif [ "$ACTION" = "end" ]; then
  TYPE="step_end"
else
  echo "Usage: trace-step.sh start|end <domain> <capability> <step> [status] [tool]" >&2
  exit 1
fi

if [ "$HAS_JQ" = true ]; then
  jq -nc \
    --arg ts "$TS" \
    --arg type "$TYPE" \
    --arg project "$PROJECT" \
    --arg domain "$DOMAIN" \
    --arg capability "$CAPABILITY" \
    --arg step "$STEP" \
    --arg status "$STATUS" \
    --arg tool "$TOOL" \
    '{ts:$ts,type:$type,project:$project,domain:$domain,capability:$capability,step:$step,status:$status,tool:$tool}' \
    >> "$TRACE_DIR/$TODAY.jsonl"
else
  echo "{\"ts\":\"$TS\",\"type\":\"$TYPE\",\"project\":\"$PROJECT\",\"domain\":\"$DOMAIN\",\"capability\":\"$CAPABILITY\",\"step\":\"$STEP\",\"status\":\"$STATUS\",\"tool\":\"$TOOL\"}" >> "$TRACE_DIR/$TODAY.jsonl"
fi
```

### 3.3 Blake 行为规则

在 Blake SKILL.md 中加一条行为规则：

```
当执行 Domain Pack capability 的 step 时：
- 每个 step 开始前: bash .tad/hooks/trace-step.sh start {domain} {capability} {step}
- 每个 step 完成后: bash .tad/hooks/trace-step.sh end {domain} {capability} {step} {status} {tool}
- status: completed | failed | skipped
- tool: 使用的主要工具名（WebSearch, Write, D2 等）
```

**这仍然是 prompt-only 规则** — Blake 可能跳过。但至少 Hook 层的文件事件 trace（Layer 1）会自动记录，作为最低保障。

## 4. Implementation Steps

### Step 1: 创建 trace-step.sh
创建 `.tad/hooks/trace-step.sh`，chmod +x

### Step 2: 在 Blake SKILL.md 中加 trace 行为规则
在 mandatory 部分或 develop_command 中加：
"When executing Domain Pack steps, call trace-step.sh for start/end recording"

### Step 3: 测试
1. 手动运行 trace-step.sh start/end
2. 检查 JSONL 输出
3. 验证 JSON 合法

## 5. AC

- [ ] AC1: trace-step.sh 创建且可执行
- [ ] AC2: start 命令输出 step_start trace
- [ ] AC3: end 命令输出 step_end trace（含 status + tool）
- [ ] AC4: JSON 合法（jq 验证）
- [ ] AC5: Blake SKILL.md 有 trace 记录行为规则
- [ ] AC6: 现有 trace 功能不受影响（post-write-sync.sh）
- [ ] AC7: 必须走 Ralph Loop + Gate 3

## 6. Notes

- ⚠️ Agent trace 是 prompt-only — Blake 可能跳过。Layer 1 Hook trace 作为保底
- ⚠️ trace-step.sh 必须 <50ms（只是写一行 JSON）
- ⚠️ 不改 post-write-sync.sh — 两层 trace 独立运行

**Handoff Created By**: Alex
