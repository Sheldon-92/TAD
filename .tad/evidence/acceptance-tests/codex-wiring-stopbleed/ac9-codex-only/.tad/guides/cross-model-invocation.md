# Cross-Model Invocation Guide

> Validated against: Codex CLI v0.125.0, Gemini CLI v0.39.1 (spike 2026-05-03)
>
> Architecture.md references: `codex exec --full-auto VALIDATED in Phase 2 Dogfood`,
> `Codex stderr failed to record rollout items is Benign`,
> `codex exec review --commit Incompatible with --full-auto [PROMPT]`,
> `codex exec --skip-git-repo-check Required for Non-Git Project Directories`,
> `Gemini CLI: -p Flag Required for Non-TTY / Sub-Agent Invocation`,
> `Gemini CLI -p Mode is Read-Only`,
> `Gemini Regex Output Requires BSD grep-E Validation`

---

## Codex CLI

### 基本调用

```bash
# 主调用模式（VALIDATED — Phase 2 dogfood confirmed）
codex exec --full-auto "prompt text"

# 通过 stdin 注入上下文（推荐：比 --full-auto + 位置参数更可靠）
{ echo "instructions:"; cat /path/to/file.txt; } \
  | codex exec --full-auto "follow the instructions above"

# 非 git 目录必须加此 flag
codex exec --skip-git-repo-check --full-auto "prompt"
```

### 场景模板

**Code Review（来自 diff）：**
```bash
git diff HEAD~1..HEAD > /tmp/tad-review-diff.txt
{ echo "Review this diff for bugs and quality:"; echo ""; cat /tmp/tad-review-diff.txt; } \
  | codex exec --full-auto "Provide structured code review with P0/P1/P2 findings"
```

**SKILL 注入 + 任务：**
```bash
cat .claude/skills/blake/SKILL.md \
  | codex exec --full-auto "You are Blake. Analyze the handoff at .tad/active/handoffs/HANDOFF-*.md and list implementation steps"
```

### Flag 参考

| Flag | 作用 |
|------|------|
| `--full-auto` | 非交互执行（必须用于 Bash tool 调用） |
| `--skip-git-repo-check` | 非 git 目录时必加 |
| `-m "model-name"` | 指定模型版本 |

> ⚠️ `--settings` 和 `--permission-mode` 是 **Claude Code (`claude -p`)** 的 flag，不是 `codex exec` 的 flag。两者不可混用。

### 已知坑

- **`--commit` 与 `--full-auto [PROMPT]` 不兼容**：用 stdin 方案替代  
  ❌ `codex exec review --commit abc123 --full-auto "review"`  
  ✅ `{ echo "review:"; cat diff.txt; } | codex exec --full-auto "review"`

- **stderr 噪音是良性的**：`failed to record rollout items` 是内部 bookkeeping log，  
  不是错误。**用 exit code 判断成功，不用 stderr 缺失。**

- **Sandbox = workspace-write**：可以读 + 写 + 执行（workdir + /tmp + ~/.codex/memories）

- **Exit code 是唯一真相**：`if [ $? -eq 0 ]; then ...`，不要 grep stderr

---

## Gemini CLI

### 基本调用

```bash
# 主调用模式（-p 在非 TTY 环境 MANDATORY）
gemini -p "prompt text"

# 指定模型
gemini -m "gemini-2.5-pro" -p "prompt"

# stdin 注入
echo "analyze this:" | gemini -p "respond to the analysis request from stdin"
```

### 场景模板

**结构化研究/分析：**
```bash
gemini -p "Research [topic]. Output a structured report with: 1) key findings 2) tool recommendations 3) gotchas. Use POSIX ERE compatible with BSD grep -E for any regex examples."
```

**代码分析（只读）：**
```bash
cat /path/to/file.py | gemini -p "Analyze this code for security vulnerabilities. Output structured findings."
```

### 限制（重要）

| 能力 | 可用？ |
|------|--------|
| grep_search（读文件搜索） | ✅ |
| read_file（读文件） | ✅ |
| glob（文件列表） | ✅ |
| write_file | ❌ 不可用 |
| run_shell_command | ❌ 不可用 |
| invoke_agent | ❌ 不可用 |

**Gemini 是只读工具。** 适合研究/分析/报告，不能写文件或执行命令。

### 已知坑

- **不加 `-p` 会永远 hang**：Bash tool 调用必须加 `-p`
- **正则输出是 PCRE 风格**：Gemini 生成的 regex 可能含 `(?!...)` 负向前瞻，  
  macOS BSD `grep -E` 不支持。用于 hook 前必须用 `echo "test" | grep -E 'PATTERN'` 验证
- **`-p` 模式不能创建文件**：任务结果只能通过 stdout 获取

---

## Preflight & Fallback

### 可用性检测（POSIX 标准）

> **PATH 注意**：`command -v` 只检测 PATH 上的工具。Codex/Gemini 均通过 Homebrew 安装
> (`/opt/homebrew/bin/`)，在 Claude Code Bash tool 的子进程中通常可见。若通过 venv 或自定义
> prefix 安装（如 `~/.cargo/bin`），需改用绝对路径调用。参见 architecture.md
> "Venv Absolute Path for AI-Invoked CLI Tools - 2026-05-03"。

```bash
# 推荐写法（POSIX 标准，比 which 更可靠）
if command -v codex >/dev/null 2>&1; then
  echo "Codex available"
else
  echo "Codex not found"
fi

if command -v gemini >/dev/null 2>&1; then
  echo "Gemini available"
else
  echo "Gemini not found"
fi
```

### 双路径回退逻辑

```
用户明确要求（"用 Codex review"）:
  → 工具存在: 执行调用
  → 工具缺失: 告知用户 "{tool} CLI 未安装，我用自身能力完成。"
              然后用自身能力完成任务

系统建议 / handoff 建议 / Alex 委派:
  → 工具存在: 执行调用
  → 工具缺失: 静默回退 — 用自身能力完成，不报错，不提及工具缺失
```

### 完整 preflight bash 片段

```bash
run_codex_review() {
  local diff_file="$1"
  if command -v codex >/dev/null 2>&1; then
    { echo "Review this diff:"; echo ""; cat "$diff_file"; } \
      | codex exec --full-auto "Provide structured code review with P0/P1/P2 findings"
    return $?
  else
    return 1  # caller decides: tell user or silent fallback
  fi
}
```
