---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-03

### Expert Review Status

| Reviewer | Type | P0 Found | P0 Fixed | Result |
|----------|------|----------|----------|--------|
| code-reviewer | Design review | 4 (Gate2 unfilled, FR2 mismatch, missing forbidden_impl, missing dir) | 4/4 fixed | CONDITIONAL PASS → PASS after fixes |
| backend-architect | Architecture review | 3 (Gate2 unfilled, FR2 terminal isolation, missing dir) | 3/3 fixed | CONDITIONAL PASS → PASS after fixes |

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| CR P0-2 | FR2 says both agents, files only modify Alex | FR2 amended to Alex-only | Resolved |
| CR P0-3 | Missing forbidden_implementations | §6.3 added 5 items | Resolved |
| CR P0-4 | Directory not in files table | §4 row 5+6 added (mkdir + deny-list) | Resolved |
| Arch P0-2 | *skillify dual-agent violates Terminal Isolation | FR2 amended to Alex-only | Resolved |
| Arch P0-3 | Directory creation missing | §4 row 5+6 added | Resolved |
| CR P1-1 | AC8 not executable (Chinese in command) | AC8 rewritten with sed+grep pipe | Resolved |
| CR P1-2 | STEP 3.57 missing interacts_with | Added ordering/suppression block | Resolved |
| CR P1-3 | NFR2 dream-candidate alignment claim inaccurate | NFR2 reworded to "directory convention" | Resolved |
| Arch P1-1 | Silent skip loses audit trail | Changed to "fill No:{gate}" in completion report | Resolved |
| Arch P1-2 | Verified gate ambiguous for *skillify | Added concrete anchor definition | Resolved |
| Arch P1-4 | No rejected candidate lifecycle | Added 30-day staleness + filtered scan | Resolved |
| Arch P1-5 | Upgrade path undefined | Explicitly marked v2 scope | Resolved |
| Arch P2-5 | Override interaction unspecified | Added interacts_with_override block | Resolved |

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Two-path trigger (KA + *skillify), 4-gate quality filter, candidate→skill pipeline |
| Components Specified | ✅ | 6 files listed with exact insertion points, forbidden_implementations defined |
| Functions Verified | ✅ | Blake KA section, Alex STEP 3.56, completion template all grounded |
| Data Flow Mapped | ✅ | Blake writes candidate → Alex detects at startup → human approves → skill created |

**Gate 2 结果**: ✅ PASS (after 2-expert review, 7 P0 fixed, 7 P1 resolved)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**Title:** Blake Knowledge Assessment 增加 Skillify Candidate 提取 + Alex *skillify 命令

**Executive Summary:**

在 Blake 的 Knowledge Assessment（Gate 3 完成后）和 Alex 的新增 *skillify 命令中，增加"自下而上的能力捕获"——将成功的工作模式提取为轻量级 project skill candidate，经人类审批后成为 .claude/skills/ 下的可复用 SKILL.md。

**Background:**

TAD 的能力积累目前只有自上而下的路径（研究驱动 → Capability Pack），缺少自下而上的路径。成功的工作模式只能写为 project-knowledge 条目（被动的"教训"），不能变成主动的可复用 skill。GBrain Skillify、Hermes Agent、Claudeception 三个开源项目验证了 bottom-up skill extraction 的可行性。

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: Blake KA Skillify 判断**
Blake 在 Knowledge Assessment 时，除了"是否有新发现"，额外判断"这次的工作模式是否可复用为 skill"。满足 4 个质量门时，生成 skillify candidate 文件。

**FR2: *skillify 显式命令（Alex-only）**
用户可以在任何时刻（不限于 Gate）主动说 `*skillify`，Alex 从当前 session 上下文中提取工作模式为 candidate。此命令仅 Alex 可响应（Terminal Isolation 原则——Blake 的路径专走 Gate 3 KA 自动评估，不走显式命令）。

**FR3: Alex 启动时 Skillify Candidate 检测**
Alex 启动时检测 `.tad/active/skillify-candidates/` 中的 pending candidates（类似 STEP 3.56 dream candidate review），呈现给用户审批。

**FR4: Candidate 审批 → Project Skill**
用户接受 candidate 后，生成 `.claude/skills/{slug}/SKILL.md`（项目级）。未来可手动提升为 `~/.claude/skills/`（用户级）。

