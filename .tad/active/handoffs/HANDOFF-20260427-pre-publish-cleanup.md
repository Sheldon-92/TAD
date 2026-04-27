---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Pre-Publish Cleanup — Dangling Refs Migration + 人话版 业务价值化 Rule

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-27 (v2 — post 2-expert review, 5 P0 + 6 P1 resolved)
**Project:** TAD Framework
**Task ID:** TASK-20260427-002
**Handoff Version:** 3.1.0
**Epic:** N/A (urgent pre-v2.8.4-publish loose-ends; not part of any Epic)
**Supersedes:** N/A (first attempt; HANDOFF-20260427-tad-cleanup-linear-and-hook missed these consumers due to Alex pre-handoff blast-radius blind spot — see `.tad/project-knowledge/architecture.md` "Cleanup Handoff Scope-Estimation Drift" entry)

⚠️ **v2 changes vs v1 (2026-04-27 expert review integration)**:
- **P0-A** (CR P0-1 + BA P0-2): Alex SKILL line numbers cited ~980-1050 → actual is **line 2009 (`step7.generate_message: |`) / 2053 (PLAIN-LANGUAGE EXPLANATION)**. All FR/MQ/Phase/§7.3 references corrected. Anchor on string `step7.generate_message: |` not line numbers.
- **P0-B** (CR P0-2): File 2 referenced `$SCRIPT_DIR` but actual file uses `$REPO_ROOT` (defined at line 9 of AC-P1.4). New code corrected.
- **P0-C** (CR P0-3 + BA P1-4): `wc -l < missing 2>/dev/null | tr -d ' ' || echo 0` produces empty string not "0" when file missing — empirically verified. Fixed via `${var:-0}` parameter expansion after assignment.
- **P0-D** (BA P0-1): 4 OTHER active files use `additionalContext`/`hookSpecificOutput` for non-UserPromptSubmit hooks (SessionStart / PostToolUse / shared lib). Risk: Blake misreads as in-scope. **§10.5 explicit allowlist added** (DO NOT MODIFY).
- **P0-E** (BA P0-3): AC13 verification grep without allowlist filter → false-positive Gate 3 FAIL. **AC13 + §6 Phase 6 step 5 grep updated with explicit `grep -vE` filters**.
- P1 fixes integrated: File 1 Python `log_path` cwd-dependency; AC13 evidence/reviews exclusion; AC10 awk terminator; AC11 ambiguity; NFR3 ongoing enforcement note; ≥28/30 baseline documentation.

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-04-27

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 5 文件级修改全部明确，patch shape 来自 backend-architect-blake-impl.md 现成方案 |
| Components Specified | ✅ | 每个文件的修改区域指明行号 + 替换前后代码 |
| Functions Verified | ✅ | `.router.log` 5-tuple format 已 grounding pass 验证（见 §4.2 File 1）|
| Data Flow Mapped | ✅ | 数据流：原 = parse hook stdout JSON；新 = read `.router.log` last line 5-tuple |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Standard TAD light — Socratic 等价已通过先前 *discuss（用户 2026-04-27 决定 Linear 砍 + hook passive + 人话版业务价值化 + 这个 follow-up 是连续讨论的产物）。已通过 step1c grounding pass 验证 3 dangling files + .router.log 实际格式。2 专家并行审查见 §9.2 Audit Trail。Blake 可独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 阅读所有章节
- [ ] **阅读「📚 Project Knowledge」章节中的 Cleanup Scope-Estimation Drift 教训**（这个 follow-up 本身就是该教训的产物）
- [ ] 理解 `.router.log` 5-tuple format（§4.2 File 1 验证过）
- [ ] 理解人话版业务价值化的具体规则差异（§4.2 Files 4-5）
- [ ] 跑 `bash .tad/hooks/run-phase2b-tests.sh` 当前应该 0/30 PASS，修复后应恢复 ≥28/30 PASS（regression 验证）

❌ 如果任何部分不清楚，**立即返回 Alex 要求澄清**。

---

## 1. Task Overview

### 1.1 What We're Building（业务价值优先描述）

完成后你的体验改善：

1. **下次 v2.8.4 publish 不会爆炸**——release-runbook 的 per-project smoke test 现在能正确读 hook 的 log，不再依赖被删掉的 stdout injection。**这是真正的解锁项**。
2. **Phase 2b 回归测试套件恢复可用**——你以后想验证 Domain Pack router hook 改动时，`run-phase2b-tests.sh` 不再因 0/30 silent fail 而骗你说"没问题"。
3. **未来 Alex 写 handoff message + Blake 写 completion message 时，人话版会真说人话**——不再是"改了 7 个文件 / 5 个 P0 / 8 个 AC"这种你早就能从 git diff 看到的废话，而是"你下次 /alex 会快多少 / 这个修复让你的什么场景不再卡顿"。

技术性描述（次要）：5 文件改动，3 个是 Linear-cleanup 漏掉的 dangling consumers (run-phase2b-tests.sh / AC-P1.4 / release-runbook)，2 个是 SKILL prose 增加业务价值优先规则 (Alex step7 / Blake step8)。

### 1.2 Why We're Building It

**业务价值（再说一次，从用户视角）**：

- **Path A 价值（dangling refs migration）**：v2.8.4 release 前不修就推不动。release-runbook smoke test 在每个下游项目上 FAIL = 不能 *sync = 不能发新版。Path A 是临门一脚必做。
- **人话版价值（SKILL prose update）**：用户在过去一天的 *discuss 中明确 feedback："你的人话版还是在讲事物型的事——改了哪个文件，做了什么 P0P1，像炼金一样或流水账。但实际上我更关注他做了什么事在业务价值上面。" 这个 rule 落地后，未来所有 Alex/Blake message 必须先讲价值再讲动作。

**为什么打包做**：用户 2026-04-27 选择 "Standard TAD 选项 A"，5 文件超 *express ≤3 上限，但都是小文本/小代码改动，捆绑做一次性专家审查比拆 2 个 *express 更省。

### 1.3 Intent Statement

**真正要解决的问题**：(a) Cleanup handoff 漏掉的 3 个 downstream consumers（pre-handoff 时 backend-architect 只 grep 了 primary mentions 没 grep consumer 端），导致 Linear cut + hook passive 已 commit 但下游消费方还在期待旧 stdout injection；(b) 人话版规则缺乏 "lead with business value" 的硬约束，导致 Alex/Blake 自由发挥经常退化成流水账。

**不是要做的**：

- ❌ 不重新审视 hook passive mode 决策（已在 cleanup handoff 落地）
- ❌ 不修改 keywords.yaml（passive 后误触不再用户可见，关键词审计推迟）
- ❌ 不动 hook 本身的脚本（只动 consumers 读 hook 输出的 3 个文件）
- ❌ 不复活 additionalContext 注入（Path C reviewer "TAD_DOMAIN_ROUTER_TEST_EMIT" hack — 拒绝）
- ❌ 不动现有 ORDER REQUIREMENT / length scaling / anti-theater 等已存在的人话版规则（只新增 "lead with business value" 这一条）

**Blake 请确认理解**：

