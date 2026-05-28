---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - .claude/skills/video-creation
  - .tad/capability-packs/video-creation
skip_knowledge_assessment: no
gate4_delta:
  - field: "AC8 + AC13"
    alex_said: "grep -c 'vimax-patterns.md' SKILL.md/CAPABILITY.md should = 1"
    actual: "Reference filenames naturally appear in 2 locations (Context Detection table + Quick Rule Index heading) — should = 2"
    caught_by: "Blake during Gate 3 AC verification + Alex raw-recompute confirmed"
  - field: "AC15"
    alex_said: "grep -ocE 'pattern' file | sort -u | wc -l counts unique pattern signal matches, expected ≥ 4"
    actual: "Command always returns 1 due to -c flag interaction with sort -u (Blake reported 4 by accident — actual unique signal count via correct command grep -oE is 4 distinct matches: first_frame, last_frame, last frame, intent)"
    caught_by: "Alex Gate 4 step4 raw-recompute caught the buggy command and re-ran with -oE alone"
  - field: "Layer 2 audit reviewer naming"
    alex_said: "Blake review files would match audit script KNOWN_REVIEWERS via canonical sub-agent type names"
    actual: "Blake used '-review' suffix convention (spec-compliance-review, code-review, architecture-review) — audit returned PASS by file count but DISTINCT_COUNT=0 with WARN"
    caught_by: "Alex Gate 4 step4c layer2-audit.sh output"
---

# Handoff: Upgrade video-creation Pack with 4 ViMax Patterns

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-05-27
**Project:** TAD framework — video-creation Capability Pack
**Task ID:** TASK-20260527-001
**Handoff Version:** 1.0 (post-expert-review with P0 fixes)
**Epic:** N/A (single handoff covering 4 related patterns)
**Supersedes:** N/A

---

## 🟢 Gate 2: Design Completeness — PASS

**Executed**: 2026-05-27 15:35

| Check | Status | Detail |
|-------|--------|--------|
| Architecture Complete | ✅ | 4 pattern + 1 integration scene, 7 files mapped, infrastructure auto-syncs |
| Components Specified | ✅ | Each pattern has ViMax source class.method + prompt excerpt + rules + boundaries |
| Functions Verified | ✅ | NotebookLM quality probe confirmed code-level details (BestImageSelector Pydantic + fallback) |
| Data Flow Mapped | ✅ | §5 cross-references map all dependencies; §10.5 confirms infrastructure invariants |
| Expert Review | ✅ | code-reviewer + product-expert both CONDITIONAL PASS; 6 P0 + 6 P1 all Resolved (§9.2) |
| ACs Verifiable | ✅ | All 16 ACs syntax-validated + 4 new commands mock-dry-run PASS (AC6=4, AC9=4, AC10=6, AC12=4) |
| Pre/post baseline | ✅ | Step 0 baseline capture + Step 7.5 post-upgrade capture = behavioral evidence chain |
| Risk Controls | ✅ | 400-line hard cap (AC3) + narrow Context Detection signal (Step 4) + negative routing test (Step 7.6) all address user's #1 concern (context bloat) |

**Gate 2 result**: ✅ PASS — Blake can implement independently.

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 阅读「📚 Project Knowledge」和「🔧 Pack References」章节
- [ ] 理解 4 个 ViMax pattern 的代码出处（NotebookLM 已验证）
- [ ] 理解 Photo-to-Beat-Sync 是真实用户验收场景，不是 hypothetical
- [ ] 理解风险防控：≤400 行的硬上限（用户最大顾虑是 context 爆炸）
- [ ] 确认能独立按本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

把 4 个从 HKUDS/ViMax 研究中提炼的 AI 视频生成 pattern 落到我们的 video-creation Capability Pack 里，作为 pack 的能力补全。

**4 个 pattern**：
1. Visual Decomposition（拆首尾帧）
2. Intent Routing（叙事/动作/蒙太奇分类）
3. View-Specific Reference Selection（按机位选参考图）
4. Camera Tree（镜头空间继承）

**集成场景**：Photo-to-Beat-Sync — 摄影照片转卡点动态视频（真实用户首批应用场景）。

### 1.2 Why We're Building It

**业务价值**：为未来 AI 视频生成项目积累可复用的 pack 能力。当前 pack 专注 motion graphics + 资产生成，缺乏 AI 视频"漂移防护"层（首尾帧约束、意图分类、机位一致、空间继承）。这 4 个 pattern 补齐这一层。

**用户受益**：用户立即将做的 Photo-to-Beat-Sync 工作流，4 个 pattern 都能直接用上。未来产品介绍动画、品牌动画、社交动画也会复用。

**成功的样子**：当用户用「我的照片 + AI 帮我做卡点动画」需求触发 pack 时，AI agent 自动调用拆首尾帧 + 意图路由 + view-specific reference 规则，生成的 prompt 含完整结构。

### 1.3 Intent Statement

**真正要解决的问题**：当前 pack 在 AI 视频生成（Seedance 等）规则方面只覆盖到「endpoint 选择 + cost 控制 + prompt anchoring」，缺乏「shot-level 内部如何精确控制 AI 不漂移」的判断规则。ViMax 4 个 pattern 是 production-tested 的解法，把它们提炼成 pack 规则。

**不是要做的（避免误解）**：
- ❌ 不是把 ViMax 整个 multi-agent pipeline 搬过来（架构错位）
- ❌ 不是做端到端 narrative video 生成器（pack 定位是 motion graphics）
- ❌ 不是改 SKILL.md 路由架构（只是加新 signal + 新 reference 文件）
- ❌ 不是创建 Python 代码（pack 是判断规则文档，不是可执行代码）

**Blake 请用自己的话回答**：
- 这 4 个 pattern 的共同主题是什么？（提示：都跟 AI 视频生成的「精确控制」相关）
- 为什么 pattern 5（Global Character Merge）没在本 handoff 范围内？（提示：NotebookLM 已诚实标记 NOT VALUABLE）

---

## 2. 📚 Project Knowledge（Blake 必读历史教训）

### ⚠️ Blake 必须注意的历史教训

