# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-25
**Project:** TAD Framework
**Task ID:** TASK-20260325-002
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-25

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Layer 0.5 insertion point clearly defined in Ralph Loop |
| Components Specified | ✅ | 5 files: tad-blake.md, config-execution.yaml, config.yaml, handoff template, optimization-program template |
| Functions Verified | ✅ | All insertion points in tad-blake.md verified (lines 398-555) |
| Data Flow Mapped | ✅ | Handoff optimization_target → Blake detects → Layer 0.5 loop → Layer 1+2 |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Add an **Autoresearch Optimization Mode** to Blake's Ralph Loop — an optional, autonomous code optimization loop (Layer 0.5) that activates when a handoff contains an `optimization_target` with measurable numeric metrics. Inspired by Karpathy's autoresearch pattern: modify code → run benchmark → compare metric → keep/discard → repeat.

### 1.2 Why We're Building It
**业务价值**：Many tasks have measurable numeric targets (response time, accuracy, bundle size, coverage). Currently Blake optimizes manually — one attempt, one check. Autoresearch mode enables systematic iteration (up to 50 attempts) with git-based state management.
**用户受益**：User gets optimized results automatically, with full experiment log for review.
**成功的样子**：When a handoff contains `optimization_target: { metric: "response_time_ms", target: 50 }`, Blake automatically enters the optimization loop, iterates until target is met or limit reached, then continues to standard Layer 1+2.

### 1.3 Intent Statement

**真正要解决的问题**：Blake currently has no systematic way to iterate on numeric optimization tasks. The autoresearch pattern (modify → measure → keep/discard → repeat) is a proven approach for this class of problems.

**不是要做的**：
- ❌ 不是替代 Ralph Loop — 是在 Layer 1 前面加一个可选的 Layer 0.5
- ❌ 不是通用 AI agent 框架 — 只处理有明确数值指标的优化任务
- ❌ 不是运行 ML 训练 — 是用 autoresearch 的模式做代码优化

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 1 条 | Ralph Loop Two-Layer Architecture pattern |

**⚠️ Blake 必须注意的历史教训**：

1. **Ralph Loop Two-Layer Architecture** (architecture.md, 2026-01-26)
   - Layer 1 (fast self-check) 和 Layer 2 (expert review) 的分离是核心设计
   - 新增 Layer 0.5 必须保持这个分离 — Layer 0.5 结束后，Layer 1+2 照常运行
   - Circuit Breaker 模式同样适用于 Layer 0.5（连续失败 → 停止优化 → 继续 Layer 1+2）

---

## 2. Background Context

### 2.1 Autoresearch (Karpathy) — Design Reference

| Concept | autoresearch | TAD Adaptation |
|---------|-------------|----------------|
| Meta-instructions | `program.md` | `optimization_target` in handoff + `optimization-program.md` template |
| Code to modify | `train.py` (single file) | `scope` files from handoff |
| Metric | `val_bpb` (single number) | Configurable: response_time_ms, accuracy, bundle_size_kb, etc. |
| Keep/discard | `git commit` / `git reset --hard HEAD~1` | Same — git as state management |
| Experiment log | `results.tsv` | `.tad/evidence/optimization-runs/{task_id}_results.tsv` |
| Time budget | 5 min per experiment | Configurable `time_budget` per experiment |
| Iteration limit | Run until stopped | `max_iterations` (default 50) |
| Agent autonomy | Fully autonomous after start | Autonomous within Layer 0.5, then standard review |

### 2.2 Current Ralph Loop Flow (what we're modifying)

```
*develop →
  1_init → 1_5_context_refresh → 1_6_tdd_check → 1_7_worktree_setup →
  [IMPLEMENTATION] →
  2_layer1_loop (build/test/lint/tsc) →
  3_layer2_loop (expert review) →
  4_gate3_v2 →
  5_worktree_finish
```

### 2.3 New Flow (with Layer 0.5)

