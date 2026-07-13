# Mobile Design System (Native Component Selection + Custom Component Specs)

## Workflow

### Layer 1 — Research components
Web search:
1. iOS 原生组件清单（UIKit/SwiftUI）
2. Material 3 组件清单
3. 目标 App 需要的自定义组件

Example queries:
- `"iOS native components" UIKit SwiftUI list 2026`
- `"Material Design 3" component catalog`

Output: `component-research.md`.

### Layer 2 — Component specs (native-first)
优先使用平台原生组件。自定义组件仅在原生不满足需求时创建。

**Native component selection table (at minimum cover)** `| 组件 | iOS | Android | 使用场景 |`:
- Navigation Bar: UINavigationBar / TopAppBar
- Tab Bar: UITabBar / BottomNavigation
- List: UITableView/List / LazyColumn
- Card: 自定义 / Card
- Button: UIButton / Button（3 种: Filled/Tonal/Text）
- TextField: UITextField / OutlinedTextField
- Sheet: UISheetPresentationController / BottomSheet
- Alert: UIAlertController / AlertDialog
- Toast: 无原生 / Snackbar
- FAB: 无原生（按钮替代） / FloatingActionButton
- Segmented Control: UISegmentedControl / SegmentedButton
- Switch: UISwitch / Switch
- Slider: UISlider / Slider

**Every component must be annotated with:**
- 尺寸（高度、内边距）
- 状态（Default/Pressed/Disabled/Loading）
- 无障碍（VoiceOver label、最小触控区域）
- 平台差异

Append to `component-research.md`.

### Layer 3 — Derive the component system
1. **Atomic Design layering** (原子 → 分子 → 有机体):
   - 原子：Button, Icon, Label, Badge
   - 分子：ListItem (Icon + Label + Chevron), SearchBar (TextField + Icon)
   - 有机体：NavigationBar, TabBar, Card (Image + Title + Subtitle + Actions)
2. **Custom component list** (only when native falls short): `| 组件 | 为什么不用原生 | 设计规范 |`
3. Component API（属性/变体/尺寸）
4. Do/Don't 使用指南

Quality bar: every custom component has a "为什么不用原生" justification. Output: `component-spec.md`.

### Layer 4 — Generate artifacts
- Component showcase HTML（移动视口，使用 Design Tokens）: `component-showcase.html`
- Mobile design system doc PDF (Typst): `mobile-design-system.pdf`

## Quality Criteria (pass/fail)
- 原生组件优先（自定义组件有"为什么不用原生"理由）
- ≥12 个组件有完整规范（尺寸+状态+无障碍）
- 每个组件有平台差异标注（iOS vs Android）
- 遵循 Atomic Design 分层
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
