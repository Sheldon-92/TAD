# Epic: Trajectory Evaluation Harness (SLM-as-Judge)

**Epic ID**: EPIC-20260701-trajectory-eval-harness
**Created**: 2026-07-01
**Owner**: Alex

---

## Objective

Build TAD's first quantitative quality-measurement infrastructure: an SLM-as-Judge harness
that scores agent execution trajectories against a calibrated rubric, replacing self-reported
Gate evidence with independent measurement. Directly addresses the two open strategic gaps
from the 2026-06-09 repositioning research: **gate-ROI unproven** and **validation theater**.

**ICP Anchor**: TAD 维护者在「评估框架改动是否真的提升质量」场景中（机械 enforcement 决断、
Gate 摩擦成本是否值得、YOLO 批量执行质量抽查）需要对执行轨迹的自动化可信评分，
最关心 judge 判断可信度（不能再造一个 validation theater）。

**Research grounding**: `.tad/evidence/research/2026-05-14-kr2-kr3-ask-findings.md` (Rank #3:
98% cost↓, 0.87 Spearman, sub-200ms) + `.tad/evidence/research/repositioning-3-walls/2026-06-09-ask-findings.md`
(gate-ROI gap). Original integration target *optimize was RETIRED 2026-06-10 (Self-Evolution
Pruning) — integration redesigned to Gate 4 acceptance + Gate-ROI report.

## Success Criteria

