# Structured Feedback Collector — NotebookLM Cross-Source Findings
Date: 2026-06-10
Notebook: 8c456e11-9ef3-4d28-8b06-6efd2cbf0639 (66 sources)

---

## Q1: Element-Level Feedback Patterns Across Tools

### Tools with point-and-click element feedback (NOT just chat):
1. **Vercel v0 Design Mode** — Cursor = DOM selection tool. Click element → design panel (typography, color, layout, text) + screenshot-anchored natural language prompt. Compiles to Tailwind-compatible code patch.
2. **Lovable Visual Edits** — WYSIWYG overlay on live preview. Style changes = zero token cost. Logic changes = credit tokens. Cross-functional friendly (PM/designer can edit freely).
3. **Dualite Interaction Mode** — Blue-overlay selection boxes on elements. Click → conversational prompt scoped to that element. Compiles to React Native.
4. **Frontman** — MCP server on REAL local app (not sandbox). Click element in running browser → AI modifies actual source files via hot module replacement.
5. **Midjourney Vary Region / Smart Select** — Lasso/rectangular selection on image. Drop positive/negative coordinate points for auto-mask calculation.
6. **Runway Inpainting** — Brush mask + auto-dilation (10px). Chronological keyframing for temporal tracking.
7. **ElevenLabs Studio 3.0** — Timestamp-anchored comments on timeline. Aggregated into sidebar checklist.
8. **FusAIn** — Experimental "smart pens" loaded with textures/colors, applied via spatial strokes.

### Common abstraction: Metadata Isolation for Non-Destructive Iteration
All tools decouple targeted element from rest of artifact:
- UI Builders: click → DOM/component hierarchy → extract CSS/selector → pass localized context to LLM
- Media Tools: click/brush → spatiotemporal coordinates → restrict regeneration to masked region/node
- Pattern: translate human spatial/tactile inputs into technical boundaries → AI patches local fragment without destroying global structure

### Tools generating BOTH artifact AND review interface:
- **ElevenLabs Studio 3.0**: generates media + secure public review URL with timestamp comments → sidebar checklist
- **Figma Weave**: builds node graph → packages into simplified "mini-app" for non-technical review
- **v0/Lovable/Dualite**: generate code + interactive preview with editing overlay

---

## Q2: Gaps and Unsolved Problems

### 1. No cross-media unified feedback system exists
- CapCut Studio & ElevenLabs Flows unify WORKFLOW (multiple models on one canvas)
- But still use model-specific feedback interventions, not a universal feedback language
- **GAP: No tool has a Universal Coordinate Protocol across DOM + pixel masks + audio transcripts**

### 2. Adaptive granularity is a major unsolved problem
- Too coarse: "cumulative generation drift" — repeated iterations diverge from original intent
- Too fine: "entropy challenge" — information overload, attentional fragmentation
- Structural Interaction Framework theory: should shift from "negotiable/liftable" (ideation) to "fixed/persistent" (execution)
- **GAP: Current tools have NO mechanism to dynamically shift granularity by workflow phase**

### 3. Missing for non-technical users:
- **Reifying tacit knowledge**: turn invisible AI logic into named, manipulatable tokens (not verbal prompts)
- **Configurable multimodal scaffolds**: separate sliders for different intent dimensions (lock color, change semantic tag)
- **Decouple iteration from credit consumption**: WYSIWYG layer for structural edits without burning AI tokens
- **Explainability**: visual confidence indicators, AI vs human contribution highlighting

---

## Q3: Architectural Principles for Universal Feedback System

### 5 Key Design Principles (from evidence):
1. **Decouple visual/structural editing from token consumption** — credit-free WYSIWYG overlay for simple tweaks
2. **Reify tacit intent into configurable scaffolds** — extract intent into drag-and-drop tokens, not text prompts
3. **Implement explanatory feedback emphasis** — confidence indicators, color-coded AI vs human contributions
4. **Enforce review-driven development checkpoints** — generate implementation plan before execution, allow comments
5. **Node-graph architecture** — isolated nodes, feedback on one node only regenerates that node + downstream dependents

### Closest existing tools to the vision:
- **Figma Weave** — generates artifact + packages into mini-app for non-technical review (closest to "generate both")
- **ElevenLabs Studio 3.0** — feedback aggregation (timestamp comments → sidebar checklist)
- **Narrix** — proves cross-medium metaphor works (DAW timeline applied to text storytelling)

### What's missing for universality:
**Universal Coordinate Protocol** — abstract DOM/pixel masks/audio timestamps into a single interaction language. One selection tool works across React button + snare drum beat + video frame.

---

## Implications for TAD Structured Feedback Collector

### What we can learn:
1. Our Colin project pattern (card + preview + structured options + free text → JSON) is a VALID and novel approach — no existing tool does exactly this for non-code artifacts
2. The "AI generates review interface alongside artifact" concept exists in fragments (ElevenLabs, Figma Weave) but nobody has generalized it as a PATTERN
3. Adaptive granularity (coarse→fine across iterations) is an UNSOLVED PROBLEM — if we solve it, we're ahead of the market
4. Credit-free WYSIWYG editing (Lovable pattern) is a key UX insight — feedback should be zero-cost
5. Node-graph non-destructive iteration (ElevenLabs Flows) is the right architecture for multi-element artifacts

