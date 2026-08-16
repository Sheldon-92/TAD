# Idea: Blake Knowledge Assessment 增加 Skillify 候选提取

**ID:** IDEA-20260603-skillify-at-knowledge-assessment
**Date:** 2026-06-03
**Status:** promoted
**Scope:** medium
**Related:** IDEA-20260602-sac-thin-protocol-thick-tools

---

## Summary & Problem

TAD 的能力积累只有一条路径：自上而下的研究驱动（NotebookLM 研究 → Capability Pack），成本高（4-8h/pack）。缺少自下而上的路径——Blake 做完一件事后，成功的工作模式无法自动捕获为可复用能力，只能写 project-knowledge 条目（被动的"教训"，不是主动的"做法"）。

**核心想法**：在 Blake 的 Knowledge Assessment（Gate 3 完成后的现有反思点）扩展一步——除了"学到了什么教训"，还问"这个工作模式本身可以复用吗"。如果可以，生成 skillify candidate，走人类审批后成为轻量 project skill。

## Research Findings

### 1. GBrain Skillify（Garry Tan）— 重量级方案
- 来源：https://github.com/garrytan/gbrain/blob/master/skills/skillify/SKILL.md
- 7-phase 流程：Qualification → Audit → Scaffolding → Cross-Modal Eval → Tests → Resolver → E2E
- 11-item checklist（SKILL.md + code + cross-modal eval + unit test + integration test + LLM eval + resolver + resolver eval + check-resolvable + E2E + brain filing）
- 关键创新：**Phase 3 Cross-Modal Eval 在 test 之前**（"先证明质量，再用 test 锁定"——避免 lock-in mediocrity）
- 3 个不同厂商模型打分（GPT-4o / Claude / Gemini），5 维度均分 ≥7，单模型无 <5
- 代价：重，每个 skill $1-3 token 成本，需要外部 eval 基础设施
- **TAD 适用性**：checklist 理念可借鉴，但完整 11 项对 TAD 太重

### 2. Hermes Agent — 自学习方案
- 来源：https://www.mindstudio.ai/blog/what-is-hermes-agent-openclaw-alternative
- 5-stage learning loop：Task Execution → Outcome Evaluation → Skill Extraction → Skill Refinement → Skill Retrieval
- 触发条件：任务成功 + 方法非平凡（>5 tool calls）
- 自动写 skill 到 ~/.hermes/skills/，下次类似任务自动加载
- Skill 会自我修正：新方法反复优于旧方法时，skill 自动更新
- 隐式质量控制（需要反复验证，不是单次），但**没有显式质量门**
- **TAD 适用性**：自动触发理念好，但"无显式质量门"不符合 TAD 哲学

### 3. Claudeception — 轻量级方案
- 来源：https://github.com/blader/Claudeception
- 专门为 Claude Code 设计的 skill extraction skill
- 6-step 流程：搜索现有 skill → 分析知识 → Web 研究 → 结构化模板 → 语义描述 → 保存
- 4 个质量门：Reusable / Non-trivial / Specific / Verified
- 触发条件：调查 >10 min + 文档误导、非显而易见的错误解决、试错成功模式
- 输出格式：标准 SKILL.md（Problem / Context / Solution / Verification / Example / Notes / References）
- **TAD 适用性**：最接近 TAD 需要的轻量级方案，质量门简洁实用

### 4. 学术基础
- Voyager (2023)：游戏 agent 通过玩游戏自动建立 skill library
- CASCADE (2024)：引入"meta-skills"概念——获取技能的技能

## Proposed Design (High-Level)

### 触发点：Blake Knowledge Assessment（现有步骤，零新增仪式）

```
Blake Gate 3 完成
    ↓
Knowledge Assessment（现有）
    ├→ 教训类发现 → project-knowledge/ 条目（现有，不变）
    └→ 工作模式可复用？→ 新增判断
           │
           ├→ 不可复用 → 跳过
           └→ 可复用 → 生成 skillify candidate
                           ↓
                    .tad/active/skillify-candidates/SCAND-{date}-{slug}.md
                           ↓
                    Alex 下次启动时检测（类似 dream candidate）
                           ↓
                    人类审批 → 接受 → .claude/skills/{slug}/SKILL.md（project-level skill）
```

### Skillify 候选的判断标准（借鉴 Claudeception 的 4 门 + GBrain Phase 0）

1. **Reusable** — 这个模式以后会再遇到吗？（≥2 次预期复用）
2. **Non-trivial** — 不是单条规则，而是多步工作流（≥3 步骤）
3. **Verified** — Gate 3 通过了，模式确实 work
4. **Not-already-captured** — 不和现有 skill / capability pack 重复

### 候选文件格式

```yaml
---
name: {kebab-case-slug}
date: {YYYY-MM-DD}
status: pending  # pending | accepted | rejected
source_handoff: HANDOFF-{date}-{slug}.md
trigger_conditions: "{什么场景下用这个模式}"
---

## Pattern
{工作模式的描述：触发条件、步骤、质量标准}

## Evidence
{这次 Gate 3 通过的证据、关键文件引用}

## Proposed Skill Outline
{如果接受，SKILL.md 应该包含什么}
```

### 和现有机制的区分

| 机制 | 产出 | 性质 | 创建方式 |
|------|------|------|----------|
| project-knowledge | 知识条目 | 被动（"下次注意 X"） | Gate 3/4 KA |
| dream candidate | 知识整合建议 | 被动（dedup/merge） | dream-scanner.sh |
| **skillify candidate（新）** | 可复用 skill | 主动（"下次这样做"） | Gate 3 KA 扩展 |
| capability pack | 领域判断力 | 深度（研究驱动） | 自上而下研究 |

### 不做什么

- 不做 GBrain 的 cross-modal eval（TAD 现有 cross-model 审查已覆盖）
- 不做 Hermes 的自动 skill 更新（TAD 不信任 agent 自我修改 skill）
- 不做完整 11-item checklist（太重，这是轻量级 project skill）
- 不自动创建 skill（只创建 candidate，人类审批）

## Open Questions

1. skillify candidate 的质量如何保证？Blake 提出候选 vs Alex 审批 vs 人类最终决定——三层够吗？
2. project-level skill (.claude/skills/) vs user-level skill (~/.claude/skills/) 的边界？
3. 随着 skill 积累，会不会出现和 capability pack 的碰撞问题？（需要类似 scan-collisions.sh 的机制？）
4. 产出的 skill 是否需要 behavioral eval fixture？（如果需要，成本就接近 capability pack 了）
5. Blake 在 KA 时有足够的上下文判断"可复用性"吗？还是应该由 Alex 在 Gate 4 时判断？

## Notes

- Garry Tan 文章 "Stop building Foxconn factories for your agents"（2026-06-01）启发了方向，但经讨论判断其"放权给 agent"的核心主张对 TAD 现阶段不适用——模型的元判断能力还不够
- 用户的关键洞察：Knowledge Assessment 是正确的触发时机，因为上下文最完整
- 这个 idea 解决的是 IDEA-20260602 提出的"双路径"中缺失的那条——自下而上的能力积累

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Handoff (via *analyze — 2026-06-03)
