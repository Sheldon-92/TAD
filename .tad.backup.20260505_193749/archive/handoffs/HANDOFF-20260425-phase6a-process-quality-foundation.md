---
# Quality Chain Metadata
task_type: mixed       # SKILL.md text + handoff template + shell script + fixtures
e2e_required: no       # CLI-level fixture tests; no browser/UI
research_required: no  # All evidence accumulated from Phase 1-5 execution

git_tracked_dirs:
  - ".claude/skills/alex"
  - ".claude/skills/blake"
  - ".tad/templates"
  - ".tad/hooks/lib"
  - ".tad/evidence/fixtures/phase6"

skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 6-A — Process Quality Foundation (Gray Zone Fix)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-25
**Project:** TAD Framework
**Task ID:** TASK-20260425-002
**Handoff Version:** 3.1.0 (v2 post 11 P0 + 7 P1 expert review integration)
**Epic:** EPIC-20260424-tad-self-upgrade-from-consumers.md (Phase 6/6 — sub-handoff A of N)
**Linear:** N/A
**Supersedes:** N/A
**Review Status:** CONDITIONAL PASS → PASS post-integration (see §9.4 Audit Trail)

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-04-25 (post v2 integration)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 2 gray zones; 4 subsystems consistent (Alex SKILL, Blake SKILL, template, layer2-audit); single source of truth for reviewer names (KNOWN_REVIEWERS in audit script) |
| Components Specified | ✅ | step1d insertion line-anchored; layer2_expert_review restructure (list→mapping) explicit; 5-item forbidden_implementations symmetric |
| Functions Verified | ✅ | layer2-audit.sh existing patterns confirmed (find -print0 to be reused); template §9.1 Spec Compliance Checklist confirmed (NOT §9.2); empirical `grep -cE 'a\|b'` returns 0 verifying CR-P0-1 |
| Data Flow Mapped | ✅ | Verification Type col flows Alex draft → Blake Gate 3; reviewer-name flows sub-agent invocation → file → audit detection |

**Gate 2 结果**: ✅ PASS

**Alex 确认**: 2 gray zones surgically targeted; 11 P0 fully integrated; assumption-level changes deferred to subsequent P6.x sub-handoffs.

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 阅读所有章节，特别是 §6.2 Stage D explicit D.1-D.5 + §6.6 line-anchored insertion map
- [ ] **阅读「📚 Project Knowledge」12 条历史教训** — 含 AR-001, Path Layering, Hook Performance, Word-Boundary Matching
- [ ] 所有 MQ 都有证据
- [ ] 理解真正意图：dogfood Phase 5 lessons + Phase 6 first sub-handoff = 流程纪律护体
- [ ] 确认本 handoff 自身已用新 §9.1 (template §9.1, NOT §9.2) dual-column 格式 — meta-trifecta dogfood

---

## 1. Task Overview

### 1.1 What We're Building

Phase 6 Sub-Handoff A — **Process Quality Foundation**. 修复 Phase 1-5 累积出的 2 个 process gray zones：

**Gray Zone 1 (P6-A.1) — AC Verification Command Drift (3 phases pattern)**
- Phase 3 / 4 / 5 都有 §9.2 verification command 在 Blake 运行时出错
- 根因：Alex 写 handoff 时**没 dry-run 命令**，BSD vs GNU + 单/多文件输出 + jq array vs scalar + markdown table pipe-escape 等 output shape 看不出来
- 修复：Alex SKILL 加 step1d (新 AC dry-run pass) — 含 **3 self-defending sub-rules** (CR self-dogfood verdict)
- handoff template **§9.1** (Spec Compliance Checklist; CR-P1-1: 不是 §9.2) 加 2 列：Verification Type + Verified Output

**Gray Zone 2 (P6-A.2) — Layer 2 ≥2 Reviewer Drift (3 phases pattern)**
- Phase 3 / 4 / 5 都是 code-reviewer 单 reviewer (Blake 用 self-review.md 替代 backend-architect)
- 根因：Blake SKILL Layer 2 协议没硬约束 ≥2 distinct sub-agent invocations
- 修复：Blake SKILL `gate3_v2.layer2_expert_review` 重构 list→mapping (CR-P0-2)，加 `hard_requirement_distinct_reviewers:` block，**reviewer 白名单 canonical source = layer2-audit.sh KNOWN_REVIEWERS** (BA-P0-2 single source of truth)
- layer2-audit.sh 升级：检测 distinct reviewer agent NAMES (find -print0 + case statement，BSD-portable)

### 1.2 Why We're Building It

**业务价值**：Phase 6 = assumption re-design Epic phase。这是 first sub-handoff，先修被 P5 自验证暴露的 process gray zones，再启动后续 P6.1-P6.8 真正 assumption redesign。**先把"Alex/Blake 各自能多稳"做实，再争论 Alex/Blake 边界假设。**

**用户受益**：
- 下一个 handoff 起 Blake 不再 flag "INTENT PASS / LITERAL FAIL" verification command bug
- 下一个 handoff 起 Layer 2 至少 2 个独立 expert 审 Blake 实现
- Phase 6 后续 sub-handoff 在 process discipline 强化的环境下进行

**成功的样子**：本 handoff Gate 4 PASS 之后，**下一个 handoff** 在 Gate 3 verdict 中**不再出现**：
- (a) "INTENT PASS / LITERAL FAIL" 类 AC verification command bug
- (b) "self-review.md substituting for backend-architect" 类 Layer 2 single-reviewer 表述

### 1.3 Intent Statement

**真正要解决的问题**：
1. Phase 1-5 已经累积 3 次"AC 命令在 handoff 设计时 imagined-correct，run-time-broken"
2. Phase 1-5 已经累积 3 次"Blake Layer 2 用 self-review.md 替代第二个 sub-agent"

**不是要做的**：
- ❌ 不是回溯 fix Phase 1-5 (per Socratic Q3 user 选 "不补")
- ❌ 不是机械强制 (per architecture.md 2026-04-15 Anti-Epic-1)
- ❌ 不是 P6.1-P6.8 assumption redesign (after this sub-handoff PASSES)
- ❌ 不是改 Gate 1/Gate 2/Gate 4 — 只动 step1d (Alex handoff 起草段) + Layer 2 (Blake Gate 3 中段)

**Sub-handoff vs new Phase criterion (BA-P1-4)**:
- **P6-X = process discipline / mechanism gap fix** (sub-handoffs of Phase 6)
- **New Phase number = 新架构假设挑战** (P6.1-P6.8 assumption redesigns are technically Phase 6 sub-items but COULD spawn Phase 7+ if scope explodes)
- This handoff (P6-A) is process; if a future P6.1 sub-handoff finds Alex/Blake boundary needs full redesign, that's a Phase 7 candidate.

