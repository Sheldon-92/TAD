# Handoff: Frontend Design Playground

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-04
**Task ID:** TASK-20260204-001
**Priority:** P1
**Complexity:** Large (Full TAD)
**Status:** Ready for Implementation

---

## Expert Review Status

| Expert | Verdict | P0 Issues | P1 Issues |
|--------|---------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → RESOLVED | 4 (all fixed) | 6 (key items fixed) |
| ux-expert-reviewer | CONDITIONAL PASS → RESOLVED | 4 (all fixed) | 5 (key items fixed) |

### P0 Issues Resolved

**Code Reviewer P0s:**
- P0-1: YAML block clarified as reference spec, not copy-paste ✅
- P0-2: Protocol structure aligned with TAD patterns (violations, tool, step naming) ✅
- P0-3: Exact config.yaml update line specified ✅
- P0-4: Keyword triggers split into strong/weak signals with context requirement ✅

**UX Expert P0s:**
- P0-1: Progressive disclosure selection flow (direction → details) ✅
- P0-2: Clear "not satisfied" path with max 2 iterations + fallback ✅
- P0-3: Measurable consistency metrics + Gate 4 verification checklist ✅
- P0-4: WCAG AA accessibility mandatory in playground-guide.md ✅

---

## Executive Summary

为 TAD 框架新增 **Frontend Design Playground** 能力，解决非设计背景用户在前端开发中"缺乏把控感"的核心痛点。Playground 是 Alex *design 阶段的子流程：当任务涉及前端/UI 时，Alex 先做设计研究（网络搜索同类产品、趋势、最佳实践），然后生成浏览器可预览的 HTML 页面，提供多组配色/字体/组件/布局/动效方案供用户选择。选定后导出为 Design Tokens + 组件规范 + project-knowledge，成为 Blake 实现的精确参考。

**核心价值**: 将前端设计从"文字描述→盲猜实现→事后调整"变为"可视化预览→主动选择→精确实现"。

---

## 📋 Handoff Checklist (Blake 必读)

Blake 在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回 Alex 要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

为 TAD 框架增加 `*playground` 命令（作为 Alex *design 的子流程），包含：
1. **Research Protocol**: Alex 在生成方案前必须做的设计研究流程
2. **HTML Playground Template**: 可在浏览器中交互预览的设计方案展示页
3. **Selection & Export Protocol**: 用户选择后导出为可执行的设计规范
4. **Project Knowledge Integration**: 设计决策持久化为项目知识

### 1.2 Why We're Building It

**业务价值**: 非设计背景的用户无法在纯文字 handoff 中对前端设计建立预期，导致实现结果与期望偏差大、反复调整浪费时间。

**用户受益**: 在 5 分钟内看到多组专业级设计方案并做出选择，获得对前端开发的掌控感。

**成功的样子**: 当用户能在浏览器中对比不同配色/字体/布局方案，选定后 Blake 按照精确的 Design Tokens 实现出 80%+ 视觉一致性时，这个功能就成功了。

### 1.3 Intent Statement

**真正要解决的问题**: 前端设计阶段的信息不对称——用户脑中的画面和 Alex 文字描述之间的鸿沟。

**不是要做的（避免误解）**:
- ❌ 不是一个完整的设计工具（如 Figma）
- ❌ 不是让 Alex 写产品代码（HTML 预览是设计产物，不是最终代码）
- ❌ 不是替代 Blake 的前端实现（Playground 提供方向，不是可部署的代码）

---

## 📚 Project Knowledge (Blake 必读)

### 步骤 1: 识别相关类别

本次任务涉及的领域：
- [x] architecture - TAD 框架架构变更
- [x] ux - 用户体验设计流程
- [ ] code-quality
- [ ] security
- [ ] performance
- [ ] testing
- [ ] api-integration
- [ ] mobile-platform

### 步骤 2: 历史经验摘录

**已读取的 project-knowledge 文件**:

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 检查 | TAD 框架架构决策记录 |

**⚠️ Blake 必须注意的历史教训**:
- TAD 框架修改时，所有 agent 命令文件的修改必须保持与 config.yaml 模块绑定一致
- 新增协议时遵循现有 YAML protocol 格式（参考 socratic_inquiry_protocol, handoff_creation_protocol 的结构）

---

## 2. Background Context

### 2.1 Current State (Problem)

TAD 的 Alex *design 阶段目前是纯文字驱动的：
- Alex 用 Markdown 描述 UI 设计
- 用户无法在实现前"看到"最终效果
- 设计决策（配色、字体、组件风格）没有可视化验证环节
- 结果：前端实现后频繁返工，用户始终缺乏把控感

### 2.2 Target State

```
Alex *design 阶段（涉及前端时）:
  1. Research     → Alex 搜索同类产品、设计趋势、最佳实践
  2. *playground  → 生成 HTML 预览页（多组方案）
  3. User Review  → 用户在浏览器中查看、对比、选择
  4. Export       → 导出 Design Tokens + 组件规范
  5. Handoff      → 精确的视觉规范传递给 Blake
```

### 2.3 Dependencies

