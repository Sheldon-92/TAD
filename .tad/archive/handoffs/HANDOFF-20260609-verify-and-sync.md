---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks/lib", ".claude/skills/alex", ".claude/skills/blake"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-skill-body-reference-boundary.md (Phase 3/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 tasks: checker hardening + SKILL rule updates + release + sync |
| Components Specified | ✅ | Integration via publish protocol, not release-verify.sh case |
| Functions Verified | ✅ | All target files confirmed via grep/read |
| Data Flow Mapped | ✅ | Checker hardening → SKILL updates → publish → sync |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Combined v2.27.0 release: checker hardening + SKILL 人话版规则修正 + 收尾 checklist + publish + sync 14 projects.

### 1.2 Why We're Building It
**业务价值**：14 个下游项目获得 Blake 执行纪律修复 + 双平台运行时架构。同时修复 Alex/Blake 经常忘写人话版和 message 的问题，并提升人话版质量。

### 1.3 Intent Statement
**真正要解决的问题**：
1. 自动化防止 3 个 inlined refs 被意外重建（负面存在性检查）
2. Alex/Blake 忘写 message + 人话版（收尾 checklist）
3. 人话版质量差——模板化、啰嗦、不解释为什么（规则重写）
4. 推送两个 Epic 的改动到 14 个项目

---

## 📚 Project Knowledge（Blake 必读）

1. **Deny-List Beats Allow-List** (principles.md) — sync 使用 deny-list，不是硬编码
2. **diff -r 是终极遗漏检测器** (principles.md) — sync 后用 `diff -rq` 验证
3. **Plain Language Quality** (feedback, just recorded) — 人话版三个问题：模板化、啰嗦、不解释为什么。用读者价值测试替代结构合规

---

## 2. Implementation Plan

### Task 1: Harden skill-body-verify.sh — negative presence checks

Add to `.tad/hooks/lib/skill-body-verify.sh` (after the existing marker checks):

```bash
# Negative presence: inlined refs must NOT be recreated
BLAKE_REFS=".claude/skills/blake/references"
for ref in completion-protocol.md execution-checklist.md ralph-loop.md; do
  if [[ -f "$BLAKE_REFS/$ref" ]]; then
    echo "  FAIL: $ref was re-extracted (must stay inlined in body)"
    fail=1
  fi
done
```

