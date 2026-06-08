---
name: gate
description: Execute TAD Quality Gate. Gate 1 (pre-design), Gate 2 (pre-handoff), Gate 3 (post-implementation), Gate 4 (acceptance).
---

# /gate Command (Execute Quality Gate)
# Note: Gate 3/4 will NOT pass without their respective evidence files in .tad/evidence/reviews/

## 🎯 自动触发条件

**Claude 应主动调用此 skill 的场景：**

### 必须执行 Gate 的时机
- **Gate 1**: Alex 完成 3-5 轮需求挖掘后，**进入设计前**
- **Gate 2**: Alex 完成设计，**创建 handoff 前**
- **Gate 3**: Blake 完成实现，**提交代码前**
- **Gate 4**: Blake 完成集成，**交付用户前**

### ⚠️ 强制规则
```
规则 1: Alex 创建 handoff → 必须先执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
```

### 如何激活
```
场景 1: Alex 准备创建 handoff
Alex: 设计已完成，准备创建 handoff
     → 必须先调用 /gate 2
     [调用 Skill tool with skill="tad-gate" args="2"]

场景 2: Blake 实现完成
Blake: 代码已实现，准备提交
      → 必须先调用 /gate 3
      [调用 Skill tool with skill="tad-gate" args="3"]
```

**核心原则**: Gate 是强制检查点，不可跳过

---

When this command is triggered, execute the appropriate quality gate based on current context:

## Gate Detection and Execution

```
Quality Gate Execution
======================

Detecting current context...

Available Gates:
1. Gate 1: Requirements Clarity (Agent A - After elicitation)
2. Gate 2: Design Completeness (Agent A - Before handoff)
3. Gate 3: Implementation Quality (Agent B - After coding)
4. Gate 4: Integration Verification (Agent B - Before delivery)

Which gate to execute? (1-4):
```

## Gate 1: Requirements Clarity (Alex) - Optional Quick Check
```yaml
When: After requirement elicitation
Owner: Agent A (Alex)
Quick Check (3 items):
  - [ ] User confirmed understanding
  - [ ] Success criteria defined
  - [ ] Requirements documented
Output: Quick summary, no formal evidence required
```

## Gate 2: Design Completeness (Alex) - **MANDATORY** 🔴
```yaml
When: Before creating handoff (BLOCKING)
Owner: Agent A (Alex)
Critical Check (4 items):
  - [ ] Architecture complete
  - [ ] Components specified
  - [ ] Functions verified (exist in codebase)
  - [ ] Data flow mapped
Evidence: Record in handoff header
Output Format:
  ### Gate 2 Result
  | Item | Status | Note |
  |------|--------|------|
  | Architecture | ✅ Pass | ... |
  | Components | ✅ Pass | ... |
  | Functions | ⚠️ Partial | 缺少 xxx |
  | Data Flow | ✅ Pass | ... |
```