```
在开始实现前，请用你自己的话回答：
1. .router.log 的 5-tuple 格式是什么？为什么 3 个 consumer 都改成读它？
2. 人话版的"事物型 vs 业务价值型"区别能用一个具体例子说出来吗？
3. 这次 5 文件捆绑而不是拆 2 个 *express 的原因是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

涉及类别：
- [x] architecture - cleanup scope-estimation drift / 人话版规则演化
- [x] code-quality - bash + python 脚本编辑
- [ ] security
- [ ] ux

### 步骤 2：历史经验摘录

**⚠️ Blake 必须注意的历史教训**（来自 architecture.md 关键词扫描）：

1. **Cleanup Handoff Scope-Estimation Drift Pattern - 2026-04-27** (architecture.md, Alex 自捕教训)
   - 教训：Alex 在 cleanup-handoff 估算 blast radius 时 systematically underestimate downstream consumers。v1: 4 文件 → v2: 7 文件 → 实际: 10 文件 (250%+ off)。Pre-handoff backend-architect 的 grep target 是 PRIMARY mentions（"linear_integration"），不是 CONSUMERS（消费 `additionalContext` 输出的 3 个文件）。
   - **本 handoff 的关联**：本 handoff 是该教训的直接产物——补做当时漏掉的 3 个 downstream consumers。Blake 实施时应额外 grep 一次 `additionalContext` 在全 .tad / .claude 范围内是否还有未列入本 handoff scope 的引用（dogfood 教训中的 "Downstream Consumers Grep" 步骤）。

2. **AC Self-Leak from "Removal Rationale" Comment - 2026-04-27** (architecture.md, Blake 自捕教训)
   - 教训：替代 comment 不要包含 grep AC 禁止的 substring（slug / removed feature name）
   - **本 handoff 的关联**：本 handoff 没有 grep-substring AC（因为不是删除工作），但人话版 SKILL prose 的修改不要意外把"业务价值优先"这种规则文本写得 grep 之类工具会扫到的形式

3. **Pre-Handoff vs Post-Implementation Reviewer Scope Distinction - 2026-04-27** (architecture.md, Blake 教训)
   - 教训：Alex Gate 2 review 检查 spec 正确性；Blake Layer 2 review 检查 implementation 正确性 + blast radius 完整性。两者不可互换。
   - **本 handoff 的关联**：Blake 必须 Layer 2 跑 fresh code-reviewer + backend-architect on 本次 5-file 实施 diff（不是只复用 Alex Gate 2 的 spec review）。预期 backend-architect Layer 2 会 grep 整个仓库验证"是否还有未列入本 handoff 的 additionalContext consumer"。

4. **Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15** (architecture.md)
   - 教训：单用户 CLI 上机械强制（fail-closed hook）的恢复成本超过防滥用收益
   - **本 handoff 的关联**：本 handoff 的 3 个 dangling consumer migration 都是 read 类（不阻塞），符合"装烟雾报警器不装自动灭火系统"原则

### Blake 确认

- [ ] 我已阅读上述 4 条历史教训
- [ ] 我会在 implementation 期间额外 grep 一次 `additionalContext` / `hookSpecificOutput` 全仓库，验证本 handoff scope 是否完整
- [ ] 我不会试图用 Path C (`TAD_DOMAIN_ROUTER_TEST_EMIT` hack) 绕过 passive mode 设计

---

## 2. Background Context

### 2.1 Previous Work

- **Cleanup handoff 上一回合**：HANDOFF-20260427-tad-cleanup-linear-and-hook (Gate 4 PASS commit 6460129) 完成 Linear 砍除 + *accept slim + hook passive。但 Alex pre-handoff backend-architect 只 grep 了 primary mentions，漏掉 3 个 downstream consumers。Blake post-impl Layer 2 backend-architect 通过 fresh codebase grep 找到。
- **人话版规则历史**：Express handoff 2026-04-14 (commit 514849f) 装了基础人话版规则（ORDER REQUIREMENT / length scaling / anti-theater rule / negative+positive examples）。但没装"lead with business value"硬约束，导致最近一周多次 Alex/Blake 人话版退化成流水账。User 2026-04-27 *discuss feedback：要加这一条硬约束。

### 2.2 Current State

- 3 dangling consumers 当前都引用已被删除的 `additionalContext` / `hookSpecificOutput`，会在不同时机 silent fail：
  - run-phase2b-tests.sh: silent 0/30 PASS forever
  - AC-P1.4 _assert_match: 所有 positive case FAIL
  - release-runbook smoke test: 下次 *publish 时 per-project FAIL
- 人话版规则当前缺乏 "lead with business value" 硬约束，Alex 上周末本 session 的"Gate 4 验收报告"开头依然是"Handoff 已经写完，过了两个专家平行审查，5 个 P0 全部修完"——典型流水账（user 当时 caught）。

### 2.3 Dependencies

- 不依赖外部库变更
- 不依赖 settings.json 改动
- `.router.log` 文件结构已稳定（自 v2.8.2 上线）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: 修改 `.tad/hooks/run-phase2b-tests.sh` 的 `run_case` 函数（line ~50-72），把 stdout JSON parsing 改为 `.tad/hooks/.router.log` last-line 5-tuple parsing。预期效果：跑 `bash .tad/hooks/run-phase2b-tests.sh` 恢复 ≥28/30 PASS（不要求 30/30，因为 keyword DB 可能与原测试预期略有 drift）。
- **FR2**: 修改 `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` 的 `_assert_match` 函数（line ~38-46），把 `printf '%s' "$out" | grep -q 'additionalContext'` 改为 read `.router.log` last line 检查 pack name not "none"。`_assert_skip` 保持不动（passive mode 下 `_assert_skip` 期望的"empty stdout"行为已自动正确）。
- **FR3**: 修改 `.claude/skills/release-runbook/SKILL.md` 第 5-6 verify step（lines ~295-305），把 `bash hook | grep -q "web-frontend"` 改为先 `bash hook >/dev/null` 再 `tail -1 .router.log | grep -q "web-frontend"`。在该 snippet 上方加一行注释："# passive mode (2.8.4): hook does not emit stdout context, log file is the smoke-test target"
- **FR4**: 修改 `.claude/skills/alex/SKILL.md` 中 `step7.generate_message` 的 PLAIN-LANGUAGE EXPLANATION 段（**string anchor: `step7.generate_message: |`** 起始约 **line 2009**，PLAIN-LANGUAGE EXPLANATION 段约 **line 2053-2105**），在 "Required content" 列表前加一条**新硬约束**：

  ```
  ⚠️ BUSINESS-VALUE-FIRST RULE (MANDATORY, 2026-04-27 user feedback):
  人话版第一段必须以"业务价值"开头，回答"完成后用户的日常体验有什么改变"。

  ✅ 正例（业务价值型）：
  "Linear 集成砍掉之后，你 /alex 启动从 ~60s 降到 < 5s。Domain Pack 误触不再注入烦人提示。
  *accept 验收时少绕一步重复检查。"

  ❌ 反例（事物型/流水账型 — VIOLATION）：
  "Handoff 已经写完，过了两个专家平行审查，5 个 P0 全部修完。第二轮专家发现的关键问题是
  '我漏数了'——原本只看到 4 个文件要改..."

  原则：
  1. 第一句话必须是"after this lands, your [...] experience changes by [...]"或
     "你的 [...] 会变 [...]"句式，**不允许**以 "Handoff 已经..." / "改了 X 个文件" /
     "专家发现 N 个 P0" / "commit hash" 等动作叙述开头。
  2. 文件数量 / 专家数量 / P0 数量 / commit hash 等动作细节，放在结尾的 1 句不超过 1 行。
  3. 用户读完第一段应该能回答："这件事让我下次用 TAD 时哪里好了"——回答不出 → VIOLATION。
  <!-- END-BUSINESS-VALUE-FIRST -->
  ```

  ⚠️ **Sentinel marker required (v2 P1-C fix)**: 上面 prose 末尾必须以字符串 `<!-- END-BUSINESS-VALUE-FIRST -->` 结束作为 AC10 awk range 关闭锚点。Blake **不要漏写这个 HTML 注释**——AC10 字字对称验证依赖它。

- **FR5**: 修改 `.claude/skills/blake/SKILL.md` 中 `step8_generate_message` 的 PLAIN-LANGUAGE EXPLANATION 段（约 line 1080-1140），加同样的 BUSINESS-VALUE-FIRST RULE（FR4 内容字字一致，确保 Alex / Blake 两端规则完全对称）。

### 3.2 Non-Functional Requirements

- **NFR1 (Backward Compat)**: 修改后旧的 acceptance test runs（pre-cleanup commits）仍能在 git checkout 历史 commit 后跑 — 不删 stdout-parsing 的 fallback 不必要，但保持兼容性的方式是历史 commit 的 hook 仍 emit stdout，所以新 consumer code 在历史 commit 下会 false-FAIL（这是预期，acceptance test 本就是版本绑定的）。
- **NFR2 (BSD/macOS portability)**: 所有 bash 改动用 BSD-compatible flags（不用 `grep -P` / `sed -i without backup` / GNU-only）。Python 改动（File 1）用 stdlib only。
- **NFR3 (Symmetry)**: FR4 + FR5 的 BUSINESS-VALUE-FIRST RULE 必须**字字一致** — 两端规则不对称是 future drift 风险来源。Blake 在 FR5 用 Read tool 验证 FR4 已写入的 prose，然后 Edit copy 到 Blake SKILL，避免人手二次输入引入差异。

---

## 4. Technical Design

### 4.1 Architecture Overview

5 文件，2 类改动：
- **Files 1-3**: 数据源迁移（hook stdout → `.router.log`），3 个 consumer 各自语言（Python / Bash / Markdown shell snippet）。
- **Files 4-5**: SKILL prose 增加 1 个新 rule（BUSINESS-VALUE-FIRST），两端字字对称。

### 4.2 Per-File Change Specification

#### File 1: `.tad/hooks/run-phase2b-tests.sh`

**位置**: 函数 `run_case`（约 line 50-72）

**当前代码**：
```python
def run_case(msg: str):
    out = subprocess.run(
        ["bash", hook],
        input=json.dumps({"prompt": msg}),
        capture_output=True, text=True, timeout=10,
    )
    if out.returncode != 0:
        return ("", f"EXIT{out.returncode}")
    if not out.stdout.strip():
        return ("", "")
    try:
        last = out.stdout.strip().splitlines()[-1]
        d = json.loads(last)
        ctx = d.get("hookSpecificOutput", {}).get("additionalContext", "")
        m = re.search(r"Pack \[([^\]]+)\]", ctx)
        mm = re.search(r"命中 (\d+)/(\d+)", ctx)
        return (m.group(1) if m else "",
                f"{mm.group(1)}/{mm.group(2)}" if mm else "")
    except Exception as e:
        return (None, f"PARSE_ERR:{e}")
