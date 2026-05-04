---
task_type: research
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "T9 knowledge loop design"
    alex_said: "note create enables knowledge feedback loop — findings written back to notebook participate in future ask context"
    actual: "T9 CONCLUSIVE NEGATIVE — notes are annotations only, NOT in ask context. Alternative path: source add with local .md file"
    caught_by: "Blake spike T9 empirical test"
  - field: "§5.1 Auth prerequisite"
    alex_said: "notebooklm list will confirm auth valid, then proceed with all tests"
    actual: "0.1.1 version (pinned in setup-notebooklm.sh) has broken AI endpoints — auth was valid but API calls failed. Required 0.3.4 upgrade."
    caught_by: "Blake spike T1 first-run failure"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-04
**Project:** TAD
**Task ID:** TASK-20260504-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260504-notebooklm-research-director.md (Phase 0/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-04

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Spike — test matrix is the architecture (13 test cases) |
| Components Specified | ✅ | 13 test cases clearly defined with commands + expected output |
| Functions Verified | ✅ | CLI --help confirmed all commands exist (subcommand --help验证) |
| Data Flow Mapped | ✅ | Test → capture (stdout/stderr/exit/timing) → write spike report |
| Expert Review | ✅ | 2 experts (code-reviewer + backend-architect), 7 P0 resolved, 5 P1 integrated |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Expert review 完成，所有 P0 已修复。Blake 可以独立根据本文档完成验证。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（验证 CLI 能力，不是写代码）
- [ ] 每个 Test Case 的输入和期望输出都清楚
- [ ] 确认可以独立使用本文档完成验证

---

## 1. Task Overview

### 1.1 背景
NotebookLM CLI (notebooklm-py) 有大量我们未使用的能力：`generate report`、`source add-research`、`note create`、`configure --persona`、`summary --topics`、`artifact suggestions/get`、`source guide`。当前 *research-notebook SKILL 只覆盖 ~20% 的 CLI 能力。

### 1.2 目标
在真实 notebook（内容副业项目的现有 notebook）上测试 10 个未验证的 CLI 命令，产出 capability matrix：每个命令的 GO/PARTIAL/NO-GO verdict + 输出格式 + 延迟 + 可用性评估。

### 1.3 非目标
- 不修改任何 SKILL 文件（Phase 1 的工作）
- 不修改 Alex/Blake 行为（Phase 2/3 的工作）
- 不需要写产品代码

---

## 2. Requirements

### Spike 测试矩阵

使用 **内容副业项目** 的现有 notebook 进行测试。推荐 target notebook:
- **True Crime 与恐怖播客** (ID: `c4f2aae5`) — 5 源，有实际查询历史
- **P2 内容品类选择** (ID: `47da593a`) — 8 源，内容丰富

所有 CLI 命令使用绝对路径：`~/.tad-notebooklm-venv/bin/notebooklm`

---

## 3. Test Cases (13 个)

### 通用规则
- 所有命令使用绝对路径：`~/.tad-notebooklm-venv/bin/notebooklm`
- 所有命令通过 `-n <notebook_id>` 指定 notebook（不使用 `use` 设置全局状态，避免测试间污染）
- 延迟测量：用 bash SECONDS 变量（`SECONDS=0; cmd; echo "elapsed: ${SECONDS}s"`），避免 `time` 的 stderr 混入问题
- 输出捕获：`cmd > tN-stdout.txt 2> tN-stderr.txt; echo $? > tN-exit.txt`
- 对于支持 `--json` 的命令，同时测试默认输出和 JSON 输出

### T1: `summary --topics`
```
命令: notebooklm summary --topics -n c4f2aae5
期望: 获得 notebook 摘要 + 建议探索的话题列表
记录: 输出格式（纯文本/JSON/markdown）、长度、话题数量、延迟
```

### T2: `configure --persona` (含重置)
```
步骤 1 - 基线: notebooklm ask "恐怖播客的制作成本和预期收益是多少" -n c4f2aae5
步骤 2 - 设置 persona: notebooklm configure --persona "你是一个内容创业顾问，专注于 AI 生成内容的 ROI 分析和生产可行性评估。回答时给出具体数据和可操作建议。" -n c4f2aae5
步骤 3 - 验证 persona: notebooklm ask "恐怖播客的制作成本和预期收益是多少" -n c4f2aae5
步骤 4 - 测试 mode: notebooklm configure --mode learning-guide --response-length shorter -n c4f2aae5
步骤 5 - 验证 mode: notebooklm ask "恐怖播客的制作成本和预期收益是多少" -n c4f2aae5
步骤 6 - ⚠️ 重置: notebooklm configure --mode default --persona "" -n c4f2aae5
步骤 7 - 验证重置: notebooklm ask "恐怖播客的制作成本和预期收益是多少" -n c4f2aae5 (应恢复步骤 1 风格)
记录: persona 是否生效、mode 是否生效、是否可组合使用、重置是否有效、回答对比
```

### T3: `source add-research --mode fast` (⚠️ 使用一次性 notebook)
```
前置: notebooklm create "Spike Test - Disposable" → 记录 test_notebook_id
命令: notebooklm source add-research "AI generated horror podcast production 2026" --mode fast -n <test_notebook_id>
期望: CLI 自动搜索网页，展示搜索结果，可能自动/手动导入源
记录: 找到多少源、质量评估、是否需要手动确认、延迟、是否有 --import-all 选项
⚠️ 注意: 不使用生产 notebook，避免污染用户数据
```

### T4: `source add-research --mode deep` (⚠️ 使用同一个一次性 notebook)
```
命令: notebooklm source add-research "true crime podcast monetization strategies" --mode deep -n <test_notebook_id> --no-wait
然后: notebooklm research status -n <test_notebook_id>
然后: notebooklm research wait -n <test_notebook_id>
期望: 深度搜索，找到更多更高质量的源
记录: 搜索时长、结果数量、是否支持 --import-all、质量 vs fast 对比
⚠️ 如果 --no-wait 同步完成 (即 deep 搜索未进入异步模式):
   → 记录此为 finding: "research status/wait 可能在 fast 模式下无用"
   → 仍然运行 research status 看返回什么
清理: 测试完成后 notebooklm delete <test_notebook_id> 删除一次性 notebook
```

### T5: `source guide <source_id>`
```
先: notebooklm source list -n c4f2aae5 (获取 source ID 列表)
命令: notebooklm source guide <first_source_id> -n c4f2aae5
也测: notebooklm source guide <first_source_id> -n c4f2aae5 --json
期望: AI 生成的源摘要 + 关键词 + 话题标签
记录: 输出格式、JSON schema 结构、摘要质量、延迟
```

### T6: `generate report --format briefing-doc`
```
命令: notebooklm generate report --format briefing-doc -n c4f2aae5 --wait
期望: 从 notebook 源生成一个结构化简报文档
记录: 生成时长、输出位置（stdout vs artifact）、内容质量、长度
```

### T7: `generate report "custom description"`
```
步骤 1: notebooklm generate report "从我的源中总结：做恐怖播客的最佳生产流程，对比各频道策略，给出具体的工具链推荐" -n c4f2aae5 --wait
步骤 2: notebooklm generate report --format custom "相同描述" -n c4f2aae5 --wait (对照：加 --format custom 是否有区别)
期望: 按自定义描述生成定制报告
记录: 描述是否被遵循、--format custom 与仅 description 的行为差异、质量 vs briefing-doc 对比、延迟
```

### T8: `artifact suggestions` + `artifact get`
```
步骤 1 (独立): notebooklm artifact suggestions -n c4f2aae5 (默认输出)
步骤 2 (独立): notebooklm artifact suggestions -n c4f2aae5 --json (JSON 格式)
步骤 3 (依赖 T6/T7): notebooklm artifact list -n c4f2aae5
步骤 4 (依赖 T6/T7): notebooklm artifact get <artifact_id> -n c4f2aae5
期望: suggestions 独立可用；artifact get 能读回完整报告内容
记录: suggestions 格式/schema、artifact get 输出格式（能否直接保存为 .md）、延迟
⚠️ 如果 T6/T7 都是 NO-GO: 运行 artifact list 检查是否有预存 artifact 可用于 get 测试
```

### T9: `note create` + `note list` + `note get` + `note save`
```
步骤 1: notebooklm note create "从 spike 测试发现：generate report 能力可用" -t "Spike Finding" -n c4f2aae5
步骤 2: notebooklm note list -n c4f2aae5
步骤 3: notebooklm note get <note_id> -n c4f2aae5
步骤 4: notebooklm note save <note_id> "更新内容：确认 note 可被 ask 查询引用" -n c4f2aae5
步骤 5: notebooklm ask "你知道我之前记录的关于 generate report 的发现吗？" -n c4f2aae5
步骤 6 - 清理: notebooklm note delete <note_id> -n c4f2aae5
期望: note CRUD 完整可用、ask 时 notebook 能参考 note 内容
记录: note 是否参与 ask 上下文（知识回流关键验证）、save 更新是否生效
```

### T10: `generate mind-map` + `generate data-table`
```
步骤 1: notebooklm generate mind-map -n c4f2aae5
   → 不加 --wait（该命令不支持此标志）
   → 用 notebooklm artifact poll <id> -n c4f2aae5 轮询，或 notebooklm artifact wait <id> -n c4f2aae5 等待
步骤 2: notebooklm generate data-table "comparison of true crime podcast formats and their production requirements" -n c4f2aae5 --wait
期望: 生成知识图谱 / 结构化数据表
记录: 输出格式、内容质量、是否可导出为文本/markdown、延迟
```

### T11: `source stale` + `source refresh` (bonus)
```
先: notebooklm source list -n c4f2aae5 (获取含 URL 的 source ID)
命令: notebooklm source stale <url_source_id> -n c4f2aae5
记录: exit code (0=stale, 1=fresh 按 --help)、输出内容
如果 stale: notebooklm source refresh <url_source_id> -n c4f2aae5
记录: refresh 行为、延迟、是否改变 source 内容
```

### T12: `generate audio` (bonus — NotebookLM 标志性能力)
```
命令: notebooklm generate audio "deep dive on true crime podcast production strategies" -n c4f2aae5 --wait
期望: 生成播客风格音频概述
记录: 生成时长、artifact 类型、是否可下载 (notebooklm download audio <id>)、质量
```

### T13: `artifact export` (bonus — Google Docs 桥接)
```
前置: 需要 T6/T7/T10 产生了 artifact
命令: notebooklm artifact export <artifact_id> --title "Spike Test Export" --type docs -n c4f2aae5
期望: 导出为 Google Doc，返回 Doc URL
记录: 成功/失败、URL 格式、是否需要额外 Google auth
```

---

## 4. Deliverables

### 4.1 Spike Report
路径: `.tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/SPIKE-REPORT.md`

结构:
```markdown
# NotebookLM CLI Capability Spike Report

## Capability Matrix
| Test | Command | Verdict | Latency | Output Format | Notes |
|------|---------|---------|---------|---------------|-------|
| T1   | summary --topics | GO/PARTIAL/NO-GO | Xs | ... | ... |
| T2   | configure --persona | ... | ... | ... | ... |
| ...  | ... | ... | ... | ... | ... |

## Key Findings
- ...

## Phase 1 Scope Recommendation
Based on spike results, recommend which capabilities to include in *research-notebook SKILL v2.

## Raw Test Outputs
(每个 test case 的原始 stdout/stderr 截取)
```

### 4.2 Evidence Directory
路径: `.tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/`

文件:
- `SPIKE-REPORT.md` — 主报告
- `t1-summary.txt` — T1 原始输出
- `t2-configure.txt` — T2 原始输出（含对照）
- ... (每个 test case 一个文件)
- `COMPLETION-REPORT.md` — Gate 3 完成报告

---

## 5. Implementation Notes

### 5.1 Auth 前置检查
测试前先确认 NotebookLM 认证有效：
```bash
~/.tad-notebooklm-venv/bin/notebooklm list 2>&1 | head -5
```
如果返回 "Not logged in" → 需要用户手动运行 Playwright export 脚本（参考 architecture.md "NotebookLM CLI Auth Path Mismatch"）。

### 5.2 延迟测量
使用 bash SECONDS 变量（避免 `time` 的 stderr 混入问题）：
```bash
SECONDS=0
~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n c4f2aae5
echo "elapsed: ${SECONDS}s"
```

### 5.3 Output 捕获
stdout、stderr、exit code 分别捕获：
```bash
SECONDS=0
~/.tad-notebooklm-venv/bin/notebooklm <cmd> > tN-stdout.txt 2> tN-stderr.txt
echo $? > tN-exit.txt
echo "${SECONDS}s" > tN-timing.txt
```

### 5.4 Verdict 标准 (按命令类别分级)

**Query 类** (summary, ask, source guide, note list/get, artifact suggestions):
- **GO**: 成功 + 延迟 < 60s + 输出可直接使用
- **PARTIAL**: 成功但延迟 60-180s，或需要后处理
- **NO-GO**: 失败或输出不可用

**Generation 类** (generate report/mind-map/data-table/audio, artifact get):
- **GO**: 成功 + 延迟 < 300s + 输出质量可用
- **PARTIAL**: 成功但延迟 300-600s，或质量不足需要人工编辑
- **NO-GO**: 失败或输出完全不可用

**Research 类** (source add-research, research status/wait):
- **GO**: 成功完成 + 找到 ≥3 相关源
- **PARTIAL**: 成功但源质量低，或异步模式不可靠
- **NO-GO**: 命令失败或无法找到任何源

**Config 类** (configure --persona/--mode, note create/save):
- **GO**: 设置生效 + 可验证 + 可重置
- **PARTIAL**: 设置生效但无法重置，或效果不明显
- **NO-GO**: 设置失败或无效果

---

## 6. Files to Create

| # | File | Action | Purpose |
|---|------|--------|---------|
| 1 | `.tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/SPIKE-REPORT.md` | Create | 主报告 (含 Capability Matrix) |
| 2 | `.tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/t1-*.txt` ~ `t13-*.txt` | Create | 每个 test case: stdout/stderr/exit/timing 文件 |
| 3 | `.tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/COMPLETION-REPORT.md` | Create | Gate 3 完成报告 |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- .claude/skills/research-notebook/SKILL.md (head 175, read at 2026-05-04)
- .tad/cross-model/capabilities.yaml (head 50, read at 2026-05-04)
- NotebookLM CLI --help + all subcommand --help (verified via Bash, 2026-05-04)

---

## 7. Acceptance Criteria

- [ ] AC1: T1-T10 全部执行完毕（每个有明确的 GO/PARTIAL/NO-GO verdict）
- [ ] AC2: SPIKE-REPORT.md 包含完整的 Capability Matrix 表格（≥10 行数据行）
- [ ] AC3: 每个已执行 test case 有独立的原始输出文件 (tN-stdout.txt + tN-stderr.txt + tN-exit.txt + tN-timing.txt)
- [ ] AC4: Phase 1 Scope Recommendation 基于实际测试结果（不是假设）
- [ ] AC5: Auth 前置检查通过（或记录了 auth 失败及解决方案）
- [ ] AC6: 延迟数据通过 SECONDS 变量获取（不是估算），每行含具体秒数
- [ ] AC7: T9 的知识回流验证有明确结论（note 内容是否参与 ask 上下文）
- [ ] AC8: T3/T4 source additions 在一次性 notebook 上执行（不污染生产 notebook），spike 结束后一次性 notebook 已删除
- [ ] AC9: T2 persona/mode 测试后已重置为 default（验证重置命令有效）
- [ ] AC10: T11-T13 (bonus) 至少执行 1 个，或在 SPIKE-REPORT.md 明确标注"deferred to Phase 0b"并说明原因

---

## 8. Time Budget

**硬上限**: 3.5 小时
**预期**: 2.5-3 小时
- Query/Config 类 (T1, T2, T5, T9, T11): ~10 min each → ~50 min
- Generation 类 (T6, T7, T10, T12): ~15-20 min each → ~70 min
- Research 类 (T3, T4): ~20-25 min each → ~45 min
- Artifact 类 (T8, T13): ~10-15 min each → ~25 min

**如果 auth 失效**: 立即 STOP。记录最后成功的 test 编号。通知用户修复（需要浏览器交互）。不要尝试自动重新认证。用户修复后从失败的 test 继续。
**如果 mid-spike auth 过期**: 同上 — STOP，不要重试。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| 教训 | 来源 | 为什么相关 |
|------|------|-----------|
| NotebookLM CLI Auth Path Mismatch | architecture.md | CLI auth 可能失效，需要 Playwright export 修复 |
| Venv Absolute Path for AI-Invoked CLI Tools | architecture.md | 必须用 `~/.tad-notebooklm-venv/bin/notebooklm` 绝对路径 |
| NotebookLM as TAD Knowledge Layer: INTEGRATE Verdict | architecture.md | 延迟 23-43s，仅研究场景 |
| Codex stderr `failed to record rollout items` is Benign | architecture.md | 类似：NotebookLM CLI 也可能有 stderr 噪音，用 exit code 判断成功 |
| Spike-Driven Epic De-Risking with Light TAD | architecture.md | Spike 方法论：multi-axis verdict，forward-compatibility |

---

## 9. Spec Compliance Checklist

### 9.1 Spec Compliance

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | Count verdict rows in Capability Matrix table | ≥ 10 data rows with GO/PARTIAL/NO-GO |
| AC2 | SPIKE-REPORT.md has `## Capability Matrix` section | Section present with table |
| AC3 | Evidence dir has per-test files | Each executed test has tN-stdout.txt + tN-exit.txt |
| AC4 | SPIKE-REPORT.md has `## Phase 1 Scope Recommendation` section | Section present with specific GO commands listed |
| AC5 | SPIKE-REPORT.md mentions auth status | "Auth: PASS" or "Auth: FAIL" + resolution |
| AC6 | Each test's timing recorded | tN-timing.txt files contain numeric seconds |
| AC7 | T9 knowledge loop finding documented | SPIKE-REPORT.md T9 row has explicit conclusion |
| AC8 | T3/T4 ran on disposable notebook | SPIKE-REPORT.md mentions "disposable" or "test notebook" for T3/T4 |
| AC9 | T2 persona reset verified | SPIKE-REPORT.md T2 notes contain "reset" confirmation |
| AC10 | Bonus tests addressed | ≥1 of T11/T12/T13 executed OR "deferred" noted |

**AC Dry-Run Log** (Alex step1d):
All ACs are post-impl-verifiable — spike produces new artifacts that don't exist yet.
Verification is INTENT-based (check section/content presence), not fragile grep commands.
This is documented per the known "AC Verification Drift" pattern (architecture.md, 4 phases recurring).

### 9.2 Expert Review (Audit Trail)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | CR-P0-1: T1 uses `&&` chained `use` — leaks session state | §3 通用规则 + T1 改为 `-n` flag | Resolved |
| code-reviewer | CR-P0-2: T10 `mind-map` 不支持 `--wait`; `data-table` 缺 description | §3 T10 已修正命令 | Resolved |
| code-reviewer | CR-P0-3: T4 异步回退指令缺失 | §3 T4 添加 "如果同步完成" 指令 | Resolved |
| code-reviewer | CR-P0-4: 单一 120s 延迟阈值不合理 | §5.4 按命令类别分级 (Query/Gen/Research/Config) | Resolved |
| backend-architect | BA-P0-1: T3/T4 永久加源到生产 notebook | §3 T3/T4 改用一次性 notebook + AC8 | Resolved |
| backend-architect | BA-P0-2: T2 persona 未重置 | §3 T2 添加重置步骤 + AC9 | Resolved |
| backend-architect | BA-P0-3: `time` stderr 混入 | §5.2/5.3 改用 SECONDS + 通用规则 | Resolved |
| code-reviewer | CR-P1-1: 缺少 source stale/refresh/audio/export 测试 | §3 添加 T11/T12/T13 bonus tests + AC10 | Resolved |
| backend-architect | BA-P1-1: 同上 | §3 添加 T11/T12/T13 | Resolved |
| code-reviewer | CR-P1-2: T8 --json 应同时测默认输出 | §3 T8 步骤 1+2 分别测两种格式 | Resolved |
| code-reviewer | CR-P1-3: T2 缺 --mode 和 --response-length 测试 | §3 T2 扩展为 7 步含 mode 测试 | Resolved |
| backend-architect | BA-P1-5: 全局 --json 测试策略 | §3 通用规则 + T5 已加 --json 对照 | Resolved |

---

## 10. Important Notes

### 10.1 不要修改现有 notebook 的源
测试 `source add-research` 时会给 notebook 加源。这是预期行为，但要记录加了什么。如果需要保持 notebook 原始状态，可以在测试后删除新加的源。

### 10.2 测试顺序建议
建议按 T1→T5→T6→T7→T8→T9→T2→T3→T4→T10 顺序执行：
- T1/T5 是只读操作，最安全
- T6/T7/T8 是生成操作，不修改源
- T9 写入 note（可逆）
- T2 修改 persona 配置
- T3/T4 添加源（最具侵入性，放最后）
- T10 额外生成验证

### 10.3 如果命令不存在或报错
记录为 NO-GO，附上完整错误信息。不需要调试或修复 — spike 只需要知道"能不能用"。

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 测试用哪个 notebook | 新建测试用 / 用内容副业现有 | 用现有 (c4f2aae5) | 有真实数据更能反映实际效果 |
| 2 | 测试范围 | 只测 top 3 命令 / 全部 10 个 | 全部 10 个 | Spike 一次做完，避免后续补测 |