- TAD v2.2.1 框架（已就绪）
- Alex 的 *design 命令流程（已存在，需扩展）
- Project-knowledge 系统（已就绪）
- Web search 能力（Alex 已有）

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: Alex 在 *design 阶段检测到前端/UI 任务时，自动建议启动 Playground
- **FR2**: Alex 在生成 Playground 前，必须执行设计研究（web search 同类产品、趋势）
- **FR3**: 生成自包含的 HTML 文件，在浏览器中可直接打开预览
- **FR4**: HTML 预览包含多组方案：配色(2-3)、字体(2-3)、组件风格(2-3)、页面布局(2-3)
- **FR5**: 用户在浏览器中查看后，通过 AskUserQuestion 告知 Alex 选择结果
- **FR6**: 选定方案导出为 Design Tokens (CSS variables + JSON/Tailwind config)
- **FR7**: 设计决策写入 `.tad/project-knowledge/frontend-design.md`
- **FR8**: 导出的 Design Tokens 和组件规范嵌入到后续 Handoff 文档中

### 3.2 Non-Functional Requirements

- **NFR1**: HTML 预览零依赖——不需要 npm install、不需要启动服务器
- **NFR2**: 方案质量下限为"业界平均水平以上"——基于研究而非随意生成
- **NFR3**: 配色/字体在 Playground 和最终实现之间必须保持一致（通过 Design Tokens 传递）
- **NFR4**: 框架无关——Design Tokens 可适配 React/Vue/Svelte/plain HTML 等任何技术栈
- **NFR5**: 用户从看到 Playground 到做出选择应在 5 分钟内完成

---

## 4. Technical Design

### 4.1 Architecture Overview

```
                  Alex *design Phase
                        │
                  ┌─────▼──────┐
                  │ Frontend    │
                  │ Detection   │──── "任务涉及 UI 吗？"
                  └─────┬──────┘
                        │ Yes
                  ┌─────▼──────┐
                  │ Research    │──── Web search + codebase scan
                  │ Protocol    │     (同类产品、趋势、现有设计)
                  └─────┬──────┘
                        │
                  ┌─────▼──────┐
                  │ Playground  │──── 生成 HTML 预览
                  │ Generation  │     (配色/字体/组件/布局/动效)
                  └─────┬──────┘
                        │
                  ┌─────▼──────┐
                  │ User        │──── 浏览器预览 → AskUserQuestion
                  │ Selection   │
                  └─────┬──────┘
                        │
                  ┌─────▼──────┐
                  │ Export &    │──── Design Tokens + 组件规范
                  │ Persist     │     + project-knowledge
                  └─────┬──────┘
                        │
                  Continue *design → *handoff
```

### 4.2 *playground Protocol (Alex's New Sub-Command)

> **Note for Blake**: This YAML below is a **reference specification**. When implementing, adapt it to match the existing protocol patterns in tad-alex.md (e.g., `socratic_inquiry_protocol`, `handoff_creation_protocol`). Do NOT copy-paste verbatim—align naming conventions, indentation, and structure with what already exists.

