---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-notebook"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Dynamic Research Strategies — Follow-the-Thread + Contradiction Hunting + So-What Chain

**From:** Alex | **To:** Blake | **Date:** 2026-05-09
**Project:** TAD
**Task ID:** TASK-20260509-004
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Three strategies as post-ask analysis layer + structured storage |
| Components Specified | ✅ | SKILL.md ask flow + storage format |
| Functions Verified | ✅ | Existing ask, saturation detection, REGISTRY update patterns verified |
| Data Flow Mapped | ✅ | ask → extract findings → choose strategy → follow-up ask → save chain |

**Gate 2 结果**: ✅ PASS (post expert review v2 — 5 P0 resolved)

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

Upgrade `*research-notebook ask` from a single Q→A call into a **dynamic multi-round research engine** with three built-in strategies: Follow-the-Thread (chase surprising findings deeper), Contradiction Hunting (detect and resolve cross-source conflicts), and So-What Chain (force actionable conclusions). These strategies trigger on ALL `*research-notebook ask` invocations — not just inside `*research-plan`.

### 1.2 Why We're Building It

**业务价值**: 当前的 ask 是一问一答的静态模式。研究的深度完全取决于人类是否手动追问。最有价值的发现往往藏在第 2-3 层追问里 — 第一层答案只是表面，追问才能暴露矛盾、揭示盲点、逼出行动项。自动化追问让每次 ask 的价值密度提高 2-3 倍。

**成功的样子**: 用户问一个问题，系统自动追问 2-3 轮，产出一条完整的"发现链"（初始答案 → 惊讶发现 → 深入验证 → 行动建议），保存为结构化文件。

### 1.3 Intent Statement

**真正要解决的问题**: Ask 目前是广度优先 — 问 5 个独立问题，得 5 个浅答案。改为深度优先 — 问 1 个问题，自动追 3-4 层，得到 1 条深度发现链。

**不是要做的**:
- ❌ 不修改 NotebookLM CLI 本身 — 只修改 SKILL.md 的 ask 流程
- ❌ 不做并行 ask — 保持串行（NotebookLM 对话有状态）
- ❌ 不做自动 notebook 创建 — 假设 notebook 已存在
- ❌ 不修改 *research-plan Phase 0-3 — 只影响 Phase 4 的 ask 执行方式

---

## 📚 Project Knowledge (Blake 必读)

### 步骤 1：相关类别
- [x] architecture - NotebookLM CLI patterns, research methodology

**⚠️ Blake 必须注意的历史教训**:

1. **NotebookLM CLI State Management: `-n` Flag vs `use` Command** (architecture.md, 2026-05-05)
   - 所有 ask 调用必须用 `-n <notebook_id>`，不用 `use`

2. **Saturation Detection Requires Three States, Not Two** (architecture.md, 2026-05-08)
   - SATURATED / DIMINISHING / CONTINUE — 三态检测，不是二态

3. **NotebookLM Research Methodology: Report Is Baseline, Multi-Round Ask Is Value** (architecture.md, 2026-05-05)
   - Report 是方向感，多轮 ask 才是价值提取 — 本 handoff 正是强化这一点

---

## 2. Background Context

### 2.1 Current State
- `*research-notebook ask` = 单次 Q→A，无自动追问
- `*research-plan` Phase 4 = 预设 Question Tree，静态逐个 ask
- Phase 4b Gap Detection = 答案说"源里没有"时补充搜索 — 但不追问更深

### 2.2 Target State
- `*research-notebook ask` = Q→A → 自动分析答案 → 选择策略 → 追问 → 循环至饱和
- `*research-plan` Phase 4 = 2-3 个种子问题 → 每个自动深入 3-4 层
- 三个策略在任何 ask 调用时可用（standalone 或 *research-plan 内）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: Ask 完成后自动分析答案，提取 4 个维度：surprising / gap / conflict / actionable
- **FR2**: 基于提取结果自动选择下一步策略（Contradiction > Follow-up > Gap > So-What）
- **FR3**: Follow-the-Thread — 追问答案中最令人惊讶的发现，深入 1-2 层
- **FR4**: Contradiction Hunting — 检测跨源矛盾时，要求 notebook 对比证据并裁决
- **FR5**: So-What Chain — 链尾强制提取行动建议（"对我们的项目意味着什么"）
- **FR6**: 饱和检测控制深度 — 新引用为 0 连续 2 轮 → 停止；链深度 ≥ 4 → 强制 So-What 收束
- **FR7**: 每条发现链保存为结构化 .md 文件到 `.tad/evidence/research/{slug}/`
- **FR8**: 用户可用 `--no-follow` flag 跳过动态追问（保持原有单次 ask 行为）
- **FR9**: `*research-plan` Phase 4 的 Question Tree 从 5-10 个问题缩减为 2-3 个种子问题