### Our unique positioning:
- Existing tools are medium-specific (UI only, video only, audio only)
- We're proposing a UNIVERSAL abstraction: [previewable element] + [AI analysis] + [structured options] + [free input] → JSON
- The JSON-as-feedback-protocol is simpler and more portable than any existing approach
- Integration with TAD workflow (Gate 4 business acceptance) adds a quality loop that no creative tool has

---

## Q4: Narrix 跨媒介隐喻深度剖析

### 核心机制：DAW → 文字叙事的映射
- **音频片段 → "故事块"**：用户段落/场景按顺序排在主轨道上
- **音频滤镜 → "叙事策略"**：感官意象、信息隐藏、戏剧反讽等作为"滤镜"叠加
- **乐器轨道 → "创意维度"**：情节、角色、信息、情感、语言、节奏、主题、参与度

### 交互方式
- 从策略库拖拽策略卡片到对应维度轨道
- 拉伸/缩小策略块控制作用范围（跨多少个故事块）
- 点击特定块的"修改"按钮 → AI 只重新生成该块，受其下方策略层驱动

### 底层数据模型
1. LLM 将连续文本分割为离散"块"（X轴 = 进程）
2. LLM 分析每个块提取叙事策略 → JSON schema（标签 + 解释 + 原文锚点）
3. NRC VAD 词典映射情感轨迹 → 0-1 量化情感弧线

### 失败点（关键！）
- **跨块不连贯**：音频加混响不影响下一段旋律，但文字有因果链——隔离编辑破坏全局连贯性
- **缺乏 A/B 并行对比**：DAW 可以 solo/mute 轨道即时对比，Narrix 没有
- **长内容无法缩放**：扁平时间线对 50 页小说完全不可用，缺乏层级嵌套（段落→场景→章节）

### 对我们的启示
- 跨媒介隐喻的可行性已证明，但必须解决"因果链"问题（文字/视频的前后依赖 vs 音频的独立轨道）
- 层级嵌套是必须的（不能只有扁平列表）
- A/B 对比能力要内置

---

## Q5: 认知负荷与反馈疲劳

### 没有"魔法数字"，但有设计原则
- 学术界没有给出"一次能评价几个元素"的硬数字
- 核心发现：问题不在"展示多少"，而在"怎么展示"
- 过度披露 + 频繁确认 → 打断心流 → 情境感知能力下降

### 降低认知负荷的 4 个设计模式
1. **渐进式披露 + 多面板布局**：分步展示，上下文与编辑区分离
2. **基于置信度的优先排序**：AI 按确定性排序，让用户先看最靠谱的
3. **选择性、按风险触发的透明度**：只在高风险时要求人类注意，提供可调阈值
4. **视觉高亮区分**：颜色编码区分 AI 生成 vs 人类内容

### 结构化 vs 自由文本的最优比例
- **不是固定比例，而是按阶段动态切换**：
  - 构思阶段 → 偏自由文本（头脑风暴、粗线条）
  - 执行阶段 → 偏结构化（分解意图为离散可操作单元）
  - 混合工作流：先 Chat 快速搭建，再切换到结构化编辑空间

### 对我们的启示
- Colin 项目的做法已经符合最佳实践（卡片 = 渐进披露，OK/Redo = 结构化，评语 = 自由文本）
- 需要加入：置信度排序（AI 不确定的元素排在前面让人类优先审查）
- 需要加入：按阶段自动切换粒度（第一轮粗，后面细）

---

## Q6: 行业趋势与竞争窗口

### 这是收敛趋势，不是孤立决策
- Figma Weave、ElevenLabs Studio 3.0、CapCut 无限画布都在解同一个问题：从"prompt-and-pray"转向"隔离式非破坏性反馈"
- 统一模式：将产出物解耦为隔离的模块化节点/空间坐标，允许人类修改一个片段而不破坏全局

### 大厂在做什么
- **Google Antigravity**：Review-Driven Development，AI 生成实现计划 → 人类用 Google Docs 式评论反馈
- **Anthropic + Pika (MCP)**：MCP 作为 AI 与实时编辑工具之间的桥梁标准
- **Figma 收购 Weavy → Weave**；**Canva 收购 Leonardo AI** → 大厂通过收购获取这个能力层

### 窗口期：月级别，不是年级别
- 大厂倾向于收购而非自建 workflow 层
- 独立的反馈 UI 包装器生命周期很短
- 如果今天开始建通用抽象，可能只有几个月领先窗口

### 护城河在哪里
- ❌ 不在 UI 模式（无限画布和聊天界面很容易复制）
- ❌ 不在生成模型本身
- ✅ **Workflow-to-App 打包**（把复杂流程打包成非技术人员可用的 mini-app）
- ✅ **Spec-Driven Development**（拥有中间规格层作为 source of truth）
- ✅ **把逻辑与 token 成本解耦**（样式编辑不消耗 AI token）
- ✅ **拥有结构行为规则**（定义元素在人类推动时如何让步、适应、锁定）

### 对我们的启示
- TAD 集成是真正的差异化：我们不是做一个独立的反馈 UI 工具（会被大厂吃掉），而是把反馈协议嵌入一个方法论框架
- JSON-as-feedback-protocol 可以成为 "spec layer"（中间规格层）
- 与 Gate 4 集成 = "Review-Driven Development" 的落地版本
