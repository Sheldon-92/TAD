---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-notebook", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Research Director + Advanced CLI (Phase 2)

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Project:** TAD | **Task ID:** TASK-20260504-003
**Epic:** EPIC-20260504-notebooklm-research-director.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-04 (pending expert review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3 tracks clearly defined (Director behavior + CLI + *learn) |
| Components Specified | ✅ | Alex SKILL insertion points identified, CLI commands specified |
| Functions Verified | ✅ | All CLI commands verified in FULL-CLI-RESEARCH.md |
| Data Flow Mapped | ✅ | Research Director triggers → CLI calls → results flow back to TAD workflow |

**Gate 2 结果**: ✅ PASS (2 experts: CR 5P0+6P1, BA 4P0+5P1 — all P0 resolved)

**Alex确认**: Expert review 完成，9 个 P0 全部修复。Blake 按 §6 实现顺序 (B→C→A) 可独立完成。

---

## 1. Task Overview

### 1.1 背景
Phase 0 验证了 NotebookLM CLI 能力，Phase 1 扩展了 SKILL 基础命令。但 Alex 仍然没有"研究总监"意识 — 不会主动扫描已有 notebook、不会建议整合、不会在设计时引用研究成果。Phase 2 让 Alex 成为一个有主动研究判断力的研究总监。

### 1.2 三个 Track
- **Track A**: Alex Research Director 行为 — 三个触发点 + notebook 整合 + 研究组合管理(*research-review) + *status 集成
- **Track B**: SKILL 高级 CLI — fulltext, --source targeting, --save-as-note, language, --retry, auth check 升级
- **Track C**: *learn 集成 — quiz/flashcards 生成 + markdown 下载

### 1.3 非目标
- 不改 Blake SKILL（Phase 3）
- 不实现 slide-deck / video / share / profile（Tier 2, 后续）
- 不写 hooks（纯 SKILL 层改动）

---

## 2. Requirements

### Track A: Alex Research Director 行为

#### A1: 激活时研究态势感知 (Alex SKILL.md → STEP 3.X)

在现有 STEP 3.7 (Session State Check) 之后，STEP 4 (greeting) 之前插入：

```yaml
step3_8_research_landscape:
  name: "Research Landscape Scan"
  action: |
    1. Check if .tad/research-notebooks/REGISTRY.yaml exists
       → If not: skip silently (project has no NotebookLM integration)
    2. If exists: Read REGISTRY.yaml
       a. Count notebooks by status (active/dormant/archived)
       b. If active_count > 5:
          → Output: "📚 Research: {active_count} active notebooks. Consider *research-notebook curate to consolidate."
       c. If active_count > 0:
          → Output: "📚 Research: {active_count} notebooks available ({topics_summary})"
       d. If active_count == 0 AND dormant_count > 0:
          → Output: "📚 Research: {dormant_count} dormant notebooks. Use *research-notebook list to review."
  blocking: false
  suppress_if: "REGISTRY.yaml not found OR 0 active + 0 dormant notebooks"
  interacts_with: |
    Runs AFTER STEP 3.7 (session state), regardless of STEP 3.7 outcome.
    Does NOT affect STEP 4 suppression — STEP 3.7's interacts_with rule controls that.
    If STEP 3.7 already suppresses STEP 4, step3_8 output still shows
    (research landscape is informational, independent of greeting).
```

#### A2: *discuss 主动研究 (discuss_path_protocol.research_notebook_awareness 升级)

替换现有 `research_notebook_awareness` 段。**替换边界**：仅替换 `research_notebook_awareness:` 块（trigger + action + note + fallback 子字段），**不要触碰**紧随其后的 `forbidden:` 列表和 `note_on_research_protocol:` 块。

```yaml
research_notebook_awareness:
  trigger: "进入 *discuss 后，首次回答用户话题之前"
  action: |
    ⚠️ 以下步骤在 domain_pack_awareness 之后、首次回答之前执行。

    1. Read .tad/research-notebooks/REGISTRY.yaml
       → If not found → skip silently (同现有 fallback)
    
    2. Match current topic against notebook topics (LLM semantic match):
       → For each active/dormant notebook: does its `topic` field relate to the current discussion?
    
    3. If matching notebook found:
       a. Output: "📚 Found relevant notebook: '{topic}' ({source_count} sources, last queried: {date})"
       b. Run: *research-notebook topics (display-only summary of that notebook)
       c. AskUserQuestion: "要在讨论中引用这个 notebook 的知识吗？"
          Options:
            - "查询 notebook" → execute *research-notebook ask "{topic-related question}" with notebook
            - "先看源质量" → execute *research-notebook fulltext on top 2 sources, display preview
            - "不需要，继续讨论" → skip
    
    4. If no matching notebook AND topic needs deep research:
       a. AskUserQuestion: "这个话题可能需要深度研究。要创建一个 research notebook 吗？"
          Options:
            - "创建 notebook + Deep Research" → *research-notebook create + *research-notebook research --mode deep
            - "创建 notebook (manual sources)" → *research-notebook create
            - "用 WebSearch 就够了" → skip

    5. If multiple matching notebooks found (>2 on same topic):
       → Trigger notebook_consolidation_suggestion (see A4)
  
  fallback: "REGISTRY.yaml 不存在或 NotebookLM 未安装 → 静默跳过"
```

#### A3: *analyze Socratic 后研究空白检查 (新增 step0_5b — 独立步骤)

在 handoff_creation_protocol.workflow 中，step0_5 和 step1 之间插入新的 peer 步骤 `step0_5b`（不是 step0_5 的子步骤）：

```yaml
step0_5b:
  name: "Research Asset Check (post-Socratic)"
  trigger: "After step0_5 knowledge reload completes, before step1 draft creation"
  action: |
    1. Read REGISTRY.yaml → find notebooks relevant to this handoff's scope
    2. If relevant notebook exists:
       a. Run: *research-notebook topics (get suggested queries)
       b. Check: are there research findings in .tad/evidence/research/ for this topic?
       c. If findings exist → cite in handoff §📚 Project Knowledge section
       d. If notebook exists but no findings → AskUserQuestion:
          "有一个相关 notebook '{topic}' 但还没产出研究报告。要现在生成吗？"
          Options:
            - "生成 briefing report" → *research-notebook report "...related to handoff scope"
            - "跳过，不影响 handoff" → continue
    3. If no relevant notebook → skip (existing research_decision_protocol handles WebSearch)
  blocking: false
```

#### A4: Notebook 整合建议 (新增 consolidation_suggestion)

```yaml
notebook_consolidation_suggestion:
  trigger: "A2 step5 检测到 >2 notebooks 匹配同一话题 OR A1 检测到 >5 active notebooks"
  action: |
    1. Analyze overlap:
       → For each matching notebook pair: compare topic field + source list overlap
       → Group by semantic similarity: "这 3 个 notebook 都在研究恐怖内容生产"
    
    2. Propose consolidation plan:
       → "建议将以下 notebook 整合：
          - '{nb1}' ({N} sources) + '{nb2}' ({M} sources) → 合并为 '{suggested_merged_topic}'
          原因：主题高度重叠，合并后 ask 能跨源综合分析"
    
    3. AskUserQuestion: "要执行整合吗？"
       Options:
         - "执行整合" → Step 4
         - "只整合部分" → user picks which
         - "不整合" → skip
    
    4. Delegate execution to *research-notebook consolidate (B6):
       → A4 is detection + suggestion layer ONLY
       → B6 (*research-notebook consolidate) is execution layer
       → A4 passes selected groups to B6: "*research-notebook consolidate with pre-selected groups"
       → A4 does NOT re-implement merge logic (避免 A4/B6 双重实现导致 drift)
```

#### A6: 研究组合管理 — 持续性研究战略 (新增 `*research-review` 行为)

Alex 不是做完一个研究就放下。他要像研究总监一样管理整个项目的研究组合：

```yaml
research_portfolio_management:
  description: "Alex 持续管理项目所有研究线程，为项目目标服务"
  
  # 触发时机 1: *status 命令自动包含研究状态
  status_integration:
    trigger: "用户运行 *status 时"
    action: |
      在 *status panoramic 输出末尾追加 Research Portfolio 板块:
      
      ### Research Portfolio
      | Notebook | Status | Sources | Last Activity | Relevance to Current Goals |
      |----------|--------|---------|---------------|---------------------------|
      | {topic}  | 🟢 Active / 💤 Dormant / ❓ Drifting | {N} | {date} | {Alex判断} |
      
      Relevance 判断逻辑:
      - Read ROADMAP.md + NEXT.md current priorities
      - For each notebook topic: does it align with an active Epic/task/roadmap theme?
      - If YES → "🎯 Aligned with: {Epic/task name}"
      - If NO clear alignment → "❓ No current alignment — consider archive or pivot"
      - If actively supporting an in-progress task → "🔥 Supporting: {task}"
  
  # 触发时机 2: 新命令 *research-review (研究复盘)
  review_command:
    trigger: "用户说 *research-review 或 Alex 在 *discuss 中发现研究散乱时主动建议"
    execution:
      step1:
        name: "全景扫描"
        action: |
          1. Read REGISTRY.yaml → all notebooks
          2. Read ROADMAP.md → project themes + goals
          3. Read NEXT.md → current tasks + epics
          4. For each active notebook:
             → Last queried date (freshness)
             → Source count (depth)
             → Alignment with current project goals
      
      step2:
        name: "分类诊断"
        action: |
          将所有 notebooks 分为四类:
          - 🔥 **加强**: 与当前目标强相关 + 最近活跃 → "这个研究应该继续深入"
          - ✅ **维持**: 与当前目标相关 + 已有充足成果 → "保持，需要时查询"
          - 🔄 **转向**: 与当前目标不再相关但有价值 → "话题需要调整方向"
          - 📦 **关闭**: 与当前目标无关 + 长期不活跃 → "建议归档"
          
          Output: 分类表格 + 每个 notebook 一句话理由
      
      step3:
        name: "行动建议"
        action: |
          AskUserQuestion: "这是你的研究组合诊断。要执行哪些操作？"
          Options:
            - "执行全部建议" → 逐个执行(加强=add-research, 关闭=archive, 转向=discuss pivot)
            - "只执行关闭/归档" → archive the 📦 ones
            - "逐个确认" → per-notebook AskUserQuestion
            - "只看看，不操作" → exit
      
      step4_strengthen:
        name: "加强研究"
        action: |
          For each 🔥 notebook:
          → AskUserQuestion: "'{topic}' 需要加强。怎么做？"
            Options:
              - "Deep research (自动加源)" → *research-notebook research --mode deep
              - "生成一份综合报告" → *research-notebook report "..."
              - "我来指定新源" → *research-notebook add
              - "跳过"
      
      step4_close:
        name: "关闭研究"
        action: |
          For each 📦 notebook:
          → *research-notebook archive (with user confirmation per existing flow)
      
      step4_pivot:
        name: "研究转向"
        action: |
          For each 🔄 notebook:
          → AskUserQuestion: "'{topic}' 需要转向。新方向是什么？"
            Options:
              - "重新定向" → create new notebook with new topic + migrate sources from old + archive old (notebooklm rename 不存在，用 create+migrate+archive 替代)
              - "保留源，新建角度" → configure --persona to reframe research lens
              - "整合到另一个 notebook" → trigger consolidation via B6
              - "直接归档" → archive
  
  # 触发时机 3: 被动检测 — Alex 在 *discuss 中发现研究散乱时
  passive_detection:
    trigger: "*discuss 中 Alex 发现用户在谈论一个已有 dormant notebook 的话题"
    action: |
      如果话题与一个 dormant (>14天未查询) notebook 高度匹配:
      → "我注意到你有一个关于 '{topic}' 的 notebook (💤 {days} 天未使用)。
         要重新激活并用它辅助讨论吗？或者它已经完成使命可以归档？"
```

#### A5: handoff 写入时引用研究成果 (step0_5 + step1 增强)

在 handoff 的 `§📚 Project Knowledge` 和 `§11 Decision Summary` 中自动引用：

```yaml
research_citation_in_handoff:
  trigger: "handoff_creation_protocol step1 draft 写作时"
  action: |
    If A3 found relevant notebook findings:
    1. In §📚 Project Knowledge section, add:
       "### Research Notebook Findings
        Notebook: '{topic}' ({source_count} sources)
        Key findings relevant to this handoff:
        - {finding 1 from *research-notebook ask}
        - {finding 2}
        Report: {path to .tad/evidence/research/ if generated}"
    
    2. In §11 Decision Summary, if any decision was informed by notebook research:
       Add "Research source" column showing which notebook/source informed the decision
```

---

### Track B: research-notebook SKILL 高级 CLI

#### B1: Preflight 升级 — `auth check --test` 替换 `list`

```
现有 preflight.checks 第3条:
  "Auth valid: ~/.notebooklm/storage_state.json exists (not checking expiry)"
替换为:
  "Auth valid: ~/.tad-notebooklm-venv/bin/notebooklm auth check --test 2>&1 | grep -q 'authenticated'"
  on_fail: "⚠️ NotebookLM auth expired. Run: bash .tad/cross-model/setup-notebooklm.sh"
```

#### B2: `ask` 命令增强 — --source + --save-as-note

```
在现有 ask Step 3 (Execute query) 中添加可选 flag:

Step 2.5 (NEW): Source targeting (optional)
  → If user specifies --source <id>:
    → notebooklm ask "{question}" --source <id1> --source <id2> -n <notebook_id>
    → Display: "🎯 Querying specific sources: {source_titles}"
  → If no --source: query all sources (existing behavior)

Step 3 (ENHANCED): Add --save-as-note
  → All ask queries in *discuss and *analyze contexts automatically add:
    --save-as-note --note-title "TAD Research: {first 40 chars of question}"
  → This creates a persistent audit trail of every research question asked
  → Note: notes don't participate in future ask (Phase 0 finding), but they
    preserve the conversation history for human review
```

#### B3: `report` 命令增强 — --append + --retry + --source

```
在现有 report Step 2 (Generate) 中:

Step 1.5 (NEW): Customize report
  → AskUserQuestion: "要给报告追加特殊要求吗？"
    Options:
      - "使用默认模板" → no --append
      - "追加自定义指令" → user types instruction → --append "{instruction}"
      - "限定特定源" → show source list → user picks → --source <id> (repeatable)

Step 2 (ENHANCED):
  → notebooklm generate report "{description}" --append "{extra}" --source <id> --retry 3 -n <id> --wait
  → --retry 3 replaces Phase 1's manual retry logic
```

#### B4: 新命令 `*research-notebook fulltext <source_id>`

```
Step 0: Resolve target notebook

Step 1: Get source ID
  → If <source_id> provided → use it
  → If not → notebooklm source list -n <id> → AskUserQuestion pick source

Step 2: Extract fulltext
  → notebooklm source fulltext <source_id> -n <id> -o /tmp/tad-fulltext-{source_id}.txt
  → Read first 100 lines for preview

Step 3: Display + option to save
  → Display preview (first 100 lines)
  → AskUserQuestion: "Save fulltext to project?"
    - "Save to .tad/evidence/research/" → copy file
    - "Just preview, don't save" → cleanup tmp file

Use case: Alex Research Director evaluates source quality before recommending deep dives
```

#### B5: 新命令 `*research-notebook language [set|get|list]`

```
*research-notebook language set <code>:
  → notebooklm language set <code>
  → "✅ NotebookLM output language set to {language_name}. Affects all future reports/quizzes."

*research-notebook language get:
  → notebooklm language get --local
  → Display current language setting

*research-notebook language list:
  → notebooklm language list
  → Display supported languages table
```

#### B6: 新命令 `*research-notebook consolidate`

```
Step 1: List all active notebooks with topics
  → notebooklm list → display table

Step 2: Analyze overlap (Alex LLM judgment)
  → Group notebooks by semantic similarity
  → For each group with >1 notebook:
    → Display: "这 {N} 个 notebook 话题重叠: {list}"

Step 3: AskUserQuestion for each group:
  "建议整合这组 notebook。选择操作："
  Options:
    - "整合为一个" → Step 4
    - "保留独立" → skip this group
    - "删除其中 N 个" → pick which to delete

Step 4: Execute merge
  → Create new notebook with merged topic name
  → For each source in old notebooks:
    → Read source list from old notebook
    → Add each source URL/file to new notebook
  → Archive old notebooks
  → Update REGISTRY
```

---

### Track C: *learn 模式集成

#### C1: Alex SKILL.md learn_path_protocol 增强

在 `learn_path_protocol.execution.step3` (Teach - Socratic Loop) 中添加：

```yaml
step3_5_quiz_generation:
  name: "Generate Learning Assessment (optional)"
  trigger: "After 3+ Socratic rounds, when user shows understanding"
  action: |
    1. Check if current topic has a matching notebook in REGISTRY
    2. If yes → AskUserQuestion:
       "你对这个话题理解得不错了。要生成一个小测验来巩固学习吗？"
       Options:
         - "生成 Quiz (推荐)" → Step 3
         - "生成 Flashcards" → Step 4
         - "不需要，继续学习" → skip
    
    3. Generate Quiz:
       → notebooklm generate quiz --difficulty medium --quantity standard -n <notebook_id> --retry 3 --wait
       → notebooklm download quiz --format markdown /tmp/tad-quiz-{topic}.md -n <notebook_id>
       → Read + display quiz content to user
       → Save to .tad/evidence/research/{topic}/quiz-{date}.md
    
    4. Generate Flashcards:
       → notebooklm generate flashcards --difficulty medium --quantity standard -n <notebook_id> --retry 3 --wait
       → notebooklm download flashcards --format markdown /tmp/tad-flashcards-{topic}.md -n <notebook_id>
       → Read + display flashcard content
       → Save to .tad/evidence/research/{topic}/flashcards-{date}.md
    
    5. If no matching notebook → skip silently (quiz/flashcards need source corpus)
```

#### C2: research-notebook SKILL 新命令 `*research-notebook quiz` + `*research-notebook flashcards`

```
*research-notebook quiz [--difficulty easy|medium|hard] [--quantity fewer|standard|more]:
  Step 0: Resolve target notebook
  Step 1: Generate
    → notebooklm generate quiz --difficulty {d} --quantity {q} -n <id> --retry 3 --wait
  Step 2: Download as markdown
    → notebooklm download quiz --format markdown <output_path> -n <id>
  Step 3: Display + save to .tad/evidence/research/{topic}/

*research-notebook flashcards (同上结构，用 flashcards 替换 quiz)
```

---

## 6. Implementation Order (⚠️ 跨 Track 依赖)

**必须按 B → C → A 顺序实现。** A 的协议调用 B/C 的命令 — 如果先做 A，引用的命令不存在。

```
Phase 1: Track B (research-notebook SKILL CLI 扩展)
  B1: preflight auth check 升级
  B2: ask --source + --save-as-note flag 支持 (SKILL 只是支持 flag，不自动加)
  B3: report --append + --retry + --source
  B4: fulltext 新命令
  B5: language 新命令
  B6: consolidate 新命令

Phase 2: Track C (*learn 集成)
  C2: quiz + flashcards 新命令 (research-notebook SKILL)
  C1: learn_path_protocol step3_5 (Alex SKILL — 调用 C2 命令)

Phase 3: Track A (Alex Research Director 行为)
  A1: step3_8 activation scan
  A2: discuss awareness 升级 (调用 B4 fulltext)
  A3: step0_5b research asset check (调用 report)
  A4: consolidation suggestion (委托给 B6)
  A6: *research-review + *status integration
  A5: handoff citation
```

**B2 关键澄清**: `--save-as-note` 是 SKILL 层支持的 flag，**不是自动行为**。Alex SKILL (A2/A3) 在调用 ask 时主动添加 `--save-as-note` flag — research-notebook SKILL 不检测调用上下文。`--no-save` flag 允许 Alex 在隐私敏感场景跳过保存。

---

## 3. Files to Modify

| # | File | Action | Lines ~Δ |
|---|------|--------|----------|
| 1 | `.claude/skills/alex/SKILL.md` | Edit | +120 (A1 step3_8, A2 awareness upgrade, A3 research check, A5 citation, C1 learn quiz) |
| 2 | `.claude/skills/research-notebook/SKILL.md` | Edit | +150 (B1-B6 CLI enhancements + C2 quiz/flashcards) |
| 3 | `.tad/cross-model/capabilities.yaml` | Edit | +20 (add fulltext, quiz, flashcards, language to capability list) |

**Grounded Against** (Alex step1c):
- .claude/skills/alex/SKILL.md (read STEP 3.7, discuss_path_protocol, learn_path_protocol, handoff step0_5)
- .claude/skills/research-notebook/SKILL.md (607 lines, Phase 1 output, full read)
- .tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/FULL-CLI-RESEARCH.md (all CLI capabilities verified)

---

## 4. Acceptance Criteria

### Track B (CLI expansion — implement FIRST)
- [ ] AC1: Preflight uses `auth check --test` instead of file-exists check
- [ ] AC2: `ask` command supports `--source <id>` flag for targeted queries
- [ ] AC3: `ask` command supports `--save-as-note --note-title` flags (SKILL supports flag; Alex decides when to use)
- [ ] AC4: `ask` command supports `--no-save` flag to suppress auto-save in privacy-sensitive contexts
- [ ] AC5: `report` supports `--append` + `--retry 3` + `--source <id>` flags
- [ ] AC6: New `fulltext` command exists with preview + save option
- [ ] AC7: New `language` command exists (set/get/list subcommands)
- [ ] AC8: New `consolidate` command exists — merge execution layer (A4 delegates to this)

### Track C (*learn integration — implement SECOND)
- [ ] AC9: New `quiz` + `flashcards` commands in research-notebook SKILL, download as markdown
- [ ] AC10: `learn_path_protocol` has `step3_5_quiz_generation` after 3+ Socratic rounds (Alex SKILL)

### Track A (Alex Research Director — implement LAST, depends on B+C)
- [ ] AC11: Alex SKILL has `step3_8_research_landscape` with `interacts_with` clause
- [ ] AC12: `discuss_path_protocol.research_notebook_awareness` upgraded — proactively queries matching notebooks (uses B6 fulltext)
- [ ] AC13: `handoff_creation_protocol` has `step0_5b` (peer step, not sub-step) for research asset check
- [ ] AC14: `notebook_consolidation_suggestion` delegates to `*research-notebook consolidate` (B8), does NOT re-implement merge
- [ ] AC15: `research_citation_in_handoff` exists — §📚 auto-cites notebook findings
- [ ] AC16: `*research-review` registered in Alex SKILL `commands:` section + has standby return (`enters_standby` entry)
- [ ] AC17: *research-review 4-step protocol classifies notebooks into 4 categories with project-goal alignment
- [ ] AC18: *status panoramic `step1` scans REGISTRY.yaml; `step2` appends Research Portfolio table after Ideas section
- [ ] AC19: Passive detection in *discuss detects dormant notebooks matching current topic

### Cross-cutting
- [ ] AC20: All new CLI invocations use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
- [ ] AC21: capabilities.yaml updated with fulltext, quiz, flashcards, language entries

---

## 5. Important Notes

### 5.1 Alex SKILL 编辑原则
Alex SKILL.md 是 ~2800 行的协议文件。插入新 section 时：
- A1 (step3_8) 插入位置：STEP 3.7 session state 之后、STEP 4 greeting 之前
- A2 替换位置：现有 `research_notebook_awareness` 段（约 15 行 → 约 40 行）
- A3 追加位置：`step0_5` 段的 step 12 之后
- C1 插入位置：`learn_path_protocol.execution` 的 step3 和 step4 之间
- 不要修改任何现有的 forbidden_implementations 或 anti_rationalization_registry 段

### 5.2 Consolidation 是建议不是自动
A4/B6 的 notebook 整合必须通过 AskUserQuestion 确认。不要自动整合。如果用户选择"保留独立"，尊重决定不再追问。

### 5.3 --save-as-note 的 privacy 考虑
B2 的自动 --save-as-note 会把每个 research question 存到 NotebookLM 的 note 中。这些 note 存在 Google 服务器上。如果用户在讨论敏感话题，应该能 opt out。在 ask 命令中加一个 `--no-save` flag 来禁用自动保存。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| 教训 | 来源 | 为什么相关 |
|------|------|-----------|
| Knowledge Feedback Loop — source add GO | architecture.md (2026-05-04) | A3/A5 可以引用 ingest 产出的知识 |
| NotebookLM CLI Capability Matrix | architecture.md (2026-05-04) | B1-B6 所有 CLI 参数的行为参考 |
| FULL-CLI-RESEARCH.md | .tad/evidence/spikes/ | Phase 2 完整设计输入，所有 flag 详情 |
| Venv Absolute Path | architecture.md (2026-05-03) | AC15 — 绝对路径 |
| Intent Router Protocol | Alex SKILL.md | A1 的插入必须不破坏现有 Router |

---

## 9. Spec Compliance

### 9.1 Verification
All ACs are post-impl (SKILL.md protocol text). Verification is INTENT-based (section/content presence).

### 9.2 Expert Review (Audit Trail)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | CR-P0-1: AC numbering gap (17-20 before 15-16) | §4 renumbered sequentially 1-21 | Resolved |
| code-reviewer | CR-P0-2: step3_8 missing interacts_with | §2 A1 added interacts_with clause | Resolved |
| code-reviewer | CR-P0-3: A2 replacement boundary unclear | §2 A2 added explicit boundary note | Resolved |
| code-reviewer | CR-P0-4: step0_5 structural ambiguity | §2 A3 renamed to step0_5b (peer step) | Resolved |
| code-reviewer | CR-P0-5: Missing Section 6 implementation order | §6 added B→C→A dependency chain | Resolved |
| backend-architect | BA-P0-1: *research-review not in commands list | §4 AC16 requires commands registration + standby | Resolved |
| backend-architect | BA-P0-2: A4/B6 consolidation duplication | §2 A4 step4 delegates to B6, no re-implement | Resolved |
| backend-architect | BA-P0-3: notebooklm rename doesn't exist | §2 A6 step4_pivot → create+migrate+archive替代 | Resolved |
| backend-architect | BA-P0-4: Cross-track dependency ordering | §6 explicit B→C→A order | Resolved |
| code-reviewer | CR-P1-2: --save-as-note is Alex-side not SKILL auto | §6 B2 clarification + AC3/AC4 分离 | Resolved |
| code-reviewer | CR-P1-3: --no-save opt-out missing AC | §4 AC4 added | Resolved |
| backend-architect | BA-P1-3: *status insertion point unspecified | §4 AC18 specifies step1 scan + step2 after Ideas | Resolved |
| backend-architect | BA-P1-4: AC8 privacy amendment | §4 AC3+AC4 split for save/no-save | Resolved |

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | 触发时机 | discuss-only / 3点 / 全部 | 3个触发点 | 用户确认：discuss + analyze后 + handoff前 |
| 2 | Notebook 整合 | Phase 2 / defer | Phase 2 | 研究总监核心能力 |
| 3 | Quiz/flashcards | Phase 2 / defer | Phase 2 | 用户确认：研究总监能产出学习材料 |
| 4 | --save-as-note 默认行为 | always / opt-in / opt-out | opt-out (默认开, --no-save 关) | 审计 > 隐私默认，但留逃生口 |