## Gate 3: Implementation Quality (Blake) - **MANDATORY** 🔴
> Gate 3 is UNIVERSAL across all task_types. Its checks come from the active handoff's
> §9.1 Spec Compliance Checklist (the PRIMARY VERIFICATION SOURCE), not from hardcoded
> tsc/test/lint. When any §9.1 AC references rubric scoring or an independent judge, the
> `## Rubric Evaluation Protocol` section below ACTIVATES.
```yaml
When: After implementation (BLOCKING)
Owner: Agent B (Blake)

# ⚠️ PREREQUISITE CHECK (BLOCKING)
Prerequisite:
  check: "Completion Report 是否存在？"
  location: ".tad/active/handoffs/COMPLETION-*.md"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法执行 - 缺少 Completion Report

      必须先创建 Completion Report 才能执行 Gate 3。
      请执行 *complete 命令创建报告，然后重新执行 Gate 3。

      Completion Report 应包含：
      - 实际完成的任务列表
      - 与 Handoff 计划的差异
      - 遇到的问题和解决方案
      - 测试执行结果
    result: "BLOCKED - 等待 Completion Report"

  if_exists:
    action: "继续执行 Gate 3 检查项"

# ⚠️ §9.1 SPEC COMPLIANCE VERIFICATION (BLOCKING) — PRIMARY VERIFICATION SOURCE
# This REPLACES the former hardcoded test-runner + Acceptance_Verification blocks.
# Gate 3 no longer hardcodes tsc/test/lint — those become Alex-generated §9.1 AC rows
# for dev projects (Backward Compatibility §10.3). The Gate executes whatever §9.1 declares.
Spec_Compliance_Verification:
  description: "Gate 3 的主验证源是 Handoff 的 §9.1 Spec Compliance Checklist 表格。逐行执行 Verification Method，对比 Expected Evidence，判断 pass/fail。"
  source: "active handoff 的 §9.1 Spec Compliance Checklist（每行：AC 编号 + Verification Method + Expected Evidence）"
  process:
    step1: "读取 active handoff 的 §9.1 表格"
    step2: "对每一行，实际执行其 Verification Method（grep/命令/脚本）"
    step3: "对比执行结果与 Expected Evidence → 标记该行 pass / fail"
    step4_decision: |
      IF 任何一行 FAIL → BLOCK Gate 3（不是 silent pass）。
      IF §9.1 含 test 类 AC（如 npm test / pytest）→ 运行该命令；可选调用 test-runner subagent 补充覆盖率视角。
      IF 所有行 pass → 继续 Gate 3 后续检查项。
  rubric_ac_trigger: |
    激活下方 ## Rubric Evaluation Protocol section，当满足以下任一（fail-safe — 强信号强制激活）：
      (a) §9.1 中存在引用 rubric 评分 / 独立 judge 的 AC（如 'spawn independent judge per Rubric Evaluation Protocol'）；OR
      (b) FRONTMATTER BACKSTOP: handoff frontmatter 是 `task_type: deliverable` 或有非空 `rubric_ref`。
    ⚠️ backstop 防止一个 rubric handoff 因为 Alex 没写触发短语就 bypass Judge_Not_Producer —— 强信号
    (task_type: deliverable / rubric_ref) 无条件激活 protocol，不依赖 §9.1 措辞是否精确。
  note: |
    dev 项目：Alex 在 §9.1 自动生成 npm test / npx tsc --noEmit / eslint / git diff --stat 等 AC 行（Alex step1_ac_generation）。
    非 dev 项目（播客/内容/电商）：§9.1 是域特定 AC（如 'python scripts/measure_consistency.py EP04 | grep overall' → > 70）。
    无论哪种，Gate 3 都逐行执行 §9.1 的 Verification Method —— 验证逻辑不再硬编码在 Gate 里。
  violations:
    - "VIOLATION: marking a §9.1 row 'pass' without actually executing its Verification Method (paper acceptance — the AC-driven gate's core anti-pattern)."
    - "VIOLATION: skipping a §9.1 row because it 'looks obviously true' — every row's Verification Method MUST run."

# ⚠️ §9.1 EMPTY GUARD (BLOCKING) — FR7 safety net for AC-driven switch
Spec_Compliance_Empty_Guard:
  check: "active handoff 的 §9.1 Spec Compliance Checklist 表格是否为空或缺失？"
  if_empty_or_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ No verification criteria found in §9.1. Alex must populate the Spec Compliance Checklist.

      从 hardcoded 切换到 AC-driven 后，空 §9.1 不能 silent pass —— 否则 Gate 失去全部检查内容。
      Alex 必须在 §9.1 填写至少一行可执行的 Verification Method，然后重新执行 Gate 3。
    rationale: "empty §9.1 → BLOCK 是 AC-driven 架构的必需安全网（VIOLATION：空 §9.1 当作 pass = Gate 形同虚设）。"

# ⚠️ DEV REGRESSION FLOOR (smoke alarm, WARN-not-BLOCK) — FR6 zero-regression backstop
# The empty guard only catches a FULLY empty §9.1. It does NOT catch a present-but-thin §9.1
# that omits the tsc/test/lint rows Alex was supposed to auto-generate (alex step1_ac_generation).
# Without this, a code handoff could PASS Gate 3 with tsc/test NEVER run — the old hardcoded
# test-runner floor's exact failure mode. Soft reminder per "Mechanical Enforcement Rejected on
# Single-User CLI" (smoke alarm, not a hook). Aligns with the project principle that a global/
# presence check is blind to must-cover loss when stripping also satisfies it.
Spec_Compliance_Dev_Floor:
  applies_when: "active handoff frontmatter task_type IN {code, mixed} AND §6 Files to Modify touches buildable files (.ts/.tsx/.js/.jsx/.py or a project with package.json/tsconfig/pyproject.toml)"
  check: "Does §9.1 contain at least one compile/test row? (a Verification Method with a tsc / test / pytest / build / lint token)"
  if_missing:
    action: "WARN (not BLOCK) — surface to human, do not silently pass"
    message: |
      ⚠️ task_type={code|mixed} handoff touches buildable files but §9.1 has no tsc/test/lint row.
      The AC-driven Gate cannot regression-check what §9.1 never declared. Confirm this is
      intentional (e.g. a pure-config edit) or ask Alex to add the missing dev-floor ACs
      (alex step1_ac_generation) before accepting Gate 3.
    not_blocking_rationale: "WARN not BLOCK — a legitimate pure-config/doc code-handoff may have no compile row. Human confirms; the gate must not hard-fail on a false positive (smoke alarm, not fire suppressor)."

# ⚠️ RISK TRANSLATION CHECK (Cognitive Firewall - Pillar 3)
Risk_Translation:
  description: "Detect fatal operations and translate code changes to business consequences"
  config: ".tad/config-cognitive.yaml → fatal_operations"
  blocking: "Only for critical severity (forced_review = true)"

  check_process:
    step0_handoff_intent: "Read handoff task descriptions — operations matching handoff intent are EXPECTED, not blocked (P0-3 FIX)"
    step1: "Read config-cognitive.yaml fatal_operations (universal_preset + project_custom)"
    step2: "Scan all changed files against safety_net paths and patterns"
    step2b: "For each match, cross-check against step0 handoff intent — skip EXPECTED operations"
    step3: "For remaining matches, generate risk translation (one-liner + risk card)"
    step4_decision: |
      IF critical matches found:
        → BLOCK Gate until human reviews and approves
        → Present risk cards to human
        → Human must explicitly approve: "I understand the risk, proceed"
      IF high matches found:
        → WARNING but not blocking
        → Include in Gate output for human awareness
      IF no matches:
        → PASS (note: "No fatal operations detected")

  output_format:
    gate3_addition: |
      #### Risk Translation (Cognitive Firewall)
      | # | Operation | Severity | Business Impact | Human Review |
      |---|-----------|----------|-----------------|--------------|
      | 1 | {op} | 🔴 Critical | {impact} | ✅ Approved / ⏳ Pending |

      {If critical items: show risk cards below the table}

# ⚠️ GIT COMMIT VERIFICATION CHECK (BLOCKING)
Git_Commit_Verification:
  check: "Implementation changes committed to git?"
  method: "Check completion report for commit hash, AND verify via git log"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 实现代码未 commit

      Blake 必须在 Gate 3 之前执行 git commit (step3c)。
      请执行 step3c (Git Commit Implementation) 然后重新执行 Gate 3。

  if_exists:
    checks:
      - "commit_hash is not empty and not 'NONE' (unless doc-only handoff)"
      - "If commit_hash is a real hash: verify via `git log --oneline -1 {hash}` returns valid output"
      - "If commit_hash is 'NONE': verify handoff has no 'Files to Create/Modify' entries (truly doc-only)"
    on_valid: "PASS"
    on_invalid: "BLOCK - commit hash not found in git history or doc-only claim invalid"

# Gate 3 检查项（Prerequisite, §9.1 Spec Compliance, Empty Guard 要求通过后执行）
Critical Check (5 items):
  - [ ] Code/deliverable complete (all handoff tasks done)
  - [ ] §9.1 Spec Compliance: every row's Verification Method executed and matches Expected Evidence (any FAIL → BLOCK; empty §9.1 → BLOCK)
  - [ ] Evidence files exist per the handoff's Required Evidence Manifest
  - [ ] Git commit done (commit hash recorded, or NONE for doc-only)
  - [ ] Knowledge Assessment complete (BLOCKING - must answer explicitly)
Evidence: Record in completion report + evidence file
Output Format:
  ### Gate 3 Result

  #### Prerequisite
  | Check | Status |
  |-------|--------|
  | Completion Report | ✅ 存在 |

  #### §9.1 Spec Compliance (PRIMARY VERIFICATION SOURCE)
  | AC# | Verification Method | Expected | Actual | Status |
  |-----|---------------------|----------|--------|--------|
  | AC1 | {command from §9.1} | {expected} | {actual} | ✅ Pass / ❌ Fail |
  | ... | (one row per §9.1 AC — empty §9.1 → BLOCK) | | | |

  #### Git Commit Verification
  | Check | Status | Detail |
  |-------|--------|--------|
  | Changes committed | ✅ / ❌ | commit_hash: {hash} or NONE (doc-only) |

  #### Quality Checks
  | Item | Status | Note |
  |------|--------|------|
  | Code/Deliverable Complete | ✅ Pass | ... |
  | §9.1 all rows pass | ✅ Pass | {P} pass, {F} fail (any fail → BLOCK) |
  | Evidence | ✅ Pass | Files exist per Required Evidence Manifest |

  #### Knowledge Assessment (MANDATORY - must answer)
  | Question | Answer | Evidence |
  |----------|--------|----------|
  | New discoveries? | ✅ Yes / ❌ No | — |
  | If Yes: written to | .tad/project-knowledge/{category}.md | Entry title: "### {title} - {date}" |
  | If No: reason | {why no new discovery} | — |

  ⚠️ "Yes" without a file path + entry title = Gate 3 FAIL.
  Blake must write directly to project-knowledge, NOT to completion report.
  Completion report references the entry, it does not contain the entry.

# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 3)
# 必须在 Gate 结果表格中显式回答，不可跳过
Knowledge_Assessment:
  blocking: true
  description: "Gate 3 无法 PASS 除非 Knowledge Assessment 表格已填写"

  mandatory_questions:
    - question: "本次实现是否有新发现？"
      must_answer: true
      options:
        - "✅ Yes - 有新发现"
        - "❌ No - 常规实现，无特殊发现"

    - question: "如果有，属于哪个类别？"
      must_answer: "if previous is Yes"
      options: "从 .tad/project-knowledge/ 目录读取"

    - question: "一句话总结"
      must_answer: true
      note: "即使无新发现，也要写明原因（如：常规 CRUD 实现）"

  evaluation_criteria:
    should_record_if:
      - "遇到了意外问题并解决（surprise factor）"
      - "发现了可复用的模式或反模式"
      - "做出了影响未来开发的技术决策"
      - "同类问题可能再次出现（recurrence）"
      - "花了 >30 分钟解决的问题"

    can_skip_if:
      - "纯粹的 CRUD 操作"
      - "完全按照 handoff 执行，无任何偏差"
      - "已有完全相同的记录"

  if_new_discovery:
    step1: "读取 .tad/project-knowledge/ 目录，列出所有可用类别"
    step2: "确定分类（或选择创建新类别）"
    step3: "写入对应的 .tad/project-knowledge/{category}.md"
    step4: "使用标准格式"
    step5_verify: "在 Gate 3 表格的 Evidence 列填写：文件路径 + 条目标题。无此信息 = Gate FAIL"

  completion_report_rule: |
    Completion report 的 Knowledge Assessment 节只写引用：
    "New discovery recorded: .tad/project-knowledge/{category}.md → '### {title}'"
    完整内容在 project-knowledge 文件中，不在 completion report 中重复。

  entry_format: |
    ### [简短标题] - [YYYY-MM-DD]
    - **Context**: 在做什么任务
    - **Discovery**: 发现了什么
    - **Action**: 建议未来如何处理

  violation: "Gate 3 结果表格中没有 Knowledge Assessment 部分 = VIOLATION = Gate 无效"

# ⚠️ GATE 3 POST-STEP — gate3_verdict marker (UNIVERSAL — all task_types)
# Promoted from the former deliverable-only marker to a universal post-step (P1 step 7).
# This runs for EVERY task_type (code / yaml / research / e2e / mixed / doc-only), not just rubric ACs.
Gate3_Verdict_Marker:
  who: |
    Whoever RAN Gate 3 writes the marker. Concretely:
      - code-shaped handoff (normal Blake path) → Blake writes it.
      - rubric AC inside a normal Blake-path handoff (no Conductor present) → Blake spawns the
        independent judge (judge ≠ Blake still holds — Blake does NOT self-score) and Blake writes
        the marker from the judge's verdict.
      - rubric AC under a Conductor/Epic lane → the Conductor/judge-orchestrator writes it.
    Single rule: the Gate 3 executor owns the marker; the judge is always a distinct sub-agent."
  when: "AFTER the Gate 3 verdict is computed, as a Gate 3 post-step (all task_types)."
  action: |
    Edit the completion report's `gate3_verdict:` frontmatter to the Gate 3 verdict
    LOWERCASED — one of pass | fail | partial (PARTIAL→partial). Mirrors blake
    completion_protocol.step4b_gate3_verdict_marker. For rubric/judge §9.1 ACs the value
    derives from the Rubric Evaluation Protocol's Verdict_Mapping output.
    Without this, emit_gate_result hits the empty-skip → ZERO gate_result telemetry
    (the paper-machine failure) for ANY task_type, not only deliverables.
  allowlist: "pass | fail | partial (post-write-sync.sh emits gate_result only for these exact lowercase values)."
  timing_note: "The completion report is written BEFORE the verdict exists, so gate3_verdict is empty at creation; the Gate 3 executor writes it as this post-step Edit, which re-triggers post-write-sync.sh to emit the gate_result event."

# ⚠️ POST-PASS ACTIONS
Post_Pass_Actions:
  trigger: "Gate 3 所有检查项 PASS（包括 Knowledge Assessment）"

  update_next_md:
    action: "更新 NEXT.md 反映实现完成状态"
    steps:
      - "标记已完成的实现任务为 [x]"
      - "添加测试/集成相关的后续任务"
      - "移动阻塞项到 Blocked 分类（如有）"
    format: "English only"
```