```
*develop →
  1_init → 1_5_context_refresh → 1_6_tdd_check → 1_7_worktree_setup →
  ┌─ 1_8_optimization_check: detect optimization_target in handoff
  │  If NOT found → skip to [IMPLEMENTATION] (unchanged)
  │  If found →
  │    1_9_optimization_loop (NEW Layer 0.5):
  │      read optimization-program.md (strategy) →
  │      LOOP:
  │        a. Form hypothesis (what to change)
  │        b. Modify scope files
  │        c. git commit -m "opt: {description}"
  │        d. Run benchmark_cmd
  │        e. Compare metric vs baseline/best
  │        f. If improved → keep (update best), log to results.tsv
  │        g. If not improved → git reset --hard HEAD~1, log to results.tsv
  │        h. If target reached → exit loop ✅
  │        i. If max_iterations reached → exit loop ⚠️
  │        j. If 5 consecutive no-improvement → exit loop (circuit breaker)
  │      END LOOP
  │      Output: optimization summary (iterations, improvement, best metric)
  └─ [IMPLEMENTATION continues if other tasks remain] →
  2_layer1_loop → 3_layer2_loop → 4_gate3_v2
```

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Add `1_8_optimization_check` step to `develop_command` in tad-blake.md — detects `optimization_target` in handoff
- FR2: Add `1_9_optimization_loop` step — the autoresearch loop with git keep/discard
- FR3: Add `optimization_target` field definition to handoff template (Section 3, NFR)
- FR4: Create `.tad/templates/optimization-program.md` — strategy template for agent
- FR5: Add `autoresearch_mode` config to config.yaml `optional_features`
- FR6: Add `autoresearch` section to config-execution.yaml with defaults
- FR7: Log experiments to `.tad/evidence/optimization-runs/{task_id}_results.tsv`

### 3.2 Non-Functional Requirements

#### optimization_target schema (in handoff Section 3 NFR):

```yaml
optimization_target:
  metric: "response_time_ms"     # What to measure (name used in benchmark output)
  baseline: 200                   # Current value (measured before optimization)
  target: 50                      # Goal value (lower/higher depends on direction)
  direction: "lower"              # "lower" = lower is better, "higher" = higher is better
  benchmark_cmd: "npm run bench:api-latency"  # Command that outputs the metric
  metric_pattern: "result:\\s*([\\d.]+)"  # Regex with capture group — first match is the metric value
  scope:                          # Files the agent can modify
    - "src/lib/api/handler.ts"
    - "src/lib/api/cache.ts"
  time_budget: 30                 # Max seconds per experiment run (default: 60)
  max_iterations: 50              # Max optimization attempts (default: 50)
  constraints:                    # Things agent must NOT do
    - "Do not change API interface signatures"
    - "Do not add new dependencies"
```

---

## 4. Technical Design

### 4.1 Files to Modify/Create

```
5 files:
├── .claude/commands/tad-blake.md              ← Add 1_8 + 1_9 steps
├── .tad/config-execution.yaml                 ← Add autoresearch section
├── .tad/config.yaml                           ← Add optional_features.autoresearch_mode
├── .tad/templates/handoff-a-to-b.md           ← Add optimization_target to Section 3
└── .tad/templates/optimization-program.md     ← NEW: strategy template
```

### 4.2 tad-blake.md — New Steps

Insert between `1_7_worktree_setup` and `2_layer1_loop`:

