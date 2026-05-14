---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: [".claude/skills/alex", ".tad/templates", ".tad/guides"]
gate4_delta: []
---

# Handoff: Research Adversarial Challenge Layer

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-14
**Project:** TAD
**Task ID:** TASK-20260514-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-14 (pending expert review)

---

## 1. Executive Summary

TAD 的研究 pipeline (\*research-plan) 功能齐全但执行深度不足。核心问题：整条 pipeline 是"顺着走"的——提问 → 回答 → 记录 → 下一个——没有任何环节在挑战"这个回答够不够好"。

本次改动在研究 pipeline 的 3 个关键点插入 **adversarial challenge 层**，使用 Codex + Gemini 双模型并行挑战 Alex 的研究产出。机制类似 product-thinking pressure-test 的 Anti-Sycophancy 合同。

**实验模式**：前 3 次真实研究同时调用两个模型，记录所有 challenge 过程和结果，然后用户决定保留哪个或两个都保留。

## 2. Problem Statement

用户反馈（2026-05-14 \*discuss）：
- 研究流于表面，到一个浅层就停下来
- Alex 不习惯先规划、分解目标、再用分支问题深入
- 研究产出不足以支撑决策——感觉只是"有限的问答"
- 所有功能"凑合能用"但没有一个真正好用

根因：pipeline 缺少 adversarial review 层。现有 saturation detection / dynamic follow-up 只检查"有没有新信息"，不检查"已有信息经不经得起推敲"。

## 3. Requirements

### FR1: Phase 0c — 挑战研究计划
- 在 Phase 0 (Research Plan) 完成后、Phase 1 (Sourcing) 开始前插入
- ⚠️ **用户确认门控**（解决 NOT_via_alex_auto 约束）：每次调用前 AskUserQuestion "运行 Codex+Gemini adversarial challenge? [执行/跳过]"
- 把 Phase 0 产出的研究问题发送给 Codex + Gemini 并行审视
- Challenge 维度：问题是否够尖锐、是否遗漏关键角度、是否有隐含假设
- 输出：refined_questions（修正后的问题列表）或 PASS（原始问题足够好）
- Alex 读取 challenge 结果后修正 Question Tree，再进入 Phase 1

### FR2: Phase 4c — 挑战研究结论（核心）
- 精确插入点：Phase 4 Step 3 (Save findings to `{date}-ask-findings.md`) 完成后、Phase 4.5 (Paper Extraction) 之前。此时所有 ask 结果已写入文件，challenge 层有具体文件可发送
- ⚠️ 不是 Phase 4b 内部（4b 是 per-question sub-loop）——challenge 在所有 question 完成后批量执行
- ⚠️ **用户确认门控**：同 FR1，AskUserQuestion 确认后再调用外部模型
- 把所有 Phase 4 findings 打包发送给 Codex + Gemini 并行审视
- Challenge 5 维度：
  1. **证据充分性**：哪些结论只有 1 个来源？标记 WEAK
  2. **角度完整性**：哪些视角完全没被探索？
  3. **假设可靠性**：研究隐含了哪些未验证的前提？
  4. **因果推理**：哪里把相关性当成了因果？
  5. **决策支撑力**：基于这些发现做决策，哪里信息不足？
- 评级：INSUFFICIENT / ADEQUATE / STRONG
- **通过条件：两个模型都给 ADEQUATE 或 STRONG**
- INSUFFICIENT → 挑战产出的 gap list 变成新的研究问题 → 回到 Phase 4 ask → 再挑战
- **最多 2 轮挑战**（防死循环）
- 2 轮后仍 INSUFFICIENT → WARN 用户 + 记录未解决的弱点 + 继续

### FR3: Phase 5b — 挑战行动建议
- 精确插入点：Phase 5 Step 1 (extract ACs from findings) 完成后、Step 2 (display to user) 之前
- ⚠️ Challenge 必须在用户看到 AC 列表之前运行——用户看到的是已标注 support_strength 的 AC，不是先 approve 再被推翻
- ⚠️ **用户确认门控**：同 FR1
- 把 extracted ACs + 对应的 research findings 发给 Codex + Gemini
- Challenge 维度：研究是否真的支持这个行动建议、有无逻辑跳跃
- 输出：每个 AC 的 support_strength (STRONG / WEAK / UNSUPPORTED)
- UNSUPPORTED 的 AC 标记为 ⚠️ 需要更多研究或降级为"假设"
- Step 2 显示给用户时每个 AC 旁边附带 support_strength 标签

