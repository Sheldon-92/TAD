# Handoff: Curation-Based Design Playground

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-04
**Task ID:** TASK-20260204-002
**Priority:** P1
**Complexity:** Large (Full TAD)
**Status:** Ready for Implementation
**Supersedes:** HANDOFF-20260204-frontend-playground.md (approach pivot: generation → curation)
**Supersede Action:** Blake 开始前，先将旧 Handoff 移至 `.tad/archive/handoffs/` (避免 tad-maintain 误路由)

---

## Expert Review Status

| Expert | Verdict | P0 Issues | P1 Issues |
|--------|---------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → RESOLVED | 3 (all fixed) | 7 (key items fixed) |
| ux-expert-reviewer | CONDITIONAL PASS → RESOLVED | 4 (all fixed) | 5 (key items fixed) |

### P0 Issues Resolved

**Code Reviewer P0s:**
- P0-1: NFR 矛盾 (npx serve vs zero-dependency) → 明确使用本地服务器，移除"零依赖"混淆 ✅
- P0-2: Section 编号与 Layer 顺序不一致 → 重新编号对齐 ✅
- P0-3: Blake 研究范围过广无边界 → 添加 minimum viable token set + fallback 指引 ✅

**UX Expert P0s:**
- P0-1: 选择流程缺少进度指示和退出策略 → 添加 3-step 进度条 + save-and-resume ✅
- P0-2: "策展人"概念对非设计用户不直观 → 添加面向用户的语言指南 ✅
- P0-3: 缺少非设计背景用户的决策辅助 → 添加 best_for 标签 + 推荐徽标 + "Why This Works" ✅
- P0-4: WCAG AA 缺少可执行检查清单 → 添加详细 accessibility verification ✅

---

## Executive Summary

将 TAD 框架的 Frontend Design Playground 从"AI 生成型"转变为**"策展型"(Curation-based)**。

核心转变：Alex 不再从零设计 HTML 页面，而是**策展人角色**——从设计奖项、组件库、行业标杆产品中收集最优秀的设计实践，提取具体设计元素（配色、字体、组件风格），组合成方案供用户选择。

**为什么转变**: 用户在 Menu Snap 项目中经历了 8 版前端设计迭代才勉强满意，证明 AI 从零生成设计的质量不稳定。而 AI 的研究和整合能力（搜索、分析、组织）远强于其设计创作能力。

**核心架构**: 4 层 Skill 体系
- Layer 1: 预置设计参考库 (design-curations.yaml) — Alex 的"设计眼光"
- Layer 2: 运行时搜索协议 — 补充最新趋势
- Layer 3: HTML 呈现模板 (playground-template.html) — "填充式"展示
- Layer 4: 行业模板 — 告诉 Alex "这类项目参考谁"

---

## Handoff Checklist (Blake 必读)

Blake 在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 理解"策展"vs"生成"的区别——Alex 不设计，Alex 收集和组织
- [ ] 理解 4 层 Skill 架构的每一层作用
- [ ] 注意：Phase 1 的 playground-guide.md 已存在但需要修改（从生成型改为策展型）
- [ ] design-tokens-template.md 可以复用，无需修改

---

## 1. Task Overview

### 1.1 What We're Building

为 Alex 构建一套"策展型设计 Playground" Skill，包含 4 层能力：

1. **预置设计参考库** — 预先整理的高质量设计系统、配色、字体、组件风格数据
2. **运行时搜索协议** — 根据项目类型动态补充最新设计趋势
3. **HTML 呈现模板** — 结构化的 HTML 模板，Alex 只需填入策展结果的具体值
4. **行业模板** — 不同项目类型（SaaS、Consumer、Landing Page 等）的推荐方向

### 1.2 Why We're Building It

**核心问题**: AI 从零生成前端设计的质量不稳定（用户实际经历：8 版迭代才基本满意）。

**核心洞察**: Alex 的能力优势在于搜索、分析、整合——不是设计创作。让 Alex 做策展人（收集最好的，组合呈现），而不是设计师（凭空创造）。

**用户原话**: "我不在乎是他自己生成的还是他去搜索收集的，然后把它组织在一起。核心是他要提供非常好的选项，让我能做选择。"

### 1.3 Intent Statement

**真正要解决的问题**: 给非设计背景的用户一个"设计选择器"——基于业界最佳实践的、可预览的设计元素菜单。

**不是要做的**:
- ❌ 不是让 AI 当设计师（AI 做策展人）
- ❌ 不是展示完整页面（展示关键设计元素）
- ❌ 不需要从零写 HTML（填充预置模板）

---

## Project Knowledge (Blake 必读)

**已读取的 project-knowledge 文件**: architecture.md

**关键提醒**:
- TAD 框架修改时，所有 agent 命令文件的修改必须保持与 config.yaml 模块绑定一致
- 新增协议时遵循现有 YAML protocol 格式
- **本次有已存在的 Phase 1 文件需要修改**（playground-guide.md），注意保留可复用部分

---

## 2. Background Context

### 2.1 前一个 Handoff 的遗产

HANDOFF-20260204-frontend-playground.md (generation-based) 的 Phase 1 已被 Blake 完成：

| 文件 | 状态 | 新 Handoff 处理 |
|------|------|----------------|
| `.tad/templates/playground-guide.md` | ✅ 存在 | **需要重写**（从生成指南改为策展+填充指南）|
| `.tad/templates/design-tokens-template.md` | ✅ 存在 | **保留不变**（导出格式不受影响）|
| `.tad/active/playground/.gitkeep` | ✅ 存在 | 保留 |
| `.tad/archive/playground/.gitkeep` | ✅ 存在 | 保留 |
| tad-alex.md (Phase 2) | ❌ 未开始 | 按新方向实现 |
| config files (Phase 3) | ❌ 未开始 | 按新方向实现 |

