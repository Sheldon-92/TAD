---
# Quality Chain Metadata
task_type: mixed       # Hook script (code) + spike report (research)
e2e_required: no       # No user-facing flow to E2E test
research_required: yes # Spike report is the primary deliverable
---

# Handoff: Domain Pack Hook Spike (Epic 1 Phase 1)

**From:** Alex (Agent A — Solution Lead)
**To:** Blake (Agent B — Execution Master)
**Date:** 2026-04-07
**Project:** TAD Framework
**Task ID:** TASK-20260407-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260407-domain-pack-reliable-loading.md (Phase 1/4)
**Linear:** N/A
**Process Depth:** Light TAD
**Type:** Spike (cheap validation, fail-fast)
**Gate 3 Mode:** Light — code-reviewer for run-spike.sh only;research-reviewer for SPIKE-REPORT structure;skip 完整测试套件审查(spike 没 unit test)

---

## Expert Review Status

| Reviewer | Status | Findings | P0 Resolved |
|----------|--------|----------|-------------|
| code-reviewer | CONDITIONAL PASS | 5 P0 issues (settings.json safety, path A/B contradiction, p95 计算, AC10 范围, prompt 格式漂移) | ✅ All addressed in revision |
| backend-architect | CONDITIONAL PASS | 3 P0 issues (path B 集成验证缺口, silent ignore 检测, recipe envelope schema) | ✅ All addressed in revision |

**Resolution summary** (post-revision):
1. ✅ run-spike.sh 安全骨架 + trap+restore + diff-based AC9
2. ✅ Path A/B 不再是 fallback 关系,B 始终全量跑(canonical accuracy),A 跑 3 条代表性 case(canonical integration)
3. ✅ Sentinel file 检测 silent ignore
4. ✅ Recipe envelope 字段进入 prompt + results.json schema
5. ✅ p95 → max_latency_ms (n=18 上 p95 无意义)
6. ✅ AC10 改为显式 BSD 检查清单(5 项)
7. ✅ Haiku prompt 加严约束 + parse_failures 单独 metric
8. ✅ 加 3 条 chat case (P1 - measure no-op latency)
9. ✅ curl 骨架进入 §4.2 Component 4

**Gate 2 结果**: ✅ PASS (post-revision)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-07

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Spike scope clear: validate UserPromptSubmit hook + Haiku classification |
| Components Specified | ✅ | Hook config, prompt template, test cases, report template all defined |
| Functions Verified | ⚠️ | UserPromptSubmit hook event existence is **what we're verifying** — accept this risk |
| Data Flow Mapped | ✅ | user message → hook → Haiku → JSON response → additionalContext → Alex |

**Gate 2 结果**: ✅ PASS (with explicit unknown documented as spike target)

**Alex 确认**: 我已验证所有 spike 设计要素。Blake 可以独立根据本文档完成 spike 执行。

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 阅读所有章节
- [ ] **阅读 §📚 Project Knowledge 中的历史经验**(尤其是 5 条 hook 相关知识)
- [ ] 理解 spike 的 fail-fast 原则:**早失败比晚失败好**
- [ ] 理解 Phase 1 的 spike 结论会决定 Phase 2-4 的设计走向
- [ ] 确认可以独立完成

❌ 任何不清楚的地方,**立即返回 Alex 澄清**,不要瞎试。

---

## 1. Task Overview

### 1.1 What We're Building

一个最小可行的 spike,用来验证三件事:

1. **机制可行性**:Claude Code 是否支持 `UserPromptSubmit` hook 事件
2. **分类准确率**:Haiku-4.5 能否在 1s 内对单个 Domain Pack capability 做出 ≥ 80% 准确率的"是否相关"判断
3. **集成可行性**:hook 注入的 `additionalContext` 是否能被 Alex(主对话)正确收到

### 1.2 Why We're Building It

**业务价值**:这个 spike 决定 Epic 1(Domain Pack 可靠加载)整个 4-phase 路径是否走得通。三个验证点任何一个失败,Phase 2-4 的设计就要重新规划。Spike 失败 = 节省后面几天的错误工作。

**用户受益**:间接 — Spike 通过后,Alex/Blake 才能用上可靠的 Domain Pack 自动加载机制。

**成功的样子**:当你看到一份 SPIKE-REPORT.md,里面有明确的 go/no-go 结论 + 实测数据 + Phase 2 设计建议 — spike 就成功了。

### 1.3 Intent Statement

**真正要解决的问题**:验证假设,不是建生产系统。

**不是要做的(避免误解)**:
- ❌ 不是写一个生产可用的 hook(那是 Phase 2 的工作)
- ❌ 不是覆盖所有 14 个 Domain Pack(只用 1 个 capability 做 PoC)
- ❌ 不是优化 Haiku prompt 到极致(够用就行,优化是 Phase 4 的事)
- ❌ 不是写完整测试套件(15 条手工测试用例就够)

**Blake 请确认理解**:

```
开始前用你自己的话回答:
1. 这个 spike 解决什么问题?
2. 如果 Claude Code 不支持 UserPromptSubmit,你会怎么办?
3. 准确率只有 70% 算 spike 成功还是失败?
```

---

## 📚 Project Knowledge (Blake 必读)

**⚠️ MANDATORY READ**:开始实现前必须 Read `.tad/project-knowledge/architecture.md`,以下 5 条直接相关:

### 步骤 1:相关类别

- [x] **architecture** - hook 设计、Claude Code 机制
- [ ] code-quality (不直接相关)
- [ ] security
- [ ] performance

### 步骤 2:历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `architecture.md` | 5 条 | hook 写法、Claude Code 机制边界、spike 方法论 |
| `security.md` | 0 条 | 无相关 |

### ⚠️ Blake 必须注意的 5 条历史教训

