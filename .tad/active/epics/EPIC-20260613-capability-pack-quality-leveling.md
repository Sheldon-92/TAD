# Epic: Capability Pack Quality Leveling (全量 24,双层尺)

**Epic ID**: EPIC-20260613-capability-pack-quality-leveling
**Created**: 2026-06-13
**Owner**: Alex

---

## Objective
把全部 24 个能力包(capability packs)拉齐到同一条高质量线。质量线是**双层**的:
(1) 元设计/结构层——对标最好的开源 skill 库的组织方式;(2) 领域内容层——对标内部最成熟的
3 个包(web-ui-design / web-frontend / web-backend)的领域深度。每个包的升级通过判别式行为
评估 + 跨模型对抗审查双重把关,杜绝 validation theater。

## Success Criteria
- [ ] 24 个包全部通过统一 rubric(元设计 checklist + 判别式行为评估,negative control 必须 FAIL)
- [ ] 每个包所在批次的跨模型(Codex)对抗审查 FIX-FIRST 全部 resolved
- [ ] `QUALITY-BAR.md` 双层 rubric 落地,成为今后新包的强制参照
- [ ] 元设计结构 checklist 固化进 `capability-upgrade` SKILL,作为新包 Gate 2 强制产出
- [ ] 基线审计前后对比:每个包的质量评分有可量化的提升记录

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | 定尺 + 基线审计 (Bar + Baseline) | ✅ Done (Gate 4 pending) | HANDOFF-20260613-pack-quality-phase1-bar-baseline.md | QUALITY-BAR.md + BASELINE-AUDIT.md (含批次分组) ✅ |
| 2 | 升级批次 1（最弱 7 个 + 无 fixture） | ⬚ Planned | — | 7 包通过双层尺 + 批次 Codex 审查 |
| 3 | 升级批次 2（中浅+结构补强 5 个） | ⬚ Planned | — | 5 包通过双层尺 + 批次 Codex 审查 |
| 4 | 升级批次 3（扎实向 gold 收口 5 个） | ⬚ Planned | — | 5 包通过双层尺 + 批次 Codex 审查 |
| 5 | 升级批次 4（近 gold 最后一抬 4 个） | ⬚ Planned | — | 4 包通过双层尺 + 批次 Codex 审查 |
| 6 | 全量验证 + 固化 | ⬚ Planned | — | 21 升级包重跑 eval gate；checklist 固化进 capability-upgrade |

### 批次成员（Phase 1 基线回填 — 弱→强，不均匀 7/5/5/4；3 gold 不进升级批，是参照）

- **批次 1（Phase 2，7）**：ml-training\*, data-engineering, ai-podcast-production\*, agent-memory, agent-orchestration, knowledge-graph, ai-tool-integration　（\*=无 fixture，强制入此批）
- **批次 2（Phase 3，5）**：llm-observability, product-thinking, code-security, synthetic-data, web-testing
- **批次 3（Phase 4，5）**：ai-agent-architecture, ai-evaluation, ai-guardrails, ai-voice-production, ai-prompt-engineering
- **批次 4（Phase 5，4）**：rag-retrieval, web-deployment, academic-research, video-creation
- **不进升级批（gold/参照）**：web-backend, web-frontend, web-ui-design　（web-ui-design 有结构 gap → 可选独立精修，见 BASELINE-AUDIT §3）
- **批次可重排**：成员 advisory，每批入口重打分纠错（详见 BASELINE-AUDIT.md §2.1/§2.2）。

### Phase Dependencies
- Phase 1 是定尺+基线,**必须先做**——它产出批次分组(哪个包进哪批由基线弱→强决定)。✅ 已完成。
- Phase 2-5 顺序执行,批次大小不均匀(7/5/5/4，按实际 gap 切，不硬钉 6)。成员已回填上方。
- Phase 6 依赖 Phase 2-5 全部完成。
- 同时只能 1 个 Active phase(TAD 约束)。

### Derived Status
- **Status**: In Progress (Phase 1 Active)
- **Progress**: 0 / 6 phases

---

## Phase Details

### Phase 1: 定尺 + 基线审计 (Bar + Baseline)

**Status:** 🔄 Active
**Execution:** HANDOFF-20260613-pack-quality-phase1-bar-baseline.md

#### Scope
产出"高水平"的两把尺并用它们量一遍现状。包含三块:(1a) 元设计研究——调研开源 skill 库的
组织方式,提炼结构 checklist;(1b) 内部金标准——从 3 个成熟包提炼领域深度 bar;(1c) 基线
审计——用统一 rubric 量 24 个包,产出质量分布 + gap 清单 + 批次分组。
**NOT in scope**:不修改任何 pack 的 SKILL.md 内容(纯研究+审计;升级在 Phase 2-5)。

#### Input
- 24 个现有 pack:`.claude/skills/{pack}/SKILL.md`(清单见 handoff §2.2)
- 现有评估工具:`.tad/scripts/pack-eval-runner.sh` + `.claude/skills/*/examples/*.md` fixtures
- 现有方法论:`.claude/skills/capability-upgrade/SKILL.md`(5 阶段)
- 知识:pack-evaluation / pack-build-rules patterns;principles.md 的 validation-theater 教训

#### Output
- `QUALITY-BAR.md`:双层 rubric(元设计结构 checklist + 领域深度评分维度),含每维度的判别式判据
- `BASELINE-AUDIT.md`:24 包 × rubric 的质量分布表 + 每包 gap 清单 + 弱→强批次分组(填回本 Epic Phase Map)