**Blake 请确认理解：**
```
1. Phase 6 = EPIC-20260424 第 6/6 phase；本次 P6-A 只解决 process gray zones
2. AC dry-run 在 Alex SKILL step1d 落地 (NEW，sibling to step1c)，prompt-level only
3. Layer 2 ≥2 reviewer 在 Blake SKILL gate3_v2 落地，prompt-level only
4. layer2-audit.sh 强化但仍是 advisory CLI (exit 0/1/2)，不 deny
5. 本 handoff 自身已 dogfood：§9.1 (template §9.1 spec compliance) dual-column + ≥2 distinct sub-agents in Layer 2 (this very review!)
6. Reviewer 白名单 canonical source = layer2-audit.sh KNOWN_REVIEWERS array; SKILL refers, doesn't enumerate
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

- [x] architecture — Process discipline 设计 + 流程层 enforcement
- [x] code-quality — bash shell portability for layer2-audit.sh enhancement
- [x] testing — fixture for AC drift catch + Layer 2 reviewer-name detection
- [ ] security/ux/performance/api/mobile/frontend — N/A

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 12 | 见下方 ⚠️ 列表 |
| security.md | 0 | 无相关 |
| README.md | N/A | 不动 |

**⚠️ Blake 必须注意的历史教训**：

1. **AC Verification Commands Need Pre-Ship Smoke Test - 2026-04-25** (architecture.md, **本 handoff 直接源动机**)
2. **Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15** — Anti-Epic-1, 所有改动 prompt-level only
3. **Path Layering: Three Defenses Against Single-Path AR-001 Drift - 2026-04-24** — symmetric forbidden_implementations 5-item baseline
4. **Hook Performance: Single-awk vs Per-item grep Loop - 2026-04-07** — layer2-audit.sh 用 find -print0 + case 单 pass
5. **Hook Path Matching - 2026-04-02** — 不动 path matcher
6. **Word-Boundary Matching for Identifier-Style Slugs - 2026-04-24** — `*express*` glob 误命中 `expression`，用精确变体
7. **Drift-Check Allowlist - 2026-04-24** — 不动 drift-check
8. **Express Handoff is NOT Review-Exemption - 2026-04-14** — *express 仍需 ≥1 expert (not zero)
9. **Alex Handoff AC Must Explicitly List ALL Required Evidence Files - 2026-04-14** — §9.3 必列具体文件名
10. **Gate 4 Verification Integrity: Verify Files, Not Claims - 2026-04-14** — Alex 重跑 §9.1 commands
11. **Honest Partial Protocol** (Phase 3 SKILL hardening) — 不把 PARTIAL 当 PASS
12. **Hook Data Integrity - 2026-04-14** — 备查 (本 handoff 不需 multi-plex output)

### Blake 确认

- [ ] 已读 12 条
- [ ] 理解 Anti-Epic-1: 所有改动 prompt-level only
- [ ] 理解 Honest Partial: 不把 PARTIAL 当 PASS

---

## 2. Background Context

### 2.1 Previous Work

- EPIC-20260424 P1-P5 全部 ✅ Done (commits 08e9e74 / 0b2e25d / ff96bd5 / d2a73a1+93fcb50 / d578707 + acceptance 563d965)
- Phase 5 Gate 4 PASS 当天暴露的 2 个 process gray zones 是本 handoff 的直接源动机
- Phase 5 加的 architecture.md 条目 "AC Verification Commands Need Pre-Ship Smoke Test" 是本 handoff Gray Zone 1 的诊断锚点

### 2.2 Current State

| 文件 / 工具 | 当前状态 | P6-A 后状态 |
|------------|---------|------------|
| Alex SKILL handoff_creation_protocol | step0_5 → step1 → step1b → step1c → step2 | + step1d (AC dry-run pass) sibling 到 step1c |
| Blake SKILL gate3_v2.layer2_expert_review | flat YAML list (4 bullets, 906-913) | restructured to mapping with `bullets:` sub-key + new `hard_requirement_distinct_reviewers:` peer (CR-P0-2 fix) |
| layer2-audit.sh | 数 reviewer 文件个数 | 升级：detect distinct reviewer agent NAMES via find -print0 + case (BSD-portable, fork-free per FR4) |
| handoff template **§9.1** (CR-P1-1: NOT §9.2) | 4-column "Spec Compliance Checklist" | 6-column: + Verification Type + Verified Output |

### 2.3 Dependencies

- bash 3.2+ (macOS BSD)
- find -print0 + sort -u (no `grep -P`, no GNU-only flags)
- 无新 external 依赖

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1 (P6-A.1 — Alex SKILL step1d AC dry-run pass with 3 self-defending sub-rules)**

加新 step `step1d` 到 `handoff_creation_protocol.workflow`，sibling 到 `step1c`。

```yaml
step1d:
  name: "AC Dry-Run Pass — verify §9.1 verification commands actually work (P6-A.1, 2026-04-25)"
  trigger: "After step1c grounding pass, before step2 expert review"
  enforcement: "prompt-level-only"
  rationale: |
    Phase 3 / 4 / 5 累积 3 次 §9.1 verification command 在 Blake runtime 出错
    (Phase 3 模板 anchor / Phase 4 grep scope / Phase 5 grep -n 输出格式)。
    根因是 Alex 脑内模拟 grep/awk/jq/markdown-table-pipe-escape output shape 不可靠。
    step1d 强制实跑 + 3 self-defending sub-rules.
  blocking_in_alex_protocol: true
  action: |
    1. Parse step1 draft's §9.1 Spec Compliance Checklist table
       (NOTE: handoff §9 numbering — §9.1 = Spec Compliance, §9.2 = Expert Review.
        Don't confuse with template's actual numbering.)
    2. For each row, classify per Verification Type:
       a. **pre-impl-verifiable**: command can run NOW on existing artifacts
       b. **post-impl-verifiable**: command requires Blake's NEW artifacts
    3. **Sub-rule 1: Raw-form-before-rendered-form (CR self-dogfood)**:
       - Author commands in RAW shell form first (e.g., `grep -cE 'a|b|c'`)
       - Dry-run from RAW form, NOT from markdown-rendered escaped form
       - Only escape pipes (`|` → `\|`) when inserting into markdown table cells
       - In §6.5 / §6.7 dry-run log, paste BOTH raw command + un-escaped output
    4. **Sub-rule 2: Syntax-validate even post-impl-verifiable rows**:
       - Even rows that can't fully run (file doesn't exist yet), run `bash -n` /
         shellcheck on the command, OR run a syntactic dry-run with `--help`-style
         expansion to confirm command parses
       - Catches `\|` literal-pipe-in-grep-E and similar regex bugs that don't
         require the target file to exist
    5. **Sub-rule 3: Re-derive every pre-impl AC value with a one-liner**:
       - Never quote AC values from memory or another section of the same doc
       - For pre-impl rows, run the command exactly as written, paste actual output
       - Cross-check against §6.7 dry-run log AC-G2 mismatch (Phase 6-A specifically
         caught its OWN AC-G2 quoting wrong number due to violation of this rule)
    6. For each pre-impl-verifiable row:
       - Run command, capture stdout + exit code
       - Paste result into "Verified Output" column of handoff §9.1
       - If output ≠ AC's "Expected Evidence" → fix the AC's Verification Method
    7. For each post-impl-verifiable row:
       - Mark "Verified Output" column as "(post-impl — Blake runs at Gate 3 v2 Layer 1)"
       - Apply Sub-rule 2 (syntax-validate)
       - DO NOT mock the future artifact (no `echo > /tmp/...` hacks)
    8. Append ## Step1d Dry-Run Log to handoff §6.5:
       ```
       **AC Dry-Run Log** (Alex step1d 实际 dry-runs at YYYY-MM-DD HH:MM):
       - AC-X-y: ✅ pre-impl-verifiable, raw cmd: <cmd>, output matched expected
       - AC-X-z: ✅ post-impl-verifiable, syntax-validated, deferred to Gate 3
       - AC-X-w: ⚠️ pre-impl-verifiable, output mismatch — Verification Method revised
       ```
  exemption_doc_only: |
    Skip step1d for handoffs with task_type=doc-only AND empty §9.1.
  exemption_pre_phase6: |
    BA-P1-1 fix: AND not OR. Pre-Phase-6 handoffs (filename date < 2026-04-25
    AND no §9.1 dual columns): skip step1d.
    NEW handoffs (date >= 2026-04-25) MUST have dual columns; missing dual cols
    is a step1 draft error, not exemption case.
  violation_self_audit: |
    At step2, if §9.1 has rows but no AC Dry-Run Log section AND no exemption:
    self-audit failed → return to step1d.
  forbidden_implementations:
    # 5 items per BA-P0-1 baseline; symmetric to step1c / express_path_protocol
    - "MUST NOT register as PreToolUse / UserPromptSubmit hook in .claude/settings.json"
    - "MUST NOT add to .tad/hooks/*.sh as auto-fired script"
    - "MUST NOT return deny exit code from any wrapping script"
    - "MUST NOT block ANY tool call (Write/Edit/Read)"
    - "Anti-AR-001: 'small handoff = step1d skippable' OR 'all post-impl so step1d
       value-less' is a forbidden interpretation. step1d's value includes Sub-rule 2
       syntax validation regardless of pre/post split."
