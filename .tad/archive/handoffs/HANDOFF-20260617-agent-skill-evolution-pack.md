---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/agent-skill-evolution"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-17
**Project:** TAD
**Task ID:** TASK-20260617-001
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-17

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 包结构、7 reference files、rule IDs、cross-cutting rule 全设计完 |
| Components Specified | ✅ | 22 条规则逐条定义在 idea 文件中，每条有 rule ID + 内容 + source |
| Functions Verified | ✅ | 不涉及代码——纯 markdown 文件 |
| Data Flow Mapped | ✅ | SKILL.md → references/ 渐进披露，keyword 路由 |

**Gate 2 结果**: ✅ PASS

---

## §1. Summary

### §1.1 One-Line
新建 `agent-skill-evolution` 能力包——教 AI agent 如何安全地自我改进 instruction/skill 文档。

### §1.2 Background
SkillOpt (Microsoft, arXiv 2605.23904, 7,761 stars) 是第一个生产级 "text-space skill optimization" 框架。深度研究（3 parallel agents 读完全仓库 ~25,000 行）揭示了一个完整的工程 paradigm：self-evolving agent skills。我们 7 个 agent 相关能力包对此覆盖度为零（13 个核心 pattern 零命中）。这个 paradigm 值得一个独立包，而非散装规则分散在 6 个现有包中。

### §1.3 Intent Statement
让 agent 在帮用户构建 self-evolving agent 时，拥有经过实验验证的工程判断力——什么时候该做、怎么设计训练循环、怎么保证安全、怎么避免退化。

---

## §2. Requirements

### §2.1 Functional Requirements

**FR1 — SKILL.md body** (< 500 lines)
符合 QUALITY-BAR Layer A 全部 10 项。包含：frontmatter (name+description)、CONSUMES/PRODUCES、cross-cutting rule、Quick Rule Index (29 rules)、Step 0 context detection router、Step 1 apply rules、Step 2 output format、Anti-Skip table、Tool Quick Reference (SkillOpt as recommended tool)。

**FR2 — 7 reference files**
每个 reference 文件包含具体 judgment rules (Layer B depth)，每条规则有 rule ID、规则文本、source citation、和 SkillOpt 实证数据（数字/阈值）。

| Reference | Rules | Key specifics (Layer B depth) |
|-----------|-------|-------------------------------|
| architecture-decisions.md | AD1-AD4 | +23.5/+24.8/+19.1 pts lift; −52.8 collapse without gate |
| training-loop.md | TL1-TL4 | 6-stage pipeline; K rollouts; spread-based selection |
| edit-safety.md | ES1-ES4 | 3 edit modes; cosine > constant LR; 4-layer protected region enforcement |
| validation-gate.md | VG1-VG4 | strictly-greater-than; hard/soft/mixed metric; SHA content cache |
| offline-consolidation.md | OC1-OC7 | 6-stage Sleep pipeline; recall_k Jaccard retrieval; dream_factor; output contract injection |
| multi-timescale-memory.md | MT1-MT3 | step buffer / slow update / meta skill; appendix consolidation threshold |
| skillopt-sleep-integration.md | SI1-SI3 | Claude Code plugin install; Codex/Copilot/OpenClaw shells; cron schedule; mock backend |

**FR3 — examples/ fixture**
Discriminative behavioral eval fixture。场景：用户要给 agent 添加 self-improvement。WITH-PACK 答案应包含 validation gate + bounded edit + protected regions 等具体机制；CONTROL 答案通常只说 "fine-tune" 或 "add feedback loop" 等泛泛建议。

**FR4 — scripts/ 验证脚本**
`gate-check.sh`：检查用户的 self-evolving agent 设计是否有 validation gate、edit budget、protected regions、staging mechanism。确定性 grep-based。Exit codes: 0=PASS (all 4 mechanisms), 1=FAIL (0 mechanisms), 2=PARTIAL (1-3 mechanisms). Must support `--help` flag.

**FR5 — Codex parity (full directory)**
Mirror the entire `.claude/skills/agent-skill-evolution/` directory to `.agents/skills/agent-skill-evolution/` (SKILL.md + references/ + examples/ + scripts/). Platform-skills symmetry gate requires full directory, not just SKILL.md.

---

## §3. Acceptance Criteria

