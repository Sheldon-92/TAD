---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Express Mini-Handoff (v2 post expert review)

**From:** Alex (Agent A)
**To:** Blake (Agent B)
**Date:** 2026-04-14
**Project:** TAD Framework
**Task ID:** TASK-20260414-002
**Type:** Express SKILL update (~25 min, was 15 min in v1)
**Priority:** P1
**Epic:** N/A (independent small framework enhancement)
**Linear:** N/A

---

## Expert Review Status

| Expert | Verdict | P0 | Resolution |
|--------|---------|----|------------|
| code-reviewer | CONDITIONAL PASS | 2 | Both fixed: (1) step8 can't follow step7 STOP gate → fold INTO existing generate_message blocks; (2) Blake target = completion_protocol step8_generate_message lines 925-963 (specific) |
| ux-expert-reviewer | CONDITIONAL PASS | 2 | Both fixed: (1) Blake format guidance inlined (not "same as Alex" reference); (2) negative example replaced with formulaic-compliance failure (not just vocabulary) |
| **Net P1 fixes integrated**: blocking:true (not false), AC grep uses 🗣️ heading, drop "简版" (use full COMPLETION template), placement 人话版 BEFORE structured message, anti-theater rule, length scales to complexity, sharper audience definition | | | |

Evidence: `.tad/evidence/reviews/alex/20260414-plain-language-after-handoffs/`

---

## Background

User feedback (2026-04-14)：希望 Alex 和 Blake 在每次写完跨终端 message 后，**同一回应中**额外用人话版给用户写一段解释 —— 让用户在做"信息桥梁"时能学习/理解，而不只是机械复制粘贴。

用户原话：
> "我把内容交给 Blake，然后他执行的时候我还可以看一下你是怎么思考的... 而不是单纯的我只是在其中不断的去复制粘贴。"
> "我想要让它变成 TAD 的能力, TAD 都会这样做。"

---

## Architectural Decision (v2 — code-reviewer P0-1)

**v1 错误**：v1 设想加 step8 跟在 Alex step7（STOP gate）之后 —— 架构矛盾，STOP 后没东西能执行。

**v2 正确**：把"人话版"折叠进**已有的** `generate_message` 模板内部：
- Alex SKILL.md：扩展 `handoff_creation_protocol → workflow → step7 → generate_message`
- Blake SKILL.md：扩展 `completion_protocol → step8_generate_message`

不新增 step，不重新编号，不会影响协议 STOP 语义。

---

## What to Do (Two file edits, surgical)

### File 1: `.claude/skills/alex/SKILL.md`

**Locate**: `handoff_creation_protocol` → `workflow` → `step7` → `generate_message:` block (around line 1663-1666 + the multiline template that follows)

**Edit**: At the end of the existing `generate_message` template (after the existing structured Blake message format block), append a new **mandatory output section** instruction:

```yaml
generate_message: |
  Alex MUST auto-generate the following structured message.
  All {placeholders} must be replaced with actual values from the handoff.

  ⚠️ ORDER REQUIREMENT (NEW):
  The response output MUST be in this exact order:
    1. The 人话版 section (defined below) — appears FIRST
    2. The structured Blake message in code block — appears SECOND
  Rationale: user sees the explanation before the technical block they need to copy.

  [... existing Blake message template stays here unchanged ...]

  ---

  PLAIN-LANGUAGE EXPLANATION (MANDATORY)

  After the structured Blake message above, the response MUST also include
  a plain-Chinese explanation section addressed to the human user (NOT Blake).
  As specified by ORDER REQUIREMENT, this section appears FIRST in the response,
  even though it's documented here second.

  Heading: ## 🗣️ 人话版：这一步是什么意思

  Audience: Someone who understands WHAT they want done (because they requested it)
  but has zero knowledge of TAD internals, agent architecture, or why steps happen
  in this order. Assume domain knowledge full, framework knowledge zero.

  Required content:
    1. 现在做什么 — current stage in everyday language (no TAD jargon: handoff/Gate/Epic/spike must be inline-defined or replaced with analogy)
    2. 为什么这么决定 — reasoning + analogies if helpful (锁/装修/考试/律师/医生 etc)
    3. 接下来会发生什么 — what to expect, what user should watch for

  Length scaling (NEW per ux-expert-reviewer P1-1):
    - Express handoffs (1 step, 1-2 files): 1-2 short paragraphs
    - Standard handoffs (multi-file feature): 3-4 paragraphs
    - Full TAD / Epic phase handoffs: 4-5 paragraphs (max)
  Padding shorter handoffs to hit a paragraph count = VIOLATION.

  Anti-theater rule (NEW per ux-expert-reviewer P1-3):
    The explanation MUST contain at least 1 sentence that would be FALSE
    if applied to a different task. Generic workflow descriptions that
    could fit any handoff = VIOLATION (this is the formulaic-compliance trap).

  Negative example (formulaic compliance — DO NOT do this):
    "我们现在在做 Phase 1b，这是一个重要阶段，需要 Blake 仔细执行。
     接下来 Blake 会按计划进行，请你转交 message。"
    → Reads correctly, contains zero task-specific content, fails anti-theater rule.

  Positive example (task-specific, with analogy):
    "Blake 在搭防作弊系统。Phase 1a 我们证明了'锁能锁住门'，
     现在 1b 是请白帽黑客 (security-auditor) 来撬这把锁。
     用户的关键决策是：任意 1 个攻击成功 → NO-GO，
     这就是为什么我们让 Blake 先做 1 个样板间停下来给你看。"
    → Specific to this Phase 1b context, uses 锁 + 装修 analogies, names actual decisions.

  Purpose anchor (NEW per ux-expert-reviewer P2-3):
    Self-check before writing: "If the user reads this and something is wrong,
    will they understand enough to ask a clarifying question?"
    If no → rewrite.
```

