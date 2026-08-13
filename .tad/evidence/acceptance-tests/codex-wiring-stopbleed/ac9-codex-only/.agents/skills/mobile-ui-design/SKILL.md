---
name: mobile-ui-design
description: "Mobile UI design capability pack. Covers iOS HIG / Material Design 3 platform-guideline research, mobile navigation architecture (Tab Bar/Stack/Modal/Drawer), mobile-viewport wireframing with gesture annotations, platform-native visual design and Design Tokens, gesture interaction specs, native-first mobile design systems, and mobile usability review (touch targets, Dynamic Type, one-hand reachability). Use for any mobile app UI/UX design, wireframe, design token, gesture spec, or mobile design review task."
version: 0.1.0
type: reference-based
keywords: ["mobile UI design", "移动端设计", "iOS HIG", "Material Design", "界面设计", "线框图", "wireframe", "导航架构", "Tab Bar", "手势交互", "gesture", "Design Tokens", "设计系统", "design system", "暗色模式", "dark mode", "可用性审查", "usability", "触控目标", "touch target", "无障碍", "accessibility", "Dynamic Type", "Safe Area"]
---

# Mobile UI Design Capability Pack

> Cross-agent portable judgment for mobile interface design — iOS HIG / Material Design 3 compliant. Outputs are wireframes, Design Tokens, interaction specs, and component inventories. Core difference vs web: platform-mandated rules, gesture interaction, touch targets ≥44pt.
> **CONSUMES**: Product requirements, page inventory, target-platform intent.
> **PRODUCES**: Platform research + decisions, navigation diagrams, mobile-viewport HTML wireframes, design-tokens.json/css, gesture spec, component spec, usability audit (per-project research dir; see `references/review-checklist.md` for the full output structure).

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| new mobile design, HIG, Material 3, platform rules, cross-platform strategy, Safe Area, 平台规范, 设计约束 | `references/platform-guidelines.md` |
| navigation, tab bar, stack, drawer, bottom sheet, sitemap, deep link, information architecture, 导航, 页面层级 | `references/navigation.md` |
| wireframe, prototype, layout, screen design, UX approaches, mobile viewport, 线框图, 原型, 布局 | `references/wireframing.md` |
| color, typography, icons, dark mode, design tokens, style guide, contrast, 视觉设计, 色彩, 字体, 暗色模式 | `references/visual-design.md` |
| gesture, swipe, long-press, pinch, pull-to-refresh, haptic, animation timing, 手势, 滑动, 长按 | `references/gesture-interaction.md` |
| component library, native components, custom component, Atomic Design, 组件库, 组件规范 | `references/design-system.md` |
| usability audit, touch-target audit, WCAG, pa11y, heuristic evaluation, Dynamic Type check, 可用性, 无障碍审查 | `references/usability-review.md` |
| before gate review / accepting mobile UI design work, Gate 2/Gate 4 for a mobile design task, 验收, 专家审查 | `references/review-checklist.md` |

**Multi-signal**: Load all matched references. Each reference carries the step-level workflow (research → analyze → derive → generate), example search queries, output artifacts, and its pass/fail quality criteria.

---

## Step 2: Decision Entry Points

**Q1 — Which platform?** iOS-only / Android-only / cross-platform must be decided WITH reasons (user base, market strategy) — never "选 iOS 因为好". Cross-platform additionally requires an adaptation strategy choice: 完全原生 (best experience, double work) / 共享核心+平台皮肤 (balanced) / 完全共享 (efficient, compromised). Load `references/platform-guidelines.md` FIRST — no design work before platform constraints are extracted with concrete values.

**Q2 — Which navigation container?** Tab Bar (≤5 high-frequency pages, primary nav) / Stack (detail pages, push/pop) / Modal Sheet (quick actions, create forms) / Drawer (low-frequency settings, more common on Android). Selection is driven by page frequency + hierarchy depth — see `references/navigation.md`.

**Q3 — Native or custom component?** Native first, always. A custom component is allowed ONLY with a written "为什么不用原生" justification — see `references/design-system.md`.