匹配类别扫描结果（task keywords: pack, reference files, markdown content, ViMax patterns, AI video）：

1. **Capability Pack: YAML Frontmatter is Load-Bearing - 2026-05-07** (architecture.md)
   - 影响本任务：SKILL.md 修改时必须保留 YAML frontmatter（`name:` + `description:`）。`vimax-patterns.md` 作为 reference 文件不需要 frontmatter（references 由 SKILL.md 路由加载）。

2. **Capability Pack: Architecture Spectrum - 2026-05-08** (architecture.md)
   - 影响本任务：video-creation 是 reference-based pack。新增 pattern 必须延续 reference-based 模式（不要变成 deep-skill 多文件交互）。

3. **Capability Pack: Design and Build Rules - 2026-05-07** (architecture.md)
   - 影响本任务："Rule sourcing: MUST read the cited source, not just the citation"。本 handoff 已通过 NotebookLM 验证 ViMax 源码（不是只读 README），引用的类名 + 方法 + prompt 模板都是从代码中提取的。
   - 影响本任务："Research findings = what to COVER, not what to SAY"。NotebookLM 给的 5 gap 分析是发现的覆盖面，不是规则字面文字。Blake 写规则时要重新组织成 pack 风格的 quick-rule 格式。

4. **Capability Pack Quality Bar: Anti-Slop Metrics - 2026-05-15** (architecture.md)
   - 影响本任务：每条规则必须有「具体数字 / 具体阈值 / 具体出处」，不能只有「best practice」般的泛泛话。Anti-slop 标准。

5. **Recurring failure: tsc missing type - 2026-05-19** (code-quality.md)
   - 影响本任务：本任务是 markdown-only（无 TypeScript），不触发。提及为完整性记录。

### Research Notebook Findings

Notebook: `video-creation-vimax-research` (id: `79b4c4a9-f1b2-49cf-962f-3188b52426d5`, 38 sources)
- 9 TAD pack files (SKILL + CAPABILITY + 7 references)
- 29 ViMax files (1 readme + 13 agents + 3 pipelines + 9 interfaces + 1 tools/protocols + 2 configs)

Findings file: `.tad/evidence/research/video-creation-vimax/2026-05-27-deep-ask-findings.md` (60 lines, Top 5 gaps with code citations)

Quality verified: probe asked `BestImageSelector` 实现细节，NotebookLM 返回类名 + Pydantic schema + base64 编码 + fallback idx=0 — 确认是真正读了代码，不是 SPA shell。

---

## 3. 🔧 Pack References

**Loaded Pack**:
| Pack | File | Matched Capabilities |
|------|------|---------------------|
| video-creation | `.claude/skills/video-creation/SKILL.md` | ai-asset-generation, storytelling, audio-design（用于 Photo-to-Beat-Sync 集成） |

⚠️ Blake 必须 Read 这个 SKILL.md + 现有 ai-asset-generation.md（理解 Seedance 规则） + audio-design.md（理解 BPM 规则）才能写好新 reference。

---

## 4. ViMax Pattern Specifications

### Pattern 1: Visual Decomposition（拆首尾帧）

**ViMax 出处**: `agents/storyboard_artist.py` → `StoryboardArtist.decompose_visual_description`
**关键 schema**: `VisDescDecompositionResponse`（强制 3-part 输出）
**Prompt 关键句**: *"dissect and rewrite a user-provided visual text description of a shot strictly and insightfully into three distinct parts: First Frame Description / Last Frame Description / Motion Description"*

**适用本 pack 的判断规则**（要写到 vimax-patterns.md）：

- 当 AI agent 要给 Seedance image-to-video 写 prompt 时，**不要写「整段动画描述」**，要先 decompose：
  - First frame: 起始静态状态（让 gpt-image-2 先生成此图）
  - Last frame: 结束静态状态（让 gpt-image-2 再生成此图）
  - Motion: 两者之间的运动方向、节奏（喂给 Seedance）
- 触发条件：任何 `image-to-video` 调用，shot 时长 ≥ 2 秒
- 反模式：直接喂整段描述（"a car drives in and stops in the center"）→ Seedance 自由发挥可能不准确
- Motion-graphics 适用边界：3-5s 短片段尤其关键（短时间内 AI 容易自由发挥）

---

### Pattern 2: Intent Routing（意图分类）

**ViMax 出处**: `agents/script_planner.py` → `ScriptPlanner.plan_script`
**关键 schema**: `IntentRouterResponse` with `Literal["narrative", "motion", "montage"]`
**Prompt 关键句**: *"intent: 'narrative' for characters multi-conversation focus, 'motion' for action/kinetic focus, 'montage' for emotional montage focus"*

**适用本 pack 的判断规则**：

- 当 AI agent 接到用户视频需求时，**第一步先分类意图**，不要直接按 keyword 选模板：
  - `narrative` — 有人物对白 / 情节推进 → 节奏偏 4-6s 中等 shot
  - `motion` — 动作 / 动感主导 → 节奏偏 1.5-3s 快切
  - `montage` — 情绪 / 氛围拼接 → 节奏偏 3-5s 渐进
- 这一层在现有 `storytelling.md` 的 "Product Demo / Social Short / Tutorial" 模板之上 — 意图先定，再选模板
- 触发条件：每次新视频任务的第一步
- 反模式：用户说"做品牌片" → 直接套 Product Demo 模板（可能是 montage 性质，节奏错位）

---

### Pattern 3: View-Specific Reference Selection（按机位选参考图）

**ViMax 出处**: `agents/reference_image_selector.py` → `ReferenceImageSelector.select_reference_images_and_generate_prompt`
**Prompt 关键句**: *"For character portraits, you can only select at most one image from multiple views (front, side, back). Choose the most appropriate one based on the frame description. For example, when depicting a character from the side, choose the side view of the character."*

**适用本 pack 的判断规则**：

- 当任务涉及同一角色 / 同一物体出现在多个 shot 中，**第一步生成 character sheet 含 front/side/back 3 视角**（用 gpt-image-2 一次生成）
- 每个 shot 的 image-to-video 调用，**根据 camera angle 自动选合适的参考图**喂给 Seedance：
  - 镜头拍正面 → 用 front view 参考
  - 镜头拍侧面 → 用 side view 参考
  - 镜头拍背面 → 用 back view 参考
