# Epic: Capability Pack Quality Leveling (全量 24,双层尺)

**Epic ID**: EPIC-20260613-capability-pack-quality-leveling
**Created**: 2026-06-13
**Owner**: Alex

---

## Objective
把全部 24 个能力包(capability packs)拉齐到同一条高质量线。质量线是**双层**的:
(1) 元设计/结构层——对标最好的开源 skill 库的组织方式;(2) 领域内容层——对标内部最成熟的
3 个包(web-ui-design / web-frontend / web-backend)的领域深度。每个包的升级通过判别式行为
评估 + Workflow 对抗审查(同模型多 lens + 一手文档核对,见 Review Approach)双重把关,杜绝 validation theater。

## Success Criteria
- [ ] 24 个包全部通过统一 rubric(元设计 checklist + 判别式行为评估,negative control 必须 FAIL)
- [ ] 每个包所在批次的 **Workflow 对抗审查**(多独立 skeptic agent,最强模型;版本敏感断言 WebSearch 核对一手文档)FIX-FIRST 全部 resolved　〔2026-06-13 决定:不用 Codex,见下方 Review Approach〕
- [ ] `QUALITY-BAR.md` 双层 rubric 落地,成为今后新包的强制参照
- [ ] 元设计结构 checklist 固化进 `capability-upgrade` SKILL,作为新包 Gate 2 强制产出
- [ ] 基线审计前后对比:每个包的质量评分有可量化的提升记录

## Review Approach (2026-06-13 决定 — 替换原 Codex 跨模型审查)

原设计每批用 Codex 跨模型对抗审查。改为 **Workflow 编排的同模型对抗审查**(理由:免 Codex auth 摩擦;Alex `NOT_via_alex_auto` 不能自动调外部 CLI):

- 每批用 **Workflow fan-out 多个独立 skeptic agent**(perspective-diverse lens:正确性 / 事实-API / 反 slop / 行为判别),最强模型(workflow agent 默认继承主循环 Opus)。
- **关键代价补偿**:同模型共享训练盲区(Codex 当初专抓事实/API 错)。故对抗 agent 有**硬约束**:所有版本敏感断言(API 名 / 版本号 / 弃用 / metric 类型 / 常量)**必须 WebSearch 核对当前一手文档**——用"查原始源"代替"换模型"兜事实错误(pack-evaluation 2026-06-01 教训点 c)。
- majority-refute 杀掉一个 finding;verify 阶段独立查证,不继承前一审查的判定。
- ⚠️ 残留风险记录:纯同模型即便查一手文档,仍可能漏掉训练分布里根深的错误模式。可接受(用户 2026-06-13 决定),但 Phase 6 抽样人审兜底。

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | 定尺 + 基线审计 (Bar + Baseline) | ✅ Accepted (Gate 4 PASS, commit f2addac) | archive/handoffs/HANDOFF-20260613-pack-quality-phase1-bar-baseline.md | QUALITY-BAR.md + BASELINE-AUDIT.md + notebook ✅ |
| 2 | 升级批次 1（最弱 7 个 + 无 fixture） | ✅ Done (commit b85e715, Gate PASS, user-confirmed) | yolo/...phase2-gate-report.md | 7 包通过双层尺 + 判别式 eval (WITH 14-21 vs CTRL 0) + 对抗审查 |
| 3 | 升级批次 2（中浅+结构补强 5 个） | ✅ Done (commit d27f108, Gate PASS; Conductor fixed 1 P0 + 1 P1 + locale bug) | yolo/...phase3-gate-report.md | 5 包通过双层尺 + 判别式 eval + 对抗审查(规则改为 any-refute→fix) |
| 4 | 升级批次 3（扎实向 gold 收口 5 个） | ✅ Done (commit f7e4efb, Gate PASS; limit-interrupted→resumed; Conductor fixed 2 P0 + 多 P1) | yolo/...phase4-gate-report.md | 5 包通过双层尺 + 判别式 eval + 对抗审查 |
| 5 | 升级批次 4（近 gold 最后一抬 4 个） | ✅ Done (commit ba1fa9c, Gate PASS) | yolo/...phase5-gate-report.md | 4 包通过双层尺 + 判别式 eval + 对抗审查 |
| 6 | 全量验证 + 固化 | ✅ Done | yolo/...EPIC-COMPLETION.md | 21/21 结构回归 PASS;checklist 固化进 capability-upgrade Gate 2 |

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
- **Status**: ✅ COMPLETE (all 6 phases done) — awaiting final human acceptance + Epic archive
- **Progress**: 6 / 6 phases