**Q4 — Is design work "done"?** Not until the usability review passes: automated WCAG + touch-target audit + 15-heuristic evaluation with P0 = 0 — see `references/usability-review.md`. Then run the persona checklists in `references/review-checklist.md` before gate review / accepting mobile UI design work.

---

## Step 3: Core Judgment Rules (always apply)

These constraints hold regardless of which reference is loaded:

1. **Touch targets ≥ 44×44pt (iOS) / ≥ 48×48dp (Android)** — below 44pt drives 25%+ mis-tap rates. Any interactive element under the floor is a P0 violation.
2. **Tab Bar ≤ 5 items** (iOS HIG hard limit; Android Bottom Navigation same, each item needs label + icon). Page hierarchy ≤ 3 levels (Root → Detail → Sub-detail).
3. **Respect Safe Area** — notch/Dynamic Island top, Home Indicator bottom (34pt). Content must never sit under them.
4. **Thumb Zone placement** — high-frequency actions in the bottom thumb hot zone (Tab Bar, FAB bottom-right); never put important actions at the screen top only.
5. **System gestures are untouchable** — iOS left-edge swipe = back, bottom swipe = Home; Android system back. Overriding them is an App Review risk.
6. **Every gesture needs a non-gesture alternative** (button/menu) — VoiceOver/TalkBack users must not depend on gestures. Every gesture needs visual feedback and concrete trigger values (pt/ms).
7. **Platform-native visual systems only** — iOS semantic system colors + SF Pro + SF Symbols; Android Material 3 Color Scheme + Roboto + Material Icons. Never invent parallel systems, never mix icon sets.
8. **Dark mode is designed, not inverted** — iOS Elevated backgrounds (3 gray levels), Android Surface tones; pure black #000000 is forbidden by Material.
9. **Dynamic Type (iOS) / Material Typography (Android) support is mandatory** — layouts must survive enlarged text.
10. **Text-background contrast ≥ 4.5:1** (WCAG AA), verified — not eyeballed.
11. **Design on a mobile viewport** — 390×844pt (or equivalent); a >430px-wide wireframe is a web layout, not a mobile one.
12. **Design Tokens must distinguish iOS vs Android system values** (color/typography/spacing/radius/touchTarget), 8pt grid shared.
13. **Every constraint and decision carries a concrete value and a reason** — "适当大小" is not a spec.
14. **Fabricated data = FAIL** — uncertain values must be tagged [ASSUMPTION]. Applies to every capability's quality gate.

### Per-Reference Pass/Fail Anchors

- `references/platform-guidelines.md` — constraints have concrete pt/dp values with sources; typography scale ≥8 text styles; cross-platform differences in a per-item comparison table; decisions have reasons.
- `references/navigation.md` — Tab Bar ≤5; hierarchy ≤3; high-frequency actions in the thumb zone; every page has a deep-link path; navigation flow diagram exists.
- `references/wireframing.md` — 3 substantively different UX approaches scored (incl. platform compliance + one-hand operation); mobile viewport; Safe Area + gesture annotations; ≥5 key pages covered.
- `references/visual-design.md` — platform-native color/type/icons; dark mode designed; contrast ≥4.5:1 verified; tokens split iOS/Android.
- `references/gesture-interaction.md` — system gestures excluded; every custom gesture has pt/ms trigger values; conflicts (e.g., swipe-delete vs edge-back) detected AND resolved; accessibility alternative per gesture; discoverability plan exists.
- `references/design-system.md` — native-first with justification for customs; ≥12 components fully specced (size + states + accessibility); platform-difference notes; Atomic Design layering.
- `references/usability-review.md` — automated WCAG + touch-target audits executed; all 15 heuristics (Nielsen 10 + mobile 5) scored with concrete findings; P0 = 0 to pass.
- `references/review-checklist.md` — 7 review personas + Gate 2 / Gate 4 checklists; run before gate review or accepting mobile UI design work.

---

