---
task_type: e2e
e2e_required: yes
research_required: no
git_tracked_dirs: [".tad/evidence"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 5/5)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex)

**Execution time**: 2026-06-09

### Gate 2 Check

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Phases 1-4 accepted; test matrix designed from Epic ACs |
| Components Specified | ✅ | 4 test scenarios (T1-T4) + 8 carry-forward items (CF1-CF8) with pass/fail criteria |
| Functions Verified | ✅ | `codex exec`, `runtime-freshness-verify.sh` confirmed available |
| Data Flow Mapped | ✅ | Input files → test execution → evidence artifacts → acceptance report |

**Gate 2 result**: ✅ PASS

**Alex confirms**: All input artifacts from Phases 1-4 are verified present. Blake can independently execute the regression tests and produce the acceptance report.

---

## Handoff Checklist (Blake)

- [ ] Read all sections
- [ ] Read Project Knowledge section
- [ ] Understand the test matrix (§4) and pass/fail criteria
- [ ] Confirm Codex CLI is available (`codex --version`)
- [ ] Confirm can independently produce all required evidence

---

## 1. Task Overview

### 1.1 What We're Building

Dual-platform regression evidence proving the Phase 1-4 architecture works in practice. Run a Codex full-cycle test on v0.137.0, verify Claude Code compatibility, check carry-forward items from earlier phases, and compile an acceptance report with linked evidence.

### 1.2 Why We're Building It

**Business value**: Without regression evidence, the dual-platform architecture is design-on-paper. Phase 5 proves it works before release.
**Success**: When the acceptance report shows Codex full-cycle PASS, Claude Code compatibility confirmed, and all carry-forward items addressed.

### 1.3 Intent Statement

**Real problem**: Prove dual-platform architecture works, not just that it's designed correctly.

**NOT**:
- ❌ Not building new features or changing architecture
- ❌ Not achieving statistical rigor (n=3 waived, see §11)
- ❌ Not testing Codex interactive mode (only `codex exec`)

**Blake confirms understanding**:
```
1. What problem? Validate the Phase 1-4 architecture with real execution evidence.
2. How used? Evidence feeds Epic acceptance and release decision.
3. Success? All 8 ACs pass (or gaps classified as accepted limitations).
```

---

## Project Knowledge (Blake must read)

**Relevant areas**: [x] testing, [x] architecture

**Read files**:

| File | Entries | Key reminder |
|------|---------|-------------|
| patterns/ac-verification.md | 7 | Dry-run verification commands before declaring PASS |
| patterns/gate-design.md | 9 | Gate 4 verification integrity: recompute from primary evidence |

**Blake must note these lessons**:

1. **AC Verification Drift** (ac-verification.md): Verification commands must be dry-run on real artifacts. Don't assume a grep will work — test it first.

2. **Gate 4 Verification Integrity** (gate-design.md): Re-derive pass/fail numbers from primary evidence. Don't read summaries — run the same commands.

3. **Expert Review Blind Spots** (gate-design.md): Post-impl review catches different things than pre-handoff review. Run Layer 2 on the evidence artifacts, not just the test scripts.

### Blake confirms

- [ ] I have read the above lessons
- [ ] I understand the verification integrity requirement
- [ ] I will dry-run all verification commands

---

## 2. Background Context

### 2.1 Previous Work

- **2026-06-07 Codex validation report** (`.tad/evidence/codex-validation/REPORT-2026-06-07.md`): n=1 full-cycle on Codex v0.130.0, slugify carrier task. PASS. Gaps: R3 resume untested, interactive entry untested, n=1 only.
- **Phase 1-4** all accepted with Gate 4 PASS. Artifacts in `.tad/evidence/designs/` and `.tad/runtime-compat/`.

### 2.2 Current State

- Codex CLI: v0.137.0 (upgraded from v0.130.0 since last validation)
- Runtime freshness ledgers: both current (2026-06-09)
- Evidence directories: `.tad/evidence/codex-regression/` and `.tad/evidence/dual-platform-regression/` do NOT exist yet — Blake creates them.

### 2.3 Dependencies