### 2.2 Target State

```
Alex 策展型 Playground 流程:

1. 检测前端任务 → 建议启动 Playground
2. 读取预置参考库 → 筛选匹配项目类型的方案
3. 运行时搜索 → 补充最新趋势和行业案例
4. 提取设计元素 → 配色、字体、组件风格的具体值
5. 填充 HTML 模板 → 生成可预览的选择页面
6. 启动本地服务器 → 用户在浏览器中查看选择
7. 收集选择 → 导出 Design Tokens
```

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: Blake 创建预置设计参考库 (design-curations.yaml)，包含至少 5 个设计系统、5 组配色、5 组字体搭配、3 种组件风格预设
- **FR2**: Blake 创建行业模板，覆盖至少 3 个行业类型（SaaS/Consumer/Landing Page）
- **FR3**: Blake 创建 HTML 呈现模板 (playground-template.html)，Alex 只需填入值即可使用
- **FR4**: HTML 模板支持逐元素展示和选择（配色区、字体区、组件区、间距区）
- **FR5**: 重写 playground-guide.md，从"生成指南"改为"策展+填充指南"
- **FR6**: tad-alex.md 添加策展型 playground_protocol
- **FR7**: 选择结果导出为 Design Tokens (复用现有 design-tokens-template.md)
- **FR8**: HTML 通过本地服务器呈现 (`npx serve` 或等效方案)

### 3.2 Non-Functional Requirements

- **NFR1**: 预置参考库中的设计系统和配色必须来自可验证的高质量来源（设计奖项、知名产品、流行设计系统）
- **NFR2**: HTML 模板自包含（内联 CSS/JS，系统字体栈），通过本地服务器 (`npx serve`) 呈现。用户环境已有 Node.js，不需要额外安装
- **NFR3**: 用户从看到 Playground 到做出初步方向选择应在 **8 分钟内**，完整流程（含细节调整）在 **15 分钟内**
- **NFR4**: 框架无关——Design Tokens 可适配任何技术栈

---

## 4. Technical Design

### 4.1 Architecture: 4-Layer Skill

```
┌──────────────────────────────────────────────────┐
│ Layer 4: 行业模板 (Industry Templates)              │
│ → 告诉 Alex "这类项目应该参考谁"                       │
│ 存放: design-curations.yaml 的 industry_templates 段 │
├──────────────────────────────────────────────────┤
│ Layer 3: HTML 呈现模板 (playground-template.html)    │
│ → Alex 填入策展值，生成可交互的选择页面                   │
│ 存放: .tad/templates/playground-template.html        │
├──────────────────────────────────────────────────┤
│ Layer 2: 运行时搜索协议 (Runtime Search Protocol)     │
│ → Alex 根据项目补充最新设计趋势                         │
│ 存放: tad-alex.md playground_protocol.step_search    │
├──────────────────────────────────────────────────┤
│ Layer 1: 预置设计参考库 (Design Curations DB)         │
│ → 高质量设计系统、配色、字体、组件风格的预置数据           │
│ 存放: .tad/references/design-curations.yaml          │
└──────────────────────────────────────────────────┘
```

### 4.2 Layer 1 + Layer 4: 预置设计参考库 + 行业模板

**文件**: `.tad/references/design-curations.yaml`

> **Note**: Layer 4 (industry_templates) 作为 Layer 1 的一个 section 存放在同一个 YAML 文件中，因为行业模板直接引用预置数据。

Blake 需要做设计研究，填充以下结构。

**研究范围边界 (P0-3 fix)**:
- **Minimum Viable Token Set** (每个设计系统至少提取): colors (primary, background, text, border, error, success), radius (sm, md, lg), shadow (sm, md), spacing (base unit + scale)
- **配色方案**: 每组至少 light 模式 6 色 (primary, background, surface, text, border, accent)，dark 模式 4 色 (background, surface, text, border)
- **"Good Enough" 标准**: 有具体 hex 值 + 标注来源即可，不需要完美覆盖所有 token
- **Fallback**: 设计系统文档无法访问时（JS渲染、rate limit），使用 WebSearch 搜索 "{system_name} default theme tokens" 从第三方文章获取
- **Blake 不填充**: `sources` 段的 `search_pattern` 和 `search_queries` 字段是 Alex 运行时使用的，Blake 只需确认它们的格式正确