## Rubric Evaluation Protocol
> UNIVERSAL Gate section (not deliverable-only). ACTIVATES when any §9.1 AC references rubric
> scoring or an independent judge (e.g. a §9.1 AC whose Verification Method is "spawn independent
> judge per Rubric Evaluation Protocol against rubric X → verdict: PASS"). Applies to ANY task_type
> whose §9.1 contains such an AC — not just `task_type: deliverable`. When no §9.1 AC references a
> rubric/judge, this section is inert (skipped). The SAFETY logic below is migrated byte-exact from
> the former Gate 3 deliverable branch — it is the anti-self-scoring backbone for rubric-based ACs.
```yaml
Activation: "Triggered from Gate 3 Spec_Compliance_Verification.rubric_ac_trigger — a §9.1 AC references rubric scoring / independent judge. Otherwise inert (no rubric AC → skip)."
Owner: "Gate/Conductor executes (spawns the judge); the producing agent revises on PARTIAL/FAIL"

# ⚠️ judge ≠ producer (BLOCKING) — contract §C — anti-self-scoring backbone (migrated byte-exact)
Judge_Not_Producer:
  hard_rule: |
    The deliverable is produced by ONE agent (a Conductor-spawned producer sub-agent /
    the Conductor). The rubric score is computed by a SEPARATE judge sub-agent, spawned
    fresh by the gate/Conductor, whose prompt references ONLY {deliverable_paths} +
    {rubric_ref} + {pass_threshold}. judge ≠ producer is defined relative to THIS producer
    (if the Conductor itself produced, the judge MUST be a distinct sub-agent).
  why: "self-enhancement bias ~10-15% inflation when an agent scores its own output (ai-evaluation: Judge ≠ Optimizer/Producer). A self-scored rubric is validation theater."
  forbidden:
    - "VIOLATION: the producing agent (or same session/persona) computes the rubric score for its own deliverable."
    - "VIOLATION: passing the producer's reasoning / 'why this is good' notes into the judge prompt."
    - "VIOLATION: reusing the producer sub-agent (or its conversation) as the judge."
    - "VIOLATION (artifact-channel): the judge crediting self-assessment / quality-claim prose embedded INSIDE the artifact (self-praise, a producer-written self-scored rubric table). The judge scores on RUBRIC EVIDENCE it independently derives from the artifact's substance — NOT on the artifact's own claims about its quality. Self-praise in the artifact is ignored, not credited."
    - "VIOLATION: 'the producer already self-scored, so skip the judge' rationalization (the 'Express → exempt' anti-pattern applied to scoring)."

# ⚠️ RUBRIC + THRESHOLD RESOLUTION (BLOCKING) — contract §A.2 precedence
Rubric_Resolution:
  description: "Resolve rubric_ref + pass_threshold + partial_threshold + verdict_shape before spawning the judge"
  precedence:
    step1: "If handoff frontmatter sets rubric_ref and/or pass_threshold → frontmatter values WIN (per-handoff override)"
    step2: "Else fall back to .tad/capability-packs/deliverable-rubrics.yaml row keyed by frontmatter `pack`"
    step3: "If BOTH absent (no frontmatter value AND no registry row / null) → BLOCK Gate 3"
  registry_read: |
    Read the registry row for the handoff's `pack` (when falling back per step2):
      yq '.packs.<pack>' .tad/capability-packs/deliverable-rubrics.yaml
    Resolve from that row: rubric_ref, pass_threshold, partial_threshold, verdict_shape.
    (Frontmatter values, when present, override the corresponding registry fields per step1.)
  if_unresolved:
    action: "BLOCK Gate 3"
    message: "deliverable handoff has no resolvable rubric_ref + pass_threshold (set in frontmatter or register the pack in deliverable-rubrics.yaml). No silent default."
  partial_threshold: "from deliverable-rubrics.yaml row (default 0.60 if omitted)"
  # ⚠️ VERDICT SHAPE GUARD (BLOCKING) — unknown shape must never be silently mis-scored
  verdict_shape_guard:
    rule: "If the resolved verdict_shape NOT IN {weighted, categorical, checklist} → BLOCK Gate 3"
    supported: [weighted, categorical, checklist]
    message: "Unknown verdict_shape — supported: weighted (0-1 ladder), categorical (rigor band), checklist (export-spec pass/fail). An unrecognized shape must NOT be silently mis-scored."
    violation: "VIOLATION: silently scoring an unrecognized verdict_shape instead of BLOCKING — an unknown shape has no defined pass semantics."

# ⚠️ REQUIRED JUDGE SUBAGENT (BLOCKING) — independent judge for rubric/judge §9.1 ACs
Required_Judge:
  subagent: "judge (a FRESH independent sub-agent — NOT the producer)"
  action: "MUST spawn an independent judge sub-agent before a rubric/judge §9.1 AC can pass"
  # contract §B.3 — judge prompt is constructed from FILE PATHS ONLY:
  judge_inputs:
    - "deliverable_paths — artifact file path(s) to evaluate (judge reads them)"
    - "rubric_ref — rubric file path (judge reads + applies it)"
    - "pass_threshold — numeric threshold (resolved per Rubric_Resolution)"
  judge_prompt_constraint: |
    Blue-team framing: "You are an independent reviewer. Score the artifact at {deliverable_paths}
    against the rubric at {rubric_ref}. Report per the resolved verdict_shape (see judge_prompt_by_shape) + the machine-readable verdict line."
    The judge prompt MUST NOT include the producer's reasoning, chat transcript, persona,
    identity, or any "this is good because…" framing.
  judge_prompt_by_shape: |
    weighted   → "Report dimension scores + weighted average + verdict." (existing)
    categorical→ "Assign a RIGOR band (rigorous|partial|superficial) per the rubric, then map
                  to verdict. Score the RIGOR of the analysis ONLY — a rigorously-argued KILL
                  is rigorous; do NOT reward/punish the BUILD/PIVOT/KILL conclusion. Emit
                  `band:`, `content_verdict:` (recorded, not gate-determining), and `verdict:`."
    checklist  → "Evaluate each required/optional export-spec item pass/fail per the rubric,
                  then map to verdict. Emit the item table and `verdict:`."
    All shapes keep judge≠producer + file-paths-only (no producer reasoning/persona/identity).
  output_to: ".tad/evidence/reviews/{date}-rubric-eval-{task}.md"
  output_format:           # contract §B.4
    - "Scores table: | # | Dimension | Weight | Score (0-1) | Notes | (one row per rubric dimension)"
    - "weighted_score = Σ(score_i × weight_i) shown with the arithmetic"
    - "For verdict_shape categorical/checklist the weighted_score arithmetic bullet is replaced by the band line / item table respectively; the `verdict:` machine-readable line is REQUIRED for ALL shapes (shape-agnostic Gate 4 token)."
    - "MUST contain an EXACT machine-readable verdict line (own line, lowercase key, uppercase value, NO bold/emoji): `verdict: PASS` | `verdict: PARTIAL` | `verdict: FAIL` — this is the token Gate 4 greps (^verdict: ). The human-readable verdict prose may appear separately."
    - "Top-3 strengths / top-3 weaknesses (actionable)"
    - "MUST state: 'Judge: independent sub-agent; producer identity not provided.'"
  output_format_constraint: |
    ⚠️ The rubric-eval file's weaknesses MUST NOT use the ^#+ *P[0-9]- heading form
    (e.g. NOT '### P0-1', '## P1-2'). post-write-sync.sh expert_review_finding counts
    heading-form P<n>- labels → a P-label heading here self-triggers false P0/P1 telemetry
    (the documented "Parser Self-Trigger" failure). Use plain prose ("Weakness 1: …") or a
    | # | Weakness | Severity | table cell — never a P-label heading.
  if_not_called:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 缺少独立 judge 的 rubric-eval 审查
      必须 spawn 一个 fresh 独立 judge sub-agent，输出到
      .tad/evidence/reviews/{date}-rubric-eval-{task}.md，然后重新执行 Gate 3。

# ⚠️ VERDICT MAPPING — contract §B.5
Verdict_Mapping:
  rule: |
    IF weighted_score ≥ pass_threshold           → PASS
    ELSE IF weighted_score ≥ partial_threshold    → PARTIAL   (default partial_threshold = 0.60)
    ELSE                                          → FAIL
  # ── verdict_shape: categorical (e.g. product-thinking BUILD/PIVOT/KILL) ──
  categorical:
    rule: |
      The judge assigns a RIGOR band from the rubric: rigorous | partial | superficial.
      rigorous → PASS · partial → PARTIAL · superficial → FAIL
    rigor_independence: |
      ⚠️ The band scores the RIGOR of the analysis, NOT its content conclusion. For
      BUILD/PIVOT/KILL packs: a rigorously-argued KILL is `rigorous` (PASS); a hand-wavy
      BUILD is `superficial` (FAIL). The judge MUST NOT raise or lower the band based on
      whether the artifact concluded BUILD vs PIVOT vs KILL.
    decoupling_firewall: |
      (P1-1 hardening — structural, not just prose:)
      1. ORDER OF EMISSION: the judge MUST write `band:` WITH its per-dimension rigor
         justification BEFORE it states `content_verdict:`. The band is committed before the
         conclusion is named, so the conclusion cannot anchor the band.
      2. CONCLUSION-NEUTRAL CRITERIA: the rubric's band criteria (Phase 2) MUST be phrased
         about rigor (evidence depth, fatal-flaw coverage, FACT/ASSUMPTION discipline,
         adapter use) — NEVER "concludes BUILD" / "is optimistic".
      3. SWAP TEST (stated in the judge prompt): "If you flipped this artifact's final
         BUILD/PIVOT/KILL word and changed nothing else, would the band change? If yes, you
         are scoring the conclusion — re-score on rigor only."
    extra_output: |
      The rubric-eval ALSO emits (own lines, for traceability — NOT gate-determining):
        band: rigorous|partial|superficial
        content_verdict: BUILD|PIVOT|KILL   (the artifact's own conclusion; recorded, never maps to gate verdict)
      The machine-readable `verdict: PASS|PARTIAL|FAIL` line (derived from band) remains the Gate 4 token.
      ⚠️ `band:` (with justification) MUST appear ABOVE `content_verdict:` in the file (order firewall).
  # ── verdict_shape: checklist (e.g. ai-voice / video-creation export specs) ──
  checklist:
    malformed_guard: |
      (P1-2 guard:) the rubric MUST define ≥1 REQUIRED item. A checklist rubric with zero
      required items → BLOCK Gate 3 ("malformed checklist rubric — cannot ever FAIL, define
      ≥1 required item"). This prevents an all-optional rubric from becoming a gate that
      always PASSes.
    rule: |
      The rubric lists REQUIRED items + OPTIONAL items (export-spec pass/fail: dB / format / duration).
      ALL required pass                     → PASS
      ALL required pass, ≥1 optional fail   → PARTIAL
      ANY required fail                     → FAIL
    evidence_independence: |
      (P1-2 artifact-channel guard:) the judge derives each item's pass/fail from the
      artifact's substance / measurable specs it independently checks — NEVER from the
      artifact's own claim that it passed (same Judge_Not_Producer artifact-channel rule).
    extra_output: |
      The rubric-eval emits a per-item | item | required? | pass/fail | table; the
      `verdict:` line is derived per the rule above.
  on_pass: "Gate 3 proceeds (KA + git checks)."
  on_partial_or_fail: "BLOCK Gate 3; the producer (§B.6) revises and re-runs — a FRESH judge re-scores the revised artifact (each re-score is a new judge spawn)."

# Rubric AC integration (how a rubric/judge §9.1 AC resolves)
Rubric_AC_Integration:
  description: "When a §9.1 AC references a rubric/judge, its row pass/fail is decided by this protocol, not by a plain grep."
  flow: |
    1. Resolve rubric_ref + threshold + verdict_shape (Rubric_Resolution).
    2. Spawn the independent judge (Required_Judge) — judge ≠ producer (Judge_Not_Producer).
    3. Map judge output → verdict (Verdict_Mapping).
    4. The §9.1 AC passes IFF the judge's machine-readable line is `verdict: PASS`; PARTIAL/FAIL → that §9.1 row FAILs → BLOCK Gate 3.
  rubric_eval_evidence: ".tad/evidence/reviews/{date}-rubric-eval-{task}.md (verdict PASS) — listed in the handoff's Required Evidence Manifest."
  gate3_verdict: "The overall Gate 3 verdict is recorded via the universal Gate3_Verdict_Marker (Gate 3 code path post-step). The rubric judge verdict feeds that marker when the §9.1 ACs are rubric-based."
  note: "Prerequisite / Git Commit / Knowledge Assessment are NOT re-declared here — the universal Gate 3 block already enforces them for ALL task_types (no deliverable-only duplication)."
```

## Gate 4: Integration Verification (Blake + Alex) - **MANDATORY** 🔴
> Gate 4 is HYBRID and UNIVERSAL across all task_types (FR5): the structural subagent
> requirements (security-auditor / performance-optimizer / code-reviewer) are PRESERVED as
> BLOCKING role-enforcement for `task_type: code` and `task_type: mixed` — they are NOT
> AC-driven and cannot be skipped by omitting an AC. The business-acceptance checks are read
> from the handoff's §9 Acceptance Criteria. When the §9.1 ACs are rubric-based, the Gate 3
> rubric-eval `verdict: PASS` is the prerequisite (see Rubric Evaluation Protocol) and code
> subagents are not applicable (a report/audio/video artifact has no code surface).
```yaml
When: Before delivery (BLOCKING)
Owner: Agent B (Blake) executes, Agent A (Alex) verifies with subagents

# ⚠️ PREREQUISITE CHECK (BLOCKING)
Prerequisite:
  check: "Gate 3 是否已通过？"
  evidence: |
    Gate 3 PASS evidence exists. For code/mixed handoffs this is the §9.1-driven Gate 3
    result + any test/review evidence the §9.1 ACs declared. For rubric-based handoffs it is
    .tad/evidence/reviews/*-rubric-eval-*.md with the machine-readable line `verdict: PASS`.

  if_missing:
    action: "BLOCK Gate 4"
    message: |
      ⚠️ Gate 4 无法执行 - Gate 3 未完成

      必须先完成 Gate 3（§9.1 全行 pass，rubric AC 须 verdict: PASS）。
    result: "BLOCKED - 等待 Gate 3 完成"

# ⚠️ TASK-TYPE CONDITIONALITY (BLOCKING for code/mixed) — structural role enforcement, NOT AC-driven
Structural_Subagent_Conditionality:
  rule: "security-auditor / performance-optimizer / code-reviewer are BLOCKING-required when task_type IN {code, mixed}. They review a code surface — role separation, NOT derivable from §9 ACs."
  for_rubric_based: "When the handoff's §9.1 ACs are rubric-based (report/audio/video artifacts, no code surface), code subagents are NOT applicable; the Gate 3 rubric-eval verdict: PASS is the structural prerequisite instead. ux-expert-reviewer stays conditional ('if UI involved')."
  anti_skip: "VIOLATION: making the structural subagents AC-driven so Alex could skip security review by not writing an AC. They are role enforcement and MUST NOT be omittable via AC authoring."

# ⚠️ REQUIRED SUBAGENT CALLS (BLOCKING) — for task_type IN {code, mixed}
Required_Subagents:
  - subagent: "security-auditor"
    required: true
    template: ".tad/templates/output-formats/security-review-format.md"
    output_to: ".tad/evidence/reviews/{date}-security-review-{task}.md"

  - subagent: "performance-optimizer"
    required: true
    template: ".tad/templates/output-formats/performance-review-format.md"
    output_to: ".tad/evidence/reviews/{date}-performance-review-{task}.md"

  - subagent: "code-reviewer"
    required: true
    output_to: ".tad/evidence/reviews/{date}-code-review-{task}.md"

  - subagent: "ux-expert-reviewer"
    required: "if UI involved"
    output_to: ".tad/evidence/reviews/{date}-ux-review-{task}.md"

# Evidence File Naming Convention
Evidence_Naming:
  pattern: ".tad/evidence/reviews/{YYYY-MM-DD}-{type}-{brief-description}.md"
  types: [testing-review, security-review, performance-review, code-review, ux-review]
  examples:
    - "2026-02-01-testing-review-user-flow.md"
    - "2026-02-01-security-review-auth-api.md"
    - "2026-02-01-performance-review-menu-load.md"

# Recommended Templates (Non-blocking, for reference)
Recommended_Templates:
  - subagent: code-reviewer
    template: git-workflow-format
    when: "*review 命令"
  - subagent: refactor-specialist
    template: refactoring-review-format
    when: "重构任务"

  if_not_called:
    action: "BLOCK Gate 4"
    message: |
      ⚠️ Gate 4 无法通过 - 缺少必要的 subagent 审查

      必须调用以下 subagents 并生成审查报告：
      1. security-auditor → .tad/evidence/reviews/{date}-security-review-{task}.md
      2. performance-optimizer → .tad/evidence/reviews/{date}-performance-review-{task}.md

      执行步骤：
      1. 调用 security-auditor subagent，使用 security-review-format 模板
      2. 调用 performance-optimizer subagent，使用 performance-review-format 模板
      3. 保存输出到 .tad/evidence/reviews/ 目录
      4. 重新执行 Gate 4

# ⚠️ DECISION COMPLIANCE CHECK (Cognitive Firewall - Pillar 1 verification)
Decision_Compliance:
  description: "Verify implementation follows the technical decisions made by human during design"
  blocking: false  # Warning only, not blocking

  check_process:
    step1: "Read handoff Decision Summary section"
    step2: "For each recorded decision, verify implementation matches the chosen option"
    step3: "Flag any deviations"

  if_deviation:
    action: "WARNING - explain why implementation deviated from agreed decision"
    human_action: "Human decides: accept deviation or request fix"

  output_format:
    gate4_addition: |
      #### Decision Compliance Check
      | # | Decision from Handoff | Implementation Match | Status |
      |---|----------------------|---------------------|--------|
      | 1 | {decision title} | {does code match decision?} | ✅/❌ |

# Gate 4 检查项（Prerequisite 和 Subagent 要求通过后执行）
Critical Check (6 items):
  - [ ] Business acceptance: the handoff's §9 Acceptance Criteria are met (read from §9, not hardcoded)
  - [ ] Ready for user (no known blockers)
  - [ ] Security review evidence exists (task_type code/mixed — structural, BLOCKING)
  - [ ] Performance review evidence exists (task_type code/mixed — structural, BLOCKING)
  - [ ] All subagent feedback addressed
  - [ ] Knowledge Assessment complete (BLOCKING - must answer explicitly)
Evidence: Record in NEXT.md or completion report + evidence files
Business_Acceptance_Source: "The business-acceptance items above are read from the handoff §9 Acceptance Criteria. The structural security/performance/code review requirements are NOT from §9 — they are role enforcement for code/mixed (Structural_Subagent_Conditionality)."
Output Format:
  ### Gate 4 Result

  #### Prerequisite
  | Check | Status |
  |-------|--------|
  | Gate 3 Passed | ✅ Yes |
  | Gate 3 Evidence | ✅ Exists (§9.1-driven result for code/mixed, or rubric-eval verdict: PASS) |

  #### Subagent Evidence Check (BLOCKING)
  | Subagent | Required | Called | Evidence File | Status |
  |----------|----------|--------|---------------|--------|
  | security-auditor | ✅ Yes | ✅ Yes | {date}-security-review-{task}.md | ✅ Exists |
  | performance-optimizer | ✅ Yes | ✅ Yes | {date}-performance-review-{task}.md | ✅ Exists |
  | code-reviewer | ✅ Yes | ✅ Yes | {date}-code-review-{task}.md | ✅ Exists |
  | ux-expert-reviewer | Conditional | ... | ... | ... |

  #### Quality Checks
  | Item | Status | Note |
  |------|--------|------|
  | Integration | ✅ Pass | ... |
  | User Ready | ✅ Pass | ... |
  | Security Evidence | ✅ Pass | File exists |
  | Performance Evidence | ✅ Pass | File exists |
  | Feedback Addressed | ✅ Pass | ... |

  #### Knowledge Assessment (MANDATORY - must answer)
  | Question | Answer | Evidence |
  |----------|--------|----------|
  | New discoveries? | ✅ Yes / ❌ No | — |
  | If Yes: written to | .tad/project-knowledge/{category}.md | Entry title: "### {title} - {date}" |
  | If No: reason | {why no new discovery} | — |

  ⚠️ Alex writes business/architecture discoveries. Blake writes implementation discoveries.
  No overlap: Blake owns Gate 3 knowledge, Alex owns Gate 4 knowledge.
  Tiebreaker: HOW code works (tool quirks, build issues, API gotchas) → Blake Gate 3.
             WHY a design should change (architecture patterns, requirement gaps) → Alex Gate 4.

## ⚠️ Gate 4 Subagent Requirement (CRITICAL)
Alex 必须调用 subagents 进行实际验收，不可仅做纸面验收：

Required Subagents (MANDATORY - Gate will BLOCK without these):
  - security-auditor → Evidence in .tad/evidence/reviews/
  - performance-optimizer → Evidence in .tad/evidence/reviews/
  - code-reviewer (ALWAYS required)

Conditional Subagents:
  - ux-expert-reviewer (if UI involved)

Workflow:
  1. Blake completes Gate 3, creates completion report + testing evidence
  2. Blake calls security-auditor → saves security-review evidence
  3. Blake calls performance-optimizer → saves performance-review evidence
  4. Alex reads completion report and evidence files
  5. Alex calls code-reviewer (and ux-expert if UI involved)
  6. Alex summarizes all subagent feedback
  7. Alex decides: PASS / CONDITIONAL PASS / REJECT
  8. If PASS: Gate 4 complete, deliver to user

# Alex Acceptance Report Format (used in Gate 4)
Acceptance_Report_Format: |
  ## Alex 验收报告

  ### 1. Subagent 审查结果

  **code-reviewer 结果：**
  - 审查范围：[文件列表]
  - 发现问题：[问题数量]
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **security-auditor 结果：**
  - 审查范围：[模块/API]
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **performance-optimizer 结果：**（如适用）
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **ux-expert-reviewer 结果：**（如适用）
  - 审查范围：[页面/组件]
  - UX 评分：[分数/等级]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  ### 2. 综合验收结论
  - [ ] 代码质量符合标准
  - [ ] 用户体验达到要求
  - [ ] 安全性无明显漏洞
  - [ ] 性能满足预期

  **最终结论**：✅ 验收通过 / ⚠️ 条件通过（需修复 N 项）/ ❌ 打回重做

# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)
# 必须在 Gate 结果表格中显式回答，不可跳过
Knowledge_Assessment_Gate4:
  blocking: true
  description: "Gate 4 无法 PASS 除非 Knowledge Assessment 表格已填写"

  mandatory_questions:
    - question: "Blake Gate 3 知识是否已验证？（project-knowledge 文件中条目存在）"
      must_answer: true
      options:
        - "✅ Yes - 已验证条目存在"
        - "⚠️ Blake said Yes but entry missing - BLOCK"
        - "N/A - Blake said No (no discovery)"

    - question: "本次审查是否有新发现？"
      must_answer: true
      options:
        - "✅ Yes - 有新发现"
        - "❌ No - 常规审查，无特殊发现"

    - question: "如果有，属于哪个类别？"
      must_answer: "if previous is Yes"
      options: "从 .tad/project-knowledge/ 目录读取"

    - question: "一句话总结"
      must_answer: true
      note: "即使无新发现，也要写明原因"

  evaluation_criteria:
    should_record_if:
      - "发现了重复出现的代码质量问题"
      - "发现了新的安全/性能风险模式"
      - "做出了影响项目的架构决策"
      - "审查中发现的最佳实践或反模式"
      - "subagent 提出了重要的改进建议"

    can_skip_if:
      - "所有 subagent 结果都是 PASS，无特殊发现"
      - "已有完全相同的记录"

  if_new_discovery:
    step1: "读取 .tad/project-knowledge/ 目录，列出所有可用类别"
    step2: "确定分类（或选择创建新类别）"
    step3: "写入对应的 .tad/project-knowledge/{category}.md"
    step4: "使用标准格式"
    step5_verify: "在 Gate 4 表格的 Evidence 列填写：文件路径 + 条目标题。无此信息 = Gate FAIL"

  acceptance_report_rule: |
    Gate 4 验收报告的 Knowledge Assessment 节只写引用：
    "New discovery recorded: .tad/project-knowledge/{category}.md → '### {title}'"
    完整内容在 project-knowledge 文件中，不在验收报告中重复。

  violation: "Gate 4 结果表格中没有 Knowledge Assessment 部分 = VIOLATION = Gate 无效"

# ⚠️ POST-PASS ACTIONS
Post_Pass_Actions:
  trigger: "Gate 4 所有检查项 PASS（包括 Knowledge Assessment）"

  update_next_md:
    action: "更新 NEXT.md 反映交付完成状态"
    steps:
      - "标记已交付任务为 [x]"
      - "添加用户反馈收集任务（如适用）"
      - "清理已完成的相关任务"
    format: "English only"

  remind_accept:
    action: "提示 Alex 执行 *accept 完成归档流程"
    message: |
      Gate 4 通过！任务已准备交付。

      ⚠️ 提醒：Alex 需要执行 *accept 命令完成：
      - 评估配对测试（UI/用户流变更时建议）
      - 归档 handoff 和 completion report
      - 更新 PROJECT_CONTEXT.md
      - 确认 NEXT.md 状态
```

## Gate 4 — Rubric-Based Handoffs (universal, no separate branch)
> NOT a separate routing branch — the universal Gate 4 above is HYBRID and handles all
> task_types. This section only documents the rubric-lane SPECIFICS that the hybrid Gate 4
> applies when the handoff's §9.1 ACs are rubric-based (report/audio/video artifacts).
```yaml
# ⚠️ RUBRIC-LANE PREREQUISITE (BLOCKING) — when §9.1 ACs are rubric-based
Rubric_Gate4_Prerequisite:
  check: "Gate 3 rubric verdict 是否 PASS？"
  evidence: ".tad/evidence/reviews/*-rubric-eval-*.md exists with the exact machine-readable line `verdict: PASS`"
  verify_command: "grep -E '^verdict: PASS' .tad/evidence/reviews/*-rubric-eval-*.md"
  verify_note: "Greps the EXACT lowercase-key/uppercase-value token the judge writes (Rubric Evaluation Protocol Required_Judge.output_format). The bold/emoji human form `**Verdict**: ✅ PASS` is NOT matched by this anchor — the machine-readable line is required."
  shape_agnostic_note: "The `^verdict: PASS` token is shape-agnostic — weighted/categorical/checklist all emit it. Gate 4 needs no per-shape branch."
  if_missing:
    action: "BLOCK Gate 4"
    message: |
      ⚠️ Gate 4 无法执行 - 一个 rubric-based §9.1 AC 的 Gate 3 未通过
      必须先有 rubric-eval 证据且含 machine-readable 行 `verdict: PASS`。
    result: "BLOCKED - 等待 rubric AC 的 Gate 3 PASS"

# Evidence File Naming (rubric-eval) — rubric-eval is a DISTINCT type (own glob *-rubric-eval-*)
Evidence_Naming_RubricEval:
  pattern: ".tad/evidence/reviews/{YYYY-MM-DD}-{type}-{brief-description}.md"
  types: [rubric-eval]   # DISTINCT evidence type — MUST NOT be aliased to testing-review/code-review
  example: "2026-05-31-rubric-eval-soy-sauce-report.md"

# Code subagents N/A for rubric artifacts (handled by Structural_Subagent_Conditionality above)
Rubric_No_Code_Subagents:
  rule: "When §9.1 ACs are rubric-based (no code surface) the security/performance/code subagents are N/A; the rubric-eval verdict: PASS is the structural prerequisite. ux-expert-reviewer stays conditional ('if UI involved')."

# Business acceptance + Knowledge Assessment are the UNIVERSAL Gate 4 blocks above — not re-declared here.
# (The hybrid Gate 4 Knowledge_Assessment_Gate4 BLOCKING/VIOLATION rule applies to ALL task_types,
#  including rubric-based ones — no deliverable-only duplication.)
```

## Interactive Gate Execution

For each gate, use 0-9 options format:

```
Gate [N]: [Name] Execution

Status Check:
✅ [Criterion]: Pass
❌ [Criterion]: Fail - [Issue]
⚠️ [Criterion]: Warning - [Concern]

Please select action (0-8) or 9 to pass gate:
0. Review checklist again
1. Fix failing items
2. Collect more evidence
3. Run additional tests
4. Use sub-agent for help
5. Document issues found
6. Request clarification
7. Partial pass with notes
8. Fail gate (restart phase)
9. Pass gate (all criteria met)

Select 0-9:
```

## Violation Handling

```
⚠️ GATE VIOLATION DETECTED ⚠️
Type: Attempting to skip Gate [N]
Required: Must execute gate before proceeding
Action: BLOCKED until gate executed

To continue:
1. Execute gate properly
2. Address any failures
3. Collect evidence
4. Get pass result
```

# Universal Violation Recovery Protocol (applies to all gates)
Violation_Recovery:
  step1: "立即停止当前操作"
  step2: "调用正确的 agent/command（如应走 /blake 的用 /blake）"
  step3: "按规范流程从头重新执行"
  principle: "违反任何规则 → 停止 → 纠正 → 重做"

[[LLM: This command executes the appropriate quality gate based on current agent and project phase. Gates are mandatory checkpoints that ensure quality.]]