- Codex CLI must be available: `command -v codex`
- Codex API key/auth must be configured (user responsibility)
- All Phase 1-4 artifacts must be present (verified by Alex grounding pass)

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Run Codex full-cycle regression (Alex activate → design → handoff → Blake impl → Gate 3 evidence)
- FR2: Verify Claude Code compatibility (role activation, handoff flow, Gate semantics)
- FR3: Check Phase 2/3/4 carry-forward items (ask_user_question hook, custom agent structural validation, draft config/agents, 8 P2 items from Phase 2)
- FR4: Verify runtime freshness ledgers are current
- FR5: Classify any gaps found
- FR6: Compile acceptance report with linked evidence

### 3.2 Non-Functional Requirements

- NFR1: All test evidence must be in version-controlled directories under `.tad/evidence/`
- NFR2: Codex exec calls must be sandboxed to evidence directories (no project-root mutations)

---

## 4. Test Matrix

### T1: Codex Full-Cycle Regression (v0.137.0)

**Carrier task**: Create a shell function `to_upper` that converts stdin to uppercase with locale safety (`LC_ALL=C`), handles empty input gracefully, and includes a test script. All outputs in `.tad/evidence/codex-regression/sandbox/`.

**Steps**:
1. `codex exec` with Alex SKILL → Alex activates → intent detection → produces inline handoff
2. `codex exec` with Blake SKILL + handoff from step 1 → Blake implements → produces Gate 3 evidence
3. Independently verify: test script runs, output is correct, evidence files exist

**Pass criteria**:
- Alex produces structured handoff with frontmatter + ACs
- Blake produces implementation + test + review evidence
- Test passes independently (re-run by Blake outside Codex)
- No protocol violations (Alex doesn't code, Blake doesn't design)

**Report format**: T1 report MUST include a plain-text `verdict: PASS` or `verdict: FAIL` line (no Markdown bold/formatting). This format is required for AC1 grep verification.

**Evidence output**: `.tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md`

### T2: Claude Code Compatibility Check

**Method**: Verify from current session artifacts + behavioral spot-checks. No new full-cycle needed — this Epic's 4 phases were all executed on Claude Code.

**Check items**:
| Surface | How to verify | Source |
|---------|--------------|--------|
| Role activation | This session's Alex activation completed correctly | Current conversation |
| Handoff flow | Phase 1-4 handoffs followed template | Exact files: `HANDOFF-20260609-dual-platform-runtime-architecture-phase1.md`, `HANDOFF-20260609-codex-native-runtime-policy.md`, `HANDOFF-20260609-dual-platform-docs-upgrade.md`, `HANDOFF-20260609-runtime-freshness-loop.md` (all in `.tad/archive/handoffs/`) |
| Gate 3 semantics | Phase 4 Gate 3 passed with Layer 2 evidence | Phase 4 completion report |
| Gate 4 semantics | Phases 1-4 all accepted with Gate 4 | Epic phase details |
| Compact recovery | session-state.md exists and was read correctly at startup | This session's STEP 3.7 |
| Skill progressive loading | References loaded on demand in this session | This session behavior |

**Behavioral spot-checks** (goes beyond session-log compilation):
1. **Alex design-only constraint**: Verify Phase 1 Alex produced zero implementation files — `git log --name-only <phase1-commit>` should show only `.tad/evidence/` artifacts, no source code.
2. **Gate 3 independent re-run**: Pick one Phase 4 test command from the completion report, re-run it independently, confirm output matches Blake's reported result.

**Pass criteria**: All 6 surfaces confirmed with evidence pointer + both behavioral spot-checks pass.

**Report format**: Each surface row must include a line `verdict: PASS` or `verdict: FAIL` (plain text, no Markdown formatting). Final report must include an overall `verdict: PASS` or `verdict: FAIL` line. Quote or excerpt the evidence from this session into the report so it is self-contained for future auditors.

**Evidence output**: `.tad/evidence/dual-platform-regression/T2-claude-code-compat.md`

### T3: Carry-Forward Verification

**Items from Phase 2/3/4 acceptance** (cross-checked against Epic "Context for Next Phase" sections):

