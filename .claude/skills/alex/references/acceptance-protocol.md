# Acceptance Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

acceptance_protocol:
  # ⚠️ TAD v2.0 变更：技术审查已移至 Blake 的 Gate 3 v2
  # Alex 的 Gate 4 v2 只负责业务验收
  v2_note: |
    Gate 3 v2 (Blake): 所有技术检查 - build, test, lint, tsc + 专家审查
    Gate 4 v2 (Alex): 业务验收 - 需求符合度 + 用户确认 + 归档

  step1: "Blake 完成 Gate 3 v2 后，会创建 completion-report.md"
  step2: "Alex 确认 Gate 3 v2 已通过（检查 completion report）"
  step3: "执行 Gate 4 v2: 业务验收"
  step4:
    action: "【业务检查 — 逐条 AC 对照】"
    details: |
      1. 读取 handoff 的 Acceptance Criteria section
      2. 读取 Blake 的 completion report
      3. 逐条对照每个 AC：
         - AC 是否在 completion report 中标记完成？
         - AC 的验证方法是否有对应 evidence？
         - 如果 AC 标记未完成 → 记录为"未满足"
      4. 输出对照表：
         | AC# | 要求 | Blake 报告状态 | Evidence 存在 | Alex 判定 |
         |-----|------|---------------|--------------|----------|
      5. 如有任何 AC 未满足 → 不通过，退回 Blake
    blocking: true
    # ⚠️ ANTI-RATIONALIZATION: "仔细审查了 completion report，功能看起来完全符合"
    # → "看起来符合"≠实际验证。必须输出逐条对照表。
  step4b:
    action: "【Evidence 完整性检查】"
    details: |
      1. 读取 completion report 的 Evidence Checklist 节
      2. 检查 required 项是否全部勾选
      3. 读取 handoff YAML frontmatter:
         - 如果 e2e_required: yes → 确认 E2E evidence 路径存在
         - 如果 research_required: yes → 确认研究文件路径存在
      4. 如有 required evidence 缺失 → 不通过，退回 Blake
    blocking: true
  step4c:
    name: "Layer 2 Audit (红字警告，不阻塞) — smoke-alarm replacement for Epic 1 mechanical enforcement"
    action: |
      Epic 1 (Mechanical Enforcement) was cancelled 2026-04-15. This step is the
      monitoring-layer replacement: check Blake's reviewer artifacts actually exist
      on disk before Alex proceeds to Knowledge Assessment. This is a SMOKE ALARM
      — size/presence heuristic only — not a structural guarantee.

      1. Extract handoff slug from current filename. Use regex:
         ^(HANDOFF|COMPLETION)-\d{8}-([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])\.md$
         Capture group $2 is the slug. This whitelist is SYMMETRIC with
         layer2-audit.sh's own slug whitelist — SKILL rejects invalid slugs early,
         don't wait for the script's exit 2.

      2. If slug extraction fails (non-standard filename, e.g. single-char slug,
         slug with leading/trailing dash): acceptance report records
         "Layer 2 audit N/A: non-standard handoff filename — manual review required"
         and proceed to step7. Do NOT block.

      3. If slug valid: run
           bash .tad/hooks/lib/layer2-audit.sh <slug>
         capturing exit code + stderr (DISTINCT_COUNT field appears in stderr summary).

      3.5. **Read task_type** from handoff frontmatter (L1 tier rule, 2026-04-27).
           Active-first path (CR-P1-5): try `.tad/active/handoffs/HANDOFF-*-${slug}.md`
           via `ls` glob; if empty, fall back to `.tad/archive/handoffs/HANDOFF-*-${slug}.md`.
           Then extract:
             awk '/^---$/{c++; if(c>=2)exit; next} c==1 && /^task_type:/{print $2}' "$HANDOFF_FILE"
           Map TASK_TYPE → tier_threshold:
           - TASK_TYPE = `code` OR `mixed` → tier_threshold=2, tier_name="Tier 1"
           - TASK_TYPE = `yaml` OR `research` OR `doc-only` → tier_threshold=1, tier_name="Tier 2"
           - TASK_TYPE = `e2e` → tier_threshold=2, tier_name="Tier e2e (test-runner + code-reviewer)"
           - TASK_TYPE empty / unrecognized → tier_threshold=2, tier_name="Tier 1 (fallback)"
             (NFR1+NFR4 safe default — silent quality loss is more dangerous than silent token waste)
           - If slug matches *express pattern (already detected by layer2-audit.sh via
             word-boundary case match `express|*-express|*-express-*|express-*`) →
             tier_threshold=1, tier_name="Express (≥1 expert per existing exception)".
             *express exception takes precedence over task_type.

      4. Interpret:
         - exit 0 AND DISTINCT_COUNT ≥ tier_threshold → acceptance report: "✅ Layer 2 artifacts verified: .tad/evidence/reviews/blake/<slug>/ (N reviewer artifacts, DISTINCT_COUNT={n}/{tier_threshold}, tier={tier_name}, size-check is smoke-alarm heuristic)"
         - exit 0 AND DISTINCT_COUNT < tier_threshold → acceptance report inserts VISIBLE warning (before Gate 4 checklist):
             ```
             ⚠️ LAYER 2 TIER UNDER-MET
             DISTINCT_COUNT={n} < tier threshold {tier_threshold} for task_type={task_type} ({tier_name}).
             Required: ≥{tier_threshold} distinct sub-agents per Blake SKILL hard_requirement_distinct_reviewers tier rule.
             Human accepter: confirm tier assignment correct, or require Blake to add another reviewer.
             ```
         - exit 1  → acceptance report inserts at a VISIBLE position (before Gate 4 checklist):
             ```
             ⚠️ LAYER 2 AUDIT FAIL
             Blake completion report claimed Layer 2 review, but .tad/evidence/reviews/blake/<slug>/
             shows missing/under-sized reviewer artifacts.
             Reason (from script stderr): <stderr first line>
             Human accepter: confirm whether Blake actually ran expert review.
             If confirmed skipped, require Blake to re-do or document exception.
             ```
         - exit 2  → treat as "Layer 2 audit N/A" (slug invalid — should not happen
           if SKILL-layer regex did its job, but defense in depth).

      5. Continue to step7 regardless of exit code. Acceptance is NOT blocked by this
         check — is a smoke alarm, not a lock. Human accepter has final call.

      Rationale: This replaces the mechanical Blake→Write deny we would have had
      from Epic 1 PreToolUse hook. We lose fail-closed guarantee; we gain no
      dogfood paradox risk + trivial recovery if script itself breaks.
    blocking: false

  step4d:
    name: "trace-digest.sh advisory check (P5.4 2026-04-25 — smoke-alarm for skipped Domain Pack steps)"
    helper_script: ".tad/hooks/lib/trace-digest.sh <slug>"
    blocking: false  # advisory; mirrors step4c
    action: |
      Phase 5 P5.4 introduced per-handoff trace subdirectory at
      `.tad/evidence/traces/per-handoff/{slug}/{date}.jsonl`. Blake invokes
      trace-step.sh during Domain Pack capability execution and the hook
      records step_start / step_end events to both date-keyed and per-handoff
      paths. step4d reads the per-handoff trace and surfaces obvious anomalies
      (orphaned starts = step skipped mid-execution, all-failed step_ends =
      capability never recovered, etc.) BEFORE Alex declares Gate 4 acceptance.

      1. Extract handoff slug from current filename (same regex as step4c):
           ^(HANDOFF|COMPLETION)-\d{8}-([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])\.md$
         Capture group $2 is the slug.

      2. If slug extraction fails: acceptance report records
         "trace-digest N/A: non-standard handoff filename — manual review required"
         and proceed to step5. Do NOT block.

      3. If slug valid: run
           bash .tad/hooks/lib/trace-digest.sh <slug>
         capturing exit code + stdout + stderr.

      4. Interpret:
         - exit 0 (PASS) → acceptance report inserts trace summary:
             "✅ Trace digest: <step_start_count> step events captured;
              <orphan_count> orphans; <failed_count> failed. (trace-digest is
              smoke-alarm only — manual review for any orphan/failed > 0)"
         - exit 1 (FAIL — orphan/failed counts non-zero) → acceptance report
           inserts at VISIBLE position (before Gate 4 checklist):
             ```
             ⚠️ TRACE DIGEST WARN
             Per-handoff trace shows skipped/failed Domain Pack steps:
             <stderr from trace-digest.sh>
             Human accepter: confirm whether Blake actually completed all
             Domain Pack steps. If skipped legitimately, document exception
             in completion report.
             ```
         - exit 2 (advisory — trace dir missing OR slug invalid) → acceptance
           report records "trace-digest N/A: <reason from stderr>" and proceed.

      5. Continue to step5 regardless of exit code. Acceptance is NOT blocked
         by this check — smoke alarm only, mirrors step4c. Human accepter has
         final call.

      Rationale: trace-digest.sh is the Blake-side analog of step4c
      (Layer 2 reviewer artifacts). step4c verifies "Blake claimed expert
      review" — step4d verifies "Blake claimed Domain Pack execution".
      Together they provide a smoke-alarm replacement for the mechanical
      enforcement Epic 1 was rejected for (per architecture.md
      "Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15").

  step5: "【业务检查】确认用户面向的行为正确"
  step6: "【人类确认】演示/走查功能，获得用户确认"
  step7:
    name: "Knowledge Assessment — Write + Verify + raw-TSV recompute (with skip_KA branch routing — P3.3 2026-04-24)"
    blocking: true

    # Phase 3 P3.3 (2026-04-24): skip_knowledge_assessment frontmatter routing.
    # Three branches: skip-no-override / skip-with-override / no-skip.
    # Layer 2 audit (step4c) is ORTHOGONAL to skip_KA — runs regardless.
    layer_2_audit_decoupling:
      note: |
        step4c Layer 2 audit runs BEFORE step7 regardless of skip_knowledge_assessment value.
        Layer 2 verifies reviewer artifacts on disk (orthogonal concern to KA ceremony).
        Do NOT couple skip_KA logic to Layer 2 audit decisions.

    pre_check:
      action: |
        1. Read handoff frontmatter `skip_knowledge_assessment` field:
           - if field ABSENT → treat as `skip_knowledge_assessment: no` (backward compat for
             Phase 1+2 archive; existing behavior preserved)
           - if field == "yes" → proceed to override-marker check (step 2)
           - if field == "no" → branch_3 (full step7 A/B/C, existing behavior)
           - if field is any other value (typo, malformed) → WARN and treat as "no" (default safe)

        2. If field == "yes": Read Blake completion report at
           `.tad/active/handoffs/COMPLETION-{slug}.md`
           Locate "## Knowledge Assessment" section header (markdown level-2).
           This anchor matches the canonical template
           (`.tad/templates/completion-report.md`) and 10+ archived precedents.
           Grep for override marker within the first ~5 non-blank lines under that header
           (a small window — not strictly the first line — so a future template tweak
           that adds boilerplate above the marker doesn't break the match):
             pattern: `^\*\*knowledge_assessment_override:\s*unskip`
             - case-sensitive, line-anchored (no leading whitespace permitted)
             - must be bold markdown (literal `**...**`)
           Blake's emission contract (Blake SKILL completion_knowledge_override.override_marker_format):
             Marker is inserted AS A NEW LINE between the `## Knowledge Assessment` header
             and the existing template body. Alex's grep window covers exactly that
             insertion zone.
           If marker present → branch_2_skip_with_override
           If marker absent  → branch_1_skip_no_override

    branch_1_skip_no_override:
      condition: "skip_knowledge_assessment: yes AND no override marker"
      A_verify_blake_claims: SKIP
      B_raw_tsv_recompute: REQUIRED
      C_alex_own_discoveries: SKIP
      acceptance_report_text: |
        "✅ Knowledge Assessment skipped — handoff frontmatter declared trivial
        (skip_knowledge_assessment: yes); Blake did not override.
        Layer 2 audit + raw-TSV recompute still ran."
      semantic_note: |
        # P3.3 Phase 3 Audit Trail (CR-P1-2 spec divergence — documented Resolved):
        # Original handoff §3 P3.3.b spec said branch_1 A_verify_blake_claims: REQUIRED.
        # Implementation deviates to A=SKIP because there is logically nothing to verify
        # under skip — Blake had NO KA obligation, so there are no "Blake KA claims"
        # to read or cross-check. B (raw-TSV recompute for quantitative ACs) still runs
        # — that's the integrity guarantee, not A. C (Alex own discoveries) is also SKIP
        # since the handoff was declared trivial.
        # Net effect matches spec intent: Layer 2 + raw-TSV still run; only the redundant
        # claim-verification ceremony is skipped.

    branch_2_skip_with_override:
      condition: "skip_knowledge_assessment: yes AND override marker found"
      A_verify_blake_claims: REQUIRED
      B_raw_tsv_recompute: REQUIRED
      C_alex_own_discoveries: REQUIRED  # full execution despite skip flag
      acceptance_report_text: |
        "⚠️ Knowledge Assessment EXECUTED despite skip flag —
        Blake override marker found. Reason: {extracted from marker text}"
      if_section_missing:
        # BA-P2-1: override marker but no actual KA section content
        condition: "Override marker line exists but no substantive KA content follows"
        verdict: "Gate 4: PARTIAL"
        acceptance_report_text: |
          "⚠️ Gate 4: PARTIAL — KA override declared but section missing.
          Blake to add Knowledge Assessment content before final accept.
          User can resume *accept after Blake fills KA."
        action: "Do NOT FAIL Gate 4 — emit actionable feedback to Blake; *accept paused"

    branch_3_no_skip:
      condition: "skip_knowledge_assessment: no OR field absent (backward compat)"
      A_verify_blake_claims: REQUIRED
      B_raw_tsv_recompute: REQUIRED
      C_alex_own_discoveries: REQUIRED
      acceptance_report_text: |
        "✅ Knowledge Assessment fully executed (existing behavior)"

    # ─── Existing A/B/C semantics (unchanged from pre-P3.3) ───
    A_verify_blake_claims:
      action: |
        1. Read Blake's completion report → find "New discovery recorded: {path} → '{title}'"
        2. If Blake said "Yes": Read the referenced project-knowledge file, confirm the entry exists
        3. If entry missing → BLOCK *accept, inform user "Blake reported knowledge but didn't write it"

    B_raw_tsv_recompute:
      action: |
        MANDATORY per AR-005 rule (Phase 1c Gate 4 integrity lesson):
        For EVERY quantitative AC in the handoff (p95 latency, coverage %, fixture pass count,
        byte counts), Alex MUST re-derive the number from the raw evidence file
        (e.g., `.tad/evidence/perf/*.tsv`) using a one-liner (awk/jq) and paste the re-derived
        value alongside Blake's reported value. If mismatch → BLOCK *accept and ask Blake to
        reconcile. Rubber-stamping Blake's summary is a VIOLATION of Gate 4 integrity.

    C_alex_own_discoveries:
      action: |
        1. Evaluate: did this acceptance reveal business/architecture insights?
        2. If Yes → classify the discovery using prediction-error heuristic:
           a. "Does this fundamentally change how TAD works?" → L1-CANDIDATE
              → Write to .tad/project-knowledge/principles.md ONLY IF an active Epic
                references a principles-modification task. Otherwise:
              → "⚠️ L1 CANDIDATE detected: '{title}'. Promoting to principles.md requires
                an Epic-level TAD flow. Recording as L2 pattern for now."
              → Write to appropriate patterns/{theme}.md instead
              → Append to patterns/_index.md
           b. "Is this a reusable pattern for a class of problems?" → L2
              → Write to .tad/project-knowledge/patterns/{matched_theme}.md
              → Append one-line entry to patterns/_index.md
              → Match theme via keyword similarity to existing pattern file names
                (if no match, create a new theme file)
           c. "Is this evidence of a specific event?" → L3
              → Write to .tad/project-knowledge/incidents/{YYYY-MM}/{slug}.md
              → Append to incidents/_index.md with linked L1/L2 reference
           d. "Would a senior TAD user already know this?" → YES → skip writing
           e. "Is this an orchestration pattern that recurred?" → WORKFLOW-CANDIDATE
              → Same Skillify 4-gate + Step 5 as Blake side
              → Write SCAND candidate with appropriate type (judgment or orchestration)
              → Human confirms adoption via STEP 3.57 or *skillify accept
        3. Fill Gate 4 Knowledge Assessment table with: layer, file path, entry title

    separation_of_concerns: |
      - Blake writes implementation knowledge (Gate 3): tool behaviors, code patterns, workarounds
      - Alex writes business knowledge (Gate 4): requirement gaps, architecture decisions, process improvements

    # P3.3 forbidden_implementations (Anti-Epic-1 parity with P3.1 / P3.2)
    # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.skip_knowledge_assessment
    forbidden_implementations:
      - "MUST NOT auto-inject override marker via hook — Blake writes it manually based on judgment"
      - "MUST NOT couple skip_KA logic to Layer 2 audit (step4c) — they are orthogonal"

  step7d:
    name: "Capture Gate 4 deltas (gate4_delta — P5.1 2026-04-25)"
    blocking: false  # advisory; prompt-level reminder only
    purpose: |
      During step7 raw-TSV recompute (step B) and AC alignment (step A), Alex
      MAY discover gaps between what Alex's handoff claimed vs what Gate 4
      verification actually shows. Examples:
        - Alex said "p95 < 200ms achievable", Gate 4 measured p95 = 156ms
          BUT coverage dropped 3% (tradeoff Alex didn't surface)
        - Alex said "ai-evaluation pack covers OPRO", Gate 4 found pack lacks
          control-variable check (caught by Gate 3 reviewer, surfaced at Gate 4)
        - Alex said "scope = 8 files", Gate 4 review revealed 11 files actually
          touched (handoff §6 estimate inaccurate)
      These are NOT failures — they're "Alex 提议 vs Gate 4 reality" gaps that
      future *evolve queries can use to detect Alex-side estimation drift.

    action: |
      IF Alex during step7 (raw-TSV recompute / AC alignment / business
      acceptance) finds a substantive "Alex 提议 vs Gate 4 reality" gap,
      Alex MAY append an entry to the handoff frontmatter `gate4_delta:`
      list with these 4 keys:
        - field:        "<which AC# or handoff §, e.g. AC11 or §6 estimate>"
        - alex_said:    "<what handoff predicted, one sentence>"
        - actual:       "<what Gate 4 verification showed, one sentence>"
        - caught_by:    "<who/what surfaced the gap: 'Alex raw-TSV recompute',
                         'Gate 3 code-reviewer P0', 'human walkthrough', etc.>"

      Example entry (added to handoff frontmatter `gate4_delta:`):
      ```yaml
      gate4_delta:
        - field: "AC11"
          alex_said: "p95 < 200ms achievable with single-awk"
          actual: "p95 = 156ms but coverage dropped 3% — tradeoff caught at Gate 4"
          caught_by: "Alex raw-TSV recompute"
      ```

      Empty list (`gate4_delta: []`) is the default and is correct when no gaps
      surface. Alex MUST NOT fabricate gaps to fill the field — empty is
      semantically meaningful (means handoff predictions held up).

    enforcement: "prompt-level-only"  # See constraints.enforcement (global)
    # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.gate4_delta
    forbidden_implementations:
      - "MUST NOT auto-populate gate4_delta entries via any hook or script — Alex writes them based on judgment"
      - "MUST NOT block *accept on gate4_delta presence/absence — empty is semantically valid"
      - "MUST NOT couple gate4_delta to skip_knowledge_assessment — orthogonal concerns"

    rationale: |
      Phase 5 P5.1 builds the data-capture substrate for future *evolve cross-
      project drift detection. Without structured gate4_delta records, *evolve
      cannot tell "Alex over-promised on perf" from "tests genuinely flaky" —
      both look like AC failures in retrospect. The 4-key structure (field,
      alex_said, actual, caught_by) is the minimum *evolve needs to attribute
      drift to a source.

  step7b: "【配对测试评估】评估是否建议配对 E2E 测试（UI/用户流变更时建议，人类决定）"
  step8: "【强制】执行 *accept 命令完成归档流程"
  step9: "限制 active handoffs 不超过 3 个"

  # Gate 4 v2 不再需要调用技术专家（已在 Gate 3 v2 完成）
  technical_review_note: |
    ⚠️ TAD v2.0 变更：
    - code-reviewer, test-runner, security-auditor, performance-optimizer
    - 这些专家现在在 Blake 的 Gate 3 v2 中调用
    - Alex 的 Gate 4 v2 只负责业务验收，不重复技术审查

  gate4_v2_checklist:
    business_acceptance:
      - "实现符合 handoff 中定义的需求"
      - "用户面向的行为符合预期"
      - "无明显的用户体验退化"
    human_approval:
      - "演示/走查完成"
      - "用户确认满意"
    knowledge_assessment:
      - "A. 验证 Blake Gate 3 知识：读 completion report 引用 → 确认 project-knowledge 条目存在"
      - "B. Alex 自己的发现：(Yes/No) — Yes 时填写文件路径 + 条目标题"
      - "如果 A 和 B 都是 No，确认原因合理（不能只写 N/A）"
      # ⚠️ ANTI-RATIONALIZATION: "常规 CRUD，没有新发现，Knowledge Assessment 是浪费"
      # → 即使无新发现也必须显式写 "No" + 原因。跳过 = 表格不完整 = Gate 无效。

  violation: "不 review Blake 的 completion report 直接开新任务 = VIOLATION"
  violation2: "Gate 3 v2 未通过就执行 Gate 4 v2 = VIOLATION"
  violation3: "验收通过后不执行 *accept 归档 = VIOLATION"

