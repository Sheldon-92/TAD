---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/gate", ".claude/skills/alex", ".claude/skills/blake", ".claude/skills/tad-handoff", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-07
**Project:** TAD
**Task ID:** TASK-20260607-001
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-07

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | AC-driven Gate with fallback to defaults |
| Components Specified | ✅ | 6 files to modify, clear scope |
| Functions Verified | ✅ | Gate 3/4 blocks exist, §9.1 format exists |
| Data Flow Mapped | ✅ | Alex generates AC → §9.1 → Blake verifies → Gate reads §9.1 |

**Gate 2 结果**: ✅ PASS
**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
TAD Universal Gate: 把 Gate 3/4 从硬编码 dev 检查（tsc/test/lint + deliverable rubric 分支）改为**§9.1 AC 驱动的动态验证**。

### 1.2 Why We're Building It
**业务价值**：TAD 能无差别服务 dev 项目（menu-snap, 合规ai）和非 dev 项目（Colin声音/播客制作, Sober Creator/内容品牌, 买卖/跨境电商）
**用户受益**：任何项目类型的 Handoff 都能得到有意义的 Gate 质量检查，不再被迫走 tsc/lint 路径
**成功的样子**：当一个播客制作 Handoff 的 AC 写"pitch 偏移 < 20Hz, 运行 measure_consistency.py"时，Gate 3 能正确执行这个验证命令并判断 pass/fail

### 1.3 Intent Statement

**真正要解决的问题**：Gate 3 的验证逻辑硬编码了 dev 检查（tsc/test/lint），非 dev 项目只能走"附加"的 deliverable 分支。改造后，§9.1 Spec Compliance Checklist 成为 Gate 3 的**主验证源**，tsc/test/lint 降为 Alex 智能生成的默认 AC 而非硬编码检查。

**不是要做的（避免误解）**：
- ❌ 不是删除 tsc/test/lint 检查——它们变成 Alex 为 dev 项目自动生成的 AC
- ❌ 不是改变 Gate 的通过/不通过语义——只是改变验证的数据来源
- ❌ 不是改变角色分工——Alex 设计, Blake 执行, Gate 检查

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - Gate 架构变更
- [x] gate-design patterns - Gate 设计模式

### ⚠️ Blake 必须注意的历史教训

1. **Non-Dev Execution Track: Branch as Additive Sibling** (来自 patterns/gate-design.md)
   - 问题：deliverable 分支用 additive sibling 实现，不能破坏原有 code block
   - 本次相关：我们在吸收 deliverable track 进新架构时，要确保不破坏原有的 byte-preservation 约束

2. **Gate Responsibility Matrix** (来自 patterns/gate-design.md)
   - 问题：Gate 3 = Blake 的技术检查, Gate 4 = Alex 的业务验收
   - 本次相关：改造只改"检查内容从哪来"，不改"谁负责检查"

3. **Gate 4 Verification Integrity** (来自 patterns/gate-design.md)
   - 问题：Gate 4 必须 raw-TSV recompute，不能只读 Blake 报告
   - 本次相关：AC 驱动的验证必须真正执行验证命令，不能只看 Blake 说"passed"

---

## 3. Requirements

### FR1: §9.1 成为 Gate 3 的主验证源
Gate 3 的检查项**完全来自** Handoff 的 §9.1 Spec Compliance Checklist 表格。每行有：
- AC 编号
- Verification Method（具体命令或检查方式）
- Expected Evidence（预期结果）

Gate 3 逐行执行 Verification Method，对比 Expected Evidence，判断 pass/fail。

### FR2: Alex 为 dev 项目智能生成基础 AC
当 Alex 在 Socratic Inquiry 中识别到项目是 dev 项目（有 package.json / tsconfig / pyproject.toml / Makefile 等），自动在 §9.1 中生成基础 AC 行：
- `npm test` / `pytest` / `make test`（检测到测试框架时）
- `npx tsc --noEmit`（检测到 tsconfig.json 时）
- `npm run lint` / `eslint .`（检测到 linter 配置时）
- `git diff --stat`（always — 确认变更范围）