**violation clause**: in step7's surrounding metadata add line `violation_plain_language: "Generating Blake message without the 人话版 section in same response = VIOLATION. Wrong order (technical block before 人话版) = VIOLATION. Formulaic compliance (no task-specific content) = VIOLATION."`

### File 2: `.claude/skills/blake/SKILL.md`

**Locate**: `completion_protocol` → `step8_generate_message:` block (lines 925-963 per code-reviewer P0-2)

**Edit**: Apply the SAME structural change. Append the same plain-language requirement to step8_generate_message's template, with these voice/role adaptations:

```yaml
step8_generate_message: |
  [... existing Alex message template stays here unchanged ...]

  ---

  PLAIN-LANGUAGE EXPLANATION (MANDATORY)

  After the structured Alex message above, the response MUST also include
  a plain-Chinese explanation section addressed to the human user (NOT Alex).
  ORDER: 人话版 section appears FIRST in the response, structured Alex message SECOND.

  Heading: ## 🗣️ 人话版：我刚做了什么

  Audience: Someone who requested this work and now needs to understand
  what was delivered before passing it back to Alex for verification.
  Assume domain knowledge full, framework knowledge zero.

  Required content:
    1. 我刚做完什么 — what was just delivered, in everyday language (no jargon: Layer 2, Gate 3, completion report, hooks must be inline-defined or replaced with analogy)
    2. 关键决策的理由 — why I made the technical choices (analogies welcome)
    3. Alex 接下来会做什么 + 你需要注意什么 — what verification Alex will do, what user should watch for in the report (so they can flag if anything looks off)

  Length scaling (NEW per ux-expert P1-1):
    - Express tasks: 1-2 short paragraphs
    - Standard tasks: 3-4 paragraphs
    - Full TAD / Epic phase tasks: 4-5 paragraphs (max)
  Padding shorter tasks to hit a paragraph count = VIOLATION.

  Anti-theater rule (NEW per ux-expert P1-3):
    Must contain ≥1 sentence that would be FALSE if applied to a different
    completion. Generic completion descriptions = VIOLATION.

  Negative example (formulaic — DO NOT do this):
    "我已经完成了所有任务，所有 AC 都通过了，请 Alex 验证并归档。"
    → Could fit ANY Blake completion. Zero task-specific content. VIOLATION.

  Positive example (task-specific, with concrete numbers):
    "我在 Phase 1a 跑了 3 个 experiment，最关键的是验证了 hook 真的能在
     Blake 试图发 'Message from Blake' 时把文件创建挡下来 —— 不是事后报警，
     是真挡住。性能 37 毫秒，远快于 200 毫秒的预算。
     接下来 Alex 会实际跑 cat results/exp1-decisions.tsv 等命令验证我的报告，
     不是看我的总结。如果 Alex 发现实际数字和我说的对不上，那就是我的报告有问题。"
    → Specific numbers (37ms vs 200ms), specific verification expectation, names actual mechanism.

  Purpose anchor (NEW per ux-expert P2-3):
    Self-check: "If the user reads this and Alex's verification fails,
    will the user understand the discrepancy enough to take a side?"

  violation_plain_language: "Sending Message to Alex without 人话版 section = VIOLATION. Wrong order = VIOLATION. Formulaic compliance = VIOLATION."
```

---

## Acceptance Criteria