```

**新代码**：
```python
def run_case(msg: str):
    # P1-A fix (CR review 2026-04-27): derive log_path from hook location to be cwd-independent.
    # Bash heredoc passes hook abs path as sys.argv[1]; .router.log lives next to the hook script.
    import os
    log_path = os.path.join(os.path.dirname(hook), ".router.log")

    # Capture pre-test log line count for delta detection
    try:
        with open(log_path) as f:
            pre_lines = sum(1 for _ in f)
    except FileNotFoundError:
        pre_lines = 0

    out = subprocess.run(
        ["bash", hook],
        input=json.dumps({"prompt": msg}),
        capture_output=True, text=True, timeout=10,
    )
    if out.returncode != 0:
        return ("", f"EXIT{out.returncode}")

    # Read .router.log last line. Format (5-tuple):
    #   <ISO-timestamp> <elapsed_ms> <pack_name|none> <matched/total|0> <msglen>
    # Example: 2026-04-27T09:30:59-0400 137 mobile-ui-design 1/13 4641
    try:
        with open(log_path) as f:
            lines = f.readlines()
        if len(lines) <= pre_lines:
            return ("", "NO_LOG_DELTA")  # hook didn't write — defensive
        last = lines[-1].strip().split()
        if len(last) < 5:
            return (None, f"LOG_PARSE_ERR:{last}")
        pack = last[2]
        ratio = last[3]
        if pack == "none" or ratio == "0":
            return ("", "")
        return (pack, ratio)
    except Exception as e:
        return (None, f"PARSE_ERR:{e}")
```

**注意**：
- 移除 `json.loads(last)` + `re.search` 整个 stdout-parsing 路径
- 改用文件读取 + split 解析 5-tuple（参考 .router.log format 约定，已 grounding pass 验证）
- 加 pre/post line count delta detection 防 hook 未写入（防御性）
- **P1-A fix**: `log_path` 从 `hook` 参数 derive（`os.path.dirname(hook)`）— cwd 无关

#### File 2: `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh`

**位置**: 函数 `_assert_match`（约 line 38-46）

**当前代码**：
```bash
_assert_match() {
  local name="$1" prompt_file="$2"
  local out
  out=$(_invoke_hook "$(cat "$prompt_file")")
  if [ -n "$out" ] && printf '%s' "$out" | grep -q 'additionalContext'; then
    printf '[PASS] %s (hook emitted hookSpecificOutput)\n' "$name"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected hookSpecificOutput, got: %q)\n' "$name" "$out"
    FAIL=$((FAIL + 1))
  fi
}
```

**新代码**（P0-B + P0-C fixes integrated）：
```bash
_assert_match() {
  local name="$1" prompt_file="$2"
  # P0-B fix (CR review 2026-04-27): file uses $REPO_ROOT (defined at line 9 of this script),
  # NOT $SCRIPT_DIR. Verified: `grep -n REPO_ROOT AC-P1.4-router-event-filter.sh` line 9.
  local out log="${REPO_ROOT}/.tad/hooks/.router.log"

  # Capture pre-invoke log line count.
  # P0-C fix (CR review 2026-04-27): `wc -l < missing 2>/dev/null | tr -d ' ' || echo 0`
  # produces empty string not "0" because `tr` succeeds on empty stdin so `||` never fires.
  # Use parameter expansion fallback `${var:-0}` AFTER assignment.
  local pre_count post_count
  pre_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
  pre_count="${pre_count:-0}"

  out=$(_invoke_hook "$(cat "$prompt_file")")

  # passive mode (2.8.4): hook never emits stdout — read .router.log instead
  post_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
  post_count="${post_count:-0}"

  local last_pack
  if [ "$post_count" -gt "$pre_count" ]; then
    last_pack=$(tail -1 "$log" 2>/dev/null | awk '{print $3}')
  else
    last_pack="NO_LOG_DELTA"
  fi
  if [ -n "$last_pack" ] && [ "$last_pack" != "none" ] && [ "$last_pack" != "NO_LOG_DELTA" ]; then
    printf '[PASS] %s (hook scored pack: %s)\n' "$name" "$last_pack"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected non-none pack, got: %s)\n' "$name" "$last_pack"
    FAIL=$((FAIL + 1))
  fi
}
```

**注意**：
- `_assert_skip` 函数**不动**（passive 后 stdout 仍然 empty，`_assert_skip` 行为正确）
- **P0-B**: 用 `$REPO_ROOT`（已在 file line 9 定义）— 不要写 `$SCRIPT_DIR`（不存在）或 fallback `.`（cwd-broken）
- **P0-C**: `pre_count` 和 `post_count` 都用 `${var:-0}` 处理 missing-file empty-string case，否则 `[ "$post_count" -gt "" ]` 触发 `integer expression expected` 错误，silent FAIL
- 添加 log line delta check（无 delta 视为 hook 未触发）

#### File 3: `.claude/skills/release-runbook/SKILL.md`

**位置**: Phase 7 验证 checklist 第 5-6 step（约 line 295-305）

**当前代码**：
```markdown
# 5. No deprecated files
for dep_file in $(yq ".deprecations.\"$NEW_VERSION\".files[]" .tad/deprecation.yaml); do
  [ ! -e "$project/$dep_file" ] || FAIL