### FR4: 双模型并行调用机制
- 每个 challenge 点顺序调用 Codex → Gemini（顺序更稳定，总增加 ~60s）
- ⚠️ **Preflight（pipeline 开头执行一次，不重复）**：
  ```
  codex_available=$(command -v codex >/dev/null 2>&1 && echo 1 || echo 0)
  gemini_available=$(command -v gemini >/dev/null 2>&1 && echo 1 || echo 0)
  ```
- **Codex 调用模式**（修复 CR-P0-1：stdin 是 data，positional arg 是 instruction）：
  ```bash
  # 写入 temp file（避免 shell 变量扩展问题）
  cat .tad/templates/research-challenge-prompt.md | sed -n '/<!-- BEGIN findings -->/,/<!-- END findings -->/p' > /tmp/tad-challenge-prompt.md
  echo "---" >> /tmp/tad-challenge-prompt.md
  cat .tad/evidence/research/{slug}/{date}-ask-findings.md >> /tmp/tad-challenge-prompt.md
  
  codex_result=$(cat /tmp/tad-challenge-prompt.md | codex exec --full-auto --skip-git-repo-check \
    "Execute the adversarial research challenge. Output your review following the format in the input." \
    2>/dev/null)
  codex_exit=$?
  ```
- **Gemini 调用模式**（修复 BA-P0-2：temp file + printf 避免 echo 扩展）：
  ```bash
  gemini_result=$(cat /tmp/tad-challenge-prompt.md | gemini -p \
    "Respond to the adversarial review request. Follow the output format exactly." \
    2>/dev/null)
  gemini_exit=$?
  ```
- **Exit code 检查后才保存**（修复 BA-P1-5）：
  ```bash
  if [ $codex_exit -eq 0 ] && [ -n "$codex_result" ]; then
    printf '%s' "$codex_result" > .tad/evidence/research/{slug}/challenge-{phase}-codex.md
  else
    echo "UNAVAILABLE: Codex exit $codex_exit" > .tad/evidence/research/{slug}/challenge-{phase}-codex.md
  fi
  # Same pattern for Gemini
  ```
- 两份结果保存到 `.tad/evidence/research/{slug}/challenge-{phase}-codex.md` 和 `challenge-{phase}-gemini.md`
- `{slug}` 是研究项目的 filesystem-safe topic identifier，与 Phase 3/4 evidence 路径一致

### FR5: 实验记录
- 每次 challenge 记录到 `.tad/evidence/research/{slug}/challenge-log.md`
- 格式：challenge point + model + rating + key gaps found + whether gap led to new research
- 3 次研究后用户可对比：哪个模型找到了更有价值的 gap

### NFR1: 增加的延迟预算
- 每个 challenge 点增加 ~30-60s（Codex ~15-30s + Gemini ~10-20s）
- 3 个 challenge 点 × ~45s = 整个 pipeline 增加 ~2-3 分钟
- 可接受：研究质量 > 速度

### NFR2: 优雅降级
- Codex 不可用（quota/网络）→ 只用 Gemini，WARN
- Gemini 不可用 → 只用 Codex，WARN
- 两个都不可用 → 跳过 challenge，WARN "adversarial review unavailable"
- 单模型时通过条件降级为：该模型 ADEQUATE+

## 4. Technical Design

### 4.1 Challenge Prompt Template

新建 `.tad/templates/research-challenge-prompt.md`，使用 **多 section 分隔符格式**（修复 CR-P2-3），3 个独立 prompt 变体。Blake 用 `sed -n '/<!-- BEGIN {variant} -->/,/<!-- END {variant} -->/p'` 提取对应变体。

文件结构：

