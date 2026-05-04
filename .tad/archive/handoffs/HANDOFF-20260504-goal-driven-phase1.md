---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 1 — Business Objective Definition + Research Gap Analysis

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Project:** TAD | **Task ID:** TASK-20260504-005
**Epic:** EPIC-20260504-goal-driven-research.md (Phase 1/3)

---

## 🔴 Gate 2: ✅ PASS (compact — scope derived from Epic + user decision)

---

## 1. Overview

让 Alex 知道用户的业务目标，并据此判断"当前缺少什么研究"。三件事：
1. 创建 OBJECTIVES.md 模板（OKR 格式）
2. Alex SKILL STEP 3.8 扩展：读 OBJECTIVES + 对比研究覆盖 → 输出 gap
3. 内容副业项目手动注册 10 个缺失 notebook 到 REGISTRY

---

## 2. Requirements

### R1: OBJECTIVES.md 模板

创建 `.tad/templates/objectives-template.md`：

```markdown
# Project Objectives

> OKR 格式：Objective (定性方向) + Key Results (可量化指标)
> Alex 读取此文件判断研究是否服务业务目标。

---

## O1: {Objective 1 — 定性描述}

**Why:** {为什么这个目标重要}
**Timeline:** {目标时间线, e.g., 2026 Q2}

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | {可量化指标} | {当前值} | {目标值} | ⬚/🔄/✅ |
| KR2 | {可量化指标} | {当前值} | {目标值} | ⬚/🔄/✅ |

**Research needed:** {Alex 填写 — 为达成此目标需要研究什么}

---

## O2: {Objective 2}
(same structure)
```

### R2: Alex SKILL — STEP 3.8 扩展为"研究态势 + 目标对齐"

当前 STEP 3.8 只扫描 REGISTRY（研究态势）。扩展为：

```yaml
step3_8_research_landscape:
  name: "Research Landscape + Objective Alignment Scan"
  action: |
    # ---- 现有行为保持不变 ----
    1. Check REGISTRY.yaml → output 研究态势 (unchanged)
    
    # ---- 新增：目标对齐检查 ----
    2. Check if OBJECTIVES.md exists (project root)
       → If not: skip silently (项目没定义目标)
    3. If exists: Read OBJECTIVES.md
       a. Extract all Objectives + Key Results
       b. For each Objective: check REGISTRY notebooks → is there research covering this goal?
       c. Gap detection:
          - If Objective has ≥1 aligned notebook → "🎯 O1 covered by: '{notebook_topic}'"
          - If Objective has NO aligned notebook → "⚠️ O1 '{objective}' — 无对应研究，建议发起"
    4. Output format (append after existing research landscape):
       ```
       🎯 Objective Alignment:
       - O1: {title} — ✅ Covered (notebook: {topic}) / ⚠️ No research
       - O2: {title} — ✅ / ⚠️
       ```
    5. If ANY gap detected:
       → "💡 建议: 运行 *research-review 或 *research-notebook research 来填补研究空白"
       (不自动发起 — Phase 2 才加自主发起能力)
  
  blocking: false
  suppress_if: "OBJECTIVES.md not found"
```

### R3: *research-review 扩展 — step2 分类时参考 OBJECTIVES

在现有 *research-review step2（分类诊断）中增加"目标对齐"维度：

```yaml
# 在现有 4 类分类逻辑中，增加 OBJECTIVES 参考：
step2_enhanced:
  action: |
    (现有逻辑保持 — 从 ROADMAP + NEXT 判断 goal alignment)
    
    新增：如果 OBJECTIVES.md 存在
    → 每个 notebook 的 "Relevance to Current Goals" 直接对标 Objective：
      - notebook topic 匹配 O1 → "🎯 Serves O1: {objective title}"
      - notebook topic 不匹配任何 O → "❓ No objective alignment"
    → 分类优先级调整：
      - 匹配 ⬚ Key Result → 🔥 加强（需要更多研究来推进这个 KR）
      - 匹配 ✅ Key Result → ✅ 维持（目标已达成，研究够了）
      - 不匹配任何 → 🔄 转向 或 📦 关闭
```

### R4: 内容副业 REGISTRY 手动注册（prerequisite）

在实现 R1-R3 之前，先把内容副业项目的 10 个未注册 notebook 补到 REGISTRY.yaml：

