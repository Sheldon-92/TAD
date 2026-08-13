# Mobile Usability Review (Touch Targets, Reachability, Dynamic Type, A11y)

## Workflow

### Step 1 — Gather artifacts
Collect all completed design outputs (wireframes, component showcase, gesture spec). Start `usability-audit.md`.

### Step 2 — Automated checks (on HTML artifacts)
1. **pa11y WCAG check**（对比度、标签、ARIA）
2. **Touch-target size audit**（检查所有可点击元素 ≥44pt）:
   - 在 HTML 中检查所有 button/a/input 的 height/width/padding
   - 小于 44px 的标记为 P0 违规
3. **Playwright screenshot** at 390×844 viewport to verify mobile rendering

Output: `a11y-report.json`.

### Step 3 — Heuristic evaluation (Nielsen 10 + Mobile 5)
Nielsen 10 条（参考 web-ui-design pack 的 usability review）+ 移动端额外 5 条：

11. **单手可操作性** — 核心功能能否单手完成？高频操作在拇指热区？
12. **触控目标达标** — 所有可交互元素 ≥44pt (iOS) / ≥48dp (Android)？
13. **Dynamic Type 支持** — 放大字体后布局是否崩溃？
14. **手势可发现性** — 新用户能否不看说明就发现手势？
15. **平台规范合规** — 导航/交互是否符合 iOS HIG / Material Design？

每条评分 1–5，<3 的列为 P0 改进项。

Quality bar: all 15 heuristics scored; the 5 mobile items MUST have concrete findings (never "界面清晰" style conclusions). Append to `usability-audit.md`.

### Step 4 — Derive the improvement list
Table: `| # | 问题 | 严重度 | 来源 | 修复方案 |`
- **P0**: WCAG 违规、触控目标不达标、核心功能单手不可达
- **P1**: 体验不佳但可用
- **P2**: 美观优化

Quality bar: P0 count must reach 0 to pass; every issue has a concrete fix. Append to `usability-audit.md`.

### Step 5 — Generate the audit report
Compile a usability audit report PDF (Typst): `mobile-usability-audit.pdf`.

## Quality Criteria (pass/fail)
- 自动化 WCAG 检查已执行
- 触控目标审计已执行（所有可交互元素 ≥44pt）
- 15 条启发式（Nielsen 10 + 移动 5）全评
- P0 问题有具体修复方案
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