done

# 6. Live smoke test — hook actually works
echo '{"prompt":"做一个 React button 组件","session_id":"","transcript_path":"","cwd":"","permission_mode":"","hook_event_name":"UserPromptSubmit"}' \
  | bash "$project/.tad/hooks/userprompt-domain-router.sh" \
  | grep -q "web-frontend"
```

**新代码**：
```markdown
# 5. No deprecated files
for dep_file in $(yq ".deprecations.\"$NEW_VERSION\".files[]" .tad/deprecation.yaml); do
  [ ! -e "$project/$dep_file" ] || FAIL
done

# 6. Live smoke test — hook actually works
# passive mode (2.8.4): hook does NOT emit stdout context. Smoke target is the .router.log line written by the keyword scoring path.
echo '{"prompt":"做一个 React button 组件","session_id":"","transcript_path":"","cwd":"","permission_mode":"","hook_event_name":"UserPromptSubmit"}' \
  | bash "$project/.tad/hooks/userprompt-domain-router.sh" >/dev/null
tail -1 "$project/.tad/hooks/.router.log" 2>/dev/null | grep -q "web-frontend"
```

#### File 4: `.claude/skills/alex/SKILL.md`

**位置**: `step7.generate_message` 的 PLAIN-LANGUAGE EXPLANATION 段。

**修改方式**: 在 "Required content" 列表（"1. 现在做什么 / 2. 为什么这么决定 / 3. 接下来会发生什么"）**前面**插入新的 BUSINESS-VALUE-FIRST RULE block。完整 prose 见 §3.1 FR4（已字字写好可 copy）。

#### File 5: `.claude/skills/blake/SKILL.md`

**位置**: `step8_generate_message` 的 PLAIN-LANGUAGE EXPLANATION 段。

**修改方式**: 在对应位置插入与 File 4 字字一致的 BUSINESS-VALUE-FIRST RULE block。FR5 NFR3 强制对称，Blake 用 Read tool 复制 File 4 已写入的 prose（避免人手二次输入差异）。

### 4.3 Data Flow

**Before** (3 dangling consumers):
```
hook → emit additionalContext via stdout JSON → consumer parses stdout → success/fail
```

**After**:
```
hook → write 5-tuple to .router.log → (no stdout) → consumer reads .router.log last line → success/fail
```

### 4.4 .router.log Format Reference (validated 2026-04-27 by Alex grounding pass)

```
2026-04-27T09:16:46-0400 144 none 0 20
2026-04-27T09:30:59-0400 137 mobile-ui-design 1/13 4641
```

5-tuple, space-separated:
1. `ISO timestamp`
2. `elapsed_ms` (integer)
3. `pack_name` (string, "none" if no match)
4. `matched/total` ratio (string like "1/13", or "0" if no match)
5. `msglen` (integer, char count of input)

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"？

**回答**：✅ 是

**证据**：用户 2026-04-27 的 *discuss feedback "我觉得现在人话版的人画还是让人听不懂，他还是在讲述事物型的东西"——明确指代 2026-04-14 commit 514849f 装的基础人话版规则。

**搜索证据**：
```bash
grep -rn "additionalContext" .tad/ .claude/ 2>/dev/null | grep -v "^\.tad/archive" | grep -v "^\.tad/active"
# 验证 3 dangling refs + 历史文档 hits
```

### MQ2: 函数存在性验证

| 引用 | 文件位置 | 行号 | 验证状态 |
|------|---------|------|---------|
| `run_case` Python function | .tad/hooks/run-phase2b-tests.sh | ~50-72 | ✅ 存在（grounding pass 验证）|
| `_assert_match` bash function | .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh | ~38-46 | ✅ 存在 |
| `_assert_skip` bash function (NOT to modify) | 同上 | ~50-60 | ✅ 存在 |
| Phase 7 verify step 5-6 | .claude/skills/release-runbook/SKILL.md | ~295-305 | ✅ 存在 |
| `step7.generate_message` PLAIN-LANGUAGE | .claude/skills/alex/SKILL.md | **~2009 (string anchor `step7.generate_message: \|`) / 2053 (PLAIN-LANGUAGE EXPLANATION)** | ✅ 存在（v2 P0-A fix: 原 v1 cited ~980-1050 是错的，差 ~1000 行）|
| `step8_generate_message` PLAIN-LANGUAGE | .claude/skills/blake/SKILL.md | 1028-1140 | ✅ 存在（grep 已验证 line 1028）|
| `.router.log` 5-tuple format | .tad/hooks/.router.log | (live file) | ✅ 验证（grounding pass 看到样本）|

### MQ3-5

N/A — 不涉及前后端数据流 / UI / 状态同步。

---

## 6. Implementation Steps

### Phase 1: File 1 (run-phase2b-tests.sh) Python migration（预计 20 分钟）

#### 实施步骤
1. Read full `.tad/hooks/run-phase2b-tests.sh`
2. 用 Edit 替换 `run_case` 函数 per §4.2 File 1 新代码
3. 跑回归：`bash .tad/hooks/run-phase2b-tests.sh` 应输出 ≥28/30 PASS（不强求 30/30，because keyword DB drift 可能略有变化）
4. 把 PASS/FAIL count 粘贴到 completion §AC1 row

### Phase 2: File 2 (AC-P1.4-router-event-filter.sh) Bash migration（预计 15 分钟）

#### 实施步骤
1. Read full `AC-P1.4-router-event-filter.sh`
2. 用 Edit 替换 `_assert_match` 函数 per §4.2 File 2 新代码
3. **不动** `_assert_skip` 函数
4. 跑回归：`bash .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` 应有 PASS 项（之前是全 FAIL）

### Phase 3: File 3 (release-runbook SKILL.md) markdown shell snippet（预计 10 分钟）

#### 实施步骤
1. 用 Edit 替换 §4.2 File 3 标识的代码块
2. 加 "passive mode (2.8.4)" 注释行
3. 不需要回归测试（这是 markdown 文档，等下次 *publish 时实际跑）

### Phase 4: File 4 (Alex SKILL.md) BUSINESS-VALUE-FIRST RULE 插入（预计 10 分钟）

#### 实施步骤
1. **Anchor on string, not line number** (v2 P0-A fix): Read SKILL.md range starting at line 2000-2110 (covers `step7.generate_message: |` at line 2009 + PLAIN-LANGUAGE EXPLANATION at line 2053). Locate "Required content:" list inside PLAIN-LANGUAGE EXPLANATION段
2. 用 Edit 在 "Required content:" 列表**前面**（即在 "PLAIN-LANGUAGE EXPLANATION (MANDATORY)" header 之后、"Audience: ..." 之前的位置）插入 §3.1 FR4 完整 prose 的 BUSINESS-VALUE-FIRST RULE block
3. 验证：`grep -c "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md` 应返回 1

