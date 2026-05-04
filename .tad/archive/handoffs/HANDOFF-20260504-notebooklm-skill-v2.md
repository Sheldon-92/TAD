---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-notebook"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: *research-notebook SKILL v2 — Full CLI Capability Expansion

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-04
**Project:** TAD
**Task ID:** TASK-20260504-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260504-notebooklm-research-director.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-04 (pending expert review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Commands defined, workflow clear |
| Components Specified | ✅ | 7 new commands + 2 fixes, all with step-by-step protocol |
| Functions Verified | ✅ | All CLI commands verified via --help + live test in spike/Gate 4 |
| Data Flow Mapped | ✅ | generate report → download → local .md → optionally source add back |

**Gate 2 结果**: ✅ PASS (2 experts, 6 P0 resolved, 4 P1 integrated)

**Alex确认**: Expert review 完成，所有 P0 已修复。Blake 可以独立根据本文档完成实现。

---

## 1. Task Overview

### 1.1 背景
Phase 0 spike 验证了 NotebookLM CLI 0.3.4 的 13 个命令。Gate 4 额外发现 `download report` 命令可以直接将 report 导出为 markdown (2s)，解决了 spike 认为的 "content not CLI-accessible" 问题。

### 1.2 目标
扩展 *research-notebook SKILL 从 8 个命令到 ~15 个命令，覆盖完整的 research lifecycle：
- **发现源** (source add-research)
- **理解源** (source guide, summary --topics)
- **配置研究角色** (configure --persona/--mode)
- **产出报告** (generate report + download report)
- **知识回流** (source add with local .md → 验证 ask 能引用)
- **修复回归** (setup-notebooklm.sh 0.1.1 → 0.3.4)

### 1.3 非目标
- 不改 Alex SKILL.md (Phase 2)
- 不改 Blake SKILL.md (Phase 3)
- 不实现 `generate audio/video` (未在 spike 验证)
- 不实现 `artifact export` to Google Docs (需要额外 auth)

---

## 2. Requirements

### 2.1 修复 (2 项)

**F1: setup-notebooklm.sh version pin**
- 文件: `.tad/cross-model/setup-notebooklm.sh`
- 当前 line 39-40: `pip install -q "notebooklm-py[browser]==0.1.1"`
- 改为: `pip install -q "notebooklm-py[browser]==0.3.4"`
- 原因: 0.1.1 API endpoints deprecated server-side (architecture.md entry)

**F2: SKILL preflight version check**
- 在 SKILL.md preflight section 添加版本检查:
  ```
  - "Version check: notebooklm --version | grep -qE '0\.[3-9]\.[0-9]' (minimum 0.3.4)"
  ```
- on_fail 信息包含: "notebooklm-py < 0.3.4 — re-run: bash .tad/cross-model/setup-notebooklm.sh"

### 2.2 新命令 (7 项)

**C1: `*research-notebook research <topic> [--mode fast|deep]`**
合并 source add-research + summary 为一个高级命令：
```
Step 0: Resolve target notebook (same as existing ask command)
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook
  → If no active notebook → AskUserQuestion: "Which notebook?" or "Create new"

Step 1: Mode selection
  → If --mode explicitly specified by user:
    - --mode fast → skip AskUserQuestion, proceed directly (cheap, ~1s)
    - --mode deep → AskUserQuestion confirmation:
      "Deep mode 将搜索 50+ 源并永久导入 (~3-4min)。确认？"
      Options: "确认 Deep" / "改用 Fast" / "Cancel"
  → If no mode specified → AskUserQuestion:
    "即将让 NotebookLM 搜索 '{topic}' 并自动导入源。"
    Options: "Fast (10 sources, ~1s)" / "Deep (50+ sources, ~3-4min)" / "Cancel"

Step 2: Execute
  → notebooklm source add-research "{topic}" --mode {choice} --import-all -n <id>
  → If --mode deep: use --no-wait, then research wait -n <id>
  → Capture output (source count + titles)
  → ⚠️ ERROR HANDLING:
    - If exit code != 0: Report error to user + EXIT (do NOT proceed to Step 3)
    - If source_count == 0: "⚠️ No sources found for '{topic}'. Try broader keywords." + EXIT
    - If deep mode + research wait > 300s: "⚠️ Deep research timed out. Sources may be partially imported. Check: *research-notebook list" + EXIT

Step 3: Summary
  → notebooklm summary --topics -n <id>
  → Display: "✅ {N} sources added. Notebook summary: {summary}"
  → Display: "Suggested topics to explore: {topics}"

Step 4: Post-research source review (deep mode only)
  → If --mode deep AND source_count > 20:
    → notebooklm source list -n <id> (show full list)
    → AskUserQuestion: "Deep research 添加了 {N} 个源。要现在清理不相关的源吗？"
      Options:
        - "查看并清理" → display source titles, user picks which to delete
          → For each selected: notebooklm source delete <id> -n <id> --yes
        - "全部保留" → continue
        - "稍后用 *research-notebook curate 清理" → continue
  → If --mode fast: skip (10 sources, low cleanup urgency)

Step 5: Update REGISTRY
  → Update source_count (after any deletions), last_queried, status=active
```

**C2: `*research-notebook report <description>`**
Generate + download a structured report as local markdown:
```
Step 0: Resolve target notebook (same as existing ask)

Step 1: Validate download capability (first-time only)
  → notebooklm download report --dry-run -n <id>
  → If exit 0 + lists artifacts → download works, proceed
  → If error → "⚠️ download report not available. Report visible in NotebookLM web UI only." + EXIT
  → Cache result: skip this check on subsequent C2 calls in same session

Step 2: Generate
  → notebooklm generate report "{description}" -n <id> --wait
  → Display: "Generating report... (typically 30-90s)"
  → If exit code != 0: "❌ Report generation failed: {stderr}" + EXIT

Step 3: Download with retry
  → notebooklm download report --latest -n <id> "{output_path}"
  → output_path: .tad/evidence/research/{notebook_topic}/{date}-{slug}.md
    (mkdir -p the directory if missing)
  → If download returns empty or error:
    → Retry up to 3 times with 10s interval
    → If still fails: "⚠️ Report generated but download failed. View in NotebookLM web UI."

Step 4: Display
  → Read first 20 lines of downloaded file
  → Output: "✅ Report saved: {path} ({line_count} lines, {word_count} words)"
```

**C3: `*research-notebook guide [--source <id>]`**
Per-source AI summary:
```
Step 1: If no --source specified:
  → notebooklm source list -n <id>
  → AskUserQuestion: select which source(s) to summarize

Step 2: For each selected source:
  → notebooklm source guide <source_id> -n <id> --json
  → Parse JSON: {summary, keywords[]}

Step 3: Display formatted summary + keywords
```

**C4: `*research-notebook configure [--persona <text>] [--mode <mode>]`**
Set notebook research persona:
```
Step 1: If no flags → show current config + AskUserQuestion for what to change
  Options: "Set custom persona", "Use mode (learning-guide/concise/detailed)", "Reset to default"

Step 2: Execute
  → notebooklm configure --persona "{text}" --mode {mode} -n <id>

Step 3: Confirm
  → "✅ Notebook configured. Persona: {first 50 chars}... | Mode: {mode}"

Note: persona up to 10,000 chars. Useful for domain-specific framing.
```

**C5: `*research-notebook topics`**
Quick notebook overview + suggested query topics (display-only, no interaction):
```
Step 0: Resolve target notebook (same as existing ask)
Step 1: notebooklm summary --topics -n <id>
Step 2: Display summary + topic list
  → Output formatted summary + numbered topic list
  → No AskUserQuestion — user invokes `ask` themselves if they want to query
  → Return to standby
```

**C6: `*research-notebook ingest <file_path>`**
Knowledge feedback loop — add local research findings back to notebook as source:
```
Step 0: Resolve target notebook (same as existing ask)

Step 1: Validate file exists + is .md or .txt + file size < 500KB

Step 2: AskUserQuestion confirmation
  → "将 {filename} 的内容作为新 source 加入 notebook '{topic}'。确认？"
  → Options: "确认" / "取消"

Step 3: Execute
  → notebooklm source add "{file_path}" -n <id>
  → ⚠️ This is the knowledge loop validation (T9 showed notes don't work, but source add might)
  → If exit code != 0: Report error + EXIT

Step 4: Verify with exponential backoff (critical — hypothesis test)
  → Attempt 1 (wait 10s): notebooklm ask "summarize the content from {filename}" -n <id> -c 00000000-0000-0000-0000-000000000000
  → If answer references file content → KNOWLEDGE LOOP CONFIRMED → Step 5
  → Attempt 2 (wait 20s): retry same ask
  → Attempt 3 (wait 30s): retry same ask
  → If all 3 attempts say "I don't have that info" → KNOWLEDGE LOOP FAILED
  → Output: "⚠️ source add 本地文件未进入 ask 上下文。知识回流路径不可用。"

Step 5: Update REGISTRY (increment source_count, add source entry)
Step 6: Output result + verdict (GO or NO-GO clearly stated)
```

**C7: Enhance existing `*research-notebook curate` — add content-staleness check**
Merge content-staleness detection INTO existing curate command (not a new command):
```
Add to curate's existing flow, after the age-based staleness check:

Step 2b (NEW): Content-staleness check (CLI-based)
  → For each URL-type source (max 20 to avoid slowness):
    → notebooklm source stale <source_id> -n <id>
    → ⚠️ INVERTED exit codes (shell `if` compatible):
      exit 0 = stale (content changed at source URL)
      exit 1 = fresh (no change)
  → Display alongside existing age-based staleness:
    | Source | Age-Stale | Content-Stale | Action |
    | {title} | 🟢/🔴 (>90 days) | 🟢/🔴 (CLI check) | — / "Refresh?" |

Step 2c (NEW): If content-stale sources found:
  → AskUserQuestion: "Found {N} content-stale sources. Refresh?"
  → If yes: notebooklm source refresh <source_id> -n <id> for each
```

### 2.3 Stale Conversation Workaround (cross-cutting)
All `ask` commands in SKILL must implement two-layer fallback:
```
Layer 1: Normal ask (no -c flag)
  → If timeout (exit 1 + stderr contains "timeout" or >30s):
Layer 2: Retry with -c 00000000-0000-0000-0000-000000000000
  → If still fails: report error to user
```
Apply to: existing `*research-notebook ask` + new C5 topics + C6 feedback verify step.

### 2.4 capabilities.yaml update
Update `notebooklm_research` entry in `.tad/cross-model/capabilities.yaml`:
- cli_command: add `download report`, `source add-research`
- Add new sub-capabilities for report generation + research mode

---

## 3. Files to Modify

| # | File | Action | Scope |
|---|------|--------|-------|
| 1 | `.tad/cross-model/setup-notebooklm.sh` | Edit line 39-40 | 0.1.1 → 0.3.4 |
| 2 | `.claude/skills/research-notebook/SKILL.md` | Major edit | Add 7 commands, version preflight, stale conversation fallback |
| 3 | `.tad/cross-model/capabilities.yaml` | Edit | Update notebooklm_research entry |

**Grounded Against** (Alex step1c):
- .claude/skills/research-notebook/SKILL.md (329 lines, read at 2026-05-04)
- .tad/cross-model/setup-notebooklm.sh (line 39-40 pinning 0.1.1, verified)
- .tad/cross-model/capabilities.yaml (head 50, read at 2026-05-04)
- NotebookLM CLI download report (live-tested in Gate 4: 2s, perfect markdown output)

---

## 4. Acceptance Criteria

- [ ] AC1: setup-notebooklm.sh pins 0.3.4 (grep -q "0.3.4" setup-notebooklm.sh)
- [ ] AC2: SKILL.md has version preflight check referencing minimum 0.3.4
- [ ] AC3: SKILL.md contains 6 new command sections (C1: research, C2: report, C3: guide, C4: configure, C5: topics, C6: ingest) + C7 curate enhancement
- [ ] AC4: C1 `research` has notebook resolution (Step 0) + conditional AskUserQuestion (deep=confirm, fast explicit=skip)
- [ ] AC5: C2 `report` validates `download report` first (Step 1), does generate + download + saves .md locally
- [ ] AC6: C6 `ingest` tests source-add-as-knowledge-loop hypothesis with 3-attempt exponential backoff verification
- [ ] AC7: Stale conversation fallback (-c 00000000...) applied to all ask-using commands (existing ask + C5 verification calls + C6 verify step)
- [ ] AC8: capabilities.yaml `notebooklm_research` entry updated with new command references
- [ ] AC9: All notebooklm CLI invocations use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
- [ ] AC10: C6 `ingest` documents in completion report whether knowledge loop works (GO or NO-GO)
- [ ] AC11: C1 `research` has explicit error handling (exit!=0, 0 sources, timeout) with user-facing messages
- [ ] AC12: C2 `report` Step 1 validates `download report --dry-run` works BEFORE implementing full pipeline (if fails → C2 degrades to "report in web UI only" with clear message)

---

## 5. Important Notes

### 5.1 不要改变现有命令的行为
现有的 8 个命令 (create, add, ask, list, sync, curate, archive, use) 保持不变。新命令是增量添加。

### 5.2 Sub-Agent 使用建议
- code-reviewer: 审查 SKILL.md 协议一致性 + setup-notebooklm.sh 变更安全性
- backend-architect: 审查命令设计的 UX 连贯性 + error handling

### 5.3 关于 C6 (knowledge feedback)
这是一个验证性实现 — 我们不确定 `source add` 本地文件是否能让 `ask` 引用其内容。Blake 需要：
1. 实现 C6 命令
2. 实际测试：创建一个测试 .md → source add → ask → 验证是否引用
3. 在 completion report 记录结果（GO 或 NO-GO）
4. 如果 NO-GO：在 SKILL.md 的 C6 command 中标注 "⚠️ Knowledge loop NOT verified — source add local file does not participate in ask context"

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| 教训 | 来源 | 为什么相关 |
|------|------|-----------|
| notebooklm-py 0.1.1 Deprecated — Minimum 0.3.4 | architecture.md (2026-05-04) | F1 修复依据 |
| NotebookLM CLI Capability Matrix | architecture.md (2026-05-04) | 全部命令行为参考 |
| Knowledge Feedback Loop Requires source add, Not note create | architecture.md (2026-05-04) | C6 设计依据 |
| Venv Absolute Path for AI-Invoked CLI Tools | architecture.md (2026-05-03) | AC9 — 绝对路径 |

---

## 9. Spec Compliance Checklist

### 9.1 Verification (INTENT-based per known AC drift pattern)

All ACs are post-impl-verifiable. Verification is presence-based (section/content exists in file) not fragile regex.

### 9.2 Expert Review (Audit Trail)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | CR-P0-1: `download report` evidence gap — architecture.md contradicts | §4 AC12 + C2 Step 1 dry-run validation | Resolved |
| code-reviewer | CR-P0-2: C1 missing error handling (0 sources, exit!=0, timeout) | §2.2 C1 Step 2 error handling block | Resolved |
| code-reviewer | CR-P0-3: C2 generate/download race condition | §2.2 C2 Step 3 retry with 3×10s | Resolved |
| backend-architect | BA-P0-1: C7 `stale` overlaps with existing `curate` | §2.2 C7 merged INTO curate as Step 2b/2c | Resolved |
| backend-architect | BA-P0-2: `feedback` name semantically wrong | §2.2 C6 renamed to `ingest` | Resolved |
| backend-architect | BA-P0-3: C1 missing notebook resolution | §2.2 C1 Step 0 added | Resolved |
| code-reviewer | CR-P1-5: Stale conversation fallback ambiguous | §2.3 clarified (exit!=0 AND stderr timeout/stale) | Resolved |
| backend-architect | BA-P1-1: Report output path needs single default | §2.2 C2 Step 3 → .tad/evidence/research/ only | Resolved |
| backend-architect | BA-P1-2: C5 `topics` should be display-only | §2.2 C5 removed AskUserQuestion | Resolved |
| backend-architect | BA-P1-3: C1 AskUserQuestion overkill for fast mode | §2.2 C1 Step 1 conditional (fast explicit=skip) | Resolved |
| user-feedback | Deep mode 加了 64 源后能否清理不相关的？ | §2.2 C1 Step 4 post-research source review + delete | Resolved |

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | generate report in Phase 1? | Defer / Include | Include | Gate 4 discovered `download report` (2s markdown) — full pipeline works |
| 2 | note create in Phase 1? | Include / Drop | Drop | T9 CONCLUSIVE NEGATIVE — notes don't participate in ask |
| 3 | knowledge loop mechanism? | note create / source add / defer | source add (验证) | architecture.md entry recommends source add path |
| 4 | Naming: high-level research command | `research` / `deep-search` / `discover` | `research` | 与用户讨论一致："让 NotebookLM 做研究" |