```markdown
<!-- BEGIN plan -->
CRITICAL FORMAT: 你的输出第一行必须且仅包含以下三个词之一：
INSUFFICIENT
ADEQUATE
STRONG
第一行不允许有其他任何内容。然后空一行，再开始正文分析。
输出语言：中文。

你是一个严苛的研究计划审稿人。你的角色是挑战以下研究问题的质量，不是认同它们。
你的默认立场是：这些问题不够好，直到被说服为止。

从 3 个维度审视：
1. 尖锐度：问题是否足够具体？能否用"是/否"回答的问题太弱
2. 角度覆盖：有没有被遗漏的关键视角？
3. 隐含假设：问题本身预设了什么？这些预设有证据吗？

评级标准：
- INSUFFICIENT: 问题集有重大盲区或过于宽泛
- ADEQUATE: 覆盖了核心方向，minor gaps 可接受
- STRONG: 问题集尖锐、全面、无隐含假设

[正文 output format 同 findings variant]

## 修正后的问题列表（仅 INSUFFICIENT 时填写）
- Q1: [修正后的问题]
<!-- END plan -->

<!-- BEGIN findings -->
CRITICAL FORMAT: 你的输出第一行必须且仅包含以下三个词之一：
INSUFFICIENT
ADEQUATE
STRONG
第一行不允许有其他任何内容。然后空一行，再开始正文分析。
输出语言：中文。

你是一个严苛的研究审稿人。你的角色是挑战以下研究发现的质量，不是认同它们。
你的默认立场是：这些研究不够好，直到被说服为止。

从 5 个维度审视：
1. 证据充分性：每个结论有几个独立来源支撑？只有 1 个来源的标记 WEAK_EVIDENCE
2. 角度完整性：列出至少 2 个完全没被探索的视角
3. 假设可靠性：找出研究暗含的前提假设，评估每个是否有证据支撑
4. 因果推理：哪些地方把相关性当因果？哪里缺少机制解释？
5. 决策支撑力：如果要基于这些发现做出"是否投入资源"的决策，缺少什么信息？

评级标准：
- INSUFFICIENT: ≥2 个维度有严重问题
- ADEQUATE: ≤1 个维度有严重问题，其余可接受
- STRONG: 所有维度都充分

输出格式：
## 维度评估
### 1. 证据充分性
[具体哪些结论 WEAK，为什么]
### 2. 角度完整性
[缺失的视角]
### 3. 假设可靠性
[隐含假设列表]
### 4. 因果推理
[逻辑漏洞]
### 5. 决策支撑力
[做决策缺什么]

## 需要补充研究的问题（仅 INSUFFICIENT 时填写）
- Q1: [具体问题 + 搜索方向]
<!-- END findings -->

<!-- BEGIN actions -->
CRITICAL FORMAT: 你的输出第一行必须且仅包含以下三个词之一：
INSUFFICIENT
ADEQUATE
STRONG
第一行不允许有其他任何内容。然后空一行，再开始正文分析。
输出语言：中文。

你是一个严苛的行动建议审稿人。你的角色是挑战研究发现与行动建议之间的逻辑链。
你的默认立场是：这些行动建议缺乏研究支撑，直到被说服为止。

对每个行动建议评估：
1. 研究是否直接支持这个建议？还是有逻辑跳跃？
2. 研究发现的条件是否适用于目标场景？
3. 有没有研究中的 counter-evidence 被忽略？

为每个建议标记：STRONG / WEAK / UNSUPPORTED

输出格式：
| # | 行动建议 | Support Strength | 理由 |
<!-- END actions -->
```

### 4.2 插入点在 Alex SKILL 中的位置（精确行号参考）

**Phase 0c**: 在 `research_plan_protocol.execution.step4.a0` Step 3 (success criteria) 之后、`step4.a` (确定 target notebook) 之前。用户确认 plan 后、sourcing 开始前。

**Phase 4c**: 在 Phase 4 Step 3 "Save findings" (SKILL ~line 1295-1297, 写入 `{date}-ask-findings.md`) 之后、`e_5` Phase 4.5 "Structured Paper Extraction" (SKILL ~line 1299) 之前。⚠️ 不在 Phase 4b 内部——4b 是 per-question sub-loop，4c 是所有 question 完成后的批量挑战。

**Phase 5b**: 在 PHASE 5 Step 1 "extract engineering-actionable items" 之后、Step 2 "Display extracted ACs to user" (AskUserQuestion) 之前。用户看到的 AC 列表已经带有 support_strength 标注。