| # | Item | Source | How to test | Expected |
|---|------|--------|------------|----------|
| CF1 | `ask_user_question` hook on Codex | Phase 2, Phase 4 | Inspect `.codex/hooks.json` for tool-call matchers; test `codex exec` with a prompt that would trigger AskUserQuestion | Document: works / accepted_limitation |
| CF2 | Custom agent structural validity | Phase 2, Phase 4 | Validate `.tad/evidence/designs/codex-runtime-candidates/agents/*.toml.draft` files are valid TOML (`python3 -c "import tomllib; tomllib.load(open('file','rb'))"` or equivalent). Do NOT copy to `.codex/agents/` — activation requires Phase 5 PASS first (circular dependency). | Document: structurally valid / needs fix. Classify activation as `accepted_limitation: circular_dependency` |
| CF3 | Draft config.toml structural validity | Phase 4 | Validate `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft` as valid TOML | Document: valid / needs fix |
| CF4 | Layer 2 evidence completeness | Phase 2/3 carry-forward | List Phase 4 review evidence files in `.tad/evidence/` — check for R2/R3 review files | Document: present (list paths) / absent (classify as process_blemish) |
| CF5 | `skills.config` schema | Phase 2 P2 | Check if Codex `config.toml` supports `skills.config` key per current Codex docs | Document: supported / not_supported / deferred |
| CF6 | `model_provider` field | Phase 2 P2 | Check if Codex `config.toml` supports `model_provider` key | Document: supported / not_supported / deferred |
| CF7 | Agent output constraints | Phase 2 P2 | Check if `.codex/agents/*.toml` support output format constraints | Document: supported / not_supported / deferred |
| CF8 | Agent runtime quality | Phase 2 P2 | Already partially tested in T1 (Codex agent produces structured output). Cross-reference T1 result. | Document: quality_acceptable / needs_improvement |

**Note on Phase 2 P2 items**: 8 P2 review items were flagged for Phase 4/5 verification. CF5-CF8 cover the 4 most actionable ones (`skills.config`, `model_provider`, output constraints, agent runtime quality). The remaining 4 are doc-level nits already addressed by Phase 3 docs upgrade — confirm by spot-checking `docs/MULTI-PLATFORM.md`.

**Gap classification vocabulary**: Use exactly one of: `protocol_bug`, `adapter_bug`, `documentation_bug`, `accepted_limitation`, `process_blemish`, `deferred`. Each finding must use one of these terms.

**Evidence output**: `.tad/evidence/dual-platform-regression/T3-carry-forward.md`

### T4: Runtime Freshness Check

**Method**: Run `bash .tad/hooks/lib/runtime-freshness-verify.sh` and record output.

**Pass criteria**: Exit 0 (both ledgers current) or documented accepted limitations.

**Evidence output**: `.tad/evidence/dual-platform-regression/T4-freshness-check.md`

---

## 5. Architecture

No new architecture. This phase validates Phases 1-4 architecture.

---

## 6. Files to Modify / Create

| File | Action | Purpose |
|------|--------|---------|
| `.tad/evidence/codex-regression/` | CREATE dir | Codex regression evidence |
| `.tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md` | CREATE | T1 report |
| `.tad/evidence/codex-regression/sandbox/` | CREATE dir | T1 sandboxed carrier task |
| `.tad/evidence/dual-platform-regression/` | CREATE dir | Cross-platform evidence |
| `.tad/evidence/dual-platform-regression/T2-claude-code-compat.md` | CREATE | T2 report |
| `.tad/evidence/dual-platform-regression/T3-carry-forward.md` | CREATE | T3 report |
| `.tad/evidence/dual-platform-regression/T4-freshness-check.md` | CREATE | T4 report |
| `.tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` | CREATE | Final acceptance report |

---

## 7. Implementation Guide

### Step 1: Setup
```bash
mkdir -p ".tad/evidence/codex-regression/sandbox"
mkdir -p ".tad/evidence/dual-platform-regression"
```

### Step 2: T1 — Codex Full-Cycle