```yaml
playground_protocol:
  description: "Frontend Design Playground - research-driven visual design exploration"
  owner: "Alex"
  tool: "AskUserQuestion"
  trigger: "Alex *design phase when task involves frontend/UI"
  blocking: false  # Trigger is non-blocking (user can decline); research_phase IS blocking once accepted
  prerequisite: "Socratic Inquiry completed (or in-progress *design phase)"

  violations:
    - "不做 web search 研究直接生成 Playground = VIOLATION"
    - "跳过用户确认直接导出 Design Tokens = VIOLATION"
    - "Playground HTML 不符合 WCAG AA = VIOLATION"

  # Step 1: Frontend Detection (trigger)
  step1_frontend_detection:
    description: "检测任务是否涉及前端/UI"
    # Keywords split into strong and weak signals to prevent false triggers (P0-4 fix)
    strong_signals:
      # Any ONE strong signal → suggest Playground
      keywords: ["UI", "界面", "前端", "用户界面", "dashboard", "landing page", "配色", "样式"]
    weak_signals:
      # Need 2+ weak signals OR 1 weak + frontend context → suggest Playground
      keywords: ["form", "navigation", "design", "页面", "组件", "布局"]
    negative_signals:
      # Suppress trigger when these backend/API terms dominate
      keywords: ["API", "database", "backend", "服务端", "schema", "migration", "CLI"]
    trigger_logic: |
      IF any strong_signal keyword detected AND no negative_signal dominance:
        → trigger AskUserQuestion
      ELIF 2+ weak_signal keywords detected AND no negative_signal dominance:
        → trigger AskUserQuestion
      ELSE:
        → do not trigger (proceed with normal *design)
    trigger_action: |
      AskUserQuestion({
        questions: [{
          question: "检测到这个任务涉及前端/UI，要启动 Design Playground 做视觉探索吗？",
          header: "Playground",
          options: [
            {label: "启动 Playground (Recommended)", description: "先做设计研究、生成多组方案预览，选定后再写 Handoff"},
            {label: "跳过，直接设计", description: "不需要视觉预览，直接进入文字设计"}
          ],
          multiSelect: false
        }]
      })

  # Step 2: Design Preferences Check
  step2_preferences_check:
    description: "检查是否已有设计偏好"
    action: |
      IF .tad/project-knowledge/frontend-design.md exists:
        AskUserQuestion({
          questions: [{
            question: "这个项目已有设计系统记录，你想怎么做？",
            header: "Existing Design",
            options: [
              {label: "沿用现有设计", description: "跳过全面 Playground，直接进入组件/页面设计"},
              {label: "基于现有设计微调", description: "保留核心 token，调整部分细节"},
              {label: "完全重新设计", description: "忽略历史，重走完整 Playground"}
            ],
            multiSelect: false
          }]
        })
      ELSE:
        → proceed to step3 (full Playground)

  # Step 3: Research Protocol (MANDATORY before generation)
  step3_research:
    description: "研究驱动的设计，不是凭空生成"
    blocking: true

    step3a_project_context:
      action: |
        1. 识别项目类型 (SaaS dashboard, consumer app, landing page, mobile web, etc.)
        2. 扫描项目现有代码:
           - package.json → 已用的 CSS/UI 框架
           - tailwind.config / globals.css → 现有设计 token
           - 组件文件 → 现有组件风格
        3. 读取 .tad/project-knowledge/frontend-design.md（如存在）
      output: "项目上下文摘要"

    step3b_web_research:
      action: |
        使用 WebSearch 搜索:
        1. "{project_type} design trends {current_year}" → 当前设计趋势
        2. "best {project_type} UI examples" → 优秀案例
        3. "{project_type} color palette inspiration" → 配色灵感
        4. "{project_type} typography best practices" → 字体最佳实践
        至少搜索 3 个不同维度，收集参考案例
      output: "研究笔记，含参考链接和关键发现"
      # Show research progress to user (UX P1-1: trust building)
      user_communication: |
        向用户展示研究进度:
        "正在研究设计方向...
         ✓ 搜索了 {project_type} 的设计趋势
         ✓ 分析了 {N} 个优秀案例
         ✓ 参考了 {N} 篇最佳实践文章"

    step3c_analyze:
      action: |
        综合项目上下文和研究结果:
        1. 确定 2-3 个设计方向（如: 明亮现代 / 深色专业 / 柔和温暖）
        2. 每个方向选取配色方案（primary, secondary, accent, background, text）
        3. 每个方向选取字体搭配（heading + body）
        4. 确定组件风格（圆角大小、阴影深浅、密度）
      output: "设计方案矩阵"

  # Step 4: Playground Generation
  step4_generation:
    description: "生成可在浏览器中查看的 HTML 预览文件"

    output_directory: ".tad/active/playground/"
    file_naming: "PLAYGROUND-{YYYYMMDD}-{project-slug}/"

    output_files:
      index_html:
        path: "index.html"  # relative to output_directory + file_naming
        description: "主预览页面 - 自包含 HTML（内联 CSS + JS）"
        requirements:
          - "零外部依赖（不需要 npm/CDN/本地服务器，不引用 Google Fonts CDN）"
          - "字体使用系统字体栈（system-ui, -apple-system, sans-serif）"
          - "直接用浏览器 open 即可查看（file:// protocol）"
          - "响应式布局（桌面/平板/移动端预览切换）"
          - "每个设计方向提供完整的配色+字体+组件+布局方案"
          - "包含 Alex 的研究注释（每个方案的灵感来源和推荐理由）"
          - "WCAG AA 合规（对比度、键盘导航、语义化 HTML、ARIA labels）"
          - "文件大小 < 300KB（理想），最大 500KB"

        sections:
          section_0_research_summary:
            title: "Research Summary"
            content: |
              - 参考案例链接（可点击）
              - 每个方案的设计理念来源
              - 为什么推荐这些方向

          section_1_color_palette:
            title: "Color Palette"
            content: |
              - 2-3 组配色方案，每组包含:
                Primary, Secondary, Accent, Background, Surface, Text, Error, Success
              - 色彩对比度标注 (WCAG AA/AAA)
              - 暗色/亮色模式双版本
              - 实际 UI 元素上的色彩应用预览

          section_2_typography:
            title: "Typography System"
            content: |
              - 2-3 组字体搭配 (heading + body, using system font stacks)
              - 完整字体层级展示 (H1-H6, body, caption, label)
              - 行高、字间距预览
              - 中英文混排效果（如项目需要）

          section_3_components:
            title: "Component Showcase"
            content: |
              Components displayed in TWO views:
              1. Static Grid View (default): All states side-by-side
                 [Default] [Hover] [Active] [Disabled] [Error]
              2. Interactive View (toggle): Live hover/click effects
              组件类别:
              - 按钮 (primary, secondary, outline, ghost, sizes)
              - 卡片 (带图, 纯文字, 列表型)
              - 表单控件 (input, select, checkbox, radio, switch)
              - 导航 (header, sidebar, tabs, breadcrumb)
              - 反馈 (toast, alert, modal, tooltip)

          section_4_layout:
            title: "Page Layouts"
            content: |
              - 2-3 种页面布局方案
              - 桌面/平板/移动端响应式预览
              - Device toolbar 切换 (375px / 768px / 1200px)
              - 关键页面的线框+实际填充内容对比

          section_5_motion:
            title: "Motion & Animation"
            content: |
              - 页面切换过渡
              - 按钮/卡片 hover 效果
              - 加载动画
              - 微交互 (toggle, expand, slide)
              使用 CSS animation/transition，可在 HTML 中直接演示

      research_notes:
        path: "research-notes.md"  # relative to output_directory + file_naming
        description: "Alex 的研究摘要，包含所有参考链接和推荐理由"

    error_handling:
      html_generation_fails:
        action: "Retry once. If still fails, inform user and fall back to text-based design description."
      file_too_large:
        action: "Split into multiple HTML files (one per section) with a simple index page."
      browser_cannot_open:
        action: "Suggest user try: right-click → Open With → browser, or copy file:// path to address bar."

  # Step 5: User Selection (Progressive Disclosure - UX P0-1 fix)
  step5_selection:
    description: "渐进式选择：先确认方向，再细化具体选择"
    max_iterations: 2
    tool: "AskUserQuestion"

    step5a_initial_feedback:
      action: |
        告知用户 HTML 文件位置，提示在浏览器中打开。
        等待用户查看后:

        AskUserQuestion({
          questions: [{
            question: "在浏览器中查看 Playground 后，你的整体反馈是？",
            header: "Overall",
            options: [
              {label: "满意，选择具体方案", description: "方向对，进入详细选择"},
              {label: "方向对但需微调", description: "整体 OK，部分细节要调整"},
              {label: "都不符合预期", description: "需要重新研究和生成"}
            ],
            multiSelect: false
          }]
        })

    step5b_direction_choice:
      trigger: "用户选'满意'或'微调'"
      action: |
        AskUserQuestion({
          questions: [{
            question: "你更倾向于哪个整体设计方向？",
            header: "Direction",
            options: [
              {label: "方向 A: {名称}", description: "{1句话描述风格特征}"},
              {label: "方向 B: {名称}", description: "{1句话描述风格特征}"},
              {label: "方向 C: {名称}", description: "{1句话描述风格特征}（如有）"}
            ],
            multiSelect: false
          }]
        })

    step5c_detail_refinement:
      trigger: "方向确定后"
      action: |
        基于选定方向，确认细节（组件+布局作为组合呈现，不单独拆分）:

        AskUserQuestion({
          questions: [
            {
              question: "基于 {direction}，配色有 2 个变体，你更喜欢？",
              header: "Color",
              options: [
                {label: "变体 A", description: "{特征}"},
                {label: "变体 B", description: "{特征}"}
              ],
              multiSelect: false
            },
            {
              question: "组件风格和布局的组合，你更喜欢？",
              header: "Style+Layout",
              options: [
                {label: "组合 A: 紧凑精致", description: "小圆角、紧凑间距、精细阴影"},
                {label: "组合 B: 宽松舒适", description: "大圆角、宽松间距、柔和阴影"}
              ],
              multiSelect: false
            }
          ]
        })

    step5d_not_satisfied_path:
      trigger: "用户选'都不符合预期'"
      action: |
        AskUserQuestion({
          questions: [{
            question: "哪些方面不符合预期？这会帮助我重新定位研究方向。",
            header: "Feedback",
            options: [
              {label: "整体风格方向偏离", description: "不是我想要的调性和感觉"},
              {label: "配色不适合目标用户群", description: "颜色选择有问题"},
              {label: "组件过于复杂/简陋", description: "组件复杂度不匹配"},
              {label: "布局不符合内容结构", description: "页面结构安排有问题"}
            ],
            multiSelect: true
          }]
        })

        Based on feedback:
        → Alex re-executes step3_research (focused on problem areas)
        → Generates Playground v2
        → Returns to step5a_initial_feedback

        After max_iterations (2) reached:
        → AskUserQuestion: "已经迭代了 2 次。建议选择当前最接近的方案，在实现阶段再做细节微调。
           或者，我们可以跳过 Playground，改用文字描述 + 参考案例链接。"

  # Step 6: Export & Persist
  step6_export:
    description: "将用户选择导出为可执行的设计规范"

    outputs:
      design_tokens_css:
        path: "design-tokens.css"
        format: |
          :root {
            /* Colors */
            --color-primary: #XXXXX;
            --color-secondary: #XXXXX;
            ...
            /* Typography */
            --font-heading: 'Font Name', sans-serif;
            --font-body: 'Font Name', sans-serif;
            --font-size-h1: Xrem;
            ...
            /* Spacing */
            --spacing-xs: Xpx;
            ...
            /* Borders */
            --radius-sm: Xpx;
            ...
            /* Shadows */
            --shadow-sm: X;
            ...
          }

      design_tokens_json:
        path: "design-tokens.json"
        description: "JSON 格式 tokens（可转换为 Tailwind config 等）"

      component_spec:
        path: "component-spec.md"
        description: |
          每个组件的规范文档:
          - 视觉规格（颜色、间距、圆角、阴影）
          - 状态说明（default, hover, active, disabled, error）
          - 响应式行为
          - 参考代码片段（HTML/CSS）

      project_knowledge_entry:
        path: ".tad/project-knowledge/frontend-design.md"
        description: |
          写入 Foundational section（如果是新项目）或追加 Accumulated section:
          - 选定的设计方向和理由
          - Design Token 清单
          - 组件风格规范
          - 注意事项和约束

  # Integration with Handoff
  handoff_integration:
    description: "Playground 结果嵌入到 handoff 中"
    action: |
      在 handoff 的 Section 4.5 (User Interface Requirements) 中：
      1. 引用 Design Tokens 文件路径
      2. 引用组件规范文档
      3. 附上 Playground 的关键截图或 HTML 路径
      4. Blake 实现时必须使用这些 Design Tokens

  # Cleanup
  cleanup:
    description: "Playground 文件生命周期"
    rules:
      - "Playground 文件在 *accept 时随 handoff 归档到 .tad/archive/"
      - "Design Tokens 和组件规范保留在 project-knowledge 中供后续任务使用"
      - "HTML 预览文件归档后可删除（设计决策已持久化到 tokens 和 spec）"
```