### 4.3 调用模式

见 FR4 中的完整调用模式。关键要点：
- 用 temp file 组装 prompt + data，避免 shell 变量扩展问题
- `sed -n '/<!-- BEGIN {variant} -->/,/<!-- END {variant} -->/p'` 提取 prompt 变体
- stdin 是 data，positional arg 是 instruction（不混用）
- exit code 检查后才保存（UNAVAILABLE 标记 for 降级）
- `printf '%s'` not `echo`（二进制安全）
- Codex 加 `--skip-git-repo-check`（cwd 可能非 git 目录）

### 4.4 Rating Extraction Contract（修复 BA-P0-3）

**Prompt 中的 format enforcement**（加到每个 prompt 变体的最前面）：
```
CRITICAL FORMAT: 你的输出第一行必须且仅包含以下三个词之一：
INSUFFICIENT
ADEQUATE
STRONG
第一行不允许有其他任何内容。然后空一行，再开始正文分析。
```

**Extraction 机制**（Alex 用 Bash grep 提取，不依赖 LLM 判断）：
```bash
rating=$(head -5 challenge-{phase}-{model}.md | grep -oE 'INSUFFICIENT|ADEQUATE|STRONG' | head -1)
if [ -z "$rating" ]; then
  rating="INSUFFICIENT"  # fail-closed: 无法解析 → 视为不通过
fi
```

**Case-insensitive 兜底**：如果 head-5 grep 无结果，再试 `grep -ioE` 全文搜索。仍无结果 → INSUFFICIENT。

**空输出处理**：如果 challenge file 为 0 bytes 或内容为 "UNAVAILABLE:"，视为该模型不可用 → NFR2 单模型降级。

### 4.5 循环逻辑

Alex 提取两份 rating 后：
- **两个都 ADEQUATE+** → Phase 4c PASS。即使 PASS，Alex 仍读两份报告的维度级发现，附加为 "Advisory: [model] flagged [gap] as potential weakness" 到 findings 文件末尾
- **任一 INSUFFICIENT** → 从两份报告中提取 "需要补充研究的问题" section → 合并（去重）→ 进入 **lightweight re-ask 循环**
- **Lightweight re-ask（不是完整 Phase 4 重跑）**：仅用 raw notebooklm CLI 逐个 ask gap questions → 结果 append 到现有 findings 文件 → 再次 Phase 4c（第 2 轮）。不触发 Phase 4b (CRAG)、不触发 Step 2.5 (Adaptive Seeds)、不触发嵌套 Phase 4c
- **第 2 轮后仍 INSUFFICIENT** → WARN 用户，显示未解决弱点，记录到 challenge-log，继续 Phase 4.5/5
- **Max 2 rounds per research item**（不是全局计数器——每次 \*research-plan 执行独立计数）

## 5. Files to Create

| # | File | Purpose |
|---|------|---------|
| 1 | `.tad/templates/research-challenge-prompt.md` | Challenge prompt 模板（3 个变体：plan/findings/actions） |

## 6. Files to Modify

