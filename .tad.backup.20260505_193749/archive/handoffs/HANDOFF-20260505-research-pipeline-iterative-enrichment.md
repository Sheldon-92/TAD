# Handoff: Research Pipeline — Iterative Enrichment + Curate Acceleration

---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
git_tracked_dirs:
  - .claude/skills/alex/
  - .claude/skills/research-notebook/
---

**From:** Alex | **To:** Blake | **Date:** 2026-05-05
**Type:** Light TAD
**Priority:** P1

## 1. Executive Summary

Upgrade the TAD 5-Phase research pipeline with two improvements validated by the menu-snap experiment report (`.tad/evidence/research/2026-05-05-research-pipeline-experiment-report.md` — run in menu-snap project, conclusions applicable to TAD framework):

1. **Phase 4 CRAG Judge Loop** — detect source gaps in ask answers, automatically trigger targeted re-research
2. **Phase 2 Parallel Delete** — replace sequential `source delete` + sleep with `xargs -P5` parallel deletion

## 2. Background

### Problem 1: Linear Pipeline Misses Cross-Domain Intersections
Experiment A (iOS Submission, 288 sources): Questions Q1/Q2 about "Capacitor + Next.js" returned "sources do not contain" despite 288 sources. Deep Research was broad but missed this technical intersection. Pipeline currently has no recovery mechanism — it just accepts unsourced answers.

### Problem 2: Phase 2 Curate Takes Too Long
Experiment B (Multi-lang OCR): 80 error sources + 236 duplicates = 316 sequential deletions × 0.3-0.5s sleep = ~5 minutes of user waiting. This is the most painful step experientially.

### Research Backing
NotebookLM notebook `f3d46229-2624-4b14-9f5e-bf0f59447438` ("Autonomous Research Agents") with 15 sources. Three ask rounds identified **Corrective RAG (CRAG)** as the best-fit architecture: Judge Agent detects gaps → targeted enrichment → re-ask. NotebookLM's own "sources do not contain" response is a free Judge signal.

## 3. Requirements

### FR1: Phase 4 Source Gap Detection + Auto-Enrichment (CRAG Judge Loop)

After each Phase 4 `ask` call, scan the answer text (case-insensitive) for gap signals:
- `"sources do not contain"` (exact NotebookLM phrase)
- `"not from your sources"` (variant)
- `"not mentioned in the provided sources"` (variant)

(NOTE: "paragraph with zero citations" heuristic DEFERRED to future iteration — expert review flagged unacceptable false-positive rate on synthesis paragraphs, enumeration headers, and contextual framing. Ship with 3 exact phrases only.)

**Cross-notebook scope** (P0 fix): In cross-notebook mode (Phase 4 Step 2 queries multiple notebooks per question), gap detection runs **per-notebook answer**, not on Alex's synthesized answer. If notebook X returns a gap signal, fast research targets notebook X only. Re-ask targets notebook X only (`-n <notebook_X_id>`). Alex re-synthesizes after all per-notebook enrichments complete.

When gap detected:
1. **Query narrowing**: Extract 2-3 most specific noun phrases from the original question. Construct fast research query as `"{noun_phrase_1} {noun_phrase_2}"` — NOT the full KR question verbatim (avoids reproducing the same broad search that missed the intersection).
2. Auto-run `source add-research "{narrowed query}" --mode fast --import-all -n <target_notebook_id>`
3. Wait for completion. **Zero-source check**: if net new sources after error cleanup = 0, skip re-ask and report: `"⚠️ Fast research found 0 usable sources for Q{N}. Keeping original answer."` → next question.
4. Run lightweight re-curate (error cleanup only — skip dedup + tiering for speed)
5. Re-ask the same question with `-n <target_notebook_id>` flag
6. Report: `"🔄 Gap detected on Q{N}. Added {M} targeted sources. Re-asking..."`
7. **Iteration limit**: `max_reask_per_question: 1` (one re-ask attempt; combined with original ask = 2 total queries per question). After re-ask, if gap signal still present → accept answer as-is + flag `"⚠️ Gap persists after enrichment"`, DO NOT iterate further.
8. **Diminishing returns detection**: count unique citations via `grep -oE '\[[0-9]+\]' | sort -u | wc -l`. If re-ask unique citation count ≤ original ask unique citation count AND gap signal phrases still present → report `"📉 Diminishing returns on Q{N}: citation count unchanged ({count}), gap signal persists. Stopping."` and move to next question.

### FR2: Phase 2 Parallel Delete Acceleration

Replace sequential per-item `source delete` + `sleep 0.5` with a **two-step batch pattern**.

**IMPORTANT**: SKILL.md is an LLM-interpreted protocol, not a shell script. The LLM (Alex/Blake) executes commands via individual Bash tool calls. The parallel delete must be expressed as a single Bash tool call containing the full pipeline.

**Two-step pattern** (the LLM runs each step as one Bash tool call):

Step A — Collect IDs (single Bash call):
```bash
error_ids=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id> | \
  jq -r '.[] | select(.status | test("error")) | .id')
echo "$error_ids"  # display count for report
```