#### Acceptance Criteria
- [ ] QUALITY-BAR.md 的元设计 checklist 至少有一个 negative control 证明它能判别(劣质结构 FAIL)
- [ ] BASELINE-AUDIT.md 覆盖全部 24 个包,每包有评分 + 具体 gap(不是"看起来还行")
- [ ] 批次分组明确(4 批 × 6),并已填回本 Epic Phase Map 的 Phase 2-5
- [ ] 评估口径引用现有 pack-eval-runner.sh 的 discriminative_pattern 机制,不重造

#### Files Likely Affected
- `.tad/evidence/pack-quality/QUALITY-BAR.md` (CREATE)
- `.tad/evidence/pack-quality/BASELINE-AUDIT.md` (CREATE)
- `EPIC-20260613-capability-pack-quality-leveling.md` (MODIFY — 回填批次成员)

#### Dependencies
None (can execute independently)

#### Notes
- 元设计研究走 research-github/notebook 持久化(CLAUDE.md 路由:深度研究→research-notebook)。
- ⚠️ validation-theater 风险:rubric 必须是判别式的(negative control 必须 FAIL),否则"全部通过"
  只是证明文件存在,不是证明质量。这是本 Epic 最大的方法论风险。

### Phase 2: 升级批次 1（基线最弱 6 个）

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
对基线审计排序最弱的 6 个包,走 capability-upgrade Stage 2(领域内容 GitHub-First 刷新)
+ 元设计结构对齐。批次成员由 Phase 1 基线决定,待回填。

#### Input
Phase 1 的 QUALITY-BAR.md + BASELINE-AUDIT.md;capability-upgrade 5 阶段流程

#### Output
6 个包升级后的 SKILL.md(+ examples/ fixtures),每个达到双层尺

#### Acceptance Criteria
- [ ] 每个包通过判别式行为评估(pack-eval-runner.sh,negative control FAIL / WITH-pack PASS)
- [ ] 每个包通过元设计结构 checklist
- [ ] 本批 6 个包的跨模型(Codex)合成对抗审查 FIX-FIRST 全部 resolved(过往经验:Codex 抓 same-model 漏掉的事实/API 错)
- [ ] 升级前后评分对比记录在案

#### Files Likely Affected
- `.claude/skills/{6 packs}/SKILL.md` (MODIFY)
- `.claude/skills/{6 packs}/examples/*.md` (CREATE/MODIFY)

#### Dependencies
Phase 1

#### Notes
跨模型审查按批跑(6 个一轮 Codex synthesis),不是每包单跑——成本可控。

### Phase 3: 升级批次 2（6 个）
（结构同 Phase 2,成员待 Phase 1 回填）
**Status:** ⬚ Planned
**Dependencies:** Phase 2

### Phase 4: 升级批次 3（6 个）
（结构同 Phase 2,成员待 Phase 1 回填）
**Status:** ⬚ Planned
**Dependencies:** Phase 3

### Phase 5: 升级批次 4（最后 6 个）
（结构同 Phase 2,成员待 Phase 1 回填）
**Status:** ⬚ Planned
**Dependencies:** Phase 4

### Phase 6: 全量验证 + 固化

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
全部 24 个包重跑 eval gate 做回归;把"元设计结构 checklist"固化进 capability-upgrade SKILL,
成为今后新包的 Gate 2 强制产出。

#### Input
Phase 2-5 升级后的 24 个包;QUALITY-BAR.md

#### Output
- 24 包全量 eval gate 通过的回归报告
- capability-upgrade SKILL 更新(checklist 成为新包强制产出)

#### Acceptance Criteria
- [ ] 24 包全部重跑判别式 eval gate,无回退
- [ ] capability-upgrade SKILL 的 Gate 2 段落新增元设计 checklist 强制产出条目
- [ ] 抽样跨模型 spot-check 确认无系统性事实错误

#### Files Likely Affected
- `.claude/skills/capability-upgrade/SKILL.md` (MODIFY)
- `.tad/evidence/pack-quality/PHASE6-REGRESSION.md` (CREATE)

#### Dependencies
Phase 2, 3, 4, 5

#### Notes
固化是为了让这次"拉齐"的成果不漂移——以后新包一出生就按这把尺。

---

## Context for Next Phase
（Alex 在每次 *accept 后更新）

### Completed Work Summary
- （尚无 Phase 完成）

### Decisions Made So Far
- 范围 = 24 个全量能力包(含 product-thinking + ai-agent-architecture 两个边界货)。
- 双层尺:元设计结构 + 领域深度。
- 每包 DoD:判别式行为评估 + 元设计 checklist + 所在批次 Codex 对抗审查。
- 批次:4 批 × 6,弱→强,成员由 Phase 1 基线决定。
- 跨模型审查按批跑(非每包单跑),控成本。

### Known Issues / Carry-forward
- validation-theater 是头号方法论风险——rubric 必须判别式(negative control 必须 FAIL)。

### Next Phase Scope
Phase 1:产出 QUALITY-BAR.md + BASELINE-AUDIT.md,并把批次成员回填本 Phase Map。

---

## Notes
- 对齐 OBJECTIVES O2/KR1(能力包行为示例)+ surplus-plan 2026-06-13 第 5 名。
- 源起:2026-06-13 *discuss 会话(skills 识别机制 → packs 全部 skill 化确认 → 质量拉齐需求)。