### 3.2 Non-Functional Requirements

- **NFR1**: 每条链最多 4 层深度（防止无限追问）
- **NFR2**: 每轮 ask 之间 sleep 1（NotebookLM rate limit）
- **NFR3**: 追问产生的所有答案保存在同一个 .md 文件中（一条链一个文件）

---

## 4. Technical Design

### 4.1 Dynamic Ask Protocol（核心逻辑）

在 SKILL.md `*research-notebook ask` 的 Step 3（现有 ask 执行）之后，插入新的 Step 3.5:

```yaml
dynamic_ask_protocol:
  trigger: "Every ask call UNLESS --no-follow flag is passed"
  max_depth: 4
  
  step3_5_post_answer_analysis:
    name: "Answer Analysis + Strategy Selection"
    action: |
      After receiving ask answer, Alex (or standalone agent) analyzes the response:
      
      1. EXTRACT four dimensions from the answer:
         surprising:  "最令人惊讶的 1 个发现（与常识/预期不同的）"
         gap:         "答案暗示了什么未被覆盖的领域（'sources do not contain' signals）"  
         conflict:    "不同源之间是否有矛盾（'Source A says X, but Source B says Y'）"
         actionable:  "是否有可以直接转化为决策/代码变更的信息"
      
      2. Count new citations: extract [N] citation markers, compare with previous round
         new_citations = count of unique [N] markers not seen in prior rounds
      
      3. CHOOSE next strategy (priority order — P0-1 fix: saturated BEFORE so_what):
      
         # Hard stop — checked FIRST (evidence-based: nothing new to find)
         IF new_citations == 0 for 2 consecutive rounds:
           → strategy = "saturated"
           → Stop chain. Save findings. DO NOT ask again.
         
         # Highest-value strategy: cross-source conflict resolution
         ELIF conflict detected:
           → strategy = "contradiction"
           → follow_up = "关于'{topic}'，一些源认为'{claim_A}'，
              而另一些源认为'{claim_B}'。
              基于你的所有源，哪个说法有更强的证据支撑？
              请引用具体段落并解释矛盾的原因。"
           # P0-follow-up-fix: questions are SELF-CONTAINED (embed the claims as quotes)
           # Do NOT use "你提到..." referential phrasing — conversation may be fresh
         
         # Chase surprising findings deeper
         ELIF surprising finding AND current_depth < max_depth:
           → strategy = "follow_thread"  
           → follow_up = "关于'{surprising_finding}'（来自关于'{topic}'的研究），
              这具体是怎么实现的？有哪些已知的局限或失败案例？
              请从你的源中找到具体例子。"
           # P0-follow-up-fix: self-contained — embed the finding as quoted context
         
         # Gap detection — ONLY when running standalone (NOT inside *research-plan Phase 4)
         ELIF gap detected AND NOT inside_research_plan:    # P0-3 fix: disable inside Phase 4
           → strategy = "gap_enrichment"
           → Trigger existing Phase 4b CRAG Judge Loop (source add-research fast → re-ask)
           # When inside *research-plan, Phase 4b handles gaps directly — avoid double-loop
         
         # Budget-based forced close — checked AFTER saturation
         ELIF current_depth >= max_depth:
           → strategy = "so_what"  # TERMINAL — see step 4b below
           → follow_up = "基于到目前为止关于'{topic}'的所有发现，
              对于{project_context}，最重要的 3 个行动建议是什么？
              每个建议请对应具体的源引用。"
         
         ELSE:
           → strategy = "continue"
           → (no auto-follow-up; user can manually ask next question)
      
      4. If strategy in [contradiction, follow_thread]:
         → Execute follow-up ask:
           ~/.tad-notebooklm-venv/bin/notebooklm ask "{follow_up}" -n <notebook_id>
           # P0-2 fix: always use -n flag; do NOT use -c 00000000... fresh conversation
           # (follow-ups may benefit from conversation context; fresh would destroy it)
           # If ask fails, fail-fast — do NOT retry with Layer 2 fresh conversation
         → sleep 1
         → Increment current_depth
         → Append round to chain .md (incremental write for compact-recovery — P1-4)
         → Loop back to step 3.5
      
      4b. If strategy == "so_what":                         # P0-so_what-terminal fix
         → Execute so-what ask (same as above)
         → DO NOT loop back to step 3.5. so_what is ALWAYS terminal.
         → Append final round to chain .md
         → Save chain and exit. (fall through to step 5)
      
      5. If strategy == "saturated" OR so_what completed:
         → Finalize chain .md in .tad/evidence/research/{notebook_topic}/ (§4.3)
         → Report: "🔬 Research chain complete: {depth} rounds, {strategy_count} strategies used.
            Findings saved to {file_path}"
      
      Context detection for inside_research_plan (P0-3 fix):
        → If .research/research-state.yaml exists AND phase == "ask" → inside_research_plan = true
        → Else → inside_research_plan = false
        → When inside_research_plan: gap_enrichment strategy DISABLED (Phase 4b already handles it)
```