- [ ] Rubric ≥5 dimensions, each with 1-5 anchor definitions, persisted to `.tad/eval/rubric.md`
- [ ] Golden set ≥10 hand-labeled trajectories (≥2 known-bad); judge agreement Spearman ≥0.7 OR within-1 ≥80% — **below threshold → Epic stops (pivot), Phase 3 does NOT start**
- [ ] Judge single evaluation cost ≤ $0.30 AND wall-clock ≤ 5 min (Sonnet-class; AMENDED 2026-07-02 by user decision — "Haiku 有点太笨了"，judge 质量优先于单次成本；成本从 subagent token 用量折算)
- [ ] Discriminative check (AMENDED 2026-07-02 — class-mean gap unsatisfiable by construction: golden pooled means are known-good 2.94 < known-bad 3.30, because early known-good trajectories are evidence-sparse and the silent-bad is deliberately high-scored per rigor≠outcome): (a) contrast pair — judge pooled mean GS-11 − GS-03 ≥ 1.5 with correct sign (golden's own gap = 2.2); (b) anti-anchoring — judge pooled mean on GS-06 (silent-bad) ≥ 3.5 despite the known-bad label
- [ ] Gate 4 acceptance can invoke judge in one step producing an evidence file; a 30-day Gate-ROI report can be generated

## Design Constraints (locked by Socratic 2026-07-01)

| Dimension | Decision |
|-----------|----------|
| Posture | **Offline measurement only** — advisory signal, NOT in-session blocking (blocking enforcement is a separate strategic decision) |
| Data | Use existing trace v2.0 events + file artifacts (handoff / completion / gate evidence); minimal schema increments only if audit proves necessary |
| Judge | Prompt-based Sonnet-class judge via internal subagent (fresh Agent spawn, paths-only, blind to golden labels); NO model training/fine-tuning. AMENDED 2026-07-02: Haiku→Sonnet per user; backend = Agent tool (与盲评方式一致，零配置) |
| Calibration freeze | Golden 分数冻结；rubric 措辞可澄清（与 judge prompt 迭代共享 ≤2 轮上限）— 防"改尺子凑分数" |
| Independence | Rubric never enters the executing agent's context (anti-Goodhart); judge runs in independent context |
| Scope | TAD repo only; no cross-project deployment |
| Interpretation | Output is a decision-support signal, not statistical proof (single-user sample size) |

## Excluded (Q3b confirmed)

Real-time/in-session blocking, trace schema major redesign, cross-project rollout,
model training, graph memory.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Data Sufficiency Audit + Rubric + Golden Set | ✅ Done | HANDOFF-20260702-trajectory-eval-p1.md (archived; Gate 4 PASS 2026-07-02) | audit report + rubric.md + labeled golden set |
| 2 | Judge Harness Spike + Calibration (pivot gate) | ✅ Done | HANDOFF-20260702-trajectory-eval-p2.md (archived; Gate 4 PASS 2026-07-02; calibration_verdict: PASS) | judge harness + calibration report vs golden set |
| 3 | Integration: Gate 4 evidence + Gate-ROI report | ⬚ Planned | — | acceptance hook-in + 30-day ROI report command |

### Phase Dependencies
All phases sequential. Phase 3 is CONDITIONAL on Phase 2 calibration passing the pivot threshold.

### Derived Status
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Data Sufficiency Audit + Rubric + Golden Set

**Status:** ✅ Done (Gate 4 PASS 2026-07-02)
**Execution:** manual (Blake Terminal 2)

#### Scope
Audit whether existing artifacts (`.tad/evidence/traces/*.jsonl` v2.0 events,
`.tad/evidence/decisions/*.jsonl`, archived handoffs, completion reports, gate evidence files)
can reconstruct a scorable trajectory per handoff — BEFORE designing the rubric
(Measure Before Optimizing). Then design a ≥5-dimension rubric grounded in the Gate canonical
checklist, and hand-label a golden set of ≥10 historical trajectories. NOT in scope: any judge
implementation, any trace emission changes beyond a documented minimal-increment proposal.

#### Input
- `.tad/evidence/traces/` daily JSONL (schema v2.0) + `per-handoff/` + `.tad/evidence/decisions/`
- `.tad/archive/handoffs/` (185+ historical handoffs with completion reports)
- `.tad/gates/gate-canonical-checklist.md` (SSOT for quality dimensions)
- Research: 2026-05-14 findings (CLEAR-style rubric reference)

#### Output
- Data audit report: coverage matrix (rubric dimension × available data source), gaps, minimal schema-increment proposal (if needed)
- `.tad/eval/rubric.md`: ≥5 dimensions with 1-5 anchors
- `.tad/eval/golden-set/`: ≥10 labeled trajectories (label + rationale per dimension)

#### Acceptance Criteria
- [ ] Audit report exists at `.tad/evidence/designs/trajectory-data-audit.md` with a dimension×source coverage matrix; every proposed rubric dimension maps to ≥1 data source that exists TODAY (or is explicitly flagged as requiring the minimal increment)
- [ ] `.tad/eval/rubric.md` has ≥5 dimensions, each with 1-5 anchor descriptions; dimensions are MECE against `.tad/gates/gate-canonical-checklist.md` (no dimension duplicates another's anchors)
- [ ] `.tad/eval/golden-set/` contains ≥10 trajectories with per-dimension human labels + 1-line rationale; ≥2 are known-bad (e.g., the 2026-04-14 express 4-P0 incident, a validation-theater case from YOLO audit)
- [ ] Human (user) has reviewed and confirmed golden-set labels (labels are the calibration ground truth — cannot be agent-only)

#### Files Likely Affected
- `.tad/evidence/designs/trajectory-data-audit.md` (CREATE)
- `.tad/eval/rubric.md` (CREATE)
- `.tad/eval/golden-set/*.md` (CREATE, ≥10 files or single indexed file)

#### Dependencies
None (can execute independently)

#### Notes
Risk #2 (data insufficiency) is resolved here by ordering: audit BEFORE rubric.
If audit shows trajectories cannot be reconstructed at all → report back to Alex before
proceeding (possible re-scope of Phase 1 deliverables).

### Phase 2: Judge Harness Spike + Calibration (pivot gate)

**Status:** ✅ Done (Gate 4 PASS 2026-07-02 — calibration_verdict: PASS，Phase 3 解锁)
**Execution:** manual (Blake Terminal 2)

#### Scope
Build a prompt-based Haiku-class judge that takes a trajectory bundle (assembled from Phase 1's
audited sources) and outputs per-dimension JSON scores + rationale. Calibrate against the golden
set; measure agreement, cost, latency, discriminative gap. NOT in scope: any integration into
acceptance/gate flows; any blocking behavior.

#### Input
- Phase 1: rubric + golden set + audit report (bundle assembly recipe)
- Haiku-class model access (claude-haiku-4-5)

#### Output
- Judge harness (CLI script or workflow) + trajectory bundle assembler
- Calibration report: Spearman / within-1 agreement, cost per eval, latency, good-vs-bad gap

#### Acceptance Criteria
- [ ] Judge CLI: given a handoff slug (or trajectory bundle path), outputs JSON with per-dimension scores (1-5) + rationale strings; deterministic output schema validated
- [ ] Calibration vs golden set: Spearman ≥0.7 OR within-1 agreement ≥80% — measured and reported; **if below threshold after ≤2 prompt-iteration rounds → STOP, write pivot report, Phase 3 blocked**
- [ ] Cost ≤ $0.05 per evaluation AND ≤60s wall-clock (measured over ≥10 runs, reported p50/p95)
- [ ] Discriminative check: known-good vs known-bad mean score gap ≥1.5
- [ ] Anti-Goodhart verified: rubric text is NOT loaded into any executing-agent SKILL/context path (grep check documented)

#### Files Likely Affected
- `.tad/eval/judge/` (CREATE — harness script + prompt template + bundle assembler)
- `.tad/evidence/eval/calibration-report-{date}.md` (CREATE)

#### Dependencies
Phase 1

#### Notes
Pivot threshold is the Epic's kill switch (Measure Before Optimizing: explicit threshold,
early course correction). Judge prompt iterations capped at 2 to prevent overfitting to golden set.

### Phase 3: Integration — Gate 4 Evidence + Gate-ROI Report

**Status:** ⬚ Planned (CONDITIONAL on Phase 2 calibration PASS)
**Execution:** pending

#### Scope
Wire the calibrated judge into (a) Alex's Gate 4 acceptance as an optional one-step independent
evidence generator, and (b) a Gate-ROI rollup report (30-day window: gates run, issues caught
pre-ship vs escaped, judge score trends). Advisory only — judge score does NOT block acceptance.
NOT in scope: Blake-side Gate 3 integration, in-session enforcement, cross-project sync.

#### Input
- Phase 2: calibrated judge + calibration report (must be PASS)
- `.claude/skills/alex/references/acceptance-protocol.md` (integration point)

#### Output
- Acceptance protocol gains optional judge invocation step producing evidence file
- Gate-ROI report generator (command or script) with 30-day rollup

#### Acceptance Criteria
- [ ] During *accept, Alex can invoke judge in one step; output evidence file lands in `.tad/evidence/acceptance-tests/{handoff-slug}/trajectory-judge.json` (or .md)
- [ ] Gate-ROI report command generates a 30-day rollup: #gates run, #P0/P1 caught pre-ship vs post-ship escapes, judge score trend per dimension — runnable against historical data
- [ ] Judge step is advisory: *accept completes normally when judge is skipped or unavailable (degradation path tested)
- [ ] Zero regression to existing *accept flow (existing acceptance on a past handoff replays clean)
- [ ] Protocol edits pass the SAFETY line-set discipline: constraint citations preserved, dual-platform parity (`.claude/skills` ↔ `.agents/skills`) maintained

#### Files Likely Affected
- `.claude/skills/alex/references/acceptance-protocol.md` (MODIFY — optional judge step)
- `.agents/skills/alex/references/acceptance-protocol.md` (MODIFY — parity mirror)
- `.tad/eval/judge/gate-roi-report.sh` or equivalent (CREATE)

#### Dependencies
Phase 2 (calibration PASS required — pivot threshold is blocking)

#### Notes
Integration target redesigned: original research said "*optimize pipeline" but *optimize was
retired 2026-06-10. New flow: Gate 4 evidence + periodic ROI report. The ROI report is the
deliverable that feeds the mechanical-enforcement strategic decision (roadmap item ④).

---

## Context for Next Phase

### Completed Work Summary
- Phase 1: Audited 24 archived trajectories (bundle reconstruction viable; evidence-persistence generational gap found). Delivered rubric (5 dims × 5 anchors, D2 scoring-basis clarified at Gate 4) + golden set (12 trajectories: 4 known-bad incl 1 silent-bad, 7 known-good, 1 mixed; per-dim ≥3 score levels verified) + BLIND-PACK. Labels confirmed via 2 independent blind subagent raters + Alex adjudication (user-approved substitution for infeasible human labeling; 3 divergences ≥2 adjudicated, 2 scores modified). Commit 7b9232b. Gate 4 report: `.tad/evidence/acceptance-tests/trajectory-eval-p1/gate4-acceptance-report.md`
- Phase 2: Judge harness built (judge-prompt.md + assemble-bundle.sh + 12 bundles) and CALIBRATED — round1 88.2% within-1 / contrast FAIL → D2 Evidence Scope Rule added to judge prompt (rubric + golden untouched, verified by git diff) → round2: **within-1 94.1% (32/34), contrast 1.75 (D4-excl, P1 ambiguity adjudicated at Gate 4 per Phase-1 pre-declaration), anti-anchor 3.75, stability probe max Δ=1**. calibration_verdict: PASS → Phase 3 unblocked. Commits aa8aeaf + 8d7b767. Gate 4 report: `.tad/evidence/acceptance-tests/trajectory-eval-p2/gate4-acceptance-report.md`

### Decisions Made So Far
- Offline measurement posture (no blocking) — keeps this Epic decoupled from the mechanical-enforcement strategic decision, while producing the data that decision needs
- Audit-before-rubric ordering (Measure Before Optimizing)
- Pivot threshold: **within-1 ≥80% is the PRIMARY calibration metric** (n=12 makes Spearman CI ±~0.28 — directional only); below threshold → Epic stops
- Ground-truth basis: DEGRADED_WITH_APPROVAL — blind agent raters, not human labels (human labeling infeasible; see gate-design.md pattern 2026-07-02)
- UNRECOVERABLE dims: pairwise exclusion in calibration; dim with full-score n<8 → data-poor, excluded from止损判定 (advisory only)

### Known Issues / Carry-forward (for Phase 3)
1. **判别余量薄**：对比对 1.75 vs 门槛 1.5（余量 0.25），探针单维 Δ 可达 1 — Phase 3 的 ROI 报告引用判别力时必须注明
2. **Judge prompt 冻结**：judge-prompt.md（含 D2 Evidence Scope Rule）是校准后产物 — Phase 3 集成时不得修改；改动 = 校准失效需重校准
3. **GS-07.D3 golden 标签存疑**：三次独立评估（盲评 3/3 + judge 4）均高于 golden 的 2 — Epic 结束后的 golden 维护周期复审，Epic 期间冻结
4. **Token 计量 DEGRADED 为常态**：judge 调用成本以 wall-clock + bundle 行数为准
5. Anti-Goodhart 持续义务：Phase 3 把 judge 接进 acceptance 流程时，rubric/judge-prompt 仍不得进入执行 agent 的常驻 context（AC10 类检查延续）

### Next Phase Scope
Phase 3: Integration — Gate 4 acceptance 一键调 judge 产出独立 evidence 文件 + 30 天 Gate-ROI 汇总报告。Advisory only（judge 分不阻塞验收）。前提已满足：Phase 2 calibration PASS。

---

## Notes

Socratic co-definition completed 2026-07-01 (user delegated Q2/Q4 definition to Alex; Q3a/Q3b/Q5
explicitly confirmed). Gate 1 PASS. Active epic count at creation: 2/3 (surplus-burn-mode + this).