Step B — Parallel delete (single Bash call, safe xargs pattern):
```bash
echo "$error_ids" | xargs -P5 -n1 sh -c '
  ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <notebook_id> --yes 2>&1 | \
    grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
  sleep 0.2
' _
```

**Safety notes** (P0 fixes from expert review):
- Uses `"$1"` positional arg (not bare `{}` inside `sh -c`) to prevent shell injection
- Uses `-n1` instead of `-I{}` for macOS BSD xargs `-P` compatibility
- Stderr NOT swallowed (`2>&1` piped to grep, not `2>/dev/null`) — 429 errors and auth failures are visible
- Post-loop: if any `FAIL:` lines in output → report `"⚠️ {N} deletes failed — consider reducing to -P3 or -P1"`
- The `⚠️ DEFENSIVE` JSON shape check (existing code) stays as a pre-loop gate in Step A

Apply to BOTH locations:
- Alex SKILL.md `research_plan_protocol.step4` Phase 2 — the "For each error source" block and the "For each group with count > 1" block
- research-notebook SKILL.md `curate` — Step 1b and Step 1c

Same two-step pattern in both files. Dedup (Step 1c) uses the same xargs call but with the dedup ID list instead of error IDs.

## 4. Technical Design

### FR1 Implementation — Insert PHASE 4b between Phase 4 Step 2 and Step 3

Current flow:
```
Phase 4 Step 2: ask loop → Step 3: save findings
```

New flow:
```
Phase 4 Step 2: ask loop
  └─ per-question: ask → gap_check
      ├─ no gap → next question
      └─ gap detected → PHASE 4b (auto-enrich)
           └─ fast research → error cleanup → re-ask → gap_check
               ├─ still gap OR no improvement → accept + flag, next question
               └─ gap resolved → next question
Phase 4 Step 3: save findings (unchanged)
```

### FR2 Implementation — Replace sleep loops with two-step batch delete

Two files, same pattern in each (reference by step name, not line numbers):
- Alex SKILL.md `research_plan_protocol.step4` → Phase 2 → "For each error source" block (Step 1) and "For each group with count > 1" block (Step 2)
- research-notebook SKILL.md `curate` → Step 1b "Auto-clean error sources" and Step 1c "Auto-deduplicate"

## 5. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Gap detection method | CRAG Judge / STORM multi-perspective / custom metric | CRAG Judge | Free signal from NotebookLM "sources do not contain"; zero additional cost |
| 2 | Iteration limit | 1 / 2 / 3 rounds | 2 rounds | Balance coverage vs time; each fast research ~1min |
| 3 | User interaction on gap | Ask every time / Auto + report / Auto silent | Auto + report | Minimize interruption; user sees what happened post-hoc |
| 4 | Delete acceleration | xargs -P5 / dedup-before-import / both | xargs -P5 | Within our control; dedup-before-import depends on CLI capability |

## 6. Files to Modify