```yaml
1_8_optimization_check:
  description: "Detect optimization_target in handoff"
  action: |
    1. Read handoff Section 3 (Requirements)
    2. Search for `optimization_target:` block
    3. If NOT found → skip to IMPLEMENTATION (existing flow, no change)
    4. If found:
       a. Read config.yaml → check optional_features.autoresearch_mode.enabled
       b. If disabled → skip with note: "Optimization target found but autoresearch_mode disabled in config"
       c. If enabled → parse optimization_target fields
       d. Validate required fields: metric, baseline, target, direction, benchmark_cmd, scope
       e. If validation fails → WARN, skip to IMPLEMENTATION
       f. If valid → proceed to 1_9_optimization_loop
  skip_if: "No optimization_target in handoff"

1_9_optimization_loop:
  description: "Autoresearch-style optimization loop (Layer 0.5)"
  prerequisite: "1_8_optimization_check found valid optimization_target"
  action: |
    ## Setup
    1. Read .tad/templates/optimization-program.md for strategy guidance
    2. Create results dir + file: `mkdir -p .tad/evidence/optimization-runs/`
       Create: .tad/evidence/optimization-runs/{task_id}_results.tsv
       Header: iteration\tcommit\tmetric_value\tstatus\tdescription\ttimestamp
    3. **Safety anchor**: Ensure working tree is clean (`git status --porcelain` = empty).
       If dirty → commit existing changes first: `git add -A && git commit -m "pre-optimization baseline"`
       Then tag: `git tag tad-opt-baseline-{task_id}`
       This tag is the "never reset past" boundary.
    4. Run baseline benchmark: execute benchmark_cmd, extract metric via metric_pattern
       If baseline doesn't match handoff's declared baseline → WARN but continue
    5. Set best_value = baseline_value
    6. Announce: "Entering optimization loop. Target: {metric} from {baseline} to {target} ({direction}). Max {max_iterations} iterations. Safety anchor: tad-opt-baseline-{task_id}"

    ## Loop (max_iterations)
    For each iteration:
      a. **Hypothesize**: Based on scope files, previous results, and constraints,
         decide what code change to try. Document reasoning briefly.
      b. **Modify**: Edit file(s) within scope ONLY.
         Respect constraints from optimization_target.
      c. **Scope verify**: Run `git diff --name-only` and check that ALL changed files
         are in the optimization_target.scope list. If any file outside scope was modified:
         → `git checkout -- {out_of_scope_files}` to discard those changes
         → If scope files were also changed, proceed. If not, treat as failed iteration.
      d. **Commit**: `git add {scope_files} && git commit -m "opt-{iteration}: {description}"`
      e. **Benchmark**: Run benchmark_cmd using Bash tool with timeout: time_budget * 1000 ms.
         If timeout → treat as failure, log as "timeout".
         If crash → treat as failure, log as "crash".
         After benchmark: `git checkout -- {scope_files}` to discard any benchmark side effects.
      f. **Extract**: Match benchmark output against metric_pattern regex.
         Parse first capture group as numeric value.
         If can't parse → treat as failure, log as "parse_error".
      g. **Compare**:
         - direction="lower": improved if new_value < best_value
         - direction="higher": improved if new_value > best_value
      h. **Decide**:
         - If improved: KEEP commit. Update best_value. Log status="✓" to results.tsv.
         - If not improved: `git reset --hard HEAD~1`. Log status="✗" to results.tsv.
           Guard: NEVER reset past tad-opt-baseline-{task_id} tag.
         - If target reached (value meets or exceeds target): Log status="✓ TARGET". Exit loop.
      i. **Constraint check** (on keep only): Before finalizing a kept commit, verify
         constraints from optimization_target.constraints are not violated.
         If violated → treat as not-improved, revert, log status="✗ constraint".
      j. **Circuit breaker**: If 5 consecutive non-improvement (✗, timeout, crash, parse_error, ✗ constraint)
         → exit loop with note "plateau reached"

    ## Post-Loop
    1. **Squash optimization commits**: Squash all kept optimization commits since
       tad-opt-baseline-{task_id} into a single commit:
       `git reset --soft tad-opt-baseline-{task_id} && git commit -m "opt: {metric} improved {baseline} → {best_value}"`
       This keeps branch history clean for merge/PR.
    2. Remove baseline tag: `git tag -d tad-opt-baseline-{task_id}`
    3. Output summary:
       "Optimization complete: {iterations_run} iterations, {kept_count} kept.
        Metric: {baseline} → {best_value} (target: {target})
        Status: {TARGET_REACHED / PLATEAU / MAX_ITERATIONS}"
    4. If other implementation tasks remain in handoff → continue to IMPLEMENTATION
    5. Proceed to 2_layer1_loop (standard Layer 1 checks on optimized code)

  circuit_breaker:
    consecutive_no_improvement: 5
    action: "Exit optimization loop, proceed to Layer 1 with best result so far"

  constraints:
    - "Only modify files listed in optimization_target.scope (enforced by scope verify step)"
    - "Respect all items in optimization_target.constraints (enforced by constraint check step)"
    - "Prefer one conceptual change per iteration for clear attribution. Multiple small coupled changes acceptable."
    - "Document reasoning for each change in commit message"

  mode_interactions:
    agent_team: |
      If optimization_target is present, Agent Team mode is DISABLED for this handoff.
      Optimization requires sequential git state management (commit/reset) that is
      incompatible with parallel file ownership.
    tdd: |
      If both tdd_enforcement and autoresearch_mode are enabled:
      - Autoresearch mode takes precedence for optimization_target.scope files
      - TDD applies to remaining implementation tasks (if any) outside scope
      - Rationale: optimization loop measures via benchmark_cmd, not test suite
```

### 4.3 config.yaml — optional_features addition