```yaml
# .tad/references/design-curations.yaml
# Alex 的策展参考数据库
# 用途: Alex 根据项目类型从此库中筛选匹配的设计元素

version: "1.0"
last_updated: "2026-02-04"

# ==================== 信息源注册 ====================
sources:
  award_sites:
    description: "设计奖项网站 — 获奖作品代表高质量基准"
    sites:
      - name: "Awwwards"
        url: "https://www.awwwards.com"
        search_pattern: "awwwards {project_type} site of the day {year}"
        value: "整体设计质量、创意、交互"
      - name: "CSS Design Awards"
        url: "https://www.cssdesignawards.com"
        search_pattern: "cssdesignawards best {project_type} {year}"
        value: "CSS/前端技术实现质量"
      - name: "FWA"
        url: "https://thefwa.com"
        search_pattern: "FWA {project_type} winner"
        value: "创新交互、动效"

  design_systems:
    description: "文档化的设计系统 — Token 值可直接提取"
    systems:
      # Blake 需要研究并填充每个系统的实际 token 值
      - name: "Shadcn/ui"
        docs_url: "https://ui.shadcn.com"
        style: "modern, minimal, accessible"
        strengths: ["components", "theming", "dark mode"]
        tokens: {}  # Blake 填充
      - name: "Radix Themes"
        docs_url: "https://www.radix-ui.com"
        style: "clean, systematic, accessible"
        strengths: ["accessibility", "primitives", "composition"]
        tokens: {}  # Blake 填充
      - name: "Ant Design"
        docs_url: "https://ant.design"
        style: "enterprise, structured, comprehensive"
        strengths: ["data-dense UI", "form controls", "tables"]
        tokens: {}  # Blake 填充
      - name: "Material Design 3"
        docs_url: "https://m3.material.io"
        style: "vibrant, expressive, dynamic"
        strengths: ["color system", "motion", "adaptive layouts"]
        tokens: {}  # Blake 填充
      - name: "Chakra UI"
        docs_url: "https://chakra-ui.com"
        style: "approachable, composable, accessible"
        strengths: ["ease of use", "theming", "responsive"]
        tokens: {}  # Blake 填充

  inspiration_galleries:
    description: "设计灵感聚合站 — 按风格/行业浏览"
    sites:
      - name: "Mobbin"
        url: "https://mobbin.com"
        value: "真实产品 UI 截图，按模式分类"
      - name: "Godly"
        url: "https://godly.website"
        value: "精选优秀网站设计"
      - name: "Land-book"
        url: "https://land-book.com"
        value: "Landing page 灵感"
      - name: "Dribbble"
        url: "https://dribbble.com"
        value: "设计概念和视觉探索"

  reference_products:
    description: "行业标杆产品 — 经过市场验证的设计"
    products:
      # Blake 需要研究每个产品的设计特征
      - name: "Stripe"
        url: "https://stripe.com"
        industry: "fintech"
        design_traits: "trustworthy, precise, clean data display"
      - name: "Linear"
        url: "https://linear.app"
        industry: "developer tools"
        design_traits: "dark-first, keyboard-driven, minimal"
      - name: "Notion"
        url: "https://notion.so"
        industry: "productivity"
        design_traits: "warm, spacious, content-first"
      - name: "Vercel"
        url: "https://vercel.com"
        industry: "developer platform"
        design_traits: "bold, high-contrast, modern"
      - name: "Airbnb"
        url: "https://airbnb.com"
        industry: "consumer marketplace"
        design_traits: "friendly, visual-rich, rounded"
      # Blake 可以增加更多

# ==================== 预置设计元素 ====================
# Blake 做研究后填充具体值

color_palettes:
  # 每组配色必须标注来源
  cool_minimal:
    source: "Inspired by Linear/Vercel"
    mood: "冷静极简"
    best_for: ["developer tools", "SaaS dashboard", "tech startup"]
    light:
      primary: ""      # Blake 填充 hex 值
      secondary: ""
      accent: ""
      background: ""
      surface: ""
      text: ""
      text_secondary: ""
      border: ""
      error: ""
      success: ""
      warning: ""
    dark:
      primary: ""
      background: ""
      surface: ""
      text: ""
      text_secondary: ""
      border: ""

  warm_professional:
    source: "Inspired by Notion/Airbnb"
    mood: "温暖专业"
    best_for: ["consumer app", "marketplace", "content platform"]
    light: {}  # Blake 填充
    dark: {}

  vibrant_modern:
    source: "Inspired by Material Design 3"
    mood: "活力现代"
    best_for: ["social app", "creative tool", "education"]
    light: {}
    dark: {}

  dark_bold:
    source: "Inspired by Linear/Arc"
    mood: "深色大胆"
    best_for: ["developer tool", "music/media", "gaming"]
    light: {}
    dark: {}

  neutral_enterprise:
    source: "Inspired by Ant Design/Stripe"
    mood: "中性企业"
    best_for: ["enterprise SaaS", "admin dashboard", "B2B"]
    light: {}
    dark: {}

font_pairings:
  # 每组字体搭配标注推荐的 web font + 系统字体回退
  modern_neutral:
    heading: "Inter"
    heading_fallback: "system-ui, -apple-system, sans-serif"
    body: "Inter"
    body_fallback: "system-ui, -apple-system, sans-serif"
    mood: "现代中性，高可读性"
    cjk_compatible: true
    best_for: ["SaaS", "dashboard", "documentation"]

  elegant_serif:
    heading: "Playfair Display"
    heading_fallback: "Georgia, 'Times New Roman', serif"
    body: "Source Sans Pro"
    body_fallback: "system-ui, sans-serif"
    mood: "优雅经典"
    cjk_compatible: false
    best_for: ["luxury brand", "editorial", "portfolio"]

  tech_geometric:
    heading: "Geist Sans"
    heading_fallback: "system-ui, sans-serif"
    body: "Geist Sans"
    body_fallback: "system-ui, sans-serif"
    mood: "技术几何感"
    cjk_compatible: false
    best_for: ["developer tool", "tech startup"]

  friendly_rounded:
    heading: "Nunito"
    heading_fallback: "system-ui, sans-serif"
    body: "Open Sans"
    body_fallback: "system-ui, sans-serif"
    mood: "友好圆润"
    cjk_compatible: true
    best_for: ["education", "health", "consumer app"]

  monospace_hacker:
    heading: "JetBrains Mono"
    heading_fallback: "ui-monospace, 'SF Mono', monospace"
    body: "IBM Plex Sans"
    body_fallback: "system-ui, sans-serif"
    mood: "开发者/极客"
    cjk_compatible: false
    best_for: ["developer tool", "terminal app", "code editor"]

component_presets:
  rounded_soft:
    radius: "12px"
    shadow_style: "soft, diffused"
    shadow_values:
      sm: ""   # Blake 填充
      md: ""
      lg: ""
    density: "spacious"
    spacing_scale: "generous (base 16px, scale 1.5x)"
    reference: "Notion, Raycast, Airbnb"
    best_for: ["consumer", "content-first"]

  sharp_dense:
    radius: "4px"
    shadow_style: "minimal, subtle"
    shadow_values: {}
    density: "compact"
    spacing_scale: "tight (base 8px, scale 1.25x)"
    reference: "Linear, GitHub, VS Code"
    best_for: ["developer tools", "data-heavy dashboards"]

  pill_playful:
    radius: "9999px (buttons), 16px (cards)"
    shadow_style: "colored, soft"
    shadow_values: {}
    density: "balanced"
    spacing_scale: "standard (base 16px, scale 1.5x)"
    reference: "Duolingo, Headspace, Spotify"
    best_for: ["education", "wellness", "entertainment"]

# ==================== 行业模板 ====================
industry_templates:
  saas_dashboard:
    description: "SaaS 管理后台 / Dashboard"
    recommended_palettes: ["cool_minimal", "neutral_enterprise"]
    recommended_fonts: ["modern_neutral", "tech_geometric"]
    recommended_components: ["sharp_dense"]
    avoid: ["pill_playful", "elegant_serif"]
    key_ui_elements: ["data table", "chart/graph", "sidebar nav", "form controls", "metric cards"]
    reference_products: ["Linear", "Vercel Dashboard", "Stripe Dashboard"]
    search_queries:
      - "best SaaS dashboard design {year}"
      - "admin panel UI inspiration"

  consumer_app:
    description: "面向消费者的应用"
    recommended_palettes: ["warm_professional", "vibrant_modern"]
    recommended_fonts: ["friendly_rounded", "modern_neutral"]
    recommended_components: ["rounded_soft", "pill_playful"]
    avoid: ["sharp_dense"]
    key_ui_elements: ["card list", "bottom nav/tab bar", "action button", "search bar", "profile"]
    reference_products: ["Airbnb", "Duolingo", "Headspace"]
    search_queries:
      - "best consumer app design {year}"
      - "{industry} app UI trends"

  landing_page:
    description: "营销着陆页 / 产品官网"
    recommended_palettes: ["vibrant_modern", "dark_bold"]
    recommended_fonts: ["tech_geometric", "elegant_serif"]
    recommended_components: ["rounded_soft"]
    avoid: []
    key_ui_elements: ["hero section", "CTA button", "feature grid", "testimonials", "pricing table"]
    reference_products: ["Stripe", "Vercel", "Arc", "Linear Landing"]
    search_queries:
      - "best landing page design {year} awwwards"
      - "{industry} landing page inspiration"

  mobile_web:
    description: "移动端优先的 Web 应用"
    recommended_palettes: ["warm_professional", "vibrant_modern"]
    recommended_fonts: ["friendly_rounded", "modern_neutral"]
    recommended_components: ["rounded_soft", "pill_playful"]
    avoid: ["sharp_dense"]
    key_ui_elements: ["bottom sheet", "swipe actions", "pull to refresh", "floating action button"]
    reference_products: ["Airbnb Mobile", "Instagram", "WeChat"]
    search_queries:
      - "best mobile web app design {year}"
      - "mobile UI patterns {year}"
```