### 4.3 HTML Template Design

Playground HTML 模板不是一个固定的 HTML 文件，而是 **Alex 根据研究结果动态生成的**。但需要一个**结构参考模板**告诉 Alex：
- HTML 页面的整体结构和布局
- 每个 section 应包含什么
- 如何组织可切换的方案对比
- 交互元素（tab 切换、暗色模式 toggle、响应式预览）的实现模式

模板文件: `.tad/templates/playground-guide.md`

这是一个 **Markdown 指南文件**（不是 HTML 模板），告诉 Alex 生成 HTML 时的规范和质量标准。包含：
- HTML 结构规范（section 顺序、命名）
- CSS 编写规范（使用 CSS 变量、响应式断点）
- JS 交互规范（tab 切换、主题切换的标准实现）
- 质量检查清单（对比度、可读性、响应式）
- 示例代码片段

### 4.4 Design Tokens Export Format

```json
{
  "colors": {
    "primary": {"value": "#3B82F6", "usage": "Primary actions, links"},
    "secondary": {"value": "#6366F1", "usage": "Secondary actions"},
    "accent": {"value": "#F59E0B", "usage": "Highlights, badges"},
    "background": {"value": "#FFFFFF", "usage": "Page background"},
    "surface": {"value": "#F9FAFB", "usage": "Card/panel background"},
    "text": {"value": "#111827", "usage": "Body text"},
    "text-secondary": {"value": "#6B7280", "usage": "Secondary text"},
    "border": {"value": "#E5E7EB", "usage": "Borders, dividers"},
    "error": {"value": "#EF4444", "usage": "Error states"},
    "success": {"value": "#10B981", "usage": "Success states"},
    "warning": {"value": "#F59E0B", "usage": "Warning states"}
  },
  "typography": {
    "font-heading": {"value": "'Inter', sans-serif", "fallback": "system-ui"},
    "font-body": {"value": "'Inter', sans-serif", "fallback": "system-ui"},
    "scale": {
      "h1": {"size": "2.25rem", "weight": "800", "line-height": "1.2"},
      "h2": {"size": "1.875rem", "weight": "700", "line-height": "1.25"},
      "h3": {"size": "1.5rem", "weight": "600", "line-height": "1.3"},
      "body": {"size": "1rem", "weight": "400", "line-height": "1.5"},
      "small": {"size": "0.875rem", "weight": "400", "line-height": "1.5"},
      "caption": {"size": "0.75rem", "weight": "400", "line-height": "1.5"}
    }
  },
  "spacing": {
    "xs": "4px", "sm": "8px", "md": "16px", "lg": "24px", "xl": "32px", "2xl": "48px"
  },
  "borders": {
    "radius-sm": "4px", "radius-md": "8px", "radius-lg": "12px", "radius-full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 2px rgba(0,0,0,0.05)",
    "md": "0 4px 6px rgba(0,0,0,0.07)",
    "lg": "0 10px 15px rgba(0,0,0,0.1)"
  }
}
```

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