```yaml
optional_features:
  # ... existing tdd_enforcement and git_worktree ...

  autoresearch_mode:
    enabled: true
    description: "When enabled and handoff has optimization_target, Blake enters autoresearch optimization loop before standard Layer 1+2"
    default_max_iterations: 50
    default_time_budget: 60  # seconds per experiment
    consecutive_fail_limit: 5  # circuit breaker threshold
    results_dir: ".tad/evidence/optimization-runs/"
```

### 4.4 config-execution.yaml — autoresearch section

Add after `ralph_loop:` section:

```yaml
# ==================== Autoresearch Optimization Mode ====================
autoresearch:
  description: |
    Optional Layer 0.5 in Ralph Loop — autonomous code optimization.
    Inspired by Karpathy's autoresearch: modify → benchmark → keep/discard → repeat.
    Only activates when handoff contains optimization_target with measurable metric.

  position: "Before Layer 1 (build/test/lint) in Ralph Loop"
  relationship_to_ralph_loop: "Layer 0.5 — runs BEFORE standard Layer 1+2, not replacing them"

  design_principles:
    - "Single metric: one number to optimize, no ambiguity"
    - "Git as memory: commit on improvement, reset on failure"
    - "Scope-limited: only modify files listed in optimization_target.scope"
    - "One change per iteration: isolate variables for clear attribution"
    - "Fixed time budget: each experiment runs in bounded time for fair comparison"
    - "Circuit breaker: stop after 5 consecutive no-improvement (plateau)"

  results_format:
    file: ".tad/evidence/optimization-runs/{task_id}_results.tsv"
    columns: ["iteration", "commit", "metric_value", "status", "description", "timestamp"]
    status_values:
      "✓": "Improvement, commit kept"
      "✗": "No improvement, commit reverted"
      "✓ TARGET": "Target reached, loop complete"
      "timeout": "Benchmark exceeded time_budget"
      "crash": "Benchmark crashed"
      "parse_error": "Could not extract metric from output"
```

### 4.5 handoff-a-to-b.md — Add optimization_target

Add to Section 3 (Requirements), after "3.2 Non-Functional Requirements":

```markdown
### 3.3 Optimization Target (Optional — triggers Autoresearch Mode)

> Only include this section if the task has a measurable numeric optimization goal.
> When present, Blake's Ralph Loop activates Layer 0.5 (autonomous optimization) before Layer 1+2.

```yaml
optimization_target:
  metric: "{metric_name}"           # e.g., "response_time_ms", "accuracy_pct", "bundle_size_kb"
  baseline: {current_value}         # Measured current value
  target: {goal_value}              # Target value to reach
  direction: "lower"                # "lower" = lower is better, "higher" = higher is better
  benchmark_cmd: "{command}"        # Command that outputs the metric
  metric_pattern: "{pattern}"       # Pattern to extract metric (e.g., "result: {value}")
  scope:                            # Files agent can modify (limit blast radius)
    - "{file_path_1}"
    - "{file_path_2}"
  time_budget: 60                   # Seconds per experiment (default: 60)
  max_iterations: 50                # Max attempts (default: 50)
  constraints:                      # Things agent must NOT change
    - "{constraint_1}"
    - "{constraint_2}"
```
```

### 4.6 optimization-program.md — New Template

Create `.tad/templates/optimization-program.md`:

```markdown
# Optimization Program (Autoresearch Mode)

> Strategy guide for Blake's Layer 0.5 optimization loop.
> Read this before starting the optimization loop.

## Approach

### General Strategy
1. **Start with quick wins** — look for obvious inefficiencies first
2. **One change per iteration** — isolate variables for clear cause-effect
3. **Read previous results** — don't repeat failed approaches
4. **Respect constraints** — never violate optimization_target.constraints
5. **Document reasoning** — commit messages should explain WHY, not just WHAT

### When Stuck (3+ consecutive failures)
- Try a completely different approach (don't keep tweaking the same thing)
- Re-read the scope files from scratch — fresh eyes find new opportunities
- Consider algorithmic changes instead of parameter tuning
- If truly stuck after 5 failures, the circuit breaker will exit — this is OK

### Common Optimization Patterns
- **Performance**: Caching, batch processing, lazy loading, algorithm complexity reduction
- **Accuracy**: Better matching algorithms, threshold tuning, edge case handling
- **Bundle size**: Tree shaking, dynamic imports, dependency replacement
- **Memory**: Object pooling, stream processing, reference cleanup

## Constraints
- Only modify files listed in `optimization_target.scope`
- All changes must pass build (if build fails, that's a failed experiment — revert)
- Do not add new dependencies unless explicitly allowed
- Do not change public API interfaces unless explicitly allowed

## Output
After each iteration, log to results.tsv:
`{iteration}\t{commit_hash}\t{metric_value}\t{status}\t{description}\t{timestamp}`
```