这些是**默认行为**，Alex 可以根据任务调整（比如纯 doc 改动跳过 tsc）。

### FR3: 非 dev 项目的 AC 完全由 Handoff 定义
对于 Colin声音项目类型的项目，§9.1 的 AC 完全来自 Socratic Inquiry 中确定的质量标准。例如：
- `python scripts/measure_consistency.py EP04 | grep "overall" | awk '{print $2}'` → `> 70`
- `python scripts/build_podcast_eval.py EP04 --check` → exit 0
- `ls podcasts/EP04-colin/final/*.wav | wc -l` → `>= 1`

### FR4: deliverable track 吸收进 §9.1 模式 — Rubric Protocol 保留为 Gate 级约束
现有的 `task_type: deliverable` **路由分支**被移除（不再有独立 Gate 3/4 block）。但以下 SAFETY 逻辑 **保留为 Gate 级别的 "Rubric Evaluation Protocol" section**（当任何 §9.1 AC 引用 rubric 评分或独立 judge 时自动触发）：
- **Judge_Not_Producer** (5 VIOLATION entries) — 防止 self-scoring bias
- **Verdict_Mapping** (weighted/categorical/checklist 3 种 verdict_shape) — 评分→verdict 映射
- **Rubric_Resolution** (precedence: frontmatter > registry > BLOCK) — rubric 来源解析
- **verdict_shape_guard** — 未知 shape → BLOCK
- **decoupling_firewall** (ORDER OF EMISSION + SWAP TEST) — categorical 防结论锚定
- **checklist malformed_guard** — 全 optional 的 checklist → BLOCK
- **evidence_independence** — judge 从实质内容评分，不信 artifact 自我声明
- **Gate3_Verdict_Marker** — 写 gate3_verdict 到 completion report frontmatter 触发 telemetry

这些逻辑从 "deliverable-only branch" 提升为 **universal Gate section "Rubric Evaluation Protocol"**，当且仅当 §9.1 中存在 rubric/judge 类 AC 时激活。Alex 在写 deliverable 类 AC 时引用此 protocol（如 "spawn independent judge per Rubric Evaluation Protocol"）。

`task_type: deliverable` 作为 frontmatter enum 值 **保留**（不删除），语义变为"此 handoff 的 §9.1 中会有 rubric 类 AC"。

### FR5: Gate 4 混合改造（structural subagents 保留 + AC 驱动 business checks）
Gate 4 的 **structural subagent requirements** (security-auditor, performance-optimizer, code-reviewer) **保留为 Gate 级约束**（不被 AC 取代）——这是角色分离原则，不能让 Alex 通过不写 AC 来跳过安全审查。Gate 4 的 **business acceptance checklist**（"实现符合需求"等）改为从 §9 AC 读取。即 Gate 4 = structural subagent checks (preserved, for task_type: code/mixed) + AC-driven business checks (new)。

### FR6: dev 项目零回归
任何现有 dev 项目（menu-snap, 合规ai 等）的 Gate 行为**不能降级**。dev 项目通过 Alex 智能生成的基础 AC 保持原有的 tsc/test/lint 检查，只是不再是 Gate 的硬编码逻辑。

### FR7: §9.1 empty guard
如果 §9.1 为空或缺失，Gate 3 **BLOCK**（不是 silent pass），提示 "No verification criteria found in §9.1. Alex must populate the Spec Compliance Checklist."。这是从 hardcoded 切换到 AC-driven 后必须的安全网。

### NFR1: 变更范围控制
修改 6 个文件 + 1 个模板，不引入新文件、新配置、新概念。

---

## 4. Technical Design

### 架构概述