- 现有 pack 的 `@character:<id>` invariant anchor 是「prompt 层一致性」，本规则补充「视觉参考层一致性」
- 触发条件：character / object 出现在 ≥ 2 个 shot 且至少 1 个角度变化
- 反模式：所有 shot 都用 front view 参考 → 侧面 / 背面镜头 AI 臆造角度

---

### Pattern 4: Camera Tree（镜头空间继承）

**ViMax 出处**: `agents/camera_image_generator.py` → `CameraImageGenerator.construct_camera_tree`
**Prompt 关键句**: *"Your task is to analyze the input camera position data to construct a 'camera position tree'. This tree structure represents a relationship where a parent camera's content encompasses that of a child camera."*

**适用本 pack 的判断规则**：

- 当多个 shot 在同一 scene 内（相同空间、相同时间点）时，**建立 parent-child 关系**：
  - Parent = 最 wide 的 shot（建立空间布局）
  - Child = 同空间内的 tight / medium shot（继承父 shot 的背景细节、光照、构图）
- Child shot 的 prompt **必须显式引用父 shot 的关键空间元素**（"following the wide-shot composition: [sofa on left, painting on back wall, lamp upper-right]"）
- 触发条件：连续 ≥ 2 个 shot 在同一 scene
- 反模式：每个 shot 独立写 prompt → AI 在 cuts 之间幻化背景细节
- Motion-graphics 适用边界：纯 GSAP / Remotion 2D 动效不需要（视觉元素是程序定义的）；**只在涉及 AI 生成视频的 scene 内多 shot 时启用**

---

### Pattern 5（集成场景）: Photo-to-Beat-Sync

**场景**：用户是摄影师，输入一组静态照片，想转成卡点动态视频。

**4 个 pattern 联动**：

| 步骤 | 调用 Pattern | 怎么用 |
|------|------------|--------|
| 1. 接到需求"把这 5 张照片转成 30s 卡点视频" | Pattern 2 | Intent Router 分类 → 多张照片 + 卡点 → **montage** 意图 |
| 2. 每张照片 → 2-3s 动画 | Pattern 1 | 照片本身 = first frame，让 gpt-image-2 生成 last frame（人物姿态变化 / 特效收尾），Seedance image-to-video 补两者之间 |
| 3. 如果同一人物在多张照片中以不同角度出现 | Pattern 3 | 从已有照片提取 view-specific reference，确保 AI 不臆造 |
| 4. 如果多张照片是同一场景（如同一房间不同角度） | Pattern 4 | 建立 camera tree，子 shot 继承空间布局 |
| 5. 卡点配乐 | 现有 audio-design.md | 按视频意图（montage）选 BPM 范围（20-80 BPM 情绪 / 110-130 BPM 现代感） + 现有 SFX Pre-Lead Rule |

**反模式**：
- ❌ 不分类意图直接套 Product Demo 模板 → 30s 卡点片当成 product demo 节奏会过快
- ❌ 不拆首尾帧直接给 Seedance "照片+'让她动起来'" → 动画方向不可控
- ❌ 卡点完全靠手工对齐 → 用 audio-design.md 的 BPM-to-cut 规则自动算

---

## 5. Capability Pack 集成方式

`vimax-patterns.md` 跟现有 7 个 reference 的关系：

| 现有 reference | 关联方式 |
|---------------|---------|
| `storytelling.md` | Pattern 2（意图路由）是其上游，本文件链接到 storytelling 的 Video Type Patterns |
| `visual-design.md` | Pattern 4（camera tree）影响 shot 内构图，本文件链接 GSAP easing 选择 |
| `audio-design.md` | Pattern 5（Photo-to-Beat-Sync）调用 BPM-to-Video-Type + SFX Pre-Lead |
| `ai-asset-generation.md` | Pattern 1 + 3 是 Seedance image-to-video 规则的精细化，本文件链接 §Seedance Endpoint Selection |
| `tool-selection.md` | 不直接关联 |
| `production.md` | Pattern 4 牵涉 multi-shot 协调，本文件链接 §Render Pipeline |
| `quality.md` | 不直接关联 |

---

## 6. Files to Modify / Create

