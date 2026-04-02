# Handoff: TAD Quality Gate Hook Enforcement

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-005
**Type:** TAD Core Infrastructure Fix
**Priority:** P0 — 质量系统有系统性缺陷

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Problem

TAD 审计发现质量机制是"合规戏剧" — 规则写得像法律，执行全靠自觉。Blake 自己承认跳过了 Ralph Loop、Gate 3、Expert Review。

根因：**所有质量门控都是 PROMPT-ONLY（软约束），没有 Hook 强制执行（硬约束）。**

## 2. 必读材料

- `.tad/hooks/startup-health.sh` — 现有 Hook 实现参考
- `.tad/hooks/post-write-sync.sh` — 现有 PostToolUse 实现参考
- `.tad/hooks/lib/common.sh` — 共享工具函数
- `.claude/settings.json` — 当前 Hook 配置

## 3. 要加的 5 个 Hook

### Hook 1: COMPLETION-*.md 创建时 → 强制提醒调 /gate 3

**类型**: PostToolUse (command)
**Matcher**: Write
**触发条件**: 写入的文件路径匹配 `.tad/active/handoffs/COMPLETION-*.md`
**行为**: 注入 additionalContext — "COMPLETION report detected. You MUST run /gate 3 before sending results to Alex. Gate 3 is MANDATORY, not optional."

**实现**: 在 `post-write-sync.sh` 中添加一个 case（现有脚本已有 HANDOFF-*.md 和 NEXT.md 的检测）。

**为什么不用 BLOCK**: PostToolUse 无法阻止已完成的写入。但 system-reminder 级别的强制提醒足以确保 Blake 不会"忘记"。

### Hook 2: *accept 前置检查 — Gate 4 证据必须存在

**类型**: PreToolUse (command)
**Matcher**: Skill（当 skill 参数包含 "accept" 时）
**触发条件**: 用户调用任何包含 "accept" 的 Skill
**行为**: 
1. 检查 `.tad/active/handoffs/` 是否有 COMPLETION-*.md（Blake 完成报告）
2. 如果不存在 → exit 2（BLOCK）+ stderr "Cannot accept: no completion report found. Blake must complete Gate 3 first."
3. 如果存在 → exit 0（ALLOW）+ additionalContext "Completion report found. Proceed with Gate 4 acceptance."

**实现**: 新建 `.tad/hooks/pre-accept-check.sh`

**脚本逻辑**:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

INPUT=$(read_stdin_json)
TOOL_NAME=$(get_json_field "$INPUT" ".tool_name")
SKILL_NAME=$(get_json_field "$INPUT" ".tool_input.skill" 2>/dev/null)

# 只在调用 accept 相关 skill 时检查
if [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"accept"* ]]; then
  output_empty
  exit 0
fi

# 检查 completion report 是否存在
COMPLETION=$(ls .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | head -1)

if [ -z "$COMPLETION" ]; then
  echo "Cannot accept: no completion report found in .tad/active/handoffs/. Blake must run *complete + /gate 3 first." >&2
  exit 2  # BLOCK
fi