```
BEFORE:
  Alex writes Handoff → Gate 3 runs hardcoded checks (tsc/test/lint)
                         └─ IF task_type=deliverable → separate rubric branch

AFTER:
  Alex writes Handoff with §9.1 → Gate 3 reads §9.1 → executes each row
  └─ dev project: Alex auto-generates tsc/test/lint rows in §9.1
  └─ non-dev project: Alex generates domain-specific rows
  └─ deliverable: Alex generates rubric-eval rows
```

### 文件变更设计

**1. gate/SKILL.md — Gate 3 主体重写**
- 删除现有的 hardcoded "Critical Check (5 items)" 块
- 删除 `Required_Subagent: test-runner` 硬编码要求
- 删除 `Acceptance_Verification` 硬编码要求
- 替换为：§9.1 逐行验证 + empty guard（§9.1 为空 → BLOCK）
- 保留：Prerequisite (completion report), Git Commit Verification, Risk Translation, Knowledge Assessment
- **Rubric Evaluation Protocol 提升**：从 deliverable branch 中提取以下 SAFETY blocks 到新的通用 section `## Rubric Evaluation Protocol`（当 §9.1 含 rubric/judge 类 AC 时激活）：
  - Judge_Not_Producer (5 VIOLATIONs)
  - Verdict_Mapping (weighted/categorical/checklist)
  - Rubric_Resolution + verdict_shape_guard
  - decoupling_firewall (ORDER OF EMISSION + SWAP TEST)
  - checklist malformed_guard + evidence_independence
  - Gate3_Verdict_Marker (telemetry — 提升为 universal post-step, 所有 task_type 都写 gate3_verdict)
- 删除 `## Gate 3 — Deliverable Branch` 独立块（其 SAFETY 逻辑已迁移到 Rubric Evaluation Protocol）
- 删除 `## Gate 4 — Deliverable Branch` 独立块
- Gate 4 混合改造：structural subagent requirements (security-auditor, performance-optimizer, code-reviewer) 保留为 BLOCKING 约束 (task_type=code/mixed)；business checklist 改为读 §9 AC

**2. alex/SKILL.md — step1 draft 增强**
- 在 `handoff_creation_protocol.step1` 中添加项目类型检测逻辑
- 当检测到 dev 项目标志（package.json, tsconfig, pyproject.toml 等），在 §9.1 自动生成 tsc/test/lint AC 行
- 当检测到非 dev 项目或 task_type=deliverable，提醒 Alex 写域特定 AC

**3. blake/SKILL.md — 最小改动**
- Blake 的 Ralph Loop Layer 1 已经基于 Handoff AC 执行。无需大改。
- 移除对 `task_type: deliverable` 的特殊路由逻辑（如果有）
- 确保 Blake 在 step2 中对每个 §9.1 AC 执行验证并记录结果

**4. templates/handoff-a-to-b.md — §9.1 提升**
- §9.1 Spec Compliance Checklist 从"补充"变成"主验证源"
- 添加注释强调每行的 Verification Method 是 Gate 3 会真正执行的命令
- 增加 dev 项目 AC 生成示例和非 dev 项目 AC 示例

**5. templates/deliverable-handoff.md — 合并/废弃**
- deliverable 不再需要独立模板，AC 写在通用 §9.1 里
- 标记为 deprecated，指向通用 handoff 模板

---

## 6. Implementation Steps

### P1: gate/SKILL.md — Gate 3 改为 AC 驱动 + Rubric Protocol 提升
1. 在 Gate 3 block 中，替换 hardcoded "Critical Check (5 items)" 为 §9.1 逐行验证逻辑
2. 添加 **§9.1 empty guard**：如果 §9.1 表格为空/缺失 → BLOCK Gate 3（不是 silent pass）
3. 替换 `Required_Subagent: test-runner` 为"Gate 按 §9.1 内容执行，如有 test 类 AC 则跑 test"
4. 替换 `Acceptance_Verification` 硬编码为"Gate 读 §9.1，逐行 pass/fail"
5. 保留 Prerequisite / Git Commit / Risk Translation / Knowledge Assessment
6. **新建 `## Rubric Evaluation Protocol` section**：从 deliverable branch 中提取以下 blocks（SAFETY keyword 须 byte-exact 保留）：
   - Judge_Not_Producer (5 VIOLATIONs)
   - Verdict_Mapping (weighted/categorical/checklist + decoupling_firewall)
   - Rubric_Resolution + verdict_shape_guard
   - checklist malformed_guard + evidence_independence
   - 激活条件：§9.1 中存在引用 rubric/judge 的 AC