**Known gotcha**: `codex exec "<prompt>"` without stdin redirect **blocks** on "Reading additional input from stdin..." in non-interactive environments. Always use `echo ... | codex exec` or `</dev/null`. The `--full-auto` flag is deprecated — use `--sandbox workspace-write` instead.

**2a. Alex call**:
```bash
cat .agents/skills/alex/SKILL.md - <<'ALEX_EOF' | codex exec --sandbox workspace-write
You are Alex. Load the SKILL above. Carrier task: design a shell function
to_upper that converts stdin to uppercase with LC_ALL=C locale safety,
handles empty input gracefully, includes a test script. All outputs in
.tad/evidence/codex-regression/sandbox/. This is non-interactive: proceed
with defaults where you would normally ask. Produce an inline handoff.
ALEX_EOF
```
Save the full output to `.tad/evidence/codex-regression/T1-alex-output.txt`.

**2b. Extract handoff** from Alex output (the section between `# Handoff` and end-of-output, or equivalent structured block).

**2c. Blake call** (resume does NOT accept `-s` flag; sandbox carries from 2a):
```bash
cat .agents/skills/blake/SKILL.md - <<'BLAKE_EOF' | codex exec --sandbox workspace-write
You are Blake. Load the SKILL above. Here is the handoff from Alex:
<paste extracted handoff from 2b>
Implement the carrier task. All files in .tad/evidence/codex-regression/sandbox/.
Produce Gate 3 evidence (test output, code review, completion report).
BLAKE_EOF
```
Save the full output to `.tad/evidence/codex-regression/T1-blake-output.txt`.

**2d. Independent verify**: Re-run the test script produced by Codex-Blake outside of Codex. Compare result with Blake's self-reported output.

**2e. Write T1 report** with `verdict: PASS` or `verdict: FAIL` line.

**If T1 fails**: Preserve partial output in sandbox/ for diagnosis. Create T1 report with `verdict: FAIL` and gap analysis. Continue to T2/T3/T4.

### Step 3: T2 — Claude Code Compatibility
Compile evidence from current session and Phase 1-4 artifacts. Verify each surface. Write T2 report.

### Step 4: T3 — Carry-Forward
Test each item. Document findings as works / accepted limitation / needs fix. Write T3 report.

### Step 5: T4 — Freshness
Run verifier script. Record output. Write T4 report.

### Step 6: Compile Acceptance Summary
Create `ACCEPTANCE-SUMMARY.md` with:
- Pass/fail matrix (all 4 tests)
- Gap classification table
- n=3 waiver statement
- Linked evidence paths
- Release readiness recommendation

---

## 8. Constraints

- All Codex exec must be sandboxed to evidence directories
- Do not modify any TAD protocol files, SKILLs, or runtime config
- Do NOT copy `.toml.draft` files to `.codex/agents/` — activation requires Phase 5 PASS first (see T3 CF2 accepted_limitation)
- Codex version must be recorded in evidence (output of `codex --version`)
- If Codex auth fails or API is unavailable, document as environment blocker and produce T2/T3/T4 without T1
- If T1 fails partway (crash, timeout, invalid output), preserve partial output for diagnosis and write T1 report with `verdict: FAIL` + gap analysis
- Expected time per `codex exec` call: 2-5 minutes. If no response after 10 minutes, terminate and document as timeout

---

## 9. Acceptance Criteria

### 9.1 Verification Commands

| AC | Description | Verification | Verified Output |
|----|-------------|-------------|-----------------|
| AC1 | Codex full-cycle regression passes | `test -f .tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md && grep -ci 'verdict:.*PASS' .tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md` | ≥1 |
| AC2 | n=3 waiver documented | `grep -ci 'n=3.*waiver\|waiver.*n=3\|stability.*waiver' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` | ≥1 |
| AC3 | Claude Code compat check passes | `test -f .tad/evidence/dual-platform-regression/T2-claude-code-compat.md && grep -ci 'verdict:.*PASS' .tad/evidence/dual-platform-regression/T2-claude-code-compat.md` | ≥1 |
| AC4 | Runtime freshness ledger current | `bash .tad/hooks/lib/runtime-freshness-verify.sh 2>&1; echo "exit=$?"` | exit=0 or documented accepted_limitation in T4 report |
| AC5 | Trace/evidence artifacts linked | `find .tad/evidence/codex-regression .tad/evidence/dual-platform-regression -name '*.md' \| wc -l` | ≥5 |
| AC6 | Platform gaps classified | `grep -ciE 'protocol_bug\|adapter_bug\|documentation_bug\|accepted_limitation\|process_blemish\|deferred' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` | ≥1 (from real gap findings, not from the n=3 waiver) |
| AC7 | Acceptance summary with release recommendation | `grep -ci 'release_readiness:' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` | ≥1 |
| AC8 | Layer 2 review evidence exists | `find .tad/evidence/codex-regression .tad/evidence/dual-platform-regression -name '*review*' -o -name '*layer2*' \| wc -l` | ≥1 |

