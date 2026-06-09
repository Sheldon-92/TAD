# Execution Checklist (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)

execution_checklist:
  description: "每个 handoff 必须按此清单检查。这不是建议，是强制要求。"

  before_start:
    - "读完 handoff 全部内容 — 包括所有 AC 和 BLOCKING 要求"
    - "读取 handoff YAML frontmatter — 确认 task_type / e2e_required / research_required"
    - "确认所有 AC 都有实现计划（不能'先做完再说'）"
    - "如果某个 AC 你认为不适用 → PAUSE → 问人确认 → 不能自己决定跳过"
    # ⚠️ ANTI-RATIONALIZATION: "这个 AC 明显是模板遗留，实际不需要"
    # → AC 是 Alex 经 Socratic Inquiry 和专家审查确定的。Blake 没有删除 AC 的权力。

  during_development:
    task_type_branching:
      description: |
        UNIFIED §9.1-driven verification (TAD v3.1): Blake verifies EVERY task_type against the
        handoff's §9.1 Spec Compliance Checklist — each row's Verification Method is the actual
        check Blake runs. The per-type hints below are how Alex typically POPULATES §9.1; Blake
        executes whatever §9.1 declares (no hardcoded branch).
      code: "§9.1 typically has build + lint + tsc + test rows (Alex step1_ac_generation) — run each, all PASS to continue"
      yaml: "§9.1 typically has `python3 -c 'import yaml; yaml.safe_load(open(f))'` + 结构验证 + 编造=FAIL rows"
      research: "§9.1 typically has WebSearch 全部执行 + ≥3 来源 + 研究文件产出 rows"
      e2e: "§9.1 typically has 测试脚本执行 + evidence 文件产出到 .tad/evidence/ rows"
      mixed: "§9.1 mixes the above row types — run each row's Verification Method"
      rubric_or_judge_ac: |
        When a §9.1 AC is rubric/judge-based (task_type: deliverable, or any handoff whose §9.1
        references rubric scoring), Blake does NOT verify it with a plain grep and does NOT score
        it himself — he follows gate/SKILL.md's `## Rubric Evaluation Protocol`:
          - PRODUCER of research/content artifacts = Conductor-side (NotebookLM/WebSearch CANNOT
            run inside a Blake sub-agent — architecture.md "Research must be Conductor-side").
          - JUDGE = a SEPARATE fresh sub-agent (judge ≠ producer; self-scoring = VIOLATION, ~10-15% bias).
          - The §9.1 rubric row passes IFF the judge emits `verdict: PASS`.
        If a handoff is a PURE content/research production task (Blake has no code-shaped work to
        implement) → it was mis-routed; return to Alex / Conductor. Blake implements code-shaped
        handoffs and verifies §9.1 rows; he does not produce or self-score rubric artifacts.
      # ⚠️ ANTI-RATIONALIZATION: "这个任务虽然标了 research 但我已经知道答案了"
      # → task_type 是 Alex 设计时决策。Blake 执行时不判断。标了 research 就必须搜索。

    layer1_self_check:
      - "按 task_type_branching 执行对应检查"
      - "全部 PASS 才进 Layer 2"
      - "一项 FAIL → 执行 reflexion_step（见下方），不直接修复"
      # ⚠️ ANTI-RATIONALIZATION: "只有 lint warning 不是 error，可以跳过"
      # → Layer 1 标准是全部 PASS。Warning 也要修。

    reflexion_step:
      trigger: "Layer 1 整轮迭代 FAIL（收集所有失败后触发一次，不是每个检查项单独触发）"
      action: |
        BEFORE attempting any fix, pause and produce a structured diagnosis:

        1. Read the error output carefully
        2. Fill the reflection template (.tad/templates/reflexion-prompt.md):
           - what_failed: "{check_name}: {error_summary}"
           - root_cause_hypothesis: "{why this happened — not the error message, the CAUSE}"
           - revised_approach: "{what to do differently — not just 'fix the error'}"
           - confidence: "low | medium | high"
        3. Record the diagnosis in conversation context (reflection_history accumulates).
           ⚠️ Do NOT call any trace helper directly here. Imperative emission is unreliable
           (historically fired once in 328 events). The diagnosis is emitted OBSERVATIONALLY:
           at completion time you write each reflection as a block under the COMPLETION
           report's `## Reflexion History` section, and post-write-sync.sh parses those
           blocks into reflexion_diagnosis trace events (deduped per slug + what_failed).
        4. NOW proceed with fix, guided by revised_approach

      on_success_path: "Skip entirely — no reflection when Layer 1 passes"

      circuit_breaker_enhancement: |
        When circuit breaker fires (consecutive_same_error >= 3):
        Instead of generic "same error 3 times" message, include:

        ────────────────────────────
        ⚡ Circuit Breaker — Reflexion History

        Attempt 1: {what_failed}
          Hypothesis: {root_cause_hypothesis_1}
          Tried: {revised_approach_1}
          Result: Still failing

        Attempt 2: {what_failed}
          Hypothesis: {root_cause_hypothesis_2}
          Tried: {revised_approach_2}
          Result: Still failing

        Attempt 3: {what_failed}
          Hypothesis: {root_cause_hypothesis_3}
          Tried: {revised_approach_3}
          Result: Still failing

        Blake assessment: {design_issue | environment_issue | unknown}
        Recommendation: {escalate to Alex for redesign | human fix environment | need more context}
        ────────────────────────────

    layer2_expert_review:
      bullets:
        - "Group 0: spec-compliance-reviewer（AC 全满足）"
        - "Group 1: code-reviewer（P0=0, P1=0）"
        - "Group 2: test-runner + security-auditor + performance-optimizer（按 trigger 规则）"
        - "Expert 说 PASS 才算完成 — 不是 Blake 自己判断"
        # ⚠️ ANTI-RATIONALIZATION: "已经跑过 npm test 全部通过，再调 subagent 是重复劳动"
        # → Layer 1 的 npm test 只检查是否通过。test-runner subagent 额外检查覆盖率和测试质量。两者目的不同。

      # Phase 6-A.2 (2026-04-25): Hard requirement — Layer 2 reviewer count discipline.
      # Phase 1-5 累积 3 次 Blake 用 self-review.md 替代 backend-architect 的 drift。
      # 修复：≥2 distinct sub-agent invocations，substitution heuristics 不算。
      hard_requirement_distinct_reviewers:
        rule: |
          Layer 2 MUST invoke ≥2 DISTINCT sub-agents:
          - code-reviewer (REQUIRED — every Layer 2 round)
          - PLUS ≥1 from layer2-audit.sh's KNOWN_REVIEWERS whitelist (canonical
            single source of truth — see `.tad/hooks/lib/layer2-audit.sh`
            top-of-file array). Choose by task fit (e.g., backend-architect for
            architecture handoffs; security-auditor for auth/secrets;
            performance-optimizer for hot-path; ux-expert-reviewer for UI; etc.).
          # P6-A.2 v2 (2026-04-27): tier rule by handoff frontmatter task_type
          # Tier 1 (≥2 distinct): task_type=code OR task_type=mixed (current rigor)
          # Tier 2 (≥1 distinct, code-reviewer): task_type=yaml OR task_type=research OR task_type=doc-only
          # Tier e2e (≥2 distinct, test-runner+code-reviewer or equiv): task_type=e2e
          # Fallback: task_type missing/unrecognized → Tier 1 (safe default per NFR1+NFR4)
          # *express exception: existing exception_express below still applies (≥1 regardless of task_type)

        rationale_single_source: |
          BA-P0-2 fix (2026-04-25): SKILL does NOT inline-enumerate reviewer names.
          The canonical list lives in layer2-audit.sh KNOWN_REVIEWERS array. SKILL
          references that array. New reviewer types are added to the array, and
          SKILL automatically inherits — no SKILL/script drift.

        exception_express:
          rule: |
            *express path 仅需 code-reviewer (single expert OK per architecture.md
            "Express Handoff is NOT Review-Exemption" 2026-04-14 — exempts from
            ≥2 reviewer rule but NOT from ≥1 reviewer rule. AR-001 anchor
            preserved: *express still requires expert review, just not 2.).
          slug_detection: |
            layer2-audit.sh detects *express via word-boundary case matching:
              case "$slug" in express|*-express|*-express-*|express-*) ;; esac
            BA-P0-3 fix: NOT via task_type frontmatter (express is path-state,
            not in task_type enum {code|yaml|research|e2e|mixed|doc-only}).
            CR-P0-6 fix: word-boundary defends against expression/compress/espresso
            false-positives.
          slug_convention: |
            (2026-05-31, mirrors alex/SKILL.md express_path_protocol.slug_convention)
            An *express handoff slug MUST contain the token `express` so the
            word-boundary detection above fires. If Alex names an *express handoff
            without `express` in the slug (e.g. `bugfix-foo` + task_type=code),
            is_express_slug() returns false → audit treats it as Standard Tier-1
            and emits a FALSE ≥2-reviewer WARN, even though *express legitimately
            keeps only ≥1 code-reviewer. Convention is doc-only — audit logic is
            already correct and MUST NOT be changed.

        forbidden:
          - "self-review.md does NOT count as Layer 2 reviewer (Blake reviewing Blake = no second perspective)"
          - "feedback-integration.md does NOT count (synthesis doc, not review)"
          - "gate3-verdict.md does NOT count (Blake's own gate verdict, not external review)"
          - "Substituting domain expert with self-review = VIOLATION (AR-001 attack surface — Phase 1-5 drift root cause)"

        enforcement: "prompt-level-only via Blake SKILL text + layer2-audit.sh advisory CLI"

        forbidden_implementations:
          # 5 items per BA-P0-1 baseline; symmetric to Phase 3/4/5 forbidden_implementations blocks
          - "MUST NOT register PreToolUse hook to count reviewers"
          - "MUST NOT add to .claude/settings.json"
          - "MUST NOT return deny exit code from layer2-audit.sh — it remains advisory CLI exit 0/1/2"
          - "Anti-AR-001: 'this task is simple, code-reviewer covers it' is forbidden interpretation for non-*express paths — must add ≥1 domain expert by task fit"
          - "MUST NOT couple Layer 2 reviewer count to step4c audit script — Blake invokes sub-agents based on judgment; audit is downstream advisory, not gate"

      # L6 (2026-04-27 v3): narrow-scope mandate for Layer 2 sub-agent invocations.
      # Symmetric with Alex SKILL expert_prompt_template — Blake's Layer 2 reviewers
      # must be invoked with focused context (diff + §6 + §9), not full handoff.
      expert_prompt_template:
        rule: |
          Layer 2 sub-agent invocations MUST follow narrow-scope template:

          REQUIRED READS:
          - Diff of THIS handoff's implementation changes (git diff <range>)
          - {handoff_path} §6 (Implementation Steps) — what Blake intended to do
          - {handoff_path} §9 (Acceptance Criteria) — what Blake claims is done
          - Specific changed files (already in diff)

          OPTIONAL READS (only if needed):
          - Other handoff sections only if REQUIRED reads insufficient

          EXPLICIT BLAST-RADIUS CHECKS (per handoff §10 specific patterns):
          - For backend-architect: targeted grep for downstream consumers of
            changed APIs/symbols if §10 lists relevant patterns
          - For code-reviewer: re-verify each AC's verification command against
            Blake's actual diff

          NOT ALLOWED:
          - Free-explore wider codebase outside REQUIRED + OPTIONAL + §10 patterns
          - Reading full handoff if §6 + §9 + diff is sufficient

        rationale: |
          Same as Alex SKILL expert_prompt_template (L6 narrow-scope) — saves ~50%
          per review (115K → 50-60K) without reducing P0 finding rate. Blake's
          post-impl reviews catch DIFFERENT P0 classes than Alex Gate 2 (blast
          radius / out-of-scope consumers per Phase 6-A 2026-04-27 lesson) — both
          still load-bearing, just narrower in context per invocation.

        enforcement: "prompt-level-only via Blake SKILL text"

        forbidden_implementations:
          - "MUST NOT register hook to enforce narrow-scope via tool blocking"
          - "MUST NOT add to .claude/settings.json"
          - "Anti-AR-001: 'narrow scope = skip review' is forbidden interpretation — narrow scope ≠ shallow review"

    research_compliance:
      - "如果 handoff frontmatter research_required: yes → 必须执行搜索"
      - "搜索词必须全部执行 → Search Log 证明"
      - "不能用 LLM 知识替代搜索（'我已经知道了'不是跳过研究的理由）"
      - "研究产出文件必须写到 handoff 指定路径"
      # ⚠️ ANTI-RATIONALIZATION: "这些工具我都用过，不需要再搜索了"
      # → 研究的目的不只是获取信息，还有发现新工具和验证假设。LLM 训练数据有截止日期。

    e2e_compliance:
      - "如果 handoff frontmatter e2e_required: yes → 必须执行 E2E 测试"
      - "E2E 结果必须写入 .tad/evidence/ — Gate 3 Hook 将检查"
      - "不能自己决定'太简单不需要 E2E' — 这个决策已由 Alex 做出"
      # ⚠️ ANTI-RATIONALIZATION: "E2E 环境没配好，先跳过提交再说"
      # → 环境问题 = PAUSE 问人，不是跳过。

  after_development:
    - "*complete 创建 COMPLETION report — 必须使用更新后的模板（含 Knowledge Assessment + Evidence Checklist）"
    - "Evidence Checklist 中 required 项全部勾选 — 缺一项 Gate 3 不可通过"
    - "Knowledge Assessment 必须回答 Yes/No — 留空 = VIOLATION"
    - "/gate 3 正式质量检查 — 不能自己说 'Gate 3 Passed'"
    - "生成 Alex 消息"
    # ⚠️ ANTI-RATIONALIZATION: "代码写完且通过测试了，Completion Report 只是文书工作"
    # → Report 迫使 Blake 显式对比 handoff 计划 vs 实际交付。没有 Report = 没有偏差检测。

  absolute_forbidden:
    - "❌ 不能自己决定跳过任何 handoff AC（必须问人）"
    - "❌ 不能为了速度跳过研究、E2E、Layer 2"
    - "❌ 不能在 agent prompt 里写 'skip Phase X'"
    - "❌ 不能在没有 evidence 的情况下声称 Gate 3 Passed"
    - "❌ 不能编造 GitHub URL 或仓库名"
    - "❌ 不能忽略 handoff frontmatter 的 task_type / e2e_required / research_required"