**FR5: 升级阶梯**
形成自然的能力升级路径：工作模式 → skillify candidate → project skill（轻量 SKILL.md）→ capability pack（研究 + fixture）→ 用户级 skill。

### 2.2 Non-Functional Requirements

**NFR1:** Skillify 判断不增加额外交互步骤——在 KA 现有流程中自然扩展
**NFR2:** Candidate 文件使用类似 dream candidate 的目录约定（.tad/active/ 下独立目录 + 前缀区分：SCAND- vs CAND-），但字段结构不同（skillify 关注工作模式的步骤/触发条件，dream 关注知识信号类型/置信度）
**NFR3:** 产出的 skill 是纯 SKILL.md，无 fixture/install.sh（轻量级，区别于 capability pack）

---

## 3. Technical Design

### 3.1 Skillify 质量门（借鉴 Claudeception 4 门 + GBrain Phase 0）

Blake/agent 在判断"是否可 skillify"时，必须满足全部 4 条：

1. **Reusable** — 模式预期会再遇到（≥2 次复用场景可想象）
2. **Non-trivial** — 不是单条规则，而是多步工作流（≥3 步骤）
3. **Verified** — 当前任务通过了 Gate 3（模式确实 work），或 *skillify 时 session 确认模式有效
4. **Not-already-captured** — 不和现有 .claude/skills/ 中的 skill 或 capability pack 重复

4 门全过 → 生成 candidate。任一不过 → 在 completion report Skillify 行填写 "No: {failed gate name}"（审计可追溯），无用户交互。

"Verified" gate 对 *skillify 路径的定义：模式在当前 session 中被应用且结果正确（无 revert、无用户纠正、无重试）。这比 Gate 3 PASS 弱但有具体锚点。

### 3.2 Skillify Candidate 文件格式

路径：`.tad/active/skillify-candidates/SCAND-{YYYY-MM-DD}-{slug}.md`

```yaml
---
name: {kebab-case-slug}
date: {YYYY-MM-DD}
status: pending  # pending | accepted | rejected
source: {handoff slug 或 "session-explicit"}
trigger_conditions: "{什么场景下用这个模式}"
reusable: true
non_trivial: true
verified: true
not_duplicate: true
---

## Pattern: {模式名称}

### When to Use
{触发条件描述}

### Steps
1. {步骤1}
2. {步骤2}
3. ...

### Quality Criteria
- {质量标准1}
- {质量标准2}

### Anti-Patterns
- {反模式1}

## Evidence
- Source handoff: {HANDOFF-{date}-{slug}.md 或 "current session"}
- Gate 3 result: {PASS / N/A for explicit *skillify}
- Key files: {参与的关键文件路径}

## Proposed Skill Outline
如果接受，SKILL.md 应包含：
- name: {slug}
- description: {one-line}
- triggers: [{触发短语1}, {触发短语2}]
- Body: {上述 Steps + Quality Criteria + Anti-Patterns}
```

### 3.3 Blake SKILL.md 修改点

在 `knowledge_assessment` section（blake/SKILL.md ~line 1787-1799）扩展：

```yaml
knowledge_assessment:
  blocking: true
  when: "Gate 3 v2 和 Gate 4 v2 执行时"
  requirement: "必须在 Gate 结果表格中填写 Knowledge Assessment 部分"

  must_answer:
    - "是否有新发现？(Yes/No)"
    - "如果有，属于哪个类别？"
    - "一句话总结（即使无新发现也要写明原因）"

  # NEW: Skillify candidate evaluation
  skillify_evaluation:
    trigger: "After knowledge_assessment must_answer is filled"
    action: |
      Evaluate whether the WORKING PATTERN (not individual lesson) from this
      implementation is reusable as a skill:
      1. Check 4 quality gates: Reusable + Non-trivial + Verified + Not-duplicate
      2. If all 4 pass → write SCAND-{date}-{slug}.md to .tad/active/skillify-candidates/
      3. Note in completion report: "Skillify candidate: {slug} (4/4 gates passed)"
      4. If any gate fails → fill completion report Skillify row "No: {gate}" (audit trail), no user interaction
    blocking: false
    note: "This is a SUGGESTION — candidate goes to human review, not auto-created skill"
    interacts_with_override: |
      skillify_evaluation runs AFTER knowledge_assessment must_answer is filled,
      regardless of whether KA was original or completion_knowledge_override-triggered.
      If skip_knowledge_assessment: yes AND no override marker → skillify_evaluation ALSO skips
      (no KA context = no pattern to evaluate).
```