---

## 6. Implementation Steps

### Phase 1: Config + Template (~15 min)

#### 交付物
- [ ] config.yaml: `optional_features.autoresearch_mode` added
- [ ] config-execution.yaml: `autoresearch` section added
- [ ] `.tad/templates/optimization-program.md` created

#### 实施步骤
1. Edit config.yaml: add `autoresearch_mode` under `optional_features`
2. Edit config-execution.yaml: add `autoresearch` section after `ralph_loop`
3. Create `.tad/templates/optimization-program.md`

#### 验证方法
- `grep "autoresearch_mode" .tad/config.yaml` → 1+ hit
- `grep "autoresearch" .tad/config-execution.yaml` → 1+ hit
- File exists: `.tad/templates/optimization-program.md`

### Phase 2: Blake Loop Integration (~30 min)

#### 交付物
- [ ] tad-blake.md: `1_8_optimization_check` step added
- [ ] tad-blake.md: `1_9_optimization_loop` step added
- [ ] Steps correctly positioned between 1_7 and 2_layer1_loop

#### 实施步骤
1. Read tad-blake.md develop_command section (lines 398-555)
2. Insert `1_8_optimization_check` after `1_7_worktree_setup`
3. Insert `1_9_optimization_loop` after `1_8_optimization_check`
4. Ensure `2_layer1_loop` remains unchanged and runs AFTER optimization loop

#### 验证方法
- `grep "1_8_optimization_check" .claude/commands/tad-blake.md` → 1 hit
- `grep "1_9_optimization_loop" .claude/commands/tad-blake.md` → 1 hit
- `grep "autoresearch" .claude/commands/tad-blake.md` → 1+ hit
- Step ordering: 1_7 → 1_8 → 1_9 → 2_layer1_loop (verify reading)

### Phase 3: Handoff Template Update (~10 min)

#### 交付物
- [ ] handoff-a-to-b.md: Section 3.3 "Optimization Target" added

#### 实施步骤
1. Edit handoff-a-to-b.md: add Section 3.3 after Section 3.2

