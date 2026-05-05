# Handoff: TAD v2.8 Phase 1 — Trace Infrastructure

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-015
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 1/5)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building

PostToolUse Hook 自动记录 Domain Pack 执行 trace（JSONL 格式）。这是 TAD v2.8 自我进化的数据基础 — 没有 trace 就没有优化依据。

### 1.2 Why

Meta-Harness 研究证明：同一模型，不同 harness，性能差 6 倍。要自动优化 harness，必须先记录执行历史。

### 1.3 Intent

**不是要做**：
- ❌ 不做分析 agent（Phase 2）
- ❌ 不做跨项目聚合（Phase 3）
- ❌ 不做审批工作流（Phase 4）
- 只做 trace 记录基础设施

---

## 📚 必读材料

- `.tad/spike-v3/domain-pack-tools/v28-research-synthesis.md` — v2.8 研究综合（trace 格式设计、优化循环设计）
- `.tad/hooks/post-write-sync.sh` — 现有 PostToolUse hook（要在这里加 trace 逻辑）
- `.tad/hooks/lib/common.sh` — 共享函数

---

## 2. Technical Design

### 2.1 Trace 记录时机

**在 PostToolUse Hook（post-write-sync.sh）中**，当检测到以下文件写入时记录 trace：

| 检测到 | 记录什么 | Trace type |
|--------|---------|-----------|
| `.tad/active/research/` 下文件创建 | Domain Pack step 完成 | `domain_pack_step` |
| `HANDOFF-*.md` 创建 | Handoff 创建完成 | `handoff_created` |
| `COMPLETION-*.md` 创建 | Blake 完成报告 | `task_completed` |
| `.tad/evidence/` 下文件创建 | Gate/Review 证据 | `evidence_created` |

### 2.2 Trace JSONL 格式

每条 trace 一行 JSON，append 到文件：

```json
{
  "ts": "2026-04-02T15:30:00Z",
  "type": "domain_pack_step",
  "project": "menu-snap",
  "file": ".tad/active/research/menu-snap/competitive-analysis.md",
  "domain": "product-definition",
  "size_bytes": 2048
}
```

**字段说明**：
- `ts`: ISO 8601 时间戳
- `type`: trace 类型（domain_pack_step / handoff_created / task_completed / evidence_created）
- `project`: 项目名（从 CWD 推断）
- `file`: 写入的文件路径
- `domain`: 匹配的 domain pack 名（从路径推断，如果在 research/ 下）
- `size_bytes`: 文件大小

### 2.3 存储位置

```
.tad/evidence/traces/
├── 2026-04-02.jsonl    # 按日期一个文件
├── 2026-04-03.jsonl
└── ...
```

按日期分文件，避免单文件过大。JSONL 格式方便 agent 读取（每行独立 parse）。

### 2.4 实现方式

**在 post-write-sync.sh 中添加 trace 记录函数**：

```bash
record_trace() {
  local type="$1"
  local file_path="$2"
  local domain="$3"
  
  local trace_dir=".tad/evidence/traces"
  mkdir -p "$trace_dir"
  
  local today=$(date +%Y-%m-%d)
  local ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local project=$(basename "$(pwd)")
  local size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
  
  # ⚠️ P0 修复：用 jq 构建 JSON（防止文件路径含特殊字符破坏 JSON）
  # 如果 jq 不可用，用简单转义 fallback
  if command -v jq &>/dev/null; then
    jq -nc \
      --arg ts "$ts" \
      --arg type "$type" \
      --arg project "$project" \
      --arg file "$file_path" \
      --arg domain "$domain" \
      --argjson size "$size" \
      '{ts:$ts,type:$type,project:$project,file:$file,domain:$domain,size_bytes:$size}' \
      >> "$trace_dir/$today.jsonl"
  else
    # Fallback: 简单转义双引号和反斜杠
    local safe_path=$(echo "$file_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"ts\":\"$ts\",\"type\":\"$type\",\"project\":\"$project\",\"file\":\"$safe_path\",\"domain\":\"$domain\",\"size_bytes\":$size}" >> "$trace_dir/$today.jsonl"
  fi
}
```

**在现有的 case 分支中调用**：