### 3.4 Alex SKILL.md 修改点

**A. STEP 3.57: Skillify candidate review（新增，after STEP 3.56 dream candidates）**

```yaml
- STEP 3.57: Skillify candidate review (conditional)
  trigger: "pending skillify candidates exist in .tad/active/skillify-candidates/"
  action: |
    1. Scan SCAND-*.md files with status: pending
    2. If 0 → skip silently
    3. If > 0:
       Output: "🔧 {N} skillify candidates detected"
       Per-candidate review:
         Display: name, trigger_conditions, steps summary, source
         AskUserQuestion per candidate:
           - "接受 → 生成 project skill" → create .claude/skills/{slug}/SKILL.md
           - "修改后接受" → user edits, then create
           - "拒绝" → status→rejected
           - "推迟" → status stays pending
    4. On accept: generate .claude/skills/{slug}/SKILL.md from candidate outline
  blocking: false
  suppress_if: "No pending candidates"
  interacts_with: |
    Runs AFTER STEP 3.56 (dream candidate review), BEFORE STEP 3.8 (research landscape).
    If STEP 3.7 announces Blake resume (case 3): suppress STEP 3.57
    (user is in Terminal 2 for Blake, not here to review candidates).
    Does NOT affect STEP 3.8 suppression.
    Does NOT affect STEP 4 suppression.
```

**B. *skillify 命令（新增到 Alex commands 列表）**

```yaml
skillify: "Extract current session's working pattern as a reusable skill candidate"
```

**C. *skillify 协议**

```yaml
skillify_command_protocol:
  trigger: "User types *skillify"
  action: |
    1. Analyze current session context — what pattern was the user working on?
    2. If no clear pattern → "当前 session 没有检测到可提取的工作模式。能描述一下你想 skillify 的模式吗？"
    3. If pattern detected → run 4 quality gates
    4. If gates pass → draft candidate, show to user for confirmation
    5. On confirm → write SCAND-{date}-{slug}.md to .tad/active/skillify-candidates/
    6. Output: "✅ Skillify candidate '{slug}' saved. Alex 下次启动时会提示审批。"
       Or if Alex is active: immediately offer to generate the skill
```

### 3.5 Completion Report 模板修改

在 completion-report.md 的 Knowledge Assessment 表格后添加一行：

```markdown
| ⚠️ Skillify Candidate | ✅/❌ | [Yes: SCAND-{slug} / No: {reason}] |
```

### 3.6 与现有机制的区分（MANDATORY — Blake must understand）

| 机制 | 触发 | 产出 | 性质 |
|------|------|------|------|
| project-knowledge | Gate 3/4 KA | 知识条目 | 被动（"下次注意 X"） |
| dream candidate | dream-scanner.sh | 知识整合建议 | 被动（dedup/merge） |
| **skillify candidate** | **Gate 3 KA + *skillify** | **可复用 skill** | **主动（"下次这样做"）** |
| capability pack | 研究驱动 | 领域判断力 | 深度（30-50 sources） |

---

## 4. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/blake/SKILL.md` | MODIFY | 在 knowledge_assessment section (~line 1799) 后添加 skillify_evaluation block |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | 在 STEP 3.56 之后、STEP 3.8 之前插入 STEP 3.57 + commands 列表添加 skillify + 添加 skillify_command_protocol |
| 3 | `.tad/templates/skillify-candidate-template.md` | CREATE | Candidate 文件模板 |
| 4 | `.tad/templates/completion-report.md` | MODIFY | 在 Knowledge Assessment 表格 (line 55) 后、### Git (line 57) 前添加 Skillify Candidate 行 |
| 5 | `.tad/active/skillify-candidates/` | CREATE (dir) | mkdir -p，零触摸目录（项目级，不 sync 到下游）|
| 6 | `.tad/hooks/lib/derive-sync-set.sh` | MODIFY | 将 `skillify-candidates` 加入 ZERO_TOUCH deny-list（防止 *sync 覆盖下游项目数据）|

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- .claude/skills/blake/SKILL.md (lines 1787-1862, read at 2026-06-03)
- .claude/skills/alex/SKILL.md (STEP 3.56 lines 177-204, read at 2026-06-03)
- .tad/templates/completion-report.md (head 60, read at 2026-06-03)

---

## 5. Acceptance Criteria