1. **Hook Shell Portability: No grep -P on macOS** (architecture.md, 2026-04-03)
   - 问题:macOS BSD grep 不支持 `-P`(Perl regex),hook 脚本里用 `grep -oP` 会静默失败
   - 解决:用 `grep -o` + `sed` 替代 lookbehind
   - 应用:本 spike 里所有 bash 处理必须 BSD-compatible

2. **Hook Path Matching: Glob Prefix Must Handle Relative Paths** (architecture.md, 2026-04-02)
   - 问题:`*/.tad/` 不匹配相对路径 `.tad/`(需要前置字符)
   - 解决:用 `*.tad/`(任意前缀含空)
   - 应用:如果 spike 里 case pattern 涉及路径匹配,用 `*.tad/`

3. **Claude Code Native Mechanism Validation — Hooks > Skill Frontmatter** (architecture.md, 2026-03-31)
   - **关键背景**:这条知识列出了**已验证**的 hook 事件:`PostToolUse`、`PreToolUse`、`SessionStart`
   - **`UserPromptSubmit` 不在已验证列表里** — 这就是本 spike 要解答的问题
   - PreToolUse 的 prompt hook type 已验证可用(参见现有 settings.json)
   - Hook event 名是 PascalCase(不是 kebab-case)
   - 应用:你的第一步是测 `UserPromptSubmit` 是否存在,如果不存在 → 立即记录 no-go 并停止后续测试

4. **Measure Before Optimizing: Context Loading Spike** (architecture.md, 2026-03-23)
   - 问题:之前一个 spike 假设需要优化,实测发现 baseline 已经够好,触发 pivot
   - 解决:spike 必须含明确 pivot threshold(例:本 spike 的"准确率 < 80% → no-go")
   - 应用:严格按 §9 验收标准判断 go/no-go,不要因为"差一点点"就放水

5. **Claude Code Enforcement Priority Order — permissions.deny > hooks > allow** (architecture.md, 2026-03-31)
   - 上下文:hook 在 permissions.deny 之后才生效;deny 之后 hook 收不到事件
   - 应用:本 spike 不涉及 deny,但要意识到 hook 不是最高优先级。设计时假设 hook 总是在 deny 之后跑

### Blake 确认

- [ ] 我已阅读上述 5 条历史教训
- [ ] 我理解 hook script 必须 BSD-compatible
- [ ] 我会先验证 `UserPromptSubmit` 存在,再做后续测试

---

## 2. Background Context

### 2.1 Previous Work

- 现有 hooks 在 `.claude/settings.json`:`SessionStart`、`PreToolUse`(Write|Edit + Skill)、`PostToolUse`(Write|Edit)
- `PreToolUse` Write|Edit 已经用了 `type: "prompt"` + `model: "claude-haiku-4-5-20251001"` — **这是本 spike 要复用的模式**
- Domain Pack 列表通过 SessionStart hook (`startup-health.sh`) 注入到 additionalContext

### 2.2 Current State vs Target

| 当前 | 目标(spike 后) |
|------|---------------|
| Domain Pack 加载完全靠 LLM 自觉扫描 SessionStart 注入的 blob | 验证 UserPromptSubmit + Haiku 能不能可靠提示 |
| 不知道 UserPromptSubmit 是否存在 | 知道 |
| 不知道 Haiku 在这种分类任务上准确率多少 | 知道(15 条 case 实测) |

### 2.3 Dependencies

- Claude Code (本机当前版本 — 见 `claude --version`)
- Anthropic API access(Haiku 通过 prompt hook type 由 Claude Code 自动调用,无需手动 API key)
- bash, jq(macOS 自带)

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: 创建 `.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/` 目录并产出全部 6 个文件(见 §7)
- **FR2**: 测试 `UserPromptSubmit` hook 事件是否在当前 Claude Code 版本中存在并工作
- **FR3**: 用 `web-frontend.component_development` 作为 PoC capability,准备 15 条测试 user messages(5 明显匹配 + 5 明显不匹配 + 5 边缘案例)
- **FR4**: 对每条测试用例运行 Haiku 分类,记录:分类结果、置信度、延迟(ms)
- **FR5**: 计算 metrics:accuracy、mean latency、p95 latency、false positive rate、false negative rate
- **FR6**: 输出 SPIKE-REPORT.md,含明确 go/no-go 结论 + 数据表 + 对 Phase 2 的设计建议

### 3.2 Non-Functional Requirements

- **NFR1**: 测试用例的 ground truth 标签由 Alex 提供(见 §6 Phase 1 步骤 2 的标签清单)
- **NFR2**: 整个 spike 工作量目标 < 4 小时,如果超时 → 立即升级
- **NFR3**: 即使 spike 失败(no-go),也要产出完整 SPIKE-REPORT.md 说明失败原因 — **失败的 spike 不是失败的工作**

---

## 4. Technical Design

### 4.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ User in Claude Code session                              │
│   ↓ types message: "做一个 button 组件"                  │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Claude Code: UserPromptSubmit event fires (HYPOTHESIS) │
│   ↓ runs configured hook                                │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Hook (type: prompt, model: claude-haiku-4-5-20251001)  │
│   ↓ sends classification prompt                         │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Haiku returns JSON: {"match": true, "confidence": 0.9} │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Hook injects additionalContext if match=true            │
│   "⚠️ Task matches web-frontend. Read .tad/domains/..." │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Alex(主对话)收到 system-reminder,执行 Read              │
└────────────────────────────────────────────────────────┘
```

### 4.2 Component Specifications

**Component 1: Hook 配置(测试用)**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/hook-poc-snippet.json`

内容:一段可粘到 `.claude/settings.json` 的 `UserPromptSubmit` 配置(prompt hook type),引用 §4.3 的 prompt 模板。

**注意**:Spike 期间,你需要把这段配置临时加到 `.claude/settings.json`(测完移除)。或者用一个测试 settings 文件 + 启动新 Claude Code session 测试。**两种方式都试,哪种快用哪种。**