output_response "Completion report found: $(basename $COMPLETION). Proceed with Gate 4 acceptance."
exit 0
```

**注意**: 
- 使用 `get_json_field` 而非 grep（P0 修复：JSON 解析一致性）
- 使用 `$SCRIPT_DIR` 绝对路径（P0 修复：不依赖 CWD）
- exit 2 = BLOCK（Claude Code 硬阻止）
- 只在 Skill tool 且 skill 包含 "accept" 时触发

### Hook 3: HANDOFF-*.md 创建时 → 强化专家审查提醒

**类型**: PostToolUse (command)  
**已有**: post-write-sync.sh 已经检测 HANDOFF-*.md 并提醒
**增强**: 把提醒从 "Remember: Expert review is MANDATORY" 改为更具体的：

```
"Handoff created. BEFORE sending to Blake:
1. Call 2+ expert sub-agents (code-reviewer REQUIRED + 1 domain expert)
2. Fix ALL P0 issues from expert review
3. Run /gate 2
4. Generate Blake message (Step 7)
Skipping expert review = VIOLATION"
```

**实现**: 修改 `post-write-sync.sh` 的 HANDOFF 检测分支。

### Hook 4: /gate 3 前置检查 — evidence 文件必须存在

**类型**: PreToolUse (command)
**Matcher**: Skill（当 skill 参数包含 "gate" 时）
**触发条件**: 调用 /gate skill
**行为**:
1. 从 stdin 读取 skill 参数（判断是 gate 几）
2. 如果是 Gate 3:
   a. 检查 `.tad/active/handoffs/COMPLETION-*.md` 是否存在
   b. 检查 `.tad/evidence/ralph-loops/` 是否有最近的 state 文件
   c. 如果缺失 → exit 2 (BLOCK) + "Cannot run Gate 3: missing completion report or Ralph Loop evidence"
3. 如果是 Gate 4:
   a. 检查 completion report 存在
   b. exit 0 (ALLOW)
4. 其他 Gate → exit 0 (ALLOW)

**实现**: 新建 `.tad/hooks/pre-gate-check.sh`

**脚本逻辑**:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

INPUT=$(read_stdin_json)
TOOL_NAME=$(get_json_field "$INPUT" ".tool_name")
SKILL_NAME=$(get_json_field "$INPUT" ".tool_input.skill" 2>/dev/null)
SKILL_ARGS=$(get_json_field "$INPUT" ".tool_input.args" 2>/dev/null)

# 只在调用 gate skill 时检查
if [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"gate"* ]]; then
  output_empty
  exit 0
fi

# 判断是 Gate 几（从 args 提取数字）
GATE_NUM=$(echo "$SKILL_ARGS" | grep -o '[0-9]' | head -1)

if [ "$GATE_NUM" = "3" ]; then
  # Gate 3 前置检查
  COMPLETION=$(ls .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | head -1)
  
  # 冷启动检查：如果 evidence 目录不存在，ALLOW（首次项目）
  if [ ! -d ".tad/evidence/ralph-loops" ]; then
    output_response "First-time project: no Ralph Loop evidence directory. Gate 3 will proceed but Ralph Loop evidence is recommended."
    exit 0
  fi
  
  if [ -z "$COMPLETION" ]; then
    echo "Cannot run Gate 3: no COMPLETION report found. Run *complete first." >&2
    exit 2  # BLOCK
  fi
  
  output_response "Gate 3 prerequisites met. Completion report: $(basename $COMPLETION)"
  exit 0
  
elif [ "$GATE_NUM" = "4" ]; then
  # Gate 4 前置检查：completion report 存在即可
  COMPLETION=$(ls .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | head -1)
  if [ -z "$COMPLETION" ]; then
    output_response "Warning: no completion report found. Gate 4 may need Gate 3 to pass first."
  fi
  exit 0
  
else
  # Gate 1, 2 或其他 → 放行
  output_empty
  exit 0
fi
```

**注意**: 
- 冷启动安全：evidence 目录不存在时 ALLOW（不会死锁首次项目）
- Gate number 从 args 提取（"3" → Gate 3）
- 只 BLOCK Gate 3 缺 completion report 的情况
- Gate 4 只提醒不 BLOCK（Gate 4 是 Alex 侧，有自己的 *accept hook）

### Hook 5: Ralph Loop 状态文件检测 — 提醒完整流程

**问题**: `*develop` 不是独立 Skill 调用 — 它是 Blake session 内的子命令，Hook matcher 无法直接捕获。

**替代方案**: 检测 Ralph Loop 状态文件的创建。当 Blake 开始 `*develop`，会创建 `.tad/evidence/ralph-loops/{task_id}_state.yaml`。

**类型**: PostToolUse (command)
**Matcher**: Write（检测写入路径包含 `ralph-loops` 或 `_state.yaml`）
**触发条件**: 任何写入 `.tad/evidence/ralph-loops/` 的操作
**行为**: 注入 additionalContext:

```
"Ralph Loop state detected. MANDATORY workflow reminder:
1. Layer 1: build + test + lint + tsc (ALL must pass)
2. Layer 2: code-reviewer + test-runner (P0=0 required)
3. *complete → write COMPLETION report
4. /gate 3 → formal quality check (Hook will BLOCK if evidence missing)
5. Message to Alex
SKIPPING ANY STEP = VIOLATION."
```

**实现**: 在 `post-write-sync.sh` 中添加一个 case 检测 `ralph-loops` 路径。