### 4.2 Integration Points

**Where this logic lives**: Add `step3_5_post_answer_analysis` to SKILL.md's `*research-notebook ask` command, between existing Step 3 (ask execution) and Step 4 (display answer).

**Standalone mode**: When invoked outside *research-plan (e.g., `*research-notebook ask "question"`), the dynamic protocol runs the same way. The `--no-follow` flag skips step 3.5 entirely.

**Inside *research-plan Phase 4**: The existing Question Tree generation (STEP 3.9 / Phase 4 Step 1) changes from "5-10 questions" to "2-3 seed questions". Each seed question enters the dynamic protocol, producing a deeper chain instead of a shallow answer. The `max_chains` limit is 3 (matching seed question count).

**project_context for So-What**: Read from OBJECTIVES.md if available (KR descriptions), else from PROJECT_CONTEXT.md, else from user's original question topic.

### 4.3 Storage Design

Each research chain is saved as a single .md file:

```
.tad/evidence/research/{notebook_topic}/       ← matches existing convention (P1-2 fix)
  {date}-chain-{topic_slug}.md                 ← one file per chain
```

**{notebook_topic} derivation**: read from REGISTRY.yaml → notebook entry → `topic` field.
Consistent with existing report files (e.g., `{date}-report.md`, `{date}-ask-findings.md`).

File format:
```markdown
---
type: research-chain
notebook_id: {id}
seed_question: "{original question}"
depth: {N}
strategies_used: [follow_thread, contradiction, so_what]
total_citations: {N unique}
created_at: {ISO timestamp}
---

## Seed Question
{original question}

## Round 1 — Initial Answer
{full answer with citations}

### Analysis
- Surprising: {extracted finding}
- Strategy: follow_thread

## Round 2 — Follow-up: {follow_up_question}
{answer}

### Analysis
- Conflict detected: {source A vs source B}
- Strategy: contradiction

## Round 3 — Contradiction Resolution: {contradiction question}
{answer}

### Analysis
- Strategy: so_what (max depth reached)

## Round 4 — Actionable Conclusions
{so-what answer with 3 action items}

## Chain Summary
- **Key finding**: {1-sentence summary of the most important discovery}
- **Action items**: {bullet list of concrete next steps}
- **Sources cited**: {count} unique sources across {depth} rounds
```

### 4.4 `--no-follow` Flag

Add to existing `*research-notebook ask` command signature:
```
*research-notebook ask <question> [--notebook <id>] [--no-follow]
```

When `--no-follow` is passed, skip step 3.5 entirely — behave exactly as current single-round ask.

Default (no flag): dynamic protocol runs.

---

