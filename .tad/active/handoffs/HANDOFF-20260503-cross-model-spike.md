---
task_type: research
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff: Spike — Cross-Model Orchestration Feasibility
**From:** Alex | **To:** Blake | **Date:** 2026-05-03
**Type:** Express Spike (skip Socratic, keep ≥1 expert review)
**Priority:** P2
**Time Cap:** 60 minutes hard

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-03

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3 个独立测试，无依赖 |
| Components Specified | ✅ | CLI 路径已验证 (codex, gemini 均在 /opt/homebrew/bin/) |
| Functions Verified | ✅ | 用 Bash tool + Agent tool，无自定义函数 |
| Data Flow Mapped | ✅ | 每个测试独立：输入 prompt → CLI 执行 → 捕获输出 → 判定 |

**Gate 2 结果**: ✅ PASS
**Alex确认**: Blake 可以独立根据本文档完成 spike。

---

## 1. Task Overview

**目标**：验证 Claude Code session 内通过 sub-agent 调用 Codex CLI 和 Gemini CLI 的可行性，为跨模型编排架构提供 GO/NO-GO 依据。

**背景**：2026-05-03 Alex *discuss 研究发现三平台能力互补（Claude=实现, Codex=Review, Gemini=Research）。Codex 路径已在 Codex CLI Adaptation Epic Phase 0 验证过，但 Gemini 路径未验证。统一输出格式和 Fallback 机制也未测试。

**参考 Idea**：`.tad/active/ideas/IDEA-20260503-cross-model-orchestration.md`

---

## 2. Spike Tests (3 个独立测试)

### Test 1: Gemini CLI 子 Agent 可达性

**目的**：验证 Gemini CLI 能否在 Claude Code 的子 terminal (Agent tool / Bash tool) 里正常运行并返回有意义的输出。

**执行方法**：
```bash
gemini -p "List 3 advantages of TypeScript over JavaScript. Output as a numbered list, nothing else."
```

⚠️ Gemini CLI 默认是交互模式，必须用 `-p` flag 才能在非 TTY 环境（sub-agent/Bash tool）下运行。
如果遇到 workspace trust 提示，加 `--skip-trust` flag。

**判定标准**：
- exit code = 0
- stdout 包含 ≥3 条带编号的条目
- 无 auth error / quota error

**如果失败**：检查 `gemini auth status`，记录错误信息。尝试加 `--skip-trust`。

### Test 2: 统一输出格式 — Codex 和 Gemini 使用同一 Review Prompt

**目的**：验证两个平台是否能按同一个 prompt 模板输出结构化 review 结果。

**Review Prompt 模板**（给两个平台用完全相同的 prompt）：
```
Review the following code for bugs, security issues, and code quality.
Output your findings in EXACTLY this markdown table format, nothing else:

## Findings
| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|

If no issues found, output the table with one row: | 1 | Info | No issues found | N/A |

## Summary
- P0 (must fix): {count}
- P1 (should fix): {count}
- P2 (nice to have): {count}

Code to review:
\`\`\`python
def login(username, password):
    query = f"SELECT * FROM users WHERE name='{username}' AND pass='{password}'"
    result = db.execute(query)
    if result:
        token = base64.b64encode(f"{username}:{password}".encode()).decode()
        return {"token": token, "expires": "never"}
    return None
\`\`\`
```

**执行方法**：
```bash
# Codex review (stdin 作为完整 prompt，用 - 表示从 stdin 读取)
echo '<上面的 prompt>' | codex exec --full-auto -

# Gemini review (必须用 -p flag，stdin 内容通过 -p 附加)
echo '<上面的 prompt>' | gemini -p "respond to the review request from stdin"
```

⚠️ Codex 如果报 "Not inside a trusted directory"，加 `--skip-git-repo-check`。
⚠️ Gemini 如果报 workspace trust 提示，加 `--skip-trust`。

**判定标准**：
- 两者都返回 markdown 表格格式
- 两者都能识别 SQL injection 漏洞（P0 级）
- 两者都能识别 token 安全问题（明文密码编码）
- 输出结构可被 grep/awk 解析（不需要人工整理）

### Test 3: Fallback 错误检测

**目的**：验证当 CLI 调用失败时，Blake 能否通过 exit code 和 stderr 检测到失败并执行降级。

**执行方法**：
```bash
# Codex 错误触发：用不存在的模型名
codex exec --full-auto --model "nonexistent-model-xyz" "say hello" 2>&1; echo "EXIT_CODE=$?"

# Gemini 错误触发：用不存在的模型名（与 Codex 对称）
gemini -p "test" -m "nonexistent-model-xyz" 2>&1; echo "EXIT_CODE=$?"

# 备选方法（如果上面的方法不触发有意义错误）：
# HOME=/tmp/gemini-no-auth gemini -p "test" 2>&1; echo "EXIT_CODE=$?"
```

**判定标准**：
- 失败时 exit code ≠ 0
- stderr 或 stdout 包含可识别的错误关键词（rate limit / error / invalid / unauthorized 等）
- Blake 能基于这些信号做条件判断（if/then in bash）

