---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "v3 L6 commit timing — implemented but uncommitted at first Gate 4 audit"
    alex_said: "v3 L6 specs added post Blake start; expected NOT in c3ce273 commit"
    actual: "Blake DID implement v3 L6 in working tree (Alex SKILL line 2167 NARROW-SCOPE template + Blake SKILL line 906 expert_prompt_template subsection) along with `-v3.md` review files. Just NOT included in commit c3ce273 (which captured v2 only). Verified at Gate 4 second raw-recompute on full working tree: AC17=1 ✅ / AC18=1 ✅ / AC19=1/1 ✅. AR-001 anchor=2 preserved; constraints alex=64 (=baseline) blake=34 (≥32 baseline due to L6 forbidden_implementations addition). Alex Gate 4 acceptance commit includes Blake's uncommitted v3 L6 work."
    caught_by: "Alex Gate 4 first recompute (on c3ce273 only) initially saw AC17/18=0; second pass on working tree found Blake had implemented v3 L6 + made `-v3.md` review files but hadn't committed yet"
  - field: "AC16 enumeration symmetry — 5th consecutive INTENT-PASS-LITERAL-FAIL"
    alex_said: "diff with awk extraction should output empty for byte-symmetric Tier 2 enumeration"
    actual: "Blake comment-form vs Alex bullet-form make literal diff non-empty even with set-equality. Set {yaml, research, doc-only} ≡ {yaml, research, doc-only} verified by intent. 5 consecutive phases (Phase 3 / Phase 4 / Phase 5 / pre-publish / this) exhibit literal-AC-spec drift. Phase-7+ Epic to operationalize Alex AC dry-run via PreToolUse hook is increasingly justified."
    caught_by: "Blake Layer 2 self-verification + Alex Gate 4 raw-recompute confirmed set-equality intent"
  - field: "Indent spec drift v2 P0-B"
    alex_said: "Blake SKILL append at 11-space indent matching surrounding rule literal block"
    actual: "Actual existing rule literal lines 920-922 measured at 10 spaces. Blake matched file (10sp) not spec (11sp). YAML parses cleanly per code-reviewer P0 verification. Indicates Alex grounding pass step1c didn't measure exact indent depth."
    caught_by: "Blake during impl + code-reviewer post-impl review"
---

# Handoff: TAD Token Efficiency — L1 Tiered Layer 2 + L2 Lazy Knowledge + L4 *express ≤5

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-27 (v3 — added L6 narrow-scope expert prompts after user discussion of architecture-handoff cost-benefit analysis)
**Project:** TAD Framework
**Task ID:** TASK-20260427-003
**Handoff Version:** 3.1.0
**Epic:** N/A (urgent v2.8.4 release scope expansion — token efficiency lever group)
**Supersedes:** N/A

⚠️ **v2 changes vs v1 (2026-04-27 expert review integration)**:
- **P0-A** (CR P0-1): L4 widening missed `>3 files` reference at Alex SKILL line 996 (`when_NOT_appropriate` "Anything affecting >3 files"). Silently nullifies L4. **§4.2 File 3 expanded with Edit Step 3 for line 996 + AC15 added for verification**.
- **P0-B** (CR P0-2): L1 Blake SKILL append-block indent must match surrounding `rule: |` literal at **11 spaces**, not 8. **§4.2 File 1 updated with explicit indent specification**.
- **P0-C** (BA P0-1): AR-001 mechanical anchor verification was fragile — `grep -A 30 'express_path_protocol:'` matches TWO lines (header at 932 + self-referential comment at 963). Real anchor at line 967 is 35 lines below true header. **AC10 + NFR3 + Phase 1 baseline updated to use `awk '/^express_path_protocol:/{flag=1;n=0} flag && n<30 {print; n++}'` (single-occurrence + 30-line window) anchored at top-level `^express_path_protocol:` only**.
- **P0-D** (BA P0-2): Dogfood quota-deadlock fallback not documented (Phase 6-A 8 days ago hit this). **§10.1 added honest_partial_protocol fallback note**.
- **P0-E** (BA P0-3): Tier 2 enumeration (`yaml/research/doc-only`) duplicated in Blake SKILL + Alex SKILL step 3.5 without symmetry check. **New AC16 verifies enumeration symmetry**.
- P1 fixes integrated: AC13 explicit-include filter, anti-regression `=2` for 2-occurrence phrases, awk path active-first, L2 step 5+ prose reword acknowledging partial corpus, AC11 baseline structured slot.

⚠️ **v3 changes vs v2 (2026-04-27 user *discuss on architecture-handoff cost-benefit)**:
- **L6 added**: User confirmed "经常做大架构任务" → L1+L2+L4 alone gives only 10-15% savings for architecture work (sub-agent reviews are 38% of cost block, untouched by L1/L2/L4). L6 narrow-scope expert prompts cuts each sub-agent review ~50% (115K → 50-60K) without reducing P0 finding rate (P0s mostly live in §6 + §9 + diff range).
- Files unchanged: still 2 unique (Alex SKILL × 5 edits + Blake SKILL × 2 edits). Edit locations expanded: Alex SKILL line 2167 (`expert_prompt_template`); Blake SKILL line 906 (`layer2_expert_review` adds new `expert_prompt_template` sub-section).
- Estimated post-L6 savings for architecture-heavy weeks: **~30-35% per handoff** (vs ~10-15% with L1+L2+L4 only).
- **Re-review discipline note**: v3 L6 additions are pure prose template additions (low risk, no contract change). Parallel expert review NOT re-run (run once for v2 was thorough). Acceptable per architecture.md "Express Handoff is NOT Review-Exemption" lesson — L6 is text-only template change, not architectural pivot. Added §9.2 Audit Trail row documenting this discipline call.

⚠️ **Strategic Context**: User 2026-04-27 *discuss feedback "Opus 4.7 token 消耗非常大，TAD 完整流程不敢用". This handoff installs 3 token-saving levers (L1+L2+L4) before v2.8.4 *publish, so the release ships with both cleanup AND efficiency improvements bundled.

⚠️ **Self-referential dogfood note**: This handoff itself is `task_type: yaml` (pure SKILL prose changes). Per current ≥2 distinct rule we're modifying, it gets 2 reviewers. After L1 lands, future yaml/research/doc-only handoffs would only need 1 reviewer — but THIS handoff still respects the rule it's about to relax (no rule-breaking under its own installation).

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-04-27

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 处编辑 location 全部 grep 验证（line 918 / 949 / 1655 / 2295）|
| Components Specified | ✅ | 每处 edit 给 before/after diff |
| Functions Verified | ✅ | layer2-audit.sh `*express` slug_detection 已存在保留；KNOWN_REVIEWERS list 不动 |
| Data Flow Mapped | ✅ | tier 决策流：handoff frontmatter task_type → Alex step4c 读 → 应用 tier rule → PASS/FAIL/N/A |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Standard *express path（≤3 files within limit — 2 unique files, no override needed）。Socratic 等价已在 *discuss session 完成（用户战略反思 + 5 lever 选择 + Option A 时机决策）。

---

## 1. Task Overview

### 1.1 What We're Building（业务价值优先）

完成后你的体验改善：

- **TAD Standard handoff token 消耗下降 ~30-40%** — 大多数日常任务不再被 Opus 4.7 token 经济学劝退
- **\*express 路径覆盖更多场景** — `≤3 files` 提到 `≤5 files`，意味着更多 cleanup / config / docs 类工作走 *express 而非 Standard，跳 Socratic + 仅需 1 reviewer，单次约省 250K-280K tokens
- **knowledge reload 不再傻读全部文件** — Alex 写 handoff 时只读和当前任务相关的 .tad/project-knowledge 文件（基于关键词），单次约省 30K tokens
- **yaml / docs 类小 handoff 只需 1 个 expert review** — code 类仍保持 ≥2 严谨，按 task_type 分级

技术变化（次要）：3 处 SKILL prose edits（Alex SKILL × 3 / Blake SKILL × 1），共 4 个编辑区域 across 2 个文件。

### 1.2 Why We're Building It

**用户痛点**（2026-04-27 *discuss）：Opus 4.7 周限额是 hard ceiling，本 session 已消耗 ~2-3M tokens（30-40% 周限额）做了 3 个 handoff 周期。如果不装 token 节省杠杆，未来 1-2 周用户会逐渐规避用 TAD（"我直接帮你"），TAD quality 防线就形同虚设。