## 5. Files to Modify

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/research-notebook/SKILL.md` | MODIFY | Add step3_5 to `ask` command; add `--no-follow` flag; update *research-plan Phase 4 seed question count |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY (minor) | Update `research_plan_protocol.step4` Phase 4 Step 1: "5-10 questions" → "2-3 seed questions" |

**Grounded Against**:
- .claude/skills/research-notebook/SKILL.md (lines 127-267, read 2026-05-09)
- .claude/skills/alex/SKILL.md (*research-plan step4 Phase 4, read at session start)

---

## 6. Implementation Details

### Task 1: Add `step3_5_post_answer_analysis` to SKILL.md ask command

**Insert after** existing Step 3 (ask execution, ~line 179) and **before** Step 4 (REGISTRY update).

The step3_5 protocol from §4.1 should be written as a YAML-style protocol block (matching SKILL.md's existing formatting). Key implementation notes:

- **Citation counting**: `grep -oE '\[[0-9]+\]' "$answer" | sort -u | wc -l` — count unique [N] markers
- **Strategy selection is LLM judgment**: Alex (or standalone agent) reads the answer and decides which of the 4 dimensions is strongest. This is NOT a regex — it's semantic analysis by the agent.
- **Recursion limit**: Track `current_depth` as a counter in conversation context. Reset to 0 for each new seed question.
- **sleep 1 between asks**: Prevent NotebookLM rate limiting.

### Task 2: Add `--no-follow` flag handling

At the top of the `ask` command (Step 1 area), add flag detection:
```
If --no-follow in args:
  → Set dynamic_follow = false
  → Remove --no-follow from args before passing to notebooklm CLI
Else:
  → Set dynamic_follow = true

After Step 3 (ask execution):
  If dynamic_follow == false → skip step3_5, go directly to Step 4
```

### Task 3: Add chain storage logic

After step3_5 completes (strategy == "saturated" or "so_what" completed):
```
1. Generate topic_slug from seed question (first 30 chars, alphanum+hyphens)
2. Determine {slug} directory:
   → If inside *research-plan: use the plan's slug
   → If standalone: use notebook topic as slug