**Blake 的关键任务**: 上面的 `tokens: {}` 和空的 hex 值需要 Blake 做实际研究填充。这是 Layer 1 的核心工作。

**研究方法**:
1. WebSearch 搜索各设计系统的官方文档
2. WebFetch 抓取设计系统的 theme/token 页面
3. 提取具体的色值、字体、间距等 token 值
4. 验证配色的 WCAG AA 对比度

### 4.3 Layer 2: 运行时搜索协议

> 详见 Section 4.5 的完整 playground_protocol（写入 tad-alex.md）。此处仅说明 Layer 2 的定位：Alex 在运行时根据项目类型，使用 `design-curations.yaml` 中的 `search_queries` 模板 + 自主补充搜索，获取最新设计趋势。搜索结果用于补充（不替代）预置库。
>
> **搜索失败 fallback**: 如果所有搜索返回低质量结果或搜索不可用，Alex 仅使用预置库数据，并在 research notes 中标注 "SEARCH_FALLBACK"。

### 4.4 Layer 3: HTML 呈现模板

**文件**: `.tad/templates/playground-template.html`

这是一个**实际的 HTML 文件**，包含完整的交互框架和占位符。Alex 使用时只需要把策展结果的值替换进去。

**模板结构要求**:

```
playground-template.html 结构:

<nav> 固定导航
  ├── 3-step 进度条: [1. Choose Direction] → [2. Refine Details] → [3. Confirm & Export]
  ├── Section 锚点链接
  ├── Dark/Light 切换
  └── "Inspiration Sources" 按钮 (原 "Research Notes"，UX P0-2 fix)

<main>
  <section id="direction-overview">
    <!-- 整体方向选择: 2-3 个连贯方案 -->
    <!-- 每个方向卡片 (UX P0-3 fix): -->
    <!--   名称 + 1句话描述风格 -->
    <!--   "Best for: [SaaS Dashboard] [Developer Tools]" 场景标签 -->
    <!--   "Used by: Linear, Vercel" 参考产品 -->
    <!--   ★ Recommended 徽标 (基于 industry_template 匹配度最高的方案) -->
    <!--   整体预览缩略图 -->
    <!--   "Choose This Direction" 按钮 -->
    <!--   "Why This Works" 展开说明 (1-2句话) -->
    <!--   "Skip & Use Recommended" 快速模式按钮 (位于 section 顶部) -->
  </section>

  <section id="color-palette">
    <!-- 配色方案展示 -->
    <!-- 色板网格: primary | secondary | accent | bg | surface | text | ... -->
    <!-- 对比度标注 -->
    <!-- Light/Dark 模式切换 -->
    <!-- 实际 UI 元素上的配色效果（小预览） -->
  </section>

  <section id="typography">
    <!-- 字体搭配展示 -->
    <!-- H1-H6 + body + caption 层级预览 -->
    <!-- 中英文混排效果 -->
    <!-- 系统字体预览 + 推荐 web font 标注 -->
  </section>

  <section id="components">
    <!-- 视图切换 (UX P1-4 fix): -->
    <!--   [Grid View: "See all at once"] / [Interactive: "Test hover/focus states"] -->
    <!-- 按钮: primary | secondary | outline | ghost × sizes × states -->
    <!-- 卡片: 带图 | 纯文字 | 列表型 -->
    <!-- 表单: input | select | checkbox | radio | switch -->
    <!-- 导航: header | sidebar | tabs | breadcrumb -->
    <!-- 反馈: toast | alert | modal | tooltip -->
  </section>

  <section id="spacing-borders">
    <!-- 间距体系可视化 (xs → 3xl) -->
    <!-- 圆角对比 (sharp | gentle | rounded | pill) -->
    <!-- 阴影层级 (sm | md | lg) -->
  </section>

  <section id="motion">
    <!-- 按钮 hover 效果 -->
    <!-- 卡片 hover/focus 效果 -->
    <!-- 页面过渡动效 -->
    <!-- 微交互 (toggle, expand, slide) -->
  </section>
</main>

<aside id="inspiration-sources">
  <!-- 可展开的侧边栏 (UX P0-2: 面向用户的语言) -->
  <!-- 标题: "Inspiration Sources" / 副标题: "Design backed by industry best practices" -->
  <!-- 按方案分组，默认折叠，选中方案时展开对应组 -->
  <!-- 参考来源链接 (可点击) -->
  <!-- 每个设计选择的理由 (1句话) -->
</aside>

<script>
  // Tab 切换 (方案 A/B/C)
  // Dark/Light 模式切换
  // Inspiration Sources 侧边栏展开/收起
  // 组件视图切换 (grid ↔ interactive)
  // 进度条状态更新 (Step 1/2/3)
  // 所有交互使用 vanilla JS
</script>
```