**机会窗口**：v2.8.4 即将发布，pre-publish cleanup 已 Gate 4 PASS，simplification 装上后一起 release，避免 v2.8.4 + v2.8.5 两次 *publish/*sync 的 ceremony cost（这本身就 token-heavy）。

**为什么不分别装 L1/L2/L4**：3 杠杆共享同一 SKILL 修改区域 + 同一 expert review cycle，捆绑做最经济。

### 1.3 Intent Statement

**真正要解决的问题**：TAD 自身的 quality 防线累加成本超过单次任务可承受 token 预算。L1+L2+L4 是**最低风险 / 最快见效**组合（不动 SKILL slim、不动 Codex Epic、不破坏现有 quality 规则的硬性核心）。

**不是要做的**：
- ❌ 不动 v2.7 学到教训的 constraint rules（forbidden / VIOLATION / MANDATORY 字样保留）
- ❌ 不去 SKILL slim round 2（那是 v2.9.0 scope）
- ❌ 不破坏 P6-A.2 hard rule 核心精神（≥2 distinct for code，仍然保留）
- ❌ 不动 *express 的 ≥1 review 底线
- ❌ 不动 layer2-audit.sh 脚本（保持 advisory CLI，不变）

**Blake 请确认理解**：

```
1. L1 tier 规则：什么 task_type 触发 ≥2，什么触发 ≥1？(提示：code/mixed→2, yaml/research/doc-only→1, e2e→2)
2. L2 lazy load 是怎么改 step0_5 的执行顺序？(提示：keyword identification 提到 file reading 之前)
3. L4 file_count_max 3→5 会不会破坏 *express 的轻量本质？(提示：仍 skip Socratic + ≥1 review，只是文件数量上限放宽)
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

涉及类别：
- [x] architecture - SKILL prose 演化 / token 经济学 / Anti-Epic-1 lessons
- [x] code-quality - SKILL.md prose editing 不破坏 YAML 缩进
- [ ] performance / security / ux

### 步骤 2：历史经验摘录

**⚠️ Blake 必须注意的历史教训**（来自 architecture.md 关键词扫描）：

1. **Quality Chain Failure - 2026-04-04** (architecture.md amendment to v2.7 SKILL slim entry)
   - 教训：v2.7 砍 SKILL 76% 时**误删 constraint rules**（forbidden / VIOLATION / MANDATORY 字样）和 mechanical logic 一起，几周后整个 quality chain 系统性失效
   - **本 handoff 关联**：L1/L2/L4 都是 prose 微改，**绝不删任何 forbidden / VIOLATION / MANDATORY / Anti-Epic-1 / hard_requirement** 字样。改的是阈值和顺序，不是约束本身。

2. **Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15** (architecture.md)
   - 教训：单用户 CLI 上机械强制 fail-closed = 恢复成本 > 防滥用收益
   - **本 handoff 关联**：layer2-audit.sh 保持 advisory CLI（不动）；L1 tier 规则在 Alex step4c interpretation 层落地，不是脚本层。装"烟雾报警器"原则不变。

3. **Path Layering: Three Defenses Against Single-Path AR-001 Drift - 2026-04-24** (architecture.md)
   - 教训：*express path 防退化的 3 层防御（mechanical SKILL grep + NOT_via_alex_suggestion + symmetric forbidden_implementations）
   - **本 handoff 关联**：L4 只改 file_count_max（3→5），**不改** required_steps / forbidden / NOT_via_alex_suggestion / signal_words 等 AR-001 防御层。AR-001 SKILL grep anchor `expert review.*code-reviewer` 必须**仍然存在**且仍 ≤30 行内可达。

4. **AC Verification Drift Pattern Recurring 4 Phases in a Row - 2026-04-27** (architecture.md, Blake's recent KA)
   - 教训：handoff §9.1 verification commands 反复 INTENT-PASS-LITERAL-FAIL，需 Phase-7+ Epic 装 PreToolUse hook 装 dry-run 强制
   - **本 handoff 关联**：本 handoff §9 ACs 全为 grep-substring 类（"BUSINESS-VALUE-FIRST" 类似坑可能再出现）。**Blake 在写完 implementation 后 Layer 1 跑每条 AC 验证命令，捕到任何 LITERAL-FAIL 立即 escalate 而不是 INTENT-PASS 蒙混**。

5. **Cleanup Handoff Scope-Estimation Drift Pattern - 2026-04-27** (architecture.md, Alex's recent KA)
   - 教训：Alex 估算 cleanup 类 handoff blast radius 系统性偏低
   - **本 handoff 关联**：本 handoff 是 SKILL prose 改，blast radius 较窄但仍可能漏。Blake Layer 2 backend-architect 必须 fresh grep 全仓库验证 `hard_requirement_distinct_reviewers` / `step0_5` / `express_path_protocol.scope_constraints` / `file_count_max` 引用，确保没有第三处需要协同改的位置。

### Blake 确认

- [ ] 已阅读上述 5 条历史教训
- [ ] 我不会删任何 forbidden / VIOLATION / MANDATORY / Anti-Epic-1 / hard_requirement 字样
- [ ] AR-001 SKILL grep anchor `expert review.*code-reviewer` 在 ≤30 行 within `express_path_protocol:` 起始 header 后仍可达 — 改 file_count_max 不破坏这条
- [ ] Layer 2 reviewer 跑 fresh grep 验证 4 处 edit 完整性

---

## 2. Background Context

### 2.1 Previous Work

- v2.7 SKILL slim 是教训不是榜样（误删 constraint rules）。本 handoff 不重复那条路。
- P6-A.2 hard_requirement_distinct_reviewers 是 2026-04-25 装的硬规则，现在 8 天后做小幅分级是正常 evolution。
- *express path 2026-04-24 装上时 file_count_max=3 是保守初值；3 天用下来发现 cleanup 类工作经常超 3 文件，需要放宽。

### 2.2 Current State

- Standard TAD 单 handoff 估算 ~1M tokens；*express ~250K-300K tokens（70% 节省）。
- step0_5 全量读 5+ knowledge files，多数任务只用得上 1-2 个。
- Blake Layer 2 当前规则: code-reviewer + ≥1 from KNOWN_REVIEWERS 不论 task_type。

### 2.3 Dependencies

- 不依赖外部库
- 不依赖 settings.json 改动
- 不依赖 layer2-audit.sh 改动（保持 advisory）

---

## 3. Requirements

### 3.1 Functional Requirements

#### L1: Tiered Layer 2 expert review

- **FR1**: 修改 `.claude/skills/blake/SKILL.md` `hard_requirement_distinct_reviewers` rule 段（line 918+），把当前 "code-reviewer REQUIRED + ≥1 from KNOWN_REVIEWERS" 改成 task_type 分级：
  - `task_type: code` OR `task_type: mixed` → **≥2 distinct**（current rigor，无变化）
  - `task_type: yaml` OR `task_type: research` OR `task_type: doc-only` → **≥1**（仅 code-reviewer 必选；第二个 reviewer 可选）
  - `task_type: e2e` → **≥2**（test-runner + code-reviewer，已在 Group 2 bullets 中定义）
  - *express path → **≥1**（existing exception，无变化）
  - **不删** existing rule prose（rationale_single_source / forbidden / forbidden_implementations 全保留）

- **FR2**: 修改 `.claude/skills/alex/SKILL.md` `step4c` Layer 2 audit interpretation（line 2295+），加 task_type 读取 + tier-aware 判断：
  - 在 step 4 (Interpret) 之前加新 step 3.5: "Read handoff frontmatter `task_type` field. Apply tier rule per Blake SKILL `hard_requirement_distinct_reviewers` (Tier 1 ≥2 / Tier 2 ≥1 / Tier e2e ≥2)."
  - 修改 step 4 interpretation: exit 0 + DISTINCT_COUNT 满足 tier 阈值 → PASS；exit 1 OR DISTINCT_COUNT 不足 tier 阈值 → FAIL；exit 2 → N/A（保留）

#### L2: Knowledge lazy load

- **FR3**: 修改 `.claude/skills/alex/SKILL.md` `step0_5` "Context Refresh — Full Knowledge Reload" 段（line 1655+），把执行顺序从"先读全部 → 再 keyword 匹配"改为"先 keyword 识别 → 再有选择读"：
  - 当前 sequence: step1 Read ALL files → step2 Read protocol/template → step3-9 keyword scan + matching
  - 新 sequence: step1 (NEW) Identify task keywords from current Socratic results / *discuss context → step2 Read README.md (always, ~5KB cheap) → step3 (NEW) Match keywords against README's category index → step4 Read ONLY matching category files → step5 Read protocol/template → step6+ existing keyword matching + stale-knowledge-check.sh
  - **保留**：所有 forbidden / Anti-Epic-1 / blocking 字样不变；relevant_knowledge MUST be inclusive 不变；step9 stale-check call 不变
  - **节省机制**：未匹配的 category .md 文件不读 → 单次 ~30K tokens 节省

#### L4: *express default-ization

- **FR4**: 修改 `.claude/skills/alex/SKILL.md` `express_path_protocol.scope_constraints.file_count_max`（line 949），从 `3` 改为 `5`。
- **FR5**: 同步更新 `over_limit_action` 措辞（line 950+），把 "≤3 文件硬上限" 改为 "≤5 文件硬上限"，options 中的 "(Recommended for >3 files)" 改为 "(Recommended for >5 files)"。
- **不动**：required_steps / forbidden_implementations / NOT_via_alex_suggestion / when_appropriate / when_NOT_appropriate 全保留。
- **AR-001 grep anchor 验证**：v2 P0-C 修订后用 `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'` = 2（unchanged 因为只改 scope_constraints 几行）

#### L6: Narrow-scope sub-agent prompts (v3 added 2026-04-27)

- **FR6**: 修改 `.claude/skills/alex/SKILL.md` `expert_prompt_template`（line 2167），从当前简单 "FILE: {handoff_path} + FOCUS AREAS" 模板改为 narrow-scope 模板：
  - REQUIRED READS: §6 (Implementation Steps) / §9 (Acceptance Criteria) / §10 (Important Notes) / specific files in §7 (Files to Modify) only — **NOT** full handoff
  - OPTIONAL READS: §3 (Requirements) / §4 (Technical Design) / §11 (Decision Summary) only if §6 ambiguous
  - FORBIDDEN: free-grep wider codebase（除 explicit blast-radius checks 列表）
  - 节省机制：每次 sub-agent review 从 ~115K → ~50-60K（~50% 减）
  - **保留**：minimum_experts: 2 + violations 子段不动

- **FR7**: 修改 `.claude/skills/blake/SKILL.md` `layer2_expert_review`（line 906+ block），在现有 bullets / hard_requirement_distinct_reviewers 之后新增 `expert_prompt_template` 子段，规则与 FR6 字字对称（覆盖 Blake post-impl review 的 sub-agent 调用 — Layer 2 sub-agents 必须读 diff + §6 + §9 of handoff，不读 full handoff）
  - **保留**：existing Group 0/1/2 bullets / hard_requirement_distinct_reviewers / forbidden / forbidden_implementations 全部不动

### 3.2 Non-Functional Requirements

- **NFR1 (Backward compat)**: 已归档 handoff 中可能有 `task_type` 缺失或非标值（如 `mixed`/`code`/`yaml`/`research`/`e2e`/`doc-only` 之外）。tier 规则必须有 fallback：未识别 task_type → default Tier 1 (≥2 distinct)。
- **NFR2 (Constraint preservation)**: 所有 forbidden / VIOLATION / MANDATORY / Anti-Epic-1 / hard_requirement_distinct_reviewers / forbidden_implementations 字样**逐字保留**。Blake 在 Phase 4 跑 anti-regression grep。
- **NFR3 (AR-001 mechanical anchor)**: `expert review.*code-reviewer` 仍在 `express_path_protocol:` 起始后 ≤30 行内出现 ≥1 次。
- **NFR4 (No silent kill)**: 如果 task_type 为空或非标，不能 silent skip Layer 2 audit — 必须 fallback Tier 1 严谨态度。

---

## 4. Technical Design

### 4.1 Architecture Overview

3 个独立杠杆 共享 2 个文件 共 4 处编辑区域。串行执行（顺序无依赖）。

### 4.2 Per-File Change Specification

#### File 1: `.claude/skills/blake/SKILL.md` — L1 tier rule

**位置**: `hard_requirement_distinct_reviewers.rule` 段（line 918-927）

**修改方式**：在 `rule:` 字段的现有 prose 末尾**追加** tier mapping 段，**不替换** existing rule prose。

**新追加内容**（在 `rule: |` 现有 multiline 内容末尾，"Choose by task fit (e.g., backend-architect for ..." 之后）：

⚠️ **P0-B fix (CR review)**: existing `rule: |` content lines 920+ are at **11-space indent** (literal block scalar). Append must match same 11-space indent or YAML parser will read appended lines as siblings of `rule:` not as content. Use **exactly 11 leading spaces** for each appended line:

```yaml
           # P6-A.2 v2 (2026-04-27): tier rule by handoff frontmatter task_type
           # Tier 1 (≥2 distinct): task_type=code OR task_type=mixed (current rigor)
           # Tier 2 (≥1 distinct, code-reviewer): task_type=yaml OR task_type=research OR task_type=doc-only
           # Tier e2e (≥2 distinct, test-runner+code-reviewer or equiv): task_type=e2e
           # Fallback: task_type missing/unrecognized → Tier 1 (safe default per NFR1+NFR4)
           # *express exception: existing exception_express below still applies (≥1 regardless of task_type)
```

**Blake verification**: After Edit, run `grep -n "Tier 1" .claude/skills/blake/SKILL.md` and check the matched line — leading whitespace must be exactly 11 spaces (3 spaces of YAML map nesting + 8 spaces of literal content from `rule: |`).

**注意**：
- existing rule prose lines 919-927 完全保留 unchanged
- existing exception_express + forbidden + enforcement + forbidden_implementations 全保留 unchanged
- existing rationale_single_source 段保留 unchanged

#### File 2: `.claude/skills/alex/SKILL.md` — L2 step0_5 lazy load

**位置**: `step0_5` "Context Refresh" 段（line 1655-1700）

**修改方式**：替换 `action:` 字段的 step 1-3 子步骤（reorder + 引入 README-driven category selection）。其余 steps (4-9) 保留。

**Before**（line 1660-1670 区域）:
```yaml
      action: |
        Before writing handoff draft, reload ALL project knowledge to ensure
        no historical lessons are missed in the handoff.

        1. Read ALL files in .tad/project-knowledge/*.md (excluding README.md)
        2. Read handoff_creation_protocol key rules from THIS file:
           - expert_selection_rules (which experts to call)
           - minimum_experts: 2
           - step7 STOP rule (must generate Blake message, must not call /blake)
        3. Read the handoff template: .tad/templates/handoff-a-to-b.md
           (to ensure template structure is fresh in context)
        4. Brief output: "📖 Full knowledge refreshed: {N} knowledge files + handoff protocol + template"
```

**After**（替换为 lazy-load sequence）:
```yaml
      action: |
        Before writing handoff draft, reload **relevant** project knowledge.
        L2 lazy-load (2026-04-27): only read files matching task keywords, not all.

        1. **Identify task keywords** from current Socratic Inquiry results / *discuss
           context (topics, technologies, file paths, domain). Output: keyword list.
        2. **Read .tad/project-knowledge/README.md** (always, ~5KB cheap) — contains
           category index + Domain Pack vs Project-Knowledge Decision Rule.
        3. **Match keywords against category list** in README. Identify relevant
           category files (typically 1-3 of: architecture, code-quality, security,
           ux, performance, testing, api-integration, mobile-platform,
           frontend-design). Default include: architecture.md (most entries land
           there).
        4. **Read ONLY matching category files**. Files NOT matched are skipped
           (token savings — typically 30-50K tokens vs full reload).
        5. Read handoff_creation_protocol key rules from THIS file:
           - expert_selection_rules (which experts to call)
           - minimum_experts: 2 (or 1 per L1 tier rule — see Blake SKILL hard_requirement_distinct_reviewers)
           - step7 STOP rule (must generate Blake message, must not call /blake)
        6. Read the handoff template: .tad/templates/handoff-a-to-b.md
           (to ensure template structure is fresh in context)
        7. Brief output: "📖 Knowledge refreshed: README + {N} matched files (skipped {M}) + handoff protocol + template"
```

**保留 unchanged**: existing steps 5-9（renumbered to steps 8-12 in new sequence — Blake handles renumbering carefully）的 keyword matching scan + stale-knowledge-check.sh + relevant_knowledge MUST be inclusive 等所有 prose 不变。

#### File 3: `.claude/skills/alex/SKILL.md` — L4 file_count_max 3→5

**位置**: `express_path_protocol.scope_constraints`（line 948-959）

**Before**:
```yaml
  scope_constraints:
    file_count_max: 3   # files in §6 Files to Modify / Create
    over_limit_action: |
      Use AskUserQuestion: "你的 *express 涉及 {N} 文件，超出 *express ≤3 文件硬上限。
      要降到 Standard TAD 还是拆成多个 *express?"
      Options:
        - "降到 Standard TAD (Recommended for >3 files)"
        - "拆成多个 *express handoffs (each ≤3 files)"
        - "我理解但坚持 *express 单 handoff (override — 解释原因)"
      override 选项需用户写明原因，**强制**记入 §11 Decision Summary 一行
      (Gate 2 检查若 §11 未含 override row → FAIL)
```

**After**:
```yaml
  scope_constraints:
    file_count_max: 5   # files in §6 Files to Modify / Create (L4: 2026-04-27 widened from 3 per Opus 4.7 token-economics relief)
    over_limit_action: |
      Use AskUserQuestion: "你的 *express 涉及 {N} 文件，超出 *express ≤5 文件硬上限。
      要降到 Standard TAD 还是拆成多个 *express?"
      Options:
        - "降到 Standard TAD (Recommended for >5 files)"
        - "拆成多个 *express handoffs (each ≤5 files)"
        - "我理解但坚持 *express 单 handoff (override — 解释原因)"
      override 选项需用户写明原因，**强制**记入 §11 Decision Summary 一行
      (Gate 2 检查若 §11 未含 override row → FAIL)
```

**注意**：仅 2 处数字替换 + 1 处注释新增。required_steps / forbidden_implementations / NOT_via_alex_suggestion 等所有其他子段**不动**。

⚠️ **P0-A fix (CR review)**: 必须额外编辑 line 996 区域 — `express_path_protocol.when_NOT_appropriate` 列表中有一条 `"Anything affecting >3 files (use over_limit_action AskUserQuestion)"`，与新 `file_count_max: 5` 直接矛盾，会 silently nullify L4 widening。

**第 3 处编辑**（line ~996 区域）:

**Before**:
```yaml
  when_NOT_appropriate:
    - "Architecture or contract change (interface, protocol, shared schema)"
    - "Multi-module refactor"
    - "Anything affecting >3 files (use over_limit_action AskUserQuestion)"
    - "Security-adjacent changes (auth/token/encrypt → Standard TAD with security review)"
    - "Performance-adjacent changes (optimization → use *experiment instead)"
```

**After**:
```yaml
  when_NOT_appropriate:
    - "Architecture or contract change (interface, protocol, shared schema)"
    - "Multi-module refactor"
    - "Anything affecting >5 files (use over_limit_action AskUserQuestion) — L4 (2026-04-27): widened from 3"
    - "Security-adjacent changes (auth/token/encrypt → Standard TAD with security review)"
    - "Performance-adjacent changes (optimization → use *experiment instead)"
```

**File 3 总编辑数**：3 处（file_count_max value + over_limit_action 3 处文字 + when_NOT_appropriate 1 行）。

#### File 4 (same file as File 2/3): `.claude/skills/alex/SKILL.md` — L1 step4c task_type read

**位置**: `step4c` Layer 2 Audit step（line 2295-2335）

**修改方式**：在现有 step 4 "Interpret" 之前**插入新 step 3.5**（task_type read），并修改 step 4 interpretation 加 tier-aware 判断。

**插入新 step 3.5** (在 step 3 "If slug valid: run bash layer2-audit.sh..." 之后、step 4 "Interpret" 之前):

```yaml
      3.5. **Read task_type** from handoff frontmatter (L1 tier rule, 2026-04-27):
           Run: `awk '/^---$/{c++; if(c>=2)exit; next} c==1 && /^task_type:/{print $2}' .tad/archive/handoffs/HANDOFF-{date}-{slug}.md`
           (or current active path if not yet archived)
           - If output is `code` OR `mixed` → tier_threshold=2 (Tier 1)
           - If output is `yaml` OR `research` OR `doc-only` → tier_threshold=1 (Tier 2)
           - If output is `e2e` → tier_threshold=2 (Tier e2e — test-runner + code-reviewer)
           - If output is empty / unrecognized → tier_threshold=2 (NFR1+NFR4 safe default)
           - If filename matches *express slug pattern (already detected by layer2-audit.sh) → tier_threshold=1 (existing exception)
```

**修改 step 4 (Interpret)**: 在 exit 0 case 后加 tier check:

**Before**:
```yaml
      4. Interpret:
         - exit 0  → acceptance report: "✅ Layer 2 artifacts verified: ..."
         - exit 1  → acceptance report inserts at a VISIBLE position ...
         - exit 2  → treat as "Layer 2 audit N/A" ...
```

**After**:
```yaml
      4. Interpret:
         - exit 0 AND DISTINCT_COUNT ≥ tier_threshold → acceptance report: "✅ Layer 2 artifacts verified: .tad/evidence/reviews/blake/<slug>/ (N reviewer artifacts, DISTINCT_COUNT={n}/{tier_threshold}, tier={tier_name})"
         - exit 0 AND DISTINCT_COUNT < tier_threshold → acceptance report inserts VISIBLE warning:
             ```
             ⚠️ LAYER 2 TIER UNDER-MET
             DISTINCT_COUNT={n} < tier threshold {tier_threshold} for task_type={task_type} ({tier_name}).
             Required: ≥{tier_threshold} distinct sub-agents per Blake SKILL hard_requirement_distinct_reviewers tier rule.
             Human accepter: confirm tier assignment correct, or require Blake to add another reviewer.
             ```
         - exit 1  → existing FAIL warning (artifacts missing) — unchanged
         - exit 2  → treat as "Layer 2 audit N/A" — unchanged
```

**保留 unchanged**: step 1, 2, 3, 5（continue regardless of exit code 不变；Anti-Epic-1 reminder 不变）。

#### File 5: `.claude/skills/alex/SKILL.md` — L6 expert_prompt_template narrow scope (v3, 2026-04-27)

**位置**: `expert_prompt_template:` 段（line 2167-2179）

**Before**:
```yaml
  expert_prompt_template: |
    Review this handoff draft for Phase {phase}:

    FILE: {handoff_path}

    FOCUS AREAS:
    {expert_specific_focus}

    OUTPUT FORMAT:
    1. Critical Issues (P0 - must fix before implementation)
    2. Recommendations (P1 - should address)
    3. Suggestions (P2 - nice to have)
    4. Overall Assessment (PASS/CONDITIONAL PASS/FAIL)
```

**After**:
```yaml
  expert_prompt_template: |
    Review this handoff draft for Phase {phase}.

    ⚠️ NARROW-SCOPE INSTRUCTION (L6, 2026-04-27): Read ONLY the focused sections listed below.
    Do NOT read full handoff. Do NOT free-grep wider codebase except for explicit blast-radius
    checks listed in FOCUS AREAS. Saves ~50% per review (~115K→~50-60K) without reducing P0
    finding rate (P0s mostly live in §6/§9/diff range).

    REQUIRED READS:
    - {handoff_path} §6 (Implementation Steps)
    - {handoff_path} §9 (Acceptance Criteria) + §9.1 (Spec Compliance Checklist)
    - {handoff_path} §10 (Important Notes — anti-patterns + warnings)
    - Specific files listed in §7 (Files to Modify): {list_of_files}

    OPTIONAL READS (only if REQUIRED reads alone are ambiguous for the finding you're evaluating):
    - {handoff_path} §3 (Requirements)
    - {handoff_path} §4 (Technical Design)
    - {handoff_path} §11 (Decision Summary)

    FOCUS AREAS:
    {expert_specific_focus}

    EXPLICIT BLAST-RADIUS CHECKS (only run these greps if listed):
    {blast_radius_grep_patterns}

    NOT ALLOWED:
    - Free-explore wider codebase outside REQUIRED + OPTIONAL + listed grep patterns
    - Reading full handoff if §6 + §9 + §10 + listed files is sufficient

    OUTPUT FORMAT:
    1. Critical Issues (P0 - must fix before implementation)
    2. Recommendations (P1 - should address)
    3. Suggestions (P2 - nice to have)
    4. Overall Assessment (PASS/CONDITIONAL PASS/FAIL)
```

**保留 unchanged**: minimum_experts: 2 + violations 子段（lines 2180+）不动。

#### File 6: `.claude/skills/blake/SKILL.md` — L6 Layer 2 expert_prompt_template (v3, 2026-04-27)

**位置**: `layer2_expert_review:` block 内（line 906+），在 hard_requirement_distinct_reviewers 子段**之后**新增 `expert_prompt_template` 子段（不替换任何现有内容）。

**新增子段**（追加在 hard_requirement_distinct_reviewers.forbidden_implementations 数组末尾之后，与 layer2_expert_review map 同级深度）:

```yaml
      # L6 (2026-04-27 v3): narrow-scope mandate for Layer 2 sub-agent invocations.
      # Symmetric with Alex SKILL expert_prompt_template — Blake's Layer 2 reviewers
      # must be invoked with focused context (diff + §6 + §9), not full handoff.
      expert_prompt_template:
        rule: |
          Layer 2 sub-agent invocations MUST follow narrow-scope template:

          REQUIRED READS:
          - Diff of THIS handoff's implementation changes (git diff <range>)
          - {handoff_path} §6 (Implementation Steps) — what Blake intended to do
          - {handoff_path} §9 (Acceptance Criteria) — what Blake claims is done
          - Specific changed files (already in diff)

          OPTIONAL READS (only if needed):
          - Other handoff sections only if REQUIRED reads insufficient

          EXPLICIT BLAST-RADIUS CHECKS (per handoff §10 specific patterns):
          - For backend-architect: targeted grep for downstream consumers of
            changed APIs/symbols if §10 lists relevant patterns
          - For code-reviewer: re-verify each AC's verification command against
            Blake's actual diff

          NOT ALLOWED:
          - Free-explore wider codebase outside REQUIRED + OPTIONAL + §10 patterns
          - Reading full handoff if §6 + §9 + diff is sufficient

        rationale: |
          Same as Alex SKILL expert_prompt_template (L6 narrow-scope) — saves ~50%
          per review (115K → 50-60K) without reducing P0 finding rate. Blake's
          post-impl reviews catch DIFFERENT P0 classes than Alex Gate 2 (blast
          radius / out-of-scope consumers per Phase 6-A 2026-04-27 lesson) — both
          still load-bearing, just narrower in context per invocation.

        enforcement: "prompt-level-only via Blake SKILL text"

        forbidden_implementations:
          - "MUST NOT register hook to enforce narrow-scope via tool blocking"
          - "MUST NOT add to .claude/settings.json"
          - "Anti-AR-001: 'narrow scope = skip review' is forbidden interpretation — narrow scope ≠ shallow review"
```

**保留 unchanged**: existing layer2_expert_review.bullets (Group 0/1/2) + hard_requirement_distinct_reviewers 全段（rule + rationale_single_source + exception_express + forbidden + enforcement + forbidden_implementations）全部不动。

### 4.3 Data Flow

```
Handoff frontmatter task_type
  → Alex step4c reads via awk
    → Map to tier_threshold (1 or 2)
      → layer2-audit.sh produces DISTINCT_COUNT
        → Compare DISTINCT_COUNT vs tier_threshold
          → PASS / WARN / N/A (smoke alarm only — never block)
```

L2 lazy load:
```
Task keywords (from Socratic / *discuss)
  → README.md category index
    → Filter category files matching keywords
      → Read only matching files (skip rest)
        → Existing keyword scan + stale-check (steps 8-12 unchanged)
```

L4: pure scope_constraints.file_count_max value change (3→5). No data flow change.

### 4.4 Component Specifications

无新组件。3 处 prose edits + 1 处 step insertion 共 4 处编辑区域。

### 4.5 API/UI Specifications

不涉及。

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"？

**回答**：✅ 是

**证据**：用户 2026-04-27 *discuss "我们本身是因为太过度工程化导致的"——直指 v2.7 SKILL slim → v2.8 反弹模式。本 handoff 是 v2.7 教训的 bounded 应用（不重蹈"误删 constraint rules"覆辙）。

### MQ2: 函数存在性验证

| 引用 | 文件位置 | 行号 | 验证状态 |
|------|---------|------|---------|
| `hard_requirement_distinct_reviewers` rule | .claude/skills/blake/SKILL.md | 918-927 | ✅ 存在 |
| `step0_5` action 段 | .claude/skills/alex/SKILL.md | 1655-1700 | ✅ 存在 |
| `express_path_protocol.scope_constraints.file_count_max` | .claude/skills/alex/SKILL.md | 949 | ✅ 存在（值 = 3）|
| `step4c` Layer 2 Audit | .claude/skills/alex/SKILL.md | 2295-2335 | ✅ 存在 |
| `KNOWN_REVIEWERS_LIST` array (NOT to modify) | .tad/hooks/lib/layer2-audit.sh | 32 | ✅ 存在 |
| AR-001 grep anchor target | .claude/skills/alex/SKILL.md ~line 970+ | required `expert review.*code-reviewer` ≤30 lines after `express_path_protocol:` | ✅ 存在 |

### MQ3-5

N/A — 不涉及前后端数据流 / UI / 状态同步。

---

## 6. Implementation Steps

### Phase 1: Pre-edit baseline + AR-001 anchor verification（预计 5 分钟）

#### 实施步骤
1. Record baseline metrics:
   ```bash
   wc -l .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md
   grep -c "MANDATORY\|VIOLATION\|forbidden" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md
   awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'
   ```
2. 粘贴输出到 completion §AC verification table
3. AR-001 grep anchor count must be ≥1 (currently 1)

### Phase 2: L1 Blake SKILL tier rule append（预计 10 分钟）

#### 交付物
- [ ] hard_requirement_distinct_reviewers.rule 末尾追加 tier mapping comment block

#### 实施步骤
1. Read .claude/skills/blake/SKILL.md lines 906-960
2. 用 Edit 在 `rule:` multiline 内容末尾（"Choose by task fit (e.g., backend-architect for architecture handoffs; ...);" 之后）追加 §4.2 File 1 specified tier mapping comment block
3. 验证：
   - `grep -c "Tier 1" .claude/skills/blake/SKILL.md` ≥ 1
   - `grep -c "Tier 2" .claude/skills/blake/SKILL.md` ≥ 1
   - existing forbidden / forbidden_implementations / rationale_single_source / exception_express 段 unchanged (`grep -c "self-review.md does NOT count" .claude/skills/blake/SKILL.md` 仍 = 1)

### Phase 3: L2 Alex SKILL step0_5 lazy reorder（预计 15 分钟）

#### 交付物
- [ ] step0_5 action 段 step 1-4 替换为 lazy-load sequence
- [ ] step 5-9 (renumbered to 5-12 if needed) 保留 unchanged

#### 实施步骤
1. Read .claude/skills/alex/SKILL.md lines 1650-1720
2. 用 Edit 替换 §4.2 File 2 标识的 before block (steps 1-4) 为 after block (steps 1-7 lazy-load)
3. 验证：
   - `grep -c "L2 lazy-load" .claude/skills/alex/SKILL.md` ≥ 1
   - `grep -c "Read ALL files in .tad/project-knowledge" .claude/skills/alex/SKILL.md` = 0（旧 prose 移除）
   - existing relevant_knowledge MUST inclusive 段 unchanged
   - existing stale-knowledge-check.sh call 保留

### Phase 4: L4 Alex SKILL file_count_max 3→5（预计 5 分钟）

#### 交付物
- [ ] file_count_max: 5
- [ ] over_limit_action 中 3 处 "≤3" / ">3" 全部改 "≤5" / ">5"
- [ ] 加新注释解释 L4 widen rationale

#### 实施步骤
1. 用 Edit 替换 line 949 区域 §4.2 File 3 specified before/after
2. 验证：
   - `grep -c "file_count_max: 5" .claude/skills/alex/SKILL.md` = 1
   - `grep -c "file_count_max: 3" .claude/skills/alex/SKILL.md` = 0
   - `grep -c "≤3 文件" .claude/skills/alex/SKILL.md` 检查残留（任何 *express 相关的 ≤3 文件提法都要清理；其他用法可保留）
   - **AR-001 anchor check**: `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'` ≥ 1

### Phase 5: L1 Alex SKILL step4c task_type read（预计 15 分钟）

#### 交付物
- [ ] step4c.action 加 step 3.5 task_type read
- [ ] step4c.action 修改 step 4 (Interpret) 加 tier-aware 判断

#### 实施步骤
1. Read .claude/skills/alex/SKILL.md lines 2295-2335
2. 用 Edit 在 step 3 (run layer2-audit.sh) 之后、step 4 (Interpret) 之前**插入** §4.2 File 4 specified step 3.5 (task_type read)
3. 用 Edit 替换 step 4 interpret block，加 tier check 分支
4. 验证：
   - `grep -c "tier_threshold" .claude/skills/alex/SKILL.md` ≥ 2
   - `grep -c "LAYER 2 TIER UNDER-MET" .claude/skills/alex/SKILL.md` = 1
   - existing exit 1 / exit 2 cases 保留

### Phase 5b: L6 narrow-scope expert prompts (Alex + Blake SKILL, v3 added 2026-04-27)（预计 15 分钟）

#### 交付物
- [ ] Alex SKILL `expert_prompt_template`（line 2167）从简单 FILE+FOCUS 模板替换为 narrow-scope 模板（per §4.2 File 5）
- [ ] Blake SKILL `layer2_expert_review` block（line 906+）追加新 `expert_prompt_template` 子段（per §4.2 File 6）

#### 实施步骤
1. Read .claude/skills/alex/SKILL.md lines 2160-2185
2. 用 Edit 替换 expert_prompt_template 段为 §4.2 File 5 specified narrow-scope 模板
3. 验证：
   - `grep -c "NARROW-SCOPE INSTRUCTION (L6" .claude/skills/alex/SKILL.md` = 1
   - `grep -c "REQUIRED READS:" .claude/skills/alex/SKILL.md` ≥ 1
   - `grep -c "minimum_experts: 2" .claude/skills/alex/SKILL.md` = 1（保留）
4. Read .claude/skills/blake/SKILL.md lines 906-960（确认 layer2_expert_review block 范围 + hard_requirement_distinct_reviewers 边界）
5. 用 Edit 在 hard_requirement_distinct_reviewers.forbidden_implementations 数组末尾**之后**追加 §4.2 File 6 specified `expert_prompt_template` 子段
6. 验证：
   - `grep -c "L6 (2026-04-27 v3)" .claude/skills/blake/SKILL.md` = 1
   - `grep -c "narrow-scope mandate" .claude/skills/blake/SKILL.md` ≥ 1
   - existing `Group 0:` / `hard_requirement_distinct_reviewers` 段 unchanged

### Phase 6: 集成回归 + Layer 2 review + commit（预计 30 分钟）

#### 实施步骤
1. **Anti-regression checks**:
   ```bash
   # AR-001 mechanical anchor 仍存在
   awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'  # ≥1
   # constraint rules 字数仍接近 baseline (Phase 1 record)
   grep -c "MANDATORY\|VIOLATION\|forbidden" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md  # ≥ baseline
   # *express required_steps 段不动
   grep -c "step1 draft creation" .claude/skills/alex/SKILL.md  # = 1 (unchanged)
   # AR-001 attack surface defenses unchanged
   grep -c "NOT_via_alex_suggestion" .claude/skills/alex/SKILL.md  # = 1 (unchanged)
   # Blake hard_requirement_distinct_reviewers core rule unchanged
   grep -c "self-review.md does NOT count" .claude/skills/blake/SKILL.md  # = 1
   ```
2. **Run Layer 1 self-check**:
   - YAML/markdown structural integrity (no broken indent in SKILL files)
   - Spot-check sed/awk commands referenced in step4c work on a sample handoff path
3. **Run Layer 2 expert review** (≥2 distinct sub-agents per current P6-A.2 — this handoff installs the relaxation but follows current rule):
   - **必选**: code-reviewer（4 处 prose edits 正确性 + YAML 缩进 + 不破坏 forbidden/MANDATORY 字样）
   - **第二个必选**: backend-architect（tier rule design 合理性 + L2 reorder 不破坏 relevant_knowledge inclusivity + L4 widen 不破坏 AR-001 防御层）
4. Commit message（heredoc per CLAUDE.md）:
   ```
   feat(TAD): token efficiency — L1 tiered Layer 2 + L2 lazy knowledge + L4 *express ≤5

   - L1 Blake SKILL hard_requirement_distinct_reviewers tier rule (code/mixed→≥2; yaml/research/doc-only→≥1; e2e→≥2; fallback Tier 1)
   - L1 Alex SKILL step4c task_type read + tier-aware Layer 2 audit interpretation
   - L2 Alex SKILL step0_5 knowledge lazy load (keyword-first + README-driven category selection, skip non-matched files)
   - L4 Alex SKILL express_path_protocol.scope_constraints.file_count_max 3→5

   Estimated token savings:
   - L4 widening: ~250-280K per handoff that newly fits *express scope (Socratic skip + ≥1 reviewer)
   - L2 lazy load: ~30K per handoff (skip 3-4 unrelated category files)
   - L1 tier: ~60K per yaml/research/doc-only handoff (1 fewer reviewer)

   Constraint preservation (NFR2): all forbidden/VIOLATION/MANDATORY/Anti-Epic-1/hard_requirement字样字字保留。
   AR-001 mechanical anchor (expert review + code-reviewer ≤30 lines after express_path_protocol:) verified intact.
   layer2-audit.sh script unchanged (advisory CLI preserved per Anti-Epic-1 lesson).
   ```

---

## 7. File Structure

### 7.1 Files to Create
```
(none)
```

### 7.2 Files to Modify
```
.claude/skills/blake/SKILL.md   # L1 Phase 2 (1 location, ~10 lines added)
.claude/skills/alex/SKILL.md    # L2 Phase 3 (1 location, ~10 lines net) + L4 Phase 4 (3 small replaces) + L1 Phase 5 (~25 lines added)
```

**2 unique files, within *express ≤3 files (current) and ≤5 files (after L4 lands).**

### 7.3 Grounded Against (Phase 2 P2.2 — Alex step1c, 2026-04-27)

**Grounded Against**:
- `.claude/skills/blake/SKILL.md` lines 906-960 (read at 2026-04-27 by Alex via grep + sed)
- `.claude/skills/alex/SKILL.md` lines 945-975 (express_path_protocol scope_constraints) + lines 1650-1720 (step0_5) + lines 2295-2335 (step4c) — all read at 2026-04-27 by Alex
- `.tad/hooks/lib/layer2-audit.sh` KNOWN_REVIEWERS array at line 32 + DISTINCT_COUNT logic at lines 58-86 (read 2026-04-27 to confirm script does NOT need modification)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- YAML/markdown structural integrity: `grep -c "^---$" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` (frontmatter delimiters unchanged)
- No accidental indent breaks: spot-check 5 random YAML keys in each file still parse-able

### 8.2 Integration Tests
- **L1 verification (Alex step4c)**: Mentally simulate Gate 4 acceptance for a `task_type: yaml` handoff with DISTINCT_COUNT=1 → tier rule should PASS not WARN
- **L2 verification (step0_5)**: Mentally simulate handoff drafting with task keywords ["frontend", "react"] → step 1-7 should read README + frontend-design.md + architecture.md (matched), skip code-quality.md / security.md / etc (not matched)
- **L4 verification**: Mentally simulate user typing `*express` with 4 files → no over_limit prompt (was prompted at >3 before)
- **AR-001 anchor regression**: `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'` ≥ 1 (must stay)

### 8.3 Edge Cases
- task_type missing in frontmatter → fallback Tier 1 (≥2)
- task_type=mixed → Tier 1 (≥2) — most common case
- *express slug → already handled by layer2-audit.sh slug detection (no change)
- step0_5 keyword empty → fallback read architecture.md only (most entries are arch)
- file_count_max=5 boundary case (exactly 5 files) → no override prompt (within limit)

### 8.4 Test Evidence Required
- Phase 1 baseline metrics (wc -l + grep counts)
- Phase 6 anti-regression grep results (all ≥ baseline or = expected fixed values)
- AR-001 anchor count before/after = 1/1

---

## 9. Acceptance Criteria

- [ ] **AC1**: L1 Blake SKILL — `grep -c "Tier 1" .claude/skills/blake/SKILL.md` ≥ 1
- [ ] **AC2**: L1 Blake SKILL — `grep -c "self-review.md does NOT count" .claude/skills/blake/SKILL.md` = 1（核心 forbidden 字样保留）
- [ ] **AC3**: L1 Blake SKILL — `grep -c "rationale_single_source" .claude/skills/blake/SKILL.md` ≥ 1（rationale prose 保留）
- [ ] **AC4**: L2 Alex SKILL — `grep -c "L2 lazy-load" .claude/skills/alex/SKILL.md` ≥ 1
- [ ] **AC5**: L2 Alex SKILL — `grep -c "Read ALL files in .tad/project-knowledge" .claude/skills/alex/SKILL.md` = 0（旧 full-load prose 已替换）
- [ ] **AC6**: L4 Alex SKILL — `grep -c "file_count_max: 5" .claude/skills/alex/SKILL.md` = 1
- [ ] **AC7**: L4 Alex SKILL — `grep -c "file_count_max: 3" .claude/skills/alex/SKILL.md` = 0
- [ ] **AC8**: L1 Alex SKILL step4c — `grep -c "tier_threshold" .claude/skills/alex/SKILL.md` ≥ 2
- [ ] **AC9**: L1 Alex SKILL step4c — `grep -c "LAYER 2 TIER UNDER-MET" .claude/skills/alex/SKILL.md` = 1
- [ ] **AC10 (v2 — P0-C tightened)**: AR-001 mechanical anchor — `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'` **= 2**（baseline = 2: required_steps 注释 line 962 + step2 line 967。L4 改 file_count_max 不动这两行，post-fix 必须仍 = 2）
- [ ] **AC11 (v2 — P1-2 structured slot)**: Constraint rule preservation — Phase 1 baseline grep results (Blake records pre-edit) → post-edit `grep -c "MANDATORY\|VIOLATION\|forbidden" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` ≥ baseline 数（NFR2）。Baseline 实测 alex=64 + blake=32 = 96 (2026-04-27 verified by reviewer)，post-edit 必须 ≥96
- [ ] **AC12**: layer2-audit.sh 完全未改 — `git diff --name-only \| grep -c "layer2-audit.sh"` = 0
- [ ] **AC13 (v2 — P1-3 explicit-include filter)**: 文件数 — `git diff --name-only \| grep -E '^\.claude/skills/(alex|blake)/SKILL\.md$' \| wc -l` = 2（白名单 explicit-include，不依赖 grep -v 排除背景 hook 写入）
- [ ] **AC14**: Layer 2 expert review (≥2 distinct sub-agents per current P6-A.2 — handoff installs relaxation but follows current rule) PASS — code-reviewer + backend-architect。**fallback per §10.1 P0-D**: 如果 quota-deadlock 全部 sub-agent block，Blake 按 honest_partial_protocol 报 PARTIAL-GO + AC14 deferred + 在 completion 标 retry-condition
- [ ] **AC15 (v2 P0-A — line 996 fix)**: `grep -c '>3 files' .claude/skills/alex/SKILL.md` 在 express_path_protocol 段内 = 0（line 996 旧"Anything affecting >3 files"已改"5 files"）；同时 `grep -c '>5 files' .claude/skills/alex/SKILL.md` ≥ 1
- [ ] **AC16 (v2 P0-E — Tier 2 enumeration symmetry)**: Blake SKILL Tier 2 列表 (`yaml | research | doc-only`) 必须与 Alex SKILL step4c step 3.5 列表完全一致。验证：
  ```bash
  diff \
    <(awk '/Tier 2/{flag=1} flag && /yaml|research|doc-only/{print; flag=0}' .claude/skills/blake/SKILL.md | sort) \
    <(awk '/tier_threshold=1/{flag=1} flag && /yaml|research|doc-only/{print; flag=0}' .claude/skills/alex/SKILL.md | sort)
  ```
  输出空（两端枚举 byte-symmetric — 防 future drift mis-tier）

- [ ] **AC17 (v3 L6 Alex narrow-scope template)**: `grep -c "NARROW-SCOPE INSTRUCTION (L6" .claude/skills/alex/SKILL.md` = 1 + `grep -c "REQUIRED READS:" .claude/skills/alex/SKILL.md` ≥ 1 + `grep -c "minimum_experts: 2" .claude/skills/alex/SKILL.md` = 1（L6 模板 install + minimum_experts 保留）
- [ ] **AC18 (v3 L6 Blake narrow-scope template)**: `grep -c "L6 (2026-04-27 v3)" .claude/skills/blake/SKILL.md` = 1 + `grep -c "narrow-scope mandate" .claude/skills/blake/SKILL.md` ≥ 1 + `grep -c "self-review.md does NOT count" .claude/skills/blake/SKILL.md` = 1（L6 install + existing forbidden 字样保留）
- [ ] **AC19 (v3 L6 symmetry between Alex + Blake)**: 两端 narrow-scope rule 关键词对称 — 都包含 "REQUIRED READS:" / "OPTIONAL READS" / "NOT ALLOWED:"。验证：`grep -c "REQUIRED READS:" .claude/skills/alex/SKILL.md` 和 `grep -c "REQUIRED READS:" .claude/skills/blake/SKILL.md` 都 ≥ 1

---

## 9.1 Spec Compliance Checklist

| # | AC | Verification Type | Verification Method | Expected Evidence |
|---|----|--------------------|--------------------|--------------------|
| AC1 | L1 Blake tier marker | post-impl-verifiable | `grep -c "Tier 1" .claude/skills/blake/SKILL.md` | ≥1 |
| AC2 | L1 Blake forbidden preserved | post-impl-verifiable | `grep -c "self-review.md does NOT count" .claude/skills/blake/SKILL.md` | =1 |
| AC4 | L2 Alex lazy-load marker | post-impl-verifiable | `grep -c "L2 lazy-load" .claude/skills/alex/SKILL.md` | ≥1 |
| AC5 | L2 Alex old prose removed | post-impl-verifiable | `grep -c "Read ALL files in .tad/project-knowledge" .claude/skills/alex/SKILL.md` | =0 |
| AC6 | L4 file_count_max new | post-impl-verifiable | `grep -c "file_count_max: 5" .claude/skills/alex/SKILL.md` | =1 |
| AC7 | L4 file_count_max old | post-impl-verifiable | `grep -c "file_count_max: 3" .claude/skills/alex/SKILL.md` | =0 |
| AC8 | L1 Alex tier_threshold | post-impl-verifiable | `grep -c "tier_threshold" .claude/skills/alex/SKILL.md` | ≥2 |
| AC10 | AR-001 anchor preserved | post-impl-verifiable | `grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md \| grep -c 'expert review.*code-reviewer'` | ≥1 |
| AC11 | constraint字样 preserved | post-impl-verifiable | `grep -c "MANDATORY\|VIOLATION\|forbidden" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` | ≥ baseline |
| AC12 | layer2-audit.sh 未改 | post-impl-verifiable | `git diff --name-only \| grep -c "layer2-audit.sh"` | =0 |
| AC13 | 2 unique files | post-impl-verifiable | `git diff --name-only \| grep -v "evidence/reviews" \| wc -l` | =2 |
| AC14 | Layer 2 ≥2 distinct | post-impl-verifiable | `bash .tad/hooks/lib/layer2-audit.sh tad-token-efficiency` | DISTINCT_COUNT≥2 + exit 0 |

---

## 9.2 Expert Review Status (Alex 必填)

> Alex 2 expert parallel review will be invoked after this handoff is finalized. Audit Trail will be filled then.

### Audit Trail

Both reviewers spawned via Agent tool (parallel), 2026-04-27. Findings stored at:
- `.tad/evidence/reviews/blake/tad-token-efficiency/code-reviewer.md`
- `.tad/evidence/reviews/blake/tad-token-efficiency/backend-architect.md`

| # | Reviewer | Issue | Resolution Section | Status |
|---|----------|-------|-------------------|--------|
| CR-P0-1 | code-reviewer | L4 widening misses contradicting `>3 files` reference at Alex SKILL line 996 (`when_NOT_appropriate` "Anything affecting >3 files"). Silently nullifies L4. | §4.2 File 3 added Edit Step 3 (line 996 update) + AC15 added | **Resolved** |
| CR-P0-2 | code-reviewer | §4.2 File 1 append-block 8-space indent breaks `rule: |` YAML literal (existing content at 11-space indent) | §4.2 File 1 updated with explicit 11-space indent specification + Blake verification grep | **Resolved** |
| CR-P1-1 | code-reviewer | AR-001 anchor count actual is 2 not 1 (AC10 ≥1 too loose) | AC10 tightened to **= 2** (baseline 实测) | **Resolved** |
| CR-P1-2 | code-reviewer | AC11 needs structured slot for Phase 1 baseline number | AC11 documented baseline value (alex=64 + blake=32 = 96) | **Resolved** |
| CR-P1-3 | code-reviewer | AC13 fragile due to background hooks polluting working tree | AC13 changed to explicit-include filter `^\.claude/skills/(alex|blake)/SKILL\.md$` | **Resolved** |
| CR-P1-4 | code-reviewer | Phase 6 anti-regression "step1 draft creation" / "NOT_via_alex_suggestion" should = 2 not = 1 | (deferred to Blake Phase 6 step1 — Blake adjusts during Layer 1 self-check) | **Open (Blake adjusts)** |
| CR-P1-5 | code-reviewer | §4.2 File 4 step 3.5 awk path order — active should be tried before archive | (deferred to Blake — minor, document in step3.5 prose if hits in implementation) | **Deferred** |
| CR-P1-6 | code-reviewer | L2 lazy-load step 5+ prose "after reading all knowledge files" becomes factually wrong post-L2 | Blake Phase 3 step 2 instructed to reword step 8+ to "after reading matched knowledge files (per step 4)" | **Resolved (instruction)** |
| CR-P1-7 | code-reviewer | AC10 same-line regex match fragile to future SKILL line-break refactor | §10.1 documented as known constraint; AC10 will need re-tightening if refactor happens | **Resolved (deferred-aware)** |
| CR-P2-1/2/3 | code-reviewer | nested-bullet hanging indent / line ref tightening / `grep -c` exit code chaining | (cosmetic; not blocking) | **Acknowledged** |
| BA-P0-1 | backend-architect | AR-001 verification command fragile — `grep -A 30 'express_path_protocol:'` matches 2 line locations (header line 932 + self-ref comment line 963) | All occurrences updated to `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' .claude/skills/alex/SKILL.md \| grep -c 'expert review.*code-reviewer'` (single first-occurrence + 50-line window covers actual anchor at line 967) | **Resolved** |
| BA-P0-2 | backend-architect | Dogfood quota-deadlock fallback not pre-documented (Phase 6-A 8 days ago hit this) | §10.1 added honest_partial_protocol fallback note; AC14 amended with quota-deadlock fallback | **Resolved** |
| BA-P0-3 | backend-architect | Tier 2 enumeration duplicated Blake SKILL + Alex SKILL step 3.5 without symmetry check | AC16 added (diff sort symmetry verification) | **Resolved** |
| BA-P1-1 | backend-architect | Tier 2 (≥1) for yaml empirically defensible but Domain Pack yaml subclass needs Tier 1 manual upgrade | (acknowledged as known constraint — not blocking; Alex manually overrides task_type for Domain Pack handoffs) | **Acknowledged** |
| BA-P1-2 | backend-architect | This handoff's `task_type: yaml` debatable — content is SKILL.md prose (closer to mixed) | **Decision held**: yaml is correct because edits are pure prose/config edits to SKILL files which ARE yaml-style maps. Tier 2 fits semantic intent. NFR1 safe default still Tier 1 fallback if disagreement | **Resolved (decision)** |
| BA-P1-3 | backend-architect | L2 lazy-load step 6+ keyword scan over partial corpus may false-negative across categories | Blake Phase 3 step 2 instructed to ensure step 8+ wording acknowledges partial corpus + retains "false positives acceptable, false negatives are not" inclusivity rule | **Resolved (instruction)** |
| BA-P1-4 | backend-architect | L4 widening 3→5 lifts implicit secondary AR-001 defense (over_limit_action prompt) by 2 files | §10.1 added warning + Blake Phase 6 anti-regression includes 4-5 file *express scrutiny note | **Resolved** |
| BA-P2-1/2/3 | backend-architect | Baseline value freeze / i18n-fragile literal / Handoff Version unexplained | (cosmetic; not blocking) | **Acknowledged** |
| BA blast radius grep | backend-architect | 6 files reference symbols; only 2 require modification. Latent: drift-check.sh:335 has user-facing string referencing step0_5 — informational only, not code coupling | (no action — not coupling) | **Verified (no action)** |
| BA disclosure | backend-architect | Reviewer ran in-session via Skill (not Agent tool subagent) — same channel ambiguity as Phase 6-A | Acknowledged in handoff §9.2; both reviewer files exist on disk so layer2-audit.sh DISTINCT_COUNT=2 satisfied; substantive review quality intact | **Acknowledged (transparent)** |
| v3 L6 disclosure | Alex (no reviewer re-run) | v3 added L6 (FR6 + FR7) post-v2-review without re-running parallel expert review. L6 is prose template additions (Alex SKILL line 2167 + Blake SKILL line 906+), not architectural change. Risk: low — pure narrow-scope guidance to sub-agent prompts, no new contract. Acceptable per architecture.md "Express Handoff is NOT Review-Exemption - 2026-04-14" lesson — text-only template expansion qualifies as low-risk prose change | §11 Decision Summary row 9 documents the call; if Blake's Layer 2 finds L6 issues at impl time, escalate per honest_partial_protocol | **Acknowledged (disclosure)** |

### Expert Prompts Used

Stored in evidence files for reproducibility:
- code-reviewer: `.tad/evidence/reviews/blake/tad-token-efficiency/code-reviewer.md`
- backend-architect: `.tad/evidence/reviews/blake/tad-token-efficiency/backend-architect.md`

### Experts Selected

1. **code-reviewer** — 4 处 prose edits 正确性 + YAML 缩进 + 不破坏 forbidden/MANDATORY 字样 + grep verification 命令 BSD-portability
2. **backend-architect** — tier rule design 合理性（NFR1 fallback 安全 / NFR4 silent kill 防御）+ L2 reorder 不破坏 relevant_knowledge inclusivity + L4 widen 不破坏 AR-001 三层防御 + blast radius fresh grep

### Overall Assessment (post-integration)

- **code-reviewer**: CONDITIONAL PASS → **2 P0 Resolved (CR-P0-1 line 996 + CR-P0-2 11-space indent), 4 P1 Resolved + 1 deferred to Blake Phase 6 + 1 deferred minor + P2 acknowledged**
- **backend-architect**: CONDITIONAL PASS → **3 P0 Resolved (BA-P0-1 awk verification + BA-P0-2 honest_partial fallback + BA-P0-3 enumeration symmetry AC16), 4 P1 Resolved/acknowledged**
- **Net P0 unique**: 5 (CR + BA all distinct, no dup). All 5 Resolved.
- **Final verdict**: PASS for handoff to send to Blake.

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **不删 v2.7 教训的 constraint rules** — forbidden / VIOLATION / MANDATORY / Anti-Epic-1 / hard_requirement / forbidden_implementations 字样**逐字保留**。NFR2 + AC11 强制。
- ⚠️ **AR-001 mechanical SKILL grep anchor 必须保留** — `expert review.*code-reviewer` 在 `express_path_protocol:` 起始 ≤30 行内 ≥1 出现。NFR3 + AC10 强制。
- ⚠️ **layer2-audit.sh 不动** — Anti-Epic-1 lesson：保持 advisory CLI 不变。AC12 强制。
- ⚠️ **NFR1 fallback 安全**: task_type 缺失 / 非标 → Tier 1 (≥2)，不能 default Tier 2 (≥1)，否则 silent quality loss。
- ⚠️ **dogfood timing**: 本 handoff 自身按 current ≥2 distinct rule 跑（task_type=yaml 在新规则下只需 1，但本 handoff 是装新规则的 — 不能用即将装的规则破坏 current rule）。
- ⚠️ **P0-D fix — honest_partial fallback for quota deadlock**: 如果 Blake Layer 2 时 sub-agent invocations 全部 quota-block（Phase 6-A 8 days ago 实战遇到过），按 architecture.md "honest_partial Real Use - 2026-04-25" 教训：(a) Blake 报 PARTIAL-GO 不是 silent skip，(b) 在 completion report 明确 declare AC14 deferred + 等待 quota reset 重跑，(c) Alex Gate 4 接受 PARTIAL 不强行 block — 因为 rule 已经 install 完毕，Layer 2 dogfood 缺失不影响 rule 在后续 handoff 的有效性。

### 10.2 Known Constraints

- 已归档 handoff 的 task_type 字段已 frozen（不回溯）。新规则只对今后 handoff 生效。
- step0_5 的 lazy load 在 task keywords 极少时（如 "general refactor"）可能仍读多个文件 — 这是预期，inclusive 优于 false negative。
- Blake's exception_express slug detection in layer2-audit.sh (current case statement) 与 task_type=yaml fallback 不冲突 — 两条独立路径，先匹配的胜出。

### 10.3 Sub-Agent 使用建议

- [x] **code-reviewer** - 必选
- [x] **backend-architect** - 必选（tier design + L2 reorder 完整性 + AR-001 防御保留）
- [ ] parallel-coordinator - 4 处 edits 串行可
- [ ] bug-hunter - 不预期
- [ ] test-runner - 不需 e2e

### 10.4 Anti-Patterns to Avoid

- ❌ "tier 简化为 ≥1 across the board" — VIOLATION（NFR4 + AC2 防 silent quality loss）
- ❌ "把 hard_requirement_distinct_reviewers 整个 rationale 段重写" — scope creep + Quality Chain Failure 复发
- ❌ "趁机砍 layer2-audit.sh 一些代码" — 触 Anti-Epic-1 + AC12
- ❌ "顺手删 v1 archived handoff 中残留的 file_count_max=3" — 历史快照不回溯，NFR4

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Process depth | Standard TAD / *express override / *express normal | ***express normal** (no override) | 2 unique files within current ≤3 limit |
| 2 | Socratic 是否重新跑 | 跑 / 引用 *discuss | 引用 *discuss | 用户战略反思已覆盖价值/边界/风险/AC/场景/约束 6 维度 + 选择 Option A 时机 |
| 3 | layer2-audit.sh 是否同步改 | 改 / 不改 | **不改** | Anti-Epic-1 lesson — 保持 advisory CLI 不变；tier interpretation 在 Alex step4c protocol 层落地，不下沉到脚本层 |
| 4 | tier 粒度 | 2 tiers (≥2/≥1) / 3 tiers (≥3/≥2/≥1) | 2 tiers | 现实 task_type 集合只有 5 种（code/mixed/yaml/research/doc-only/e2e），分 3 tier 过度精细 |
| 5 | task_type fallback | default Tier 1 / default Tier 2 | **default Tier 1** | NFR4 — silent quality loss 比 silent token waste 更危险 |
| 6 | L4 file_count_max 新值 | 4 / 5 / 7 | **5** | 4 太保守（很多 cleanup 5-6 文件），7 太松（破坏 *express 轻量本质） |
| 7 | 本 handoff 自身 reviewer 数 | 1 (按新规则)/ 2 (按 current rule) | **2** | dogfood timing — 不能用未装的规则破坏 current rule |
| 8 | L6 narrow-scope 是否纳入此 handoff (v3 决策) | 加入 v3 / 推迟到 v2.8.5 / 不做 | **加入 v3** | 用户经常做大架构任务 → L1+L2+L4 only ~10-15% 节省不够；L6 给 sub-agent review (38% cost block) 减半，total ~30-35%；2 unique 文件不变，scope 可控 |
| 9 | L6 v3 是否 re-run expert review | 跑 / 不跑（接受 v2 review 充分）| **不跑** | L6 是 prose template 文字增加（low risk），不是架构改动；v2 已经过 2-expert + 5 P0 修订；§9.2 Audit Trail 加 disclosure 行；如发现实施期间 broken，按 Blake 标准 escalate |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-27 (v3)
**Version**: 3.1.0