**问题**: 用户是否提到"之前的"、"原来的"方案？

**回答**: ❌ 否 — 这是 TAD 框架的全新功能，无历史实现。但需确认现有 *design 流程的结构。

**搜索执行**: 已搜索 tad-alex.md 中的 *design 命令定义，确认其当前不包含前端可视化流程。

### MQ2: 函数存在性验证

**回答**: 本次修改主要是 YAML 协议和模板文件，不涉及函数调用。需确认的文件位置：

| 文件/Section | 位置 | 验证 |
|-------------|------|------|
| playground_protocol | tad-alex.md (新增) | N/A (新建) |
| playground-guide.md | .tad/templates/ (新建) | N/A (新建) |
| frontend_detection keywords | 嵌入 playground_protocol | N/A (新建) |
| design_tokens template | .tad/templates/ (新建) | N/A (新建) |
| *design 命令 | tad-alex.md commands section | ✅ 存在 |
| project-knowledge 系统 | .tad/project-knowledge/ | ✅ 存在 |
| AskUserQuestion 工具 | Claude Code 内建 | ✅ 存在 |
| WebSearch 工具 | Claude Code 内建 | ✅ 存在 |

### MQ3: 数据流完整性

**问题**: 后端计算/返回了哪些字段？前端都显示了吗？

**回答**: ❌ N/A — 本次任务不涉及前后端数据传递。这是 TAD 框架配置文件和模板的修改，不存在 API 数据流。

### MQ4: 视觉层级

**问题**: 功能有不同状态/类型吗？用户如何区分？

**回答**: ❌ N/A — 本次任务是创建 Playground 协议和模板，不直接创建用户界面。Playground 的视觉层级标准定义在 playground-guide.md 中，由 Alex 在运行时动态生成。

### MQ5: 状态同步

**问题**: 数据存在几个地方？

**回答**:

```
Playground 设计决策流:

[HTML 预览] → 用户选择 → [Design Tokens files] (Source of Truth)
                              ↓ 同步时机: export_phase
                         [project-knowledge/frontend-design.md] (持久化参考)
                              ↓ 同步时机: handoff 创建时
                         [Handoff Section 4.5] (Blake 的实现参考)

唯一的 Source of Truth: Design Tokens files (.css + .json)
其他位置是引用/复制，不存在双向同步问题。
```

---

## 6. Implementation Steps (分 Phase)

### Phase 1: Core Protocol & Templates