**备选方案**: 如果 Blake 不创建 Ralph Loop 状态文件（跳过了 `*develop`），那 Hook 4 (pre-gate-check) 会在 Gate 3 时 BLOCK（因为没有 evidence）。这是**双层保险**：
- 层 1: 如果 Blake 跑了 Ralph Loop → Hook 5 提醒走完整流程
- 层 2: 如果 Blake 跳过了 → Hook 4 在 Gate 3 时 BLOCK

---

## 4. settings.json 更新

当前:
```json
{
  "hooks": {
    "SessionStart": [...],
    "PreToolUse": [prompt hook for Write|Edit],
    "PostToolUse": [post-write-sync.sh]
  }
}
```

更新后:
```json
{
  "hooks": {
    "SessionStart": [...],
    "PreToolUse": [
      { existing prompt hook for Write|Edit },
      { Hook 2: pre-accept-check.sh for Skill(accept) },
      { Hook 4: pre-gate-check.sh for Skill(gate) }
    ],
    "PostToolUse": [
      { existing post-write-sync.sh — enhanced with Hook 1, 3, 5 }
    ]
  }
}
```

---

## 5. 实现步骤

### Step 1: 新建 pre-accept-check.sh
1. 创建 `.tad/hooks/pre-accept-check.sh`（Hook 2）
2. chmod +x
3. 本地测试: 有/无 COMPLETION 文件时的行为

### Step 2: 新建 pre-gate-check.sh  
1. 创建 `.tad/hooks/pre-gate-check.sh`（Hook 4）
2. chmod +x
3. 本地测试: 有/无 evidence 文件时的行为

### Step 3: 增强 post-write-sync.sh
1. 增强 HANDOFF 检测提醒（Hook 3）
2. 增加 COMPLETION 检测提醒（Hook 1）
3. 增加 *develop 提醒（Hook 5）

### Step 4: 更新 settings.json
1. 添加两个新的 PreToolUse hook 配置
2. 验证 JSON 合法

### Step 5: 测试
用 self-test agent 验证:
1. 写一个 COMPLETION 文件 → 看到 Gate 3 提醒？
2. 调 *accept 但没有 COMPLETION 文件 → 被 BLOCK？
3. 调 *accept 有 COMPLETION 文件 → 正常通过？
4. 写 HANDOFF 文件 → 看到增强版专家审查提醒？
5. 调 /gate 3 但没有 evidence → 被 BLOCK？

### Step 6: 同步到下游项目
更新后的 hooks + settings.json 需要同步。

---

## 6. Acceptance Criteria

- [ ] AC1: pre-accept-check.sh 创建且可执行
- [ ] AC2: pre-gate-check.sh 创建且可执行
- [ ] AC3: post-write-sync.sh 增强（COMPLETION 提醒 + HANDOFF 增强 + develop 提醒）
- [ ] AC4: settings.json 更新且 JSON 合法
- [ ] AC5: 测试 — *accept 无 COMPLETION 时 BLOCK（exit 2）
- [ ] AC6: 测试 — *accept 有 COMPLETION 时 ALLOW
- [ ] AC7: 测试 — /gate 3 无 evidence 时 BLOCK
- [ ] AC8: 测试 — HANDOFF 创建后看到增强提醒
- [ ] AC9: 测试 — COMPLETION 创建后看到 Gate 3 提醒
- [ ] AC10: 现有 Hook 功能不受影响（SessionStart, PreToolUse Haiku）
- [ ] AC11: **Blake 必须对本 handoff 执行完整 Ralph Loop**（Layer 1 + Layer 2 + Gate 3）

---

## 7. Important Notes

- ⚠️ **AC11 是关键** — 这个 handoff 本身必须走完整的 Ralph Loop 流程，作为修复后的第一次正式执行
- ⚠️ PreToolUse hook 的 matcher 需要精确匹配 — 只匹配 Skill tool，不影响其他工具
- ⚠️ exit 2 = 硬阻止。测试时确认不会误阻止正常操作
- ⚠️ post-write-sync.sh 修改要保持向后兼容（现有 HANDOFF/NEXT.md/EPIC 检测不能坏）
- ⚠️ Hook 脚本必须 <500ms（不做网络调用）

**Handoff Created By**: Alex
**Date**: 2026-04-02