| # | 文件 | 操作 | 行数预算 | 备注 |
|---|------|------|---------|------|
| 1 | `.claude/skills/video-creation/references/vimax-patterns.md` | CREATE | ≤ 400 | 4 个 pattern + Photo-to-Beat-Sync 集成场景，紧凑格式 |
| 2 | `.tad/capability-packs/video-creation/references/vimax-patterns.md` | CREATE | ≤ 400 | 与文件 1 byte-identical（pack 镜像）|
| 3 | `.claude/skills/video-creation/SKILL.md` | MODIFY | +12 行（Context Detection 表 1 新行 + Quick Rule Index 4 新行 + version bump） | 加新 signal 路由 + 4 条新规则一行摘要 |
| 4 | `.tad/capability-packs/video-creation/CAPABILITY.md` | MODIFY | +12 行 | 与文件 3 同步 |
| 5 | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md` | CREATE | ≤ 80 行 | Blake 准备的验收 fixture — 真实 prompt 示例 + 期望 AI 输出特征 |
| 6 | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/pre-upgrade-output.md` | CREATE | ≥ 30 行 | Step 0 baseline — pre-upgrade AI agent 响应捕获 |
| 7 | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md` | CREATE | ≥ 30 行 | Step 7.5 post-upgrade AI agent 响应捕获（对比验证 pack 改进） |

**Grounded Against** (Alex 实际 Read 过的源文件)：
- `.claude/skills/video-creation/SKILL.md` (head 175, read at 2026-05-27 14:53)
- `.claude/skills/video-creation/references/ai-asset-generation.md` (head 100, read at 2026-05-27 14:55)
- `.claude/skills/video-creation/references/audio-design.md` (head 50, read at 2026-05-27 14:55)
- `.tad/templates/handoff-a-to-b.md` (head 100, read at 2026-05-27 15:00)
- `.tad/project-knowledge/README.md` (head 80, read at 2026-05-27 14:58)
- `.claude/skills/video-creation/references/vimax-patterns.md` (new — will be created)
- `.tad/capability-packs/video-creation/references/vimax-patterns.md` (new — will be created)
- `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md` (new — will be created)

---

## 7. Implementation Steps

### Step 0: 捕获 pre-upgrade baseline（P0 — 验收必须）

⚠️ 必须在 ANY 修改之前做。验收要"upgrade 前 vs upgrade 后"对比，没有 baseline 无法判断。

1. 创建 evidence 目录：
```bash
mkdir -p .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation
```

2. 用 Task subagent 模拟 AI agent 调用当前 pack 处理 Photo-to-Beat-Sync 任务：
   - subagent_type: `general-purpose`
   - prompt 包含：(a) Read 当前 `.claude/skills/video-creation/SKILL.md` 和 references；(b) 任务："我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。你会怎么规划这个视频？输出你给 AI 视频生成器和音频工具的具体 prompt 和参数选择。"

3. 把 subagent 的完整 response 保存到 `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/pre-upgrade-output.md`。

4. 验证：`wc -l pre-upgrade-output.md` 应 > 30 行（确认 subagent 真的产出了内容）。

### Step 1: 验证 ViMax 源文件可访问

**优先顺序**（按可靠性排序）：
1. **NotebookLM notebook**（authoritative）：notebook id `79b4c4a9-f1b2-49cf-962f-3188b52426d5`。Blake 用 `~/.tad-notebooklm-venv/bin/notebooklm ask "..." -n <id>` 重新查询任何 ViMax 代码细节。
2. **GitHub 源**：https://github.com/HKUDS/ViMax — 各文件 blob URL 可读
3. **本地 clone**（可能已被清理）：`/tmp/vimax-source/`。如不存在：
```bash
cd /tmp && git clone --depth 1 https://github.com/HKUDS/ViMax.git vimax-source
```

**precondition**：如果 NotebookLM **且** GitHub **且** local clone 全部不可用 → 立即 escalate Alex，**不要**根据残缺信息写规则。

### Step 2: 写 `vimax-patterns.md` 第一个版本
按 §4 的 4 个 pattern 结构。每个 pattern 包含：
- H2 标题：`## Pattern N: 中文名（英文名）`
- "**ViMax 出处**" 行：`path/file.py` → `Class.method`
- "**关键 prompt 句**" 引用块（≤ 80 字符摘要 + 完整 prompt 路径）
- "**规则**" 区：触发条件 / 反模式 / 适用边界
- "**Grounded in**" 行：ViMax source URL + license attribution

文件结构（参考现有 `audio-design.md` 风格）：
```markdown
# ViMax-Inspired AI Video Pipeline Patterns

> Source: NotebookLM research notebook `video-creation-vimax-research` (38 sources)
> ViMax repo: https://github.com/HKUDS/ViMax (MIT License)
> Research findings: .tad/evidence/research/video-creation-vimax/2026-05-27-deep-ask-findings.md

---

## Quick Index

- Pattern 1: Visual Decomposition → §Pattern 1
- Pattern 2: Intent Routing → §Pattern 2
- Pattern 3: View-Specific Reference Selection → §Pattern 3
- Pattern 4: Camera Tree → §Pattern 4
- Photo-to-Beat-Sync Integration → §Integration Scene

---

## Pattern 1: Visual Decomposition
[内容按 §4 Pattern 1 写]

## Pattern 2: Intent Routing
[同上]

## Pattern 3: View-Specific Reference Selection
[同上]

## Pattern 4: Camera Tree
[同上]

---

## Integration Scene: Photo-to-Beat-Sync
[按 §4 Pattern 5 集成场景写]

---

## Cross-References

- `ai-asset-generation.md` §Seedance Endpoint Selection — Pattern 1+3 是其精细化
- `storytelling.md` §Video Type Patterns — Pattern 2 之后用
- `audio-design.md` §BPM-to-Video-Type — Photo-to-Beat-Sync 调用
- `visual-design.md` §GSAP Easing — Pattern 4 涉及构图时

## License Attribution

Patterns derived from HKUDS/ViMax (MIT License). Implementation rules adapted
for motion-graphics context. Original code at https://github.com/HKUDS/ViMax.
```

⚠️ **硬上限 400 行**（用户最关心 context 爆炸）。写完用 `wc -l` 验证。

### Step 3: 写 fixture 文件
`.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md`

内容：用户场景描述 + 预期 AI prompt 应包含的 marker：

```markdown
# Fixture: Photo-to-Beat-Sync Acceptance Scenario

## User Task
"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## Expected AI Agent Output Markers

When AI agent processes this task using the upgraded pack, the generated
prompt + plan MUST include:

1. **Intent classification**: explicit "montage" tag (Pattern 2)
2. **First/Last frame plan** per photo:
   - Each photo → "first_frame: <photo>, last_frame: <described>, motion: <described>"
   (Pattern 1)
3. **View consistency check**: if same person across photos, note view selection
   (Pattern 3)
4. **Scene cohesion**: if photos share location, camera-tree parent-child note
   (Pattern 4)
5. **BPM target**: explicit BPM from audio-design.md (montage → 20-80 BPM 情绪 OR 110-130 BPM lofi)
6. **Cut timing**: 6s / 3 photos = 2s per photo, align cuts with BPM beat
   (audio-design BPM-to-cut)

## Verification Command (post-impl)
Blake runs this fixture mentally OR with an AI agent in test mode, captures
the generated prompt, and checks for the 6 markers above. Report findings
in completion-report §AC Verification.
```

### Step 4: 更新 `SKILL.md` 的 Context Detection 表

⚠️ **Signal narrowness rule (P0 修正)**：避免与现有 motion graphics signals 冲突。**不要**使用 "animation / motion / cameo" 等宽泛词（会误触 GSAP-only 任务）。

在现有表格末尾加 1 行：
```markdown
| Seedance / image-to-video / first-last frame / 照片转视频 / photo-to-video / AI video clip / multi-shot scene | `references/vimax-patterns.md` |
```