#### 交付物
- [ ] `.tad/templates/playground-guide.md` — Playground HTML 生成指南
- [ ] `.tad/templates/design-tokens-template.md` — Design Token 导出模板
- [ ] `.tad/active/playground/` 目录 (with `.gitkeep`)
- [ ] `.tad/archive/playground/` 目录 (with `.gitkeep`)

#### 实施步骤

**1. 创建 playground-guide.md**

这是 Alex 生成 Playground HTML 时的参考指南（Markdown 文件，不是 HTML 模板）。内容必须包含：

```
# Playground HTML Generation Guide

## HTML Structure Standard
- DOCTYPE, meta viewport, 自包含（所有 CSS/JS 内联）
- Section 顺序: Hero Banner → Color Palette → Typography → Components → Layouts → Motion
- 每个 Section 有 tab 切换器（方案 A/B/C）
- 固定导航栏（Section 锚点跳转）
- 暗色/亮色模式切换按钮
- 响应式预览切换（桌面/移动端视口模拟）

## CSS Standards
- 使用 CSS Custom Properties 定义所有 token
- 响应式断点: 375px (mobile), 768px (tablet), 1200px (desktop)
- 对比度: 文字至少 WCAG AA (4.5:1)
- 平滑过渡: transition 统一使用 0.2s ease

## JS Interaction Standards
- Tab 切换: data-tab attribute, CSS class toggle
- 主题切换: 切换 root class (data-theme="dark")
- 响应式预览: iframe 或 container width 切换
- 零外部依赖 (vanilla JS only)

## Accessibility Requirements (MANDATORY - WCAG AA)
- [ ] Color contrast: 所有文字至少 4.5:1 (normal text), 3:1 (large text)
- [ ] Keyboard navigation: Tab 键可访问所有交互元素 (tabs, theme toggle, viewport switcher)
- [ ] Focus indicators: 所有可聚焦元素有清晰的 focus ring (outline: 2px solid)
- [ ] ARIA labels: 所有交互控件有 aria-label 或 aria-labelledby
- [ ] Semantic HTML: 使用 <button>, <nav>, <section>, <main> 等语义化标签
- [ ] Skip navigation: 提供跳转到主内容的链接
VIOLATION: 生成不符合 WCAG AA 的 Playground HTML = VIOLATION

## Quality Checklist (Alex 生成后自检)
- [ ] 文件 < 300KB (理想), 最大 500KB (内联所有内容)
- [ ] 浏览器直接打开可用 (file:// protocol)
- [ ] 零外部依赖 (不引用 CDN, 使用系统字体栈)
- [ ] 所有方案都可切换查看
- [ ] 暗色/亮色模式都正常
- [ ] 移动端/平板/桌面端预览正常
- [ ] 每个方案都有 Alex 的推荐理由注释
- [ ] 所有 Accessibility Requirements 通过

## Example Code Snippets
[提供 tab 切换器、主题切换、响应式预览的标准 JS/CSS 实现片段]
```

**2. 创建 design-tokens-template.md**

Design Token 导出的模板和格式规范。内容包含：
- CSS Custom Properties 格式模板
- JSON 格式模板（可转换为 Tailwind/其他框架配置）
- 命名约定 (--color-primary, --font-heading, --spacing-md 等)
- 每个 token 的用途说明

**3. 创建目录结构**

```
.tad/active/playground/     (.gitkeep)
.tad/archive/playground/    (.gitkeep)
```

#### Phase 1 完成证据 (Blake 必须提供)
- [ ] playground-guide.md 存在且包含所有必要 section
- [ ] design-tokens-template.md 存在且格式正确
- [ ] 目录结构创建完成

---

### Phase 2: Alex Protocol Integration

#### 交付物
- [ ] `tad-alex.md` 更新 — 添加 `*playground` 命令和完整协议
- [ ] `tad-alex.md` 更新 — *design 流程中集成 Playground 触发

#### 实施步骤

**1. 在 tad-alex.md 的 `commands` section 添加 *playground**

```yaml
commands:
  # ... existing commands ...
  playground: Launch Frontend Design Playground (sub-phase of *design)
```

**2. 在 tad-alex.md 添加完整的 `playground_protocol`**

参考本 Handoff Section 4.2 的完整 protocol 设计。关键 sections:
- `frontend_detection` — 关键词检测 + AskUserQuestion 触发
- `research_phase` — 3 步研究流程 (project context → web research → analyze)
- `generation_phase` — HTML 生成规范（引用 playground-guide.md）
- `selection_phase` — 用户选择收集（AskUserQuestion 模式）
- `export_phase` — Design Tokens + 组件规范 + project-knowledge 导出
- `handoff_integration` — 如何将 Playground 结果嵌入 handoff
- `cleanup` — Playground 文件生命周期

**3. 更新 *design 流程 — 添加 Playground 触发点**

tad-alex.md 当前没有显式的 `design_protocol` section（*design 在 `commands` 中声明但无详细协议）。Blake 需要：

a. 在 `commands` section 的 `design` 行添加描述性注释：
```yaml
design: Create technical design from requirements (includes *playground trigger for frontend tasks)
```

b. 创建新的 `design_protocol` section（放在 `handoff_creation_protocol` 之前），包含：
```yaml
design_protocol:
  description: "Technical design creation workflow"
  steps:
    step1: "Review Socratic Inquiry results"
    step2: "Check if task involves frontend (playground_protocol.step1_frontend_detection)"
    step3_if_frontend: "Execute playground_protocol (if user accepts)"
    step4: "Create architecture design"
    step5: "Create data flow / state flow diagrams"
    step6: "Proceed to *handoff"
```