**关键设计决策**:
- 模板中所有颜色/字体/间距/圆角/阴影使用 CSS Custom Properties 占位
- Alex 填充时替换 `:root { ... }` 中的值即可改变整个页面外观
- 每个 section 的方案切换通过切换 CSS class 实现（不需要重新生成 HTML）

**模板质量要求**:
- 模板本身（填充默认值后）必须能在浏览器中正常显示
- 所有交互 (tab 切换、主题切换、侧边栏) 在模板中已实现
- WCAG AA 合规（对比度、键盘导航、ARIA、语义 HTML）
- 文件大小 < 200KB（模板本身，不含填充内容）
- 零外部依赖

### 4.5 Alex Protocol (写入 tad-alex.md)

Layer 2 的完整运行时协议。Alex 在运行时执行的步骤：

```yaml
playground_protocol:
  description: "Curation-based Frontend Design Playground"
  owner: "Alex"
  tool: "AskUserQuestion"
  trigger: "Alex *design phase when task involves frontend/UI"
  blocking: false
  prerequisite: "Socratic Inquiry completed"

  violations:
    - "不读 design-curations.yaml 直接搜索 = VIOLATION"
    - "不做运行时搜索直接使用预置值 = VIOLATION (至少补充 1 个最新趋势)"
    - "跳过用户选择直接导出 Design Tokens = VIOLATION"

  step1_frontend_detection:
    # 同前一个 Handoff，strong/weak/negative 三级关键词检测
    strong_signals: ["UI", "界面", "前端", "用户界面", "dashboard", "landing page", "配色", "样式"]
    weak_signals: ["form", "navigation", "design", "页面", "组件", "布局"]
    negative_signals: ["API", "database", "backend", "服务端", "schema", "migration", "CLI"]

  step2_context_gathering:
    description: "收集项目上下文"
    actions:
      - "读取 design-curations.yaml → 加载预置参考库"
      - "识别项目类型 → 匹配 industry_templates"
      - "检查 .tad/project-knowledge/frontend-design.md → 是否有历史设计偏好"
      - "扫描项目代码 → package.json, tailwind.config, globals.css 等"

  step3_runtime_search:
    description: "补充搜索最新设计趋势"
    min_queries: 3
    query_templates:
      - "{project_type} design trends {current_year}"
      - "best {project_type} UI {current_year} awwwards"
      - "{industry} color palette {current_year}"
    actions:
      - "WebSearch 至少 3 个查询"
      - "WebFetch 1-2 个高质量结果页面"
      - "提取新发现的设计元素（配色、字体、组件风格）"
      - "与预置库对比：补充新的、替换过时的"

  step4_assemble_options:
    description: "组装 2-3 套连贯方案"
    actions:
      - "每套方案 = 1 个 palette + 1 个 font_pairing + 1 个 component_preset"
      - "确保方案间有明显差异（不能 3 个都是冷色极简）"
      - "每套方案标注参考来源和推荐理由"
    coherence_check: "方案内部元素必须风格协调（不拼凑冲突的元素）"

  step5_fill_template:
    description: "将策展结果填入 HTML 模板"
    actions:
      - "复制 playground-template.html 到 .tad/active/playground/PLAYGROUND-{date}-{slug}/"
      - "替换 CSS Custom Properties 值"
      - "填入研究笔记和参考链接"
      - "启动本地服务器: npx serve {path} -p 3333 (或其他可用端口)"
      - "告知用户打开 http://localhost:3333"

  step6_user_selection:
    description: "渐进式选择（含进度指示和退出策略）"
    max_iterations: 2
    progress_visualization: "3-step stepper in nav: [Choose Direction] → [Refine] → [Export]"
    save_and_resume: "Allow saving current state to .tad/active/playground/temp-selection.json"

    round1_direction:
      scope: "Choose 1 of 2-3 complete direction packages (palette + font + component style)"
      user_action: "Click 'Choose This Direction' or 'Skip & Use Recommended'"
      result: "Locks in overall aesthetic — palette + font + component preset as a package"
      quick_mode: "User can click 'Skip & Use Recommended' to export recommended direction without full review"

    round2_refinement:
      scope: "Adjust individual values WITHIN the chosen direction"
      allowed_changes:
        - "Swap 1-2 accent/secondary colors"
        - "Adjust spacing scale (more/less spacious)"
        - "Tweak border radius"
      not_allowed:
        - "Cannot switch font family (part of direction package)"
        - "Cannot switch to entirely different palette (use 'Not Satisfied' instead)"
      skip_option: "Button: 'Looks perfect, export now'"

    not_satisfied:
      iteration_ui: "Show 'Iteration X of 2' counter"
      actions:
        - "Collect specific feedback (which aspects are wrong)"
        - "Re-execute step3 focused on problem areas"
        - "Generate revised playground"
      after_max_iterations: |
        Show explicit message: "Based on 2 rounds of exploration, recommend choosing the closest option.
        Details can be refined during Blake's implementation."
        Option: Fall back to text-based design brief with reference links

  step7_export:
    description: "Preview + Export Design Tokens"
    flow:
      1_generate: "生成 design-tokens.css + .json + component-spec.md"
      2_preview: "在终端显示 token 摘要 (前 10 个关键变量)"
      3_confirm: "Ask user: 'Token preview looks good? Export?' (yes/edit/back)"
      4_export: "yes → 写入文件 + project-knowledge; edit → 允许手动调整; back → 返回 step6"
    outputs:
      - "design-tokens.css (按 design-tokens-template.md 格式)"
      - "design-tokens.json"
      - "component-spec.md"
      - ".tad/project-knowledge/frontend-design.md"
```