**理由**：这些触发词都明确指向"AI 视频生成"上下文，与 GSAP / Remotion 2D 动效（HyperFrames 路线）正交。Step 7.6 会做 negative routing 验证。

### Step 5: 更新 `SKILL.md` 的 Quick Rule Index
在末尾加新章节：
```markdown
### ViMax Patterns (`references/vimax-patterns.md`)
- **Visual Decomposition Rule**: AI image-to-video → decompose into first_frame + last_frame + motion, never single description → §Pattern 1
- **Intent Router Rule**: every new video task → classify narrative/motion/montage FIRST → §Pattern 2
- **View-Specific Reference Rule**: character in ≥2 shots → generate front/side/back sheet → feed angle-matched view per shot → §Pattern 3
- **Camera Tree Rule**: multi-shot in same scene → child shot prompt MUST cite parent shot's spatial elements → §Pattern 4
```

### Step 6: 同步 `.tad/capability-packs/` 镜像（CAPABILITY.md 也要改）

⚠️ **P0 修正**：Step 4-5 修改的是 `.claude/skills/.../SKILL.md`。CAPABILITY.md 是 pack 源（install.sh 从这里安装），**必须并行更新**。两个文件都要加新 Context Detection 行 + 4 条 Quick Rule Index 摘要。

执行：
```bash
# 1. 把 vimax-patterns.md 复制到 capability-packs 镜像
cp .claude/skills/video-creation/references/vimax-patterns.md \
   .tad/capability-packs/video-creation/references/vimax-patterns.md

# 2. 验证 references 完全一致（AC2）
diff -q .claude/skills/video-creation/references/ \
        .tad/capability-packs/video-creation/references/
# 应输出为空

# 3. 把 SKILL.md 的 Context Detection 表新行 + Quick Rule Index 新章节 也加到 CAPABILITY.md
# （除 frontmatter `name:` / `description:` 行外，body 内容应一致 — 注意不要破坏 CAPABILITY.md 自己的 frontmatter）

# 4. 验证 CAPABILITY.md 同步（AC13）
grep -c 'vimax-patterns.md' .tad/capability-packs/video-creation/CAPABILITY.md
# 应输出 1
```

**Anti-pattern**：不要直接 `cp SKILL.md CAPABILITY.md` — frontmatter 不同会破坏 install.sh。只复制 body 改动。

**P1 note (tad.sh auto-sync)**：tad.sh:115 用 directory 遍历同步 references/，新增 vimax-patterns.md 会自动 propagate 到下游项目，**不需要**改 tad.sh。

### Step 7: Layer 1 自检
- `wc -l vimax-patterns.md` ≤ 400 ✅
- Markdown cross-references 链接有效（`§Pattern N` 锚点存在）
- 两边 references/ byte-identical（diff -q 空输出）
- SKILL.md frontmatter 完整（grep `^name:` + `^description:`）
- Quick Rule Index 新章节存在
- Context Detection 表新行存在
- CAPABILITY.md 也含 `vimax-patterns.md` 引用（AC13）

### Step 7.5: 捕获 post-upgrade output（P0 — 验收必须）

⚠️ **fixture markers 必须跟 SKILL.md Quick Rule Index 名一一对应**（P1-3 修正）：
- "Intent classification" ↔ Quick Rule "Intent Router Rule"
- "First/Last frame plan" ↔ Quick Rule "Visual Decomposition Rule"
- "View consistency check" ↔ Quick Rule "View-Specific Reference Rule"
- "Scene cohesion" ↔ Quick Rule "Camera Tree Rule"
- "BPM target" / "Cut timing" ↔ 现有 audio-design.md 规则

执行：
1. 用 **相同的** Task subagent 调用模式（同 Step 0），prompt 内容**完全相同**（"我有 3 张人像照片..."），但 subagent 现在能读到 upgraded pack（含 vimax-patterns.md）。
2. 把 response 保存到 `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md`。
3. 验证（AC15）：output 含 ≥ 4 个 ViMax pattern signal（first_frame / last_frame / intent classification / view-specific / camera tree）：
```bash
grep -ocE 'first.frame|last.frame|intent.+(narrative|motion|montage)|view-specific|camera.tree' \
  .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md \
  | sort -u | wc -l | tr -d ' '
# 期望 ≥ 4
```
4. 在 completion report §AC Verification 里写**对比摘要**：pre vs post 输出的关键差异（不要 paste 全文，只要 3-5 行 diff 性质的总结）。

### Step 7.6: Negative routing test（P1 修正 — 防止 signal 误触）

新 Context Detection signal 不应该匹配纯 GSAP/Remotion 任务。验证：

模拟一个 GSAP-only 任务的 user signal："I need GSAP easing for a fade-in animation on a button" 。手动检查 SKILL.md Context Detection 表：是否会路由到 vimax-patterns.md？

- 期望：**不会**（关键词 "GSAP easing / fade-in / button" 与 vimax-patterns 的 signals "Seedance / image-to-video / first-last frame / 照片转视频 / photo-to-video / AI video clip / multi-shot scene" 无重叠）
- 如果会误触 → 收紧 Step 4 signal 措辞，删掉过于宽泛的词
- 在 completion report §Negative Routing Test 记录：用了哪个 GSAP 触发词、检查结论（pass / fail）

### Step 8: Commit
```
feat(video-creation): add 4 ViMax patterns (decomposition/intent/view/camera-tree)

- New reference: vimax-patterns.md (4 patterns + Photo-to-Beat-Sync integration)
- SKILL.md: +1 Context Detection signal, +4 Quick Rule Index entries
- Synced to capability-packs/ source
- Photo-to-Beat-Sync fixture for acceptance testing
- ViMax MIT license attributed

Research: notebook 79b4c4a9 (38 sources)
Findings: .tad/evidence/research/video-creation-vimax/
```

---

## 8. Required Evidence Manifest