#### 验证方法
- `grep "optimization_target" .tad/templates/handoff-a-to-b.md` → 1+ hit
- `grep "Autoresearch" .tad/templates/handoff-a-to-b.md` → 1+ hit

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/commands/tad-blake.md              # Add 1_8 + 1_9 steps
.tad/config-execution.yaml                 # Add autoresearch section
.tad/config.yaml                           # Add optional_features.autoresearch_mode
.tad/templates/handoff-a-to-b.md           # Add Section 3.3
```

### 7.2 Files to Create
```
.tad/templates/optimization-program.md     # Strategy template for optimization loop
```

### 7.3 Files NOT to Modify
```
.claude/commands/tad-alex.md               # Alex doesn't run optimization
.tad/config-workflow.yaml                  # Not related
.tad/ralph-config/                         # Layer 0.5 config is in config-execution.yaml
```

---

## 8. Testing Requirements

### 8.1 Verification Checklist
- [ ] `grep "autoresearch_mode" .tad/config.yaml` → exists with `enabled: true`
- [ ] `grep "autoresearch:" .tad/config-execution.yaml` → section exists
- [ ] `grep "1_8_optimization_check" .claude/commands/tad-blake.md` → exists
- [ ] `grep "1_9_optimization_loop" .claude/commands/tad-blake.md` → exists
- [ ] `grep "optimization_target" .tad/templates/handoff-a-to-b.md` → exists
- [ ] File exists: `.tad/templates/optimization-program.md`
- [ ] Step order in tad-blake.md: 1_7 → 1_8 → 1_9 → 2_layer1_loop

### 8.2 Manual Review
- Read 1_9_optimization_loop end-to-end: is the loop logic clear?
- Verify circuit_breaker is defined (consecutive_no_improvement: 5)
- Verify git keep/discard mechanism is described (commit on improve, reset on not)
- Verify results.tsv format is consistent between config-execution.yaml and tad-blake.md

---

## 9. Acceptance Criteria

- [ ] AC1: config.yaml has `autoresearch_mode` under `optional_features` with `enabled: true`
- [ ] AC2: config-execution.yaml has `autoresearch` section with design principles and results format
- [ ] AC3: tad-blake.md has `1_8_optimization_check` that detects `optimization_target` in handoff
- [ ] AC4: tad-blake.md has `1_9_optimization_loop` with full loop logic (hypothesize → modify → commit → benchmark → compare → keep/discard)
- [ ] AC5: Loop uses git commit/reset for state management (not file backup)
- [ ] AC6: Circuit breaker: exits after 5 consecutive no-improvement
- [ ] AC7: Results logged to `.tad/evidence/optimization-runs/{task_id}_results.tsv`
- [ ] AC8: handoff-a-to-b.md has Section 3.3 with `optimization_target` schema
- [ ] AC9: `.tad/templates/optimization-program.md` exists with strategy guidance
- [ ] AC10: Layer 1+2 run AFTER optimization loop (not skipped)
- [ ] AC11: When no `optimization_target` in handoff, Blake's flow is completely unchanged

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | Config exists | grep "autoresearch_mode" config.yaml | Present, enabled: true |
| 2 | Execution config | grep "autoresearch:" config-execution.yaml | Section present |
| 3 | Detection step | grep "1_8_optimization_check" tad-blake.md | Present |
| 4 | Loop step | grep "1_9_optimization_loop" tad-blake.md | Present |
| 5 | Git mechanism | grep "git reset --hard HEAD~1" tad-blake.md | Present |
| 6 | Circuit breaker | grep "consecutive_no_improvement" tad-blake.md | 5 |
| 7 | Results log | grep "results.tsv" tad-blake.md | Referenced |
| 8 | Handoff schema | grep "optimization_target" handoff-a-to-b.md | Present |
| 9 | Program template | ls .tad/templates/optimization-program.md | File exists |
| 10 | Layer order | Read tad-blake.md step sequence | 1_9 before 2_layer1 |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Layer 0.5 must NOT skip Layer 1+2 — optimization loop exits → standard quality checks still run
- ⚠️ Git reset is destructive — only use on the optimization commits, never on pre-existing work
- ⚠️ `scope` field is a hard boundary — agent must NOT modify files outside scope during optimization
- ⚠️ This is a PROTOCOL change (adding steps to Blake's flow), not code — all changes are in .md/.yaml files

### 10.2 Design Decisions

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Position in Ralph Loop | Replace Layer 1 / Before Layer 1 / After Layer 2 | Before Layer 1 (Layer 0.5) | Optimization changes still need standard quality checks |
| 2 | State management | File backup / Git branch / Git commit+reset | Git commit+reset | Mirrors autoresearch design; simple, reversible, auditable |
| 3 | Circuit breaker threshold | 3 / 5 / 10 | 5 consecutive failures | Balance: enough tries to explore, not so many to waste time |
| 4 | Config approach | Always on / config flag / handoff flag | config flag + handoff field | Dual gate: must be enabled in config AND present in handoff |
| 5 | Results storage | In-memory / File / Database | TSV file in evidence/ | Simple, human-readable, git-trackable, consistent with autoresearch |

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed | Result |
|--------|-----------|----------|----------|--------|
| code-reviewer | CONDITIONAL PASS → PASS | 3 | 3 ✅ | All P0 addressed |
| backend-architect | CONDITIONAL PASS → PASS | 3 | 3 ✅ | All P0 addressed |

**P0 Issues Fixed:**
1. ✅ Safety anchor — added `git tag tad-opt-baseline-{task_id}` before loop + guard on reset
2. ✅ Scope enforcement — added `git diff --name-only` verification step (step c)
3. ✅ metric_pattern semantics — changed to regex with capture group, documented extraction method
4. ✅ Commit squash — added post-loop squash step (`git reset --soft` + single commit)

**P1 Issues Addressed:**
- ✅ Agent Team interaction — explicitly disabled when optimization_target present
- ✅ TDD interaction — autoresearch takes precedence for scope files
- ✅ Circuit breaker — all non-improvement types (✗, timeout, crash, parse_error) count
- ✅ Benchmark side effects — added `git checkout` after benchmark
- ✅ Directory creation — added `mkdir -p` step
- ✅ Timeout enforcement — specified Bash tool timeout parameter

**Final Status: Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-25
**Version**: 3.1.0