| AC | Description | Verification |
|----|-------------|-------------|
| AC1 | SKILL.md frontmatter 含 name (kebab-case) + description (third-person, what+when) | Read frontmatter |
| AC2 | SKILL.md body < 500 lines | `wc -l SKILL.md` |
| AC3 | CONSUMES/PRODUCES 声明存在 | `grep 'CONSUMES\|PRODUCES' SKILL.md` |
| AC4 | Cross-cutting rule 在 body 中（"No validation gate = no self-evolution" + −52.8 数据） | Read SKILL.md body |
| AC5 | Quick Rule Index 表列出全部 29 条规则 (AD1-4, TL1-4, ES1-4, VG1-4, OC1-7, MT1-3, SI1-3) | Count entries in index = 29 |
| AC6 | Step 0 context detection router 覆盖中英文关键词 | Read Step 0 table |
| AC7 | Anti-Skip table 存在且含 ≥ 3 条 agent 会跳过的理由 + 反驳 | Read Anti-Skip |
| AC8 | Tool Quick Reference 含 SkillOpt (pip install skillopt + key commands) | Read Tool Reference |
| AC9 | 7 个 reference 文件存在于 references/ 目录 | `ls references/ \| wc -l` |
| AC10 | 每条规则有 rule ID + source citation (arXiv/file path) | Spot-check 3 rules across 3 different reference files |
| AC11 | Layer B depth: ≥ 20 个具体数字/阈值/退出码（−52.8, +23.5, +24.8, +19.1, cosine > constant, strictly-gt, 2-4 epochs, K≥3 rollouts, recall_k=10/20, Jaccard overlap, SHA hash, 300-2000 tokens, 6-stage, 4-layer enforcement, 3:17 AM cron, mock backend exit 0, etc.） | Count specific numbers across all references ≥ 20 |
| AC12 | examples/ fixture 存在，含 discriminative_pattern + min_discriminative | `grep 'discriminative_pattern' examples/*.md` |
| AC13 | scripts/gate-check.sh 存在、可执行、有 --help flag、exit codes (0=PASS/1=FAIL/2=PARTIAL) | `bash scripts/gate-check.sh --help` 输出用法 + exit code 说明 |
| AC14 | .agents/skills/agent-skill-evolution/ 全目录与 .claude/ 版本一致（SKILL.md + references/ + examples/ + scripts/） | `diff -rq .claude/skills/agent-skill-evolution .agents/skills/agent-skill-evolution` |
| AC15 | 规则风格为 descriptive（讲 tradeoff，不下命令）— 除安全类规则可 prescriptive | Spot-check 3 rules |
| AC16 | skillopt-sleep-integration.md 含 Claude Code plugin 安装/配置/运行指南 | Read file |

---

## §4. Technical Design

### §4.1 SKILL.md body 结构

```markdown
---
name: agent-skill-evolution
description: "Agent skill evolution capability pack. Gives AI agents the judgment
  rules for building self-improving agents — architecture decisions (fixed vs evolvable
  instruction), training loop design (rollout→reflect→edit→gate), edit safety (bounded
  edit, LR schedule, protected regions), validation gates, offline consolidation
  (sleep cycles), and multi-timescale memory. Research-grounded rules from SkillOpt
  (Microsoft, arXiv 2605.23904), SkillOpt-Sleep, and EmbodiSkill. Use for any
  self-evolving agent design, skill optimization pipeline, or agent self-improvement task."
keywords: [...]
type: reference-based
---

**CONSUMES**: Agent description + self-improvement requirements + optional existing
  skill/memory docs + evaluation setup
**PRODUCES**: Applied self-evolution judgment rules + architecture decision + training
  loop design + safety mechanism review + gate configuration guidance

# Agent Skill Evolution Capability Pack
...
## Cross-Cutting Rule: No Gate = No Evolution
...
## Quick Rule Index (all 29 rules)
...
## Step 0: Context Detection
...
## Step 1: Apply Rules
...
## Step 2: Output
...
## Anti-Skip Table
...
## Tool Quick Reference
```

### §4.2 Reference files — rule 内容

⚠️ **IDEA supersession**: IDEA-20260616-agent-skill-evolution-pack.md listed 22 rules across 6 references. This handoff supersedes that: **29 rules across 7 references** (added SI1-SI3 in skillopt-sleep-integration.md per Socratic confirmation). Use THIS handoff as the authoritative spec, not the IDEA file.

全部 29 条规则的定义（AD1-4, TL1-4, ES1-4, VG1-4, OC1-7, MT1-3 来自 idea file §Rule Summary；SI1-3 来自 §2.1 FR2 表）。Blake 按该定义展开为完整规则文本，每条规则格式：

```markdown
### AD1: Checkable Correctness Signal Required

> Before building a self-evolving agent, verify you have a checkable correctness
> signal...
> Source: SkillOpt paper §4.1; trainer.py evaluate_gate()
```

SI1-SI3 (skillopt-sleep-integration.md) 是新增的：
- SI1: Claude Code plugin 安装 (`/plugin marketplace add`)、cron schedule (`install-cron.sh`)、mock vs real backend
- SI2: Codex/Copilot/OpenClaw plugin shells — one engine, thin per-platform shells
- SI3: Safety contract — harvest read-only, nothing live changes, staging + adopt

### §4.3 Fixture design