| Evidence | Path | Format |
|----------|------|--------|
| Reference file (skills/) | `.claude/skills/video-creation/references/vimax-patterns.md` | Markdown, ≤ 400 lines |
| Reference file (capability-packs/) | `.tad/capability-packs/video-creation/references/vimax-patterns.md` | byte-identical to above |
| SKILL.md updated | `.claude/skills/video-creation/SKILL.md` | Context Detection + Quick Rule Index added |
| CAPABILITY.md updated | `.tad/capability-packs/video-creation/CAPABILITY.md` | mirror of SKILL.md changes |
| Fixture | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md` | Markdown, ≤ 80 lines |
| Pre-upgrade output (baseline) | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/pre-upgrade-output.md` | Subagent raw response, ≥ 30 lines |
| Post-upgrade output | `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md` | Subagent raw response, ≥ 30 lines |
| Completion report | `.tad/active/handoffs/COMPLETION-20260527-vimax-pattern-upgrade-video-creation.md` | Standard template + §AC Verification with pre/post diff summary + §Negative Routing Test record |
| Layer 2 expert reviews | `.tad/evidence/reviews/blake/vimax-pattern-upgrade-video-creation/{reviewer}-review.md` | Per-reviewer findings |
| Knowledge updates | `.tad/project-knowledge/{category}.md` | Add entries if discoveries |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected | Verification Type |
|---|----|---------------------|----------|-------------------|
| AC1 | vimax-patterns.md 存在于两个位置 | `test -f .claude/skills/video-creation/references/vimax-patterns.md && test -f .tad/capability-packs/video-creation/references/vimax-patterns.md && echo OK` | OK | pre-impl-verifiable (will be after creation) |
| AC2 | 两个位置内容 byte-identical | `diff -q .claude/skills/video-creation/references/vimax-patterns.md .tad/capability-packs/video-creation/references/vimax-patterns.md` | (empty output) | post-impl |
| AC3 | vimax-patterns.md ≤ 400 行 | `wc -l < .claude/skills/video-creation/references/vimax-patterns.md` | ≤ 400 | post-impl |
| AC4 | 4 个 pattern section 都存在 | `grep -c '^## Pattern [1-4]:' .claude/skills/video-creation/references/vimax-patterns.md` | 4 | post-impl |
| AC5 | Photo-to-Beat-Sync 集成 section 存在 | `grep -c '^## Integration Scene: Photo-to-Beat-Sync' .claude/skills/video-creation/references/vimax-patterns.md` | 1 | post-impl |
| AC6 | 每个 pattern 含 ViMax 出处 attribution + 真实 Python path | `grep -cE '\*\*ViMax 出处\*\*.+\.py\|ViMax source.+\.py' .claude/skills/video-creation/references/vimax-patterns.md` | ≥ 4 | post-impl |
| AC7 | ViMax MIT license attribution 存在 | `grep -c 'MIT License' .claude/skills/video-creation/references/vimax-patterns.md` | ≥ 1 | post-impl |
| AC8 | SKILL.md Context Detection 表加新 signal 行 | `grep -c 'vimax-patterns.md' .claude/skills/video-creation/SKILL.md` | = 1 | post-impl |
| AC9 | SKILL.md Quick Rule Index 加 4 条新规则 | `grep -cE 'Visual Decomposition Rule\|Intent Router Rule\|View-Specific Reference Rule\|Camera Tree Rule' .claude/skills/video-creation/SKILL.md` | = 4 | post-impl |
| AC10 | Fixture 文件存在并含 6 unique markers | `grep -oE 'Intent classification\|First/Last frame plan\|View consistency check\|Scene cohesion\|BPM target\|Cut timing' .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md \| sort -u \| wc -l \| tr -d ' '` | 6 | post-impl |
| AC11 | Pack frontmatter (YAML) 仍完整 | `head -3 .claude/skills/video-creation/SKILL.md \| grep -cE '^name:\|^description:'` | = 2 | post-impl |
| AC12 | Cross-references 到现有 references 有效 | `grep -oE 'audio-design\.md\|ai-asset-generation\.md\|storytelling\.md\|visual-design\.md' .claude/skills/video-creation/references/vimax-patterns.md \| sort -u \| wc -l \| tr -d ' '` | ≥ 3 | post-impl |
| AC13 | CAPABILITY.md 也加了新 signal 行（mirror SKILL.md） | `grep -c 'vimax-patterns.md' .tad/capability-packs/video-creation/CAPABILITY.md` | = 1 | post-impl |
| AC14 | Pre-upgrade baseline output 已捕获（Step 0） | `test -s .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/pre-upgrade-output.md && echo OK` | OK | post-impl |
| AC15 | Post-upgrade output 已捕获且含 ≥4 个 ViMax pattern signal | `grep -ocE 'first.frame\|last.frame\|intent.+(narrative\|motion\|montage)\|view-specific\|camera.tree' .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md \| sort -u \| wc -l \| tr -d ' '` | ≥ 4 | post-impl |
| AC16 | Context Detection 新 signal 不会误触 GSAP-only 任务 | 见 §7 Step 7.6 negative routing test：用一个纯 GSAP/Remotion 触发词（"GSAP easing for fade-in"）跑 pack signal 匹配，期望 vimax-patterns.md 不在加载列表中 | 见 Step 7.6 | post-impl |

### 9.2 Expert Review Status