7. **Gate3_Verdict_Marker 提升为 universal post-step**：所有 task_type 的 Gate 3 完成后都写 gate3_verdict 到 completion report frontmatter（不只 deliverable）
8. 删除 `## Gate 3 — Deliverable Branch` 整个 block（SAFETY 逻辑已迁移到 step 6）
9. 删除 `## Gate 4 — Deliverable Branch` 整个 block
10. Gate 4 混合改造：保留 structural subagent requirements (security-auditor/performance-optimizer/code-reviewer) 为 BLOCKING (task_type=code/mixed)；business checklist 改为读 §9 AC

### P2: alex/SKILL.md — AC 智能生成
1. 在 `handoff_creation_protocol.step1` 添加 `step1_ac_generation` 子步骤
2. 检测方式是 **task-scoped**（基于当前任务的 §6 文件列表 + Socratic 结果），不是纯 project-scoped
   - 如果任务涉及的文件有 .ts/.tsx → 生成 tsc AC
   - 如果任务涉及的文件有 .py → 检测 pytest/unittest → 生成 test AC
   - 如果项目有 linter config（.eslintrc, pyproject.toml [tool.ruff]）→ 生成 lint AC
   - `git diff --stat` 总是生成（确认变更范围）
   - 如果任务是纯 doc/audio/video/content → 不生成 dev AC
3. 根据项目类型生成基础 §9.1 AC 行
4. 在 `step0_6_deliverable_classification` 中：保留 `task_type: deliverable` 设置，但改为选择通用 handoff 模板（handoff-a-to-b.md），不再路由到 deliverable-handoff.md

### P3: blake/SKILL.md — 统一 task_type 处理
1. 移除 `task_type_branching.deliverable` 特殊路由
2. 替换为：Blake 对所有 task_type 统一按 §9.1 AC 执行验证，如果 AC 涉及 rubric/judge → 参照 gate/SKILL.md 的 Rubric Evaluation Protocol

### P4: 模板更新
1. handoff-a-to-b.md：§9.1 增加 "⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 will execute each row" 注释
2. handoff-a-to-b.md：增加 dev AC 示例 + 非 dev AC 示例 + rubric AC 示例
3. deliverable-handoff.md：头部标记 DEPRECATED，指向 handoff-a-to-b.md

### P5: tad-handoff/SKILL.md — 更新模板选择
1. 移除 `task_type: deliverable` 到 deliverable-handoff.md 的路由
2. 所有 task_type 统一使用 handoff-a-to-b.md

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- .claude/skills/gate/SKILL.md (head 100 + lines 100-300 + lines 300-400, read at 2026-06-07)
- .claude/skills/alex/SKILL.md (full activation protocol, read at 2026-06-07)
- .tad/templates/handoff-a-to-b.md (head 160, read at 2026-06-07)
- .tad/project-knowledge/patterns/gate-design.md (full, read at 2026-06-07)
- .tad/project-knowledge/patterns/handoff-design.md (head 60, read at 2026-06-07)

---

