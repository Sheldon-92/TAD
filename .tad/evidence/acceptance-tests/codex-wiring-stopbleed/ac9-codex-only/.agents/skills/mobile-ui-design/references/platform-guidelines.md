# Platform Guidelines Research (iOS HIG / Material Design 3)

Research the target platform's design rules, extract hard constraints, and derive platform decisions BEFORE any design work.

## Workflow

### Layer 1 — Research platform rules
Search the latest platform specs (web search):
1. iOS HIG: latest Human Interface Guidelines updates
2. Material Design 3: latest M3 component specs
3. Reference apps in the target domain (screenshots / reviews of comparable apps)

Determine target platform: iOS-only / Android-only / cross-platform.

Example queries:
- `"iOS Human Interface Guidelines" {领域} app design 2026`
- `"Material Design 3" {领域} app component guidelines`
- `"{领域}" iOS app design review UI UX`

Output: `platform-research.md` under the project research dir.

### Layer 2 — Extract hard constraints
Build constraint tables with concrete values and sources (`| 约束 | 值 | 来源 |`).

**iOS constraint checklist:**
- 触控目标 ≥ 44×44 pt
- Tab Bar ≤ 5 项
- Navigation Bar 高度 44pt
- Tab Bar 高度 49–83pt（含 Home Indicator）
- Status Bar 44pt（刘海）/ 59pt（灵动岛）
- Home Indicator Safe Area 底部 34pt
- 8pt 网格系统（4pt 微调）
- SF Pro Text ≤19pt / SF Pro Display ≥20pt
- 圆角：10pt（小）/ 13pt（中）/ 20pt（大）
- Back 按钮左上角，Action 按钮右上角，Tab 底部

**Android constraint checklist:**
- 触控目标 ≥ 48×48 dp
- Bottom Navigation ≤ 5 项（必须有 label + icon）
- Top App Bar 高度 64dp
- 8dp 间距系统
- Roboto 字体（15 种 Typography tokens）
- 圆角：4dp（小）/ 12dp（中）/ 28dp（大/FAB）

**Cross-platform difference table (`| 维度 | iOS | Android |`):**
- 导航返回：系统手势左滑 / 返回按钮
- 删除：左滑删除 / 长按菜单
- 模态：Sheet（从底部） / Dialog（居中）
- 图标：SF Symbols / Material Icons
- 字体：SF Pro / Roboto

Quality bar: every constraint has a concrete value (pt/dp), never "适当大小". Cite the source. Append to `platform-research.md`.

### Layer 3 — Derive design decisions
Based on constraints + project requirements, decide:
1. **Target platform choice (with reason)**: iOS-first → why? (用户群、市场策略); Android-first → why?; 跨平台 → 共享设计语言 vs 平台原生?
2. **Adaptation strategy**:
   - 完全原生（每平台独立设计）— 最佳体验，双倍工作
   - 共享核心 + 平台皮肤 — 平衡策略
   - 完全共享（一套设计两平台）— 效率最高，体验折中
3. **Platform-specific scenario list**: `| 场景 | iOS 做法 | Android 做法 | 选择 |`

Quality bar: every decision has a reason; every cross-platform difference has an explicit handling plan. Output: `platform-decisions.md`.

### Layer 4 — Generate summary
Compile a platform-guidelines summary PDF (Typst PDF generation): constraint checklists + design decisions + cross-platform difference table. Output: `platform-guidelines.pdf`.

## Quality Criteria (pass/fail)
- 触控目标尺寸有具体数值（iOS ≥44pt, Android ≥48dp）
- 字体系统有完整的 Typography scale（≥8 种 text style）
- 跨平台差异有逐项对比表
- 设计决策有理由（不是"选 iOS 因为好"）
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