| # | File | Change | Lines (est.) |
|---|------|--------|-------------|
| 1 | `.claude/skills/alex/SKILL.md` | 在 research_plan_protocol 中插入 Phase 0c、4c、5b 三个 challenge 步骤 | +150 lines |
| 2 | `.tad/guides/tool-quick-reference-alex.md` | 添加 challenge 调用模式的快速参考 | +15 lines |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` (read lines 1030-1250, research_plan_protocol Phase 0-5)
- `.tad/guides/tool-quick-reference-alex.md` (read lines 1-50, Codex/Gemini CLI patterns)

## 7. Micro-Tasks

| # | Task | Files | Est. |
|---|------|-------|------|
| T1 | 创建 challenge prompt 模板（3 变体） | templates/research-challenge-prompt.md | 20 min |
| T2 | SKILL 插入 Phase 0c（计划挑战） | alex/SKILL.md | 15 min |
| T3 | SKILL 插入 Phase 4c（结论挑战 — 核心） | alex/SKILL.md | 30 min |
| T4 | SKILL 插入 Phase 5b（行动挑战） | alex/SKILL.md | 15 min |
| T5 | 更新 tool-quick-reference-alex.md | guides/ | 5 min |
| T6 | 创建 challenge-log 模板结构 | evidence 目录约定 | 5 min |

## 8. Risk Analysis

| Risk | Mitigation |
|------|-----------|
| Codex/Gemini 可能不可用 | NFR2 优雅降级（单模型或跳过） |
| Challenge 永远返回 INSUFFICIENT | 最多 2 轮硬上限 |
| Challenge prompt 过于严格导致研究无法通过 | ADEQUATE 标准允许 ≤1 维度有问题 |
| Codex stderr 噪音干扰结果解析 | exit code 为 source of truth，stderr 忽略（已验证） |
| 增加 2-3 分钟延迟 | NFR1 已确认可接受 |

## 9. Acceptance Criteria

| AC# | Criterion | Verification |
|-----|-----------|-------------|
| AC1 | research-challenge-prompt.md 存在，包含 3 个变体（plan/findings/actions） | `grep -c "challenge_type" .tad/templates/research-challenge-prompt.md` ≥ 3 |
| AC2 | Alex SKILL research_plan_protocol 包含 Phase 0c 步骤 | `grep -c "Phase 0c\|phase_0c\|challenge.*plan" .claude/skills/alex/SKILL.md` ≥ 1 |
| AC3 | Alex SKILL research_plan_protocol 包含 Phase 4c 步骤 | `grep -c "Phase 4c\|phase_4c\|challenge.*findings" .claude/skills/alex/SKILL.md` ≥ 1 |
| AC4 | Alex SKILL research_plan_protocol 包含 Phase 5b 步骤 | `grep -c "Phase 5b\|phase_5b\|challenge.*action" .claude/skills/alex/SKILL.md` ≥ 1 |
| AC5 | Phase 4c 包含双模型通过条件：两个都 ADEQUATE+ | `grep "ADEQUATE" .claude/skills/alex/SKILL.md` 出现在 4c 上下文中 |
| AC6 | Phase 4c 包含 max 2 轮硬上限 | `grep -c "max.*2.*round\|2.*challenge.*round" .claude/skills/alex/SKILL.md` ≥ 1 |
| AC7 | 优雅降级：Codex/Gemini 不可用时 WARN 并跳过 | SKILL 包含 fallback 逻辑 |
| AC8 | Challenge 输出路径：`.tad/evidence/research/{slug}/challenge-{phase}-{model}.md` | SKILL 中指定此路径 |
| AC9 | tool-quick-reference-alex.md 包含 challenge 调用模式 | `grep "challenge" .tad/guides/tool-quick-reference-alex.md` |

### 9.1 Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence |
|------|-------------------|-------------------|
| AC1 | `grep -c "challenge_type" .tad/templates/research-challenge-prompt.md` | ≥ 3 |
| AC2-AC4 | grep SKILL.md for phase markers | Each ≥ 1 |
| AC5 | Read Phase 4c section, confirm dual-model pass logic | Both ADEQUATE+ |
| AC6 | Read Phase 4c, confirm round limit | max 2 rounds |
| AC7 | Read fallback section | WARN + skip pattern |
| AC8 | Read challenge output path | matches spec |
| AC9 | grep tool-quick-reference | challenge mentioned |

### 9.2 Expert Review — Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | CR-P0-1: Codex stdin/prompt conflict | FR4 invocation rewritten with temp file + positional instruction | Resolved |
| code-reviewer | CR-P0-2: Phase 4c insertion point inside per-question loop | FR2 + §4.2 precise insertion point after Step 3 save | Resolved |
| code-reviewer | CR-P0-3: Phase 5b UX — user approves before challenge | FR3 moved challenge before Step 2 display | Resolved |
| backend-architect | BA-P0-1: NOT_via_alex_auto constraint violation | FR1/FR2/FR3 all add AskUserQuestion gate | Resolved |
| backend-architect | BA-P0-2: Gemini large payload shell expansion | FR4 temp file approach + printf | Resolved |
| backend-architect | BA-P0-3: Rating extraction no parsing spec | §4.4 Rating Extraction Contract + grep + fail-closed | Resolved |
| code-reviewer | CR-P1-1: Rating parse under-specified | §4.4 covers (merged with BA-P0-3) | Resolved |
| code-reviewer | CR-P1-2: echo shell expansion risk | FR4 uses printf '%s' | Resolved |
| code-reviewer | CR-P1-3: Preflight check timing | FR4 preflight at pipeline start | Resolved |
| code-reviewer | CR-P1-5: Loop-back scope ambiguous | §4.5 lightweight re-ask (no Phase 4b/Step 2.5/nested 4c) | Resolved |
| backend-architect | BA-P1-2: Dimension findings even on PASS | §4.5 "Advisory" append on PASS | Resolved |
| backend-architect | BA-P1-5: Exit code check before saving | FR4 exit code gate | Resolved |
| code-reviewer | CR-P2-3: Template multi-section format | §4.1 uses BEGIN/END delimiters + sed extraction | Resolved |
| backend-architect | BA-P2-4: --skip-git-repo-check for Codex | FR4 added flag | Resolved |
| code-reviewer | CR-P1-4: sed global flag | FR4 uses sed -n section extraction, no {challenge_type} substitution | Resolved |
| backend-architect | BA-P1-4: Output language specification | §4.1 all 3 variants include "输出语言：中文" | Resolved |

**Review verdict**: CONDITIONAL PASS → all P0s resolved → **PASS**

## 10. Important Notes

### 10.1 Anti-Sycophancy 是核心设计原则
Challenge prompt 必须以"默认假设研究不够好"作为立场。如果 prompt 写成"请审视这些发现"（中性语气），Codex/Gemini 会倾向于说"看起来不错"——跟 Claude 自己审视自己一样无用。

### 10.2 实验模式优先
前 3 次真实研究是实验——两个模型都调，所有过程文件都保存。不要优化掉任何一个模型的调用，即使看起来其中一个更好。数据先收集完再做决策。

### 10.3 Codex stdin 注意事项
`codex exec --full-auto` 接受 stdin，但 `--commit` 和 positional prompt 互斥。用 `cat file | codex exec --full-auto "instructions"` 模式。stderr 的 `failed to record rollout items` 是 benign noise，忽略。

### 10.4 Gemini 只读
`gemini -p` 不能写文件。Challenge report 的保存由 Alex（Bash tool echo/redirect）完成，不是 Gemini 自己写。

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Challenge 粒度 | per-question / per-phase / end-only | per-phase | 平衡深度和速度 |
| 2 | 挑战工具 | Codex only / Gemini only / both | both (experiment) | 先收数据再决策 |
| 3 | 通过条件 | any ADEQUATE / both ADEQUATE / Alex judges | both ADEQUATE+ | 严格——防止单模型偏见 |
| 4 | 范围 | 4c only / 0c+4c / 0c+4c+5b | 0c+4c+5b | 三个点一起做 |
| 5 | 循环上限 | 1 round / 2 rounds / unlimited | max 2 rounds | 防死循环 |

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Gemini CLI `-p` 是只读模式** (architecture.md 2026-05-03): 不能写文件、不能执行命令
- **Codex stderr benign noise** (architecture.md 2026-05-03): `failed to record rollout items` 忽略，用 exit code 判断成功
- **Codex `--commit` 与 positional prompt 互斥** (architecture.md 2026-05-03): 用 stdin pipe
- **Venv 绝对路径** (architecture.md 2026-05-03): AI agent 调用 CLI 工具必须用绝对路径
- **Cross-Model Prompt Symmetry** (architecture.md 2026-05-03): 给两个模型的 prompt 必须对称，否则差异归因错误

---

## Blake Instructions

这是一个 Standard TAD handoff。核心工作是：
1. 创建 challenge prompt 模板文件
2. 在 Alex SKILL.md 的 research_plan_protocol 中插入 3 个 challenge 步骤（0c/4c/5b）
3. 更新 tool-quick-reference

改动范围集中在 Alex SKILL 的 research_plan_protocol 区域（约 lines 1030-1300）。不需要改 Blake SKILL、hooks、或 config。

⚠️ 关键约束：Challenge prompt 的语气必须是 adversarial（"默认假设不够好"），不能写成中性的 review。参考 product-thinking pressure-test 的 Anti-Sycophancy Rules。
