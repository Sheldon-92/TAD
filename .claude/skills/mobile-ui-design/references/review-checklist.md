# Expert Review Personas & Gate Checklists

Use during Gate reviews or whenever mobile UI design work needs expert review. Spawn each persona as a reviewer (Execution-Review Separation: personas ONLY for review, never during execution).

## Review Personas (per capability)

### iOS/Android 设计规范专家 — platform guidelines work
- 是否遵循目标平台的官方设计规范？
- 触控目标是否达标？
- 平台特定的导航/交互模式是否正确？

### 移动端 UX 架构师 — navigation work
- 导航模式是否符合平台规范？
- 核心功能是否 ≤2 次点击可达？
- 是否考虑了单手操作？

### 移动端 UI 设计师 — wireframing work
- 视口尺寸是否正确？
- 触控目标是否达标？
- 手势交互是否标注清楚？

### 移动端视觉设计师 — visual design work
- 色彩系统是否遵循平台规范？
- 字体是否支持 Dynamic Type？
- 暗色模式是否正确（非简单反转）？

### 交互设计师 — gesture interaction work
- 手势是否符合平台习惯？
- 手势冲突是否解决？
- 无障碍替代是否完整？

### 设计系统架构师 — design system work
- 原生组件是否优先使用？
- 组件规范是否完整（尺寸+状态）？
- 是否有平台差异标注？

### 移动端 QA 工程师 — usability review work
- 触控目标是否全部达标？
- Dynamic Type 放大后布局是否正常？
- 核心流程能否单手完成？

## Gate 2 (Design) Checklist
- 平台规范约束已提取（具体数值）
- 导航架构有 Tab Bar + Stack + Modal 设计
- 线框图使用移动视口
- 触控目标 ≥ 44pt (iOS) / ≥ 48dp (Android)
- 手势交互有状态图和无障碍替代

## Gate 4 (Acceptance) Checklist
- pa11y WCAG 检查已执行
- 15 条启发式评估 P0 = 0
- Design Tokens 区分 iOS/Android
- 组件规范有平台差异标注
- 暗色模式有设计（非简单反转）

## Expected Output Structure (per project research dir)

```
.tad/active/research/{project}/
├── platform-research.md / platform-decisions.md / platform-guidelines.pdf
├── navigation-research.md / navigation-design.md / navigation-flow.svg / mobile-sitemap.svg
├── wireframe-research.md / wireframe-design.md / wireframe.html / wireframe-screenshot.png
├── visual-research.md / design-tokens.json / design-tokens.css / mobile-style-guide.pdf
├── gesture-research.md / gesture-spec.md / gesture-states.svg / gesture-interaction.pdf
├── component-research.md / component-spec.md / component-showcase.html / mobile-design-system.pdf
└── usability-audit.md / a11y-report.json / mobile-usability-audit.pdf
```