## 7. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | .claude/skills/gate/SKILL.md | MODIFY | Gate 3: hardcoded → §9.1 driven + empty guard; new Rubric Evaluation Protocol section; Gate3_Verdict_Marker universal; Gate 4: structural subagents preserved + AC business checks; remove deliverable branches |
| 2 | .claude/skills/alex/SKILL.md | MODIFY | Add step1_ac_generation (task-scoped detection + AC auto-gen); update step0_6 to use universal template |
| 3 | .claude/skills/blake/SKILL.md | MODIFY | Remove task_type_branching.deliverable; unify AC-driven verification for all task_types |
| 4 | .tad/templates/handoff-a-to-b.md | MODIFY | Elevate §9.1 to primary verification source, add dev/non-dev/rubric AC examples |
| 5 | .tad/templates/deliverable-handoff.md | MODIFY | Add DEPRECATED header pointing to universal template |
| 6 | .claude/skills/tad-handoff/SKILL.md | MODIFY | Remove deliverable → deliverable-handoff.md routing; all task_types use handoff-a-to-b.md |

---

## 8. Testing Checklist

- [ ] 写一个 dev 风格的 mock Handoff（有 tsc/test/lint AC），跑 Gate 3，确认行为不变
- [ ] 写一个非 dev 风格的 mock Handoff（有自定义验证命令 AC），跑 Gate 3，确认能正确执行
- [ ] 验证 deliverable-handoff.md 的 deprecation header 正确
- [ ] 确认 alex/SKILL.md 的 step1_ac_generation 不会在非 dev 项目生成 tsc 类 AC
- [ ] 确认 Gate 4 改造后对现有 dev 项目零回归

---

## 9. Acceptance Criteria

### §9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Gate 3 block no longer hardcodes tsc/test/lint | `grep -cE 'Tests pass\|Standards met\|linting, formatting' .claude/skills/gate/SKILL.md` | 0 (removed) |
| AC2 | Gate 3 references §9.1 as primary verification source | `grep -cE '§9\.1\|Spec Compliance' .claude/skills/gate/SKILL.md` | >= 3 |
| AC3 | Deliverable Branch blocks removed from gate/SKILL.md | `grep -c 'Deliverable Branch' .claude/skills/gate/SKILL.md` | 0 |
| AC4 | Alex SKILL has step1_ac_generation | `grep -c 'step1_ac_generation' .claude/skills/alex/SKILL.md` | >= 1 |
| AC5 | Alex step1_ac_generation detects task-scoped file types | `grep -A20 'step1_ac_generation' .claude/skills/alex/SKILL.md \| grep -cE 'package\.json\|tsconfig\|pyproject\.toml'` | >= 1 |
| AC6 | deliverable-handoff.md has deprecation notice | `head -5 .tad/templates/deliverable-handoff.md \| grep -ci 'deprecated'` | >= 1 |
| AC7 | Gate 3 Prerequisite/Git/Risk/KA blocks preserved | `grep -cE 'Prerequisite\|Git_Commit_Verification\|Risk_Translation\|Knowledge_Assessment' .claude/skills/gate/SKILL.md` | >= 4 |
| AC8 | handoff-a-to-b.md §9.1 has primary verification annotation | `grep -cE 'PRIMARY VERIFICATION\|primary verification\|主验证源' .tad/templates/handoff-a-to-b.md` | >= 1 |
| AC9 | Zero regression: dev + non-dev AC examples in template | `grep -cE 'npm test\|tsc --noEmit\|eslint\|pytest\|measure_consistency\|build_podcast_eval' .tad/templates/handoff-a-to-b.md` | >= 3 |
| AC10 | SAFETY keyword count preserved (baseline 44) | `grep -cE 'BLOCKING\|MANDATORY\|VIOLATION' .claude/skills/gate/SKILL.md` | >= 44 |
| AC11 | Rubric Evaluation Protocol section exists | `grep -c 'Rubric Evaluation Protocol' .claude/skills/gate/SKILL.md` | >= 1 |
| AC12 | Judge_Not_Producer VIOLATIONs preserved in new section | `grep -A50 'Rubric Evaluation Protocol' .claude/skills/gate/SKILL.md \| grep -c 'VIOLATION'` | >= 5 |
| AC13 | §9.1 empty guard exists | `grep -cE 'empty\|missing.*BLOCK\|No verification criteria' .claude/skills/gate/SKILL.md` | >= 1 |
| AC14 | Gate3_Verdict_Marker is universal (not deliverable-only) | `grep -B5 'Gate3_Verdict_Marker\|gate3_verdict' .claude/skills/gate/SKILL.md \| grep -cv 'deliverable'` | >= 1 |
| AC15 | Gate 4 structural subagents preserved for code/mixed | `grep -cE 'security-auditor\|performance-optimizer\|code-reviewer' .claude/skills/gate/SKILL.md` | >= 3 |
| AC16 | tad-handoff/SKILL.md no longer routes to deliverable-handoff.md | `grep -c 'deliverable-handoff' .claude/skills/tad-handoff/SKILL.md` | 0 |