### 5.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|---------------------|-------------------|
| AC1 | Blake KA 流程包含 skillify 判断 | grep -c 'skillify_evaluation' .claude/skills/blake/SKILL.md | ≥1 |
| AC2 | Alex STEP 3.57 存在 | grep -c 'STEP 3.57' .claude/skills/alex/SKILL.md | ≥1 |
| AC3 | *skillify 命令在 Alex commands 列表 | grep -c 'skillify:' .claude/skills/alex/SKILL.md | ≥1 |
| AC4 | Candidate 模板存在 | test -f .tad/templates/skillify-candidate-template.md | exit 0 |
| AC5 | Completion report 模板含 Skillify 行 | grep -c 'Skillify Candidate' .tad/templates/completion-report.md | ≥1 |
| AC6 | 4 质量门定义完整 | grep -cE 'Reusable\|Non-trivial\|Verified\|Not-already-captured' .claude/skills/blake/SKILL.md | ≥4 |
| AC7 | Candidate 路径为 .tad/active/skillify-candidates/ | grep -c 'skillify-candidates' .claude/skills/blake/SKILL.md | ≥1 |
| AC8 | Alex candidate 审批流程含 AskUserQuestion | sed -n '/STEP 3.57/,/STEP 3.8/p' .claude/skills/alex/SKILL.md \| grep -c 'AskUserQuestion' | ≥1 |

---

## 6. Important Notes

### 6.1 关键约束

- **Blake 只写 candidate，不创建 skill** — skill 创建是 Alex/人类的职责
- **4 门全过才写 candidate，否则静默跳过** — 不增加任何交互负担
- **Candidate 使用类似 dream candidate 的目录约定** — SCAND- 前缀区分，字段结构不同
- **产出是纯 SKILL.md，无 fixture/install.sh** — 与 capability pack 的关键区别
- **Rejected candidates 留在原目录**（status=rejected），STEP 3.57 扫描时过滤掉。超过 30 天的 pending candidate 在 STEP 3.57 中额外提醒用户处理
- **升级路径 project skill → capability pack 为 v2 scope** — 本次只交付 candidate → project skill 这一段

### 6.2 不做什么

- 不做 GBrain 的 cross-modal eval（TAD 现有 cross-model 审查已覆盖重型场景）
- 不做 Hermes 的自动 skill 更新（TAD 不信任 agent 自我修改 skill）
- 不做 resolver/routing-eval.jsonl（TAD 用 keyword 匹配，不需要训练数据）
- 不为 *skillify 创建 hook（prompt-level-only enforcement，per 2026-04-15 原则）

### 6.3 forbidden_implementations (AR-001 Protection)

- MUST NOT auto-accept candidates without human review — the entire value proposition is human-in-the-loop
- MUST NOT create `.claude/skills/{slug}/SKILL.md` from Blake — Blake writes candidates, Alex/human creates skills
- MUST NOT make `skillify_evaluation` blocking — it is explicitly `blocking: false`
- MUST NOT register hooks for skillify enforcement (per 2026-04-15 mechanical enforcement rejected principle)
- MUST NOT auto-invoke *skillify without user explicit command (Alex side) — Blake's path is KA-only

### 6.4 Anti-Patterns

- ❌ 每次 Gate 3 都强制问用户"要不要 skillify" — 4 门不过就静默跳过
- ❌ 把 project-knowledge 条目和 skillify candidate 混为一谈 — 前者是教训，后者是做法
- ❌ 产出的 skill 过重（fixture + install.sh + registry entry）— 那是 capability pack 的职责

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Judgment-Only Skill Files** (principles.md) — 精简 SKILL.md 时不能删 constraint rules，v2.7 质量链失效前车之鉴。本次修改只在现有 section 追加内容，不删现有规则。
- **Memory and Learning** (patterns/memory-and-learning.md) — compact recovery 相关：新增的 skillify 状态需要能从文件恢复。Candidate 文件自描述（status field），无需额外 session state。

---

## Required Evidence Manifest

```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/skillify-ka/design-review-cr.md
    - .tad/evidence/reviews/alex/skillify-ka/design-review-arch.md
  gate_verdicts:
    - Gate 2 in this handoff
  completion:
    - .tad/active/handoffs/COMPLETION-20260603-skillify-at-knowledge-assessment.md
  blake_reviews:
    - .tad/evidence/reviews/blake/skillify-ka/
  knowledge_updates:
    - .tad/project-knowledge/ (if discoveries)
```
