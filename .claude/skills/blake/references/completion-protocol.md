# Completion Protocol (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)

completion_protocol:
  # ⚠️ ANTI-RATIONALIZATION: "代码写完且通过测试了，Completion Report 只是文书工作"
  # → Report 迫使 Blake 显式对比 handoff 计划 vs 实际交付。没有 Report = 没有偏差检测。
  step1: "使用 *develop 启动 Ralph Loop"
  step2: "通过 Layer 1 自检（build, test, lint, tsc）"
  step3: "通过 Layer 2 专家审查（spec-compliance → code-reviewer → parallel experts）"
  step3b: "验收标准验证：为 Handoff 每条 Acceptance Criteria 生成并执行可运行验证（详见 acceptance-verification-guide）"
  step3c: "Git commit + evidence ls-check (Phase 3 anchor B-01) + Slug Contract (layer2-audit 2026-04-15): BEFORE git add, run `ls -la` on every path listed in handoff's Required Evidence Manifest §1.4 — if any required file is missing, ABORT commit and escalate. **SLUG CONTRACT (MANDATORY)**: Blake MUST write reviewer artifacts to `.tad/evidence/reviews/blake/<slug-from-handoff-filename>/` where `<slug-from-handoff-filename>` is the EXACT string captured by regex `^(HANDOFF|COMPLETION)-\\d{8}-(.+)\\.md$` group $2 — no abbreviation, no case change, no suffix. Alex `acceptance_protocol.step4c` runs layer2-audit.sh against this exact slug; a mismatch → 红字警告 in verdict. Then: git add（opt-out 策略：包含所有变更，排除 .tad/active/handoffs/ 和 .tad/logs/）→ 自动生成 commit message（格式：feat(TAD): implement {handoff-slug} [Gate 3 pending]）→ git commit → 记录 commit hash。如果无变更（doc-only handoff）→ WARN 并记录 commit_hash: NONE。如果 git 命令失败（pre-commit hook、权限等）→ 修复并重试，3 次失败后 escalate to human。"
  step4: "执行 Gate 3 v2 (Implementation & Integration) - 包含 Knowledge Assessment"
  step4b_gate3_verdict_marker:
    name: "Write gate3_verdict frontmatter marker (Gate 3 POST-STEP — observational trace)"
    blocking: false
    trigger: "AFTER Gate 3 produces its verdict (PASS/PARTIAL/FAIL) — NOT at initial COMPLETION write"
    action: |
      ⚠️ TIMING CONTRACT (FR2b): *complete writes the COMPLETION report BEFORE /gate 3 runs,
      so the verdict does not exist yet at creation time. Blake MUST therefore Edit the
      COMPLETION-*.md frontmatter as a Gate 3 POST-STEP (after the verdict is known) to set:
          gate3_verdict: <pass|fail|partial>
      Map Gate 3 v2 result → marker value: ✅ PASS→pass, ⚠️ PARTIAL→partial, ❌ FAIL→fail.
      Do NOT guess-fill at creation (an unverified placeholder would emit a false event).
      This Edit re-triggers post-write-sync.sh's COMPLETION arm, which parses the marker and
      emits the gate_result trace event (timing correct: verdict already known). The hook
      dedups task_completed (already emitted at creation) and emits gate_result once per
      (slug, day), updating only if the verdict value changes.
    note: "This is the agent-written stable marker the hook consumes. The hook NEVER parses COMPLETION prose for gate verdicts (prose is fragile + collides with template menu lines)."
  step5: "创建 completion-report.md（必须含 `## Reflexion History` 小节 + frontmatter `gate3_verdict:` 占位字段）"
  step5b_reflexion_history:
    name: "Write ## Reflexion History section (FR5 — observational reflexion emission)"
    blocking: false
    action: |
      The COMPLETION report MUST contain a `## Reflexion History` section.
      - If Layer 1 passed with zero failed iterations → write the section with an explicit
        "无 reflexion（Layer 1 一次通过）" note (no field lines → hook emits nothing).
      - For EACH Layer 1 reflexion that occurred during this handoff, write one block with
        these four field lines (the hook parses these literally — keep the field names exact):
            - what_failed: <check>: <error summary>
            - root_cause_hypothesis: <cause, not the error text>
            - revised_approach: <what you did differently>
            - confidence: <low|medium|high>
      post-write-sync.sh parses each block into a reflexion_diagnosis trace event, deduped
      per (slug, what_failed, day). This REPLACES the deleted imperative trace call (FR5).
  step_session_state_complete:
    name: "Update session-state.md Status to COMPLETE"
    action: |
      Read .tad/active/session-state.md (if exists).
      Write: update Status field → COMPLETE, Current Position → "Completion report written — awaiting Alex Gate 4"
      This enables Alex STEP 3.7 to detect the handoff is done and suggest *review/*accept.
    trigger: "After COMPLETION-*.md is written successfully"
  step6: "记录实际实现、遇到问题、与计划差异"
  step7: "更新 NEXT.md（标记完成项 [x]，添加新发现任务）"
  step8: "生成给 Alex 的信，通知人类传递到 Terminal 1"
  step8_generate_message: |
    Blake MUST auto-generate the following structured message after Gate 3 passes.
    All {placeholders} must be replaced with actual values.
    The message inside the code block is designed for the human to copy-paste directly to Terminal 1.

    ⚠️ ORDER REQUIREMENT (MANDATORY):
    The response output MUST be in this exact order:
      1. The 人话版 section (defined below) — appears FIRST
      2. The structured Alex message in code block — appears SECOND
    Rationale: user sees the explanation before the technical block they need to copy.

    ⚠️ raw-metric quote REQUIREMENT (Phase 3 anchor B-02):
    For every numeric claim in the message (p95 latency, coverage %, fixture pass count,
    byte counts, iteration counts), Blake MUST quote the source path + line number from
    raw evidence (e.g., `ci-bench-N100.tsv line 42: p95=47ms`), NOT aggregate summaries.
    Alex will raw-TSV-recompute from these citations in Gate 4 (per AR-005 + Phase 1c
    Gate 4 integrity lesson). Missing raw citations → Alex rejects the message.

    Output format (structured Alex message — appears SECOND in response):
    ---
    ## ✅ Implementation Complete

    我已生成一封给 Alex 的信，请复制下方内容到 Terminal 1：

    ```
    📨 Message from Blake (Terminal 2)
    ────────────────────────────────
    Task:      {task title from the handoff}
    Status:    ✅ Implementation Complete - Gate 3 Passed
    Git Commit: {commit_hash}
    Handoff:   .tad/active/handoffs/HANDOFF-{date}-{name}.md

    What was done:
    {bulleted list of key changes made, 3-5 items}

    Files changed:
    {list of files modified/created, one per line, prefixed with "  - "}

    Evidence:
    {list of evidence files created in .tad/evidence/reviews/, one per line}

    ⚠️ Notes:
    {any deviations from plan, known limitations, or things Alex should pay attention to - or "None"}

    Action: Please run Gate 4 (Acceptance) to verify and archive.
    ────────────────────────────────
    ```

    ⚠️ **我不会在这个 Terminal 调用 /alex**
    人类是 Alex 和 Blake 之间唯一的信息桥梁。
    ---

    ---

    PLAIN-LANGUAGE EXPLANATION (MANDATORY)

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

    After the structured Alex message above, the response MUST also include
    a plain-Chinese explanation section addressed to the human user (NOT Alex).
    As specified by ORDER REQUIREMENT, this section appears FIRST in the
    actual response output, even though it is documented here second.

    Heading: ## 🗣️ 人话版：我刚做了什么

    Audience: Someone who requested this work and now needs to understand
    what was delivered before passing it back to Alex for verification.
    Assume domain knowledge full, framework knowledge zero.

    Required content:
      1. 我刚做完什么 — what was just delivered, in everyday language
         (no jargon: Layer 2, Gate 3, completion report, hooks must be
         inline-defined or replaced with analogy)
      2. 关键决策的理由 — why I made the technical choices
         (analogies welcome: 锁/装修/考试/律师/医生 etc)
      3. Alex 接下来会做什么 + 你需要注意什么 — what verification Alex
         will do, what user should watch for in the report (so they can
         flag if anything looks off)

    Length scaling (per complexity):
      - Express tasks (1 step, 1-2 files): 1-2 short paragraphs
      - Standard tasks (multi-file feature): 3-4 paragraphs
      - Full TAD / Epic phase tasks: 4-5 paragraphs (max)
    Padding shorter tasks to hit a paragraph count = VIOLATION.

    Anti-theater rule (MANDATORY):
      The explanation MUST contain at least 1 sentence that would be FALSE
      if applied to a different completion. Generic completion descriptions
      that could fit any Blake completion = VIOLATION.

    Negative example (formulaic compliance — DO NOT do this):
      "我已经完成了所有任务，所有 AC 都通过了，请 Alex 验证并归档。"
      → Could fit ANY Blake completion. Zero task-specific content. VIOLATION.

    Positive example (task-specific, with concrete numbers):
      "我在 Phase 1a 跑了 3 个 experiment，最关键的是验证了 hook 真的能在
       Blake 试图发 'Message from Blake' 时把文件创建挡下来 —— 不是事后报警，
       是真挡住。性能 37 毫秒，远快于 200 毫秒的预算。
       接下来 Alex 会实际跑 cat results/exp1-decisions.tsv 等命令验证我的
       报告，不是看我的总结。如果 Alex 发现实际数字和我说的对不上，那就是
       我的报告有问题。"
      → Specific numbers (37ms vs 200ms), specific verification expectation,
        names actual mechanism.

    Purpose anchor (self-check before writing):
      "If the user reads this and Alex's verification fails, will the user
      understand the discrepancy enough to take a side?" If no → rewrite.

    violation_plain_language: "Sending Message to Alex without 人话版 section = VIOLATION. Wrong order (technical block before 人话版) = VIOLATION. Formulaic compliance (no task-specific content) = VIOLATION."
    ---
  step9: "Alex 执行 Gate 4 v2 (Acceptance) 后，将 handoff 移至 archive"

  # ⚠️ Ralph Loop 完整流程
  ralph_loop_flow:
    trigger: "*develop [task-id]"
    layer1: "Self-Check (max 15 retries, circuit breaker @ 3)"
    layer2: "Expert Review (max 5 rounds, escalation @ 3)"
    gate3_v2: "Expanded technical + integration checks"
    completion: "Report + handoff to Alex for Gate 4 v2"

  # ⚠️ step3b 详细执行协议 (Acceptance Verification)
  step3b_acceptance_verification:
    description: "为每条验收标准生成并执行可运行的验证"
    blocking: true
    trigger: "Ralph Loop Layer 2 通过后（即 step3 完成后）"
    guide: ".tad/templates/acceptance-verification-guide.md"
    relation_to_gate3_ac_driven: |
      TAD v3.1 note: Gate 3 itself now executes the handoff §9.1 Spec Compliance Checklist
      row-by-row (gate/SKILL.md Spec_Compliance_Verification) — that is the Gate-3-consumed
      verification source. This step3b (per-AC script + acceptance-verification-report.md) is
      SUPPLEMENTARY independent coverage; it is NOT a separate Gate 3 prerequisite gate. When
      §9.1 already encodes each AC's runnable Verification Method, step3b may simply RUN those
      same §9.1 commands and collect results — do not invent a second, divergent AC set.

    violations:
      - "跳过验收验证直接进 Gate 3 = VIOLATION"
      - "验收标准无对应验证 = VIOLATION"
      - "验证未实际执行（只写了没跑）= VIOLATION"

    process:
      step1_read_criteria:
        action: "读取 Handoff 的 Acceptance Criteria section"
        output: "验收标准列表（编号）"

      step2_generate_verifications:
        action: "为每条标准生成验证脚本（形式参考 guide: bash/test file）"
        output_dir: ".tad/evidence/acceptance-tests/{task_id}/"
        naming: "AC-{NN}-{brief-slug}.{sh|test.ts|test.py}"

      step3_execute:
        action: "执行所有验证脚本，收集结果"
        output: "acceptance-verification-report.md"

      step4_handle_failures:
        action: |
          IF any FAIL:
            场景 A (脚本 bug): 修脚本 → 仅重跑修复的验证
            场景 B (代码缺陷): 修代码 → 重跑 Ralph Loop Layer 1 → 重跑所有验证
          IF all PASS: 继续到 step4 (Gate 3)

    verification_quality:
      - "每个验证必须可独立运行（不依赖执行顺序）"
      - "每个验证必须产出明确的 PASS 或 FAIL"
      - "每个验证必须在 30 秒内完成（超时 = FAIL）"
      - "Bash 脚本: exit 0 = PASS, exit 1 = FAIL"
      - "测试文件使用项目测试框架，无框架时用 bash"

  # ⚠️ Knowledge Assessment 是 Gate 的一部分（BLOCKING）
  knowledge_assessment:
    blocking: true
    when: "Gate 3 v2 和 Gate 4 v2 执行时"
    requirement: "必须在 Gate 结果表格中填写 Knowledge Assessment 部分"
    location: ".tad/project-knowledge/{category}.md"

    must_answer:
      - "Q1: 是否有新发现？(Yes/No) — 如果有，属于哪个类别？一句话总结。"
      - "Q2: 是否有可复用的工作模式？(Yes/No) — Skillify 4-gate + Step 5 路由。"
      - "Q3: 是否发现 workflow 模式？(Yes/No) — 信号：执行中是否手动做了多 agent 编排（并行、竞争、循环），或现有 workflow 有缺陷？"

    violation: "Gate 结果表格缺少 Knowledge Assessment = Gate 无效 = VIOLATION"

    # Skillify candidate evaluation (after KA must_answer is filled)
    skillify_evaluation:
      trigger: "After knowledge_assessment must_answer is filled"
      action: |
        Evaluate whether the WORKING PATTERN (not individual lesson) from this
        implementation is reusable as a skill:
        1. Check 4 quality gates:
           - Reusable — pattern expected to recur (≥2 future use scenarios imaginable)
           - Non-trivial — multi-step workflow (≥3 steps), not a single rule
           - Verified — current task passed Gate 3 (pattern confirmed to work)
           - Not-already-captured — no overlap with existing .claude/skills/ or capability packs
        2. If all 4 pass → write SCAND-{date}-{slug}.md to .tad/active/skillify-candidates/
           using template .tad/templates/skillify-candidate-template.md
        2b. Step 5 — Pattern Type Routing (after 4-gate pass):
            Classify the pattern: does executing it require >1 agent coordinating?
            Yes → set `type: orchestration` in SCAND frontmatter → targets .workflow.js
            No  → set `type: judgment` in SCAND frontmatter → targets SKILL.md (existing path)
            Signal table:
            | Signal | Type | Target |
            |--------|------|--------|
            | "Evaluating X requires checking Y and Z" | judgment | SKILL.md |
            | "Per-AC verifier + skeptic each time" | orchestration | .workflow.js |
            | "N agents compete, judge selects, merge" | orchestration | .workflow.js |
            | "When rubric score is abnormal, check inter-rater reliability" | judgment | SKILL.md |
            | "Loop finding bugs until K dry rounds" | orchestration | .workflow.js |
            If type: orchestration, also note in "Proposed Skill Outline":
              "Target: .workflow.js (orchestration pattern, not SKILL.md)"
        3. Note in completion report Skillify Candidate row:
           "Yes: SCAND-{date}-{slug} (4/4 gates passed)"
        4. If any gate fails → fill completion report Skillify Candidate row:
           "No: {failed_gate_name}" (audit trail, no user interaction)
      blocking: false
      note: "This is a SUGGESTION — candidate goes to human review via Alex STEP 3.57, not auto-created skill"
      candidate_path: ".tad/active/skillify-candidates/SCAND-{YYYY-MM-DD}-{slug}.md"
      interacts_with_override: |
        skillify_evaluation runs AFTER knowledge_assessment must_answer is filled,
        regardless of whether KA was original or completion_knowledge_override-triggered.
        If skip_knowledge_assessment: yes AND no override marker → skillify_evaluation ALSO skips
        (no KA context = no pattern to evaluate).
      forbidden_implementations:
        - "MUST NOT auto-accept candidates without human review — the entire value proposition is human-in-the-loop"
        - "MUST NOT create .claude/skills/{slug}/SKILL.md from Blake — Blake writes candidates, Alex/human creates skills"
        - "MUST NOT make skillify_evaluation blocking — it is explicitly blocking: false"
        - "MUST NOT register hooks for skillify enforcement (per 2026-04-15 mechanical enforcement rejected principle)"
        - "MUST NOT auto-invoke *skillify without user explicit command (Alex side) — Blake's path is KA-only"

    workflow_evaluation:
      trigger: "After skillify_evaluation completes (regardless of skillify gate result)"
      action: |
        Q3 signal detection — scan the implementation process for:
        Signal words: "parallel agents", "fan-out", "tournament", "loop until",
        "competing approaches", "adversarial verify", "pairwise judge"
        
        Two sub-paths:
        a. "I manually orchestrated multi-agent coordination that worked well"
           → New workflow candidate: write SCAND-{date}-{slug}.md with type: orchestration
        b. "An existing workflow had a defect (bad prompt, too loose judgment, missing dimension)"
           → Record in completion report Q3 row: "Defect in {workflow_name}: {description}"
           → Alex creates bugfix handoff during *accept
        
        If no signal detected → Q3 row: "No: no workflow patterns observed"
      blocking: false
      interacts_with_skillify: |
        Skip ONLY if skillify_evaluation Step 5 explicitly routed a pattern to
        type: orchestration. If skillify gates 1-4 rejected the pattern (Step 5
        never ran), workflow_evaluation MUST still perform its own signal detection.
        Q3 serves as a safety net for orchestration patterns that don't pass
        skillify's quality gates.
      interacts_with_override: |
        Follows the same skip/override chain as skillify_evaluation:
        If skip_knowledge_assessment: yes AND no override marker → workflow_evaluation ALSO skips.
        If skip_knowledge_assessment: yes AND override marker present → workflow_evaluation runs.
      forbidden_implementations:
        - "MUST NOT write production .workflow.js directly — write SCAND draft candidates only, human confirms adoption"
        - "MUST NOT make workflow_evaluation a blocking gate — it is explicitly non-blocking"
        - "MUST NOT auto-create bugfix handoffs from sub-path (b) — record the defect, Alex creates handoff during *accept"
        - "MUST NOT register hooks for workflow_evaluation enforcement (per 2026-04-15 mechanical enforcement rejected principle)"

  violation: "完成实现但不创建 completion report = 绕过验收 = VIOLATION"