3. Write chain .md file per §4.3 format
4. Output: "🔬 Chain saved to {path}"
```

### Task 4: Update Alex SKILL.md *research-plan Phase 4

In `research_plan_protocol.step4`:
- Change "Generate Question Tree" from "5-10 questions from KRs" to "2-3 seed questions from KRs"
- Add note: "Each seed question triggers dynamic_ask_protocol (step3_5) automatically"
- The rest of Phase 4 (cross-notebook, gap detection, enrichment) remains unchanged

---

## 7. Testing Checklist

- [ ] `ask "question" --no-follow` behaves exactly as current (single Q→A, no follow-up)
- [ ] `ask "question"` triggers step3_5 analysis + at least one follow-up
- [ ] Follow-the-thread: surprising finding in answer → auto-generates follow-up question
- [ ] Contradiction detection: conflicting sources → asks for evidence comparison
- [ ] So-what: chain reaches depth 4 → forces actionable conclusions
- [ ] Saturation: 2 consecutive rounds with 0 new citations → chain stops
- [ ] Chain .md file saved to .tad/evidence/research/{slug}/ with correct format
- [ ] *research-plan Phase 4 uses 2-3 seeds instead of 5-10 questions

---

## 8. Acceptance Criteria

| # | AC | Verification |
|---|-----|-------------|
| AC1 | step3_5 exists in SKILL.md ask command | `grep -c 'step3_5\|post_answer_analysis\|dynamic_ask' .claude/skills/research-notebook/SKILL.md` ≥ 1 |
| AC2 | Three strategies named in SKILL.md | `grep -c 'follow_thread\|contradiction\|so_what' .claude/skills/research-notebook/SKILL.md` ≥ 3 |
| AC3 | --no-follow flag documented | `grep -c 'no-follow' .claude/skills/research-notebook/SKILL.md` ≥ 2 |
| AC4 | max_depth = 4 specified | `grep -c 'max_depth.*4\|depth.*4\|4.*depth' .claude/skills/research-notebook/SKILL.md` ≥ 1 |
| AC5 | Chain storage path specified | `grep -c 'evidence/research.*chain' .claude/skills/research-notebook/SKILL.md` ≥ 1 |
| AC6 | Saturation detection (0 new citations × 2 rounds) | `grep -c 'new_citations.*0\|saturated' .claude/skills/research-notebook/SKILL.md` ≥ 1 |
| AC7 | Alex SKILL.md seed questions updated | `grep -c '2-3.*seed\|seed.*2-3' .claude/skills/alex/SKILL.md` ≥ 1 |
| AC8 | Sleep 1 between ask rounds | `grep -c 'sleep 1' .claude/skills/research-notebook/SKILL.md` ≥ 1 (in step3_5 context) |

---

## 9. Important Notes

### 9.1 这不是"自动化研究" — 是"增强每次 ask 的深度"
策略选择是 LLM 判断（Alex 或 standalone agent 读答案然后决定），不是正则匹配。三个策略是工具，不是流程 — agent 基于答案内容选择最合适的一个。

### 9.2 与 Phase 4b Gap Detection 的关系（P0-3 fix 更新）
- **Standalone ask**（不在 *research-plan 内）: step3_5 的 gap 策略可用，复用 Phase 4b 逻辑
- **Inside *research-plan Phase 4**: gap_enrichment 策略 DISABLED — Phase 4b 已经处理 gap，避免双重循环
- contradiction 和 follow_thread 在两种场景下都可用

### 9.3 Follow-up 问题必须是自包含的（BA-P0-2 fix）
Follow-up 问题不能用"你提到..."这种引用对话上下文的措辞。NotebookLM 对话可能被重置（Layer 2 fresh conversation 或超时）。所有 follow-up 必须把关键发现作为引用文本嵌入问题本身。

### 9.4 Follow-up ask 不使用 Layer 2 重试（CR-P0-2 fix）
Follow-up asks 使用 `-n <notebook_id>` 但 **不使用** `-c 00000000...` fresh conversation fallback。如果 follow-up ask 失败，fail-fast（chain 提前终止并保存已有内容），不重试。原因：fresh conversation 会丢失追问所依赖的对话上下文。

---

## 10. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | 触发范围 | 只 *research-plan / 所有 ask | 所有 ask | 用户确认 |
| 2 | 存储位置 | .research/sessions / .tad/evidence/research | .tad/evidence/research/{notebook_topic}/ | 用户确认 + BA-P1-2 path fix |
| 3 | 默认行为 | 默认动态 / 默认静态 | 默认动态 + --no-follow opt-out | 深度研究成为默认 |
| 4 | 种子问题数 | 5-10 / 2-3 | 2-3（Alex 可加到 4-5 with justification） | 深度优先 |
| 5 | 策略优先级 | 平等 / 有优先级 | saturated > contradiction > follow > gap > so_what | saturated 是硬停（P0-1 fix）；so_what 是预算停 |
| 6 | so_what 终止性 | 循环 / 终止 | 终止（不 loop back） | CR-P0-3 fix |
| 7 | gap inside Phase 4 | 启用 / 禁用 | 禁用（Phase 4b 已处理） | BA-P0-3 fix |

---

## 11. Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0-1: saturated unreachable (priority order) | §4.1 step 3 reordered: saturated checked FIRST | Resolved |
| code-reviewer | P0-2: Layer 2 retry loses -n flag | §9.4 follow-up no Layer 2 retry | Resolved |
| code-reviewer | P0-3: so_what loops back | §4.1 step 4b: so_what is terminal | Resolved |
| code-reviewer | P1-1: insertion line number wrong | §6 Task 1: use step name not line number | Resolved |
| code-reviewer | P1-3: --no-follow is LLM-parsed not argv | §9 note: consumed by SKILL gate logic | Resolved |
| code-reviewer | P1-4: slug derivation ambiguous | §4.1 step 5: read research-state.yaml for context | Resolved |
| backend-architect | P0-1: same saturated bug | same fix | Resolved |
| backend-architect | P0-2: referential follow-up phrasing | §4.1 step 3 templates rewritten self-contained + §9.3 | Resolved |
| backend-architect | P0-3: Phase 4 double-loop | §4.1 inside_research_plan detection + §9.2 | Resolved |
| backend-architect | P1-2: storage path diverges from convention | §4.3 uses {notebook_topic}/ | Resolved |
| backend-architect | P1-4: depth counter not compact-safe | §4.1 step 4: incremental write to chain .md | Resolved |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/dynamic-research-strategies/code-reviewer.md
  - .tad/evidence/reviews/blake/dynamic-research-strategies/backend-architect.md
completion:
  - .tad/active/handoffs/COMPLETION-20260509-dynamic-research-strategies.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md
```