c. 这样 Playground 在 *design 流程中的位置是：需求确认后、架构设计前。

**4. 更新 `my_tasks` 列表**

添加 playground 相关任务引用。

**5. 在 `success_patterns` 中添加 Playground 最佳实践**

```yaml
success_patterns:
  # ... existing patterns ...
  - Use *playground for ALL frontend/UI design tasks
  - ALWAYS research before generating playground (web search mandatory)
  - Export Design Tokens after user selection (CSS + JSON)
  - Persist design decisions to project-knowledge
```

**6. 更新 Quick Reference section**

在 tad-alex.md 底部的 Quick Reference 中添加 `*playground` 命令说明。

#### Phase 2 完成证据 (Blake 必须提供)
- [ ] tad-alex.md 包含 *playground 命令
- [ ] playground_protocol 完整且结构符合现有 YAML 协议格式（violations array, tool field, step numbering）
- [ ] design_protocol section 创建且包含 Playground 触发点
- [ ] Quick Reference 包含 *playground 说明

---

### Phase 3: Config & Integration

#### 交付物
- [ ] `config-workflow.yaml` 更新 — 添加 playground 配置
- [ ] `CLAUDE.md` 更新 — Alex 使用场景表中添加 Playground
- [ ] `.tad/project-knowledge/README.md` 更新 — 添加 frontend-design 类别说明

#### 实施步骤

**1. 更新 config-workflow.yaml**

在 `document_management` section 后添加：

```yaml
# ==================== Frontend Design Playground ====================
playground:
  description: "Research-driven visual design exploration for frontend tasks"
  ownership: "Alex generates, human selects, design persists to project-knowledge"
  base_dir: ".tad/active/playground/"
  archive_dir: ".tad/archive/playground/"
  naming: "PLAYGROUND-{YYYYMMDD}-{project-slug}/"

  research_requirements:
    min_search_queries: 3
    must_cover: ["design trends", "similar products", "best practices"]
    violation: "不做研究直接生成 = VIOLATION"

  generation:
    template_guide: ".tad/templates/playground-guide.md"
    design_tokens_template: ".tad/templates/design-tokens-template.md"
    max_options_per_section: 3
    min_options_per_section: 2

  export:
    design_tokens_formats: ["css", "json"]
    persist_to: ".tad/project-knowledge/frontend-design.md"
    embed_in_handoff: true

  cleanup:
    archive_on_accept: true
    keep_tokens: true  # Design Tokens 保留在 project-knowledge
    delete_html_after_archive: false  # 保留以供参考
```

**2. 更新 config-workflow.yaml document_management.structure**

Add `playground` to both active and archive structure lists:

```yaml
# In document_management.structure:
active:
  - tasks
  - designs
  - handoffs
  - epics
  - playground    # ← ADD THIS LINE
archive:
  - by_date
  - by_task
  - by_version
  - epics
  - playground    # ← ADD THIS LINE
```

**3. 更新 config.yaml master index**

Add playground to `config_modules.config-workflow.yaml.contains`. Insert after `pair_testing`:

```yaml
contains:
  - document_management (handoff_lifecycle, next_md_maintenance, epic_lifecycle)
  - tad_maintain
  - pair_testing
  - playground (frontend_detection, research_phase, generation, selection, export)  # ← ADD THIS LINE
  - requirement_elicitation (research_phase)
  - socratic_inquiry_protocol
  - scenarios (new_project, bug_fix)
```

**4. 更新 CLAUDE.md**

在 Section 2 的使用场景表中添加：

```
| `/alex` + `*playground` | 任务涉及前端/UI 设计，需要可视化探索 |
```

**4. 更新 project-knowledge README.md**

添加 `frontend-design` 类别说明：
```
- **frontend-design.md**: 前端设计决策 - Design Tokens、组件规范、视觉风格
```

#### Phase 3 完成证据 (Blake 必须提供)
- [ ] config-workflow.yaml 包含 playground section
- [ ] CLAUDE.md 有 Playground 提及
- [ ] project-knowledge README 包含 frontend-design 类别

---

## 7. File Structure

### 7.1 Files to Create

```
.tad/templates/playground-guide.md          # Playground HTML 生成指南
.tad/templates/design-tokens-template.md    # Design Token 导出模板
.tad/active/playground/.gitkeep             # Active playground 目录
.tad/archive/playground/.gitkeep            # Archive playground 目录
```

### 7.2 Files to Modify

```
.claude/commands/tad-alex.md     # 添加 *playground 命令和协议
.tad/config-workflow.yaml        # 添加 playground 配置节
.tad/config.yaml                 # 更新 master index
CLAUDE.md                        # 添加 Playground 使用场景
.tad/project-knowledge/README.md # 添加 frontend-design 类别
```

---

## 8. Testing Requirements

### 8.1 Verification Scenarios

- [ ] **场景 1**: Alex 激活后，用户描述前端任务 → Alex 检测到前端关键词 → 建议 Playground
- [ ] **场景 2**: 用户拒绝 Playground → 正常 *design 流程不受影响
- [ ] **场景 3**: 用户接受 Playground → Alex 按 research_phase 执行研究
- [ ] **场景 4**: Playground 协议结构符合 TAD YAML 格式规范（与 socratic_inquiry_protocol 一致）
- [ ] **场景 5**: Design Tokens 模板格式正确（CSS + JSON 双格式）
- [ ] **场景 6**: playground-guide.md 包含所有必要的 HTML 生成规范
- [ ] **场景 7**: 非前端任务 → 不触发 Playground（无误触发）

