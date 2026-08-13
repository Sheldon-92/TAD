# Mobile Wireframing (with Gesture Annotations, Mobile-Viewport HTML Prototype)

## Workflow

### Layer 1 — Research layouts
Search mobile layout references (web search):
1. Key-page layouts of 3+ comparable apps
2. Identify mobile layout patterns: 列表型 / 卡片型 / 全屏型 / 分段型
3. Record each reference app's core interaction pattern

Example queries:
- `"{领域}" iOS app UI design screenshot`
- `"{领域}" mobile app layout pattern`

Output: `wireframe-research.md`.

### Layer 2 — Design 3 UX approaches
Table: `| 方案 | 布局哲学 | 优势 | 风险 |`
- 方案 1: 参考最成功竞品的验证过模式
- 方案 2: 探索不同的信息组织方式
- 方案 3: 强调差异化的创新布局

Score each approach on:
- 学习成本（1=高, 5=低）
- 信息密度（1=低, 5=高）
- 平台规范合规度（1=低, 5=高）
- 单手操作友好度（1=低, 5=高）

Quality bar: the 3 approaches must differ substantively; scoring must include platform compliance and one-hand-operation dimensions. Append to `wireframe-research.md`.

### Layer 3 — Select and design wireframes
1. Pick the best approach by combined score.
2. Design rules:
   - 移动视口：390×844pt（iPhone 15 逻辑分辨率）
   - 灰度色板（B&W 线框阶段）
   - 标注触控目标区域（≥44pt 虚线框）
   - 标注手势交互（左滑→删除，下拉→刷新 等）
   - 标注 Safe Area（顶部 + 底部）
3. Cover ALL key pages (≥5 pages).

Output: `wireframe-design.md`.

### Layer 4 — Generate HTML prototype (mobile viewport)
Build `wireframe.html`:
- viewport: width=390px（CSS `max-width: 390px; margin: auto`）
- 灰度色板，系统字体
- Tab Bar 在底部，Navigation Bar 在顶部
- 可点击的 Tab 切换
- 手势标注用虚线 + 文字说明

Then screenshot with Playwright at 390×844 viewport → `wireframe-screenshot.png`.

## Quality Criteria (pass/fail)
- 线框图使用移动视口（390×844pt 或等效）
- 所有触控目标 ≥ 44pt（iOS）或 ≥ 48dp（Android）
- 有 Safe Area 标注（顶部状态栏 + 底部 Home Indicator）
- 有手势交互标注（滑动、长按等）
- 覆盖 ≥5 个关键页面
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
