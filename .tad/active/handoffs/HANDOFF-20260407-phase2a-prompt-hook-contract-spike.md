---
task_type: mixed       # Minimal hook config + spike report
e2e_required: no
research_required: yes # Spike report is the deliverable
---

# Handoff: Phase 2a — `type: prompt` Contract Micro-Spike

**From:** Alex (Agent A — Solution Lead)
**To:** Blake (Agent B — Execution Master)
**Date:** 2026-04-07
**Project:** TAD Framework
**Task ID:** TASK-20260407-003
**Epic:** EPIC-20260407-domain-pack-reliable-loading.md (Phase 2a/4)
**Process Depth:** Light TAD (micro-spike)
**Type:** Contract verification spike
**Timebox:** **60 min hard cap** with explicit milestones (see §9.3)

## Expert Review Status

| Reviewer | Verdict | Findings | Resolved |
|----------|---------|----------|----------|
| code-reviewer | CONDITIONAL PASS | 4 P0 (probe 1 conflation, JSON injection, trap≠per-probe restore, session ambiguity) | ✅ All |
| backend-architect | CONDITIONAL PASS | 4 P0 (probe 1 conflation, silent ignore detection, B2 must be mandatory, 45min math fails) | ✅ All |

**Post-revision resolution**:
1. P1 split into P1a (pure fire test) + P1b ($ARGUMENTS probe)
2. Sentinel file via co-located `type: command` hook (Phase 1-proven pattern)
3. JSON injection fixed (delimiter wrapping, no $ARGUMENTS in JSON value position)
4. Explicit `restore_and_verify` function between every probe
5. Session method pinned: new terminal + `claude` interactive only
6. B2 (pre-filter) promoted from bonus to mandatory Probe
7. Timebox 45 → 60 min + T+15/T+35/T+50/T+60 milestones
8. §10 Phase 2b Input Contract (8 structured fields)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3 contract probes clearly defined |
| Components Specified | ✅ | 1 test settings snippet + 1 spike report |
| Functions Verified | ⚠️ | 本 spike 就是为了验证未知 — ACCEPTED |
| Data Flow Mapped | ✅ | user msg → prompt hook → Haiku → ??? → Alex context (the ??? is what we're testing) |

**Gate 2**: ✅ PASS

---

## 📋 Handoff Checklist

- [ ] 阅读所有章节(handoff 很短,不会超过 10 分钟)
- [ ] 阅读 Phase 1 SPIKE-REPORT §2 Mechanism Findings(`/tmp` 里 `/Users/.../SPIKE-20260407-domain-pack-hook/SPIKE-REPORT.md`)
- [ ] 理解本 spike 的**唯一目标是拿到契约**,不是建生产 hook
- [ ] 确认 45 min 上限

---

## 1. Task Overview

### 1.1 真正要解答的 3 个问题

Phase 1 spike 用 **`type: command`** hook(bash 脚本)证明了 `UserPromptSubmit` 事件存在。但 Phase 2 想用 **`type: prompt`** hook(Claude Code 内部调 Haiku,用户的 Max 套餐,无需 API key)。

**Phase 1 没验证**:`type: prompt` 对 `UserPromptSubmit` 的契约。这个组合在整个代码库里没有任何先例。

本 spike 必须回答:

1. **Q1**:`type: prompt` + `UserPromptSubmit` 的 hook 组合,事件发生时会不会真的触发?
2. **Q2**:触发后,prompt 里用什么变量访问用户消息?(现有 PreToolUse 用 `$ARGUMENTS` 访问 tool 输入 — UserPromptSubmit 是否同名?payload 是纯字符串还是 JSON envelope?)
3. **Q3**:Claude Code 怎么解析 Haiku 的响应并把内容注入成 `additionalContext`?有 3 种可能契约:
   - **Contract A**:Haiku 返回原生 envelope `{"hookSpecificOutput":{"UserPromptSubmit":{"additionalContext":"text"}}}`,Claude Code 解析并注入
   - **Contract B**:Haiku 返回任意 JSON,Claude Code 自动查找 `additionalContext` 字段
   - **Contract C**:Haiku 只能返回 `{"ok":bool,"reason":str}`(和 PreToolUse 一样),**不支持 additionalContext 注入** → 架构 A 死路
   - **Contract D**:某种我们没想到的格式

**Bonus(如果主要 probes 跑完还有时间)**:
- **B1**:真延迟 — 测 3-5 次 Haiku 调用的真实 wall clock(不是 `claude -p` proxy,是 `type: prompt` 真身)
- **B2**:Pre-filter 可行性 — 在 prompt 里加一个"short message → empty envelope"的早退规则,看 Haiku 是否遵守

### 1.2 Non-Goals (避免 scope creep)

- ❌ 不写生产 hook(Phase 2b 的事)
- ❌ 不测分类准确率(Phase 1 已经证明)
- ❌ 不修改 skill 文件
- ❌ 不写完整 test suite
- ❌ 不处理 fence wrapping(了解 Claude Code 是否自动 strip 属于 Q3 副产品)

---

## 📚 Project Knowledge (Blake 必读)

| 条目 | 相关性 |
|------|-------|
| **UserPromptSubmit Hook Verified** (architecture.md, 2026-04-07) | Phase 1 findings — **注意:该条目验证的是 `type: command`,不是 `type: prompt`** |
| **Spike-Driven Epic De-Risking** (architecture.md, 2026-04-07) | 本 spike 的方法论 |
| **Hook Shell Portability** (architecture.md, 2026-04-03) | 如需辅助 bash,必须 BSD-compatible |

---

## 2. Background Context

### 2.1 Reference File

**`.claude/settings.json` 的 PreToolUse prompt hook**(唯一的 `type: prompt` 先例):

```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "prompt",
      "prompt": "A tool is about to modify a file. Here are the full details:\n\n$ARGUMENTS\n\n[rules]\n\nRespond with JSON only: {\"ok\": true} or {\"ok\": false, \"reason\": \"...\"}",
      "model": "claude-haiku-4-5-20251001",
      "timeout": 10
    }
  ]
}
```

**观察**:
- 用 `$ARGUMENTS` 访问 tool 输入(是 JSON)
- 响应是 `{"ok":...}` 权限决策格式
- **无任何 additionalContext 注入的先例**

本 spike 就是要看看 `$ARGUMENTS` 和响应契约对 UserPromptSubmit 是不是一样。

### 2.2 Why This Matters

如果 Contract C(只支持权限决策)→ 架构 A 死。Phase 2b 必须转架构 C(关键词匹配)。
如果 Contract A/B → 知道确切 schema,Phase 2b 可以精确设计 prompt 模板。

**30 分钟换 5 小时的不确定性消除 = 划算**。

---

## 3. Requirements

### 3.1 Functional

- **FR1**: 创建 `.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/` 目录
- **FR2**: 产出 SPIKE-REPORT-PHASE2A.md 回答 Q1-Q3(bonus B1/B2 如时间允许)
- **FR3**: settings.json 修改**必须临时**,trap 恢复 + sha256 验证 byte-identical
- **FR4**: 为 Q3 的 3 个可能契约各测 1 个最简 hook 配置
- **FR5**: 如果所有 contract 测试都失败 → NO-GO verdict + 架构 C fallback 建议

### 3.2 Non-Functional

- **NFR1**: 时限 45 min(比 Phase 1 spike 更紧)
- **NFR2**: 不修改任何 skill 文件
- **NFR3**: 不引入任何生产代码

---

## 4. Technical Design

### 4.1 Test Strategy — 5 Probes (P0-1 split + P0-6 mandatory B2)

**全局规则(P0-2 Silent Ignore Detection)**:每个 prompt hook 必须**同时挂载一个 `type: command` sentinel hook**,作为"事件是否到达 hook 系统"的旁路信号。Phase 1 已验证 `type: command` UserPromptSubmit 工作。

Sentinel hook 模板(每个 Probe 都用这个伴随):

```json
{
  "type": "command",
  "command": "echo \"$(date +%s) PROMPT_EVENT_FIRED probe=$PROBE_NAME\" >> /tmp/phase2a-sentinel.log"
}
```

**判定原则**:
- Sentinel log 有内容 → hook 系统收到事件(Q1 = YES)
- Sentinel log 为空 → UserPromptSubmit 根本没触发(Q1 = NO,直接 NO-GO)
- Sentinel 有内容但 prompt hook 无效果 → `type: prompt` 被 silently dropped(Contract 不成立)

---

**Probe 1a: Q1 — 事件触发 + prompt hook 是否跑?(无副作用)**

```json
{
  "UserPromptSubmit": [{
    "matcher": "",
    "hooks": [
      {
        "type": "prompt",
        "prompt": "Wait 1 second then respond ONLY with: {\"ok\":true,\"reason\":\"P1A-FIRED\"}",
        "model": "claude-haiku-4-5-20251001",
        "timeout": 10
      },
      {
        "type": "command",
        "command": "echo \"$(date +%s) P1A-SENTINEL\" >> /tmp/phase2a-sentinel.log"
      }
    ]
  }]
}
```

**判定决策表**:

| Sentinel log | Claude Code 延迟 | Alex 看到 "P1A-FIRED" | 含义 |
|--------------|-----------------|----------------------|------|
| 空 | baseline | N/A | Q1 = NO(UserPromptSubmit 完全不触发)→ **NO-GO,结束 spike** |
| 有 P1A-SENTINEL | baseline | N/A | Sentinel 工作,但 prompt hook 被 silently dropped → Contract 全失败,进 Probe 3 对照 |
| 有 P1A-SENTINEL | ≥2s extra | 是 | Contract B 工作(自动注入 reason/ok 字段)→ ✅ |
| 有 P1A-SENTINEL | ≥2s extra | 否 | prompt hook 跑了但 Contract B 不成立 → 进 Probe 2 |

⚠️ **注意**:P1a 不引用 `$ARGUMENTS`,只测 hook 是否跑。$ARGUMENTS 的验证在 P1b。

---

**Probe 1b: Q2 — `$ARGUMENTS` 变量名和 payload shape**

仅在 P1a 证明 hook 触发后跑。

```json
{
  "UserPromptSubmit": [{
    "matcher": "",
    "hooks": [
      {
        "type": "prompt",
        "prompt": "The user input is delimited below between triple pipes. Count bytes, detect if raw string or JSON object. Respond ONLY with: {\"ok\":true,\"reason\":\"P1B form=<string|json> preview=<first 30 chars>\"}\n\n|||$ARGUMENTS|||",
        "model": "claude-haiku-4-5-20251001",
        "timeout": 10
      },
      {
        "type": "command",
        "command": "cat >> /tmp/phase2a-sentinel.log"
      }
    ]
  }]
}
```

**注意**:
- P0-3 修复:`$ARGUMENTS` 被 triple-pipe delimiter 包裹,**不再嵌入 JSON value position**。无论 $ARGUMENTS 是字符串还是 JSON,都不会破坏 prompt 的 JSON 输出约束。
- Sentinel hook 改为 `cat >>` 把 stdin(完整 hook payload)dump 到 log — 这直接告诉我们 Claude Code 传给 hook 的真实 payload 结构,**不依赖 Haiku 的观察**。

**判定**:
- 读 `/tmp/phase2a-sentinel.log` 看 Claude Code 传的 payload 真实形式(JSON envelope 还是纯字符串)
- 对比 Haiku 的 reason 字段(它从 `$ARGUMENTS` 看到什么)
- **同时拿到 Q2 的两个答案**:系统层 payload + prompt 层变量

---

**Probe 2: Contract A(explicit envelope)**

```json
{
  "UserPromptSubmit": [{
    "matcher": "",
    "hooks": [{
      "type": "prompt",
      "prompt": "Respond ONLY with this exact JSON, no markdown, no fences:\n{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"P2-ENVELOPE-TEST: If Alex sees this, Contract A works.\"}}",
      "model": "claude-haiku-4-5-20251001",
      "timeout": 10
    }]
  }]
}
```

**判定**:
- 输入任意消息
- 问 Alex "你有没有看到 P2-ENVELOPE-TEST?"
- 看到 → Contract A 工作 ✅
- 没看到 → Contract A 不工作,可能是 Contract B 或 D

**Probe 3: Test Contract C (permission gate format,对照组)**

```json
{
  "UserPromptSubmit": [{
    "matcher": "",
    "hooks": [{
      "type": "prompt",
      "prompt": "Respond ONLY with: {\"ok\": true, \"reason\": \"P3-PERMISSION-TEST\"}",
      "model": "claude-haiku-4-5-20251001",
      "timeout": 10
    }]
  }]
}
```

**判定**:
- 输入任意消息
- 观察:
  - 消息被允许 → UserPromptSubmit 接受 `{"ok":true}` 格式
  - 消息被拒 → UserPromptSubmit 也做权限 gating
  - 报错 → UserPromptSubmit 不要这个 shape
  - Alex 看到 "P3-PERMISSION-TEST" 在 context → reason 被当成 additionalContext 注入(Contract B 的证据)

**Probe 4: Pre-filter viability(MANDATORY per P0-6,阻塞 Phase 2b 的 UX 问题)**

仅在至少一个 Contract(A/B/C)工作时跑。用成功的 Contract schema + 以下 prompt:

```
CRITICAL OUTPUT RULES:
- Entire response must be a single JSON object
- No markdown fences, no preamble
- First character `{`, last character `}`

PRE-FILTER: If the user input (below between triple pipes) EXACTLY matches one of these
whitelisted short inputs, return a "skip" response immediately.
Whitelist (exact match, case-sensitive): "yes", "no", "ok", "继续", "嗯", "明白", "收到", "好的", "y", "n"

If whitelisted → respond with {"additionalContext":""} (or the confirmed Contract envelope with empty string)
Otherwise → respond with {"additionalContext":"P4-FILTER-PASSED"} (or Contract envelope)

|||$ARGUMENTS|||
```

⚠️ **P1-4 修复**:原设计用"< 30 字符"做 filter,但 LLM 数字符不可靠。改用**精确字符串白名单**,Haiku 能稳定匹配。

**测试流程**:
- 输入 "yes" → 观察:additionalContext 是否为空?延迟是否低于正常 Probe?
- 输入"做一个 React 组件" → 观察:additionalContext 是否含 P4-FILTER-PASSED?延迟是否正常?

**判定(决定 Phase 2b 的 Architecture A 是否可行)**:
- ✅ Whitelist 命中时 Haiku 真的早退 + 延迟降低 → Phase 2b 可用 pre-filter → 架构 A 可行
- ❌ Whitelist 命中时 Haiku 不遵守(仍返回 filter_passed)→ pre-filter 不可用 → Phase 2b 必须转架构 C(关键词匹配),因为 UX 延迟无法缓解

---

**B1: Real latency(optional,时间允许)**

用 Probe 1a 或 Probe 4 成功的配置,连续输入 5 条消息并粗测 wall clock:

- "做一个 React button 组件"(长)
- "我想连数据库"(中)
- "yes"(白名单短)
- "ok 继续"(白名单短)
- "做一个复杂的 E-commerce 购物车组件"(长)

**目的**:量化 baseline p50/p95 latency(n=5,只是粗测)。这个数据 Phase 2b 会用来调 `timeout` 字段。

### 4.3 Safety Envelope (P0-4: explicit per-probe restore)

settings.json 修改必须 bulletproof。**Trap 是崩溃安全网,不是正常路径** — 每个 probe 之间必须显式调用 `restore_and_verify`。

```bash
#!/bin/bash
set -euo pipefail

SETTINGS=".claude/settings.json"
BACKUP="${SETTINGS}.phase2a-backup-$(date +%s)"
SHA_BEFORE=$(shasum -a 256 "$SETTINGS" | awk '{print $1}')

# Emergency trap (crash safety net only)
cp "$SETTINGS" "$BACKUP"
trap '
  cp "$BACKUP" "$SETTINGS" 2>/dev/null || true
  echo "⚠️  TRAP FIRED — attempted emergency restore to $SETTINGS"
' EXIT INT TERM

# Normal per-probe restore (called explicitly between probes)
restore_and_verify() {
  cp "$BACKUP" "$SETTINGS"
  local SHA_NOW
  SHA_NOW=$(shasum -a 256 "$SETTINGS" | awk '{print $1}')
  if [ "$SHA_BEFORE" = "$SHA_NOW" ]; then
    echo "✅ between-probe restore OK ($(date +%T))"
  else
    echo "❌ SHA MISMATCH between probes — STOP"
    echo "   before: $SHA_BEFORE"
    echo "   after:  $SHA_NOW"
    exit 2  # triggers escalation
  fi
}

# JSON validation before any test session
validate_settings() {
  jq . "$SETTINGS" >/dev/null || {
    echo "❌ settings.json invalid after edit — restoring"
    restore_and_verify
    exit 3
  }
}

# Sentinel log reset between probes
reset_sentinel() {
  rm -f /tmp/phase2a-sentinel.log
  touch /tmp/phase2a-sentinel.log
}
```

**使用模式**(每个 probe 之间强制调用):

```bash
# Probe 1a
reset_sentinel
# ... edit settings.json ...
validate_settings
# ... run test session (see §6) ...
restore_and_verify          # MANDATORY between probes
# ... record observations ...

# Probe 1b
reset_sentinel
# ... edit settings.json ...
validate_settings
# ... run test session ...
restore_and_verify
# ... repeat for P2, P3, P4 ...
```

**Recovery protocol on sha mismatch**:
1. STOP immediately,不要进下一个 probe
2. `diff "$BACKUP" "$SETTINGS"` 看漂移内容
3. 手动 `cp "$BACKUP" "$SETTINGS"` 再校验
4. 还是 mismatch → settings.json 可能被其他进程修改了(用户的另一个 Claude Code session) → 升级给 Alex,不要继续

---

## 5. 强制问题回答

### MQ1: 历史代码搜索

```bash
jq '.hooks.PreToolUse' .claude/settings.json
grep -r "\$ARGUMENTS" .claude/
ls .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/
```

记录找到的所有 `$ARGUMENTS` 用例和 Phase 1 spike 的相关文件路径。

### MQ2: 3 个 probe 结果

| Probe | 测什么 | 观察到什么 | 判定 |
|-------|--------|-----------|------|
| P1 | 触发 + `$ARGUMENTS` + Contract B | | |
| P2 | Contract A (envelope) | | |
| P3 | Contract C (ok/reason) | | |

---

## 6. Implementation Steps (60 min hard cap with milestones)

### Session Restart Method (P0-5 — MANDATORY, pick exactly ONE)

**每个 probe 测试都用这个方法,不要用其他方式**:

1. **打开一个新的 terminal 窗口**(不是新 tab,不是 Blake 当前的 terminal)
2. `cd "/Users/sheldonzhao/01-on progress programs/TAD"`
3. 运行 `claude`(**interactive 模式,不是 `claude -p`**)
4. 等 prompt ready
5. 手动输入测试消息
6. 观察响应 + 截图 / 复制到 `observations.log`
7. 输入 `/exit`,关闭 terminal
8. 回到 Blake 自己的 terminal,运行 `restore_and_verify`

**绝对不要**:
- ❌ 在 Blake 自己的 terminal 里测试(settings.json 已在启动时加载,看不到改动)
- ❌ 用 `claude -p "msg"`(非交互模式,hook 语义可能不同)
- ❌ 同 terminal 内多个 probe 连着跑(累积状态污染)

### Pre-check: matcher field existence (from P1-5)

在写 Probe 配置前,先读 Phase 1 spike 的 hook-poc-snippet.json,确认 `matcher` 字段用法:

```bash
jq '.UserPromptSubmit[0]' .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/hook-poc-snippet.json
jq '.hooks.PreToolUse[0]' .claude/settings.json  # reference pattern
```

- Phase 1 用了 `matcher: ""` → 本 spike 照抄
- Phase 1 省略了 matcher → 本 spike 也省略
- 不确定 → 照抄 Phase 1 的精确 snippet

### Step 1: Setup (5 min,milestone T+5)

- [ ] Read Phase 1 SPIKE-REPORT §2(重点)
- [ ] 执行 Pre-check matcher
- [ ] 创建 `.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/`
- [ ] 写 safety envelope 脚本(见 §4.3 骨架)
- [ ] Backup settings.json + sha256 baseline
- [ ] `reset_sentinel`

### Step 2: Probe 1a — Event Fires + Latency Oracle (10 min,milestone T+15)

- [ ] 编辑 settings.json 加 P1a 配置(见 §4.1 Probe 1a,含 sentinel 旁路 hook)
- [ ] `validate_settings`
- [ ] 按"Session Restart Method"启动新 terminal + `claude`
- [ ] 输入 "test message for probe 1a"
- [ ] **记录**:
  - Wall-clock 延迟(和 baseline 对比 — baseline = 无 hook 状态下同类消息的响应时间,先测一个)
  - Claude Code 是否报错 / warning
  - Alex 是否主动提到 "P1A-FIRED"(不要提示 Alex,观察自发反应)
- [ ] `/exit` 新 session,回 Blake terminal
- [ ] `restore_and_verify`
- [ ] 根据 §4.1 P1a 决策表填 verdict 到 observations.log

**⏱ MILESTONE T+15**: Probe 1a 必须完成。如果没完成 → 立即升级

### Step 3: Probe 1b — $ARGUMENTS Shape Probe (10 min,milestone T+25)

仅在 Probe 1a 确认 hook 触发时跑。

- [ ] `reset_sentinel`
- [ ] 编辑 settings.json 加 P1b 配置(sentinel hook 改为 `cat >>` dump 完整 stdin)
- [ ] `validate_settings`
- [ ] 新 terminal + `claude`,输入 "probe 1b payload check with some content"
- [ ] **记录**:
  - `cat /tmp/phase2a-sentinel.log` 输出(这是 Claude Code 传给 hook 的真实 payload)
  - Haiku reason 字段内容(这是 prompt 看到的 $ARGUMENTS)
  - 两者是否一致?形式是 string 还是 JSON?
- [ ] `/exit`,`restore_and_verify`

### Step 4: Probe 2 — Contract A explicit envelope (10 min,milestone T+35)

- [ ] `reset_sentinel`
- [ ] 编辑 settings.json 加 Probe 2 配置(§4.1 Probe 2 — 原 Contract A envelope)
- [ ] `validate_settings`
- [ ] 新 terminal + `claude`,输入 "probe 2 test"
- [ ] **记录**:Alex 是否看到 P2-ENVELOPE-TEST?
- [ ] `/exit`,`restore_and_verify`

**⏱ MILESTONE T+35**: P1a + P1b + P2 必须完成。进度 checkpoint

### Step 5: Probe 3 — Contract C permission gate format (5 min)

仅在 P1a 显示 sentinel 有内容 + Alex 没看到任何 additionalContext 时跑(即 Contract B 和 Contract A 都失败的情况)。

- [ ] 同上流程,配置见 §4.1 Probe 3
- [ ] `restore_and_verify`

如果 P1a/P2 已经确认某个 Contract 工作,**跳过 P3** 节省时间给 P4。

### Step 6: Probe 4 — Pre-filter Viability (MANDATORY, 10 min,milestone T+50)

**仅在至少一个 Contract 工作时**跑(否则 Phase 2b 注定要转架构 C,pre-filter 测试无意义)。

- [ ] `reset_sentinel`
- [ ] 编辑 settings.json 用成功 Contract 的 schema 包装 §4.1 Probe 4 的 prompt
- [ ] `validate_settings`
- [ ] 新 terminal + `claude`
- [ ] 输入两条:
  - "yes"(白名单命中)
  - "做一个 React 组件"(非白名单)
- [ ] **记录**:
  - "yes" 的延迟 vs baseline
  - "yes" 是否产生 P4-FILTER-PASSED(应该**没有**)
  - 长消息是否正常产生 P4-FILTER-PASSED
- [ ] `/exit`,`restore_and_verify`

**⏱ MILESTONE T+50**: Probe 4 完成(或明确说明为何跳过)

### Step 7: Write SPIKE-REPORT (10 min,milestone T+60)

- [ ] 填满 §10 结构化 Phase 2b Input Contract(8 个字段)
- [ ] Verdict + 决策表
- [ ] 诚实标注所有不确定性
- [ ] architecture.md 知识条目草稿(AC8)

**⏱ MILESTONE T+60**: REPORT 必须存在。即使部分完成也要 commit。

### Bonus: Probe B1 — Latency baseline (只有时间富余时跑)

看上面 Step 7 完成后是否还有时间。如无 → 跳过,Phase 2b 开始时再做。

---

## 7. File Structure

### 7.1 Files to Create

```
.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/
├── SPIKE-REPORT-PHASE2A.md    # 最终交付
├── probe-1-hook-config.json   # P1 的 settings 片段
├── probe-2-hook-config.json   # P2 的片段
├── probe-3-hook-config.json   # P3 的片段(如用到)
└── observations.log            # 原始观察/截图描述
```

### 7.2 Files to Modify (temporarily)

- `.claude/settings.json` — **每个 probe 后必须恢复**,sha256 验证

---

## 8. Acceptance Criteria

- [ ] **AC1**: Spike 文件存在于 `.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/`,最少含 SPIKE-REPORT-PHASE2A.md + observations.log + 各 probe 配置 json 片段
- [ ] **AC2**: SPIKE-REPORT-PHASE2A.md §1 含明确 verdict(GO / NO-GO / PARTIAL)+ confirmed contract type (A/B/C/D/NONE)
- [ ] **AC3**: Probe 1a + 1b + 2 + 4 全部执行(P3 允许跳过,需说明原因)
- [ ] **AC4**: settings.json 最终 sha256 与 spike 开始前 byte-identical(每个 probe 之间的 restore_and_verify 日志作为 audit trail)
- [ ] **AC5**: Sentinel log(`/tmp/phase2a-sentinel.log`)每个 probe 产生数据并被保存到 observations.log
- [ ] **AC6**: SPIKE-REPORT §10 所有 8 个字段都填了(至少写 "unknown" + reason,不能空)
- [ ] **AC7**: 时限 60 min 硬上限,每个 milestone 超时立即按 §9.3 表格行动
- [ ] **AC8**: architecture.md 条目更新草稿(扩展现有 UserPromptSubmit Verified 条目,增加 `type: prompt` 子节,**不新建独立条目**)放在 SPIKE-REPORT §11
- [ ] **AC9**: Probe 4(pre-filter)是 mandatory — 跳过唯一合理原因是所有 contract 都 NO-GO
- [ ] **AC10**: B1(latency baseline)是真正的 bonus,跳过 OK
- [ ] **AC11**: 每个 probe 的 settings.json 修改 100% 使用 `restore_and_verify` 之间的 checkpoint(P0-4 修复)
- [ ] **AC12**: 所有 session restart 100% 使用 `claude` interactive in a **new** terminal(P0-5 修复)
- [ ] **AC13**: Probe 1a 的 sentinel hook 和 prompt hook 共存是否工作,被显式记录(P1-4 co-existence 预检)

## 8.1 Spec Compliance

| # | AC | Verification |
|---|----|----|
| AC1 | `ls .tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/` | 最少 3 个文件 |
| AC2 | `grep -E "Verdict|Contract type" SPIKE-REPORT-PHASE2A.md` | 含 verdict 和 contract |
| AC4 | `shasum -a 256 .claude/settings.json` vs baseline | 一致 |
| AC6 | SPIKE-REPORT 中 10.1-10.8 小节 | 8 小节全存在 |
| AC8 | `grep "UserPromptSubmit" SPIKE-REPORT-PHASE2A.md` | 含草稿更新 |

---

## 9. Important Notes

### 9.1 Critical Warnings

- ⚠️ **settings.json 是 daily driver** — 每个 probe 之间**必须**恢复 + sha256 校验。不能累积修改
- ⚠️ **不要引入生产代码** — 这是 spike,所有配置都是临时的
- ⚠️ **不要扩大范围** — 看到别的有趣问题,记到 follow-up notes,不现场探究
- ⚠️ **时限硬上限 45 min** — Phase 1 spike 实际 50 min,这个更窄,超时立即停
- ⚠️ **如果 probes 需要手动输入消息** — 每次启动新 session 保持环境干净(避免上次 session 的 state 污染)
- ⚠️ **Haiku fence wrapping** — Phase 1 已知 Haiku 总 wrap JSON in ```json。Probe 判定要看 Claude Code 是否自动 strip(这是 Q3 的一部分)

### 9.2 What NOT to do

- ❌ 不要写完整 run-spike.sh(保持简单,bash one-liners 或简短脚本)
- ❌ 不要测 14 个或 20 个 pack 的分类(Phase 1 已经测过类似的了)
- ❌ 不要为了"漂亮报告"延长时间 — 够答 Q1-Q3 就够
- ❌ 不要尝试 workaround 如果 contract 全失败 — NO-GO 报告就是有效输出

### 9.3 Escalation Triggers + Timebox Milestones

**Timebox milestones**(60 min hard cap,超每个都立即升级):

| 时点 | 必须完成 | 失败 action |
|------|---------|-----------|
| T+5 | Setup + Pre-check + baseline | 升级 |
| T+15 | Probe 1a | 升级(hook 机制可能有更深问题)|
| T+25 | Probe 1b | 降级:跳过 Probe 4 Bonus,保 P2+P3+REPORT |
| T+35 | Probe 2 | 立即停 probing,直接写 REPORT(部分结果优于无结果)|
| T+50 | Probe 4 (or explicit skip) | 跳过 B1 latency bonus |
| **T+60** | **SPIKE-REPORT-PHASE2A.md committed** | 硬上限,无论状态立即停 |

**Escalation Triggers**(立即停止 + 升级给 Alex):
1. 任何 probe 让 Claude Code 崩溃或进入坏状态
2. settings.json sha256 不 match(restore_and_verify 失败)
3. 任何 milestone 超时(见上表)
4. 发现全新的未知(例:Claude Code 版本不支持 UserPromptSubmit prompt hook 类型)
5. Probe 1a sentinel log 为空(事件根本不触发)→ 直接写 NO-GO REPORT 然后结束,不要试 Probe 2/3/4
6. 发现架构 A 根本不可行 → 写 REPORT 含架构 C fallback 建议,结束 spike

---

## 10. Phase 2b Input Contract — SPIKE-REPORT §10 必须填满这 8 个字段

SPIKE-REPORT-PHASE2A.md 必须包含一个 §10 章节,Blake 回答以下所有字段(如无法回答,写 "unknown — blocked by <cause>"):

```markdown
## §10 Phase 2b Design Inputs

10.1 Confirmed contract type: <A | B | C | D | NONE>
     - A = explicit hookSpecificOutput envelope
     - B = auto-find additionalContext field
     - C = permission-gate-only (PreToolUse-style)
     - D = other (describe)
     - NONE = no contract works → Phase 2b must switch to architecture C

10.2 Exact response schema (copy-pasteable JSON template that Claude Code accepted):
     {
       "<field>": "<type>",
       ...
     }
     (If NONE: leave blank, explain why in 10.7)

10.3 Input variable(s):
     - prompt template variable: <$ARGUMENTS | other name | unknown>
     - payload shape: <raw string | JSON envelope with fields {...} | unknown>
     - source: sentinel dump vs Haiku observation

10.4 Fence stripping behavior:
     - Haiku always wraps in ```json: <yes | no>
     - Claude Code auto-strips: <yes | no | unknown>
     - If NO strip: Phase 2b prompt must use stricter format lock

10.5 Pre-filter (Probe 4) viability:
     - Whitelist exact match works: <yes | no | partial>
     - Short-input latency vs long-input latency: <value ms | not measured>
     - If NO: Phase 2b MUST switch to architecture C

10.6 Baseline latency observations (from Probe 1a latency oracle + Probe 4):
     - no-hook baseline: ~<N>ms
     - with prompt hook (short msg): ~<N>ms
     - with prompt hook (long msg): ~<N>ms
     - UX impact estimate: <tolerable | painful | unusable>

10.7 Known failure modes encountered + workarounds:
     - <list any unexpected behavior>
     - <workaround if any>

10.8 Open questions for Phase 2b:
     - <any residual unknowns Phase 2b will need another micro-test for>
```

## 11. Decision Rationale

### 为什么 Phase 2 要拆成 2a + 2b?

专家审查(code-reviewer + backend-architect)在原 Phase 2 handoff 上发现 4 个 P0:
1. 契约未验证(本 spike 解决)
2. Pack count 错(Alex 说 14,实际 20 — 修 Phase 2b 时修正)
3. Latency UX 火坑(本 spike 测真数据 + 测 pre-filter)
4. Skill checkpoint 假防御(Phase 2b 时诚实化)

P0-2(成本 50x)被用户的 Max 套餐事实消除。剩下 3 个 P0,其中 P0-1 和 P0-3 的数据由本 spike 提供,P0-4 是 Phase 2b 的文档修正。

**30 分钟 spike = 5 小时 Phase 2b 的风险降级**。这就是 Epic 1 Phase 1 学到的 "Measure Before Optimizing" 模式。

---

**Handoff Created By**: Alex
**Date**: 2026-04-07
**Status**: Draft — pending expert review