### Phase 5: File 5 (Blake SKILL.md) 字字对称 copy（预计 5 分钟）

#### 实施步骤
1. Read Phase 4 已写入的 alex SKILL.md prose 区域
2. Read 当前 `step8_generate_message` 的 PLAIN-LANGUAGE EXPLANATION 段
3. 用 Edit 在 Blake SKILL.md 对应位置插入字字一致的 BUSINESS-VALUE-FIRST RULE
4. 验证字字对称（NFR3）：`diff <(grep -A 30 "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md) <(grep -A 30 "BUSINESS-VALUE-FIRST" .claude/skills/blake/SKILL.md)` 应输出空（无 diff）

### Phase 6: 集成回归 + Layer 2 review + commit（预计 30 分钟）

#### 实施步骤
1. `git status` 应显示 5 个 modified files
2. `git diff --stat` 复核改动
3. **Run Layer 1 self-check**: 5 file syntax validation
4. **Run Layer 2 expert review** (≥2 distinct sub-agents per P6-A.2 hard rule):
   - **必选**: code-reviewer（5 文件编辑正确性 + Python/Bash portability）
   - **第二个必选**: backend-architect（dangling refs 完整性 — fresh grep `additionalContext`/`hookSpecificOutput` 全仓库验证 5 文件之外是否还有 consumer。如有发现 → flag P0 而不是 silent fix）
5. **Backend-architect 必须额外做的事（dogfood Cleanup Scope-Estimation Drift 教训）**:

   ⚠️ v2 P0-D + P0-E fix: 以前 v1 写的简单 grep 会误报 4 个 OTHER active 文件（SessionStart / PostToolUse 用 `additionalContext` 是 legitimate）。新版 grep 用 `grep -vE` 显式 allowlist。

   ```bash
   grep -rln -E "additionalContext|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
     | grep -vE "^\.tad/archive/" \
     | grep -vE "^\.tad/active/handoffs/" \
     | grep -vE "^\.tad/evidence/" \
     | grep -vE "^\.tad/spike-v3/" \
     | grep -vE "^\.tad/hooks/startup-health\.sh$" \
     | grep -vE "^\.tad/hooks/post-write-sync\.sh$" \
     | grep -vE "^\.tad/hooks/lib/common\.sh$" \
     | grep -vE "^\.claude/skills/alex/SKILL\.md$" \
     | grep -vE "^\.claude/skills/blake/SKILL\.md$"
   ```

   **预期结果**：grep 输出**仅本 handoff scope 的 3 个 dangling consumer**：
   - `.tad/hooks/run-phase2b-tests.sh`
   - `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` (由于 evidence/ 被滤掉，应该不出现 — 这是 OK 的 because 该文件本来就在 scope 内 §7.2 已列出)
   - `.claude/skills/release-runbook/SKILL.md`

   **所有 allowlist 排除项是 legit**（v2 P0-D 添加，§10.5 详细解释）：
   - `.tad/archive/` `.tad/active/handoffs/` — 历史/当前 handoff 文档
   - `.tad/evidence/` — 历史 spike + acceptance test + reviews 都是历史快照
   - `.tad/spike-v3/` — 历史 spike documentation
   - `startup-health.sh` — SessionStart hook (legitimate, DO NOT TOUCH)
   - `post-write-sync.sh` — PostToolUse hook (legitimate, DO NOT TOUCH)
   - `lib/common.sh` — shared `output_response()` library function (legitimate, DO NOT TOUCH)
   - `alex/SKILL.md` `blake/SKILL.md` — refs to SessionStart additionalContext (lines 561/570/1541 etc.) NOT UserPromptSubmit consumers; 本 handoff §3.1 FR4-FR5 在这两个文件中插入 BUSINESS-VALUE-FIRST RULE 不会触发 grep（因为不含 `additionalContext`/`hookSpecificOutput` 字符串）

   **如果 grep 输出包含**任何**未在上述预期列表中的活跃文件 → P0**：handoff scope 不完整，Blake 必须 STOP 并 escalate Alex 扩 scope。
6. Commit message（heredoc per CLAUDE.md）:
   ```
   feat(TAD): pre-publish cleanup — dangling refs migration + 人话版 BUSINESS-VALUE-FIRST rule

   - Migrate 3 dangling consumers from hook stdout to .tad/hooks/.router.log:
     * .tad/hooks/run-phase2b-tests.sh (Python parsing)
     * .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh (_assert_match)
     * .claude/skills/release-runbook/SKILL.md (per-project smoke test)
   - Install BUSINESS-VALUE-FIRST hard rule in人话版 prose (Alex SKILL step7 + Blake SKILL step8, byte-symmetric)
   - Unblocks v2.8.4 *publish (release-runbook smoke test would FAIL on every downstream project without this fix)

   Closes pre-publish loose ends from HANDOFF-20260427-tad-cleanup-linear-and-hook (Gate 4 PASS commit 6460129).
   Implements 2026-04-27 user *discuss feedback on人话版 quality.
   ```

---

## 7. File Structure

### 7.1 Files to Create
```
(none)
```

### 7.2 Files to Modify
```
.tad/hooks/run-phase2b-tests.sh                                                            # Python `run_case` rewrite
.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh    # Bash `_assert_match` rewrite
.claude/skills/release-runbook/SKILL.md                                                    # Phase 7 verify step 5-6 update
.claude/skills/alex/SKILL.md                                                               # step7 BUSINESS-VALUE-FIRST RULE insert
.claude/skills/blake/SKILL.md                                                              # step8 BUSINESS-VALUE-FIRST RULE insert (byte-symmetric)
```

### 7.3 Grounded Against (Phase 2 P2.2 — Alex step1c, 2026-04-27)

