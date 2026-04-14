---
task_type: mixed
e2e_required: no
research_required: no
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-13
**Project:** TAD Framework
**Task ID:** TASK-20260413-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260413-symmetric-quality-enforcement.md (Phase 1a/6)
**Linear:** N/A
**Type:** Light TAD Spike (4-6h hard cap)
**Priority:** P0

---

## Expert Review Status

| Expert | Focus | Verdict | P0 Count | P0 Resolution |
|--------|-------|---------|----------|---------------|
| code-reviewer | Type safety, testing, exec order, scope | CONDITIONAL PASS | 5 | All resolved in v2 (PostToolUse→PreToolUse, schemas, paths, self-validation, step order) |
| security-auditor | Bypass surface, override injection, log integrity | **FAIL** | 7 | 3 resolved in v2 (fail-closed, override format, PreToolUse); 4 deferred to **Phase 1b** (sentinel bypass ≥8, evidence forgery, override injection vectors, log tamper) per scope-split recommendation |
| performance-optimizer | Latency methodology, PreToolUse cost, N=30 | CONDITIONAL PASS | 4 | All resolved in v2 (end-to-end measurement, budget decomposition, PreToolUse fast-path test, N=30 + p95) |

**Overall**: CONDITIONAL PASS (v2). v1 failed security; v2 fixes in-scope P0s and explicitly defers adversarial robustness to Phase 1b spike.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-04-13 (post expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | PreToolUse Write 为核心拦截机制（已验证存在 — settings.json 已有 PreToolUse prompt hook）；三个 experiment 机制对齐 |
| Components Specified | ✅ | §4.2.1 含完整 stdin/stdout JSON schema；`{slug}` 定义明确 |
| Functions Verified | ✅ | `read_stdin_json`、`output_response` 复用（Epic 1 Phase 2b 已验证）|
| Data Flow Mapped | ✅ | PreToolUse Write → sentinel check → evidence check → permissionDecision JSON → allow/deny |
| Scope Discipline | ✅ | 对抗测试（≥8 bypass、forgery、log 篡改）显式移至 Phase 1b |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 本文档是 Light TAD spike Phase 1a，scope 严格限定在**机制存在性验证**。对抗鲁棒性验证已拆分到 Phase 1b。Blake 可独立执行。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图：**验证 3 个机制是否存在，不涉及对抗鲁棒性**
- [ ] 每个 Experiment 的交付物和 evidence 要求都清楚
- [ ] 确认 4-6h 时间盒 —— 到点即停，报告 PARTIAL 也行
- [ ] 明确 out-of-scope：sentinel bypass ≥8 种、evidence forgery、log 篡改测试 → 全部 Phase 1b 做

❌ 如果任何部分不清楚，**立即返回 Alex 要求澄清**。

---

## 1. Task Overview

### 1.1 What We're Building

Phase 1a Spike：验证 Claude Code hook 机制**基础机制存在性** —— 3 个机制：

1. **拦截能力（PreToolUse Write）** — 当 Write 内容含 sentinel 字符串 `Message from Blake` 且 `.tad/evidence/reviews/blake/{slug}/` 下 `.md` 文件数 < 2 时，hook 通过 `permissionDecision: "deny"` 阻止文件创建（**PreToolUse，不是 PostToolUse**）
2. **Override 识别（UserPromptSubmit）** — 当人类 prompt 匹配格式 `TAD_OVERRIDE: <gate> <reason ≥20 chars>` 时，hook 识别并追加日志到 `.tad/evidence/overrides/spike-test.log`；格式不合规（缺 gate、reason 太短）时不写日志
3. **基础 evidence 结构验证** — checker 脚本读 `.md` 文件：size > 100B + 含 `Overall: PASS` 或 `Overall: FAIL`（行首锚定 `^Overall: `）→ exit 0 有效；否则 exit 1 无效 + 原因

### 1.2 Why We're Building It

**业务价值**：文字约束（MANDATORY）被 LLM 系统性合理化。本 spike 验证"机械强制"的基础机制是否可实现，为 Phase 2 架构提供 go/no-go 信号。

**用户受益**：如 GO → Phase 1b 做对抗测试 → Phase 2-5 设计实现 → 质量链真正被执行。

**成功的样子**：Blake 试图 Write 含 sentinel 的 content 而 evidence 不足时，Write **在落盘前被 permissionDecision=deny 阻止**，错误信息清晰列出缺失的 evidence。

### 1.3 Intent Statement

**真正要解决的问题**：验证 Claude Code 的 PreToolUse Write + UserPromptSubmit + 基础内容 checker 三件套是否可行。

**不是要做的（Phase 1a 范围外）**：
- ❌ 不是对抗鲁棒性测试（Phase 1b 单独做）
- ❌ 不是测 ≥8 种 sentinel bypass（Phase 1b）
- ❌ 不是 evidence 伪造抵抗（Phase 1b）
- ❌ 不是 log 完整性（Phase 1b）
- ❌ 不是生产级 quality-enforcement.sh（Phase 3）
- ❌ 不是 SKILL.md 修改（Phase 3）
- ❌ 不是 Haiku 内容判断（方案已排除）

**Blake 请确认理解**：

```
在开始实现前，请用你自己的话回答：
1. Phase 1a 验证什么 3 个机制？
2. 哪些对抗测试 Blake 不做（因为是 1b 的范围）？
3. PreToolUse vs PostToolUse 的关键区别是什么？为什么用 PreToolUse？
4. PARTIAL / NO-GO 的阈值是什么？

Human 确认理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files
2. Read the handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional

### 步骤 1：识别相关类别

- [x] architecture - 架构决策
- [x] security - 安全（但仅基础 fail-closed，不含对抗测试）

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 9 条直接相关 | Hook 机制、shell 可移植性、性能、Spike 模式 |
| security.md | 1 条 | Security pack 跨切审查模式（参考） |

**⚠️ Blake 必须注意的历史教训**（全部来自 `.tad/project-knowledge/architecture.md`）：

1. **Claude Code Native Mechanism Validation — Hooks > Skill Frontmatter (2026-03-31)**
   - 问题：skill frontmatter 不可靠
   - 解决方案：**`settings.json` 全局 hooks 是唯一可靠 enforcement primitive**
   - Event key **PascalCase**：`PreToolUse` / `PostToolUse` / `SessionStart` / `UserPromptSubmit`

2. **UserPromptSubmit Hook Verified — 4th Validated Hook Event (2026-04-07)**
   - 已验证 Claude Code 2.1.92 支持
   - stdin JSON 含 `prompt` 字段，读取：`jq -r '.prompt'`
   - **`type: prompt` 是权限 gate only**（返回 `{ok:bool}`，不能注入 context）
   - 本 spike 的 UserPromptSubmit 和 PreToolUse 都用 **`type: command`**

3. **Hook Performance: Single-awk vs Per-item grep Loop (2026-04-07)**
   - 单 awk 进程 84ms median（20 packs × 12 keywords）
   - 环境变量传递：**必须 `ENVIRON["VAR"]`**，不是 `-v var=$msg`（后者解释 `\n` 转义）
   - 环境变量赋值位置：**必须在 awk 命令前**，不是前置 pipeline stage
   - 本 spike exp1 的 sentinel 匹配必须用此模式

4. **`claude -p` is a Valid UserPromptSubmit Hook Testing Channel (2026-04-07)**
   - 对 hook fire + injection 验证有效
   - **不适合 latency 测量**（3-5s cold start）
   - Phase 1a 性能测量用 `time bash exp*.sh < fixture.json`（script-only）

5. **Hook Shell Portability: No grep -P on macOS (2026-04-03)**
   - **不用 `grep -P`**（BSD grep 不支持）
   - 用 `grep -o` + `sed` 或 awk

6. **Hook Path Matching: Glob Prefix Must Handle Relative Paths (2026-04-02)**
   - 用 `*.tad/` 不用 `*/.tad/`（后者不匹配 `.tad/`）

7. **Spike-Driven Epic De-Risking with Light TAD (2026-04-07)**
   - 本 spike 复刻此模式：时间盒 + 多轴 verdict + 预留 forward-compat schema
   - PARTIAL 可接受，不强求 binary GO/NO-GO

8. **Epic Architecture Pivot Through Successive Spikes (2026-04-07)**
   - Phase 1a NO-GO → Phase 2 架构需重新设计，不要硬推

9. **Claude Code Enforcement Priority Order (2026-03-31)**
   - **关键：PreToolUse 能阻止工具调用，PostToolUse 不能**
   - PostToolUse 在 tool 执行后才 fire，文件已落盘；deny 只能反馈给模型，无法撤销
   - 本 spike v1 错误设计为 PostToolUse（已纠正，见 §4.1）

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 我理解 PreToolUse vs PostToolUse 的本质区别

---

## 🔧 Domain Pack References (Blake 必读)

**Loaded Packs:**

| Pack | File | Matched Capabilities |
|------|------|---------------------|
| ai-agent-architecture | `.tad/domains/ai-agent-architecture.yaml` | `safety_design`, `role_behavior_design` |
| ai-evaluation | `.tad/domains/ai-evaluation.yaml` | `regression_testing`（adversarial_testing 移至 Phase 1b）|

**最关键的 pack 指导**：

- `ai-agent-architecture → safety_design → quality_criteria` 第 6 条：
  > "降级策略是 fail-closed（不是 fail-open）"
  
  这直接决定 AC14：**hook 崩溃默认 deny**。

- `ai-agent-architecture → role_behavior_design → anti_patterns` 第 2 条：
  > "只用 prompt MANDATORY（没有 hook/architecture 层 enforce = 建议不是规则）"
  
  这是**本 Epic 的根本命题**。

---

## 2. Background Context

### 2.1 Previous Work

TAD 现有 hook 基础设施：
- `.tad/hooks/lib/common.sh` — `read_stdin_json`, `output_response`（Epic 1 Phase 2b 验证）
- `.tad/hooks/userprompt-domain-router.sh` — UserPromptSubmit `type: command` + awk 单进程模式
- `.claude/settings.json` **已存在** `PreToolUse Write|Edit` (type: prompt, Haiku gate) — 证明 PreToolUse Write 可用

### 2.2 Current State

- Alex 跳过 Socratic / 专家审查
- Blake 跳过 Layer 2 / Completion Report / Gate 3
- 两者都知道规则但选择绕过 → 需机械强制

### 2.3 Dependencies

- macOS 默认工具：bash / awk / jq / find（无外部依赖）
- `.tad/hooks/lib/common.sh` 已存在

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**：创建 spike 目录 `.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/` 放所有 experiment 产出
- **FR2**：Experiment 1 — 验证 **PreToolUse Write** 的内容模式拦截
  - 当 `tool_name == "Write"` 且 `tool_input.content` 匹配 sentinel `Message from Blake`（大小写不敏感，允许任意空白）且 `.tad/evidence/reviews/blake/{slug}/*.md` 数 < 2 时 → 返回 `permissionDecision: "deny"`
  - 否则 → 返回 `permissionDecision: "allow"`（空响应也视为 allow）
  - `{slug}` 定义：从 `tool_input.file_path` 提取 handoff slug（正则 `HANDOFF-[0-9]{8}-([a-z0-9-]+)` 的捕获组 1）；若路径不含则用默认值 `spike-default` 作测试
- **FR3**：Experiment 2 — 验证 **UserPromptSubmit** 的 Override 格式识别
  - 当 `prompt` 匹配 `^TAD_OVERRIDE: (\S+) (.{20,})$`（行首 + gate 名 + 理由 ≥20 字符）→ 追加 `{ISO timestamp} gate={1} reason={2}` 到 `.tad/evidence/overrides/spike-test.log`
  - 否则不写日志
  - **注意：格式严格是 1a 要求；注入攻击抵抗移至 1b**
- **FR4**：Experiment 3 — 基础 evidence 结构 checker
  - 输入：`.md` 文件路径
  - 检查：文件存在 + size > 100 字节 + 含 `^Overall: (PASS|FAIL)$`（`grep -E` 行首锚定，单词锚定）
  - 输出：exit 0 valid / exit 1 invalid；stderr 打印失败原因（具体到哪条检查失败）
  - **注意：伪造抵抗（padding / stale / copy-paste）移至 1b**
- **FR5**：Fail-closed 验证 — 构造一个必定崩溃的 stdin（如 `{"malformed json`），确认 exp1 hook 返回 `permissionDecision: "deny"`（不是 allow）
- **FR6**：产出 `SPIKE-REPORT.md`，含 3 个 experiment 的结果 + 性能数据（N=30, median + p95 + max）+ fail-closed 测试结果 + GO/PARTIAL/NO-GO 决策 + Phase 1b 建议

### 3.2 Non-Functional Requirements

- **NFR1（性能，两个指标）**：
  - Script-only median < 200ms（`time bash exp1-hook.sh < fixture.json`，N=30，去除前 3 次 warm-up）
  - p95 < 300ms
  - 必须含**逐步 latency 分解**（jq / awk / find / output），用 `date +%s%N` 打 checkpoint
  - e2e `claude -p` 测量**不**要求（Epic 1 已证 hook 能 fire，本 spike 只测 script 性能）
- **NFR2（时间盒）**：**4-6 小时硬上限**，到点立即停
- **NFR3（隔离）**：**不修改 `.claude/settings.json`**。Blake 用 `bash exp*.sh < fixture.json` 直接 pipe 测试，不经 Claude Code 端到端调用
- **NFR4（可回滚）**：所有修改在 `.tad/evidence/spikes/SPIKE-*/` 内；完成后可完整删除
- **NFR5（fail-closed）**：hook 脚本用 `set -euo pipefail`；trap ERR 输出 `permissionDecision: "deny"` 后退出

---

## 4. Technical Design

### 4.1 Architecture Overview

```
┌─────────────────┐
│  Blake/Alex    │
│  Write tool     │  (tool call)
└────────┬────────┘
         │ PreToolUse fires (BEFORE tool executes)
         ▼
┌──────────────────────────────────┐
│ PreToolUse Write hook            │  type: command, bash+awk+jq
│ Input:  stdin JSON envelope       │
│ Match:  tool_input.content sentinel │
│ Check:  .tad/evidence/reviews/blake/{slug}/*.md ≥ 2 │
│ Output: permissionDecision JSON   │
└──────────────┬───────────────────┘
               │
       ┌───────┴────────┐
       │                │
    ALLOW            DENY
   tool runs      tool blocked    ✅ file never written
   file written   + reason msg to model

┌─────────────────┐
│ Human prompt    │  "TAD_OVERRIDE: gate3 reason with at least 20 chars"
└────────┬────────┘
         │ UserPromptSubmit fires
         ▼
┌──────────────────────────────────┐
│ UserPromptSubmit hook (type:cmd) │
│ Parse: .prompt via jq             │
│ Match: ^TAD_OVERRIDE: <g> <r>$    │
│ If match → append log, allow      │
│ If not   → no log, allow          │
└──────────────────────────────────┘
         │
    session continues (no block — override is informational)
```

### 4.2 Component Specifications

**Experiment 1 — PreToolUse Write interceptor**
- 文件：`.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/exp1-pretool-interceptor.sh`
- Stdin: JSON envelope（schema §4.2.1）
- Logic:
  1. `set -euo pipefail`; `trap 'echo {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"hook crashed - fail closed"}}; exit 1' ERR`
  2. 单次 jq: `jq -r '[.tool_name, .tool_input.file_path, .tool_input.content] | @tsv' < stdin`
  3. tool_name != "Write" → allow
  4. awk sentinel match with `CONTENT="$content" awk 'BEGIN { if (index(tolower(ENVIRON["CONTENT"]), "message from blake") > 0) exit 0; exit 1 }'`
  5. 不匹配 → allow
  6. 匹配 → 从 file_path 提取 slug（`grep -oE 'HANDOFF-[0-9]{8}-[a-z0-9-]+' | sed ...`；失败用 `spike-default`）
  7. `count=$(find .tad/evidence/reviews/blake/"$slug" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')`
  8. count < 2 → deny with reason；≥ 2 → allow
- Stdout: §4.2.1 JSON

**Experiment 2 — UserPromptSubmit Override detector**
- 文件：`exp2-override-detector.sh`
- Stdin: JSON envelope with `prompt` field
- Logic:
  1. `set -euo pipefail`; ERR trap → print empty output and exit 0（UserPromptSubmit fail-closed 语义 = 不特殊处理 prompt，相当于 allow，因为 override 检测失败不应阻塞人类消息）
  2. `prompt=$(jq -r '.prompt' < stdin)`
  3. `if [[ "$prompt" =~ ^TAD_OVERRIDE:\ ([^[:space:]]+)\ (.{20,})$ ]]`（bash regex，不用 grep -P）
  4. 匹配 → `mkdir -p .tad/evidence/overrides`; `printf '%s gate=%s reason=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" >> .tad/evidence/overrides/spike-test.log`
  5. 输出空（allow）

**Experiment 3 — Evidence content validator**
- 文件：`exp3-evidence-validator.sh`
- 参数：`$1` = `.md` 文件路径
- Logic:
  1. `set -euo pipefail`
  2. 文件不存在 → `echo "FAIL: file not found" >&2; exit 1`
  3. size=$(wc -c < "$1" | tr -d ' '); size ≤ 100 → `echo "FAIL: too small ($size bytes)" >&2; exit 1`
  4. `grep -qE '^Overall: (PASS|FAIL)$' "$1"` || → `echo "FAIL: missing '^Overall: (PASS|FAIL)$' line" >&2; exit 1`
  5. exit 0

### 4.2.1 Exact stdin/stdout JSON Schemas

**PreToolUse stdin envelope** (confirmed by Epic 1 Phase 2a probe):
```json
{
  "session_id": "string",
  "transcript_path": "string (absolute path)",
  "cwd": "string",
  "permission_mode": "string",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "string (absolute or relative)",
    "content": "string"
  }
}
```

**PreToolUse hook stdout (allow)**:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```
空 stdout 也视为 allow（Claude Code 默认行为）。

**PreToolUse hook stdout (deny)**:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Missing evidence: .tad/evidence/reviews/blake/{slug}/*.md has 0 files, need ≥2. Please run Layer 2 expert review before generating Message to Alex."}}
```

**UserPromptSubmit stdin envelope** (confirmed Epic 1 Phase 2a):
```json
{
  "session_id": "string",
  "transcript_path": "string",
  "cwd": "string",
  "permission_mode": "string",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "string (user's actual message, may have trailing \\n)"
}
```

**UserPromptSubmit hook stdout**: 空（don't block，不注入 context）

### 4.3 Data Models

```
.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/
├── exp1-pretool-interceptor.sh     # PreToolUse Write (NOT PostToolUse)
├── exp2-override-detector.sh       # UserPromptSubmit
├── exp3-evidence-validator.sh      # Content checker
├── test-fixtures/                  # Build BEFORE running validators
│   ├── minimal-stdin-pretool-match-missing.json    # matches sentinel, evidence missing
│   ├── minimal-stdin-pretool-match-ok.json         # matches sentinel, evidence ≥2
│   ├── minimal-stdin-pretool-no-match.json         # no sentinel
│   ├── minimal-stdin-pretool-malformed.json        # deliberate invalid JSON (fail-closed test)
│   ├── minimal-stdin-override-valid.json           # TAD_OVERRIDE with ≥20 char reason
│   ├── minimal-stdin-override-too-short.json       # TAD_OVERRIDE with <20 char reason
│   ├── minimal-stdin-override-not-present.json     # normal prompt
│   ├── fake-empty-review.md                        # expected invalid (size)
│   ├── fake-missing-keyword.md                     # expected invalid (no Overall:)
│   ├── fake-valid-review.md                        # expected valid
│   └── seed-evidence/                              # pre-populate for "ok" test: 2x .md files
├── test-runner.sh                  # Driver (fixtures → run → record results)
├── results/                        # Populated by test-runner
│   ├── exp1-latencies-ms.tsv       # 30 lines of ms numbers + per-step breakdown
│   ├── exp1-decisions.tsv          # fixture → decision → reason
│   ├── exp2-override.log           # Cleaned log of exp2 runs
│   ├── exp3-validation-output.tsv  # fixture → exit_code → stderr
│   └── failclosed-test-output.tsv  # malformed stdin → decision
└── SPIKE-REPORT.md                 # Final GO/PARTIAL/NO-GO
```

### 4.4 API Specifications
N/A

### 4.5 UI Requirements
N/A

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索 — [x] 是

Blake 在开始前必须 Read：
```bash
cat .tad/hooks/lib/common.sh
cat .tad/hooks/userprompt-domain-router.sh
cat .claude/settings.json  # 查看现有 PreToolUse Write|Edit 配置格式
```

### MQ2: 函数存在性验证

| 函数/机制 | 位置 | 用途 | 验证 |
|---------|------|------|------|
| `read_stdin_json` | `.tad/hooks/lib/common.sh` | 读 hook stdin | ✅ 存在 |
| `output_response` | `.tad/hooks/lib/common.sh` | 输出 hook JSON | ✅ 存在 |
| PreToolUse Write matcher | `.claude/settings.json` | Claude Code 已支持此 hook event | ✅ 已有 `PreToolUse` 配置 |
| `permissionDecision` JSON | Claude Code 文档 | deny 机制 | ✅ 记忆 2026-03-31 已验证 |

### MQ3: 数据流完整性

| Hook | Stdin input | Check logic | Stdout output | Verification |
|------|-------------|-------------|---------------|--------------|
| exp1 PreToolUse Write | tool_name + file_path + content | sentinel match → evidence dir count | permissionDecision allow/deny | 4 fixture 覆盖 4 种组合 |
| exp2 UserPromptSubmit | prompt | regex `^TAD_OVERRIDE: (\S+) (.{20,})$` | empty + log side-effect | 3 fixture 覆盖 valid/短/不存在 |
| exp3 CLI arg | `.md` file path | exists + size + keyword | exit 0/1 + stderr reason | 3 fixture 覆盖 valid/空/缺关键字 |

### MQ4: 视觉层级
N/A

### MQ5: 状态同步
单一状态存储：`.tad/evidence/overrides/spike-test.log`（唯一写入点，无同步问题）

---

## 6. Implementation Steps

### 6.1 Micro-Tasks (reordered per code-reviewer P1-2)

| # | File | Operation | Verification | Est. Time |
|---|------|-----------|--------------|-----------|
| 1 | `.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/` + `test-fixtures/` + `results/` + `test-fixtures/seed-evidence/` | 创建目录结构 | `ls -d .tad/evidence/spikes/SPIKE-20260413-quality-enforcement/{test-fixtures,results,test-fixtures/seed-evidence}` | 5 min |
| 2 | `test-fixtures/fake-*.md` (3 files) | 构造 3 份 exp3 fixture | `wc -c fake-*.md`；`grep -E '^Overall: '` | 15 min |
| 3 | `test-fixtures/seed-evidence/*.md` (2 files) | 构造 2 份预备 "evidence OK" 场景的占位文件 | `ls seed-evidence/*.md \| wc -l` → 2 | 5 min |
| 4 | `test-fixtures/minimal-stdin-*.json` (7 files) | 构造 §4.3 列的 7 个 stdin fixture（含 malformed 用于 fail-closed 测试） | `jq . minimal-stdin-pretool-*.json` 合法的 6 个通过，malformed 1 个报错（预期）| 20 min |
| 5 | `exp3-evidence-validator.sh` | 写 checker（size + keyword） | `bash exp3-evidence-validator.sh test-fixtures/fake-empty-review.md` exit 1；`bash exp3-evidence-validator.sh test-fixtures/fake-valid-review.md` exit 0 | 20 min |
| 6 | `exp2-override-detector.sh` | 写 UserPromptSubmit hook | `jq . test-fixtures/minimal-stdin-override-valid.json \| bash exp2-override-detector.sh` → log 增加一条；invalid fixtures → log 不变 | 40 min |
| 7 | `exp1-pretool-interceptor.sh` | 写 PreToolUse Write hook（含 fail-closed trap） | 4 fixtures → 4 种预期 decision | 60 min |
| 8 | `test-runner.sh` | 一键驱动：(a) 跑 exp3 on 3 fixtures；(b) 跑 exp2 on 3 fixtures；(c) 跑 exp1 on 4 fixtures 各 30 次（warm-up 3 + 测量 30）；(d) 跑 exp1 on malformed fixture（fail-closed 检查）；(e) 汇总 results/ | `bash test-runner.sh`; `ls results/` 5 files | 45 min |
| 9 | `SPIKE-REPORT.md` | 写 GO/PARTIAL/NO-GO 报告（含 §9 AC 列表的结构 + per-step latency 分析 + Phase 1b 建议列表） | `bash exp3-evidence-validator.sh SPIKE-REPORT.md` → exit 0（dogfooding 自验证） | 60 min |

**总估算**：4h 30min（低于 6h 上限，留缓冲给意外调试）

### Phase 1a 交付物

- [ ] 9 个 micro-task 全部完成
- [ ] `SPIKE-REPORT.md` 产出 GO / PARTIAL / NO-GO 决策
- [ ] fail-closed 测试结果记录在 `results/failclosed-test-output.tsv`
- [ ] Phase 1b 建议清单（至少涵盖 security-auditor 原始 P0 未解决项：sentinel bypass ≥8、evidence forgery、override 注入、log 完整性）

### Phase 1a 完成证据（Blake 必须提供）

- [ ] `results/exp1-latencies-ms.tsv` 含 30 行 + per-step 分解（jq / awk / find / output 各自 ms）
- [ ] `results/exp1-decisions.tsv` 含 4 个 fixture 的决策矩阵（全部符合预期）
- [ ] `results/exp2-override.log` 证明匹配的 log 增加、不匹配的 log 不变
- [ ] `results/exp3-validation-output.tsv` 3 个 fixture 的 exit code + stderr reason
- [ ] `results/failclosed-test-output.tsv` 证明 malformed stdin 触发 deny（fail-closed 工作）
- [ ] `SPIKE-REPORT.md` 结尾含 `Overall: PASS` 或 `Overall: FAIL`（行首）
- [ ] `SPIKE-REPORT.md` 用 `exp3-evidence-validator.sh` 自验证 exit 0（真 dogfooding）

**Human 审查问题**：
- 3 个 experiment 每个都有明确量化结果吗？
- Fail-closed 测试通过了吗？
- Phase 1b 建议清单是否完整覆盖 security-auditor 的原始 7 个 P0？
- median < 200ms 且 p95 < 300ms 达成了吗？

**Human 决策**：✅ 继续 Phase 1b / ⚠️ 调整 / ❌ 回 *discuss

---

## 7. File Structure

### 7.1 Files to Create

（见 §4.3 完整列表）

### 7.2 Files to Modify

**无**。完全隔离在 `.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/`。

**严格禁止修改**：
- `.claude/settings.json`
- `.tad/hooks/` 下已有脚本
- Alex/Blake SKILL.md
- Epic 文件（已由 Alex 更新过）

---

## 8. Testing Requirements

### 8.1 Unit Tests

**Experiment 1（4 fixtures × 30 runs + 1 fail-closed）**：
- Test `pretool-match-missing`: sentinel 匹配 + evidence 缺 → `"permissionDecision":"deny"` + reason 含 "Missing evidence"
- Test `pretool-match-ok`: sentinel 匹配 + evidence ≥2 → `"permissionDecision":"allow"`
- Test `pretool-no-match`: sentinel 不匹配 → `"permissionDecision":"allow"`（不关心 evidence）
- Test `pretool-malformed`: JSON 不合法 → `"permissionDecision":"deny"` + reason 含 "hook crashed"（fail-closed）

**Experiment 2（3 fixtures）**：
- Test `override-valid`: `TAD_OVERRIDE: gate3 this is a sufficient reason with length` → log 新增一条
- Test `override-too-short`: `TAD_OVERRIDE: gate3 short` → log 无变化
- Test `override-absent`: `Just a regular message` → log 无变化

**Experiment 3（3 fixtures）**：
- Test `valid-review`: size > 100B + `^Overall: PASS$` → exit 0
- Test `empty-review`: size ≤ 100B → exit 1 + "too small"
- Test `missing-keyword`: size OK 但无 Overall → exit 1 + "missing"

### 8.2 Integration Tests

`test-runner.sh` 整合运行 3 experiment × 所有 fixture + 性能测量 + fail-closed 测试。

### 8.3 Edge Cases (Phase 1a scope)

- **EC1**：exp1 `file_path` 不含 `HANDOFF-*-*` → 用 `spike-default` slug，测试仍工作
- **EC2**：exp1 evidence 目录存在但为空 → 视为 0 files，deny
- **EC3**：exp3 文件正好 100 字节 → exit 1（严格 > 100 才 valid）
- **EC4**：exp2 prompt 有尾随 `\n` → regex 仍匹配（注意 `\n` 处理）

**显式 OUT OF SCOPE（Phase 1b 做）**：
- ❌ Sentinel bypass：case variation、Unicode 形近、零宽字符、split-across-writes、Edit vs Write、Bash redirect
- ❌ Evidence 伪造：lorem-ipsum padding、stale review、copy-paste from archive、symlink
- ❌ Override 注入向量：read-induced、social engineering、clipboard、sub-agent context
- ❌ Log 篡改抵抗
- ❌ Hook 文件保护（防 Blake 改 hook 本身）
- ❌ TOCTOU 竞争
- ❌ settings.local.json bypass

### 8.4 Test Evidence Required

（见 §6 交付物清单）

---

## 9. Acceptance Criteria

Blake 的实现被认为完成，当且仅当：

- [ ] **AC1**：目录结构完整（`.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/` + 4 子目录 + 所有文件）
- [ ] **AC2**：Experiment 1 hook 在 4 种 fixture 下给出正确 allow/deny 决策（deny 的 reason 必须清晰列出缺失 evidence 路径）
- [ ] **AC3（from: performance-optimizer）**：`results/exp1-latencies-ms.tsv` 含 30 行 + per-step 分解；**median < 200ms + p95 < 300ms**（用 `date +%s%N`，不用 `time bash`）
- [ ] **AC4**：Experiment 2 hook 在 3 种 fixture 下正确判断 override 格式；log 文件的变化可在 `results/exp2-override.log` 中验证
- [ ] **AC5**：Experiment 3 checker 正确处理 3 种 fixture 的 valid/invalid 判定，stderr 输出具体原因
- [ ] **AC6**：4 个 Edge Case 全部处理正确（§8.3 EC1-EC4）
- [ ] **AC7（fail-closed, from: ai-agent-architecture → safety_design + security-auditor P0-1）**：malformed stdin 触发 hook 崩溃时，**permissionDecision = "deny"**（不是 allow），reason 含 "hook crashed"
- [ ] **AC8**：`test-runner.sh` 一键运行能产出完整 `results/` 目录（5 个 tsv/log 文件）
- [ ] **AC9（真 dogfooding）**：`SPIKE-REPORT.md` 满足 `exp3-evidence-validator.sh` 验证（exit 0），**且** `grep -cE '^Overall: (PASS\|FAIL)$' SPIKE-REPORT.md` ≥ 1
- [ ] **AC10（决策结构）**：`SPIKE-REPORT.md` 含结构化表格：每 experiment 一行 × 3 列（量化结果 / 结论 / 后续建议）
- [ ] **AC11（Phase 1b 建议，from: security-auditor scope-split 建议）**：`SPIKE-REPORT.md` 含 "Phase 1b 测试清单" 小节，明确列出至少 security-auditor 原始 P0 未解决的 7 项（sentinel bypass ≥8 种 / evidence forgery ≥3 种 / override 注入 4 向量 / log 完整性 / hook 文件保护 / TOCTOU / settings.local.json bypass）
- [ ] **AC12（时间盒）**：**4-6 小时硬上限**，到 6h 仍未完成 → 停，报告现状判 PARTIAL
- [ ] **AC13（scope 锁死）**：**不修改** `.claude/settings.json` / `.tad/hooks/` 已有文件 / Alex/Blake SKILL.md / Epic 文件
- [ ] **AC14（已移除旧 fail-open 条款，由 AC7 替代）**：hook 的 `set -euo pipefail` + `trap ERR` 在 `exp1-pretool-interceptor.sh` 脚本头部存在（`grep -c 'set -euo pipefail' exp1-pretool-interceptor.sh` ≥ 1；`grep -c 'trap' exp1-pretool-interceptor.sh` ≥ 1）

---

## 9.1 Spec Compliance Checklist

| # | AC | Verification | Expected |
|---|----|--------------|----------|
| 1 | AC1 目录 | `find .tad/evidence/spikes/SPIKE-20260413-quality-enforcement/ -maxdepth 2 -type d \| wc -l` | ≥ 4 |
| 2 | AC2 决策 | cat `results/exp1-decisions.tsv` | 4 行覆盖 4 种 fixture |
| 3 | AC3 性能 | Parse `results/exp1-latencies-ms.tsv`；计算 median + p95 | median < 200 && p95 < 300 |
| 4 | AC4 override log | `wc -l .tad/evidence/overrides/spike-test.log` 在 valid fixture 前后差为 1 | 1 |
| 5 | AC5 fixture 区分 | `bash exp3-evidence-validator.sh test-fixtures/{fake-empty,fake-missing-keyword,fake-valid}-review.md; echo $?` | 1, 1, 0 |
| 6 | AC7 fail-closed | cat `results/failclosed-test-output.tsv` | permissionDecision=deny + "hook crashed" |
| 7 | AC9 dogfood | `bash exp3-evidence-validator.sh SPIKE-REPORT.md; echo $?` | 0 |
| 8 | AC11 1b list | `grep -cE '(sentinel bypass\|evidence forgery\|override 注入\|log 完整性\|hook 文件保护\|TOCTOU\|settings.local)' SPIKE-REPORT.md` | ≥ 7 |
| 9 | AC14 fail-closed guard | `grep -c 'set -euo pipefail\|trap' exp1-pretool-interceptor.sh` | ≥ 2 |

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **PreToolUse 不是 PostToolUse**。PostToolUse fires 在 tool 执行后，无法阻止写盘。必须用 PreToolUse + `permissionDecision: "deny"`
- ⚠️ **不修改 `.claude/settings.json`**。所有 hook 测试通过 `bash exp*.sh < fixture.json` 直接 pipe
- ⚠️ **awk `ENVIRON["VAR"]` 不是 `-v var=$msg`**（后者解释 `\n` 转义）；env var 必须在 awk 命令前，不是前置 pipeline stage
- ⚠️ **不用 `grep -P`**（macOS BSD 不支持）
- ⚠️ **fail-closed（AC7）不是 fail-open**。hook 崩溃默认 deny，不是 allow
- ⚠️ **时间盒 4-6h 硬约束**。PARTIAL 可接受，不追求完美
- ⚠️ **对抗鲁棒性全部在 Phase 1b**。Blake 若在 1a 发现高风险 bypass 可在 SPIKE-REPORT 的 Phase 1b 建议区记录，但不展开测试

### 10.2 Known Constraints

- 纯 bash/awk/jq/find（macOS 默认）
- 不依赖 Claude API
- 所有工作在 `.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/` 内

### 10.3 Sub-Agent 使用建议

- [ ] **bug-hunter** - 若 exp1 latency 异常（>1s）或 decision 不符预期
- [ ] **test-runner** - 运行完 3 个 experiment 后做 completion review

### 10.4 Domain Pack Anti-Patterns

- ⚠️ [ai-agent-architecture → safety_design] 禁止 fail-open 降级（已由 AC7 强制）
- ⚠️ [ai-agent-architecture → role_behavior_design] 禁止只用 prompt MANDATORY 约束（本 Epic 的根本命题）

---

## 11. Learning Content

### 11.1 Decision Rationale: 为什么 PreToolUse 而非 PostToolUse

**选择的方案**：PreToolUse Write + `permissionDecision: "deny"`

**考虑的替代方案**：

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| PreToolUse Write（选中）| 真能阻止 tool 执行，文件不会落盘 | 每次 Write 都跑（需快速 fast-path） | ✅ 选中 |
| PostToolUse Write（v1 原设计）| 实现简单 | 文件已写，deny 只发 feedback 给模型 | ❌ 错误：不真阻止，code-reviewer / security / perf 三审查都发现 |
| Haiku 判断 | 最智能 | 每次 2-5s + 3k tokens | ❌ 成本不可接受 |

**💡 Human 学习点**：Hook 机制的选择必须匹配语义。PostToolUse 是"观察者"，PreToolUse 是"守门员"。本 spike v1 的错误正是这个范式错配。

### 11.2 Decision Rationale: 为什么拆分 Phase 1a/1b

**选择的方案**：拆分

**理由**：security-auditor 指出单一 spike 混合"机制存在（简单）"+"对抗鲁棒（复杂）"两个不同难度的问题，4-6h 时间盒会爆到 8-12h 或产出错误 GO。拆分后 1a 测可行性、1b 测抗攻击，符合 Light TAD spike 的 scope 纪律。

---

## 12. Sub-Agent 使用记录

Blake 完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| bug-hunter | — | — | — | — |
| test-runner | — | — | — | — |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-13
**Version**: 3.1.0 (v2 post expert review)
**Status**: ✅ Ready for Implementation