### 4.6 Design Tokens Export

**复用现有文件**: `.tad/templates/design-tokens-template.md` — 无需修改。

导出流程不变：用户选择 → Alex 生成 CSS + JSON tokens → 写入 project-knowledge。

---

## 5. 强制问题回答 (Evidence Required)

### MQ1: 历史代码搜索

**回答**: 本次是在前一个 Handoff (frontend-playground) 基础上的方向调整。已存在的文件：
- `.tad/templates/playground-guide.md` — 需要重写
- `.tad/templates/design-tokens-template.md` — 保留
- `.tad/active/playground/` 目录 — 保留

### MQ2: 函数存在性验证

| 文件/Section | 位置 | 验证 |
|-------------|------|------|
| playground-guide.md | .tad/templates/ | ✅ 存在（需重写）|
| design-tokens-template.md | .tad/templates/ | ✅ 存在（保留）|
| design-curations.yaml | .tad/references/ | N/A（新建）|
| playground-template.html | .tad/templates/ | N/A（新建）|
| playground_protocol | tad-alex.md | N/A（新建）|
| *design 命令 | tad-alex.md commands | ✅ 存在 |
| npx serve | npm registry | ✅ 可用 |

### MQ3: 数据流完整性

**回答**: N/A — 不涉及前后端数据传递。

### MQ4: 视觉层级

**回答**: N/A — 本次创建协议和模板，不直接创建用户界面。

### MQ5: 状态同步

```
策展结果数据流:

[design-curations.yaml] (预置静态数据)
       +
[运行时搜索结果] (动态补充)
       ↓ 组装
[playground HTML] (临时呈现)
       ↓ 用户选择
[Design Tokens] (.css + .json) ← Source of Truth
       ↓ 同步
[project-knowledge/frontend-design.md] (持久化)
       ↓ 引用
[Handoff Section 4.5] (Blake 实现参考)

唯一 Source of Truth: Design Tokens files
```

---

## 6. Implementation Steps

### Phase 1: 预置设计参考库 (Layer 1 + Layer 4)

#### 交付物
- [ ] `.tad/references/design-curations.yaml` — 完整填充的设计参考库

#### 实施步骤

**1. 创建 .tad/references/ 目录**

**2. 研究并填充 design_systems 的 tokens**

对每个设计系统 (Shadcn, Radix, Ant Design, Material Design 3, Chakra UI)：
- WebSearch 搜索其官方文档的 theme/token 页面
- WebFetch 抓取 token 值
- 填入 design-curations.yaml 的对应 `tokens` 字段
- 至少提取: colors (primary, secondary, accent, bg, surface, text, border, error, success), border-radius, shadow, spacing scale

**3. 研究并填充 color_palettes**

对每组预定义的配色 (cool_minimal, warm_professional, vibrant_modern, dark_bold, neutral_enterprise)：
- WebSearch 搜索参考产品的实际配色
- 提取 light 和 dark 模式的完整色值
- 验证 text on background 的对比度 >= 4.5:1 (WCAG AA)
- 填入所有 hex 值

**4. 研究并填充 component_presets 的 shadow_values**

对每个预设 (rounded_soft, sharp_dense, pill_playful)：
- 参考对应的设计系统文档
- 提取 shadow 具体 CSS 值
- 填入 shadow_values

**5. 验证行业模板的推荐组合**

确认每个 industry_template 的 recommended 组合是协调的（不冲突）。

#### Phase 1 完成证据
- [ ] design-curations.yaml 所有 `tokens: {}` 和空 hex 值已填充
- [ ] 至少 5 组配色方案有完整的 light + dark 色值
- [ ] 至少 3 个设计系统有提取的 token 值
- [ ] 配色方案的文字对比度通过 WCAG AA

---

### Phase 2: HTML 呈现模板 (Layer 3)

#### 交付物
- [ ] `.tad/templates/playground-template.html` — 可填充的 HTML 模板
- [ ] `.tad/templates/playground-guide.md` — 重写（策展+填充指南）

#### 实施步骤

**1. 创建 playground-template.html**