```

**FR2 (P6-A.1 supplementary — handoff template §9.1 dual-column, NOT §9.2 — CR-P1-1 fix)**

Edit `.tad/templates/handoff-a-to-b.md` **§9.1 Spec Compliance Checklist** (line 490 per template grep, NOT §9.2 which is Expert Review Status). Current header (template line ~492):

```markdown
| # | Acceptance Criterion | Verification Method | Expected Evidence |
```

Change to:

```markdown
| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
```

Add documentation comment block above table (after `## 9.1 Spec Compliance Checklist` line, before table header):

```markdown
> **Verification Type column** (Phase 6-A.1, 2026-04-25):
> - `pre-impl-verifiable` — Alex dry-runs at handoff drafting (step1d); paste raw output
> - `post-impl-verifiable` — Blake runs at Gate 3 v2 Layer 1 after implementation
>
> **Pipe-escape note**: Markdown tables require `|` inside regex to be written `\|` for cell rendering.
> When extracting commands to run in bash, **un-escape**: `grep -cE 'a\|b\|c'` (rendered) → `grep -cE 'a|b|c'` (run).
> Step1d Sub-rule 1 mandates dry-running from raw form, not rendered.
>
> The `Verified Output` column is filled by Alex during step1d for pre-impl rows;
> by Blake during Gate 3 for post-impl rows. Empty Verified Output post step1d
> with non-empty Verification Method = handoff incomplete.
```

**FR3 (P6-A.2 — Blake SKILL Layer 2 hard rule with single source of truth)**

Edit `.claude/skills/blake/SKILL.md` `gate3_v2.layer2_expert_review` block (lines 906-913). **CR-P0-2 fix**: current block is a flat YAML list of 4 bullets — need to **convert to mapping** with `bullets:` sub-key, then add `hard_requirement_distinct_reviewers:` as peer.

**Before** (lines 906-913 current state):
```yaml
    layer2_expert_review:
      - "Group 0: spec-compliance-reviewer（AC 全满足）"
      - "Group 1: code-reviewer（P0=0, P1=0）"
      - "Group 2: test-runner + security-auditor + performance-optimizer（按 trigger 规则）"
      - "Expert 说 PASS 才算完成 — 不是 Blake 自己判断"
```

**After** (post FR3 — restructured to mapping + new peer):
```yaml
    layer2_expert_review:
      bullets:
        - "Group 0: spec-compliance-reviewer（AC 全满足）"
        - "Group 1: code-reviewer（P0=0, P1=0）"
        - "Group 2: test-runner + security-auditor + performance-optimizer（按 trigger 规则）"
        - "Expert 说 PASS 才算完成 — 不是 Blake 自己判断"

      # Phase 6-A.2 (2026-04-25): Hard requirement — Layer 2 reviewer count discipline
      # Phase 1-5 累积 3 次 self-review.md 替代 backend-architect 的 drift。
      hard_requirement_distinct_reviewers:
        rule: |
          Layer 2 MUST invoke ≥2 DISTINCT sub-agents:
          - code-reviewer (REQUIRED — every Layer 2 round)
          - PLUS ≥1 from layer2-audit.sh's KNOWN_REVIEWERS whitelist (canonical
            single source of truth — see `.tad/hooks/lib/layer2-audit.sh`
            top-of-file array). Choose by task fit (e.g., backend-architect for
            architecture handoffs; security-auditor for auth/secrets; etc.).
        rationale_single_source: |
          BA-P0-2 fix: SKILL does NOT inline-enumerate reviewer names. The
          canonical list lives in layer2-audit.sh KNOWN_REVIEWERS array. SKILL
          references that array. New reviewer types are added to the array,
          and SKILL automatically inherits — no SKILL/script drift.
        exception_express:
          rule: |
            *express path 仅需 code-reviewer (single expert OK per architecture.md
            'Express Handoff is NOT Review-Exemption' 2026-04-14).
          slug_detection: |
            layer2-audit.sh detects *express via word-boundary matching
            (case "$slug" in express|*-express|*-express-*|express-*) ;; esac).
            BA-P0-3 fix: NOT via task_type frontmatter (express is path-state,
            not in task_type enum {code|yaml|research|e2e|mixed|doc-only}).
        forbidden:
          - "self-review.md does NOT count as Layer 2 reviewer (Blake reviewing Blake)"
          - "feedback-integration.md does NOT count (synthesis doc, not review)"
          - "gate3-verdict.md does NOT count (Blake's own gate verdict)"
          - "Substituting domain expert with self-review = VIOLATION (AR-001 surface)"
        enforcement: "prompt-level-only via Blake SKILL text + layer2-audit.sh advisory"
        forbidden_implementations:
          # 5 items per BA-P0-1 baseline (was 4; +1 added)
          - "MUST NOT register PreToolUse hook to count reviewers"
          - "MUST NOT add to .claude/settings.json"
          - "MUST NOT return deny exit code from layer2-audit.sh"
          - "Anti-AR-001: 'this task is simple, code-reviewer covers it' is forbidden
             interpretation for non-*express paths — must add ≥1 domain expert by
             task fit"
          - "MUST NOT couple Layer 2 reviewer count to step4c audit script — Blake
             invokes sub-agents based on judgment; audit is downstream advisory"
```

**FR4 (P6-A.2 supplementary — layer2-audit.sh enhancement, BSD-portable, fork-free, machine-readable)**

Edit `.tad/hooks/lib/layer2-audit.sh`. Existing script ~135 lines; line 114 reports `Layer 2 audit PASS: %d reviewer artifacts found`.

**Required additions** (new logic, layered ON TOP of existing min-bytes filter — do not replace, P1-6):

```bash
# At top of script (after existing constants), add:
# BA-P0-2: canonical single source of truth for Layer 2 reviewer types
KNOWN_REVIEWERS_LIST="code-reviewer backend-architect security-auditor performance-optimizer ux-expert-reviewer api-designer data-analyst bug-hunter"
SUBSTITUTION_HEURISTICS_LIST="self-review feedback-integration gate3-verdict"

# Express path detection — CR-P0-6 fix: word-boundary, not substring
is_express_slug() {
  local slug="$1"
  case "$slug" in
    express|*-express|*-express-*|express-*) return 0 ;;
    *) return 1 ;;
  esac
}

# CR-P0-4 fix: use existing find -print0 + read -d '' loop pattern
detect_distinct_reviewers() {
  local dir="$1"
  local distinct_count=0
  local distinct_list=""
  local substitutions_list=""
  local unknown_list=""
  while IFS= read -r -d '' f; do
    local name="${f##*/}"
    name="${name%.md}"
    # CR-P0-4: case statement (BSD-portable, fork-free, faster than grep)
    case " $KNOWN_REVIEWERS_LIST " in
      *" $name "*)
        distinct_list="$distinct_list $name"
        distinct_count=$((distinct_count + 1))
        ;;
      *)
        case " $SUBSTITUTION_HEURISTICS_LIST " in
          *" $name "*) substitutions_list="$substitutions_list $name" ;;
          *) unknown_list="$unknown_list $name" ;;
        esac
        ;;
    esac
  done < <(find "$dir" -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null)
  # Output structured machine-readable format (CR-P0-5 fix)
  printf 'DISTINCT_COUNT=%d\n' "$distinct_count"
  printf 'DISTINCT_LIST=%s\n' "${distinct_list# }"
  printf 'SUBSTITUTIONS=%s\n' "${substitutions_list# }"
  printf 'UNKNOWN=%s\n' "${unknown_list# }"
}
```