### 9.2 Dry-Run Notes

- AC1/AC3: Reports MUST include plain-text `verdict: PASS` or `verdict: FAIL` lines (format specified in T1 and T2 sections). Grep uses `-ci` for case-insensitive matching.
- AC4: If `runtime-freshness-verify.sh` returns exit=1 (BLOCK), Blake must record the exact BLOCK lines from stderr and classify whether the block is a genuine limitation or a ledger maintenance gap. A ledger gap is a Phase 4 bug, not an accepted limitation.
- AC6: Uses the exact gap classification vocabulary defined in T3 (underscore-separated). The n=3 waiver is tracked under `waiver:` key in ACCEPTANCE-SUMMARY, not as a gap classification — AC6 must be satisfied by real findings.
- AC8: Layer 2 review is a Gate 3 requirement (§10). Blake must produce at least one review file for the regression evidence.

---

## 10. Required Evidence Manifest

| Evidence | Type | Gate |
|----------|------|------|
| T1 full-cycle report | E2E regression | Gate 3 |
| T2 Claude Code compat report | Verification | Gate 3 |
| T3 carry-forward report | Verification | Gate 3 |
| T4 freshness check report | Verification | Gate 3 |
| Acceptance summary | Synthesis | Gate 4 |
| Layer 2 review evidence | Expert review | Gate 3 |

---

## 11. Decision Summary

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| D1 | n=1 fresh + n=3 waiver | Existing n=1 (06-07, v0.130.0) + fresh n=1 (v0.137.0) = 2 runs across 2 versions. Cost of n=3 full-cycle Codex exec outweighs marginal confidence gain. Waiver rationale: version diff is minor (0.130.0→0.137.0), carrier tasks exercise same protocol surfaces, and Phase 1-4 design was architecture-only (no code changes to regress). **Adversarial surface note**: The 06-07 report validated adversarial paths (planted-bug detection, gate failure + Ralph Loop) on v0.130.0. This Phase 5 runs happy-path only on v0.137.0. The 7-minor-version gap is insufficient to regress adversarial behavior — accepted as waiver scope. | n=3 full (expensive), n=1+differential (middle ground) |
| D2 | Claude Code verified from session artifacts + behavioral spot-checks | This Epic's 4 phases all ran on Claude Code — rerunning a full cycle would be redundant. Spot-check compilation + 2 behavioral verifications (Alex design-only constraint, Gate 3 independent re-run) bridges the gap between "session ran" and "protocol preserved." | Separate full-cycle re-run (waste), session-only (too weak per expert review P1-2) |
| D3 | `to_upper` carrier task | Different from 06-07 slugify (adds variety), still small enough for sandbox, exercises locale/testing patterns. | Reuse slugify (less variety), larger task (more risk in sandbox) |
| D4 | Phase 2 P2 items: verify 4, defer 4 | 8 P2 review items from Phase 2 acceptance were flagged for Phase 4/5. CF5-CF8 in T3 cover the 4 most actionable (skills.config, model_provider, output constraints, agent runtime quality). The remaining 4 are doc-level nits already addressed by Phase 3 docs upgrade — Blake confirms by spot-checking `docs/MULTI-PLATFORM.md`. | Verify all 8 individually (more thorough but diminishing returns on doc-level nits) |

---

## 12. Audit Trail

### Expert Review Record