| # | File | Change |
|---|------|--------|
| 1 | `.claude/skills/alex/SKILL.md` | Insert PHASE 4b gap detection loop inside Phase 4 Step 2 ask loop (after each `ask` call, before `sleep 1`). Modify Phase 2 "For each error source" and "For each group" blocks to use two-step batch delete pattern. |
| 2 | `.claude/skills/research-notebook/SKILL.md` | Modify curate Step 1b "Auto-clean error sources" and Step 1c "Auto-deduplicate" to use two-step batch delete pattern. |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` (lines 1035-1134, read at 2026-05-05)
- `.claude/skills/research-notebook/SKILL.md` (lines 244-283, read at 2026-05-05)

## 7. Acceptance Criteria

- [ ] AC1: Phase 4 ask 返回含 "sources do not contain" 的答案时，自动触发 `add-research --mode fast`
- [ ] AC2: fast research 完成后自动 re-ask 同一个问题
- [ ] AC3: `max_reask_per_question: 1` 明确定义（1 次 re-ask = 总共 2 次查询），不会无限循环
- [ ] AC4: diminishing returns 使用 `grep -oE '\[[0-9]+\]' | sort -u | wc -l` 统计 unique citation count，re-ask 未增加且 gap 信号仍在时报告并停止
- [ ] AC5: 每次 gap 检测 + 补源都有 report 输出（"🔄 Gap detected..."）
- [ ] AC6: Phase 2 error cleanup 使用 `xargs -P5` 并行删除（Alex SKILL）
- [ ] AC7: Phase 2 dedup 使用 `xargs -P5` 并行删除（Alex SKILL）
- [ ] AC8: research-notebook curate Step 1b 使用 `xargs -P5` 并行删除
- [ ] AC9: research-notebook curate Step 1c 使用 `xargs -P5` 并行删除

## 8. Testing Checklist

- [ ] Read modified SKILL sections, verify PHASE 4b logic is syntactically correct YAML
- [ ] Verify xargs pattern includes `sleep 0.2` rate limiting
- [ ] Verify gap detection signals list matches the 3 known NotebookLM phrases
- [ ] Verify max iteration = 2 is enforced (not 2 re-asks, but 1 original + 1 re-ask)
- [ ] Verify diminishing returns detection logic (citation count comparison)

## 9. Spec Compliance Checklist

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `grep -c "sources do not contain" .claude/skills/alex/SKILL.md` | ≥1 |
| AC2 | `grep -c "re-ask\|re_ask" .claude/skills/alex/SKILL.md` | ≥1 |
| AC3 | `grep -c "max_reask_per_question.*1\|max_reask.*1" .claude/skills/alex/SKILL.md` | ≥1 |
| AC4 | `grep -c "diminishing\|citation.*count\|citation.*增加" .claude/skills/alex/SKILL.md` | ≥1 |
| AC5 | `grep -c "Gap detected\|gap.*detect" .claude/skills/alex/SKILL.md` | ≥1 |
| AC6-7 | `grep -c "xargs -P5\|xargs -P 5" .claude/skills/alex/SKILL.md` | ≥2 |
| AC8-9 | `grep -c "xargs -P5\|xargs -P 5" .claude/skills/research-notebook/SKILL.md` | ≥2 |

## 10. Important Notes

### 10.1 PHASE 4b 不改变 Phase 4 的其他逻辑
Question Tree 生成、cross-notebook query、save findings 都不变。PHASE 4b 只在每个 ask 返回后插入一个检查点。

### 10.2 xargs -P5 的 rate limiting
NotebookLM API 的 rate limit 未公开文档。5 concurrent workers × (API call ~0.1s + sleep 0.2s) ≈ ~17 deletes/sec 峰值。如果 output 中出现 `FAIL:` 行（429 或其他错误），Blake 应降回 `-P3` 再试；如果仍有 FAIL 则降回 `-P1`（等效于 sequential + sleep 0.2s）。

### 10.3 gap 信号列表是 extensible
初始 3 个短语来自实验观察。未来可追加更多 NotebookLM 返回的 gap 信号文本。

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P0-1: Cross-notebook scope undefined for CRAG loop | FR1 "Cross-notebook scope" paragraph added | Resolved |
| backend-architect | P0-2: Paragraph >50 words heuristic false-positive factory | FR1 gap signals — heuristic DEFERRED with note | Resolved |
| backend-architect | P0-3: xargs shell injection + error swallowing | FR2 rewritten with safe `"$1"` positional + `2>&1` pipe | Resolved |
| backend-architect | P1-1: "Max 2 rounds" inconsistent definition | FR1 step 7 uses canonical `max_reask_per_question: 1` | Resolved |
| backend-architect | P1-2: Fast research query too broad | FR1 step 1 "Query narrowing" added | Resolved |
| backend-architect | P1-3: Zero-source fast research not handled | FR1 step 3 "Zero-source check" added | Resolved |
| backend-architect | P1-4: Diminishing returns lacks operational definition | FR1 step 8 explicit `grep -oE` method + conjunction rule | Resolved |
| code-reviewer | P0-1: Line numbers drift (recurring 4-phase pattern) | §6 replaced with step-name references | Resolved |
| code-reviewer | P0-2: xargs incompatible with SKILL execution model | FR2 rewritten as two-step Bash call pattern | Resolved |
| code-reviewer | P0-3: Citation counting no operational definition | FR1 step 8 explicit regex method | Resolved |
| code-reviewer | P1-3: Rate limiting math incorrect | §10.2 corrected (~17 deletes/sec peak) | Resolved |
| code-reviewer | P1-4: AC3 grep too loose | §9 AC3 tightened to `max_reask_per_question` | Resolved |
| code-reviewer | P1-5: §11 "keep Phase 1-5 unchanged" contradicts PHASE 4b | §11 reworded to clarify Phase 4 internal insertion | Resolved |

**Round 1 verdict**: code-reviewer CONDITIONAL PASS (3 P0), backend-architect CONDITIONAL PASS (3 P0).
**After P0 fixes**: All 6 unique P0s + 7 P1s resolved. Ready for Gate 2.

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **NotebookLM CLI State Management: `-n` Flag vs `use` Command** (architecture.md) — 补源 re-ask 必须用 `-n` flag，绝不能用 `use` 切换
- **NotebookLM Research Methodology: Report Is Baseline, Multi-Round Ask Is Value** (architecture.md) — Phase 4b 的 re-ask 是管线的核心价值所在
- **Venv Absolute Path for AI-Invoked CLI Tools** (architecture.md) — 所有 CLI 调用必须用绝对路径

## 11. Blake Instructions

这是一个 YAML-type 的 SKILL 文本编辑任务。不需要写代码——修改两个 .md 文件的 YAML protocol 定义。

**关键约束**：
- 保持 Phase 1/2/3/5 结构不变。Phase 4 内部在 Step 2 ask 循环的每个 ask 返回后插入 PHASE 4b gap 检查，不改变 Step 1/2/3 的现有逻辑
- xargs 替换时保留 `⚠️ DEFENSIVE` JSON shape 检查逻辑
- 所有 `notebooklm` 调用使用绝对路径 `~/.tad-notebooklm-venv/bin/notebooklm`