**Verdict logic** (added to existing PASS path):
- IF `DISTINCT_COUNT >= 2` → `Layer 2 audit PASS: <N> distinct reviewers found: <list>` + existing "artifacts found" line preserved (additive per impl decision #10)
- ELSE IF `DISTINCT_COUNT == 1` AND `is_express_slug "$slug"` → `Layer 2 audit PASS: 1 distinct reviewer (express path exception): <list>` + structured `WARN_REVIEWER_COUNT=1_EXPRESS_OK` line
- ELSE IF `DISTINCT_COUNT == 1` AND NOT express → `Layer 2 audit WARN: 1 distinct reviewer (need ≥2 unless *express); found: <list>` + structured `WARN_REVIEWER_COUNT=1` line + exit 0 (advisory)
- ELSE IF `DISTINCT_COUNT == 0` AND substitutions_list non-empty → existing FAIL path + structured `WARN_REVIEWER_COUNT=0_SUBSTITUTIONS_ONLY` line + exit 1
- Unknown names go to stderr WARN list (logged, not silently dropped — CR-P0-4 fix)

**Exit code semantics preserved (BA-P1-5 fix):**
- 0 = PASS or WARN (advisory)
- 1 = existing FAIL paths (no reviewer files at all, or substitutions-only)
- 2 = invalid slug (existing)
- **No new exit 3** — verified via `grep -cE '^[ \t]*exit (0|1|2)' .tad/hooks/lib/layer2-audit.sh` returns existing count

**FR5 (P6-A — fixture: AC drift catch test)**

Create `.tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh`. Tests reproduce 3 known AC drift cases (CR-P1-4 fix: regression test, NOT catch simulation):

```
Case 1: Reproduce Phase 5 AC-G2 — 3-field grep regex on 2-field grep -n single-file output.
  Fixture creates a 1-line test file, runs the buggy command, asserts output ≠ Expected.
Case 2: Reproduce Phase 4 Anti-Epic-1 grep scope issue — fail-closed grep without --exclude-dir.
  Fixture asserts wide grep returns >0 hits; narrowed grep returns 0 hits.
Case 3: Reproduce CR-P0-1 from this very handoff — markdown-table pipe-escape.
  Fixture: `printf 'a\nb\n' | grep -cE 'a\|b'` returns 0; same with `'a|b'` returns 2. Asserts ≠.
```

Test runner outputs 3 PASS markers (one per case where the bug IS reproduced; meaning step1d would have caught at draft time).

**FR6 (P6-A — fixture: Layer 2 reviewer-name detection)**

Create `.tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh`. P1-5 fix: explicit `LAYER2_AUDIT_REVIEW_ROOT` env-var hook needed because the script currently hardcodes `.tad/evidence/reviews/blake/<slug>/`. Test creates temp dir, sets env, invokes audit.

5 cases:
1. Temp dir with `code-reviewer.md + backend-architect.md` → expect `DISTINCT_COUNT=2`
2. Temp dir with `code-reviewer.md + self-review.md` → expect `DISTINCT_COUNT=1` + `SUBSTITUTIONS=self-review`
3. Temp dir with `code-reviewer.md` only, slug `phase6a-process-quality-foundation` (non-express) → expect `WARN_REVIEWER_COUNT=1`
4. Same dir, slug `express-bugfix-styling` → expect `WARN_REVIEWER_COUNT=1_EXPRESS_OK` (PASS exit 0)
5. Temp dir with `code-reviewer.md + backend-architect.md + security-auditor.md` → expect `DISTINCT_COUNT=3`

### 3.2 Non-Functional Requirements

- **NFR1 (Performance)**: layer2-audit.sh enhanced still <100ms wall (per architecture.md 2026-04-07 single-pass).
- **NFR2 (Portability)**: macOS BSD bash 3.2 + grep + sed + jq + find -print0; 禁 `grep -P`.
- **NFR3 (Anti-Epic-1)**: Zero hooks added; zero `permissions.deny` additions; layer2-audit.sh advisory CLI; step1d Alex SKILL 文字约束.
- **NFR4 (Backward Compat)**: Existing layer2-audit.sh exit codes preserved (0/1/2). Pre-Phase-6 handoffs without dual-column §9.1 don't break.
- **NFR5 (Idempotent)**: layer2-audit.sh repeated calls return same verdict.
- **NFR6 (Single Source of Truth)**: Reviewer name list lives ONLY in layer2-audit.sh KNOWN_REVIEWERS; SKILL references via prose.

### 3.3 Optimization Target

N/A.

---

## 4. Technical Design

### 4.1 Architecture Overview

```
[Alex drafts handoff]
   ↓
   step0_5 → step1 → step1b → step1c
   ↓
   step1d (NEW per FR1)
       Sub-rule 1: Author commands in raw form, dry-run from raw
       Sub-rule 2: Syntax-validate even post-impl rows
       Sub-rule 3: Re-derive every pre-impl AC value with one-liner (no quote)
       For each §9.1 row:
         - Classify pre-impl / post-impl
         - Run + paste output to "Verified Output" col
       Append AC Dry-Run Log to §6.5
   ↓
   step2 → ... (rest unchanged)

[Blake Gate 3 v2 Layer 2]
   ↓
   gate3_v2.layer2_expert_review.hard_requirement_distinct_reviewers
       MUST: code-reviewer + ≥1 from KNOWN_REVIEWERS (audit script canonical list)
       NOT count: SUBSTITUTION_HEURISTICS_LIST (self-review, feedback-integration, gate3-verdict)
       Exception: *express slug → code-reviewer alone OK
   ↓
   Sub-agent invocation results land in .tad/evidence/reviews/blake/<slug>/<reviewer-agent-name>.md
   ↓
   Alex *accept step4c → layer2-audit.sh <slug> (advisory CLI)
       Detect distinct reviewer names via find -print0 + case statement
       Output structured machine-readable lines (DISTINCT_COUNT, etc.)
       Apply express-path word-boundary detection
   ↓
   Gate 4 verdict
```

### 4.2 Component Specifications

详见 §6.

### 4.3 Data Models

**§9.1 dual-column row example** (FR2):

```markdown
| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| 1 | AC-X-a (existing) | pre-impl-verifiable | `grep -c 'pattern' file.md` | ≥1 | `1` ✅ |
| 2 | AC-Y-a (NEW) | post-impl-verifiable | `test -f new-file.sh` | exit 0 | (post-impl) |
```

**Reviewer name canonical source** (§FR4 + BA-P0-2 single source of truth):

```bash
# .tad/hooks/lib/layer2-audit.sh top-of-file:
KNOWN_REVIEWERS_LIST="code-reviewer backend-architect security-auditor performance-optimizer ux-expert-reviewer api-designer data-analyst bug-hunter"
SUBSTITUTION_HEURISTICS_LIST="self-review feedback-integration gate3-verdict"
```

Blake SKILL refers via prose: "from layer2-audit.sh's KNOWN_REVIEWERS whitelist". No enumeration in SKILL.

**Express path word-boundary detection** (CR-P0-6 fix):
```bash
case "$slug" in
  express|*-express|*-express-*|express-*) is_express ;;
  *) not_express ;;
esac
# This matches: "express", "phase6-express", "express-bugfix", "phase6-express-styling"
# This does NOT match: "expression", "compress", "espresso"
```

### 4.4 API Specifications

N/A.

### 4.5 User Interface Requirements

N/A.

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

- [x] 是

**搜索证据**：
```bash
grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'
# Output: 2 (AR-001 anchor in place)

grep -nE '^    layer2_expert_review:' .claude/skills/blake/SKILL.md
# Output: line 906 (confirmed restructure target)

sed -n '906,913p' .claude/skills/blake/SKILL.md
# Output: flat YAML list of 4 bullets — confirmed CR-P0-2 (cannot graft mapping under list)

grep -nE '^## 9' .tad/templates/handoff-a-to-b.md
# Output: §9.1 = Spec Compliance Checklist, §9.2 = Expert Review Status — confirmed CR-P1-1
```

### MQ2: 函数存在性验证

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| step1c grounding | .claude/skills/alex/SKILL.md | ~1020 | `step1c: name: "Grounding Pass..."` | ✅ |
| layer2_expert_review (flat list) | .claude/skills/blake/SKILL.md | 906-913 | `layer2_expert_review:` then 4 bullets | ✅ |
| layer2-audit qualified counter | .tad/hooks/lib/layer2-audit.sh | 114 | `Layer 2 audit PASS: %d reviewer artifacts found` | ✅ |
| Template §9.1 Spec Compliance | .tad/templates/handoff-a-to-b.md | 490 | `## 9.1 Spec Compliance Checklist (for automated verification)` | ✅ |

### MQ3: 数据流完整性

| 后端字段 | 用途说明 | 前端组件 | 是否显示 | 不显示原因 |
|---------|---------|---------|---------|-----------|
| §9.1 Verification Type col | Alex/Blake 责任划分 | handoff §9.1 表 | ✅ | — |
| §9.1 Verified Output col | Alex step1d 实跑证据 | handoff §9.1 表 | ✅ | — |
| AC Dry-Run Log | Alex step1d 完成证明 | handoff §6.5 | ✅ | — |
| KNOWN_REVIEWERS array | reviewer canonical source | layer2-audit.sh top | ✅ (引用 from SKILL) | — |
| DISTINCT_COUNT structured line | machine-readable verdict | layer2-audit.sh stdout | ✅ for AC matching | — |

### MQ4: 视觉层级

N/A.

### MQ5: 状态同步

| 数据 | 存储位置 1 | 存储位置 2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| Reviewer canonical list | layer2-audit.sh KNOWN_REVIEWERS | Blake SKILL prose ref | Edit time | 引用 (single source) |
| §9.1 Verified Output | Alex step1d | Blake Gate 3 verification | step1d → Gate 3 | 单向 |
| Layer 2 reviewer artifacts | Blake sub-agent invoke | reviews/blake/<slug>/<name>.md | Layer 2 round | 写入 |

✅ 单向 + single source of truth.

---

## 6. Implementation Steps

### 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | `.claude/skills/alex/SKILL.md` | Add `step1d` block to `handoff_creation_protocol.workflow` (insertion line-anchored §6.6) | `grep -A 5 'step1d:' .claude/skills/alex/SKILL.md \| grep -c 'AC Dry-Run'` ≥ 1 | 30 min |
| 2 | `.tad/templates/handoff-a-to-b.md` | **§9.1** (CR-P1-1: Spec Compliance Checklist, NOT §9.2) add 2 columns + doc comment | `grep -A 2 'Spec Compliance' .tad/templates/handoff-a-to-b.md \| grep -c 'Verification Type'` ≥ 1 | 15 min |
| 3 | `.claude/skills/blake/SKILL.md` | Restructure `layer2_expert_review` list→mapping + add `hard_requirement_distinct_reviewers:` peer | `grep -A 30 'hard_requirement_distinct_reviewers:' .claude/skills/blake/SKILL.md \| grep -c 'KNOWN_REVIEWERS'` ≥ 1 | 45 min |
| 4 | `.tad/hooks/lib/layer2-audit.sh` | Add KNOWN_REVIEWERS, SUBSTITUTION_HEURISTICS, is_express_slug, detect_distinct_reviewers; integrate into existing PASS/FAIL paths | `bash .tad/hooks/lib/layer2-audit.sh phase5-evolve-data-capture 2>&1 \| grep -c '^DISTINCT_COUNT='` ≥ 1 | 60 min |
| 5 | `.tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh` | NEW — 3 regression cases per FR5 | `bash .tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh \| grep -c 'PASS'` ≥ 3 | 45 min |
| 6 | `.tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh` | NEW — 5 cases per FR6 with LAYER2_AUDIT_REVIEW_ROOT env var | `bash .tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh \| grep -c 'PASS'` = 5 | 45 min |

**Estimated total: ~4 hours** (Blake)

### 6.2 Stage Sequencing (BA-P0-5 fix — explicit D.1-D.5)

**Stage A** (single-sequential agent — same SKILL.md files):
1. Micro-Task 1 (Alex SKILL step1d)
2. Micro-Task 3 (Blake SKILL restructure + hard_requirement)

**Stage B** (parallel-coordinator OK — independent files):
3. Micro-Task 2 (handoff template) ║ Micro-Task 4 (layer2-audit.sh)

**Stage C** (parallel-coordinator OK — fixtures independent):
4. Micro-Task 5 (AC drift fixture) ║ Micro-Task 6 (Layer 2 reviewer fixture)

**Stage D — explicit ordering**:
- **D.1**: Run all fixtures (FR5 + FR6) — confirm 3 + 5 PASS markers
- **D.2**: Run §9.1 AC verification commands (this handoff's own §9.1 as smoke test) — 11 ACs
- **D.3**: **Layer 2 sub-agent invocations land** — Blake invokes ≥2 distinct sub-agents (code-reviewer required + ≥1 from KNOWN_REVIEWERS); reviewer files written to `.tad/evidence/reviews/blake/phase6a-process-quality-foundation/<reviewer-name>.md`
- **D.4**: **Run new audit script on this handoff's slug** — `bash layer2-audit.sh phase6a-process-quality-foundation` should report `DISTINCT_COUNT >= 2` (because D.3 just installed the rule + D.4 verifies via the script enhanced in Stage B)
- **D.5**: Run integration test on Phase 5 slug (retroactive WARN proof) — verifies the new audit catches historical drift

### 6.3 Files to Create

```
.tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh         # FR5
.tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh # FR6
```

### 6.4 Files to Modify

```
.claude/skills/alex/SKILL.md          # FR1
.claude/skills/blake/SKILL.md         # FR3 (list→mapping restructure)
.tad/templates/handoff-a-to-b.md      # FR2 — §9.1 (NOT §9.2)
.tad/hooks/lib/layer2-audit.sh        # FR4
```

### 6.5 Grounded Against (Alex step1c — read 2026-04-25)

- `.claude/skills/alex/SKILL.md` (head 50 + grep step1c at 2026-04-25 16:30 — confirmed step1c at line ~1020)
- `.claude/skills/blake/SKILL.md` (lines 906-913 read 2026-04-25 18:00 — confirmed flat YAML list structure)
- `.tad/templates/handoff-a-to-b.md` (full read prior session — §9.1 Spec Compliance + §9.2 Expert Review confirmed at 2026-04-25 18:00 via grep)
- `.tad/hooks/lib/layer2-audit.sh` (135 lines + line 114 message format confirmed at 2026-04-25 16:30)
- `.tad/project-knowledge/architecture.md` (line 455+ AC drift entry self-authored 2026-04-25 17:00)
- `.tad/active/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md` (archived; §9.2 single-column format read for upgrade reference)
- `.tad/evidence/fixtures/phase6/` — `(new — will be created)`

### 6.6 Insertion Point Map (BA-P1-2 + CR-P1-2 fix — line-anchored)

| Add | File | Insert AFTER (line + sibling block name) | Insert BEFORE (line + sibling block name) | Indent |
|-----|------|------|------|--------|
| `step1d:` block | `.claude/skills/alex/SKILL.md` `handoff_creation_protocol.workflow` | step1c block end (after `forbidden_implementations:` list of step1c, ~line 1100 — verify with `grep -n 'step1c' .claude/skills/alex/SKILL.md`) | `step2:` block start of handoff_creation_protocol (NOT other protocols' step2 — there are 15 `step2:` total in SKILL.md). **Use protocol path: `handoff_creation_protocol.workflow.step2`** at ~line 1107-1110 (Expert Selection). | 4-space (sibling to step1c) |
| `bullets:` reorganization + `hard_requirement_distinct_reviewers:` | `.claude/skills/blake/SKILL.md` `gate3_v2.layer2_expert_review` | line 906 `layer2_expert_review:` line | line 914 `research_compliance:` line | 6-space (under gate3_v2.layer2_expert_review.bullets); 4-space for new peer hard_requirement_distinct_reviewers under layer2_expert_review |
| §9.1 dual-column header replacement | `.tad/templates/handoff-a-to-b.md` line 492 (current 4-col header) | line 491 `## 9.1 Spec Compliance Checklist` line | line 493 (existing row template) | 0-space (table) |
| §9.1 doc comment block | `.tad/templates/handoff-a-to-b.md` | line 491 `## 9.1` header line | line 492 (replaced header above) | 0-space |

### 6.7 AC Dry-Run Log (Alex step1d 2026-04-25 — DOGFOOD with 3 self-defending sub-rules — corrected per CR-P0-3)

**Sub-rule 1 applied**: Commands authored in RAW form below; markdown table cells will escape pipes when rendered.
**Sub-rule 2 applied**: Even post-impl-verifiable rows syntax-validated.
**Sub-rule 3 applied**: AC values re-derived from actual command output, NOT quoted from §6.7 or §9.1.

**AC Dry-Run Log** (Alex step1d at 2026-04-25 18:30):

| AC | Type | Dry-Run Result |
|----|------|----------------|
| AC-P6A-1-a (step1d block exists in Alex SKILL post-impl) | post-impl-verifiable | (post-impl — Blake runs at Gate 3) |
| AC-P6A-1-b (step1d forbidden_impl = 5 items) | post-impl-verifiable | (post-impl) |
| AC-P6A-1-c (step1d AFTER step1c BEFORE step2 in handoff_creation_protocol) | post-impl-verifiable | (post-impl) |
| AC-P6A-2-a (hard_requirement block exists) | post-impl-verifiable | (post-impl) |
| AC-P6A-2-b (block references KNOWN_REVIEWERS) | post-impl-verifiable | (post-impl) |
| AC-P6A-2-c (forbidden lists self-review + feedback-integration + gate3-verdict) | post-impl-verifiable | (post-impl) |
| AC-P6A-2-d (exception_express references AR-001) | post-impl-verifiable | (post-impl) |
| AC-P6A-3-a (template §9.1 has Verification Type col) | post-impl-verifiable | (post-impl) |
| AC-P6A-3-b (doc comment mentions pre/post impl) | post-impl-verifiable | (post-impl) |
| AC-P6A-4-a (audit reports DISTINCT_COUNT structured line) | post-impl-verifiable | (post-impl) |
| AC-P6A-4-b (Phase 5 slug → WARN_REVIEWER_COUNT=1) | post-impl-verifiable | (post-impl — needs new layer2-audit) |
| AC-P6A-4-c (substitutions excluded from distinct count) | post-impl-verifiable | (post-impl) |
| AC-P6A-4-d (exit 0/1/2 preserved) | post-impl-verifiable | (post-impl) |
| AC-P6A-5-a (AC drift fixture 3 PASS) | post-impl-verifiable | (post-impl — fixture new) |
| AC-P6A-6-a (Layer 2 reviewer fixture 5 PASS) | post-impl-verifiable | (post-impl) |
| AC-G1 (no permissions.deny additions) | **pre-impl-verifiable** | RAW: `jq '.permissions.deny \| length' .claude/settings.json` → output `0` ✅ matches expected |
| AC-G2 (no `"deny"` literal in layer2-audit.sh — CR-P0-3 corrected from prior `exit 1` mismatch) | **pre-impl-verifiable** | RAW: `grep -c '"deny"' .tad/hooks/lib/layer2-audit.sh` → output `0` ✅ matches expected |
| AC-G3 (no fail-closed in new fixtures) | post-impl-verifiable | (post-impl — fixtures new; Sub-rule 2 syntax check: `grep -c 'fail-closed' file.sh` is valid bash, will work after files exist) |
| AC-G4 (≥1 architecture.md entry conditional) | post-impl-verifiable | (post-impl — Blake/Alex add per discovery) |

**Step1d self-result**: 2/2 pre-impl-verifiable PASS (matched expected); 17/17 post-impl-verifiable correctly deferred + Sub-rule 2 syntax-validated. **AC-G2 quote-from-memory bug from v1 detected and corrected** (was `'exit 1'` → 1 → wrong; now `'"deny"'` → 0 → matches Sub-rule 3). 

---

## 7. File Structure

(See §6.3 + §6.4)

---

## 8. Testing Requirements

### 8.1 Fixture Tests

**FR5 fixture** (`p6a-ac-drift-catch-test.sh`) — 3 regression cases per CR-P1-4:
- Case 1: Phase 5 AC-G2 grep -n single-file 2-field reproduction
- Case 2: Phase 4 Anti-Epic-1 grep scope reproduction
- Case 3: CR-P0-1 markdown-table pipe-escape reproduction (`'a\|b'` → 0 vs `'a|b'` → 2)

**FR6 fixture** (`p6a-layer2-reviewer-detect-test.sh`) — 5 cases per FR6 spec, with `LAYER2_AUDIT_REVIEW_ROOT` env var (P1-5).

### 8.2 Integration Tests

- Run enhanced `layer2-audit.sh phase5-evolve-data-capture` (archived slug). Expected: `WARN_REVIEWER_COUNT=1` (only code-reviewer; substitutions filtered) — proves retroactive detection works (intentional, see §10.1).
- Run `layer2-audit.sh phase6a-process-quality-foundation` (this handoff's slug) after Stage D.3 lands. Expected: `DISTINCT_COUNT >= 2` (this Layer 2 review has ≥2 distinct).

### 8.3 Edge Cases

- **EC1**: Reviewer file with non-canonical name (e.g., `extra-domain-expert.md`). Goes to UNKNOWN list, not silently dropped.
- **EC2**: Empty `reviews/blake/<slug>/` dir. Existing FAIL path preserved.
- **EC3**: *express path slug — word-boundary detection per CR-P0-6 (NOT substring).
- **EC4**: Pre-Phase-6 handoffs — exemption_pre_phase6 AND logic per BA-P1-1.

### 8.4 Test Evidence Required

- [ ] p6a-ac-drift-catch-test.sh outputs 3 PASS markers
- [ ] p6a-layer2-reviewer-detect-test.sh outputs 5 PASS markers
- [ ] integration test on Phase 5 slug shows `WARN_REVIEWER_COUNT=1` structured line
- [ ] integration test on this handoff's own slug after Blake completes shows `DISTINCT_COUNT >= 2`

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist (List of N — DUAL-COLUMN dogfood)

> **Verification Type column** (Phase 6-A.1 self-dogfood):
> - `pre-impl-verifiable` — Alex dry-runs at step1d
> - `post-impl-verifiable` — Blake runs at Gate 3 v2 Layer 1
>
> **Pipe-escape note**: `\|` in cells = markdown table escape; un-escape to `|` when running.

| # | Acceptance Criterion | Verification Type | Verification Method (raw form) | Expected Evidence | Verified Output (Alex step1d 2026-04-25) |
|---|---|---|---|---|---|
| 1 | AC-P6A-1-a (step1d block contains "AC Dry-Run") | post-impl | `grep -A 5 'step1d:' .claude/skills/alex/SKILL.md \| grep -c 'AC Dry-Run'` | ≥ 1 | (post-impl) |
| 2 | AC-P6A-1-b (step1d forbidden_impl = 5 items, BA-P1-3) | post-impl | `awk '/^    step1d:/,/^    step[2-9]:/' .claude/skills/alex/SKILL.md \| grep -c '^[ ]*- "MUST NOT'` | = 5 (was ≥4 in v1) | (post-impl) |
| 3 | AC-P6A-1-c (step1d AFTER step1c BEFORE step2 — CR-P1-7) | post-impl | `awk '/^    step1c:/{c=NR} /^    step1d:/{d=NR} /^    step2:/{t=NR} END{exit !(c<d && d<t)}' .claude/skills/alex/SKILL.md && echo OK` | "OK" | (post-impl) |
| 4 | AC-P6A-2-a (hard_requirement_distinct_reviewers exists) | post-impl | `grep -c 'hard_requirement_distinct_reviewers:' .claude/skills/blake/SKILL.md` | ≥ 1 | (post-impl) |
| 5 | AC-P6A-2-b (BA-P0-4 fix — references canonical not enumerates) | post-impl | `grep -cE 'KNOWN_REVIEWERS\|layer2-audit\.sh' .claude/skills/blake/SKILL.md` (raw `\|` is markdown escape; un-escape to `\|` becomes `|`) | ≥ 1 | (post-impl) |
| 6 | AC-P6A-2-c (forbidden lists 3 substitutions) | post-impl | `awk '/hard_requirement_distinct_reviewers:/,/forbidden_implementations:/' .claude/skills/blake/SKILL.md \| grep -cE 'self-review\|feedback-integration\|gate3-verdict'` | ≥ 3 (one per substitution token) | (post-impl) |
| 7 | AC-P6A-2-d (exception_express references AR-001) | post-impl | `awk '/exception_express:/,/forbidden:/' .claude/skills/blake/SKILL.md \| grep -c 'AR-001\|Express Handoff'` | ≥ 1 | (post-impl) |
| 8 | AC-P6A-3-a (template §9.1 has both new column headers) | post-impl | `grep -c 'Verification Type\|Verified Output' .tad/templates/handoff-a-to-b.md` (raw `|` un-escape) | ≥ 2 | (post-impl) |
| 9 | AC-P6A-3-b (doc comment mentions pre/post impl) | post-impl | `grep -cE 'pre-impl-verifiable\|post-impl-verifiable' .tad/templates/handoff-a-to-b.md` | ≥ 2 | (post-impl) |
| 10 | AC-P6A-4-a (audit emits structured DISTINCT_COUNT) | post-impl | `bash .tad/hooks/lib/layer2-audit.sh phase5-evolve-data-capture 2>&1 \| grep -cE '^DISTINCT_COUNT='` | ≥ 1 | (post-impl) |
| 11 | AC-P6A-4-b (Phase 5 slug emits WARN_REVIEWER_COUNT=1, CR-P0-5 word-anchored) | post-impl | `bash .tad/hooks/lib/layer2-audit.sh phase5-evolve-data-capture 2>&1 \| grep -cE '^WARN_REVIEWER_COUNT=1$'` | = 1 | (post-impl) |
| 12 | AC-P6A-4-c (substitutions filtered from DISTINCT_COUNT) | post-impl | `bash .tad/hooks/lib/layer2-audit.sh phase5-evolve-data-capture 2>&1 \| grep -E '^SUBSTITUTIONS=' \| grep -cE 'self-review\|feedback-integration'` | ≥ 1 | (post-impl) |
| 13 | AC-P6A-4-d (exit codes preserved 0/1/2 only, BA-P1-5) | post-impl | `grep -cE '^[ \t]*exit ([0-9]+)' .tad/hooks/lib/layer2-audit.sh \| awk '{print}' && grep -nE '^[ \t]*exit (3\|4\|5\|6\|7\|8\|9)' .tad/hooks/lib/layer2-audit.sh \| wc -l` | first ≥ existing count, second = 0 | (post-impl) |
| 14 | AC-P6A-5-a (AC drift fixture exists, 3 cases PASS) | post-impl | `test -x .tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh && bash .tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh \| grep -c 'PASS'` | ≥ 3 | (post-impl) |
| 15 | AC-P6A-6-a (Layer 2 reviewer fixture exists, 5 cases PASS) | post-impl | `test -x .tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh && bash .tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh \| grep -c 'PASS'` | = 5 | (post-impl) |
| 16 | AC-G1 (no permissions.deny additions) | **pre-impl-verifiable** | `jq '.permissions.deny \| length' .claude/settings.json` (un-escape `\|` to `\|` raw) | = 0 | `0` ✅ matches |
| 17 | AC-G2 (no `"deny"` literal in audit) | **pre-impl-verifiable** | `grep -c '"deny"' .tad/hooks/lib/layer2-audit.sh` | = 0 | `0` ✅ matches |
| 18 | AC-G3 (no fail-closed in new fixtures) | post-impl | `grep -c 'fail-closed' .tad/evidence/fixtures/phase6/*.sh 2>/dev/null \| awk -F: '{s+=$2}END{print s+0}'` | = 0 | (post-impl) |

(Sub-rule 1 raw forms preserved above; Sub-rule 2 syntax validation via `bash -n` for all shell constructs; Sub-rule 3 AC-G1 + AC-G2 actual output pasted, not quoted from elsewhere.)

### 9.2 Expert Review Status (Alex 必填)

(Per template: §9.2 = Expert Review Status — see §9.4 below.)

### 9.3 Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/phase6a-process-quality-foundation/code-reviewer.md
  - .tad/evidence/reviews/blake/phase6a-process-quality-foundation/backend-architect.md
  # Per FR3 hard_requirement_distinct_reviewers — this very handoff's Layer 2 must comply.

gate_verdicts:
  - .tad/evidence/reviews/blake/phase6a-process-quality-foundation/gate3-verdict.md

completion:
  - .tad/active/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md

fixture_results:
  - .tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh
  - .tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh
  - .tad/evidence/fixtures/phase6/results.tsv

integration_test:
  - .tad/evidence/fixtures/phase6/integration-layer2-on-phase5.log

knowledge_updates:
  - .tad/project-knowledge/architecture.md (conditional per AC-G4)
```

---

## 9.4 Expert Review Status (Alex 必填)

### Audit Trail (P1.5 dogfood — 11 P0 + 7 P1 + 6 P2 integrated 2026-04-25)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: §9.2 row 4 markdown-table `\|` literal pipe regex bug | FR1 step1d Sub-rule 1 + §9.1 row 5 raw-form note | Resolved |
| code-reviewer | CR-P0-2: layer2_expert_review is flat list, can't graft hard_requirement | FR3 explicit list→mapping restructure with before/after YAML | Resolved |
| code-reviewer | CR-P0-3: §6.7 AC-G2 quoted wrong command + wrong number (`exit 1` → 1) | §6.7 corrected to actual AC-G2 (`"deny"` → 0); FR1 Sub-rule 3 prevents recurrence | Resolved |
| code-reviewer | CR-P0-4: FR4 reviewer-name extraction underspecified | FR4 explicit `find -print0 + while read -d '' + case` BSD-portable | Resolved |
| code-reviewer | CR-P0-5: AC-P6A-4-b regex matches "11 distinct" substring | §9.1 row 11: structured machine-readable `^WARN_REVIEWER_COUNT=1$` anchored | Resolved |
| code-reviewer | CR-P0-6: `*express` glob false-positive on `expression` | FR4 + §4.3 word-boundary case `express\|*-express\|*-express-*\|express-*` | Resolved |
| code-reviewer | CR-P1-1: handoff calls Spec Compliance §9.2 but template's actual §9.2 is Expert Review | FR2 + §6.6 + §6.4 corrected to §9.1 | Resolved |
| code-reviewer | CR-P1-2: §6.6 indentation rule needs YAML path | §6.6 protocol-path-anchored (`handoff_creation_protocol.workflow.step2`) | Resolved |
| code-reviewer | CR-P1-3: exit-code matrix missing for new states | FR4 explicit "exit 0/1/2 preserved, no exit 3" + AC-P6A-4-d | Resolved |
| code-reviewer | CR-P1-4: FR5 fixture cannot test "step1d catches" (prose) | FR5 reworded as regression test (3 reproduction cases) | Resolved |
| code-reviewer | CR-P1-5: FR6 needs LAYER2_AUDIT_REVIEW_ROOT env var | FR6 + §8.1 explicit env var hook | Resolved |
| code-reviewer | CR-P1-6: FR4 must preserve existing min_bytes filter + symlink logic | FR4 explicit "layered ON TOP, not IN PLACE OF" | Resolved |
| code-reviewer | CR-P1-7: AC-P6A-1-c lacks §9.1 verification row | §9.1 row 3 added with awk ordering check | Resolved |
| code-reviewer | CR-P2-1: §6.7 "2/2 pre-impl PASS" arithmetic | §6.7 updated; pre-impl rows reclassified per CR-P0-3 | Resolved |
| code-reviewer | CR-P2-2: §10.1 *express phrasing | §10.1 Critical Warnings clarified ≥1 not ≥0 | Resolved |
| code-reviewer | CR-P2-3 to P2-6 | Smaller cosmetic fixes | Resolved (in-text) |
| backend-architect | BA-P0-1: forbidden_implementations 4 items vs 5+ baseline | FR1 + FR3 both have 5 items now (added 5th item) | Resolved |
| backend-architect | BA-P0-2: Reviewer whitelist two sources, drift risk | FR3 prose references KNOWN_REVIEWERS (single source); SKILL doesn't enumerate; §11.2 #11 records contract | Resolved |
| backend-architect | BA-P0-3: FR4 `task_type: express` not in enum | FR4 dropped task_type:express; uses only word-boundary slug | Resolved |
| backend-architect | BA-P0-4: AC-P6A-2-b incompatible with P0-2 fix | AC-P6A-2-b changed to verify reference (`KNOWN_REVIEWERS\|layer2-audit\.sh`) not enumeration | Resolved |
| backend-architect | BA-P0-5: §6.2 Stage D ordering ambiguous | §6.2 Stage D rewritten as D.1-D.5 explicit | Resolved |
| backend-architect | BA-P1-1: exemption_pre_phase6 OR logic dangerous | FR1 step1d.exemption_pre_phase6 AND not OR | Resolved |
| backend-architect | BA-P1-2: §6.6 step2 line ambiguity (15 step2 in SKILL) | §6.6 protocol path + line anchor specified | Resolved |
| backend-architect | BA-P1-3: AC-P6A-1-b "≥4" should be "= 5" | §9.1 row 2 expected = 5 | Resolved |
| backend-architect | BA-P1-4: §1.3 sub-handoff vs new phase criterion | §1.3 explicit "P6-X = process; new Phase = assumption" | Resolved |
| backend-architect | BA-P1-5: WARN exit code preserve check | FR4 + AC-P6A-4-d explicit "no new exit 3" | Resolved |
| backend-architect | BA-P2-1 to P2-3 | Smaller renames + edge case docs | Resolved (in-text) |

### Experts Selected

1. **code-reviewer** — Phase 6-A is shell + SKILL.md text + template + fixtures; correctness/portability/AC verifiability is primary risk
2. **backend-architect** — Phase 6-A introduces hard contract across 4 subsystems; cross-system consistency is primary risk. **Self-dogfood Layer 2**: this very handoff's Layer 2 review uses ≥2 distinct sub-agents (code-reviewer + backend-architect), validating FR3 rule on its own delivery.

### Overall Assessment (post-integration)

- code-reviewer: **PASS** (6 P0 + 7 P1 + 6 P2 fully integrated)
- backend-architect: **PASS** (5 P0 + 5 P1 + 3 P2 fully integrated, 0 deferred)

### Expert Review Files

- `.tad/evidence/reviews/alex/phase6a-process-quality-foundation/code-reviewer.md` (~200 lines, ~20K bytes)
- `.tad/evidence/reviews/alex/phase6a-process-quality-foundation/backend-architect.md`

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **Anti-Epic-1**: 所有改动 prompt-level only。step1d 是 Alex SKILL 文字; hard_requirement_distinct_reviewers 是 Blake SKILL 文字; layer2-audit.sh 仍是 advisory CLI exit 0/1/2，不影响 tool 调用。
- ⚠️ **Self-dogfood Layer 2 (this very handoff)**: Blake Gate 3 Layer 2 **必须**调 ≥2 distinct sub-agents (code-reviewer + ≥1 from KNOWN_REVIEWERS). self-review.md 和 feedback-integration.md 不算。这是 P6-A.2 规则的 first real-use scenario。
- ⚠️ **Reviewer whitelist single source of truth (BA-P0-2)**: KNOWN_REVIEWERS 数组住 layer2-audit.sh top；Blake SKILL 引用，不枚举。新 sub-agent 类型加进 array → SKILL 自动继承。
- ⚠️ **CR-P0-1 markdown pipe-escape (Sub-rule 1)**: §9.1 cells 中 `\|` 是表格 escape，bash 运行时 un-escape 为 `|`。step1d Sub-rule 1 强制 raw-form dry-run，不从 rendered form 跑。
- ⚠️ **CR-P0-3 quote-from-memory (Sub-rule 3)**: §6.7 dry-run log 不能从 §9.1 quote AC 值；必须 re-derive from actual command output。v1 的 AC-G2 错就是违反此规则。
- ⚠️ **AC-P6A-4-b "Phase 5 retroactive WARN"**: **有意为之的诊断特性**。Phase 5 acceptance 当时只有 code-reviewer + self-review，新 audit 在 Phase 6 后 retroactive 跑出 WARN — 证明新机制能识别历史 drift，不是回头修。
- ⚠️ **layer2-audit reviewer name whitelist extensible**: KNOWN_REVIEWERS 不是 hardcoded final。新 sub-agent 类型 (e.g., docs-writer, devops-engineer) 第一次被用作 Layer 2 reviewer 时把名字加入 array。Blake SKILL 自动跟随。
- ⚠️ **Express path word-boundary (CR-P0-6)**: `expression`, `compress`, `espresso` 等字符串**不**会被误判为 *express path。case pattern: `express|*-express|*-express-*|express-*`。
- ⚠️ **Stage A/C single-sequential**: Stage A 同 SKILL.md 文件不并行；Stage C 内 fixture 间互独立可并行但 fixture 内顺序保持。

### 10.2 Known Constraints

- macOS BSD shell only (bash 3.2 + grep + sed + jq + find -print0)
- 禁 `grep -P`
- layer2-audit.sh enhancement <100ms wall

### 10.3 Sub-Agent 使用建议

- [x] **parallel-coordinator** — Stage B/C 可并行；Stage A 必 sequential
- [x] **bug-hunter** — 如 layer2-audit.sh BSD 平台某些 reviewer 名 detect 失败
- [x] **test-runner** — Stage D.1 跑 fixtures + integration

---

## 11. Decision Summary

### 11.1 Boundary Decisions (Socratic 2026-04-25)

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | AC dry-run trigger location | step1.5 / Gate 2 / hook / template col | **Alex SKILL step1d** | Recommended; Alex 本人能修，不晚到 Blake 阶段 |
| 2 | AC dry-run scope | All §9.1 / multi-pipe only / G-class only | **All §9.1 verification commands** | Recommended; 5 min overhead 防 100% drift |
| 3 | Layer 2 ≥2 reviewer | hard / soft / gradient / dual-layer | **Hard ≥2 distinct sub-agent** | Recommended; 3 phases drift 已证软建议无效 |
| 4 | First handoff scope | only Gray Zones / + P6.4 / + P6.7+P6.8 / all P6.1-8 | **Only Gray Zones** | Recommended; assumption-level 改动需稳的 process 底子 |
| 5 | Pre/post impl split | split / defer all / mock / syntax-only | **Split with Sub-rule 2 syntax-validate even post-impl** | Recommended + CR self-dogfood enhancement |
| 6 | Phase 6 done criteria | next handoff no drift / + script + fixture / script only | **Next handoff no drift** | Recommended; 动态验证 + script + fixture |
| 7 | Phase 1-5 backfill | no / Phase 5 only / all 5 | **No backfill** | Recommended; 前向生效 |
| 8 | Scope size | this fits / + P6.4 / 6a/6b split | **Fits ~4 hour** | Recommended; cleanest |

### 11.2 Implementation Decisions (post expert review)

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 9 | step1d insertion point | between step1c and step2 / after step2 | **Between step1c and step2 of handoff_creation_protocol.workflow** | Logical sequencing; line-anchored per §6.6 |
| 10 | layer2-audit report format | breaking change / additive | **Additive (new structured DISTINCT_COUNT/WARN_REVIEWER_COUNT lines + preserve old "artifacts found")** | Backward compat + machine-readable AC matching |
| 11 | **Reviewer whitelist canonical source (BA-P0-2)** | hardcoded each / config file / extensible array in audit script | **Extensible bash array at top of layer2-audit.sh; Blake SKILL refers, doesn't enumerate** | Single source of truth; new reviewer types auto-inherit; SKILL-script drift impossible |
| 12 | step1d 3 self-defending sub-rules (CR self-dogfood) | omit / 1 rule / **3 rules** | **3 rules: raw-form / syntax-validate post-impl / re-derive not quote** | CR's own dogfood found 3 step1d-class bugs in v1; without sub-rules step1d would let same drift recur |
| 13 | Express slug detection (CR-P0-6) | substring / word-boundary case / env var only | **Word-boundary case pattern** | False-positive defense; backwards compat with existing slugs |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-25
**Version**: 3.1.0 (v2 post-review integration; 11 P0 + 7 P1 fully resolved; CR self-dogfood verdict 3 sub-rules integrated into step1d)
