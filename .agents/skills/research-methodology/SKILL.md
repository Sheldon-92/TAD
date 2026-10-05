---
name: research-methodology
description: Unified research pipeline for AI agents — 5-phase (Plan→Source→Curate→Analyze→Output) with state-tracking, saturation detection, anti-hallucination guards, PIVOT/REFINE logic, and QCE output. Invoke when user says "研究 X", "研究一下", "深入了解", "调研", "landscape", "对比研究", "deep research", or similar multi-source synthesis tasks.
keywords: ["研究", "research", "调研", "landscape", "对比研究", "deep research", "分析", "综述", "竞品", "市场调研", "技术调研"]
type: orchestration-router
---

# Research Methodology Capability Pack v1.0

**CONSUMES**: User research question + optional existing context
**PRODUCES**: QCE-structured research report + extracted AC list + `.research/` session artifacts

> This file is the **orchestration router**. Phase logic lives in `references/*.md` — load the relevant reference file when entering each phase. Do NOT implement all logic inline here.

---

## Step 0: System Preflight + Session Management

Before starting any research:

### 0.1 NotebookLM Availability Check
```
notebooklm_bin="$HOME/.tad-notebooklm-venv/bin/notebooklm"
```
- If `test -x "$notebooklm_bin"` → **FULL MODE**: all 5 phases + 4-layer anti-hallucination
- If check fails → **DEGRADED MODE**: announce "⚠️ NotebookLM not available. Running in degraded mode (WebSearch only). For full capability: bash .tad/cross-model/setup-notebooklm.sh" and continue with per-phase fallbacks defined in references/sourcing.md and references/analysis.md

### 0.2 Concurrent Session Guard (FR11)
Check if `.research/research-state.yaml` exists:

**If NOT found** → fresh session, create `.research/` directory, proceed to Phase 1.

**If found** → read `phase` field:
- If `phase == complete` → archive to `.research/sessions/{session_id}/`, start fresh
- If `phase != complete` → this is an active session. Use AskUserQuestion:
  - Question: "已有进行中的研究 '{topic}'（当前阶段: {phase}）。怎么处理？"
  - Options: "恢复现有研究" / "归档并开始新研究" / "取消"
  - If resume → proceed to 0.3 (crash recovery validation)
  - If archive → move state to `.research/sessions/{session_id}/`, start fresh
  - If cancel → return to standby

### 0.3 Crash Recovery Validation (FR10)
Only runs when resuming an existing session:
- Stale check: if `updated` timestamp > 7 days ago → AskUserQuestion "发现 7 天前的未完成研究 '{topic}'。恢复还是重新开始？"
- Notebook validation (FULL MODE only): run `"$notebooklm_bin" source list -n {notebook_id}` — if fails → warn "笔记本 {notebook_id} 不可访问，将跳过 NotebookLM 步骤" and downgrade to DEGRADED MODE for this session
- Announce: "恢复研究: '{topic}', 当前阶段: {phase}" → enter that phase directly

### 0.4 Session Budget Guardrails (NFR6)
Default limits (user can override via AskUserQuestion when limit reached):
- Max ask rounds per session: **10** (includes REFINE re-asks and PIVOT new-angle asks — every `notebooklm ask` call increments `analyze.ask_rounds`)
- Max sources per notebook: **100**
- Max PIVOTs per session: **3** (cross-question total; after 3 PIVOTs, end session with PARTIAL output and document remaining gaps)

**Concurrent session note**: `.research/research-state.yaml` is a single-writer file. If two Claude Code sessions start researching simultaneously, the last writer wins. Always check §0.2 at session start and look for mismatched `session_id` or `topic` in the state file — if the file's `topic` doesn't match the current request, treat as concurrent session conflict and present §0.2 options.

---

## Phase 1: PLAN

**State**: `phase: plan`
**Reference**: `references/planning.md`

Load `references/planning.md` for detailed protocols. Summary:

1. **Decompose** research question into a problem tree (≥3 sub-questions)
2. **Define** source strategy (GitHub-First by default; see references/sourcing.md)
3. **Define** success criteria ("能回答完整决策树" is a valid form)
4. **Check dead-end registry**: before finalizing question tree, scan `.research/dead-ends.yaml` for each sub-question. Dead-end schema:

