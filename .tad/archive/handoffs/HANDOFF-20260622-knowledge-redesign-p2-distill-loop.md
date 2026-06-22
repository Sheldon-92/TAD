---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake", ".claude/skills/gate"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Recording Redesign — P2 Capture/Distill Cross-Bridge Loop

**From:** Alex (Terminal 1) · **To:** Blake (Terminal 2) · **Date:** 2026-06-22
**Epic:** EPIC-20260622-knowledge-recording-redesign.md (Phase 2/4)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | journal/playbook 物理分离 + cross-bridge loop 全流程定义 |
| Components Specified | ✅ | Blake Gate 3 KA → journal; Alex Gate 4 KA → distill loop; hand-back format; Codex criteria |
| Functions Verified | ✅ | 目标改动在 blake/SKILL.md 和 alex/SKILL.md 的精确行号范围(见 §7) |
| Data Flow Mapped | ✅ | Blake journal → 人类桥 → Alex distill → 缺口问题 → 人类桥 → Blake 答 → Alex 定稿 |

**Gate 2 结果**: ✅ PASS(专家审查后回填 §9.2)

---

## 1. Task Overview

### 1.1 What We're Building
把 Knowledge Assessment 从"干完就写成品"拆成两步:**Blake Gate 3 只落原始 journal**(便宜、无质量门槛),**Alex Gate 4/*accept 跑缺口驱动的提炼回环**(陌生人提炼 → typed entry → 填不出的字段变成问题 → 人类桥 → Blake 答 → Alex 定稿到 playbook)。

### 1.2 Why We're Building It
P1 建了契约(schema + rules + template),但 Gate 3/4 执行逻辑还在用旧的 Context/Discovery/Action 直写模式——知识诅咒问题没被切断。P2 让实际的流水线换到新架构上。

### 1.3 Intent Statement
**真正要解决的问题**:Blake 在任务结尾写的"知识"是日记(知识诅咒);而 Alex 虽然是陌生人(没有 Blake 的执行上下文),但旧协议里 Alex 也是自己直写知识,没有用"陌生人视角"。
**不是要做的**:
- ❌ 不是建 maintenance/dedup/lint(P3)
- ❌ 不是迁移已有知识(P4)
- ❌ 不改 skillify_evaluation / workflow_evaluation(保留不动)

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ Blake 必须注意的历史教训**:

1. **Execution Discipline Content Must Stay in SKILL Body — Circular Trigger**(principles.md)
   - 本 handoff 改 Gate KA 逻辑。新的 distill-loop 触发条件**必须留在 SKILL body**,不能只放 reference(否则 agent 不知道 distill 存在,永远不会触发)。把 distill-loop 的**触发规则**写在 body,**详细步骤**可以放 reference。
2. **Knowledge Is Forged at Distill, Not Captured**(principles.md,P1 新增)
   - 这是本 phase 要落地的原则。Blake 的改动必须确保 Gate 3 KA **不再**让 Blake 写成品 knowledge,只写 journal。
3. **Mechanical Enforcement Rejected on Single-User CLI**(principles.md)
   - 新增的 distill-loop 是协议层面的"应该做",不是 hook/settings 层面的"必须做"。不注册任何 hook。

**研究依据**:`.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md` + P1 产出(schema/rules/template)。

---

## 2. Background Context

### 当前状态(要改的两处)

**Blake Gate 3 KA**(blake/SKILL.md L1804-1877):
- `must_answer` 3 问(Q1 新发现 / Q2 可复用模式 / Q3 workflow 模式)
- Q1 如果 Yes → Blake 直接写 `project-knowledge/{category}.md`,用旧 Context/Discovery/Action 格式
- skillify_evaluation(Q2/Q3 后续) + workflow_evaluation + completion_knowledge_override 全部围绕这个 must_answer 展开

**Alex Gate 4 KA**(alex/SKILL.md L1559-1606 `post_review_knowledge`):
- 评估审查过程中的发现 → 如果值得记 → 直接写 `project-knowledge/{category}.md`,同样旧格式
- 只在验收**后**跑,没有从 Blake 的 journal 拉信息的步骤

### 要变成的状态

**Blake Gate 3 KA** → 只落 journal:
- Q1 改为"发生了什么值得追溯的 → 追加到 `evidence/journal/{handoff-slug}-{date}.md`"
- journal 格式:自由散文/要点列表,无 schema 约束,append-only,便宜
- Q2/Q3(skillify/workflow)保留不变——它们不直接写 knowledge,写 SCAND

**Alex Gate 4 KA** → 缺口驱动的提炼回环:
- 读 Blake 的 journal → 尝试填 typed entry(P1 schema)→ 填不出的字段 = 问题 → 展示给用户 → 用户传给 Blake → Blake 答 → Alex 定稿 → 写 `project-knowledge/`
- 如果 journal 内容通不过变量化测试 → 留在 journal,不提炼(一次性)
- Codex-stranger 升级:当条目是 SAFETY / 跨项目复用 / 新 L1 → spawn Codex 再跑一遍提炼

---

## 3. Technical Plan

### 3.1 Blake Gate 3 KA 改动(blake/SKILL.md)

**改动范围**:L1804-1816 的 `knowledge_assessment` 段。

**改什么(逐字规格)**:

`must_answer` 改为:
```yaml
must_answer:
  - "Q1: 本次实现有什么值得追溯的发现、踩坑、或关键决策？(Yes → 追加到 journal / No → 写 'No discoveries')"
  - "Q2: 是否有可复用的工作模式？(Yes/No) — Skillify 4-gate + Step 5 路由。"
  - "Q3: 是否发现 workflow 模式？(Yes/No) — 手动多 agent 编排信号。"
```

Q1 Yes 路径改为:
```yaml
if_q1_yes:
  step1: "确定 journal 路径: evidence/journal/{handoff-slug}-{date}.md"
  step2: "追加到 journal(创建或 append)。格式自由——要点列表、散文、关键数值皆可。"
  step3: "在 completion report Knowledge Assessment 行写: 'Journal entry added: evidence/journal/{slug}-{date}.md'"
  note: "Blake 不写 project-knowledge/ 下的成品条目。那是 Alex 在 Gate 4 提炼回环里做的。"
```

`location` 行改为:`evidence/journal/`(不是 `project-knowledge/`)。

**不改什么(明确列出)**:
- `skillify_evaluation`(L1818-1877):保留不变——它写 SCAND,不写 knowledge
- `workflow_evaluation`(L1879+):保留不变
- `completion_knowledge_override`(L1913+):保留不变,但 `override_marker_anchor` 中的 `## Knowledge Assessment` header 继续触发 skillify_evaluation,只是 Q1 的产出换成 journal
- Gate 3 v2 的 Layer 1 / Layer 2 / 所有其他 step:不变

### 3.2 Alex Gate 4 KA 改动(alex/SKILL.md)

**改动范围**:L1559-1606 的 `post_review_knowledge` 段。

**替换为 `distillation_loop`(逐字规格)**:

```yaml
# ⚠️ MANDATORY: Knowledge Distillation Loop (replaces post_review_knowledge in SKILL body)
# ⚠️ 触发规则和 loop 入口 MUST stay in SKILL body (circular-trigger safety).
# ⚠️ This is the JOURNAL-distillation path. It does NOT replace acceptance-protocol step7.C
#    (C_alex_own_discoveries) — that remains unchanged and blocking as Alex's OWN-observation path.
# 详细步骤可放 reference.
distillation_loop:
  trigger: "验收完成后（无论通过与否），作为 Gate 4 KA 的执行方式"
  blocking: false  # ← P0-2 fix: 用户可跳过提炼,一致 "soft/advisory"
  
  high_level_flow: |
    Blake 写了 journal → Alex 当陌生人读它 → 尝试提炼为 typed entry →
    填不出的字段 = 问题 → 给用户让用户传给 Blake → Blake 答 → Alex 定稿。
    变量化测试不通过 → 留在 journal,不提炼。无 journal → skip。
  
  note_blocking_taxonomy: |
    ⚠️ 三层 blocking 分清:
    1. Blake Gate 3 Q1 (must_answer): blocking: true — 必须答 Yes/No,日记或不日记
    2. Alex distillation_loop (本节): blocking: false — 用户可跳过提炼
    3. Alex acceptance-protocol step7.C (C_alex_own_discoveries): blocking: true (unchanged) —
       Alex 基于自身审查发现直接写知识的路径,始终保持 blocking,这是 Gate 4 KA 仍然
       blocking 的安全网。即使 distillation_loop 被跳过,step7.C 仍然执行。
  
  reference: ".claude/skills/alex/references/distillation-loop-protocol.md"
  load_when: "When executing Gate 4 Knowledge Assessment, Read the reference for detailed steps."
```

**新增 reference 文件**:`.claude/skills/alex/references/distillation-loop-protocol.md`

内容规格(Blake 据此创建):

```markdown
# Distillation Loop Protocol

## Precondition
- Blake 的 completion report 标注了 journal 路径(evidence/journal/{slug}-{date}.md)
- 如果 journal 不存在或 Q1=No → 跳过提炼,KA 写 "No journal material to distill"
- 如果 journal 存在但内容过短(<3 行) → 跳过提炼,留 journal

## Step 1: 读取 journal
Read evidence/journal/{slug}-{date}.md。Alex 此时没有 Blake 的 session 上下文——
这正是去知识诅咒的机制(principles.md "Knowledge Is Forged at Distill, Not Captured")。

## Step 2: 变量化测试
对 journal 内容执行变量化测试(knowledge-writing-rules.md 规则 1):
- 把每个项目专属值替换为 {slot} → 连贯骨架还在?
- guard (a): 来源是 Gate-passed 工作?(是,因为已过 Gate 3)
- guard (b): 若成品仍含源案例字面值 → 抽象失败

如果测试不通过(全化成 slot / 什么都抽不出)→ 知识留 journal,不提炼。
KA 写 "Journal exists but material is one-off (variabilize test: FAIL)"。结束。

## Step 3: 起草 typed entry
用 playbook-entry-template.md 填写 6 字段:
- label: 从 journal 关键词生成
- selector: 枚举触发词 + near-miss 排除
- value: 祈使句、自包含、无相对时间
- failure_mode: naive 默认会怎么错(**如果填不出 → 这个字段变成问题**)
- validator: 怎么验证照做了
- read_only: 默认 false

## Step 4: 缺口检测
对草稿的每个字段自检:
- "我能从 journal 内容充分填出这个字段吗?"
- 能 → 保留
- 不能(信息不在 journal 里 / 不确定具体参数 / 不知道为什么这样选) →
  **这个字段变成一个精确的问题**

## Step 5: 缺口提问(如有)
如果有 ≥1 个字段填不出:
- 生成缺口问题列表:
  ```
  ## 🔍 Knowledge Distillation — Blake 需要回答的问题
  
  以下字段我从 journal 里填不出来,需要 Blake 的执行上下文:
  
  1. [failure_mode] — journal 说 "swell 不能太高",但没说 naive 默认会设多少、为什么那个值是错的。
     **问题: Blake,如果一个新手不读这条知识,它默认会把 swell 设成多少?为什么那个值有问题?**
  2. [validator] — journal 没提怎么验证这条做对了。
     **问题: 怎么验证 BGM swell 设置正确——播放检查还是有量化指标?**
  ```
- 展示给用户,用户传给 Blake(Terminal 2)
- Blake 答(追加到 journal 或直接回复)
- Alex 用答案填入草稿
- **封顶 2 轮**。2 轮后仍有缺口 → 标注 "[INCOMPLETE — field needs future verification]" 落盘,不阻塞

## Step 6: 定稿
- 应用 knowledge-writing-rules.md 5 条规则做最后一遍检查
- leak 检测: 成品还含源案例字面值 → 修或标注
- 写入 project-knowledge/{category}.md(用 playbook-entry-schema.md 格式)
- KA 写 "Playbook entry created: {label} in {category}.md"

## Step 7: Codex 升级(可选)
触发条件(任一):
- 条目将标 read_only: true(SAFETY)
- 条目预计跨项目复用(sync 到下游)
- 新 L1 原则级别

执行: spawn Codex CLI,只给它这一条 entry + "尝试按 entry 执行任务;列出每个不确定的点"。
Codex 提的问题 = 更严格的陌生人测试(不同模型先验)。

## Anti-Theater
- 如果用户决定跳过提炼 → 合法(soft, not blocking);KA 写 "User skipped distillation"
- 如果 Blake 没写 journal(Q1=No) → 合法;KA 写 "No discoveries"
- 整个 loop 是 advisory/human-gated;不注册 hook(L1 reject-mechanical-enforcement)
```

### 3.3 acceptance-protocol.md 改动

在 `step4e_feedback` 之后插入新的 step:

```yaml
step4f_distillation:
  name: "Knowledge Distillation Loop (journal→playbook)"
  blocking: false  # soft — user can skip; Gate 4 KA 仍 blocking via step7.C
  action: |
    Execute distillation_loop (see SKILL body trigger → load reference).
    This is the JOURNAL-to-PLAYBOOK distillation path.
    ⚠️ This does NOT replace step7.C (C_alex_own_discoveries) — step7.C is Alex's
    OWN-observation path (blocking: true, writes directly), which remains unchanged
    and ensures Gate 4 KA is still blocking overall even if the user skips step4f.
```

**step7.C (`C_alex_own_discoveries`)明确不变不标 DEPRECATED**:它是 Alex 基于自身审查发现写知识的路径(blocking),跟 distillation_loop 互补不重叠——step4f 炼 Blake 的 journal,step7.C 记 Alex 自己的发现。两者可以都写,也可以一个写一个不写。

`post_review_knowledge` 段(alex/SKILL.md L1559-1606)**标注 DEPRECATED**:
```
# DEPRECATED by distillation_loop (P2, 2026-06-22) — see distillation_loop above.
# 如果遇到此段,请忽略并转到 distillation_loop。不删除是为了 P4 迁移时清理。
# ⚠️ 注意：post_review_knowledge (SKILL body) ≠ step7.C (acceptance-protocol.md)。
# step7.C 是 NOT deprecated,仍然 blocking。
```

### 3.5 gate/SKILL.md 改动(P0-1 修复)

**改动范围**:gate/SKILL.md 的 `Knowledge_Assessment` 段中 `if_new_discovery` 路径和 `completion_report_rule` + `step5_verify`。

**改什么**:
- `if_new_discovery.step3`:从 "写入 `.tad/project-knowledge/{category}.md`" 改为 "写入 `evidence/journal/{handoff-slug}-{date}.md`"
- `completion_report_rule`:从 "New discovery recorded: .tad/project-knowledge/{category}.md" 改为 "Journal entry added: evidence/journal/{slug}-{date}.md"
- `step5_verify`:接受 `evidence/journal/` 作为有效 KA evidence 路径(不只是 `project-knowledge/`)
- `entry_format`:从 Context/Discovery/Action 改为"自由格式(journal)"
- 其余 gate KA 结构(blocking: true、Q1-Q3 问题本身)不变

### 3.4 evidence/journal/ 目录约定

- 路径:`evidence/journal/{handoff-slug}-{YYYY-MM-DD}.md`
- 格式:自由——要点列表/散文/关键数值。无 schema 约束。
- 规则:append-only(新发现追加,不编辑旧内容)
- 保留策略:journal 永久保留(不随 handoff 归档删除),是审计线索

**创建 `.tad/evidence/journal/.gitkeep`** 确保目录存在。

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/skills/alex/references/distillation-loop-protocol.md   # 提炼回环详细步骤
.tad/evidence/journal/.gitkeep                                  # journal 目录
```
### 7.2 Files to Modify
```
.claude/skills/blake/SKILL.md                # Gate 3 KA: Q1→journal, 不直接写 playbook
.claude/skills/alex/SKILL.md                 # Gate 4 KA: distillation_loop(触发+指向 reference) + post_review_knowledge 标 DEPRECATED
.claude/skills/alex/references/acceptance-protocol.md  # 插入 step4f_distillation
.claude/skills/gate/SKILL.md                 # KA if_new_discovery + completion_report_rule + step5_verify → 接受 evidence/journal/ 路径
```

---

## 9. Acceptance Criteria
- [ ] Blake Gate 3 KA Q1 路径指向 evidence/journal/,不指向 project-knowledge/
- [ ] Blake Gate 3 KA 不删除 skillify/workflow evaluation(保留不变)
- [ ] Alex SKILL.md 有 distillation_loop 触发规则在 body(非纯 reference)
- [ ] distillation-loop-protocol.md 包含 7 步(读journal→变量化→起草→缺口→提问→定稿→Codex升级)
- [ ] acceptance-protocol.md 有 step4f_distillation
- [ ] post_review_knowledge 标 DEPRECATED(不删除)
- [ ] evidence/journal/.gitkeep 存在

## 9.1 Spec Compliance Checklist

| # | AC | Verification Type | Verification Method | Expected | Verified Output |
|---|-----|-------------------|---------------------|----------|-----------------|
| 1 | Blake Q1 → journal | post-impl | `grep -E 'evidence/journal' .claude/skills/blake/SKILL.md \| wc -l` | >= 2 | (post-impl) |
| 2 | Blake Q1 不指向 project-knowledge(Q1 路径段内) | post-impl | `awk '/if_q1_yes:/,/^[^ ]/' .claude/skills/blake/SKILL.md \| grep -c 'project-knowledge'` | 0 | (post-impl) |
| 3 | skillify_evaluation 保留 | post-impl | `grep -c 'skillify_evaluation' .claude/skills/blake/SKILL.md` | >= 3 | (post-impl) |
| 4 | distillation_loop 在 alex body(含 trigger + load_when) | post-impl | `grep -cE 'distillation_loop\|load_when.*Gate 4' .claude/skills/alex/SKILL.md` | >= 2 | (post-impl) |
| 5 | reference 存在 | post-impl | `test -f .claude/skills/alex/references/distillation-loop-protocol.md && echo OK` | OK | (post-impl) |
| 6 | reference 含 7 step | post-impl | `grep -cE '^## Step [0-9]' .claude/skills/alex/references/distillation-loop-protocol.md` | 7 | (post-impl) |
| 7 | step4f 在 acceptance-protocol | post-impl | `grep -c 'step4f_distillation' .claude/skills/alex/references/acceptance-protocol.md` | >= 1 | (post-impl) |
| 8 | post_review_knowledge 标 DEPRECATED(指向 distillation_loop) | post-impl | `grep -iE 'DEPRECATED.*distillation_loop\|distillation_loop.*DEPRECATED' .claude/skills/alex/SKILL.md \| wc -l` | >= 1 | (post-impl) |
| 9 | journal 目录存在 | post-impl | `test -d .tad/evidence/journal && echo OK` | OK | (post-impl) |
| 10 | gate/SKILL.md 接受 journal 路径 | post-impl | `grep -E 'evidence/journal' .claude/skills/gate/SKILL.md \| wc -l` | >= 1 | (post-impl) |
| 11 | gate/SKILL.md Q1 不再指向 project-knowledge 写入 | post-impl | `awk '/if_new_discovery/,/^[^ ]/' .claude/skills/gate/SKILL.md \| grep -c 'project-knowledge.*写入'` | 0 | (post-impl) |
| 12 | distillation_loop blocking: false(一致) | post-impl | `grep -A2 'distillation_loop:' .claude/skills/alex/SKILL.md \| grep -c 'blocking: false'` | 1 | (post-impl) |
| 13 | step7.C 未标 DEPRECATED | post-impl | `grep -c 'C_alex_own_discoveries.*DEPRECATED\|DEPRECATED.*C_alex_own_discoveries' .claude/skills/alex/references/acceptance-protocol.md` | 0 | (post-impl) |
| 14 | 改动只落在 sanctioned 路径 | post-impl | `git diff --name-only \| grep -vE '^(\.claude/skills/(blake/SKILL\.md\|alex/SKILL\.md\|alex/references/(distillation-loop-protocol\|acceptance-protocol)\.md)\|\.claude/skills/gate/SKILL\.md\|\.tad/evidence/journal/\.gitkeep)$' \| grep -c .` | 0 | (post-impl) |

## 9.2 Expert Review Status

### Experts Selected
1. **code-reviewer** — AC 可执行性、SKILL 修改一致性、backward compat
2. **protocol-safety reviewer**(general-purpose) — Gate blocking 保持、terminal 隔离、知识链完整性

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: gate/SKILL.md 有 14 处 project-knowledge 引用和新 journal 路径矛盾,不在改动范围 | §3.5 新增 gate/SKILL.md 改动段;§7.2 加入 gate/SKILL.md;§9.1 加 AC10/AC11 | Resolved |
| code-reviewer | P0-2a: AC2 `sed` 范围提取不准 | §9.1 AC2 改用 `awk '/if_q1_yes:/,/^[^ ]/'` 精确段提取 | Resolved |
| protocol-safety | P0-2b: SKILL body `blocking: true` vs acceptance-protocol `blocking: false` 矛盾 | §3.2 SKILL body 改 `blocking: false`;§3.3 step4f 保持 `false`;§3.2 新增 `note_blocking_taxonomy` 三层分清 | Resolved |
| protocol-safety | P0-3: step7.C(C_alex_own_discoveries)和 distillation_loop 关系不明 | §3.2 note 明确 step7.C 不变不 DEPRECATED;§3.3 step4f action 明确互补关系;§9.1 AC13 验 step7.C 未标 DEPRECATED | Resolved |
| code-reviewer | P1-1: completion_knowledge_override 改写目标未说明 | §3.1 保留不变,override 触发后 Q1 产出换 journal(已在"不改什么"段说明) | Noted |
| protocol-safety | P1-1: blocking 三层分层需固化 | §3.2 `note_blocking_taxonomy` 逐字列出三层 | Resolved |
| protocol-safety | P2-1: 慢性跳过无提醒 | 可接受风险 per L1;P3 考虑加 skip 计数 soft warning | Deferred to P3 |
| code-reviewer | P2-2: DEPRECATED 段加指向 distillation_loop 的指引 | §3.3 DEPRECATED 注释含"请忽略并转到 distillation_loop"+ 明确"≠ step7.C" | Resolved |

### Overall Assessment (post-integration)
- **code-reviewer**: CONDITIONAL PASS → 2 P0 + 2 P1 全 Resolved/Noted
- **protocol-safety**: CONDITIONAL PASS → 2 P0 Resolved;KA 整体仍 blocking(via step7.C);terminal 隔离无违反;慢性跳过风险已接受

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Circular-trigger safety**:distillation_loop 的触发条件("验收完成后")和 `load_when`("When distillation_loop is entered at Gate 4")MUST 在 alex/SKILL.md body,不能只在 reference。详细步骤可放 reference。这是 principles.md circular-trigger 原则的直接要求。
- ⚠️ **不删 post_review_knowledge**:标 DEPRECATED 但保留文本,P4 再清理。避免在这个 phase 产生"旧代码被删"的 rollback 风险。
- ⚠️ **skillify/workflow evaluation 不动**:它们和 Q2/Q3 绑定,不直接写 knowledge,写 SCAND。改了会影响技能提取管线。
- ⚠️ **distill loop 是 soft(blocking: false)**:用户可以跳过。这跟 L1 reject-mechanical-enforcement 一致。但 Q1(journal)是 blocking(必须答 Yes/No)——分清哪层是硬哪层是软。

### 10.2 Dry-Run Walkthrough 要求
Blake 完成实现后,必须在 completion evidence 中写一个 **dry-run walkthrough**:取一个真实过去案例(推荐:voice-studio 的 "BGM swell 40% not 80%" 教训),模拟整个回环:
1. 假设 Blake 的 journal 写了什么(从 session log 提取)
2. Alex 作为陌生人读 journal,尝试填 typed entry
3. failure_mode 填不出(journal 没说 naive 默认是什么)→ 生成缺口问题
4. Blake 答("naive 默认 80%,因为...")→ Alex 填入
5. 展示最终 typed entry

这不是实际跑回环(P4 才在真实知识上跑),是纸面模拟证明流程可行。

---

**Handoff Created By**: Alex · **Date**: 2026-06-22 · **Version**: 3.1.0