```yaml
# 从 E2E report P3.3 差异明细直接获取：
notebooks_to_register:
  - {id: "c4f2aae5", topic: "True Crime 与恐怖播客 - 内容制作手法研究", source_count: 5}
  - {id: "47da593a", topic: "P2 内容品类选择 - 什么内容值得做", source_count: 8}
  - {id: "249caca9", topic: "2026 最新 TTS 与音频制作工具", source_count: 9}
  - {id: "48daeac2", topic: "AI 资讯内容 - 需求分析与案例", source_count: 6}
  - {id: "23c7d40f", topic: "TTS 与音频生产工具链对比", source_count: 7}
  - {id: "5046042f", topic: "AI 资讯多语种播客 - 需求与制作", source_count: 6}
  - {id: "d4dfc53f", topic: "AI 产品广告视频生成 - 工具与商业模式", source_count: 8}
  - {id: "99cb5c0d", topic: "AI 恐怖短视频与漫画短剧", source_count: 11}
  - {id: "9957a237", topic: "短篇有声故事 - 恐怖悬疑 true crime", source_count: 0}
  - {id: "ff50b394", topic: "AI Music Passive Income - Spotify & YouTube", source_count: 0}

target_file: "~/01-on progress programs/内容副业/.tad/research-notebooks/REGISTRY.yaml"
action: "Append these entries to notebooks list, update active_notebook to c4f2aae5 (most content-rich)"
```

### R5: 为内容副业创建初始 OBJECTIVES.md

在 `~/01-on progress programs/内容副业/OBJECTIVES.md` 创建基于用户已知战略（from research/09-strategic-thinking-20260503.md）：

```markdown
# Project Objectives — 内容副业

## O1: 第一个恐怖播客频道上线并获得初始受众

**Why:** P2 方向已选定（恐怖/犯罪故事），需要从研究转入执行
**Timeline:** 2026 Q2

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | 第一期完整内容发布 | 有 prototype | 1 期完整发布 | 🔄 |
| KR2 | TTS 工具链确定并可稳定出片 | 工具调研完成 | 固定 pipeline | ⬚ |
| KR3 | 选定分发平台并开通账号 | 平台研究完成 | ≥2 平台上线 | ⬚ |

**Research needed:** (Alex 填写)

## O2: 建立可复用的 AI 内容生产 pipeline

**Why:** 速度 > 完美。Pipeline 成熟后可快速复制到其他方向（P1/P3/P4）
**Timeline:** 2026 Q2-Q3

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | 单期生产时间 | 未知 | < 4 小时/期 | ⬚ |
| KR2 | 生产流程文档化 | 无 | 完整 SOP | ⬚ |
| KR3 | 至少生产 5 期内容 | 1 prototype | 5 期 | ⬚ |

**Research needed:** (Alex 填写)
```

---

## 3. Files to Modify/Create

| # | File | Action | Project |
|---|------|--------|---------|
| 1 | `.tad/templates/objectives-template.md` | Create | TAD |
| 2 | `.claude/skills/alex/SKILL.md` | Edit (~30 lines) | TAD |
| 3 | `~/01-on progress programs/内容副业/.tad/research-notebooks/REGISTRY.yaml` | Edit | 内容副业 |
| 4 | `~/01-on progress programs/内容副业/OBJECTIVES.md` | Create | 内容副业 |

---

## 4. Acceptance Criteria

- [ ] AC1: `.tad/templates/objectives-template.md` exists with OKR format
- [ ] AC2: Alex SKILL STEP 3.8 reads OBJECTIVES.md + outputs gap analysis
- [ ] AC3: *research-review step2 references OBJECTIVES for classification
- [ ] AC4: 内容副业 REGISTRY.yaml has 11 notebooks (1 existing + 10 new)
- [ ] AC5: 内容副业 OBJECTIVES.md exists with O1 + O2 filled in
- [ ] AC6: STEP 3.8 suppress_if when OBJECTIVES.md not found (不影响无目标项目)
- [ ] AC7: 内容副业 REGISTRY.yaml YAML 有效 (`yq '.notebooks | length'` returns 11)
- [ ] AC8: 所有内容副业路径在 Bash/Edit 中双引号包裹（路径含空格）

---

## 5. Important Notes

- R4 的 notebook source_count 是估算值（来自 E2E report），不需要精确验证
- R5 的 OBJECTIVES 内容从 `research/09-strategic-thinking-20260503.md` 提取，用户已确认方向
- Alex SKILL 改动很小 — 只是在现有 STEP 3.8 末尾追加 2-5 步目标对齐检查
- 不要改 STEP 3.8 的现有研究态势行为（保持向后兼容）

---

## 📚 Project Knowledge

- Phase 3 E2E report P3.3：29 vs 1 差距明细 + 10 个 notebook ID 列表
- 09-strategic-thinking-20260503.md：用户业务战略（P1-P4 四个方向 + 时间窗口判断）

---

## 9.2 Expert Review

Compact phase — Alex SKILL 改动 ~30 行，其余是模板创建和数据填充。Layer 2 code-reviewer 审查 SKILL 改动。