### §9.2 Expert Review

| Reviewer | Focus | Findings | Status |
|----------|-------|----------|--------|
| code-reviewer | Structural integrity, SAFETY keyword preservation, byte-change audit | 3 P0 (SAFETY migration gap, AC1 grep flag, no SAFETY count AC) + 5 P1 | ✅ Done — all P0 fixed in v2 |
| backend-architect | Architecture coherence, backward compatibility, deliverable-branch-removal safety | 3 P0 (verdict_shape orphaned, empty §9.1, judge≠producer lost) + 4 P1 | ✅ Done — all P0 fixed in v2 |

### §9.2.1 Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| CR-P0-1 | 22 SAFETY keywords in deliverable branch have no preservation plan | §10.2 enumerates all blocks + byte-exact preservation requirement; AC10/AC12 verify | Resolved |
| CR-P0-2 | AC1 grep missing `-E` flag (literal pipe, not alternation) | AC1 changed to `grep -cE` | Resolved |
| CR-P0-3 | No SAFETY keyword count AC | AC10 added: baseline 44, post >= 44 | Resolved |
| ARCH-P0-1 | verdict_shape ecosystem has no migration path | FR4 rewritten: Rubric Evaluation Protocol section preserves all SAFETY logic; P1 step 6 details migration | Resolved |
| ARCH-P0-2 | §9.1 empty → silent pass | FR7 added: empty guard → BLOCK; AC13 verifies | Resolved |
| ARCH-P0-3 | judge≠producer enforcement lost | FR4 explicitly preserves Judge_Not_Producer in Rubric Eval Protocol; AC12 verifies 5 VIOLATIONs | Resolved |
| CR-P1-1 | Blake deliverable routing understated | P3 rewritten: explicit unified AC-driven verification | Resolved |
| CR-P1-2 | tad-handoff/SKILL.md missing from §7 | File #6 added; P5 added | Resolved |
| CR-P1-3 | step0_6 task_type=deliverable fate unclear | FR4 clarifies: enum value preserved, template routing changed | Resolved |
| CR-P1-4 | AC5 non-discriminative | AC5 changed to section-scoped grep | Resolved |
| CR-P1-5 | Gate 4 subagent requirements at risk | FR5 rewritten: structural subagents preserved, only business checklist AC-driven | Resolved |
| ARCH-P1-1 | Alex detection fragile for mixed projects | P2 step 2 rewritten: task-scoped not project-scoped detection | Resolved |
| ARCH-P1-2 | Gate 4 symmetry conflicts with role boundary | FR5 rewritten: hybrid model (structural + AC) | Resolved |
| ARCH-P1-3 | Gate3_Verdict_Marker telemetry gap | P1 step 7 added: universal post-step; AC14 verifies | Resolved |
| ARCH-P1-4 | AC9 weak regression gate | AC9 expanded: includes non-dev examples too | Resolved |

---

## 10. Important Notes

### 10.1 SAFETY: Preserved Blocks — Gate Infrastructure
The following Gate 3 blocks MUST be preserved byte-exactly (they are Gate infrastructure, not task-type-specific):
- Prerequisite check (completion report)
- Git Commit Verification
- Risk Translation (Cognitive Firewall)
- Knowledge Assessment
- Post_Pass_Actions (NEXT.md update)