---

## Phase Details

### Phase 1: 定尺 + 基线审计 (Bar + Baseline)

**Status:** ✅ Accepted (Gate 4 PASS 2026-06-13, commit f2addac)
**Execution:** archive/handoffs/HANDOFF-20260613-pack-quality-phase1-bar-baseline.md

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
- [ ] 本批的 Workflow 对抗审查 FIX-FIRST 全部 resolved(多独立 skeptic agent;版本敏感断言 WebSearch 核对一手文档;见 Review Approach)
- [ ] 升级前后评分对比记录在案

#### Files Likely Affected
- `.claude/skills/{6 packs}/SKILL.md` (MODIFY)
- `.claude/skills/{6 packs}/examples/*.md` (CREATE/MODIFY)

#### Dependencies
Phase 1

#### Notes
Workflow 对抗审查按批跑(一批一轮 fan-out),不是每包单跑——成本可控。

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
- [ ] 抽样**人审** spot-check 确认无系统性事实错误(同模型审查兜底,见 Review Approach 残留风险)

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
- Phase 1 ✅ Accepted (Gate 4 PASS, commit f2addac): QUALITY-BAR.md(双层尺,两层各一 negative control 实跑 FAIL:Layer A 0/10、Layer B specN=0→1/5)+ BASELINE-AUDIT.md(24 包评分 + 弱→强 4 批 7/5/5/4,3 gold 排除)+ NotebookLM notebook `capability-pack-meta-design`。Gate 4 报告:`.tad/evidence/acceptance-tests/pack-quality-phase1-bar-baseline/gate4-acceptance-report.md`。

### Decisions Made So Far
- 范围 = 24 个全量能力包;其中 3 个 gold(web-backend/frontend/ui-design)是参照,不进升级批 → **21 个升级候选**。
- 双层尺:Layer A 元设计结构(/10,通过线 7)+ Layer B 领域深度(0/2/5,含 specN 可计数子维度)。
- 每包 DoD:判别式行为评估 + 元设计 checklist + 所在批次 Workflow 对抗审查(同模型多 lens + 一手文档核对;不用 Codex,见 Review Approach)。
- 批次:**不均匀 7/5/5/4**(非 6/6/6/6),弱→强,成员已回填 Phase Map;批次可重排(每批入口重打分)。
- 对抗审查按批跑(非每包单跑),控成本。

### Known Issues / Carry-forward
- validation-theater 是头号方法论风险——rubric 必须判别式(已证:两层 negative control 实跑 FAIL)。
- **结构-gold ≠ 深度-gold**:web-ui-design 深度 5/5 但 body 1202 行违反 <500 → 结构 gap,另列 BASELINE §3 可选独立精修。
- 2 个无 fixture 包(ml-training + ai-podcast-production)已进 Batch 1,补 fixture 是该批 Phase-2 交付物。
- specN 单维会误排 gold(web-backend specN 仅 27)→ gold 由定义锚 5,specN 仅对非 gold 初判 + 边界包重打分。

### Next Phase Scope
**Phase 2 = Batch 1(7 包)**:ml-training\*, data-engineering, ai-podcast-production\*, agent-memory, agent-orchestration, knowledge-graph, ai-tool-integration（\*=补 fixture）。走 capability-upgrade Stage 2 领域刷新 + 元设计结构对齐;DoD 含本批 Workflow 对抗审查(不用 Codex)。

---

## Notes
- 对齐 OBJECTIVES O2/KR1(能力包行为示例)+ surplus-plan 2026-06-13 第 5 名。
- 源起:2026-06-13 *discuss 会话(skills 识别机制 → packs 全部 skill 化确认 → 质量拉齐需求)。