```yaml
dead_ends:
  - id: "DE-001"
    question: "What tools exist for automated grounded theory coding?"
    scope: "exact"          # exact | fuzzy
    reason: "No CLI tools found; all solutions are GUI-only SaaS"
    contradicting_evidence: "ASReview exists but is active-learning, not grounded theory"
    recorded_at: "2026-05-08"
    session_id: "RS-20260508-001"
    ttl_days: 90
    overridable: true
```
  - If match found AND not expired (recorded_at + ttl_days > today) AND overridable=true → AskUserQuestion "此问题曾标记为死胡同: {reason}。要继续研究吗？"
  - If not overridable → skip that question, note in plan

5. **Initialize** `.research/research-state.yaml` (template in §4 of this file)

**GATE H1**: Use AskUserQuestion — "请审查研究计划：\n[问题树]\n[来源策略]\n[成功标准]\n批准还是修改？"
- Options: "批准，继续 SOURCE" / "修改问题树" / "修改来源策略"
- On approval: write `plan.gate_h1: approved` to state file → proceed to Phase 2

---

## Phase 2: SOURCE

**State**: `phase: source`
**Reference**: `references/sourcing.md`

Load `references/sourcing.md` for GitHub-First strategy details.

**FULL MODE**:
1. Execute GitHub-First sourcing (awesome-lists → company repos → tool repos → docs → articles)
2. Add sources to NotebookLM: `"$notebooklm_bin" source add -n {notebook_id} "{url}"`
3. Track: update `source.total_added` in state file
4. Source budget: if total_added approaches 100 → AskUserQuestion before adding more

**DEGRADED MODE**:
1. Execute WebSearch (≥3 queries per sub-question from problem tree)
2. Save results in context (no notebook) — note source URLs for manual citation in Phase 5
3. Layer 1 anti-hallucination: use WebFetch to confirm each URL returns HTTP 200

*No human gate after SOURCE — automated phase.*

---

## Phase 3: CURATE

**State**: `phase: curate`
**Reference**: `references/quality-control.md`

Load `references/quality-control.md` for tier criteria and cleanup protocols.

**FULL MODE**:
1. Clean error sources (those that failed to import)
2. Deduplicate (same URL added multiple times)
3. Score each source: T1 (official/academic) / T2 (industry) / T3 (community)
4. Run: `bash scripts/source-quality.sh .research/research-state.yaml`
   - Exit 0 (T1 ratio ≥ 0.30) → proceed
   - Exit 1 (T1 ratio < 0.30) → recommend adding T1 sources, AskUserQuestion to continue anyway
5. Update state: `curate.tier1_count`, `tier2_count`, `tier3_count`, `tier1_ratio`

**DEGRADED MODE**: N/A (no notebook to curate — skip to Phase 4)

**GATE H2**: Use AskUserQuestion — "来源质量报告：T1={N} T2={N} T3={N} (T1 占比 {ratio}%)。继续分析还是先补充 T1 来源？"
- Options: "继续分析" / "先补充来源再继续"
- On approval: write `curate.gate_h2: approved` → proceed to Phase 4

---

## Phase 4: ANALYZE

**State**: `phase: analyze`
**Reference**: `references/analysis.md`

Load `references/analysis.md` for ask loop, CRAG, and PIVOT/REFINE protocols.