**Component 2: Haiku Prompt 模板**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/haiku-prompt-template.md`

⚠️ **使用 envelope 格式** — Haiku 必须返回 `matched_packs` 数组(为 Phase 2 多 pack 扩展和 Epic 3 recipe 字段预留接口)。即使本 spike 只测 1 个 capability,envelope 也要存在。

```
You are a classifier for AI development assistant tasks. Given a user message,
determine which capabilities (if any) the user's task relates to.

Available capabilities:
- pack: web-frontend
  capability: component_development
  description: Building reusable UI components in React/Vue/Angular, including
    state management, props design, lifecycle handling, component composition,
    and UI element creation (buttons, forms, modals, lists, etc.).

User message: "{user_message}"

Match guidelines:
- match a capability if user's primary intent is producing runnable
  component code/markup
- discussions ABOUT components without intent to build = no match
- tasks where component work is >50% of effort (e.g., "build login page")
  = match
- short affirmation/chat messages ("thanks", "ok", "yes") = no match,
  return empty matched_packs

CRITICAL OUTPUT FORMAT — your entire response must be parseable by `jq`:
- First character MUST be `{`, last character MUST be `}`
- NO markdown code fences (no ```json)
- NO text before `{` or after `}`
- NO trailing punctuation outside the JSON
- NO explanation or preamble

Response schema (envelope, future-compatible with multi-pack and recipes):
{
  "matched_packs": [
    {"pack": "web-frontend", "capability": "component_development",
     "confidence": 0.0-1.0, "reason": "one short sentence"}
  ],
  "matched_recipes": []
}

If no match: return {"matched_packs": [], "matched_recipes": []}
```

**Component 3: 测试用例文件**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/test-cases.yaml`

结构(15 条):

```yaml
test_cases:
  # === 5 明显匹配 ===
  - id: TC01
    message: "做一个 React button 组件"
    expected: true
    category: clear_match

  - id: TC02
    message: "需要写一个 form validation 的组件"
    expected: true
    category: clear_match

  - id: TC03
    message: "How do I build a reusable modal component in React?"
    expected: true
    category: clear_match

  - id: TC04
    message: "组件状态管理用 useState 还是 useReducer?"
    expected: true
    category: clear_match

  - id: TC05
    message: "I need to create a list component that supports pagination"
    expected: true
    category: clear_match

  # === 5 明显不匹配 ===
  - id: TC06
    message: "怎么连接 PostgreSQL 数据库"
    expected: false
    category: clear_nonmatch

  - id: TC07
    message: "今天天气怎么样"
    expected: false
    category: clear_nonmatch

  - id: TC08
    message: "写一个 bash 脚本备份文件"
    expected: false
    category: clear_nonmatch

  - id: TC09
    message: "解释一下 SQL 注入是什么"
    expected: false
    category: clear_nonmatch

  - id: TC10
    message: "我想发一封邮件给团队"
    expected: false
    category: clear_nonmatch

  # === 5 边缘案例 ===
  - id: TC11
    message: "做一个登录页"
    expected: true  # 登录页主要是前端组件 + 表单
    category: edge
    note: "Could be auth-related, but main work is UI"

  - id: TC12
    message: "性能优化"
    expected: false  # 太宽泛,不指向 component_development
    category: edge
    note: "Too vague to match this specific capability"

  - id: TC13
    message: "改个按钮样式"
    expected: true
    category: edge
    note: "Trivial but clearly frontend component territory"

  - id: TC14
    message: "API 设计要遵循什么规范"
    expected: false  # backend topic
    category: edge
    note: "Backend / API design, not component"

  - id: TC15
    message: "showcase 一个商品列表"
    expected: true
    category: edge
    label_confidence: low
    note: "showcase could mean 'demo/present' (= asking for example) instead of 'build'. Low-confidence label."

  # === 3 chat/no-op cases (P1 from arch review: measure no-op latency) ===
  - id: TC16
    message: "thanks"
    expected: false
    category: chat_noop
    label_confidence: high
    note: "Affirmation/chat message — should not match any capability"

  - id: TC17
    message: "ok 继续"
    expected: false
    category: chat_noop
    label_confidence: high
    note: "Continuation prompt — should not match"

  - id: TC18
    message: "yes"
    expected: false
    category: chat_noop
    label_confidence: high
    note: "Single-word affirmation — should not match"
```

⚠️ **Ground Truth Decision Rules** (write at top of test-cases.yaml):

```
Ground truth rule: expected=true iff the user's primary intent is producing
runnable component code/markup. Discussions ABOUT components without intent
to build = false. Tasks where component work is one of multiple workstreams
(e.g. login page) = true if UI work is >50% of effort.

label_confidence field:
  - high: unambiguous, defensible label
  - medium: defensible but reasonable people could disagree
  - low: contested, report accuracy on this case separately
```

⚠️ **Note on TC11/TC15**: Both labeled `label_confidence: low` (TC11 update: see below). Report accuracy with and without low-confidence cases.

Update TC11 to add `label_confidence: low` field (login page is borderline).

⚠️ **Total cases: 18** (15 original + 3 chat). Update §9 ACs and §4.2 Component 5 schema accordingly.

**Component 4: 自动化执行脚本**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/run-spike.sh`

职责:
1. **备份并设置 trap 恢复 settings.json**(强制,见下方安全骨架)
2. 读 `test-cases.yaml`
3. **同时跑 Path A(集成验证)和 Path B(准确率 canonical)**,各自记录
4. 写入 `results.json`(envelope 格式,见 Component 5)
5. 计算 metrics 并打印

### 双路径执行模型(P0 修复 — 不再是 fallback 关系)

| 路径 | 角色 | 何时跑 | 失败影响 |
|------|------|--------|---------|
| **Path A: Real hook** | **Integration canonical** — 唯一能验证 UserPromptSubmit 真的工作 | Phase 1 hook 存在性确认后跑;只跑 3 条代表性 case(1 match + 1 nonmatch + 1 edge) | 失败 → verdict 必须是 NO-GO 或 PARTIAL,即使 Path B accuracy 100% |
| **Path B: API 模拟** | **Accuracy canonical** — 用 curl 直接调 Haiku,measurement 来源 | **始终都跑** 全部 18 条 case | 失败 → Haiku 本身能力问题,Phase 2 可能要换模型 |

**关键原则**:Path A 和 Path B 不可互相替代。
- Path B 高 accuracy + Path A 失败 = "Haiku 能分类,但 hook 集成不通" → NO-GO
- Path B 低 accuracy + Path A 成功 = "hook 通了,但 Haiku 分错" → NO-GO,Phase 2 换思路

### Silent-Ignore 检测(P0 修复)

⚠️ **最危险的失败模式**:Claude Code 接受 settings.json 中未知 hook event(无报错)但永不触发。MQ2 step 2 "看 Claude Code 是否报错" **不足以**检测这个。

**强制要求**:Path A 的 hook 命令必须**写一个 sentinel 文件**作为正向信号:

```bash
# hook command 内容(在 hook-poc-snippet.json 里)
echo "$(date +%s%N) | $ARGUMENTS" >> /tmp/tad-spike-userprompt-fired.log
```

测试结束后:
- Sentinel log 存在且行数 ≥ 测试 case 数 → hook 真的触发了
- Sentinel log 不存在或为空 → **silent ignore** → Path A FAIL,verdict NO-GO on integration

### 安全骨架(run-spike.sh 必须包含)

```bash
#!/bin/bash
set -euo pipefail

SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$HOME/01-on progress programs/TAD/.claude/settings.json"
BACKUP_FILE="${SETTINGS_FILE}.spike-backup-$(date +%s)"
SENTINEL_LOG="/tmp/tad-spike-userprompt-fired.log"
START_TIME=$(date +%s)
HARD_CAP_SECONDS=$((4 * 3600 + 1800))  # 4.5h

# === Safety: backup + trap restore ===
cp "$SETTINGS_FILE" "$BACKUP_FILE"
trap '
  if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$SETTINGS_FILE" \
      && echo "✅ settings.json RESTORED from $BACKUP_FILE" \
      || echo "❌ RESTORE FAILED — manual cleanup needed: $BACKUP_FILE"
  fi
  ELAPSED=$(($(date +%s) - START_TIME))
  echo "⏱  Total elapsed: ${ELAPSED}s (budget: ${HARD_CAP_SECONDS}s)"
' EXIT

# === Time check ===
check_timebox() {
  local elapsed=$(($(date +%s) - START_TIME))
  if [ $elapsed -gt $HARD_CAP_SECONDS ]; then
    echo "❌ Timebox exceeded (${elapsed}s > ${HARD_CAP_SECONDS}s) — aborting"
    exit 1
  fi
}

# === Path B canonical accuracy run ===
run_path_b() {
  local message="$1"
  local start_ms=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local response
  response=$(curl -sS https://api.anthropic.com/v1/messages \
    -H "x-api-key: ${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY not set}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "{
      \"model\": \"claude-haiku-4-5-20251001\",
      \"max_tokens\": 200,
      \"messages\": [{\"role\": \"user\", \"content\": $(jq -Rs . < "$SPIKE_DIR/haiku-prompt-template.md" | sed "s|{user_message}|$message|")}]
    }")
  local end_ms=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local latency=$((end_ms - start_ms))
  # Extract content, then parse as JSON envelope; record parse_ok separately
  local content=$(echo "$response" | jq -r '.content[0].text // empty')
  local parse_ok="true"
  if ! echo "$content" | jq -e '.matched_packs' >/dev/null 2>&1; then
    parse_ok="false"
  fi
  echo "{\"latency_ms\": $latency, \"parse_ok\": $parse_ok, \"raw\": $(echo "$content" | jq -Rs .)}"
}

# Main loop: run all 18 cases through Path B, then 3 representative through Path A
# (full implementation: Blake writes ~80-120 lines)
```

⚠️ **Note on perl/awk**: 上面用 `perl -MTime::HiRes` 是因为 BSD `date` 不支持 `%N`。Blake 可以改用 python 或其他 BSD-compatible 方式。

### Path A 触发(集成验证)

由于真 hook 测试需要在另一个 Claude Code session 中操作(不能在 run-spike.sh 里全自动跑),Path A 由 Blake 半手工执行:

1. 把 hook-poc-snippet.json 内容合并进 settings.json(run-spike.sh 已备份)
2. 启动新 Claude Code session: `claude` 或在另一个 terminal 里
3. 在新 session 输入 3 条代表性 case(从 18 条中挑:1 clear_match + 1 clear_nonmatch + 1 edge)
4. 检查 sentinel log:`cat /tmp/tad-spike-userprompt-fired.log`
5. 在新 session 中问 Alex: "你刚才有收到关于 web-frontend 的 system-reminder 吗?" — 截图回复
6. 退出 session(trap 自动恢复 settings.json)
7. 把 Path A 结果手工填入 results.json 的 `path_a_integration` 字段

**Component 5: 原始结果**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/results.json`

⚠️ **使用 envelope 格式 + 区分 Path A/B + 包含 parse_ok**(P0 修复)

```json
{
  "spike_id": "SPIKE-20260407-domain-pack-hook",
  "ran_at": "2026-04-07T...",
  "claude_code_version": "<output of `claude --version`>",
  "anthropic_model": "claude-haiku-4-5-20251001",

  "path_b_results": [
    {
      "id": "TC01",
      "message": "做一个 React button 组件",
      "expected": true,
      "label_confidence": "high",
      "category": "clear_match",
      "raw_response": "{\"matched_packs\":[...]}",
      "parse_ok": true,
      "matched_packs": [
        {"pack": "web-frontend", "capability": "component_development",
         "confidence": 0.92, "reason": "..."}
      ],
      "actual_match": true,
      "latency_ms": 234,
      "input_tokens": 180,
      "output_tokens": 45,
      "cost_usd": 0.000023,
      "correct": true
    }
  ],

  "path_a_integration": {
    "executed": true,
    "test_cases_run": ["TC01", "TC06", "TC11"],
    "sentinel_log_path": "/tmp/tad-spike-userprompt-fired.log",
    "sentinel_log_lines": 3,
    "hook_fired_count": 3,
    "additional_context_received_by_alex": true,
    "evidence": "Alex confirmed receiving system-reminder for TC01 — see screenshot/log: ..."
  },

  "metrics": {
    "total_cases": 18,
    "path_b_correct": 16,
    "path_b_accuracy_all": 0.889,
    "path_b_accuracy_high_confidence_only": 0.933,
    "false_positives": 1,
    "false_negatives": 1,
    "parse_failures": 0,
    "mean_latency_ms": 312,
    "max_latency_ms": 612,
    "mean_cost_usd": 0.000022,
    "total_cost_usd": 0.0004
  },

  "hook_existence": {
    "user_prompt_submit_event_recognized": true,
    "user_prompt_submit_actually_fires": true,
    "evidence": "Sentinel log /tmp/tad-spike-userprompt-fired.log has 3 entries after Path A test session. claude --version: ..."
  }
}
```

**关键 schema 决策**:
- `matched_packs` 用 envelope 数组(为多 pack + Epic 3 recipe 预留)
- `parse_ok` 单独字段(P0 修复:区分"分类错"和"输出格式漂移")
- `path_a_integration` 独立 block(P0 修复:integration 与 accuracy 解耦)
- `accuracy_high_confidence_only` 独立报告(P1:label 噪声防御)
- `max_latency_ms` 替代 p95(P0 修复:n=18 上 p95 无意义)
- `cost_usd` 字段(P1:Epic 1 success criterion 之一)

**Component 6: SPIKE-REPORT.md(最终交付)**

文件:`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/SPIKE-REPORT.md`

必须包含 8 个章节:

### §1 Verdict(必填)

格式:`<integration>/<accuracy>` 两维度独立判定

| Verdict | 含义 |
|---------|------|
| ✅ **GO** | Path A 集成成功 **AND** Path B accuracy ≥ 80% (high-conf cases) **AND** mean latency < 1s |
| ⚠️ **PARTIAL** | 一个维度通过但另一个不通过 (例:hook 工作但 accuracy 73%,或 accuracy 高但 hook silent ignore) |
| ❌ **NO-GO** | Path A integration 失败 **OR** accuracy < 70% **OR** 出现致命问题(API 不可用等) |

⚠️ Path A 失败 + Path B 高 accuracy = **NO-GO on integration**(不能算 PARTIAL,因为 Epic 1 的核心就是 hook 机制)

### §2 Mechanism Findings

- `claude --version` 输出
- UserPromptSubmit 是否在 settings.json 中被接受(无报错)
- Sentinel log 是否生成,行数
- Alex 是否报告收到 system-reminder
- 关键观察(任何意外行为)

### §3 Accuracy Data

- Metrics 表(从 results.json `metrics` 块)
- 18 条 case 明细表(id, expected, actual, confidence, latency, parse_ok, correct)
- High-confidence vs all 的对比

### §4 Failure Analysis(必填,即使全对也写)

| TC ID | Expected | Actual | Conf | Haiku reason | Failure type |
|-------|----------|--------|------|--------------|--------------|
| ... | ... | ... | ... | ... | semantic / parse / latency / api_error / none |

如全对:写 "No failures across 18 cases. High-confidence cases: 15/15. Low-confidence cases: 3/3."

### §5 Generalization Risk Assessment(P0 修复)

⚠️ **明确声明**:18 个 case × 1 个 capability = **smoke test, not statistical validation**

- 当前结果在哪些维度上**不能**外推到 Phase 2 的 80+ capabilities × 千万级用户消息?
- 已知的潜在风险(例:类似词触发误判、多语言、长消息)
- Phase 2 应做的扩展验证

### §6 Phase 2 Readiness Checklist(P0 修复)

回答每一项 yes/no + 证据引用:

- [ ] Hook event verified to exist and fire reliably (引用 §2)
- [ ] additionalContext delivery to Alex confirmed (引用 §2)
- [ ] Latency budget achievable (mean < 500ms p-target, max < 1s actual)
- [ ] Cost budget achievable (< $0.0002/call,Epic success criterion)
- [ ] Output schema includes recipe envelope (matched_packs + matched_recipes)
- [ ] Format reliability ≥ 95% (parse_failures / total)
- [ ] Known unknowns enumerated for Phase 2 (列出至少 3 个)

### §7 Recommendations for Phase 2(必填)

至少 3 条具体建议(不是泛泛而谈):
- Prompt 模板:具体应怎么调
- 阈值:confidence cutoff 推荐值(基于 §3 的分布)
- 检查点位置:Alex/Blake 哪些地方加 system-reminder 接收逻辑
- 已知陷阱:例如"chat 类消息要 prefilter"
- 如果 NO-GO:推荐 fallback 路径(PreToolUse on Skill / command hook / 其他)

### §8 Time Spent + Knowledge Entry

- 实际工时(诚实记录)
- **Draft architecture.md 知识条目**(供 Alex 在 Gate 4 merge):

  ```
  ### UserPromptSubmit Hook Verification - 2026-04-07
  - **Context**: Epic 1 Phase 1 spike验证 hook 可行性
  - **Discovery**: {填实际发现 — 存在/不存在/silent ignore/可用}
  - **Action**: Phase 2 应 {基于发现的具体建议}
  ```

---

## 5. 强制问题回答(Evidence Required)

### MQ1: 历史代码搜索

**问题**:这个项目有没有 hook 相关的历史代码或文档?

**Blake 必须执行**:

```bash
# 搜索现有 hook 配置
grep -r "UserPromptSubmit" .claude/ .tad/ 2>/dev/null
grep -r "PreToolUse\|PostToolUse\|SessionStart" .claude/settings.json
ls .tad/hooks/
```

**预期发现**:
- `.claude/settings.json` 已有 PreToolUse(prompt type)用法 — **直接复用此模式**
- `.tad/hooks/startup-health.sh` 已有 SessionStart hook 注入 additionalContext 的写法 — **参考其 JSON 输出格式**
- `.tad/hooks/lib/common.sh` 可能有可复用的 helpers

**记录**:把 grep/ls 输出贴到 SPIKE-REPORT.md §Mechanism Findings。

### MQ2: 函数/机制存在性验证

**问题**:`UserPromptSubmit` 这个 hook 事件名在 Claude Code 中是否存在?

**Blake 必须执行**:

| 验证步骤 | 命令/动作 | 预期 |
|----------|----------|------|
| 1. 查 Claude Code 文档 | `claude --help` 或查官方文档 | 看是否提到 UserPromptSubmit |
| 2. 试加配置 | 把 hook-poc-snippet.json 内容加到 settings.json | 看 Claude Code 是否报错 |
| 3. 启动 session 测试 | 启动新 session 输入测试消息 | 看 hook 是否被触发 |
| 4. 检查日志 | 查看 ~/.claude/logs/ 或类似位置 | 看是否有 hook 执行记录 |

**Human 验证点**:每个步骤都有具体输出/截图吗?

### MQ3-MQ5: 不适用

本 spike 不涉及前后端数据流、UI 状态、多状态同步。**N/A**。

---

## 6. Implementation Steps

### Phase 1: 机制验证(预计 1-1.5 小时)

#### 交付物
- [ ] 搞清楚 UserPromptSubmit 是否存在(MQ2 表格填完)
- [ ] hook-poc-snippet.json 已写
- [ ] (如果 hook 存在)在测试 session 中成功触发一次

#### 实施步骤

1. **Read** `architecture.md` 中 5 条相关知识(Project Knowledge §)
2. **Read** `.claude/settings.json` 学习现有 prompt hook 用法
3. **Read** `.tad/hooks/startup-health.sh` 学习 additionalContext 注入格式
4. **执行 MQ1 grep** — 记录现有 hook 资产
5. **写 hook-poc-snippet.json** — 基于现有 PreToolUse 模式,改成 UserPromptSubmit
6. **测试存在性** — 临时加到 settings.json,启动新 Claude Code session,输入一句 "做一个 button 组件"
7. **观察结果**(三种情况,**注意 silent-ignore 是最危险的**):
   - **情况 a**:hook 触发了 + sentinel log 有内容 → 记录"存在 + 工作",Path A 确认可行
   - **情况 b**:Claude Code 报错"unknown hook event" → 记录"不存在",Path A FAIL,但 Phase 2 的 Path B accuracy 测试**仍然要跑全套**(理解 Haiku 能力)
   - **情况 c (最危险)**:无报错但 sentinel log 为空 → **silent ignore**,记录为 Path A FAIL,verdict 必须 NO-GO on integration(Epic 1 必须重新设计)

   **任何一种情况,都继续 Phase 2 的 Path B 全量测试** — 数据本身有价值,无论 Path A 结果如何

#### Phase 1 完成证据
- [ ] **截图/文本**:Claude Code 启动 session 后的反应(成功触发 / 错误信息)
- [ ] **MQ2 表格填完**
- [ ] **Phase 1 结论**:hook 存在 ✅ / 不存在 ❌(写在 results.json 的 hook_existence 字段)

**Human 决策点**:Phase 1 结果决定 Phase 2 走真 hook 路径(A)还是模拟路径(B)。

---

### Phase 2: 准确率测试(预计 1.5-2 小时)

#### 交付物
- [ ] test-cases.yaml(**18 条** = 15 原始 + 3 chat,见 §4.2 Component 3)
- [ ] haiku-prompt-template.md(envelope 格式,见 §4.2 Component 2)
- [ ] run-spike.sh(含 trap+restore 安全骨架,见 §4.2 Component 4)
- [ ] results.json(envelope schema,见 §4.2 Component 5)

#### 实施步骤

1. **写 test-cases.yaml** — 用 §4.2 Component 3 的 18 条(15 原始 + 3 chat),保留 ground_truth_decision_rules 顶部注释
2. **写 haiku-prompt-template.md** — 用 §4.2 Component 2 的 envelope 版本
3. **写 run-spike.sh** — 必须包含 §4.2 Component 4 的安全骨架(`set -euo pipefail`、`trap restore`、`check_timebox`)
4. **前置检查**:
   - `echo $ANTHROPIC_API_KEY` 是否非空,否则停下来配置
   - `command -v jq && command -v perl` 检查依赖
5. **Path B 全量执行**(canonical for accuracy):
   - 跑全部 18 条 case 通过 curl
   - 每条记录:`raw_response, parse_ok, matched_packs, actual_match, latency_ms, input_tokens, output_tokens, cost_usd, correct`
   - 写入 `results.json` 的 `path_b_results` 数组
6. **Path A 集成验证**(canonical for integration):
   - 仅在 Phase 1 情况 a 的前提下执行
   - 选 3 条代表性 case:1 clear_match (TC01) + 1 clear_nonmatch (TC06) + 1 edge (TC11)
   - 半手工执行(见 §4.2 Component 4 "Path A 触发"部分)
   - 把结果填入 `results.json` 的 `path_a_integration` block
7. **计算 metrics**(用 §4.2 Component 5 schema):
   - `path_b_correct = sum(correct)`
   - `path_b_accuracy_all = correct / 18`
   - `path_b_accuracy_high_confidence_only = correct_in_high / total_high`
   - `false_positives` / `false_negatives`(只统计 high-confidence cases)
   - `parse_failures = sum(!parse_ok)` — **单独统计,不算 classification 错误**
   - `mean_latency_ms` / `max_latency_ms`(不要 p95)
   - `mean_cost_usd` / `total_cost_usd`(从 token counts 算)
8. **手工复算一遍 metrics** — 防止脚本 bug(§8.2 要求)

#### Phase 2 完成证据
- [ ] results.json 完整(15 条 + metrics 块)
- [ ] 至少 3 条错误案例的 Haiku reason 摘录(如果全对,记录 0 条)

---

### Phase 3: 报告与建议(预计 30 分钟)

#### 交付物
- [ ] SPIKE-REPORT.md

#### 实施步骤

1. 把 Phase 1 + 2 的所有数据填进 SPIKE-REPORT.md(模板见 §4.2 Component 6)
2. 写明 verdict(GO / PARTIAL / NO-GO)
3. 写 Phase 2 设计建议(给未来 Alex 看):
   - Hook 应该怎么实现(基于本 spike 学到的)
   - Prompt 应该怎么调
   - Skill 检查点应该放哪
   - 已知的问题/边界
4. 诚实记录 time spent

#### Phase 3 完成证据
- [ ] SPIKE-REPORT.md 完整(6 个必填章节)

---

## 7. File Structure

### 7.1 Files to Create

```
.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/
├── SPIKE-REPORT.md            # 最终交付物
├── test-cases.yaml            # 15 条测试用例 + ground truth
├── haiku-prompt-template.md   # Haiku 分类 prompt
├── hook-poc-snippet.json      # settings.json 测试片段
├── run-spike.sh               # 自动化执行脚本
└── results.json               # 原始测试数据 + metrics
```

### 7.2 Files to Modify (with mandatory backup+trap)

- `.claude/settings.json` — **临时**加 UserPromptSubmit hook 测试。
- ⚠️ **强制安全机制**(P0 修复 — 不再靠自觉):
  1. `run-spike.sh` 启动时 `cp` 备份到 `.claude/settings.json.spike-backup-{timestamp}`
  2. `trap '...' EXIT` 在脚本退出(任何原因)时自动恢复
  3. AC9 验证用 `diff` 比对原文件(byte-identical),不是 grep
  4. 备份文件保留在原地,Blake 在 spike 完成后手工删除(确认恢复成功后)

---

## 8. Testing Requirements

### 8.1 Spike 自身的 Test 不需要 Unit Test

Spike 是一次性验证工具,不需要写 unit test。

### 8.2 验证 Spike 输出正确性

- [ ] results.json 的 metrics 块手工复算一遍(避免脚本 bug)
- [ ] SPIKE-REPORT.md 的 verdict 与 metrics 一致(不能 metrics 80% 但 verdict 写 90%)

### 8.3 Edge Cases

- [ ] 如果 Anthropic API 报错(rate limit / network) → 记录失败 case,不算分类错误
- [ ] 如果 Haiku 返回非 JSON(违反 prompt 指令) → 记录,算 false negative

---

## 9. Acceptance Criteria

Blake 的 spike 被认为完成,当且仅当:

- [ ] **AC1**: §7.1 列出的 6 个文件全部存在于 `.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/`
- [ ] **AC2**: SPIKE-REPORT.md §1 包含明确的 verdict(GO / PARTIAL / NO-GO)
- [ ] **AC3**: results.json `path_b_results` 数组包含 **18 条** case 的完整数据(envelope 字段:matched_packs, raw_response, parse_ok, actual_match, latency_ms, input_tokens, output_tokens, cost_usd, correct)
- [ ] **AC4**: results.json `metrics` 块包含 11 个字段:total_cases, path_b_correct, path_b_accuracy_all, path_b_accuracy_high_confidence_only, false_positives, false_negatives, **parse_failures**, mean_latency_ms, **max_latency_ms**, mean_cost_usd, total_cost_usd
- [ ] **AC5**: results.json `hook_existence` 块包含 user_prompt_submit_event_recognized + user_prompt_submit_actually_fires + evidence(都非空)
- [ ] **AC6 (accuracy)**: verdict = GO 要求 path_b_accuracy_high_confidence_only ≥ 0.80 AND mean_latency_ms < 1000
- [ ] **AC6b (integration — P0 修复)**: verdict = GO **额外要求** `path_a_integration.executed = true` AND `path_a_integration.hook_fired_count >= 3` AND `path_a_integration.additional_context_received_by_alex = true`。Path B 高 accuracy + Path A 失败 ≠ GO
- [ ] **AC6c (silent ignore — P0 修复)**: 如果 settings.json 接受配置无报错但 sentinel log 为空 → 必须记录为 silent ignore,verdict NO-GO on integration
- [ ] **AC7**: SPIKE-REPORT §7 包含 Phase 2 建议(GO 或 NO-GO 都要有)
- [ ] **AC8**: SPIKE-REPORT §6 Phase 2 Readiness Checklist 7 项全部 yes/no + 证据引用
- [ ] **AC9 (cleanup — P0 修复)**: `diff .claude/settings.json .claude/settings.json.spike-backup-*` 输出为空(byte-identical 恢复),不是 grep 检查
- [ ] **AC10 (BSD compat — P0 修复)**: run-spike.sh 通过以下显式检查清单(SPIKE-REPORT 中勾选):
  - [ ] 无 `grep -P` / `grep -oP` / PCRE 类(\d \s)在 -E patterns 中
  - [ ] 无 `sed -i` 不带空备份参数
  - [ ] 无 GNU-only `date -d` / `readlink -f` / `stat -c` / `xargs -r`
  - [ ] 无 `mktemp` 不带 XXXXXX 模板
  - [ ] hook glob patterns 用 `*.tad/` 不是 `*/.tad/`
- [ ] **AC11 (timebox — P0 修复)**: run-spike.sh 包含 `START_TIME` 和 `check_timebox` 函数,4.5h 硬上限。SPIKE-REPORT §8 诚实记录实际工时
- [ ] **AC12 (envelope schema — P0 修复)**: haiku-prompt-template.md 要求 Haiku 返回 `matched_packs` 数组 + `matched_recipes: []`(预留 Epic 3 接口),不是平铺 `match` 字段
- [ ] **AC13 (parse failure 隔离)**: parse_failures 单独统计,不算 false_negatives
- [ ] **AC14 (knowledge entry)**: SPIKE-REPORT §8 包含 architecture.md 草稿条目供 Alex Gate 4 merge

---

## 9.1 Spec Compliance Checklist

| # | AC | Verification | Expected Evidence |
|---|----|----|----|
| 1 | AC1 | `ls .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/` | 6 个文件 |
| 2 | AC2 | `grep -E "^## §1|Verdict:" SPIKE-REPORT.md` | 含 GO/PARTIAL/NO-GO 之一 |
| 3 | AC3 | `jq '.path_b_results \| length' results.json` | 输出 18 |
| 4 | AC4 | `jq '.metrics \| keys \| length' results.json` | ≥ 11 |
| 5 | AC5 | `jq '.hook_existence \| .user_prompt_submit_actually_fires' results.json` | true 或 false (非 null) |
| 6 | AC6 | `jq '.metrics.path_b_accuracy_high_confidence_only >= 0.8 and .metrics.mean_latency_ms < 1000' results.json` | true(仅当 verdict=GO) |
| 6b | AC6b | `jq '.path_a_integration.executed and .path_a_integration.additional_context_received_by_alex' results.json` | true(仅当 verdict=GO) |
| 8 | AC8 | `grep -c "^- \[.\]" SPIKE-REPORT.md` 在 §6 范围内 | 7 项 |
| 9 | AC9 | `diff .claude/settings.json .claude/settings.json.spike-backup-*` | 输出为空 |
| 10 | AC10 | SPIKE-REPORT §8 BSD 检查清单 5 项全勾;`grep -rE "grep -P\|grep -oP\|sed -i [^']\|date -d \|readlink -f\|stat -c " .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/run-spike.sh` | 无匹配 |
| 11 | AC11 | `grep -c "check_timebox\|START_TIME\|HARD_CAP" run-spike.sh` | ≥ 3 |
| 12 | AC12 | `grep "matched_packs\|matched_recipes" haiku-prompt-template.md` | 两个都有 |
| 13 | AC13 | `jq '.metrics.parse_failures' results.json` | 是数字(可以是 0) |
| 14 | AC14 | `grep "architecture.md" SPIKE-REPORT.md` | 有匹配 |

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **不要污染主 settings.json** — 测试完必须清理 UserPromptSubmit 配置(AC9 强制)
- ⚠️ **失败的 spike 也是成功的工作** — 如果 hook 不存在或准确率太低,**如实记录**,不要为了"过 spike"而调高门槛或挑用例
- ⚠️ **不要扩大 spike 范围** — 只测 1 个 capability,只用 15 条 case。Phase 2-4 才是大工作
- ⚠️ **BSD bash compatibility** — 历史教训 #1,不要用 `grep -P`
- ⚠️ **时间盒** — 4.5 小时硬上限(AC11),超过就升级,不要默默加班

### 10.2 Known Constraints

- Haiku API 可能有 rate limit — 15 条不应触发,但如果触发了 sleep 后重试
- Claude Code 版本差异可能影响 hook 行为 — 在 SPIKE-REPORT 里记录 `claude --version`

### 10.3 Sub-Agent 使用建议

- [ ] **bug-hunter** — 如果 hook 测试遇到诡异错误
- [ ] **test-runner** — 不适用(spike 没 unit test)
- [ ] **parallel-coordinator** — 不适用(任务太小)

可以不用 sub-agent — 这个 spike 简单到一个人(Blake)就能搞定。

---

## 11. Learning Content (Optional)

### 11.1 Decision Rationale: 为什么用 Light TAD 而不是 Full TAD

**选择**:Light TAD

**权衡**:

| 方案 | 优 | 缺 | 选择理由 |
|------|---|---|---------|
| Full TAD | 严谨完整 | 4-5 倍工作量 | ❌ Spike 是廉价验证,套 Full 喧宾夺主 |
| Standard TAD | 中等严谨 | 2-3 倍工作量 | ❌ 同上 |
| Light TAD ✅ | 快速,聚焦验证 | 不够严谨 | ✅ 选中 — spike 本质就是 fail-fast |
| Skip TAD | 最快 | 没记录,Phase 2 无依据 | ❌ Spike 结论是 Phase 2 的输入,必须有 handoff 留档 |

**💡 通用原则**:**Spike 用 Light TAD,Spike 之后的实施用 Standard/Full TAD**。

### 11.2 Decision Rationale: 为什么只用 1 个 capability 测试

**选择**:web-frontend.component_development(单个)

**理由**:
- Spike 目的是验证**机制**和**模式**,不是覆盖率
- 单个 capability 的 ground truth 标签 Alex 一个人就能定,多个 capability 会引入歧义
- 如果单个都跑不通,多个更跑不通 — fail-fast 原则
- Phase 3(集成测试)会扩展到多个 capability

---

## 12. Sub-Agent 使用记录

(Blake 完成后填)

| Sub-Agent | 调用? | 时机 | 输出 | 证据 |
|-----------|------|------|------|------|
| bug-hunter | ?/❌ | | | |
| test-runner | ❌ | N/A | | |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-07
**Version**: 3.1.0
**Status**: Draft — pending expert review