**如果错误信号不可预测**：记录实际的错误输出格式，在 SPIKE-REPORT 中标注需要针对每个平台定制错误检测逻辑。

---

## 6. Files to Create

| File | Purpose |
|------|---------|
| `.tad/evidence/spikes/SPIKE-20260503-cross-model-orchestration/SPIKE-REPORT.md` | 三测试结果 + GO/NO-GO 判定 |

**Grounded Against** (Alex step1c):
- /opt/homebrew/bin/codex (verified exists)
- /opt/homebrew/bin/gemini (verified exists)
- No existing target files to modify (spike creates new evidence only)

---

## 9. Acceptance Criteria

| AC# | Criteria | Verification |
|-----|----------|-------------|
| AC1 | Gemini CLI 在子 terminal 返回有意义输出 (exit 0) | SPIKE-REPORT Test 1 结果 |
| AC2 | Codex 和 Gemini 均按表格模板返回结构化 review | SPIKE-REPORT Test 2 结果 |
| AC3 | 两者均识别 SQL injection (P0) | SPIKE-REPORT Test 2 findings |
| AC4 | CLI 失败时 exit code ≠ 0 可被 bash 捕获 | SPIKE-REPORT Test 3 结果 + `grep -cE "EXIT_CODE=[1-9][0-9]*"` |
| AC5 | SPIKE-REPORT.md 含 3 测试结果 + 综合 GO/NO-GO 判定 | `test -f` + 内容检查 |

**综合判定规则**：
- 3/3 PASS = **GO** (可设计完整架构)
- 2/3 PASS = **PARTIAL-GO** (需调整后可行)
- 1/3 或更少 = **NO-GO** (需重新评估方向)

---

## 9.1 Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|-----|--------------------|--------------------|-------------------------------|
| AC1 | `grep -c "exit.*0\|PASS" SPIKE-REPORT.md` | ≥1 | (post-impl — Blake runs) |
| AC2 | `grep -c "Severity\|Issue\|Suggestion" SPIKE-REPORT.md` | ≥2 (both platforms) | (post-impl — Blake runs) |
| AC3 | `grep -ci "sql injection\|injection" SPIKE-REPORT.md` | ≥2 | (post-impl — Blake runs) |
| AC4 | `grep -cE "EXIT_CODE=[1-9][0-9]*" SPIKE-REPORT.md` | ≥1 | (post-impl — Blake runs) |
| AC5 | `test -f .tad/evidence/spikes/SPIKE-20260503-cross-model-orchestration/SPIKE-REPORT.md` | exists | (post-impl — Blake runs) |

**AC Dry-Run Log** (Alex step1d at 2026-05-03):
- AC1-AC5: ✅ all post-impl-verifiable (spike creates new file), syntax-validated (grep patterns are standard)

---

## 9.2 Expert Review

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: Gemini CLI 需要 `-p` flag 否则挂起 | §2 Test 1/2/3 所有 gemini 命令已加 `-p` | Resolved |
| code-reviewer | P0-2: Codex stdin 模式应用 `-` 直接读取 | §2 Test 2 Codex 命令改为 `codex exec --full-auto -` | Resolved |
| code-reviewer | P1-1: Gemini 错误触发用 API key 不可靠 | §2 Test 3 改为 `-m "nonexistent-model-xyz"` | Resolved |
| code-reviewer | P1-2: Gemini 可能需要 `--skip-trust` | §2 Test 1/2 已加 fallback 提示 | Resolved |
| code-reviewer | P1-3: AC4 regex 不够健壮 | §9 + §9.1 AC4 改为 `grep -cE "EXIT_CODE=[1-9][0-9]*"` | Resolved |
| code-reviewer | P1-4: Codex 可能需要 `--skip-git-repo-check` | §2 Test 2 已加 fallback 提示 | Resolved |

---

## 10. Important Notes

### 10.1 Time Cap
- **60 分钟硬上限**。如果某个测试卡住 > 15 分钟，标记该测试为 FAIL 并继续下一个。
- 不要花时间调优 prompt — 记录原始输出即可，调优是后续工作。

### 10.2 不要修改 TAD 框架代码
- 这是纯 spike，不改 SKILL / config / hooks

### 10.3 错误记录优先于成功
- 如果测试失败，详细记录错误信息（完整 stderr）比解决问题更重要。
- Spike 的价值在于信息收集，不在于问题修复。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Codex CLI TAD Feasibility (architecture.md)**: `codex exec --full-auto` 已验证可工作，ChatGPT 账户沙箱是 workspace-write 权限
- **`codex exec --full-auto` VALIDATED (architecture.md)**: 用 `echo "prompt" | codex exec --full-auto "instruction"` 模式
- **`codex exec --skip-git-repo-check` Required (architecture.md)**: 非 git 目录需要此 flag

### Required Evidence Manifest
```yaml
spike_report: ".tad/evidence/spikes/SPIKE-20260503-cross-model-orchestration/SPIKE-REPORT.md"
completion: ".tad/active/handoffs/COMPLETION-20260503-cross-model-spike.md"
```