**FULL MODE**:
1. Generate baseline report: `"$notebooklm_bin" summary --topics -n {notebook_id}`
2. Run ask loop — for each sub-question in problem tree:
   - Ask: `"$notebooklm_bin" ask -n {notebook_id} "{question}"`
   - Extract claims (### Claim: blocks) and count NEW findings vs prior rounds
   - Update `analyze.new_findings_per_round[]` in state file
   - Run saturation check: `bash scripts/saturation-check.sh .research/research-state.yaml`
     - `SATURATED` → stop loop, proceed to Phase 5
     - `DIMINISHING` → AskUserQuestion "研究收敛中 — 继续还是进入 OUTPUT？"
     - `CONTINUE` → next question
   - Check for gap signals (see references/analysis.md for CRAG patterns)
   - Apply PIVOT/REFINE decision tree (see references/analysis.md)
3. Round budget: if ask_rounds reaches 10 → AskUserQuestion "已完成 10 轮问答。继续还是进入 OUTPUT？"

**DEGRADED MODE**:
1. Execute WebSearch synthesis for each sub-question
2. Synthesize findings in context (no cross-source NotebookLM ask)
3. Layer 2 anti-hallucination: agent must include exact quote from source (not paraphrased)

*No human gate — automated, but PIVOT decisions require user confirmation (see references/analysis.md).*

---

## Phase 5: OUTPUT

**State**: `phase: output` → `complete`
**Reference**: `references/output.md`

Load `references/output.md` for QCE format spec and AC extraction rules.

1. Generate QCE report to `.research/report.md` (project-level, not session dir)
2. Extract ACs to `.research/acs.md` (project-level, not session dir)
3. Update dead-end registry: add entries for any Claim with confidence=low and zero contradicting evidence
4. Update state: `output.qce_report_path: .research/report.md`, `output.extracted_acs_path: .research/acs.md`

**GATE H3**: Use AskUserQuestion — "研究完成。请审查报告和 AC 列表。"
- Options: "批准，归档研究" / "需要补充某个方向" / "需要修改输出"
- On approval (archive only on user approval — do NOT archive before gate):
  1. `mkdir -p .research/sessions/{session_id}/`
  2. Move: `.research/report.md` → `.research/sessions/{session_id}/report.md`
  3. Move: `.research/acs.md` → `.research/sessions/{session_id}/acs.md`
  4. Move: `.research/research-state.yaml` → `.research/sessions/{session_id}/research-state.yaml` (update phase: complete first)
  5. Update moved state copy: set `phase: complete`, `output.qce_report_path` and `output.extracted_acs_path` to final session paths

---

## §4: State File Template

Create at `.research/research-state.yaml` on session start:

```yaml
session_id: "RS-{YYYYMMDD}-{001}"
topic: "{research question}"
phase: "plan"  # plan | source | curate | analyze | output | complete
notebook_id: null  # set after NotebookLM notebook creation
mode: "full"  # full | degraded
created: "{ISO timestamp}"
updated: "{ISO timestamp}"

plan:
  question_tree: []
  source_strategy: "github-first"
  success_criteria: ""
  gate_h1: pending  # pending | approved | rejected

source:
  total_added: 0
  errors_cleaned: 0
  sources_healthy: 0

curate:
  tier1_count: 0
  tier2_count: 0
  tier3_count: 0
  tier1_ratio: 0.0
  gate_h2: pending  # pending | approved | rejected

analyze:
  ask_rounds: 0
  new_findings_per_round: []  # [12, 8, 6, 4, 1, ...]
  saturation_reached: false
  pivots: []
  refines: []
  # refine entry: {round: N, reason: "gap in X"}
  # pivot entry: {round: N, old_angle: "...", new_angle: "..."}

output:
  qce_report_path: ""
  extracted_acs_path: ""
  gate_h3: pending  # pending | approved | rejected
```

---

## §5: Anti-Hallucination Summary

| Layer | Mechanism | FULL MODE | DEGRADED MODE |
|-------|-----------|-----------|---------------|
| 1 | URL existence | NotebookLM source add validates | WebFetch + HTTP 200 check |
| 2 | Citation traceability | NotebookLM citations native | Agent includes exact quote |
| 3 | QCE structure | Contradictory evidence required | Same |
| 4 | Dead-end registry | Prevents citing refuted findings | Same |

---

## §6: Routing Priority (NFR1)

This pack's keywords are a **strict superset** of research-notebook and research-github SKILL keywords. When CLAUDE.md research routing triggers, this pack takes priority.

Trigger keywords: 研究, 调研, 研究一下, 深入了解, landscape, 对比, 对比研究, 比较, 分析市场, 深度调查, deep research, investigate, research, survey, systematic review, 行业分析, 技术调研, 竞品分析, 找一下, 了解一下, 看看有什么, 有哪些工具

After this pack is validated in ≥1 real project, mark research-notebook and research-github SKILLs as deprecated per NFR1 deprecation plan.