按 Section 4.3 的结构规范创建完整的 HTML 模板。关键要求：
- 所有设计值使用 CSS Custom Properties（Alex 替换 `:root` 值即可）
- 内置 tab 切换（方案 A/B/C）
- 内置 Dark/Light 切换
- 内置 Research Notes 侧边栏
- 组件 section 有 static/interactive 两种视图
- 所有交互用 vanilla JS 实现
- WCAG AA 合规
- 填入默认值后能在浏览器中正常显示

**2. 重写 playground-guide.md**

从"生成指南"改为"策展+填充指南"。新内容：

```
# Playground Curation & Assembly Guide

## 1. Alex 的角色
- 不从零设计，从预置库 + 搜索结果中选择和组合
- 保证方案的连贯性和质量下限

## 1.1 User-Facing Language (UX P0-2)
- ❌ 不对用户说 "Alex acts as a curator" 或 "策展"
- ✅ 对用户说 "Alex presents design options from award-winning products and top design systems"
- ❌ 侧边栏标题不叫 "Research Notes"
- ✅ 叫 "Inspiration Sources" + 副标题 "Design backed by industry best practices"
- ❌ 不说 "curated palette"
- ✅ 说 "color scheme inspired by {product_name}"

## 2. 策展流程
- Step 1: 读取 design-curations.yaml
- Step 2: 匹配 industry_template
- Step 3: 运行时搜索补充
- Step 4: 组装 2-3 套方案
- Step 5: 填充 playground-template.html

## 3. 填充规范
- 如何替换 CSS Custom Properties
- 如何填入研究笔记
- 如何添加参考链接

## 4. 质量检查清单
- 方案间差异度 (不能太相似)
- 方案内连贯性 (palette + font + component 协调)
- WCAG AA 对比度
- 所有交互可用

## 5. 本地服务器启动
- npx serve 命令
- 端口选择策略
```

#### Phase 2 完成证据
- [ ] playground-template.html 在浏览器中可正常显示（填入默认值后）
- [ ] 所有交互（tab 切换、主题切换、侧边栏）正常工作
- [ ] WCAG AA 合规（键盘导航、ARIA、对比度）
- [ ] playground-guide.md 已重写为策展+填充指南
- [ ] 文件大小 < 200KB

---

### Phase 3: Alex 协议集成 (Layer 2) + Config 更新

#### 交付物
- [ ] `tad-alex.md` — 添加策展型 playground_protocol + design_protocol + *playground 命令
- [ ] `config-workflow.yaml` — 添加 playground 配置
- [ ] `config.yaml` — 更新 master index
- [ ] `CLAUDE.md` — 添加使用场景

#### 实施步骤

**1. tad-alex.md 更新**

a. 在 commands section 添加:
```yaml
playground: Launch Curation-based Design Playground (sub-phase of *design)
```

b. 添加完整的 playground_protocol（参考 Section 4.4）

c. 创建 design_protocol section:
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

d. 更新 success_patterns 和 Quick Reference

**2. config-workflow.yaml 更新**

> **注意 (P1-6 fix)**: config-workflow.yaml 可能已有旧的 `playground:` section（来自前一个 Handoff 的 Phase 1）。如果已存在，**更新**其内容为策展型描述；如果不存在，则新建。同时确认 `document_management.structure` 的 active/archive 列表包含 `playground`。

添加/更新 playground section 为策展型描述 + 添加对 `design-curations.yaml` 和 `playground-template.html` 的引用。

**3. config.yaml 更新**

> **注意 (P1-5 fix)**: config.yaml 的 `config_modules.config-workflow.yaml.contains` 可能已有旧的 playground 行（如 `playground (config, research_requirements, generation, export, cleanup)`）。如果已存在，**替换**为新内容；如果不存在，则添加。

更新为:
```yaml
- playground (curation, runtime_search, template_fill, selection, export)
```

**4. CLAUDE.md 更新**

在 Section 2 表格中添加:
```
| `/alex` + `*playground` | 任务涉及前端/UI 设计，需要可视化探索 |
```

#### Phase 3 完成证据
- [ ] tad-alex.md 包含策展型 playground_protocol
- [ ] protocol 结构符合 TAD 格式 (violations, tool, step numbering)
- [ ] config-workflow.yaml 包含 playground section
- [ ] config.yaml contains 列表包含 playground
- [ ] CLAUDE.md 提及 Playground

---

## 7. File Structure

### Files to Create
```
.tad/references/design-curations.yaml        # Layer 1 + 4: 预置设计参考库
.tad/templates/playground-template.html       # Layer 3: HTML 呈现模板
```

### Files to Modify
```
.tad/templates/playground-guide.md            # 重写: 生成指南 → 策展+填充指南
.claude/commands/tad-alex.md                  # Layer 2: 策展型协议
.tad/config-workflow.yaml                     # playground 配置
.tad/config.yaml                              # master index
CLAUDE.md                                     # 使用场景
```

### Files to Keep (No Changes)
```
.tad/templates/design-tokens-template.md      # 导出格式不变
.tad/active/playground/.gitkeep               # 目录已存在
.tad/archive/playground/.gitkeep              # 目录已存在
```

---

## 8. Testing Requirements

### Verification Scenarios
- [ ] **场景 1**: design-curations.yaml 结构完整，所有 token 值已填充
- [ ] **场景 2**: playground-template.html 在 Chrome/Safari 中正常显示
- [ ] **场景 3**: Tab 切换、主题切换、侧边栏交互正常
- [ ] **场景 4**: npx serve 启动后能在 localhost 访问
- [ ] **场景 5**: 非前端任务不触发 Playground（关键词检测准确）
- [ ] **场景 6**: tad-alex.md 协议结构符合 TAD YAML 格式
- [ ] **场景 7**: 不影响现有 TAD 流程