### 8.2 Edge Cases

- 项目无现有前端代码（全新项目）→ 研究阶段跳过 codebase scan
- 项目已有 project-knowledge/frontend-design.md → 读取并基于此迭代
- 用户选择"混搭"方案 → Alex 支持自由讨论再重新生成

---

## 9. Acceptance Criteria

Blake 的实现被认为完成，当且仅当：

- [ ] playground-guide.md 存在且包含 HTML 结构/CSS/JS/Accessibility/质量检查 5 个完整 section
- [ ] playground-guide.md 包含 WCAG AA 强制要求（对比度、键盘导航、ARIA、语义 HTML）
- [ ] design-tokens-template.md 存在且包含 CSS + JSON 双格式模板
- [ ] tad-alex.md 包含完整的 playground_protocol（6 steps: detection → preferences → research → generation → selection → export）
- [ ] playground_protocol 结构符合 TAD 格式（violations array, tool field, step numbering）
- [ ] tad-alex.md 包含 design_protocol section（含 Playground 触发点）
- [ ] 关键词触发使用 strong/weak/negative 三级分类（不误触发后端任务）
- [ ] 选择流程使用渐进式披露（方向优先 → 细节细化）
- [ ] 包含 "不满意" 迭代路径（max 2 次 + fallback）
- [ ] 包含已有设计偏好检测（project-knowledge 复用）
- [ ] config-workflow.yaml 包含 playground section + document_management.structure 更新
- [ ] config.yaml master index contains 列表包含 playground
- [ ] CLAUDE.md 提及 Playground 使用场景
- [ ] 目录结构 .tad/active/playground/ 和 .tad/archive/playground/ 存在
- [ ] 不影响现有 TAD 流程（非前端任务不触发 Playground）

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **Playground 是设计产物，不是产品代码** — HTML 文件是临时的可视化工具，不要试图让它变成可复用的前端组件
- ⚠️ **研究是强制的** — Alex 不做 web search 就生成 Playground 是 VIOLATION
- ⚠️ **Design Tokens 是 Source of Truth** — Blake 实现时必须使用 Playground 导出的 token，不能自行决定配色/字体

### 10.2 Known Constraints

- HTML Playground 使用纯 CSS/JS，复杂状态交互（如表单验证流程）可能需要简化展示
- **字体**: Playground HTML 必须使用系统字体栈（zero CDN dependency, 符合 NFR1）。Design Tokens 导出时可以指定 web fonts（如 Inter, Poppins），但 Playground 预览中以系统字体呈现，并在 token 注释中标注推荐的 web font
- Playground 不替代 pair testing — 它是设计探索工具，不是 E2E 测试

### 10.3 Design Consistency Verification (Gate 4 Integration)

当包含 Playground 的任务进入 Gate 4 验收时，Alex 必须额外检查：

```
Consistency Metrics (自动化检查):
- [ ] Color exact match: 实现中使用的颜色值与 Design Tokens 100% 匹配
- [ ] Font family match: 字体族完全一致（系统字体栈或指定 web font）
- [ ] Spacing deviation: 间距误差 < 4px
- [ ] Border radius deviation: 圆角误差 < 2px

Human Verification:
- [ ] Side-by-side comparison: Playground screenshot vs 实现 screenshot
- [ ] 用户提供"一致性满意度"(1-5 分, ≥4 分通过)

Blake Implementation Requirement:
- [ ] Blake 必须 import/link 导出的 design-tokens.css 或将 JSON tokens 转换为框架配置
- [ ] Gate 3 时 Blake 需提供 token 使用证据（import 语句截图）
```

### 10.4 Sub-Agent 使用建议

Blake 应该考虑使用：
- [ ] **code-reviewer** — 审查 YAML 协议结构的一致性和完整性
- [ ] **test-runner** — 验证 Playground 不影响现有 TAD 流程

---

## 11. Learning Content

### 11.1 Decision Rationale: 为什么是 HTML 文件而不是其他方案

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| HTML 文件 (选中) | 零依赖、即开即看、框架无关 | 复杂交互受限 | ✅ 选中 |
| 本地 dev server | 更接近真实效果 | 需要 npm、与项目技术栈耦合 | 每个项目栈不同，不通用 |
| Figma/设计工具集成 | 专业设计效果 | 需要额外工具和学习成本 | TAD 用户不一定有设计工具 |
| AI 图片生成 | 视觉丰富 | 不可交互、无法导出 token | 看到不等于能实现 |

**核心权衡**: 通用性 vs 保真度。HTML 方案牺牲了极致保真度，换取了框架无关和零依赖的通用性。通过 Design Tokens 机制保证配色/字体级别的精确传递。

### 11.2 Decision Rationale: 研究驱动 vs AI 直觉

用户明确要求设计方案应基于**充分研究**（搜索同类产品、当前趋势、最佳实践），而非依赖 AI 的已有知识。这确保产出质量的下限在"业界平均水平以上"。

---

**Handoff Created By**: Alex (Solution Lead)
**Date**: 2026-02-04
**Version**: 2.3.0