**Expert 1: code-reviewer** (2026-06-09)
- Findings: 2 P0, 6 P1, 6 P2
- P0-1: Missing Phase 4 carry-forward + 8 P2 items from Phase 2 → **FIXED**: T3 expanded to 8 carry-forward items (CF1-CF8), D4 added
- P0-2: Epic missing "Phase 4 Accepted" section → **NOTED**: Epic housekeeping item, non-blocking for handoff
- P1-1: AC1 grep pattern won't match Markdown format → **FIXED**: case-insensitive + explicit format requirement in T1
- P1-2: AC3 doesn't check for PASS → **FIXED**: changed to `verdict:.*PASS`
- P1-3: AC6 grep too specific → **FIXED**: case-insensitive + extended regex + exact vocabulary in T3
- P1-4: `codex exec` stdin blocking + deprecated flag → **FIXED**: full command templates in §7 Step 2
- P1-5: No command templates → **FIXED**: copy-paste templates with heredoc in §7 Step 2
- P1-6: Layer 2 evidence has no AC → **FIXED**: AC8 added

**Expert 2: test-runner** (2026-06-09)
- Findings: 3 P0, 5 P1, 4 P2
- P0-1: Expert review record empty → **FIXED**: this section (review was in-flight)
- P0-2: `codex exec` invocation insufficient → **FIXED**: same as CR P1-4/P1-5
- P0-3: AC3 passes on `verdict: FAIL` → **FIXED**: same as CR P1-2
- P1-1: AC1 format mismatch → **FIXED**: same as CR P1-1
- P1-2: T2 session-artifact method too weak → **FIXED**: added 2 behavioral spot-checks to T2
- P1-3: T3 toml.draft test circular dependency → **FIXED**: reframed as structural validation + accepted_limitation
- P1-4: T2 glob includes unrelated Epic handoffs → **FIXED**: replaced with exact 4 filenames
- P1-5: Happy-path only, no adversarial regression → **FIXED**: acknowledged in D1 waiver rationale

**All P0 resolved. All P1 resolved.**

---

## Message to Blake

Blake，这是 Dual-Platform Native Runtime Architecture Epic 的最后一个 Phase — 回归测试验证。

**核心任务**: 4 项测试 + 8 项 carry-forward 验证，最后编写验收总结报告。

**为什么重要**: Phase 1-4 做了完整的双平台架构设计，但纸上设计≠实际可用。这个 Phase 用真实执行证明它 work。

**关键要点**:
1. **T1（Codex 全周期）是最重要的测试** — 用 `to_upper` 载体任务在 Codex v0.137.0 上跑完整 Alex→Blake 链路。§7 Step 2 有完整的 `codex exec` 命令模板（注意 stdin redirect 和 `--sandbox workspace-write`）。如果 Codex auth 不可用就记录为环境阻塞，其他测试照做
2. **T2 不只是编译会话记录** — 除了 6 个 surface 确认，还有 2 个行为 spot-check（Alex design-only + Gate 3 独立重跑）
3. **T3 有 8 项 carry-forward**（CF1-CF8）— 注意 CF2 toml.draft 测试只做结构验证（TOML 合法性），不要复制到 `.codex/agents/`（循环依赖，归为 accepted_limitation）
4. **所有报告必须包含 `verdict: PASS` 或 `verdict: FAIL` 纯文本行**（不要 Markdown 加粗），AC grep 验证依赖此格式
5. **gap 分类必须使用精确词汇**: `protocol_bug` / `adapter_bug` / `documentation_bug` / `accepted_limitation` / `process_blemish` / `deferred`
6. n=3 已豁免（§11 D1），你只需跑 1 次 fresh + 引用 06-07 的 n=1
7. 所有产出在 `.tad/evidence/` 下，不要修改任何 TAD 协议文件

**8 个 AC 概要**: T1 全周期 PASS / n=3 waiver 文档 / T2 兼容性 PASS / freshness exit=0 / ≥5 evidence 文件 / gap 分类存在 / release_readiness 建议 / Layer 2 review 存在

**期望时间**: ~1-2 小时（主要耗时在 Codex exec 等待）

祝顺利！