Reviewers: 2 (code-reviewer + product-expert), both returned CONDITIONAL PASS. All P0 + key P1 integrated.

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC12 regex `\|` 在 grep -E 是字面值，会 always 返回 0 | §9.1 AC12 — 删反斜杠 + 加 `\.` 转义 | Resolved |
| code-reviewer | P0-2: AC10 `grep -c` 数行而非 occurrences，markers 同一行/重复会假阳性/假阴性 | §9.1 AC10 — 改用 `grep -oE \| sort -u \| wc -l` | Resolved |
| code-reviewer | P0-3: AC6 只验"**ViMax 出处**"结构标记，不验 Python path | §9.1 AC6 — 加 `.+\.py` 要求 | Resolved |
| code-reviewer | P0-4: Step 6 没验证 CAPABILITY.md sync | §7 Step 6 重写 + §9.1 新增 AC13 | Resolved |
| code-reviewer | P1-1: 缺 CAPABILITY.md update 对应 AC | §9.1 AC13（同上） | Resolved |
| code-reviewer | P1-2: tad.sh:115 已 auto-sync references/，handoff 应明示 | §7 Step 6 末尾 + §10.5 | Resolved |
| code-reviewer | P1-3: fixture markers 应 1:1 映射 SKILL Quick Rule Index 名 | §7 Step 7.5 序号 mapping 表 | Resolved |
| code-reviewer | P1-4: Step 1 fallback 顺序应 notebook → github → /tmp/ | §7 Step 1 重写优先序 | Resolved |
| code-reviewer | P2-A: AC8 应 `= 1` 而非 `≥ 1`（防重复） | §9.1 AC8 改为 `= 1` | Resolved |
| product-expert | P0-A: fixture "心算" 不算执行，AC10 collapses to "Blake wrote a file" | §7 Step 7.5 强制 Task subagent 实跑 + 新 AC15 验证 output 含 ≥4 pattern signal | Resolved |
| product-expert | P0-B: 没 pre-upgrade baseline → "improvement" 无对比 | §7 Step 0 新增 baseline 捕获 + §9.1 AC14（baseline exists）+ Step 7.5 输出对比 | Resolved |
| product-expert | P1-A: Context Detection signal 过宽，会误触 GSAP-only 任务 | §7 Step 4 narrow signal + §7 Step 7.6 negative routing test + §9.1 AC16 | Resolved |
| product-expert | P1-B: Open Q2 需补"notebook+code 都不可用时 escalate"precondition | §7 Step 1 precondition + §12 Q2 改写 | Resolved |
| product-expert | P2-A: Decision 2 应承认 Pattern 3 在首批场景可能不触发 | §11 新增 Decision 6 | Resolved |
| product-expert | P2-B: 单向 cross-references 造成 pack graph 不透明 | Deferred — §10.4 现有规则禁止改其他 references；Blake 不动 | Deferred |

### AC Dry-Run Log (Alex step1d, re-run after P0 fixes at 2026-05-27 15:30)

**Escaping convention**: All `\|` in table cells are markdown pipe escapes — actual shell command should use `|` (raw pipe). Dry-run validates the RAW shell form per SKILL §step1d Sub-rule 1.

| AC | Type | Status | Note |
|----|------|--------|------|
| AC1 | post-impl | ✅ syntax-validated | `test -f && test -f && echo OK` parses |
| AC2 | post-impl | ✅ syntax-validated | `diff -q` parses; empty stdout = identical |
| AC3 | post-impl | ✅ syntax-validated | `wc -l < file` parses |
| AC4 | post-impl | ✅ syntax-validated | `grep -c '^## Pattern [1-4]:' ...` — BSD grep OK |
| AC5 | post-impl | ✅ syntax-validated | `grep -c '^## Integration Scene: ...'` — literal match |
| AC6 | post-impl | ✅ syntax-validated (fixed P0-3) | RAW: `grep -cE '\*\*ViMax 出处\*\*.+\.py\|ViMax source.+\.py' file` — counts lines matching pattern with .py path |
| AC7 | post-impl | ✅ syntax-validated | `grep -c 'MIT License'` literal |
| AC8 | post-impl | ✅ syntax-validated (fixed P2-A: = 1) | `grep -c 'vimax-patterns.md'` |
| AC9 | post-impl | ✅ syntax-validated (fixed P0-1: -E flag) | RAW: `grep -cE 'Visual Decomposition Rule\|Intent Router Rule\|View-Specific Reference Rule\|Camera Tree Rule'` — `-cE` correctly treats `\|` as OR |
| AC10 | post-impl | ✅ syntax-validated (fixed P0-2: unique-count) | RAW: `grep -oE '...marker_list...' file \| sort -u \| wc -l \| tr -d ' '` — counts UNIQUE markers, not lines |
| AC11 | post-impl | ✅ syntax-validated | `head -3 \| grep -cE '^name:\|^description:'` |
| AC12 | post-impl | ✅ syntax-validated (fixed P0-1) | RAW: `grep -oE 'audio-design\.md\|ai-asset-generation\.md\|storytelling\.md\|visual-design\.md' file \| sort -u \| wc -l \| tr -d ' '` — `\.` properly escapes dot in ERE |
| AC13 | post-impl | ✅ syntax-validated (new — P0-4) | `grep -c 'vimax-patterns.md' CAPABILITY.md` |
| AC14 | post-impl | ✅ syntax-validated (new — P0-B) | `test -s file && echo OK` — `-s` requires non-empty |
| AC15 | post-impl | ✅ syntax-validated (new — P0-A) | `grep -ocE '...' \| sort -u \| wc -l \| tr -d ' '` — counts unique pattern signals in post-output |
| AC16 | post-impl | manual — see §7 Step 7.6 (new — P1-A) | Negative routing test; not a one-liner — Blake checks SKILL.md signal does NOT match GSAP-only trigger phrase |

**Pre-impl validation**: N/A — all target files don't exist yet (handoff scope is CREATE / MODIFY). Sub-rule 2 (syntax validation) applied to all 16 ACs. Sub-rule 3 (re-derive pre-impl values) N/A.

**Bash dry-run executed for new/fixed ACs** (against synthetic mock file containing all expected markers): AC9 / AC10 / AC12 / AC15 all return correct counts. Documented in completion-report when Blake runs them against real files.

---

## 10. Important Notes

### 10.1 Risk: Rule Bloat / Context Explosion

**用户最大顾虑**：4 个新章节让 pack 体积膨胀，AI 加载 reference 时 context window 压力增大。

**防控措施**：
1. 硬上限 ≤ 400 行 — `wc -l` 是 AC3 的验证标准
2. 紧凑格式：每个 pattern 章节按现有 audio-design.md / storytelling.md 风格写（quick-rule + 表格 + 出处 attribution），避免 prose 长篇大论
3. 单独 reference 文件 — 无关任务不会加载（SKILL.md 路由按 signal 触发）
4. Cross-reference 而不是 duplicate — 与现有 references 链接，不重复其规则

### 10.2 Risk: 翻译失真