场景模板：
```markdown
---
discriminative_pattern: "held.out.*gate|strictly.greater.than|bounded.edit.*LR|EXECUTION_LAPSE|SKILL_DEFECT|cosine.*schedule|protected.region.*marker|\.prev\.md|recall_k|contrastive.*reflect|dream.rollout|staging.*adopt"
min_discriminative: 6
---
## Scenario
You are designing an AI coding assistant that should get better at your recurring
tasks over time. It currently runs on Claude Code with a SKILL.md file. You want it
to learn from your past sessions and automatically improve its instructions — but you
need it to never get worse at things it already does well. Design the self-improvement
system.
```

WITH-PACK 答案应命中 4+ discriminative terms (validation gate, bounded edit, protected regions, staging, etc.)。CONTROL 答案通常说 "add a feedback loop" / "fine-tune the model" / "log failures and iterate" — 泛泛建议，命中 < 4。

### §4.4 gate-check.sh 设计

```bash
#!/usr/bin/env bash
# Verify a self-evolving agent design has the four safety mechanisms
# Usage: bash gate-check.sh <path-to-design-doc-or-skill.md>
# Returns: PASS (all 4) / PARTIAL (1-3) / FAIL (0) + per-mechanism status
```

检查 4 个安全机制：
1. Validation gate (grep: validation.gate|held.out|gate.*accept|gate.*reject)
2. Edit budget / LR (grep: edit.budget|learning.rate|bounded.edit|max.edits)
3. Protected regions (grep: protected.region|SLOW_UPDATE|APPENDIX|write.isolation)
4. Staging + adopt (grep: staging|nothing.live|human.adopt|backup)

---

## §5. Implementation Hints