### 10.2 SAFETY: Preserved Blocks — Rubric Evaluation Protocol (migrated from Deliverable Branch)
The following SAFETY blocks from the current Deliverable Branch MUST be migrated to the new `## Rubric Evaluation Protocol` section with **constraint text byte-exact preserved**:
- **Judge_Not_Producer** — 5 VIOLATION entries (lines 431-445). Every `VIOLATION:` line must survive verbatim.
- **Verdict_Mapping** — weighted/categorical/checklist rules + `decoupling_firewall` (ORDER OF EMISSION, CONCLUSION-NEUTRAL CRITERIA, SWAP TEST). The `rigor_independence` warning must survive.
- **Rubric_Resolution** — precedence chain (frontmatter > registry > BLOCK) + `verdict_shape_guard` (unknown shape → BLOCK).
- **checklist malformed_guard** — ≥1 REQUIRED item check → BLOCK if all optional.
- **evidence_independence** — judge scores from substance, not artifact self-claims.
- **output_format_constraint** — P-label heading prohibition (parser self-trigger avoidance).
- **Gate3_Verdict_Marker** — but migrated to a **universal post-step** (all task_types, not deliverable-only).

**Pre-implementation baseline**: `grep -cE 'BLOCKING|MANDATORY|VIOLATION' .claude/skills/gate/SKILL.md` = 44. Post-implementation MUST be >= 44 (AC10).

### 10.3 Backward Compatibility
Dev projects MUST continue to get tsc/test/lint checks. The mechanism changes (from hardcoded Gate check to Alex-generated AC), but the user-visible behavior does not.

### 10.4 Deliverable Branch Removal Strategy
The `## Gate 3 — Deliverable Branch` and `## Gate 4 — Deliverable Branch` blocks are REMOVED as **routing branches**. Their SAFETY logic is migrated to the Rubric Evaluation Protocol (§10.2). Their routing logic ("IF task_type=deliverable → use this block") is eliminated because §9.1 is now the universal verification source for all task_types.

`task_type: deliverable` as a frontmatter enum value is PRESERVED — it signals "this handoff's §9.1 contains rubric/judge ACs" and can trigger the Rubric Evaluation Protocol section in Gate.

### 10.5 Anti-Pattern Warning
- ❌ Do NOT create a new configuration file for "project type" — Alex detects from task scope
- ❌ Do NOT add a new frontmatter field for "gate mode" — §9.1 content IS the gate mode
- ❌ Do NOT make Gate 3 "optional" for non-dev projects — it becomes universal via AC
- ❌ Do NOT delete SAFETY keywords during migration — byte-exact preservation required (AC10, AC12)
- ❌ Do NOT make Gate 4 subagent requirements AC-driven — they are structural role enforcement

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Gate verification source | Hardcoded / §9.1 driven / config-based | §9.1 driven | §9.1 already exists and has the right format; no new concepts needed |
| 2 | Dev protection mechanism | Hardcoded in Gate / Alex auto-generates / Project config | Alex auto-generates | Keeps Gate universal; Alex already knows project context from Socratic |
| 3 | Deliverable track handling | Keep separate / Absorb into §9.1 / Deprecate | Absorb | Reduces code paths; rubric eval becomes a type of AC, not a Gate branch |
| 4 | Scope | Gate 3 only / Gate 3+4 / Gate 3+4+template | All three | User confirmed "全部"; consistent architecture across all Gates |

---

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/universal-gate-ac-driven/cr-review.md
  - .tad/evidence/reviews/blake/universal-gate-ac-driven/arch-review.md
gate_verdicts:
  - .tad/evidence/reviews/blake/universal-gate-ac-driven/gate3-verdict.md
completion:
  - .tad/active/handoffs/COMPLETION-20260607-universal-gate-ac-driven.md
knowledge_updates: []
```