### 8.2 Accessibility Verification (WCAG AA — UX P0-4)

Blake 必须验证 playground-template.html 满足以下每一项：

**Contrast Ratio**:
- [ ] 所有 normal text on background >= 4.5:1
- [ ] 所有 large text (18px bold / 24px) >= 3:1
- [ ] 验证工具: WebAIM Contrast Checker 或 Chrome DevTools Accessibility audit

**Keyboard Navigation**:
- [ ] Tab 顺序逻辑（从上到下，从左到右）
- [ ] 所有按钮、tab、toggle 可通过 Tab 键到达
- [ ] Enter/Space 激活按钮和方案选择
- [ ] Escape 关闭侧边栏
- [ ] Focus ring 可见: `outline: 2px solid var(--color-primary); outline-offset: 2px`

**ARIA Labels**:
- [ ] `<nav>` 有 `aria-label="Playground Navigation"`
- [ ] Tab 组有 `role="tablist"`, `role="tab"`, `role="tabpanel"`
- [ ] Dark/Light 切换有 `role="switch"` + `aria-pressed`
- [ ] 侧边栏有 `aria-expanded` 状态
- [ ] 方案选择按钮有描述性 `aria-label`

**Semantic HTML**:
- [ ] 使用 `<button>` 而非 `<div onclick>`
- [ ] 使用 `<nav>`, `<main>`, `<section>`, `<aside>` 语义化标签
- [ ] Heading 层级正确 (h1 > h2 > h3，不跳级)
- [ ] Skip navigation link: 首个可聚焦元素链接到 `#playground-main`

### 8.3 Edge Cases
- 项目无现有前端代码 → 纯依赖 design-curations.yaml + 搜索
- 项目已有 frontend-design.md → 读取历史偏好
- design-curations.yaml 中的参考网站不可访问 → 依赖预置 token 值
- 运行时搜索全部失败 → 使用预置库 + 标注 SEARCH_FALLBACK

---

## 9. Acceptance Criteria

Blake 的实现被认为完成，当且仅当：

- [ ] `.tad/references/design-curations.yaml` 存在且所有 token/色值已填充（非空）
- [ ] 至少 5 组配色方案有完整 light + dark 模式色值
- [ ] 至少 5 组字体搭配有 heading + body + fallback
- [ ] 至少 3 个行业模板 (SaaS/Consumer/Landing Page) 有推荐组合
- [ ] `.tad/templates/playground-template.html` 存在且可在浏览器中正常显示
- [ ] HTML 模板所有交互可用（tab、主题切换、侧边栏、static/interactive 视图）
- [ ] HTML 模板 WCAG AA 合规（通过 Section 8.2 全部检查项）
- [ ] HTML 模板包含 3-step 进度条 + "Skip & Use Recommended" 快速模式
- [ ] HTML 模板方向卡片包含 best_for 标签 + Recommended 徽标 + "Why This Works"
- [ ] HTML 侧边栏标题为 "Inspiration Sources"（非 "Research Notes"）
- [ ] `.tad/templates/playground-guide.md` 已重写为策展型指南（含 User-Facing Language section）
- [ ] `tad-alex.md` 包含策展型 playground_protocol (7 steps)
- [ ] 关键词触发使用 strong/weak/negative 三级分类
- [ ] config-workflow.yaml 和 config.yaml 已更新（更新现有 playground 行，非新增）
- [ ] 旧 Handoff 已归档到 .tad/archive/handoffs/
- [ ] 不影响现有 TAD 流程

---

## 10. Important Notes

### 10.1 Critical Warnings

- **策展不是偷懒** — Alex 读预置库 + 搜索是为了保证质量下限，不是跳过研究
- **Design Tokens 是 Source of Truth** — Blake 实现时必须使用导出的 token
- **HTML 模板是框架** — Alex 填值，不需要修改模板结构；如需结构修改应更新模板文件本身

### 10.2 Known Constraints

- 预置参考库会随时间过时 → 运行时搜索补充最新趋势
- HTML 预览使用系统字体栈 → token 注释中标注推荐 web font
- 本地服务器需要 npx（用户已有 node.js 环境）

### 10.3 Design Consistency Verification (Gate 4)

同前一个 Handoff 的设计，Gate 4 时检查:
- Color exact match: 实现中颜色值与 Design Tokens 100% 匹配
- Font family match: 字体族一致
- Spacing deviation < 4px
- Border radius deviation < 2px
- 用户一致性满意度 >= 4/5

### 10.4 Sub-Agent 使用建议

- [ ] **code-reviewer** — 审查 design-curations.yaml 结构和 HTML 模板质量
- [ ] **frontend-specialist** — 审查 playground-template.html 的前端实现质量
- [ ] **test-runner** — 验证不影响现有 TAD 流程

---

## 11. Learning Content

### Why Curation > Generation

| 维度 | AI 生成 | AI 策展 |
|------|---------|---------|
| 质量下限 | 不稳定（可能很差）| 有保障（参考库是高质量的）|
| 速度 | 快但不可靠 | 预置库加速，搜索补充 |
| AI 能力匹配 | 需要设计能力（AI 弱项）| 需要搜索+分析+组织能力（AI 强项）|
| 用户信任 | "AI 设计的"→ 低信任 | "业界最佳实践"→ 高信任 |
| 可追溯 | 设计来源不明 | 每个选择标注参考来源 |

### Key Architectural Decision

**为什么用 4 层架构**: 将"策展能力"拆分为静态知识（Layer 1/4）和动态能力（Layer 2/3），确保即使运行时搜索失败，Alex 仍有预置库可用（graceful degradation）。

---

**Handoff Created By**: Alex (Solution Lead)
**Date**: 2026-02-04
**Version**: 2.3.0-curation