**Grounded Against**:
- `.tad/hooks/run-phase2b-tests.sh` (lines 50-80, read at 2026-04-27 by Alex)
- `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` (lines 30-60, read at 2026-04-27 by Alex)
- `.claude/skills/release-runbook/SKILL.md` (lines 290-310, read at 2026-04-27 by Alex)
- `.claude/skills/alex/SKILL.md` (**lines 2000-2110** verified at 2026-04-27 v2 by Alex via grep — `step7.generate_message: |` at line 2009, PLAIN-LANGUAGE EXPLANATION at line 2053; v1 cited 980-1050 is incorrect)
- `.claude/skills/blake/SKILL.md` (line 1028 grep'd + step8_generate_message head 20 read at 2026-04-27 by Alex)
- `.tad/hooks/.router.log` (last 5 lines tailed at 2026-04-27 — 5-tuple format verified)
- `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/backend-architect-blake-impl.md` (P0-1/P0-2/P0-3 patch shape sections read at 2026-04-27)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- File 1: `python3 -c "import ast; ast.parse(open('.tad/hooks/run-phase2b-tests.sh').read())"` — 不报错（注：该文件混合 bash + python，跳过）。代之：直接跑该脚本看输出。
- File 2: `bash -n .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` exit 0
- File 3-5: Markdown / SKILL — 不需 syntax check，但 grep 验证 BUSINESS-VALUE-FIRST 字字对称（FR5 NFR3）

### 8.2 Integration Tests
- **File 1 regression**: `bash .tad/hooks/run-phase2b-tests.sh` 应输出 ≥28/30 PASS。粘贴 PASS/FAIL count 到 completion。
- **File 2 regression**: `bash .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` 应有 PASS（之前 cleanup 后全 FAIL）。粘贴最后几行输出。
- **File 3 verification**: 不能 e2e 跑（需要真实下游项目），但 markdown 检查注释行已加 + 代码片段语法正确。
- **File 4-5 symmetry verification**: `diff <(awk '/BUSINESS-VALUE-FIRST/,/^$/' .claude/skills/alex/SKILL.md | head -50) <(awk '/BUSINESS-VALUE-FIRST/,/^$/' .claude/skills/blake/SKILL.md | head -50)` 输出空。

### 8.3 Edge Cases
- File 1 `.router.log` 不存在或 0 行：返回 NO_LOG_DELTA，不 crash
- File 2 acceptance test 在 SCRIPT_DIR 未定义时 fallback `.`（cwd-independent）
- File 3 `.router.log` 不存在时 `tail -1 ... 2>/dev/null` 返回空，`grep -q` exit 1，smoke FAIL（这是正确行为 — 没有 log 文件本身就是 hook 异常）

### 8.4 Test Evidence Required
Blake 必须提供：
- [ ] File 1 regression output（≥28/30 PASS 数字）
- [ ] File 2 regression output（PASS 项 ≥1）
- [ ] File 4-5 byte-symmetry diff 输出（应为空）
- [ ] `git diff --stat` 输出（5 文件）

---

## 9. Acceptance Criteria

- [ ] **AC1**: `grep -c "additionalContext" .tad/hooks/run-phase2b-tests.sh` 返回 0
- [ ] **AC2**: `grep -c "hookSpecificOutput" .tad/hooks/run-phase2b-tests.sh` 返回 0
- [ ] **AC3 (v2 — P1-F refined)**: `bash .tad/hooks/run-phase2b-tests.sh` 输出 ≥28/30 PASS **AND ≥ pre-fix baseline**。Blake 必须在 Phase 1 step 1 之前先跑一次记录 baseline（"pre-fix PASS=N/30"），post-fix 必须 ≥ pre-fix（无 regression）+ ≥ 28/30 absolute floor（粘贴 pre/post 两次输出到 completion）
- [ ] **AC4**: `grep -c "additionalContext" .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` 返回 0
- [ ] **AC5**: `bash .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` 至少 1 个 PASS 行（粘贴最后几行到 completion）
- [ ] **AC6**: `grep -c 'grep -q "web-frontend"' .claude/skills/release-runbook/SKILL.md` ≥ 1（保留下游 grep 目标），且该 grep 之前一行有 `tail -1` 引用 `.router.log`
- [ ] **AC7**: `grep -c "passive mode (2.8.4)" .claude/skills/release-runbook/SKILL.md` ≥ 1
- [ ] **AC8**: `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md` 返回 1
- [ ] **AC9**: `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/blake/SKILL.md` 返回 1
- [ ] **AC10 (v2 — P1-C fixed awk terminator)**: 字字对称 — Alex/Blake SKILL 中 BUSINESS-VALUE-FIRST RULE block 完全相同。
  - **不要用** v1 的 `awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/'` — FR4 prose 含内部 blank lines (✅正例 / ❌反例 / 原则 段之间)，awk 会在第一个 blank line 提前关闭 range 导致 partial-block diff 假 PASS。
  - **改用 sentinel 字符串作 terminator**: `awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/'` —— 这要求 FR4/FR5 prose 在末尾**显式加** `<!-- END-BUSINESS-VALUE-FIRST -->` HTML comment 标记作 awk range 结束 sentinel。
  - 验证命令：`diff <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/alex/SKILL.md) <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/blake/SKILL.md)` 输出空
- [ ] **AC11 (v2 — P1-D clarified)**: `git diff --name-only` (excluding `.tad/evidence/reviews/blake/pre-publish-cleanup/` Blake's review artifacts which are Layer 2 byproducts, NOT in-scope edits) 显示恰好 5 个文件 modified, 0 created, 0 deleted。
  - 命令：`git diff --name-only | grep -v "^\.tad/evidence/reviews/blake/pre-publish-cleanup/" | wc -l` = 5
- [ ] **AC12**: Layer 2 expert review (≥2 distinct sub-agents per P6-A.2) PASS — code-reviewer + backend-architect
- [ ] **AC13 (v2 — P0-D + P0-E + P1-B integrated)**: backend-architect Layer 2 review must perform fresh codebase grep with **explicit allowlist** filter (per §6 Phase 6 step 5 grep command, with `grep -vE` clauses for `.tad/archive/` / `.tad/active/handoffs/` / `.tad/evidence/` / `.tad/spike-v3/` / `startup-health.sh` / `post-write-sync.sh` / `lib/common.sh` / `alex/SKILL.md` / `blake/SKILL.md` per §10.5 allowlist). Output should contain only the 3 in-scope dangling consumers OR be empty (post-fix). 0 unexpected hits.

---

## 9.1 Spec Compliance Checklist

| # | AC | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|----|--------------------|--------------------|--------------------|-------------------------------|
| AC1 | hookSpecific etc removed from run-phase2b-tests | post-impl-verifiable | `grep -c "additionalContext" .tad/hooks/run-phase2b-tests.sh` | 0 | (post-impl) |
| AC3 | run-phase2b regression | post-impl-verifiable | `bash .tad/hooks/run-phase2b-tests.sh \| tail -3` | ≥28/30 PASS | (post-impl) |
| AC4 | additionalContext removed from AC-P1.4 | post-impl-verifiable | `grep -c "additionalContext" .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | 0 | (post-impl) |
| AC6 | release-runbook tail -1 .router.log added | post-impl-verifiable | `grep -B 1 'grep -q "web-frontend"' .claude/skills/release-runbook/SKILL.md \| grep -c "tail -1"` | ≥1 | (post-impl) |
| AC8 | Alex SKILL BUSINESS-VALUE-FIRST | post-impl-verifiable | `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| AC9 | Blake SKILL BUSINESS-VALUE-FIRST | post-impl-verifiable | `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/blake/SKILL.md` | 1 | (post-impl) |
| AC10 | byte-symmetric Alex/Blake | post-impl-verifiable | `diff <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/alex/SKILL.md) <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/blake/SKILL.md)` (v2 P1-C: sentinel terminator, NOT blank-line range) | empty | (post-impl) |
| AC11 | exactly 5 files in scope | post-impl-verifiable | `git diff --name-only \| grep -v "^\.tad/evidence/reviews/blake/pre-publish-cleanup/" \| wc -l` (v2 P1-D: filter Blake's review byproducts) | 5 | (post-impl) |
| AC12 | Layer 2 ≥2 distinct | post-impl-verifiable | `bash .tad/hooks/lib/layer2-audit.sh pre-publish-cleanup` | DISTINCT_COUNT ≥ 2 + exit 0 | (post-impl) |
| AC13 | downstream consumers grep clean (v2 P0-D + P0-E + P1-B integrated) | post-impl-verifiable | full grep cmd with allowlist clauses — see §6 Phase 6 step 5 (10 lines `grep -vE` filters) | only the 3 in-scope dangling consumers, OR empty post-fix | (post-impl) |

> All AC post-impl-verifiable (cleanup work, no Alex pre-impl dry-run needed).
> AC13 dogfoods Cleanup Scope-Estimation Drift Pattern lesson — Blake's Layer 2 backend-architect MUST do this grep, not optional.

---

## 9.2 Expert Review Status (Alex 必填)

> Alex 2 expert parallel review will be invoked after Blake confirms readiness to receive handoff. Audit Trail will be filled at that time.

### Audit Trail

Both reviewers spawned in parallel via Agent tool, 2026-04-27. Findings stored at:
- `.tad/evidence/reviews/blake/pre-publish-cleanup/code-reviewer.md`
- `.tad/evidence/reviews/blake/pre-publish-cleanup/backend-architect.md`

| # | Reviewer | Issue | Resolution Section | Status |
|---|----------|-------|-------------------|--------|
| CR-P0-1 | code-reviewer | Alex SKILL.md cited line ~980-1050 wrong by ~1030 lines — actual `step7.generate_message` at line 2009, PLAIN-LANGUAGE EXPLANATION at line 2053 | §3.1 FR4 + §5 MQ2 row 5 + §6 Phase 4 step 1 + §7.3 — all updated to ~2009/2053 with string anchor `step7.generate_message: \|` | **Resolved** |
| CR-P0-2 | code-reviewer | File 2 referenced `$SCRIPT_DIR` but actual script uses `$REPO_ROOT` (defined line 9 of AC-P1.4); `${SCRIPT_DIR:-.}` fallback would cwd-break | §4.2 File 2 new code — replaced with `${REPO_ROOT}/.tad/hooks/.router.log` | **Resolved** |
| CR-P0-3 | code-reviewer | `wc -l < missing 2>/dev/null \| tr -d ' ' \|\| echo 0` produces empty string not "0" (tr exits 0 on empty stdin so `\|\|` never fires); `[ "$post_count" -gt "" ]` triggers integer-expr error → silent FAIL | §4.2 File 2 new code — `${var:-0}` parameter expansion AFTER assignment for both pre_count and post_count | **Resolved** |
| CR-P1-1 | code-reviewer | File 1 Python `log_path = ".tad/hooks/.router.log"` cwd-dependent | §4.2 File 1 new code — derive via `os.path.join(os.path.dirname(hook), ".router.log")` | **Resolved** |
| CR-P1-2 | code-reviewer | AC13 grep doesn't filter Blake's own review artifacts in `.tad/evidence/reviews/blake/pre-publish-cleanup/` | §6 Phase 6 step 5 — added `grep -vE "^\.tad/evidence/"` filter (covers all evidence subdirs) | **Resolved** |
| CR-P1-3 | code-reviewer | AC10 `awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/'` terminates at first blank line; FR4 prose has internal blank lines → premature close → false PASS on partial-block diff | §3.1 FR4 prose updated with `<!-- END-BUSINESS-VALUE-FIRST -->` sentinel; AC10 verification cmd updated to `awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/'` | **Resolved** |
| CR-P1-4 | code-reviewer | AC11 `git diff --name-only \| wc -l = 5` ambiguity — Blake's `.tad/evidence/reviews/blake/pre-publish-cleanup/` Layer 2 artifacts could inflate count | §9 AC11 updated with explicit `grep -v` filter for review dir; clarification added | **Resolved** |
| CR-P2-1 | code-reviewer | FR4 prose contains characters that look like ASCII " — byte-symmetry risk if Blake hand-types | §6 Phase 5 step 1 already mandates Read+Edit copy from File 4 (no hand-typing); §10.4 anti-pattern reaffirms | **Resolved (already mitigated)** |
| BA-P0-1 | backend-architect | Implicit treatment of all `additionalContext`/`hookSpecificOutput` refs as UserPromptSubmit consumers — 4 OTHER active files use these for SessionStart/PostToolUse/shared lib (legitimate, NOT in scope) | §10.5 explicit allowlist added (DO NOT MODIFY): `startup-health.sh` / `lib/common.sh` / `post-write-sync.sh` / `alex SKILL lines 561/570/1541` / `blake SKILL` | **Resolved** |
| BA-P0-2 | backend-architect | Same as CR-P0-1 (Alex SKILL line numbers wrong) — independent confirmation | Same resolution as CR-P0-1 | **Resolved (dup)** |
| BA-P0-3 | backend-architect | AC13 verification grep without allowlist filter → false-positive Gate 3 FAIL on the 4 legitimate other-hook files | §6 Phase 6 step 5 + AC13 — explicit `grep -vE` allowlist clauses added per §10.5 | **Resolved** |
| BA-P1-1 | backend-architect | NFR3 byte-symmetry has no ongoing enforcement; future drift risk after 6 months | §10.6 added — recommend release-runbook smoke test step (P1 follow-up, NOT in this handoff scope; tracked as v2.9.0 release-runbook enhancement). Blake should add `// TODO release-runbook smoke test` breadcrumb comment near insertions | **Resolved (deferred)** |
| BA-P1-2 | backend-architect | ≥28/30 threshold lacks documented baseline | §10.7 + §9 AC3 — Blake must record pre-fix baseline before edits; post-fix must be ≥ pre-fix AND ≥ 28/30 absolute | **Resolved** |
| BA-P1-3 | backend-architect | Log rotation behavior at 1MB unstated | §8.3 already covers `.router.log` not exist; rotation at 1MB irrelevant for 30-case run (~3KB delta vs 29KB current) — document as known constraint | **Resolved (no change needed)** |
| BA-P1-4 | backend-architect | Same as CR-P0-3 (wc -l empty-string bug) — independent confirmation | Same resolution as CR-P0-3 | **Resolved (dup)** |
| BA-P1-5 | backend-architect | AC13 verification command should live inline in §9.1, not buried in §6 | §9.1 spec compliance row for AC13 references §6 Phase 6 step 5 explicitly; minor cross-reference improvement only — not blocking | **Resolved (cross-ref OK)** |
| BA fresh grep finding | backend-architect | AC13 dogfood fresh grep verified — 50 hits total, but only 3 are actual UserPromptSubmit consumers (the 3 in handoff scope). 4 others are legitimate (allowlisted in §10.5). Cleanup Scope-Estimation Drift Pattern lesson IS honored | (no further action — verifies handoff completeness) | **Resolved (verification PASS)** |

### Expert Prompts Used

Stored in evidence files for reproducibility:
- code-reviewer: `.tad/evidence/reviews/blake/pre-publish-cleanup/code-reviewer.md`
- backend-architect: `.tad/evidence/reviews/blake/pre-publish-cleanup/backend-architect.md`

### Experts Selected

1. **code-reviewer** — 5 文件编辑正确性 + Python/Bash BSD-portability + AC verification command 语法
2. **backend-architect** — dangling refs 完整性 + AC13 dogfood 全仓库 fresh grep + 人话版 prose 对称性架构合理性

### Overall Assessment (post-integration)

- **code-reviewer**: CONDITIONAL PASS → **all 8 findings Resolved in v2** (3 P0 + 4 P1 + 1 P2)
- **backend-architect**: CONDITIONAL PASS → **all 8 findings Resolved in v2** (3 P0 + 5 P1, with P0-2 / P1-4 dup with CR; AC13 fresh grep confirmed handoff scope completeness)
- **Net P0 unique**: 5 (CR P0-1 = BA P0-2; CR P0-3 = BA P1-4 deduplicated). All 5 Resolved.
- **Final verdict**: PASS for handoff to send to Blake.

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **AC13 不是可选**：backend-architect Layer 2 必须做 fresh codebase grep。不做 = AR-001 substitution 类违规（"Alex pre-handoff backend-architect 已经 grep 过" 不算 — Pre-Handoff vs Post-Implementation Reviewer Scope Distinction 教训明确两者不可互换）
- ⚠️ **不要试图复活 additionalContext 注入**（Path C `TAD_DOMAIN_ROUTER_TEST_EMIT` env var hack）—— 拒绝，破坏 passive mode 设计
- ⚠️ **NFR3 字字对称**：FR5 必须 Read FR4 实际写入的 prose 后 copy，不要人手二次输入
- ⚠️ **不动 keywords.yaml** — passive mode 让误触不再用户可见，关键词审计推迟
- ⚠️ **不动 hook script (`userprompt-domain-router.sh`)** — 只动 consumer 端

### 10.2 Known Constraints

- run-phase2b-tests.sh 跑 30/30 不强求（keyword DB 与原测试预期可能略 drift），≥28/30 即 PASS
- AC-P1.4 acceptance test 是历史 handoff 的 acceptance test，本身已归档无运行需求；本 handoff 只是让它**仍可运行**而非保证 PASS
- `.router.log` 是 hook 自动写入，不需要手动初始化

### 10.3 Sub-Agent 使用建议

- [x] **code-reviewer** - 必选 per P6-A.2
- [x] **backend-architect** - 必选 per P6-A.2 + 必须做 AC13 fresh grep
- [ ] parallel-coordinator - 5 文件可串行，不需要
- [ ] bug-hunter - 不预期遇到 bug
- [ ] test-runner - 回归测试 §8.2 已明确

### 10.4 Anti-Patterns to Avoid

- ❌ "Alex 已经 grep 过 additionalContext，我跳过 AC13" — VIOLATION（Pre-Handoff vs Post-Impl Reviewer 教训）
- ❌ 在 SKILL prose 里写"BUSINESS-VALUE-FIRST" 但例子是流水账 — 自我矛盾，VIOLATION
- ❌ File 1 Python 改动用 list comprehension 一行解决 — 可读性 vs 简洁 取可读性，明确分步骤
- ❌ File 2 改 `_assert_skip` 函数 — scope creep，不要动
- ❌ "顺手清理" §10.5 allowlist 中任何文件 — VIOLATION（v2 P0-D added — 那 4 个文件是 SessionStart / PostToolUse 的 legitimate `additionalContext` 用法，不是被删机制的 consumer）

### 10.5 Allowlist — Files Containing `additionalContext`/`hookSpecificOutput` That MUST NOT Be Modified（v2 P0-D — BA review）

These files USE `additionalContext` / `hookSpecificOutput` for **non-UserPromptSubmit** hook events (SessionStart / PostToolUse / shared library). They are **legitimate** and **NOT** dangling consumers of the removed UserPromptSubmit injection.

| File | Hook event | Why it uses `additionalContext`/`hookSpecificOutput` | Action |
|------|-----------|-----------------------------------------------------|--------|
| `.tad/hooks/startup-health.sh` | SessionStart | Injects TAD status summary into every new session via `additionalContext` | **DO NOT MODIFY** |
| `.tad/hooks/lib/common.sh` | shared library | `output_response()` function generates the JSON envelope used by both SessionStart and PostToolUse hooks | **DO NOT MODIFY** |
| `.tad/hooks/post-write-sync.sh` | PostToolUse | Calls `output_response "PostToolUse" "..."` to remind agent after file writes | **DO NOT MODIFY** |
| `.claude/skills/alex/SKILL.md` lines 561 / 570 / 1541 | (documentation) | References to **SessionStart additionalContext** as Domain Pack catalog source — NOT UserPromptSubmit | **DO NOT MODIFY these references**. FR4 BUSINESS-VALUE-FIRST insertion is at line ~2053, separate location |
| `.claude/skills/blake/SKILL.md` (no current refs but BA P0-1 caveat) | (potential future) | If Blake SKILL gets SessionStart references in future, same exclusion applies | FR5 BUSINESS-VALUE-FIRST insertion is at step8_generate_message, line ~1080-1140, separate location |

**Why this matters**: a naive "remove all `additionalContext` references" sweep would break SessionStart pack catalog injection (which agents depend on for Domain Pack awareness) AND PostToolUse hook reminders (which agents see after every Write). Blake must NOT touch these 4 files except for the SKILL FR4/FR5 insertion at the documented anchor lines.

### 10.6 NFR3 Ongoing Symmetry Enforcement (P1-E from BA review)

The byte-symmetry between Alex SKILL FR4 and Blake SKILL FR5 BUSINESS-VALUE-FIRST RULE is verified at delivery time via AC10. **There is no ongoing enforcement** — 6 months from now someone might update Alex's version and forget Blake's, causing silent drift.

**Recommendation for next release**: Add a `release-runbook` smoke test step (Phase 7 verify) that runs the AC10 diff at every `*publish` time. This is a **P1 follow-up** and **NOT in this handoff's scope** — but Blake should add a `// TODO release-runbook smoke test for byte-symmetry` comment near the FR4 / FR5 insertion sites so the future maintainer has a breadcrumb. Track in NEXT.md as a Pending item under "v2.9.0 release-runbook enhancements" pile.

### 10.7 ≥28/30 PASS Baseline Documentation (P1-F from BA review)

**Why ≥28/30 not 30/30**: The original test set was hand-curated 2026-04-07 with the exact pack/keyword DB at that snapshot. Subsequent Phase 4 (2026-04-25 commits d2a73a1 + 93fcb50) modified Domain Pack content / added keywords / changed quality_criteria. **Current baseline (Blake should measure pre-fix)**: run `bash .tad/hooks/run-phase2b-tests.sh` BEFORE editing any file → record current PASS/FAIL count. The post-fix run should be ≥ pre-fix count (no regression introduced by the migration alone). If pre-fix shows < 28/30 already, that's a separate issue from this handoff and should be flagged but not block this fix.

**Acceptance**: post-fix PASS count ≥ pre-fix PASS count (regression check), AND post-fix PASS count ≥ 28/30 (absolute floor). If either condition fails → Blake escalate.

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Process depth | Standard TAD / *express override / 拆 2 个 *express | Standard TAD light | User explicit choice 2026-04-27 (option A) |
| 2 | Socratic 是否重新跑 | 跑 / 引用 *discuss | 引用 *discuss | 已经在 cleanup handoff 之后 *discuss 过完整 6 维度（价值/边界/风险/AC/场景/技术约束）|
| 3 | 数据源迁移 | Path A (read .router.log) / Path B (TAD_DOMAIN_ROUTER_TEST_EMIT env hack) / Path C (defer) | **Path A** | Reviewer recommended; preserves passive design; .router.log 已是 source of truth |
| 4 | run-phase2b PASS 阈值 | 30/30 / ≥28/30 / 任意 | ≥28/30 | keyword DB drift 不可避免，强求 30/30 是 over-spec |
| 5 | AC-P1.4 `_assert_skip` 是否动 | 动 / 不动 | 不动 | passive 后 stdout 已自动 empty，`_assert_skip` 行为正确无需改 |
| 6 | Alex/Blake SKILL 是否字字对称 | 必须对称 / 各自表述 | **必须对称** | 历史漂移风险来源——一处 prose 改了另一处忘了 |
| 7 | AC13 fresh grep 是否强制 | 强制 / 建议 | **强制** | dogfood Cleanup Scope-Estimation Drift Pattern 教训；非 ceremonial |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-27
**Version**: 3.1.0