Use `$BLAKE_REFS` relative to CWD (consistent with the existing script's approach). When the script is called with a custom path (for false-negative testing), these checks should still run against the standard location.

### Task 2: Add 收尾 checklist to both SKILL bodies

**Blake SKILL.md** — add near the END of the completion protocol section (which is now inline in body), after the last step:

```yaml
# ⚠️ FINAL OUTPUT CHECKLIST (compact-resistant — stays in context after long sessions)
# After completing implementation + Gate 3, BEFORE ending your response:
final_output_checklist:
  - "✅ 生成 structured Alex message（📨 格式，含 task/status/commit/files/evidence）"
  - "✅ 写 人话版（见 plain_language_rules 下方）"
  - "⚠️ 缺任何一项 = 不完整的 completion，Alex 会打回"
```

**Alex SKILL.md** — add near the END of the handoff_creation_protocol stub section (in body), after step7's reference pointer:

```yaml
# ⚠️ FINAL OUTPUT CHECKLIST (compact-resistant — stays in context after long sessions)
# After completing handoff + expert review + Gate 2, BEFORE ending your response:
final_output_checklist:
  - "✅ 生成 structured Blake message（📨 格式，含 task/handoff/priority/scope/files）"
  - "✅ 写 人话版（见 plain_language_rules 下方）"
  - "⚠️ 缺任何一项 = 不完整的 handoff，人类无法传递给 Blake"
```

### Task 3: Rewrite 人话版 rules in both SKILL bodies

Replace the current 人话版 rules in BOTH Alex and Blake SKILLs with the new reader-value-based rules.

**New rule (same text for both agents, adapt context):**

```yaml
plain_language_rules:
  description: "人话版质量规则 — 读者价值测试，不是结构合规检查"
  test: |
    读完人话版，用户应该能回答：
    1. 这件事改完后我的体验具体哪里不同了？（不是"改了哪些文件"）
    2. 为什么走这条路而不是其他路？（不是"TAD 流程规定"）
    3. 接下来我需要做什么决定或注意什么？
  fail_condition: "如果任何一个答案换个任务也能用 → 重写"
  length: "上限 2-3 段。说不清楚不是因为篇幅不够，是因为没想清楚。"
  anti_patterns:
    - "❌ 模板化：每次差不多的套话（'Blake 将按照 handoff 执行...'）"
    - "❌ 啰嗦：重复 handoff 里已有的信息"
    - "❌ 不解释为什么：只说做了什么，不说为什么这么选择"
    - "❌ TAD 术语堆砌：Gate/Phase/Layer 对用户无意义时不用"
```

**Where in Alex:** The detailed 人话版 rules live in `references/handoff-creation-protocol.md` (lines ~703-772), NOT in the SKILL body. Modify the REFERENCE file: find the `PLAIN-LANGUAGE EXPLANATION (MANDATORY)` block, replace the length scaling / anti-theater rule / negative-positive examples with the new `plain_language_rules` block. Keep the ORDER REQUIREMENT (人话版 appears FIRST). Also add the new `plain_language_rules` as a SHORT summary in the SKILL BODY near the step7 stub — so it survives compact even if the reference isn't loaded.

**Where in Blake SKILL.md:** The completion protocol is now inlined in body. Find the message generation section (around line 1600, after `violation_plain_language`). Replace the old 人话版 block (`BUSINESS-VALUE-FIRST RULE`, `Length scaling`, `Anti-theater rule`, negative/positive examples) with the new `plain_language_rules` block.

### Task 4: Version bump + CHANGELOG

Update `.tad/config.yaml` version to 2.27.0.

CHANGELOG entry for v2.27.0 (combined release):

```markdown
## v2.27.0 — SKILL Body Boundary Fix + Dual-Platform Native Runtime (2026-06-09)

### Fixed
- Blake SKILL: inlined 3 circular-trigger references (ralph-loop, execution-checklist, completion-protocol) back into body — fixes Codex dogfood where Blake skipped Layer 2 / Gate 3 / completion report
- Agent message + 人话版 forgetting: added compact-resistant final output checklist to both SKILL bodies
- 人话版 quality: replaced structural compliance rules with reader-value test (3 questions + 2-3 paragraph limit)

### Added
- `skill-body-verify.sh`: body-integrity checker with 6 markers + safety floor + mirror sync + negative presence for deleted refs
- principles.md: "Circular Trigger Test" principle (14/15)
- Dual-platform native runtime architecture: Codex/Claude Code compatibility ledgers, runtime freshness verifier, drift-check release gate
- `.codex/config.toml` native policy + `.codex/agents/` evaluation framework

### Architecture
- Blake SKILL.md: 737 → 2005 lines (3 refs inlined, 2 ref-ok remain)
- Alex SKILL.md: minor additions (收尾 checklist + 人话版 rules)
- Dual-platform: both runtimes treated as first-class with independent compatibility tracking
```

### Task 5: Publish + Sync

1. Read release-runbook skill: `.claude/skills/release-runbook/SKILL.md`
2. Run `bash .tad/hooks/lib/skill-body-verify.sh` (body integrity pre-flight)
3. Run `bash .tad/hooks/lib/release-verify.sh structural` (if applicable)
4. Git add + commit + push
5. Tag v2.27.0
6. Run `*sync` to 14 projects
7. Post-sync: `diff -rq` spot check on 1-2 projects

**Note on checker integration**: Do NOT embed skill-body-verify.sh inside release-verify.sh's case structure (expert review P0: release-verify.sh is a two-mode case dispatcher, adding a third mode breaks its contract). Instead, call it directly as a pre-flight step in the publish flow (Task 5 step 2 above). If the checker fails, the publish should abort.

---

## 5. Files to Modify/Create

| File | Action | Description |
|------|--------|-------------|
| `.tad/hooks/lib/skill-body-verify.sh` | MODIFY | Add negative presence checks |
| `.claude/skills/blake/SKILL.md` | MODIFY | Add 收尾 checklist + rewrite 人话版 rules |
| `.claude/skills/alex/SKILL.md` | MODIFY | Add 收尾 checklist + 人话版 rules summary in body |
| `.claude/skills/alex/references/handoff-creation-protocol.md` | MODIFY | Replace old 人话版 block with new plain_language_rules |
| `.agents/skills/blake/SKILL.md` | MODIFY | Mirror of .claude/ blake |
| `.agents/skills/alex/SKILL.md` | MODIFY | Mirror of .claude/ alex (if .agents/ has alex) |
| `.tad/config.yaml` | MODIFY | version: 2.26.0 → 2.27.0 |
| `CHANGELOG.md` | MODIFY | Add v2.27.0 entry |

---

## 6. Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews: []
  gate_verdicts:
    - Gate 3 Layer 1 in completion report
  completion:
    - .tad/active/handoffs/COMPLETION-20260609-verify-and-sync.md
  dogfood:
    - Codex dogfood: deferred to user manual testing post-sync
  knowledge_updates: []
```

---

## 7. Important Notes

### 7.1 人话版 rules — find and replace, don't append
The new `plain_language_rules` REPLACES the existing 人话版 block. Don't leave both old and new versions in the SKILL files. The old block has: `PLAIN-LANGUAGE EXPLANATION (MANDATORY)`, length scaling, anti-theater rule, negative/positive examples. Remove all of that and replace with the new compact block.

Keep the ORDER REQUIREMENT (人话版 appears FIRST in the response, structured message SECOND) — that's separate from the quality rules.

### 7.2 .agents/ mirror
After modifying `.claude/skills/blake/SKILL.md` and `.claude/skills/alex/SKILL.md`, sync to `.agents/` mirrors. Check with `diff -q` before committing.

### 7.3 Codex dogfood is NOT in scope
User will manually test on Codex after sync. Blake notes this in completion report but does not attempt Codex CLI invocation.

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Negative presence checks in checker | `grep -c 'completion-protocol\|execution-checklist\|ralph-loop' .tad/hooks/lib/skill-body-verify.sh` | ≥ 3 |
| AC2 | Checker still passes | `bash .tad/hooks/lib/skill-body-verify.sh` | exit 0 |
| AC3 | Blake 收尾 checklist in body | `grep -c 'FINAL OUTPUT CHECKLIST' .claude/skills/blake/SKILL.md` | ≥ 1 |
| AC4 | Alex 收尾 checklist in body | `grep -c 'FINAL OUTPUT CHECKLIST' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC5 | Blake 人话版 new rules | `grep -c 'plain_language_rules\|读者价值' .claude/skills/blake/SKILL.md` | ≥ 1 |
| AC6 | Alex 人话版 new rules | `grep -c 'plain_language_rules\|读者价值' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC7 | Old 人话版 rules removed from Blake | `grep -ci 'Length scaling\|anti-theater rule\|Padding shorter handoffs\|BUSINESS-VALUE-FIRST RULE' .claude/skills/blake/SKILL.md` | = 0 |
| AC7b | Old 人话版 rules removed from Alex ref | `grep -ci 'Length scaling\|anti-theater rule\|Padding shorter handoffs' .claude/skills/alex/references/handoff-creation-protocol.md` | = 0 |
| AC8 | Version bumped | `grep 'version:' .tad/config.yaml \| head -1` | "version: 2.27.0" |
| AC9 | CHANGELOG has entry | `grep -c 'v2.27.0' CHANGELOG.md` | ≥ 1 |
| AC10 | Git tag | `git tag -l v2.27.0` | "v2.27.0" |
| AC11 | .agents/ mirrors synced | `diff -q .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` | identical |
| AC12 | Sync completed | *sync output | 14 projects |

### 9.2 Expert Review Status

| Expert | Focus | Status | Findings |
|--------|-------|--------|----------|
| code-reviewer | Phase 3 v1: checker integration | ✅ Incorporated | P0: $TAD_ROOT undefined → fixed (direct call); P1: integration point → fixed (not in case) |
| backend-architect | Phase 3 v1: checker integration | ✅ Incorporated | P1: case dispatcher contract → fixed; P2: negative checks TAD-main-only → noted |
| code-reviewer | Phase 3 v2: Tasks 2+3 | ✅ Incorporated | P1: AC7 targets wrong file (Alex not Blake) → fixed (AC7 retargeted + AC7b added) |
| backend-architect | Phase 3 v2: Tasks 2+3 | ✅ Incorporated | P0: Alex 人话版 rules in reference not body → fixed (added ref to Files to Modify + Task 3 clarified) |

---

## 10. Decision Summary

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| D1 | Checker integration | Direct call from publish flow | Expert P0: release-verify.sh is case dispatcher |
| D2 | 人话版 rules | Reader-value test | User feedback: old rules = structural compliance theater |
| D3 | Combined release | v2.27.0 with both Epics | Batch efficiency: one publish + one sync |
