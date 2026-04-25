---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake", ".tad/templates", ".tad"]
skip_knowledge_assessment: no
---

# Handoff: Phase 3 — New Paths for Real Usage Patterns

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2) | **Date:** 2026-04-24
**Epic:** `.tad/active/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md` (Phase 3/6)
**Evidence Reference:** `.tad/evidence/learnings/HARVEST-20260424-cross-project.md`
**Priority:** P0
**Status:** Ready for Implementation (post expert review v2)
**Type:** Standard TAD (Phase handoff; not Express)

---

## 1. Executive Summary

Phase 3 把用户已经在手动绕开 TAD 仪式的两类需求**正式化为一等路径**：
- **P3.1** `*express` — Next Guest 项目 7 天 3 个 same-day supersede handoff 都标 "skip Socratic, skip epic review" — trivial 任务的合法快车道
- **P3.2** `*experiment` — toy OPRO/prompt-tuning 类任务塞进 implementation 模型违和；Gate 替换为实验有效性检查

外加：
- **P3.3** `skip_knowledge_assessment` frontmatter — 让 Alex 默认值 + Blake override unskip，给 trivial handoff 跳 KA 仪式的合法机制（含 Blake 安全网防 menu-snap SDK shape bug 类发现丢失）

**全 prompt-level enforcement** —— 同 anti_rationalization_registry 性质。三个新路径都有 `forbidden_implementations` 列表（anti-Epic-1 对称防御）。

**关键设计护栏：**
- *express **不是** AR-001 "review = exempt" 别名 — 必保留 ≥1 expert review (code-reviewer 必选)
- *express 不能由 Alex 在 step3 主动 pre-select 为 Recommended — 仅响应 user 显式输入
- *experiment Gate 是 **AUGMENT (additive)** 不是 **REPLACE** — 原 build/test/lint 仍 apply 于 harness 代码，5 个实验有效性检查是**附加**
- Audit Trail (P1.5) 在 *express 中**保留** — 它是 ≥1 review 的可审计证据

---

## 2. Epic Context

Phase 1 ✅ Done (commit 08e9e74) — drift detector / git-tracked / slug truncation / router filter / Audit Trail
Phase 2 ✅ Done (commit 0b2e25d) — grounded_in + Revalidated + stale-check + step1c grounding pass

Phase 3 与 1+2 完全独立。本 handoff dogfood Phase 2 step1c (§6 含 Grounded Against) + dogfood Phase 3 自身 frontmatter `skip_knowledge_assessment: no`（因为 Phase 必有 protocol 设计发现）。

---

## 3. Task Breakdown

### Task P3.1 — `*express` 路径正式化

**问题**（Next Guest active/handoffs 7 天 × 3 + my-openclaw `ntc-agents-md-slim`）: 用户在 handoff 顶部手动写 `Type: Express Bugfix (skip Socratic, skip epic review)` — 默认协议没正式 *express 路径，所以用户自创注释绕路。

#### P3.1.a — Alex SKILL `*express` 路径定义

`.claude/skills/alex/SKILL.md` 加新协议块：

```yaml
express_path_protocol:
  description: "Quick path for trivial bugfix / small UX polish. Skips ceremony, keeps ≥1 review."
  trigger:
    type: "user_explicit_only"
    activation_word: "*express"
    NOT_via_alex_suggestion: |
      Alex MUST NOT proactively recommend *express. Specifically:
      (a) MUST NOT add *express to adaptive_complexity_protocol step2 AskUserQuestion options
      (b) MUST NOT pre-select *express as Recommended (Option 1) in intent_router_protocol step3
          even if signal-word detection favors it (signal detection of express keywords routes to
          analyze with a 'looks small — start *analyze; user can downgrade by typing *express' note)
      (c) MUST NOT use AskUserQuestion to suggest *express in any other workflow step
      Reason: avoids anti-rationalization (AR-001) where Alex auto-downgrades scope to fit
      *express. User must explicitly type *express to opt in.
  scope_constraints:
    file_count_max: 3  # files in §6 Files to Modify / Create
    over_limit_action: |
      Use AskUserQuestion: "你的 *express 涉及 {N} 文件，超出 *express ≤3 文件硬上限。
      要降到 Standard TAD 还是拆成多个 *express?"
      Options:
        - "降到 Standard TAD (Recommended for >3 files)"
        - "拆成多个 *express handoffs (each ≤3 files)"
        - "我理解但坚持 *express 单 handoff (override — 解释原因)"
      override 选项需用户写明原因，**强制**记入 §11 Decision Summary 一行
      (Gate 2 检查若 §11 未含 override row → FAIL)
  required_steps:  # cannot be skipped — anti-AR-001 hard guarantee
    - "step1 draft creation"
    - "step1b frontmatter validation (含 git_tracked_dirs)"
    - "step1c grounding pass (P2.2 — Read 目标文件 head 50)"
    - "step2 expert review with ≥1 expert (code-reviewer 必选; ≥1 expert; 视场景可加第 2 个)"
    - "step4 Audit Trail integration (P1.5 dogfood — *express 仍含 Audit Trail，记录 ≥1 review 的可审计证据)"
    - "step5 Gate 2 check"
    - "step7 Blake message generation with 人话版"
    - "Gate 3 v2 (Blake side: build/test/lint + Layer 2 ≥1 expert)"
    - "Gate 4 v2 acceptance (Alex side)"
  skipped_steps:
    - "Socratic Inquiry Protocol (3-5 rounds)"
    - "Adaptive Complexity Protocol step2 (no scope choice)"
    - "Epic Phase Map evaluation (express handoffs not part of Epics)"
    - "Knowledge Assessment ceremony (skip_knowledge_assessment defaults to yes; Blake can override unskip per P3.3)"
  enforcement: "prompt-level-only"
  forbidden_implementations:
    - "MUST NOT register PreToolUse / UserPromptSubmit hook to gate *express"
    - "MUST NOT add to .claude/settings.json"
    - "MUST NOT return deny exit code from any wrapping script"
    - "Anti-AR-001: 'express = review-exempt' is a forbidden interpretation"
    - "MUST NOT auto-downgrade Standard TAD handoff to *express via any mechanism"
```