```bash
# ⚠️ P0 修复：record_trace 调用必须在现有 case 分支内部（同一个 case 臂）
# 不是新增独立分支，是在现有分支的逻辑开头加一行 record_trace

# 现有 HANDOFF 分支内部（在 output_response 之前）加：
#   record_trace "handoff_created" "$FILE_PATH" ""
#   然后继续现有的 output_response 提醒逻辑

# 现有 COMPLETION 分支内部（在 output_response 之前）加：
#   record_trace "task_completed" "$FILE_PATH" ""
#   然后继续现有的 output_response 提醒逻辑

# 示例（HANDOFF 分支的完整写法）：
# *.tad/active/handoffs/HANDOFF-*)
#   record_trace "handoff_created" "$FILE_PATH" ""
#   output_response "Handoff created. BEFORE sending to Blake: ..."
#   ;;

# 新增: research 目录文件 → 记录 Domain Pack step
*.tad/active/research/*)
  domain=$(detect_domain "$FILE_PATH")  # 从路径推断 domain
  record_trace "domain_pack_step" "$FILE_PATH" "$domain"
  ;;

# 新增: evidence 目录文件 → 记录证据创建
# ⚠️ P0 修复：排除 traces/ 目录自身（防止无限递归）
*.tad/evidence/traces/*)
  # 跳过 — trace 文件本身不记录 trace
  ;;
*.tad/evidence/*)
  record_trace "evidence_created" "$FILE_PATH" ""
  ;;
```

### 2.5 Domain 检测逻辑

```bash
detect_domain() {
  local path="$1"
  # .tad/active/research/{project}/{files} → 无法从路径确定 domain
  # 但可以检查 .tad/domains/ 下哪些 pack 的 output_dir 匹配
  # 简化版：返回空字符串，Phase 2 分析时再关联
  echo ""
}
```

Phase 1 只做基础记录，domain 关联在 Phase 2 分析时做。

---

## 3. Implementation Steps

### Step 1: 创建 trace 目录
```bash
mkdir -p .tad/evidence/traces
```

### Step 2: 在 post-write-sync.sh 中添加 record_trace 函数

### Step 3: 在现有 case 分支中调用 record_trace

### Step 4: 新增 research/ 和 evidence/ 的 case 分支

### Step 5: 测试
1. 写一个测试文件到 `.tad/active/research/test/test.md`
2. 检查 `.tad/evidence/traces/$(date +%Y-%m-%d).jsonl` 是否有新记录
3. 验证 JSON 格式（`cat trace.jsonl | python3 -m json.tool`）
4. 删除测试文件

### Step 6: 验证现有功能不受影响
- 写 HANDOFF-*.md → 仍然看到专家审查提醒 + trace 记录
- 写 COMPLETION-*.md → 仍然看到 Gate 3 提醒 + trace 记录

---

## 4. Acceptance Criteria

- [ ] AC1: record_trace 函数在 post-write-sync.sh 中实现
- [ ] AC2: HANDOFF 创建时记录 trace（type=handoff_created）
- [ ] AC3: COMPLETION 创建时记录 trace（type=task_completed）
- [ ] AC4: research/ 目录文件创建时记录 trace（type=domain_pack_step）
- [ ] AC5: evidence/ 目录文件创建时记录 trace（type=evidence_created）
- [ ] AC6: Trace 存储在 `.tad/evidence/traces/{date}.jsonl`
- [ ] AC7: 每条 trace 是合法 JSON（python3 可 parse）
- [ ] AC8: 现有 hook 功能不受影响（提醒信息仍然正常）
- [ ] AC9: Hook 执行时间仍然 <500ms（trace 写入不能拖慢）
- [ ] AC10: 必须走完整 Ralph Loop + Gate 3

---

## 5. Important Notes

- ⚠️ **只做记录，不做分析** — 分析是 Phase 2
- ⚠️ **JSONL append-only** — 不修改已有记录
- ⚠️ **不记录文件内容** — 只记录元数据（路径、大小、时间戳）。内容在原文件里
- ⚠️ **post-write-sync.sh 已有逻辑不能破坏** — 新增 case 分支，不改现有分支

**Handoff Created By**: Alex