- [ ] **AC1**: `.claude/skills/alex/SKILL.md` 的 `step7.generate_message` 内含 PLAIN-LANGUAGE EXPLANATION block + ORDER REQUIREMENT 段
- [ ] **AC2**: `.claude/skills/blake/SKILL.md` 的 `step8_generate_message` 内含相同结构的 PLAIN-LANGUAGE EXPLANATION block + ORDER REQUIREMENT 段
- [ ] **AC3**: 两个 SKILL 文件**没有**新增独立的 step8/step8b/step9 等（folding 进 existing template，不破坏 step7 STOP 语义）
- [ ] **AC4**: 两边都包含 4 项强制要素：Length scaling + Anti-theater rule + Negative + Positive examples + Purpose anchor
- [ ] **AC5（grep verification — code-reviewer P1-2 fix）**：用稳定的 emoji 而非英文 key 名验证：
  - `grep -c '🗣️ 人话版' .claude/skills/alex/SKILL.md` ≥ 1
  - `grep -c '🗣️ 人话版' .claude/skills/blake/SKILL.md` ≥ 1
- [ ] **AC6**: violation 条款两边都加上（与现有 SKILL 风格一致：用 `violation:` 或 `violation_plain_language:` key）
- [ ] **AC7**: COMPLETION-REPORT.md 用 `.tad/templates/completion-report.md` **完整模板**生成（**不是简版** — code-reviewer P1-3 + Blake SKILL 自身反 anti-pattern 都警告过）
  - 路径：`.tad/active/handoffs/COMPLETION-20260414-plain-language-after-handoffs.md`（**注意：不放 express-handoffs/ 子目录**，与现有归档规范一致）
- [ ] **AC8**: Commit message：`feat(TAD): fold "plain-language for human" into Alex step7 + Blake step8 message templates — user feedback 2026-04-14 (v2 post expert review, 11 issues integrated)`
- [ ] **AC9**: 不需要 `*sync` 立即推送（下次 *sync 自然带走）
- [ ] **AC10（dogfood，from v1 retained）**：Blake 写完 commit + COMPLETION-REPORT 后给 Alex 的 message **必须用新规则** —— 即在结构化 message 之前加 `## 🗣️ 人话版：我刚做了什么` 段。Blake 是新规则的第一次实践者，给后续示范
- [ ] **AC11（NEW）**：在 `.tad/project-knowledge/architecture.md` 加 1 条新 entry 记录此次发现（来自 code-reviewer P2-3 + 整个会话教训）：
  - 标题建议：`Express Handoff is NOT Review-Exemption — Self-Caught Anti-Pattern - 2026-04-14`
  - 内容：Alex (this session) wrote AC8="不需要 expert review" for an "express" SKILL update. Hook reminded; Alex caught self mid-step. Demonstrates that the "express → exempt" rationalization persists even in agents aware of the user's "全部 kill 逃生通道" decision. Reinforces that mechanical hook (even just text reminder hook) catches what self-discipline doesn't.

---

## Files to Modify

```
.claude/skills/alex/SKILL.md       # Edit step7.generate_message (fold in)
.claude/skills/blake/SKILL.md      # Edit step8_generate_message (fold in)
.tad/project-knowledge/architecture.md  # Add 1 knowledge entry (AC11)
```

**禁止修改**: 任何其他文件（包括 settings.json / hooks / 当前 Phase 1b spike artifacts / 本 handoff 自身在归档前不要再改）

---

## Important Notes

- ⚠️ **不要新增 step8/step9** —— v1 设计错误已被 code-reviewer 抓到，正确做法是 fold in（见 §Architectural Decision）
- ⚠️ **完整 COMPLETION-REPORT，不要简版** —— Blake SKILL 自身明确："Completion Report 只是文书工作 = anti-pattern"
- ⚠️ **AC10 dogfood**: 你完成这个 handoff 给 Alex 的 message 本身就要用新规则（这是协议的第一次活体测试）
- ⚠️ 时间盒：**25 min hard cap**（v1 写 15 min 太紧，v2 加了 architecture.md entry + dogfood 准备）。超时 → 报 PARTIAL
- ⚠️ Phase 1b 中途穿插：建议在 Phase 1b 的 pause point（Cat 1 pilot 完成、等 Alex 确认 scaffolding 那个点）顺手做。如果 Phase 1b 还没到 pause point，可以选择立即做（25min）或等 pause point —— 你判断哪个 context switch 成本更低

---

## Sub-Agent Usage

无 sub-agent 调用必要（纯文档编辑）。

---

## Completion Report

完成后写**完整** COMPLETION-REPORT.md（用 `.tad/templates/completion-report.md`，包含 Knowledge Assessment + Evidence Checklist + AC matrix）：
- 路径：`.tad/active/handoffs/COMPLETION-20260414-plain-language-after-handoffs.md`
- Knowledge Assessment 必填（Yes/No + 具体路径，已有 AC11 加 entry，Yes 是确定的）
- 然后 commit + 写给 Alex 的 message（按新规则用 dogfood）

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-14
**Version**: 3.1.0 (v2 post expert review — 11 issues from code-reviewer + ux-expert integrated)
**Status**: ✅ Ready for Implementation