ViMax 是 Python 代码（class + method），我们 pack 是 markdown 判断规则。翻译时容易丢失：
- prompt 模板的精确措辞
- fallback 逻辑（如 BestImageSelector 的 idx=0 fallback）
- 边界条件

**防控**：每个 pattern 章节必须包含：
- ViMax 完整路径 + class.method 名
- prompt 关键句的原文引用（即使是节选）
- 适用边界（"motion-graphics-only" vs "AI-video-generation-only"）

### 10.3 Pattern 5 (Global Character Merge) 明确排除

NotebookLM 在 deep-ask 分析中明确标记 "NOT VALUABLE" 给我们的 motion graphics 上下文（多 scene character 状态合并是给几十分钟长片用的）。本 handoff **不**做 Pattern 5。Blake 不需要 try to implement，也不需要 mention in vimax-patterns.md（避免 noise）。

### 10.4 Anti-Patterns（Blake 必须避免）

- ⚠️ 不要把 ViMax 的 Pydantic schema 字面复制到 markdown — 翻译为判断规则
- ⚠️ 不要超过 400 行硬上限 — 即使内容更多，要砍 / 压缩
- ⚠️ 不要忘记 capability-packs/ 镜像同步 — references/ + CAPABILITY.md 都要 sync（两边内容一致，frontmatter 不动）
- ⚠️ 不要去研究 ViMax 的国内 API 实现细节（Yunwu / Doubao / Nanobanana 等 tools/）— 与本任务无关
- ⚠️ 不要修改其他 references/*.md 的内容（只允许 SKILL.md 加 2 处 + CAPABILITY.md 加 2 处 + 新建 vimax-patterns.md）
- ⚠️ 不要直接 `cp SKILL.md CAPABILITY.md` — 两文件 frontmatter 不同，复制会破坏 install.sh

### 10.5 Infrastructure Notes

- **tad.sh sync 已 auto-handle**: tad.sh:115 用 directory 遍历同步 references/，新增 vimax-patterns.md 会自动 propagate 到所有 registered projects。**不需要**改 tad.sh。
- **install.sh 已 auto-handle**: capability-packs/video-creation/install.sh 把整个 references/ 复制到 .claude/skills/，新文件同样自动覆盖。
- **不动 hooks / settings.json**: 本 handoff 是 prompt-level 规则添加，无 hook 触发逻辑变化。

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Pack 落地位置 | (a) 新建 vimax-patterns.md / (b) 加到 ai-asset-generation.md / (c) 拆到多个现有 / (d) 新建子目录 | (a) 新建单文件 | 用户在 Socratic step5 明确选 Recommended option a |
| 2 | 4 个 pattern 全做 vs 分批 | (a) Standard TAD 单 handoff 4 个 / (b) Epic 2 phases | (a) 单 handoff 全做 | 用户选 Standard TAD + "4 个一视同仁做扎实" |
| 3 | 验收场景 | (a) 产品介绍 / (b) 品牌片 / (c) 社交短片 / (d) 用户自定义 = Photo-to-Beat-Sync | (d) Photo-to-Beat-Sync | 用户真实首批应用场景，覆盖 4 个 pattern + 与 audio-design 集成 |
| 4 | Pattern 5 是否包含 | (a) 做 / (b) 不做 | (b) 不做 | NotebookLM 诚实标记 NOT VALUABLE for our context |
| 5 | License 处理 | (a) 提取代码片段 / (b) 引用 + attribution | (b) | ViMax MIT 允许，attribution 即可，避免代码复制 |
| 6 | Pattern 3 在首批 Photo-to-Beat-Sync 场景的命中率 | (a) 削减 Pattern 3 / (b) 保留但承认 deferred value | (b) | product-expert 指出：用户首批场景是 5 张独立人像（不同主体），Pattern 3 仅在"同一角色 ≥2 shot 含不同角度"时触发，可能不命中。但 Pattern 3 仍是"future asset"价值的合理组成（后续多主体视频会用到），保留。完成 report 应记录"首批是否实际触发 Pattern 3"作为价值跟踪信号。 |

---

## 12. Open Questions for Blake

如果实施过程中遇到以下情况，**escalate 给 Alex**（不要自己决定）：

1. 如果 400 行硬上限不够装下 4 个 pattern + Photo-to-Beat-Sync — 哪个 pattern 砍 / 怎么压缩？
2. 如果 NotebookLM 重新查询发现 ViMax 代码细节与本 handoff 描述不一致 — **答案明确：代码为准（NotebookLM 或 GitHub 上的 ViMax 源），handoff §4 是 Alex 当时理解的快照，可能不全**。**Precondition**：如果 NotebookLM **且** GitHub URL **且** local clone 全部不可用（Step 1 precondition 触发）→ 立即 escalate，**不要**基于残缺信息写规则。
3. 如果发现 vimax-patterns.md 跟现有某个 reference（如 ai-asset-generation.md 的 Seedance 规则）有规则冲突 — 哪边优先？
4. 如果 Step 7.5 post-upgrade output 跟 pre-upgrade output 几乎没差异（新 pack 没影响 subagent 行为）— 说明 pack 规则没有被 subagent 应用，escalate 排查 SKILL 路由 / Quick Rule Index 措辞问题。
5. 如果 Step 7.6 negative routing test 失败（vimax-patterns.md 在 GSAP-only 任务中被路由触发）— escalate，需要收紧 Context Detection signal 措辞。

---

## 13. References

- **ViMax 仓库**：https://github.com/HKUDS/ViMax (MIT License, 7.7K stars)
- **ViMax 本地 clone**：`/tmp/vimax-source/` (Alex shallow-cloned, may be cleaned)
- **NotebookLM notebook**：`79b4c4a9-f1b2-49cf-962f-3188b52426d5` (38 sources, 1 deep-ask round)
- **Research findings**：`.tad/evidence/research/video-creation-vimax/2026-05-27-deep-ask-findings.md`
- **TAD pack 当前版本**：`.claude/skills/video-creation/SKILL.md` (v0.1.0)
- **Project Knowledge**：`.tad/project-knowledge/architecture.md` (Capability Pack 相关 entries)

---

**Alex 确认**：我已验证所有设计要素，Blake 可以独立按本文档完成实现。