## Anti-Patterns

### Platform Guidelines
- ❌ 不查 HIG/Material 就开始设计 = 违反平台规范
- ❌ 用 Web 的设计思路做移动端（侧边栏→Tab Bar）
- ❌ 忽略 Safe Area（刘海/灵动岛/Home Indicator 遮挡内容）
- ❌ 触控目标 <44pt（iOS 研究：<44pt 导致 25%+ 误触率）
- ❌ 跨平台设计完全忽略平台差异（返回手势、删除模式不同）

### Navigation
- ❌ Tab Bar 超过 5 项 = 认知过载（iOS HIG 硬限制）
- ❌ 把重要操作放在屏幕顶部 = 单手不可达
- ❌ 用 Hamburger Menu 替代 Tab Bar（隐藏 = 不存在）
- ❌ Modal 套 Modal = 导航混乱
- ❌ 没有返回路径（用户被困在详情页）

### Wireframing
- ❌ 用桌面宽度设计移动端线框图（>430px 宽）
- ❌ 触控按钮只有 20pt 高 = 无法点击
- ❌ 忽略 Safe Area = 内容被刘海/Home Indicator 遮挡
- ❌ 只画首页不画详情页和交互流程
- ❌ 没有手势标注 = 开发时不知道要实现什么手势

### Visual Design
- ❌ 自定义字体替代 SF Pro/Roboto = 破坏 Dynamic Type 支持
- ❌ 暗色模式用纯黑 #000000 = Material 规范禁止（用 Surface tones）
- ❌ 图标用 PNG 不用矢量 = 不支持多尺寸/多色渲染
- ❌ 忽略 Elevated 颜色层级（iOS 暗色模式有 3 级灰度）
- ❌ 混用 SF Symbols 和 Material Icons = 视觉不一致

### Gesture Interaction
- ❌ 覆盖系统返回手势 = iOS 审核风险
- ❌ 左滑删除和边缘返回手势冲突未处理
- ❌ 手势无视觉反馈（用户不知道手势是否触发）
- ❌ 手势是唯一操作方式（VoiceOver 用户无法使用）
- ❌ 长按触发 <500ms = 和普通点击混淆

### Design System
- ❌ 所有组件自定义（不用原生 Tab Bar、Navigation Bar）
- ❌ 组件只有 Default 状态（缺 Pressed/Disabled/Loading）
- ❌ 忽略 VoiceOver/TalkBack 无障碍标注
- ❌ iOS 和 Android 用完全相同的组件（忽略平台差异）

### Usability Review
- ❌ 只做自动化检查不做人工评估
- ❌ 忽略 Dynamic Type（放大字体后文字被截断）
- ❌ 忽略单手操作（重要按钮在屏幕顶部）
- ❌ "界面清晰"这种空话结论（必须有具体发现）

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I know mobile design, skip the HIG research" | MUST extract platform constraints with concrete pt/dp values first — see `references/platform-guidelines.md` |
| "Six tabs, users will manage" | MUST keep Tab Bar ≤5 items; restructure hierarchy per `references/navigation.md` |
| "One desktop-width mockup is enough" | MUST use a 390×844 mobile viewport with Safe Area + gesture annotations and cover ≥5 key pages — see `references/wireframing.md` |
| "Dark mode = invert the colors later" | MUST design dark mode with Elevated/Surface tones — see `references/visual-design.md` |
| "Swipe-to-delete is obvious, no spec needed" | MUST spec trigger values (pt/ms), resolve gesture conflicts, and add non-gesture alternatives — see `references/gesture-interaction.md` |
| "Custom components look more unique" | MUST default to native components; each custom needs a written why-not-native — see `references/design-system.md` |
| "The design looks clean, ship it" | MUST run automated WCAG + touch-target audits and the 15-heuristic evaluation to P0 = 0 — see `references/usability-review.md` |
| "Skipping the reviewer checklists" | Before gate review / accepting mobile UI design work, MUST run the persona checklists in `references/review-checklist.md` |