#### P3.1.b — Intent Router 集成（surgical, 无 step3 special case）

`.claude/skills/alex/SKILL.md` 的 `intent_router_protocol` 改动（**修正 v1 错误**：*express 走**现有的 step1 explicit-command bypass**，跟 *bug/*discuss/*idea/*learn/*analyze 同模式，**不**新增 step3 special case）：

- **step1 (Check Explicit Command)**: 加 `*express` 和 `*experiment` 到识别列表（现有逻辑：检测到显式命令 → 跳过 detection 直接路由）
- **step3 (User Confirmation)**: **NO new branch**。当用户输入 `*express`，step1 已经直接路由到 step4，step3 自动跳过（同 *bug 等现有逻辑）
- **step3 7-mode display strategy 扩展**（仅在 user 输入**模糊文本**时触发）:
  - 现有 5-mode display: Recommended + 2 by signal + analyze fallback
  - 7-mode 扩展: Recommended + 2 by signal + analyze (always)
  - ***express 永不 pre-selected as Recommended** — 即使 signal favors it，分类为 analyze with note "looks small — *analyze; you can downgrade by typing *express"
  - **AskUserQuestion 4-option 溢出处理**: 当候选 modes >4，按 priority_order tiebreaker (在 config-workflow.yaml.intent_modes.detection.priority_order) 选 3 个非 analyze + analyze 总在第 4 位
- **step4 (Route)**: 加 `express → Enter express_path_protocol`, `experiment → Enter experiment_path_protocol`
- **standby.enters_standby**: 加 "After *express completes (Gate 4 accept) → Enter standby" + 同 *experiment
- **path_transitions matrix（完整定义）**:
  ```yaml
  allowed:
    - from: express, to: analyze, trigger: "User says 'this turned out bigger than I thought'"
    - from: express, to: experiment, trigger: "User realizes the bugfix is actually an A/B test"
    - from: experiment, to: analyze, trigger: "Experiment results show this needs production design"
    # 现有 allowed 保留 (discuss → analyze, discuss → idea, bug → analyze, idea → analyze, learn → analyze, idea-promote → analyze)
  forbidden:
    - from: analyze, to: express, reason: "Once in Standard TAD with Socratic complete, downgrading to *express loses ceremony rationale (AR-001 attack surface)"
    - from: analyze, to: experiment, reason: "Same — analyze→experiment hides scope shift; user must explicit *cancel + new *experiment"
    - from: any, to: any (other than listed allowed), reason: "Default deny — explicit transitions only"
  ```

#### P3.1.c — config-workflow.yaml `intent_modes` 扩展

`.tad/config-workflow.yaml` 的 `intent_modes` block 加 `*express` 和 `*experiment` 条目（参考 line 603-669 现有结构）；`detection.priority_order` 加 `express`、`experiment`（顺序：bug > idea > experiment > express > discuss > learn > analyze）。

**AC:**
- [ ] AC-P3.1-a: Alex SKILL 含 `express_path_protocol` 完整 block (trigger 含 NOT_via_alex_suggestion 三条规则 / scope_constraints / required_steps / skipped_steps / forbidden_implementations 5 项)
- [ ] AC-P3.1-b: Intent Router step1 识别 `*express`（不新增 step3 special case，复用现有 explicit-command bypass）
- [ ] AC-P3.1-c: scope_constraints.over_limit_action AskUserQuestion 文字含 3 选项，含 override + §11 强制写理由
- [ ] AC-P3.1-d: required_steps 显式列出 ≥1 expert review（code-reviewer 必选）；anti-AR-001 文字明示
- [ ] AC-P3.1-e: enforcement = prompt-level-only；forbidden_implementations 列 5 项含 "MUST NOT auto-downgrade"
- [ ] AC-P3.1-f: Anti-Epic-1 mechanical grep — 见 §5 中的 anti_epic1_compliance（非 greedy 模式）
- [ ] AC-P3.1-g: 文档化 `*express` 何时合适（Next Guest 案例）vs 不合适（架构变更 / 多模块）
- [ ] AC-P3.1-h: **AR-001 mechanical anchor (CR-P0-4)** — `grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer\|code-reviewer.*expert review'` 返回 ≥1。SKILL-text grep 不是 runtime hook，纯 prompt-level
- [ ] AC-P3.1-i: **scope override 强制 §11 (CR-P1-4)** — fixture: 5-file *express handoff 选 override → §11 必含 Decision row + 用户原因；缺则 Gate 2 FAIL
- [ ] AC-P3.1-j: **step3 不 pre-select *express (BA-P1-2)** — fixture: 模糊 prompt "fix small thing" + signal detection 倾向 express → step3 显示 Recommended = analyze (不是 express)
- [ ] AC-P3.1-k: **step3 7-mode display (BA-P0-1)** — fixture: signal counts trigger 5+ modes → 选 3 非 analyze + analyze 在第 4 位；按 priority_order 决定 tiebreaker
- [ ] AC-P3.1-l: path_transitions matrix 含完整 allowed (3 new) + forbidden (analyze → express / experiment) 显式

---

### Task P3.2 — `*experiment` mode

**问题**（toy `architecture.md:172-176`）: OPRO / prompt tuning / A-B / benchmark 类任务塞进 handoff-implementation 模型违和。toy OPRO 用 Claude Sonnet 同时做 judge + optimizer（已知 self-enhancement bias 源），文档里写 "acknowledged rather than mitigated" — TAD 没机制 review 实验方法论。

#### P3.2.a — Alex SKILL `*experiment` 路径定义

`.claude/skills/alex/SKILL.md` 加：

```yaml
experiment_path_protocol:
  description: "For OPRO / A-B test / benchmark / prompt tuning / eval-loop tasks. Gates ADD experiment-validity checks; original Gate 3 still applies to harness code."
  trigger:
    type: "user_explicit_OR_frontmatter"
    activation_word: "*experiment"
    frontmatter_field: "task_type=experiment"
    note: |
      User can say *experiment to enter (via existing step1 explicit-command bypass).
      OR Alex during *analyze can set task_type=experiment based on signals (then path is
      Standard *analyze with experiment_specific_gates AUGMENTING Gate 3/4 criteria).
    auto_detection_signals:
      - "task involves OPRO / A-B / benchmark / eval-loop"
      - "comparing prompts/models/configs and measuring against rubric"
      - "iteratively tuning generator/optimizer/judge model"
  alex_evaluation_signals:
    when_to_suggest_task_type_experiment:
      - "Socratic answers mention 'iteratively', 'rubric', 'A vs B', 'optimize prompt', 'eval against baseline'"
      - "Domain Pack ai-evaluation or ai-prompt-engineering matches"
      - "Output measured by score not by 'feature works'"
    note: "Alex MAY set task_type=experiment in frontmatter during *analyze drafting; Alex MUST NOT bypass *analyze and route directly to *experiment without user explicit input"
  domain_pack_auto_load:
    rule: "experiment_path_protocol step1 MUST Read .tad/domains/ai-evaluation.yaml at start of drafting"
    rationale: |
      *experiment is a router mode, not a UserPromptSubmit keyword pattern; the existing
      Domain Pack loader (keywords.yaml) does not auto-fire on protocol routing. Without
      this explicit Read, *experiment users get workflow without tools — exactly what
      the protocol is meant to prevent.
    fallback: "If ai-evaluation.yaml missing → emit WARN 'ai-evaluation pack not found; experiment_path_protocol will use default workflow only' and continue"
  required_steps:
    - "Standard TAD steps (Socratic / step0_5 / step1 / step1b / step1c) — DO follow"
    - "step1 explicit Read of .tad/domains/ai-evaluation.yaml (per domain_pack_auto_load)"
    - "step1 §6 may be 'Experiment Setup' (rubric / fixture / generator-judge config) instead of 'Files to Modify'"
    - "step2 expert review — recommend security-auditor SKIP unless safety-critical (toy OPRO 非 safety); add product-expert IF stakeholder validation matters"
  experiment_specific_gates:
    gate3_focus_AUGMENTATION:  # ⚠️ AUGMENT not REPLACE (BA-P0-2)
      semantics: "Original Gate 3 v2 (build/test/lint/coverage) STILL APPLIES to any harness/runner code in the experiment. Following 5 are ADDITIONAL — both layers must PASS."
      additional_checks:
        1. "Control variables clear (which model is generator? judge? optimizer? all 3 different or some shared?)"
        2. "Self-enhancement bias mitigated (judge ≠ optimizer; or documented as accepted limitation with rationale)"
        3. "Baseline established (what's the 'before optimization' score; how was it measured)"
        4. "Reproducibility (rubric saved, fixtures saved, hyperparams saved)"
        5. "Generator model = production model (toy OPRO 教训: 别在 Qwen Plus 上调出 prompt 然后部署到 qwen3-omni-flash)"
    gate4_focus_AUGMENTATION:  # ⚠️ AUGMENT not REPLACE
      semantics: "Original Gate 4 v2 (user-facing behavior + business AC) STILL APPLIES. Following 4 are ADDITIONAL."
      additional_checks:
        1. "Score improvement statistically meaningful (not within noise)"
        2. "Improvement transfers to production model (re-eval on production model if generator differed)"
        3. "No regression on holdout / negative test cases"
        4. "Discoveries (positive findings + anti-patterns) captured in knowledge_updates"
  required_evidence_manifest_template:
    experiment_design: ".tad/evidence/experiments/{slug}/experiment-design.md"
    rubric: ".tad/evidence/experiments/{slug}/rubric.yaml"
    raw_results: ".tad/evidence/experiments/{slug}/results.tsv"
    analysis: ".tad/evidence/experiments/{slug}/analysis.md"
    baseline: ".tad/evidence/experiments/{slug}/baseline.txt"
    production_validation:
      path: ".tad/evidence/experiments/{slug}/production-validation.txt"
      conditional: "REQUIRED IF gate3_focus_AUGMENTATION.5 detects generator≠production model mismatch; OPTIONAL otherwise"
  domain_pack_integration:
    pack: "ai-evaluation"
    relationship: "Pack is tool/framework recommendations (promptfoo / DSPy / trulens). experiment_path_protocol is the workflow + Gate semantics. Loaded explicitly via domain_pack_auto_load (above)."
  enforcement: "prompt-level-only"
  forbidden_implementations:
    - "MUST NOT register hooks to gate *experiment"
    - "MUST NOT add to settings.json"
    - "MUST NOT return deny exit code from gate replacement scripts"
    - "MUST NOT replace Gate 3/4 silently — semantics is AUGMENT (additive), original criteria still apply"
    - "MUST NOT bypass *analyze Socratic for *experiment — all Standard TAD steps DO run"
```

#### P3.2.b — Intent Router 集成 for *experiment

同 *express，走**现有 step1 explicit-command bypass**（修正 v1）：
- step1 加 `*experiment` 到识别列表（已含 step3 7-mode display 处理）
- step4 routes to experiment_path_protocol
- step3 中 *experiment **可以** pre-select as Recommended（不同于 *express — 因为 *experiment 不是 ceremony-skip 路径，不存在 AR-001 风险）

#### P3.2.c — config-workflow.yaml + ai-evaluation pack 引用

加 `*experiment` 到 `.tad/config-workflow.yaml.intent_modes`；experiment_path_protocol.domain_pack_auto_load 强制 Read `.tad/domains/ai-evaluation.yaml`。

**AC:**
- [ ] AC-P3.2-a: Alex SKILL 含 `experiment_path_protocol` 完整 block (含 trigger / domain_pack_auto_load / required_steps / experiment_specific_gates / required_evidence_manifest_template / forbidden_implementations)
- [ ] AC-P3.2-b: 触发支持双路径 (user 显式 OR frontmatter)
- [ ] AC-P3.2-c: experiment_specific_gates.gate3_focus_AUGMENTATION 显式声明 semantics = "AUGMENT not REPLACE"; 5 检查项 (BA-P0-2 关键修复)
- [ ] AC-P3.2-d: gate4_focus_AUGMENTATION 显式 AUGMENT semantics; 4 检查项
- [ ] AC-P3.2-e: required_evidence_manifest_template 6 项 (含 production_validation 的 conditional 文字直接写在 template 里, CR-P1-2)
- [ ] AC-P3.2-f: domain_pack_integration + domain_pack_auto_load 显式声明 pack 路径 + Read 时机
- [ ] AC-P3.2-g: forbidden_implementations 5 项 (含 "MUST NOT replace Gate 3/4 silently" + "MUST NOT bypass Socratic")
- [ ] AC-P3.2-h: **Augmentation 双层验证 AC (BA-P0-2)** — fixture: experiment harness 有 syntax error → Gate 3 FAIL（原 build/test 仍 apply）+ 不只看 5 个 experiment 检查
- [ ] AC-P3.2-i: **ai-evaluation pack auto-load (BA-P1-3)** — fixture: *experiment 启动 → Alex 输出 "Loaded Domain Pack: ai-evaluation"
- [ ] AC-P3.2-j: Anti-Epic-1 — 见 §5 mechanical grep
- [ ] AC-P3.2-k: Intent Router *experiment 走 step1 bypass（不新增 step3 special case）

---

### Task P3.3 — `skip_knowledge_assessment` frontmatter

**问题**（Next Guest 70% capture rate, 12/17）: 现行协议要求 Alex *accept Gate 4 step7A 必须填 KA 表（哪怕 "No new discoveries"）。对 trivial CSS / copy / 单文件配置类 handoff，每次写"No 新发现"是仪式 overhead。

#### P3.3.a — handoff frontmatter 加字段

`.tad/templates/handoff-a-to-b.md` frontmatter section 加：

```yaml
skip_knowledge_assessment: no  # yes|no — Alex 默认值; Blake 可 override unskip
                                # 适用于 trivial 任务 (CSS / copy / 单文件配置)
                                # task_type=doc-only 推荐设 yes
                                # task_type=mixed/code/research 推荐设 no
                                # 字段缺失 (backward compat) 视作 no (现有行为)
```

#### P3.3.b — Alex *accept step7 行为修改

`.claude/skills/alex/SKILL.md` 的 `acceptance_protocol.step7` 改写：

```yaml
step7:
  pre_check:
    1. Read handoff frontmatter `skip_knowledge_assessment` field
       - if field absent: treat as `skip_knowledge_assessment: no` (backward compat for Phase 1+2 archive)
       - if field == yes: proceed to override check
       - if field == no: full step7 A/B/C (existing behavior)
    2. Read Blake completion report COMPLETION-{slug}.md
       Locate "## Knowledge Updates" section header
       Grep for override marker:
         pattern: `^\*\*knowledge_assessment_override:\s*unskip`
         - case-sensitive, line-anchored
         - matches first non-blank line under "## Knowledge Updates" section
  layer_2_audit_decoupling:
    note: "step4c Layer 2 audit runs BEFORE step7 regardless of skip_knowledge_assessment value
           — Layer 2 verifies reviewer artifacts (orthogonal to KA)"

  branch_1_skip_no_override:  # field == yes AND no override marker
    A_verify_blake_claims: REQUIRED  # still verify Blake's Gate 3 claims
    B_raw_tsv_recompute: REQUIRED    # still re-derive any quantitative AC
    C_alex_own_discoveries: SKIP     # only THIS section is skipped
    acceptance_report: "KA skipped — frontmatter declared trivial; Layer 2 + raw recompute still ran"
  
  branch_2_skip_with_override:  # field == yes AND override marker found
    A_verify_blake_claims: REQUIRED
    B_raw_tsv_recompute: REQUIRED
    C_alex_own_discoveries: REQUIRED  # full execution
    acceptance_report: "KA executed despite skip flag — Blake override: {reason from marker}"
    if_section_missing:  # override marker but no actual KA section content (BA-P2-1)
      verdict: "Gate 4: PARTIAL — KA override declared but section missing; Blake to add KA before final accept"
      action: "Do NOT FAIL Gate 4; emit actionable feedback to Blake; user can resume after Blake fills KA"
  
  branch_3_no_skip:  # field == no OR field absent
    A_verify_blake_claims: REQUIRED
    B_raw_tsv_recompute: REQUIRED
    C_alex_own_discoveries: REQUIRED
    acceptance_report: "Full step7 executed (existing behavior)"
```

#### P3.3.c — Blake completion override unskip 协议

`.claude/skills/blake/SKILL.md` 加段落:

```yaml
completion_knowledge_override:
  rule: |
    Even when handoff frontmatter says skip_knowledge_assessment: yes,
    Blake MUST add knowledge entries to architecture.md (or relevant category file)
    if implementation surfaces:
      - Reusable bash/CLI pattern (e.g., parallel CLI prefetch)
      - Library / SDK / API quirk reproducible across projects
      - LLM behavior pattern (drift / refusal / hallucination signature)
      - Anti-pattern with clear remediation
      - TAD framework mechanism discovery (hook contract / shell portability / etc)
  
  override_marker_anchor: "## Knowledge Updates"  # exact section header in COMPLETION-{slug}.md
  override_marker_format: |
    First non-blank line under "## Knowledge Updates" section, literal:
    `**knowledge_assessment_override: unskip — reason: <one sentence why this trivial-tagged
    handoff actually surfaced reusable knowledge>**`
    Format must be exactly: bold markdown (`**...**`), no leading whitespace, single line.
  alex_grep_pattern: '^\*\*knowledge_assessment_override:\s*unskip'  # case-sensitive, line-anchored
  
  rationale: |
    menu-snap SDK shape cast bug (architecture.md:55) was found in what looked like a small
    bugfix. If the handoff had skip_KA=yes and Blake had no override channel, the lesson
    would have been lost. Override is the safety net.

forbidden_implementations:  # ⚠️ Anti-Epic-1 parity with P3.1 / P3.2 (BA-P0-3)
  - "MUST NOT register PreToolUse / PostToolUse / UserPromptSubmit hook to read frontmatter and skip step7 mechanically"
  - "MUST NOT add to .claude/settings.json"
  - "MUST NOT return deny exit code from any wrapping script that reads skip_knowledge_assessment"
  - "MUST NOT auto-inject override marker via hook — Blake writes it manually based on judgment"
  - "MUST NOT couple skip_KA logic to Layer 2 audit (step4c) — they are orthogonal"
```

**AC:**
- [ ] AC-P3.3-a: Handoff template frontmatter 含 `skip_knowledge_assessment: yes|no` 字段 + 1 句使用说明 + backward compat 注释 (字段缺失 = no)
- [ ] AC-P3.3-b: Alex SKILL acceptance_protocol.step7 改写含 3 分支 (skip-no-override / skip-with-override / no-skip) + Layer 2 decoupling 显式
- [ ] AC-P3.3-c: Blake SKILL completion_knowledge_override 段落含 5 类应 override 的发现 + override_marker_anchor + override_marker_format + alex_grep_pattern
- [ ] AC-P3.3-d: dogfood — 本 handoff frontmatter 显式声明 `skip_knowledge_assessment: no`
- [ ] AC-P3.3-e: 验证 acceptance report 输出在 3 种情况下的文字差异（skip-clean / skip-overridden / no-skip）
- [ ] AC-P3.3-f: Phase 1 / Phase 2 archive 中已有 handoff (没 skip_KA 字段) → Alex *accept 视作 `skip_knowledge_assessment: no`（backward compat）
- [ ] AC-P3.3-g: **forbidden_implementations 5 项 (BA-P0-3 — Anti-Epic-1 对称防御)** + extended grep 含 `skip_knowledge.*hook|knowledge_assessment.*hook` 返回 0 hits
- [ ] AC-P3.3-h: **Override marker exact format (CR-P0-3)** — fixture: `## Knowledge Updates\n**knowledge_assessment_override: unskip — reason: bug fix surfaced SDK pattern**` → Alex grep matches; 错位 (e.g., 不在 KA section / 缺粗体 / 行首空白) → grep 不 match
- [ ] AC-P3.3-i: **Missing-section PARTIAL behavior (BA-P2-1)** — fixture: 含 override marker 但无 KA section content → Alex 输出 "Gate 4: PARTIAL — KA override declared but section missing"，**不 FAIL**

---

## 4. Acceptance Criteria Summary

**Total: 29 ACs** (P3.1: 12 [a–l], P3.2: 11 [a–k], P3.3: 9 [a–i])

All must PASS individually — no aggregate substitution (per AC Precision lesson 2026-04-14).

---

## 5. Required Evidence Manifest

```yaml
required_evidence:
  completion_report:
    path: .tad/active/handoffs/COMPLETION-20260424-phase3-new-paths.md
    required: true

  expert_reviews:
    - path: .tad/evidence/reviews/alex/phase3-new-paths/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/alex/phase3-new-paths/backend-architect.md
      required: true

  review_feedback_integration:
    - path: .tad/evidence/reviews/alex/phase3-new-paths/feedback-integration.md
      required: true

  gate_verdicts:
    - path: .tad/evidence/completions/phase3-new-paths/GATE3-REPORT.md
      required: true

  blake_reviews:
    - path: .tad/evidence/reviews/blake/phase3-new-paths/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/blake/phase3-new-paths/self-review.md
      required: true

  blake_review_feedback:
    - path: .tad/evidence/reviews/blake/phase3-new-paths/feedback-integration.md
      required: true

  fixture_results:
    - path: .tad/evidence/completions/phase3-new-paths/fixtures/
      required: true
      minimum_fixtures:
        - fixtures/skip-ka-yes.frontmatter.yaml
        - fixtures/skip-ka-no.frontmatter.yaml
        - fixtures/no-skip-ka-field-backward-compat.frontmatter.yaml  # uses real Phase 1 archive
        - fixtures/express-3-files.md
        - fixtures/express-5-files-warning-trigger.md
        - fixtures/express-override-with-decision-row.md  # AC-P3.1-i
        - fixtures/express-not-recommended-by-step3.md  # AC-P3.1-j
        - fixtures/intent-router-7mode-display.md  # AC-P3.1-k
        - fixtures/experiment-frontmatter.yaml
        - fixtures/experiment-harness-syntax-error.md  # AC-P3.2-h augment-not-replace
        - fixtures/experiment-pack-loaded.md  # AC-P3.2-i
        - fixtures/override-marker-correct.md  # AC-P3.3-h positive
        - fixtures/override-marker-malformed.md  # AC-P3.3-h negative
        - fixtures/override-marker-missing-section.md  # AC-P3.3-i PARTIAL behavior
        - fixtures/skill-text-grep-ar001-mechanical.txt  # AC-P3.1-h grep output

  anti_epic1_compliance:
    - path: .tad/evidence/completions/phase3-new-paths/anti-epic1-grep.txt
      description: |
        Phase 3 grep pattern (CR-P1-1 fix: word-boundary + exclude comment lines):
        # Approach: assert NO new hook keys in settings.json + NO new files in .tad/hooks/ matching express|experiment|skip_knowledge
        grep -rE '^[^#]*\*express[^|]*hook|^[^#]*express_path[^|]*hook|^[^#]*\*experiment[^|]*hook|^[^#]*experiment_path[^|]*hook|^[^#]*skip_knowledge[^|]*hook|^[^#]*knowledge_assessment[^|]*hook' \
             .claude/settings.json .tad/hooks/*.sh .tad/hooks/lib/*.sh
        # AND
        ls .tad/hooks/ .tad/hooks/lib/ | grep -E '^(express|experiment|skip_knowledge|knowledge_assessment)'
        # Both must return 0 hits / 0 matches.
      required: true

  ar001_mechanical_anchor:
    - path: .tad/evidence/completions/phase3-new-paths/ar001-grep.txt
      description: |
        AC-P3.1-h: SKILL-text grep verifying express_path_protocol.required_steps
        contains literal "expert review" AND "code-reviewer" on consecutive lines:
        grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md \
          | grep -c 'expert review.*code-reviewer\|code-reviewer.*expert review'
        Must return ≥1.
      required: true

  dogfood:
    - path: .tad/evidence/completions/phase3-new-paths/dogfood.md
      description: |
        Multi-trifecta:
        1. 本 handoff §6 含 Grounded Against (P2 dogfood)
        2. 本 handoff frontmatter 含 skip_knowledge_assessment=no (P3.3 dogfood)
        3. 至少 1 条新 architecture.md entry 用 Grounded in + Revalidated 格式
        4. 真实 Phase 1 archive HANDOFF (无 skip_KA 字段) → Alex *accept 默认 no behavior 验证 (real-archive backward-compat fixture, BA-P2-4)
        5. 端到端 round-trip: *express 模拟 + Blake override unskip 添加 KA 实际触发 (CR-P2 round-trip fixture)
      required: true

  knowledge_updates:
    - path: .tad/project-knowledge/architecture.md
      description: "至少 1 条新 entry 关于 *express vs anti-rationalization 边界设计 / *experiment Gate AUGMENT 思路 / skip_KA override 安全网 / Intent Router 7-mode 溢出处理"
      required: true
```

---

## 6. Files to Modify / Create

**修改:**
- `.claude/skills/alex/SKILL.md` (~200 行新增):
  - intent_router_protocol step1 加 *express + *experiment（surgical，不动 step3 现有逻辑）
  - intent_router_protocol step3 7-mode display strategy 扩展（处理 4-option 溢出）
  - intent_router_protocol path_transitions matrix 完整版（allowed + forbidden）
  - express_path_protocol 完整 block (~70 行)
  - experiment_path_protocol 完整 block (~90 行)
  - acceptance_protocol.step7 改写为 3 分支 + missing-section PARTIAL (~40 行)
- `.claude/skills/blake/SKILL.md` (~30 行):
  - completion_knowledge_override 段落 + forbidden_implementations
- `.tad/templates/handoff-a-to-b.md` (~6 行):
  - frontmatter 加 skip_knowledge_assessment 字段
- `.tad/config-workflow.yaml` (~30 行):
  - intent_modes 加 *express + *experiment + priority_order 调整

**新建:**
- `.tad/evidence/completions/phase3-new-paths/fixtures/**` (15 fixtures per §5)

**Grounded Against** (Alex step1c — Phase 2 dogfood):
- `.claude/skills/alex/SKILL.md` lines 300-447 (intent_router_protocol — 验证现有 step1/step3/step4 结构)
- `.claude/skills/alex/SKILL.md` lines 1984-2122 (acceptance_protocol — 验证 step7 现状)
- `.claude/skills/alex/SKILL.md` lines 3368-3435 (anti_rationalization_registry — 验证 AR-001 anchor)
- `.claude/skills/blake/SKILL.md` (head 50 — 验证 Blake completion 协议结构)
- `.tad/templates/handoff-a-to-b.md` lines 1-11 (frontmatter — 验证 field 插入点)
- `.tad/config-workflow.yaml` lines 603-669 (intent_modes — 验证现有结构)
- `.tad/project-knowledge/architecture.md` (head 50 — 验证现有 entry 格式)
- `.tad/domains/ai-evaluation.yaml` (head 50 — 验证 pack 存在性 + capability 列表，给 P3.2 cross-reference)

---

## 7. Testing Checklist

- [ ] Frontmatter parse: 3 个 fixture (yes / no / 无字段 backward-compat) 在 YAML parser 下都合法
- [ ] *express scope: 5 文件 fixture → AskUserQuestion 提示降 Standard；用户选 override → §11 必含 row（缺则 Gate 2 FAIL）
- [ ] *experiment 双触发: (1) user 显式 (2) frontmatter task_type=experiment 任一进入
- [ ] *experiment ai-evaluation pack auto-load: 启动 *experiment → Alex 输出 "Loaded Domain Pack: ai-evaluation"
- [ ] *experiment Gate AUGMENT: harness syntax error fixture → Gate 3 FAIL（原 build/test 仍 apply，不只看 5 实验检查）
- [ ] Override marker exact format: 正例匹配 / 4 个反例 (位置错 / 缺粗体 / 行首空白 / 缺 reason) 全部不匹配
- [ ] Missing-section PARTIAL: override marker + 无 KA section → Gate 4 PARTIAL（不 FAIL）
- [ ] Anti-Epic-1 (greedy fix): 不会假阳匹配文档注释行；新 hook 文件名 0 个
- [ ] AR-001 mechanical: SKILL grep 返回 ≥1
- [ ] Backward compat: Phase 1+2 archived handoffs (无 skip_KA) → Alex *accept 视作 no
- [ ] Round-trip dogfood: *express + Blake override unskip 全流程跑通
- [ ] Real-archive backward-compat: 解析 HANDOFF-20260424-phase1-state-consistency.md → Alex 视作 skip_KA=no
- [ ] Cross-reference: experiment_path_protocol 文档中明确引用 ai-evaluation pack 路径

---

## 8. Blake Instructions

- 这是 **Standard TAD Phase handoff**，不是 Express。完整 Ralph Loop + Layer 2 + Gate 3 v2。
- 3 个 task 互相独立。建议顺序：P3.3 (frontmatter + Alex step7 + Blake override 协议) → P3.1 (express path) → P3.2 (experiment path 含 Gate AUGMENT，最复杂)。
- **STRICT prompt-level enforcement**: 三个 path 都是 SKILL 自律。**任何**实现把它们做成 PreToolUse hook / UserPromptSubmit hook / settings.json 注册 = 直接退回（Phase 3 是协议层，无 shell 工具）。
- **AR-001 兼容性是 P3.1 设计核心** (重申): *express **不是** review-exempt。AC-P3.1-h 通过 SKILL grep 机械验证 "expert review" + "code-reviewer" 字面字符串存在。
- **AUGMENT not REPLACE 是 P3.2 设计核心** (BA-P0-2 关键修复): experiment harness 仍需 build/test/lint，5 个实验检查项是**附加**。AC-P3.2-h fixture 验证。
- **skip_KA forbidden_implementations 不能漏** (BA-P0-3): P3.3 跟 P3.1/P3.2 有对称的 5-item forbidden 列表。Extended anti-Epic-1 grep 含 `skip_knowledge.*hook` patterns。
- **Intent Router step3 7-mode 溢出**: 当候选 modes >4，按 priority_order tiebreaker；analyze 始终在第 4 位；*express **永不** pre-selected as Recommended。
- **path_transitions 完整 matrix**: 含 forbidden analyze→express / analyze→experiment（防 AR-001 attack）。
- **Override marker exact format**: 必须 bold markdown 在 "## Knowledge Updates" 第一行非空白；Alex grep 是 case-sensitive line-anchored。
- **scope 警戒**: Alex SKILL ~200 行；总改动 ~270 行。**超 400 行 escalate to Alex**。
- 本 Phase 是协议层，**无新 shell 工具**——如觉得"必须加新工具"，那就是 anti-Epic-1 警钟。

---

## 9. Project Knowledge — Blake 必读历史教训

| 教训 | 文件 | 关系 |
|------|------|------|
| Express Handoff is NOT Review-Exemption (2026-04-14) | architecture.md | **P3.1 设计核心**: *express ≠ review-exempt |
| anti_rationalization_registry AR-001 | architecture.md (entry context) | P3.1 必须保留 ≥1 review (AC-P3.1-h SKILL grep 机械验证) |
| Mechanical Enforcement Rejected on Single-User CLI (2026-04-15) | architecture.md | 三个 path 全 prompt-level only; P3.3 也加 forbidden_implementations |
| Cross-Model Prompt Optimization (LLM-as-Judge/Optimizer) - 2026-04-24 | architecture.md (Phase 1 dogfood) | **P3.2 直接受益**: OPRO pattern 是 *experiment Gate 设计依据 |
| Long Context Enables In-Session Decision Making (2026-03-25) | architecture.md | *experiment 模式可受益于 in-session decision (4D Protocol 类) |
| AC Precision: List-based vs Aggregate (2026-04-14) | architecture.md | 本 handoff 29 AC 全列具体项 |
| Revalidated State Defeats Alarm Fatigue (2026-04-24) | architecture.md (Phase 2 dogfood) | dogfood 提醒 — 参考 entry 格式 |
| Word-Boundary Matching for Identifier-Style Slugs (2026-04-24) | architecture.md (Phase 1) | *express *experiment 都是 identifier-style |
| Domain Pack Loading (Phase 2b 2026-04-07) | architecture.md | P3.2 集成 ai-evaluation pack auto-load 时参考 |

---

## 10. Expert Review Status

### Audit Trail (P1.5 模板)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: §4 AC count 错乱 + meta-commentary 漏正文 | §4 重写为 "Total: 29 ACs (P3.1=12, P3.2=11, P3.3=9)" 单一陈述 | Resolved |
| code-reviewer | P0-2: P3.1.b "step3 NOT NEEDED" 跟现有 step1 冲突 | §P3.1.b 改写: *express 走现有 step1 explicit-command bypass 同 *bug 等; step3 不新增 special case (但 step3 7-mode display 扩展是另一回事 per BA-P0-1) | Resolved |
| code-reviewer | P0-3: P3.3 Override marker anchor + 格式 + grep pattern 三义不明 | §P3.3.c 显式: anchor="## Knowledge Updates", format=bold markdown 第一非空白行, grep pattern `^\*\*knowledge_assessment_override:\s*unskip` | Resolved |
| code-reviewer | P0-4: AR-001 hard guarantee 是 text-only | AC-P3.1-h: SKILL-text grep `grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md \| grep -c 'expert review.*code-reviewer'` ≥1 | Resolved |
| code-reviewer | P1-1: anti-Epic-1 grep `.*` greedy 假阳 | §5 anti_epic1_compliance pattern 重写: word-boundary + 排除 `^#` 注释行 + ls 验证无新文件 | Resolved |
| code-reviewer | P1-2: production_validation 条件埋深 | §P3.2.a required_evidence_manifest_template 中 production_validation 直接含 conditional 字段 | Resolved |
| code-reviewer | P1-3: skip_KA missing-field branch 显式 | §P3.3.b step7 pre_check 显式: "if field absent → treat as no" | Resolved |
| code-reviewer | P1-4: scope override 强制 §11 | AC-P3.1-i: fixture override → §11 必含 row + 用户原因; 缺 → Gate 2 FAIL | Resolved |
| code-reviewer | P1-5: gate3_focus REPLACE 语义 | §P3.2.a 重命名 gate3_focus_AUGMENTATION + semantics 显式 "AUGMENT not REPLACE" | Resolved (合并 BA-P0-2) |
| code-reviewer | P2-1: §6 行数估算 | §6 已显示 ~200 行 Alex SKILL，~270 行总；超 400 行 escalate | Resolved |
| code-reviewer | P2-2: §9 Cross-Model 问号 | §9 已确认: 是 Phase 1 dogfood 加的 entry，移除问号 | Resolved |
| code-reviewer | P2-3: §10 Audit Trail skeleton | §10 (本 section) 已填表 — 表明 review 完成 | Resolved |
| code-reviewer | P2-4: 加 *express + Blake override 端到端 fixture | §5 fixtures 加 round-trip + dogfood §dogfood.md 的第 5 项 | Resolved |
| backend-architect | P0-1: Intent Router 7-mode vs 4-option 溢出 | §P3.1.b step3 7-mode display strategy 扩展; AC-P3.1-k fixture | Resolved |
| backend-architect | P0-2: Gate REPLACES 太激进 | §P3.2.a 重命名 gate3/4_focus_AUGMENTATION + semantics 双层验证 + AC-P3.2-h fixture (harness syntax error) | Resolved |
| backend-architect | P0-3: skip_KA 缺 forbidden_implementations | §P3.3.c 加 5-item forbidden_implementations + AC-P3.3-g extended grep | Resolved |
| backend-architect | P1-1: path_transitions matrix 不全 | §P3.1.b path_transitions 完整 (3 new allowed + analyze→express/experiment forbidden) + AC-P3.1-l | Resolved |
| backend-architect | P1-2: AskUserQuestion suggestion 漏洞 (step3 不能 pre-select *express) | §P3.1.a trigger.NOT_via_alex_suggestion 三条规则 (a/b/c) + AC-P3.1-j | Resolved |
| backend-architect | P1-3: ai-evaluation pack auto-load 契约 | §P3.2.a domain_pack_auto_load 显式 step1 Read; AC-P3.2-i fixture | Resolved |
| backend-architect | P1-4: AC count 错乱 (重叠 CR-P0-1) | 同 CR-P0-1 解决 | Resolved (merged) |
| backend-architect | P2-1: step7 missing-section PARTIAL not FAIL | §P3.3.b branch_2_skip_with_override.if_section_missing → PARTIAL + actionable feedback; AC-P3.3-i | Resolved |
| backend-architect | P2-2: Audit Trail 在 *express 中保留 | §1 Executive Summary + §P3.1.a required_steps 显式含 "step4 Audit Trail integration (P1.5 dogfood)" | Resolved |
| backend-architect | P2-3: Layer 2 audit decouple skip_KA | §P3.3.b layer_2_audit_decoupling note 显式 + forbidden_implementations 第 5 项 | Resolved |
| backend-architect | P2-4: Real-archive backward-compat fixture | §5 minimum_fixtures 加 `no-skip-ka-field-backward-compat.frontmatter.yaml` 用真实 Phase 1 archive | Resolved |

### Experts Selected
1. **code-reviewer** — Alex/Blake SKILL.md 协议块 syntax / completeness / 跟现有协议兼容性 / AR-001 mechanical anchor
2. **backend-architect** — Intent Router 7 模式状态机 / *experiment Gate AUGMENT vs REPLACE / skip_KA forbidden_implementations 对称性 / path_transitions matrix 完整性

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS** (4 P0 + 5 P1 + 4 P2 全 Resolved)
- backend-architect: CONDITIONAL PASS → **PASS** (3 P0 + 4 P1 + 4 P2 全 Resolved)

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | *express 触发 + scope | user 显式+≤3 / +≤5 / +无上限 / Alex 自动 | user 显式 + ≤3 文件 | 用户选 Recommended; 边界清晰; AR-001 兼容 |
| 2 | *express 必保留步骤 | ≥1 review+G2+G3 / ≥2 review / 仅 G3 | ≥1 review+G2+G3 + Audit Trail | 用户选 Recommended; 与 AR-001 完全兼容 |
| 3 | *experiment 触发 | 双路径 / 仅 user / 仅 frontmatter | user 显式 OR frontmatter | 用户选 Recommended; 双路径灵活 |
| 4 | skip_KA 反悔机制 | Alex+Blake override / Alex 不可推翻 / 仅 task_type | Alex 默认 + Blake override unskip | 用户选 Recommended; menu-snap SDK shape bug 反向证据 |
| 5 | *express + Adaptive Complexity | Alex 不可推荐 / 弱建议 / 强建议 | **Alex 不可推荐 + step3 不 pre-select Recommended** | Alex 决策; AR-001 防御; BA-P1-2 强化 |
| 6 | *experiment + ai-evaluation pack 关系 | 重复 / 互补 / pack 包含 protocol | 互补 + auto-load via Read | Alex 决策; BA-P1-3 加 explicit Read |
| 7 | task_type=mixed 是否默认 skip_KA | 是 / 否 / Alex 判断 | **否 (默认 no)** | Alex 决策 |
| 8 | Phase 1+2 backward compat | 默认 yes / 默认 no / 强制声明 | 默认 no (现有行为) + AC-P3.3-f 验证 | Alex 决策 |
| 9 | **experiment Gate 语义 (BA-P0-2)** | REPLACE / AUGMENT / both | **AUGMENT (additive)** | harness 仍需 build/test/lint; 5 实验检查附加; 双层质量验证 |
| 10 | **Intent Router 7-mode 溢出处理 (BA-P0-1)** | 移除某模式 / priority_order / random | priority_order tiebreaker + analyze 总在第 4 位 | 确定性 UX; *express 永不 Recommended |
| 11 | **skip_KA forbidden_implementations (BA-P0-3)** | 不加 / 部分加 / 加 5 项对称 | 加 5 项对称 (P3.1/P3.2 parity) | Anti-Epic-1 attack surface 对称防御 |
| 12 | **path_transitions analyze → express/experiment (BA-P1-1)** | 允许 / 默认拒 / 显式 forbidden | **显式 forbidden** | 防 AR-001 中途降级 attack |

---

**Status**: Feedback integration complete (7 P0 + 9 P1 + 4 P2 all Resolved) → Gate 2 → Blake message