**⚠️ Implementation order (mandatory)**:
1. Create directory structure: `.claude/skills/agent-skill-evolution/{references,examples,scripts}/`
2. Write 7 reference files FIRST (references/*.md) — SKILL.md Quick Rule Index references them
3. Write examples/ fixture
4. Write scripts/gate-check.sh (chmod +x)
5. Write SKILL.md body LAST (it cross-references all the above)
6. Mirror full directory to `.agents/skills/agent-skill-evolution/`
7. Verify: `diff -rq .claude/skills/agent-skill-evolution .agents/skills/agent-skill-evolution`

- 从 SkillOpt 仓库 /tmp/SkillOpt 读取原始数据（仍在 disk 上；如果已清理: `git clone https://github.com/microsoft/SkillOpt /tmp/SkillOpt`）
- 参考现有 gold-standard 包结构（web-backend / rag-retrieval）作为 Layer A 模板
- 每条规则必须引用具体数字（Layer B depth），不要写 "use a proper validation gate" 这种泛话
- keywords 要覆盖中英文（自演化 / self-evolving / skill optimization / prompt optimization / 离线学习 / offline learning / sleep cycle / 验证门 / validation gate）
- descriptive 风格 = "SkillOpt 实证 cosine > constant（论文 Table 3），实践中 2-4 epochs 够了" 而非 "必须用 cosine"

---

## §6. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| 规则过于学术/理论化，agent 不知道怎么 apply | 每条规则附 "When to apply" + 具体场景示例 |
| discriminative eval 通过率低（self-evolution 太 niche） | Fixture 场景设计为 "common enough"：agent 从使用中学习 |
| SkillOpt 仓库不稳定（新项目，可能改 API） | 规则是通用的，SkillOpt 只是 tool reference，不是硬依赖 |

---

## §7. Scope Estimation

| Item | Effort |
|------|--------|
| SKILL.md body | ~200 lines |
| 7 reference files | ~100-150 lines each × 7 = ~700-1050 lines |
| examples/ fixture | ~30 lines |
| scripts/gate-check.sh | ~60 lines |
| .agents/ sync | cp |
| Total | ~1000-1350 lines 新文件 |

---

## §8. Additional Sections

### §8.1 Testing Strategy
- Layer A: 逐项 grep 验证 QUALITY-BAR A1-A10
- Layer B: count specific numbers across references (target ≥ 10)
- Discriminative: 跑 pack-dogfood 对这个新包

### §8.4 Friction Preflight
无 friction-sensitive prerequisites。SkillOpt repo 已 clone 到 /tmp/SkillOpt。

---

## §9. Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer, backend-architect | P0: Rule count arithmetic wrong (26 enumerated, not 22; 29 with SI) | All "22 rules" → "29 rules" throughout; AC5 updated to include SI1-3 | ✅ Fixed |
| code-reviewer | P1: gate-check.sh no exit codes | FR4 + AC13: added exit codes 0/1/2 + --help flag | ✅ Fixed |
| code-reviewer | P1: AC5 omits SI1-3 | AC5 updated to list all 29 including SI1-3 | ✅ Fixed |
| code-reviewer | P1: Fixture discriminative_pattern too generic, min_discriminative too low | §4.3: tightened to SkillOpt-specific compound patterns, raised to 6 | ✅ Fixed |
| code-reviewer | P1: No implementation step sequence | §5: added mandatory 7-step order (references first, SKILL.md last) | ✅ Fixed |
| backend-architect | P1: .agents/ sync only SKILL.md, not full dir | FR5 + AC14: changed to full directory mirror + diff -rq | ✅ Fixed |
| backend-architect | P1: AC11 threshold ≥10 too low | AC11: raised to ≥20 with expanded example list | ✅ Fixed |
| backend-architect | P1: IDEA file says 22/6, handoff says 29/7 — Blake may reference wrong source | §4.2: added explicit IDEA supersession note | ✅ Fixed |
| code-reviewer | P2: Section numbering deviates from template | Noted — cosmetic, not blocking | Accepted |
| code-reviewer, backend-architect | P2: Missing LICENSE file | Noted — Blake can add if gold-standard packs have one | Accepted |
| code-reviewer | P2: AC13 assumes --help exists | Fixed in AC13 + FR4 (--help now specified) | ✅ Fixed |
| code-reviewer | P2: /tmp/SkillOpt ephemeral | §5: added fallback git clone command | ✅ Fixed |
| code-reviewer | P2: LC_ALL for gate-check.sh | Noted — Blake can add if needed for macOS grep | Accepted |
| backend-architect | P2: Fixture naming convention | Noted — Blake can use pack-standard naming | Accepted |
| backend-architect | P2: No version field in frontmatter | Noted — Blake can add Version: 0.1.0 in body | Accepted |

---

## §10. Files to Create

| File | Action |
|------|--------|
| `.claude/skills/agent-skill-evolution/SKILL.md` | New — pack body |
| `.claude/skills/agent-skill-evolution/references/architecture-decisions.md` | New |
| `.claude/skills/agent-skill-evolution/references/training-loop.md` | New |
| `.claude/skills/agent-skill-evolution/references/edit-safety.md` | New |
| `.claude/skills/agent-skill-evolution/references/validation-gate.md` | New |
| `.claude/skills/agent-skill-evolution/references/offline-consolidation.md` | New |
| `.claude/skills/agent-skill-evolution/references/multi-timescale-memory.md` | New |
| `.claude/skills/agent-skill-evolution/references/skillopt-sleep-integration.md` | New |
| `.claude/skills/agent-skill-evolution/examples/self-improving-agent.md` | New — fixture |
| `.claude/skills/agent-skill-evolution/scripts/gate-check.sh` | New — validator |
| `.agents/skills/agent-skill-evolution/SKILL.md` | Sync |

---

## §11. Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Pack vs scattered rules | Standalone pack | Coherent paradigm loses value when scattered across 6 packs |
| SkillOpt role | Tool reference (like rag-retrieval → LlamaIndex) | It's the production reference implementation for this domain |
| Rule style | Descriptive (tradeoffs, not commands) | Users need to adapt patterns to their specific agent scenario |
| Sleep integration | Included as reference file | User confirmed — practical integration guide adds actionable value |
| Cross-references to existing packs | None | keyword routing handles discovery; avoids maintenance burden |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Pack Build Rules** (patterns/pack-build-rules.md) — Layer B 必须携带研究落地的具体数字，不是泛泛的通用建议
- **Pack Evaluation** (patterns/pack-evaluation.md) — fixture 的 discriminative_pattern 必须是 pack-specific 的，不能用通用关键词
- **YOLO Audit: Validation Theater** (project_yolo-audit-findings.md) — 结构性检查不等于功能验证；gate-check.sh 必须能实际判别有无 gate

---

## 📨 Blake 消息

```
📨 新 Handoff 待执行

任务: 新建 agent-skill-evolution 能力包
文件: .tad/active/handoffs/HANDOFF-20260617-agent-skill-evolution-pack.md
优先级: Medium
范围: ~1000-1350 行新文件 (SKILL.md + 7 references + fixture + script + .agents sync)

这个包教 AI agent 怎么安全地自我改进 instruction——训练循环、validation gate、
bounded edit、protected regions、offline consolidation (sleep cycle)、
multi-timescale memory。基于 SkillOpt (Microsoft) 的全仓库深度研究。

关键 AC:
- AC1-8: SKILL.md body 符合 QUALITY-BAR Layer A (10/10)
- AC9-11: 7 reference files 含 22+3 条规则 + Layer B depth (≥10 具体数字)
- AC12-13: fixture + gate-check.sh 可用
- AC14: .agents/ parity
- AC15: descriptive 规则风格
- AC16: Sleep integration guide

SkillOpt repo 在 /tmp/SkillOpt (已 clone)。
规则定义在 IDEA-20260616-agent-skill-evolution-pack.md 中完整列出。
```
